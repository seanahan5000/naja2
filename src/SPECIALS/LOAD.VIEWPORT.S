
AIRLOCK         JSR LOAD_VIEWPORT
                JMP DO_AIRLOCK

VIEWPORT        PHA
                JSR LOAD_VIEWPORT
                PLA
                JMP DO_VIEWPORT

LOAD_VIEWPORT   LDA #fileViewport
                CMP VIEWPORT_FILE
                BEQ :1
                LDY #>VIEWPORT_FILE
                JMP LOAD_FILE
:1              RTS
