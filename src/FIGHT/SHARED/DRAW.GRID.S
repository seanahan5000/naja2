
IGRID_YPNTS     =   AGRID_YPNTS

GINDEX          =   $C0
INDEX3          =   $C1
LEFT_RIGHT      =   $C2
BLOCK_DATA      =   $C3
DOT_MASK        =   BLOCK_DATA

A_DRAW_TABLES
A_VLINE_Y1      DB  83,71
A_VLINE_Y2      DB  128,83
A_VLINE_XI      DB  0,9
A_HLINE_X1      DB  1,70,3
A_HLINE_X2      DB  4,86,71
A_HLINE_Y       DB  127,82

C_DRAW_TABLES
C_VLINE_Y1      DB  127,172
C_VLINE_Y2      DB  172,190
C_VLINE_XI      DB  9,0
C_HLINE_X1      DB  70,1,3
C_HLINE_X2      DB  86,4,71
C_HLINE_Y       DB  127,172

VLINE_Y1        DS  2
VLINE_Y2        DS  2
VLINE_XI        DS  2
HLINE_X1        DS  3
HLINE_X2        DS  3
HLINE_Y         DS  2


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
                LDY #5
                JSR DRAW_GRID_DOTS
                JSR DRAW_WALLS

                JSR GET_CDATA
                JSR SET_CPOINTS
                LDX #6
                LDY #11
                JSR DRAW_GRID_DOTS
                JSR DRAW_WALLS

                JSR DRAW_DOTTED

                JSR FIRST_CHAR
:2              JSR DRAW_CHAR_TOPVIEW
                JSR NEXT_CHAR
                BCC :2
                RTS

DRAW_WALLS      JSR SET_WHITE1
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
                ORA OR_BYTES,Y
                STA (SCREENL),Y
                INY
                LDA (SCREENL),Y
                ORA OR_BYTES,Y
                STA (SCREENL),Y
                DEY
                INX
:MOD            CPX #$FF
                BNE :1
                RTS

OR_BYTES        HEX 180000000000000000000300

DRAW_GRID_DOTS  STY :MOD+1
:1              STX GINDEX
                LDY IGRID_YPNTS,X
                DEY
                JSR VMOVE_TO
                CPX #10
                BCC :2
                DEX
:2              LDA GRID_BITS,X
                LSR
                ORA GRID_BITS,X
                CPX #1
                BCC :3
                ORA GRID_BITS-1,X
:3              EOR #%01111111
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
                ORA DOT_BITS,X
                STA (SCREENL),Y
:2              INX
                CPX #6
                BNE :1
                RTS

DOT_COLS        DB  0,3,5,7,9,12

DOT_BITS        DB  %00100000
                DB  %00000001
                DB  %00000100
                DB  %00010000
                DB  %01000000
                DB  %00000010

DRAW_DOTTED     LDY #0
                LDA #10
                JSR :DOTTED_SUB
                LDA GRID_BITS+4
                AND GRID_BITS+5
                AND #%00100000
                BNE :2
                LDY #10
                LDA #12
:DOTTED_SUB     STA :MOD1+1
                LDX #127
                JSR SET_SOURCE_LINE
:1              LDA DOTTED_LINE,Y
                ORA (SCREENL),Y
                STA (SCREENL),Y
                INY
:MOD1           CPY #$FF
                BNE :1
:2              RTS

DOTTED_LINE     HEX 081122440811224408112244
