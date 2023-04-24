
; GRID_HEIGHT     =   10
; GRID_WIDTH      =   5
; GCELL_WIDTH     =   15
; GCELL_HEIGHT    =   11

LEFT_SIDE       =   1

IGRID_YPNTS     =   AGRID_YPNTS

GINDEX          =   $C0
INDEX3          =   $C1
LEFT_RIGHT      =   $C2
BLOCK_DATA      =   $C3
DOT_MASK        =   BLOCK_DATA

; TODO: save these somewhere
AGRID_HALLS     DS  6                   ; these must be contiguous
CGRID_HALLS     DS  6                   ;   in this order

; TODO: save these somewhere
GRID_BITS       DS  10

GRID_HALLS      DS  6                   ; TODO: consider ZPAGE for this

A_TABLES
A_VLINE_Y1      DB  83,72-1
A_VLINE_Y2      DB  127+1,83+1
        do LEFT_SIDE
A_VLINE_XI      DB  1,9
A_HLINE_X1      DB  3,67,7
A_HLINE_X2      DB  7,86,67
A_GBITS_LRC     DB  0,%00010000,%00001111
        else
A_VLINE_XI      DB  3,11
A_HLINE_X1      DB  3,82,21
A_HLINE_X2      DB  22,86,83
A_GBITS_LRC     DB  %00000001,0,%00011110
        fin
A_HLINE_Y       DB  127,83
A_GBITS_OFF     DB  4,3,2,1,0

C_TABLES
C_VLINE_Y1      DB  127,171
C_VLINE_Y2      DB  171+1,183+7
        do LEFT_SIDE
C_VLINE_XI      DB  9,1
C_HLINE_X1      DB  67,3,7
C_HLINE_X2      DB  85,7,67
C_GBITS_LRC     DB  %00010000,0,%00001111
        else
C_VLINE_XI      DB  11,3
C_HLINE_X1      DB  82,3,21
C_HLINE_X2      DB  86,22,83
C_GBITS_LRC     DB  0,%00000001,%00011110
        fin
C_HLINE_Y       DB  127,171
C_GBITS_OFF     DB  5,6,7,8,9

VLINE_Y1        DS  2
VLINE_Y2        DS  2
VLINE_XI        DS  2
HLINE_X1        DS  3
HLINE_X2        DS  3
GBITS_LRC       DS  3
HLINE_Y         DS  2
GBITS_OFF       DS  5

; TODO:
;   - with and without grid
;   - green or white walls
;   - with or without extra boundaries?
;   - with and without L/R shift


; capture 3 rows of hall block data facing aliens and characters
;   (XSIDE bits are forced set for later use by LIMIT_HALLS)

CAPTURE_HALLS   JSR GET_NSEW
                LDX #5
:1              LDA BLOCK_BUFFER,X
                ORA #XSIDE_MASK
                STA AGRID_HALLS,X
                DEX
                BPL :1

                JSR MOVE_FORWARD
                JSR TURN_AROUND
                JSR GET_NSEW
                LDX #5
:2              LDA BLOCK_BUFFER,X
                ORA #XSIDE_MASK
                STA CGRID_HALLS,X
                DEX
                BPL :2
                JSR MOVE_FORWARD
                JMP TURN_AROUND


SET_APOINTS     LDY #0
                DB  $2C                 ; BIT abs
SET_CPOINTS     LDY #C_TABLES-A_TABLES
                LDX #0
:1              LDA A_VLINE_Y1,Y
                STA VLINE_Y1,X
                INY
                INX
                CPX #C_TABLES-A_TABLES
                BNE :1
                RTS

GET_ADATA       LDY #0
                DB  $2C                 ; BIT abs
GET_CDATA       LDY #6
                LDX #0
:1              LDA AGRID_HALLS,Y
                STA GRID_HALLS,X
                INY
                INX
                CPX #6
                BNE :1
                RTS

