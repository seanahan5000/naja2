
KING_RUUIK      LDA RUUIK_MOD
                CMP #modRuuik
                BEQ :1
                LDX #fileRuuik
                JSR LOAD_FILE
:1              JMP RUUIK
