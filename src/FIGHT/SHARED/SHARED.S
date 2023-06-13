
CGRID_MAIN      ENT
                DS  25                  ; TODO: move to storage area

AGRID_MAIN      ENT
                DS  25                  ; TODO: move to storage area

MASK_BITS       =   TEMP                ;***

;---------------------------------------

INIT_CGRID      ENT
                LDY #0
                LDX #0
:1              STX COUNT
                LDA GRID_BITS+5,X
                STA MASK_BITS
                LDX #0
:2              LSR MASK_BITS
                ROR
                ROR
                ROR
                AND #cellBlocked
:3              STA CGRID_MAIN,Y
                INY
                INX
                CPX #5
                BNE :2
                LDX COUNT
                INX
                CPX #5
                BNE :1
                RTS
;
; On entry:
;   Y: 0 to 24 in character grid
;
; On exit:
;   A: 11 coordinate in character grid
;
I25_TO_CPOS     ENT
                LDA #$05


                LDA MOD5,Y
                ASL
                ASL
                ASL
                ASL
;               CLC
                ADC #$10
                STA :MOD+1
                LDA #$05
                SEC
                SBC DIV5,Y
:MOD            ORA #$FF
                RTS
;
; On entry:
;   X: 0 to 24 in character grid
;
; On exit:
;   Draw position set to character grid cell
;
I25_MOVETO_CGRID ENT
                LDY MOD5,X
                LDA GRID_XPNTS,Y
                PHA
                LDY DIV5,X
                LDA CGRID_YPNTS,Y
                TAY
                PLA
                TAX
                JMP MOVE_TO

;---------------------------------------

INIT_AGRID      ENT
                LDY #0
                LDX #0
:1              STX COUNT
                LDA GRID_BITS+0,X
                STA MASK_BITS
                LDX #0
:2              LSR MASK_BITS
                ROR
                ROR
                ROR
                AND #cellBlocked
:3              STA AGRID_MAIN,Y
                INY
                INX
                CPX #5
                BNE :2
                LDX COUNT
                INX
                CPX #5
                BNE :1
                RTS
;
; On entry:
;   Y: 0 to 24 in character grid
;
; On exit:
;   A: 11 coordinate in character grid
;
I25_TO_APOS     ENT
                JSR I25_TO_CPOS
                CLC
                ADC #$05
                RTS

;---------------------------------------

EZONE_CURSOR    ENT
                LDY CURSOR
                LDX MOD5,Y
                LDA DIV5,Y
                TAY
                LDA GRID_XPNTS,X
                PHA
                TAX
                LDA AGRID_YPNTS,Y
                PHA
                TAY
                DEX
                BIT EZONE_FLAG
                BPL :1
                TXA
                CLC
                ADC #cellWidth
                TAX
:1              JSR MOVE_TO
                LDX #<EZONE_VERT
                LDY #>EZONE_VERT
                JSR NEW_DRAW_SHAPE

                PLA
                TAY
                PLA
                TAX
                DEY
                BIT EZONE_FLAG
                BPL :2
                TYA
                CLC
                ADC #cellHeight
                TAY
:2              JSR MOVE_TO
                LDX #<EZONE_HORZ
                LDY #>EZONE_HORZ
                JMP NEW_DRAW_SHAPE

; TODO: turn this into a parameter instead of setting directly
EZONE_FLAG      ENT
                DB  0

EZONE_VERT      DB  $12,$00
                DB  %10000001
                DB  %00000001
                DB  %00000001
                DB  %00000001
                DB  %10000000

EZONE_HORZ      DB  $21,$00
                DB  %01111111
                DB  %10000000
                DB  %01111111
                DB  %10000000

*-------------------------------
