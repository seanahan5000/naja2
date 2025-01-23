
KEY_PEDESTAL    LDA #fileKeyCrystal
                CMP KEY_CRYSTAL_FILE
                BEQ :1
                LDY #>KEY_CRYSTAL_FILE
                JSR LOAD_FILE
:1              JMP DO_KEY_PEDESTAL

