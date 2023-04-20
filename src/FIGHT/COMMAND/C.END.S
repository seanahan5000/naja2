END             LDY COMPNTR
                LDA #$8A
                STA COMMAND,Y
                INY
                LDA #$72
                STA COMMAND,Y
                JSR SHRINK_TUNITS
                JSR DOTIME2
                JMP OPT_CURSOR
