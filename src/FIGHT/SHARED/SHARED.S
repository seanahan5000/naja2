
MASK_BITS       =   TEMP                ;***

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
I25_TO_CPOS     ENT
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

CGRID_MAIN      ENT
                DS  25                  ; TODO: move to storage area