SET_ADATA       LDY #0
                DB  $2C                 ; BIT abs
SET_CDATA       LDY #6
                LDX #0
:1              LDA GRID_HALLS,X
                STA AGRID_HALLS,Y
                INY
                INX
                CPX #6
                BNE :1
                RTS
;
; mark squares that won't be accessible
;   by clearing their XSIDE_MASK values
;
LIMIT_HALLS     LDX #2
:1              LDY GRID_HALLS,X
                TYA
                AND #SIDE_MASK
;               CMP #SIDE_OPEN
                BNE :2
                TYA
                AND #XSIDE_MASK!$FF
                STA GRID_HALLS,X

                TYA
                AND #XFRONT_MASK
;               CMP #XFRONT_OPEN
                BNE :2
                LDA GRID_HALLS+2,X
                AND #XSIDE_MASK!$FF
                STA GRID_HALLS+2,X

:2              INX
                CPX #4
                BNE :1

:3              LDA GRID_HALLS-2,X
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BNE :4

                LDY GRID_HALLS,X
                TYA
                AND #SIDE_MASK
;               CMP #SIDE_OPEN
                BNE :4
                TYA
                AND #XSIDE_MASK!$FF
                STA GRID_HALLS,X

:4              INX
                CPX #6
                BNE :3
                RTS
;
; hide walls that are behind other contiguous walls
;
HIDE_WALLS      LDX #0
:1              LDY GRID_HALLS,X
                TYA
                AND #SIDE_MASK          ; if SIDE is set
;               CMP #SIDE_OPEN
                BEQ :2
                LDA GRID_HALLS+2,X
                AND #SIDE_MASK          ; and next.SIDE is set
;               CMP #SIDE_OPEN
                BEQ :2
                TYA
                AND #XFRONT_MASK!$FF    ;   then clear XFRONT
                STA GRID_HALLS,X
:2              INX
                CPX #4
                BNE :1

:3              LDY GRID_HALLS-2,X      ; top row only
                TYA
                AND #FRONT_MASK             ; if prev.FRONT is set
;               CMP #FRONT_OPEN
                BEQ :4
                TYA
                AND #SIDE_MASK+XFRONT_MASK  ;   and prev.SIDE or prev.XFRONT are set
                BEQ :4
                LDA GRID_HALLS,X
                AND #SIDE_MASK!$FF          ;   then clear SIDE
                STA GRID_HALLS,X
:4              INX
                CPX #6
                BNE :3
                RTS


BUILD_GRID      JSR CAPTURE_HALLS

                JSR GET_ADATA
                JSR SET_APOINTS
                JSR LIMIT_HALLS
                JSR HIDE_WALLS
                JSR BUILD_GRIDBITS
                JSR SET_ADATA

                JSR GET_CDATA
                JSR SET_CPOINTS
                JSR LIMIT_HALLS
                JSR HIDE_WALLS
                JSR BUILD_GRIDBITS
                JMP SET_CDATA

DRAW_GRID2      JSR GET_ADATA
                JSR SET_APOINTS
                LDX #0
                LDY #4
                JSR DRAW_GRID_DOTS
                JSR DRAW_WALLS

                JSR GET_CDATA
                JSR SET_CPOINTS
                LDX #5
                LDY #11
                JSR DRAW_GRID_DOTS
                JSR DRAW_WALLS

                JSR DRAW_DOTTED

                JSR FIRST_CHAR
:1              JSR DRAW_CHAR_TOPVIEW
                JSR NEXT_CHAR
                BCC :1
                RTS


BUILD_GRIDBITS  LDY #0
:1              STY GINDEX
                LDX HALL_OFFS,Y
                LDY #$00

                LDA GRID_HALLS+0,X
                AND #XSIDE_MASK
;               CMP #XSIDE_OPEN
                BEQ :2
                TYA
                ORA GBITS_LRC+0
                TAY

:2              LDA GRID_HALLS+1,X
                AND #XSIDE_MASK
