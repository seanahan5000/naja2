PARRY           JSR CLEAR_WTIME
                JSR DRAW_PICT
                PictTextAt 102;150;"PARRY FOR HOW MANY T.UNITS?"
                PictTextAt 138;162;"<MAXIMUM: "
                PictEnd
                LDA TIMLEFT
                JSR DIGIT_DRAW
                LDA #TextGT
                STA TEXTBUF+2
                LDA #TextSpace
                STA TEXTBUF+3
                LDA #TextLineEnd
                STA TEXTBUF+4
                JSR DRAW_TEXTBUF

                LDA TIMLEFT
                JSR INPUT_SUB
                BCC NOMIND
                STA TIMTAKE
                TAX
                BEQ NOMIND
                LDA COMCNT
                BEQ NOBEFOR
                LDY COMPNTR
                LDA COMMAND-2,Y
                CMP #cmdPARRY
                BEQ BEFORE
NOBEFOR         LDA TIMTAKE
                STA INSTR2
                LDA #cmdPARRY
                STA INSTR1
                BNE GOCO1               ; always
BEFORE          STA INSTR1
                LDA COMMAND-1,Y
                STA INSTR2
                DEC COMCNT
                DEC COMPNTR
                DEC COMPNTR
                JSR COMND2
                DEC COMCNT
                LDY COMPNTR
                INY
                LDA COMMAND,Y
                CLC
                SED
                ADC TIMTAKE
                CLD
                STA INSTR2
GOCO1           JSR POST_COMMAND
NOMIND          JSR CLEAR_WTIME
                JSR OPTIONS
                JMP GETOP2
