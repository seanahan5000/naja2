
KING_RUUIK      LDA #fileRuuik
                CMP RUUIK_FILE
                BEQ :1
                LDY #>RUUIK_FILE
                JSR LOAD_FILE
:1              JMP RUUIK
