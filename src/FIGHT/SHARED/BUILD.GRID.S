
A_BUILD_TABLES
        do LEFT_SIDE_GRID
A_GBITS_LRC     DB  0,%00010000,%00001111
        else
A_GBITS_LRC     DB  %00000001,0,%00011110
        fin
A_GBITS_OFF     DB  4,3,2,1,0

C_BUILD_TABLES
        do LEFT_SIDE_GRID
C_GBITS_LRC     DB  %00010000,0,%00001111
        else
C_GBITS_LRC     DB  0,%00000001,%00011110
        fin
C_GBITS_OFF     DB  5,6,7,8,9

GBITS_LRC       DS  3
GBITS_OFF       DS  5
;
; caller must have called CAPTURE_HALLS
;
BUILD_GRID      ENT
                JSR GET_ADATA
                JSR SET_AGBITS
                JSR LIMIT_HALLS
                JSR HIDE_WALLS
                JSR BUILD_GRIDBITS
                JSR SET_ADATA

                JSR GET_CDATA
                JSR SET_CGBITS
                JSR LIMIT_HALLS
                JSR HIDE_WALLS
                JSR BUILD_GRIDBITS
                JMP SET_CDATA

SET_AGBITS      LDY #0
                DB  $2C                 ; BIT abs
SET_CGBITS      LDY #C_BUILD_TABLES-A_BUILD_TABLES
                LDX #0
:1              LDA A_GBITS_LRC,Y
                STA GBITS_LRC,X
                INY
                INX
                CPX #C_BUILD_TABLES-A_BUILD_TABLES
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