;               CMP #XSIDE_OPEN
                BEQ :3
                TYA
                ORA GBITS_LRC+1
                TAY
:3
                LDA GRID_HALLS-2,X
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BEQ :5
                TYA
                ORA GBITS_LRC+2
                TAY

:5              TYA
                LDY GINDEX
                LDX GBITS_OFF,Y
                STA GRID_BITS,X
                INY
                CPY #5
                BNE :1
                RTS

HALL_OFFS       DB  2,2,2,2,4           ; both


DRAW_WALLS      JSR SET_GREEN
                LDX #0
:1              STX GINDEX
                LDA GRID_HALLS,X
                STA BLOCK_DATA
                TXA
                LSR
                STA INDEX3
                LDA #0
                ROL
                STA LEFT_RIGHT

                CPX #2
                BCC :3
                LDA BLOCK_DATA
                AND #SIDE_MASK
;               CMP #SIDE_OPEN
                BEQ :2
                JSR DRAW_VLINE          ; 2,4
                LDX GINDEX
:2
                CPX #4
                BCS :4
                LDA BLOCK_DATA
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BEQ :3
                JSR DRAW_HLINE_C        ; 2
:3
                LDA BLOCK_DATA
                AND #XFRONT_MASK
;               CMP #XFRONT_OPEN
                BEQ :4
                JSR DRAW_HLINE_LR       ; 0,2
:4
                LDX GINDEX
                INX
                CPX #6
                BNE :1
                RTS


DRAW_HLINE_C    LDX INDEX3
                LDY HLINE_Y,X
                LDX HLINE_X1+2
                JSR MOVE_TO
                LDX HLINE_X2+2
                JMP HLINE_TO


DRAW_HLINE_LR   LDX INDEX3
                LDY HLINE_Y,X
                JSR VMOVE_TO
                LDY LEFT_RIGHT
                LDX HLINE_X1,Y
                JSR HMOVE_TO
                LDY LEFT_RIGHT
                LDX HLINE_X2,Y
                JMP HLINE_TO


DRAW_VLINE      LDY INDEX3
                LDX VLINE_Y1-1,Y
                LDA VLINE_Y2-1,Y
                STA :MOD+1
                LDY LEFT_RIGHT
                LDA VLINE_XI,Y
                TAY
:1              JSR SET_SOURCE_LINE
                LDA (SCREENL),Y
                AND AND_BYTES,Y
                ORA OR_BYTES,Y
                STA (SCREENL),Y
                INX
:MOD            CPX #$FF
                BNE :1
                RTS

AND_BYTES       HEX 00FE00FC00FB00F300EF009F
OR_BYTES        HEX 000100010004000400100040


DRAW_GRID_DOTS  STY :MOD+1
:1              STX GINDEX
                LDY IGRID_YPNTS,X
                DEY
                JSR VMOVE_TO
                CPX #10
                BCC :2
                DEX
:2              LDA GRID_BITS,X
                ASL
                ORA GRID_BITS,X
                EOR #%00111111
                JSR DRAW_DOT_ROW
                LDX GINDEX
                INX
:MOD            CPX #$FF
                BNE :1
                RTS

DRAW_DOT_ROW    STA DOT_MASK
                LDX YCOORD
                JSR SET_SOURCE_LINE
                LDX #0
:1              LDY DOT_COLS,X
                LSR DOT_MASK
                BCC :2
                LDA (SCREENL),Y
                ORA BIT_TABLE,X
                STA (SCREENL),Y
:2              INX
                CPX #6
                BNE :1
                RTS

DOT_COLS        DB  1,3,5,7,9,11

DRAW_DOTTED     LDX #127
                JSR SET_SOURCE_LINE
                LDY #11
:1              LDA DOTTED_LINE,Y
                STA (SCREENL),Y
                DEY
                BPL :1
                RTS

DOTTED_LINE     HEX 001122440811224408112244
