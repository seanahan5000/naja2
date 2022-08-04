
                PUT /NAJA/VARS/CONSTANTS
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
POINTIT         ENT                 ; legacy name
SET_CHAR        ENT
                CLC
                ADC #1
                LSR
                PHP
                CLC
                ADC #$BC
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
                LDA #$80
                STA CHARDL
                LDA #$BC
                STA CHARDH
                LDX #0
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
