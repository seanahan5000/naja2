
AIRLOCK         JSR LOAD_VIEWPORT
                JMP DO_AIRLOCK

VIEWPORT        PHA
                JSR LOAD_VIEWPORT
                PLA
                JMP DO_VIEWPORT

LOAD_VIEWPORT   LDA VIEWPORT_MOD
                CMP #modViewport
                BEQ :1
                LDX #fileViewport
                JSR LOAD_FILE
:1              RTS
