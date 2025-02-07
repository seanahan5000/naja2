
; *** load should also expand rings ***
; *** preload

KEY_PEDESTAL2   LDA #fileKeySand
                CMP KEY_SAND_FILE
                BEQ :1
                LDY #>KEY_SAND_FILE
                JSR LOAD_FILE
:1              JMP DO_SAND

