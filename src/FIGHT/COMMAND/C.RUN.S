RUN             LDX #cmdRUN
                LDY #$00
                LDA TIMES+allTime
                JSR GENERAL_POST
                JSR CLEAR_WTIME
                JSR OPTIONS
                JMP GETOP2
