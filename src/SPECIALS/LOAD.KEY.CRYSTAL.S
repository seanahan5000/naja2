
; TODO: could add other cells that preload crystal code

KEY_PEDESTAL    JSR LOAD_CRYSTAL
                JMP DO_CRYSTAL

LOAD_CRYSTAL    LDA #fileKeyCrystal
                CMP KEY_CRYSTAL_FILE
                BEQ :1
                LDY #>KEY_CRYSTAL_FILE
                JSR LOAD_FILE
                JSR EXPAND_RINGS
:1              RTS
