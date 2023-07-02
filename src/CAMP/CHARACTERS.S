;
; On entry:
;   A: character index
;
; On exit:
;   X: unchanged
;   Y: unchanged
;   Other ZPAGE unchanged
;   CHARDL,H: pointing at given character
;
; Does not set CHAR_INDEX for compatibility
;
SET_CHAR        ENT
                LSR
                PHP
                CLC
                ADC #>CHAR_0
                STA CHARDH
                LDA #$00
                PLP
                ROR
                STA CHARDL
                RTS
;
; On exit:
;   X: character index (0)
;   Y: unchanged
;   CHAR_INDEX: 0
;   Other ZPAGE unchanged
;
FIRST_CHAR      ENT
                LDA #>CHAR_0
                STA CHARDH
                LDX #0
                STX CHARDL
                STX CHAR_INDEX
                RTS
;
; On exit:
;   X: character index
;   Y: unchanged
;   CHAR_INDEX: incremented
;   Other ZPAGE unchanged
;   C=0: more characters remain
;   C=1: list complete
;
NEXT_CHAR       ENT
                LDX CHAR_INDEX
                INX
                STX CHAR_INDEX
                CPX GROUP_SIZE
                BCS :1
                LDA CHARDL
                EOR #$80
                STA CHARDL
                BNE :1
                INC CHARDH
:1              RTS
;
; On entry:
;   CHARDL/H pointing at possible cybernate
;
; On exit:
;   CHARDL/H pointing at robot, if found
;   A: robot character index or $FF if not found
;   N: BMI/BPL of A value
;
FIND_ROBOT      LDY #profrace
                LDA (CHARDL),Y
                AND #$F0
                CMP #cybernate*16
                BNE :2
                LDY #disklocation
                LDA (CHARDL),Y
                STA :MOD+1
                JSR FIRST_CHAR
:1              LDY #robotcyblink
                LDA (CHARDL),Y
:MOD            CMP #$FF
                BEQ :3
                JSR NEXT_CHAR
                BCC :1
:2              LDA #$FF
                RTS
:3              LDA CHAR_INDEX
                RTS
;
; On entry:
;   A: index of character to be hidden
;
HIDE_MEMBER     STA CHAR_INDEX
                JSR SET_CHAR
:1              LDA CHARDL
                STA DESTINL
                LDA CHARDH
                STA DESTINH
                JSR NEXT_CHAR
                BCS :3
                LDY #$7F
:2              LDA (CHARDL),Y
                TAX
                LDA (DESTINL),Y
                STA (CHARDL),Y
                TXA
                STA (DESTINL),Y
                DEY
                BPL :2
                BMI :1                  ; always
:3              DEC GRPNUMB
                RTS
;
; On entry:
;   CHARDL/H pointing at possible robot
;
; On exit:
;   X: unchanged
;   SEC: is robot
;   CLC: is not robot
;
IS_ROBOT        ENT
                LDY #profrace
                LDA (CHARDL),Y
                ASL
                RTS
