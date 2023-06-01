
; GRID_HEIGHT     =   10
; GRID_WIDTH      =   5
; GCELL_WIDTH     =   15
; GCELL_HEIGHT    =   11

IGRID_YPNTS     =   AGRID_YPNTS

GINDEX          =   $C0
INDEX3          =   $C1
LEFT_RIGHT      =   $C2
BLOCK_DATA      =   $C3
DOT_MASK        =   BLOCK_DATA

A_DRAW_TABLES
A_VLINE_Y1      DB  83,72-1
A_VLINE_Y2      DB  127+1,83+1
        do LEFT_SIDE_GRID
A_VLINE_XI      DB  1,9
A_HLINE_X1      DB  3,67,7
A_HLINE_X2      DB  7,86,67
        else
A_VLINE_XI      DB  3,11
A_HLINE_X1      DB  3,82,21
A_HLINE_X2      DB  22,86,83
        fin
A_HLINE_Y       DB  127,83

C_DRAW_TABLES
C_VLINE_Y1      DB  127,171
C_VLINE_Y2      DB  171+1,183+7
        do LEFT_SIDE_GRID
C_VLINE_XI      DB  9,1
C_HLINE_X1      DB  67,3,7
C_HLINE_X2      DB  85,7,67
        else
C_VLINE_XI      DB  11,3
C_HLINE_X1      DB  82,3,21
C_HLINE_X2      DB  86,22,83
        fin
C_HLINE_Y       DB  127,171

VLINE_Y1        DS  2
VLINE_Y2        DS  2
VLINE_XI        DS  2
HLINE_X1        DS  3
HLINE_X2        DS  3
HLINE_Y         DS  2

; TODO:
;   - with and without grid
;   - green or white walls
;   - with or without extra boundaries?
;   - with and without L/R shift


SET_APOINTS     LDY #0
                DB  $2C                 ; BIT abs
SET_CPOINTS     LDY #C_DRAW_TABLES-A_DRAW_TABLES
                LDX #0
:1              LDA A_VLINE_Y1,Y
                STA VLINE_Y1,X
                INY
                INX
                CPX #C_DRAW_TABLES-A_DRAW_TABLES
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

DRAW_GRID2      ENT
                JSR GET_ADATA
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
