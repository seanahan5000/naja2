DELAY           JSR CLEAR_WTIME

                JSR DRAW_PICT
                PictTextAt 132;146;"MAXIMUM DELAY: 99"
                PictTextAt 132;156;"CURRENT DELAY: "
                PictEnd

                LDA DELAY_TIME
                JSR DIGIT_DRAW
                JSR DRAW_TEXTBUF

                JSR DRAW_PICT
                PictTextAt 156;166;"NEW_DELAY: "
                PictEnd

                LDA #$99
                JSR INPUT_SUB
                BCC :1
                STA DELAY_TIME
:1              JSR CLEAR_WTIME
                JSR OPTIONS
                JMP GETOP2

DIGIT_DRAW      PHA
                LSR
                LSR
                LSR
                LSR
                BNE :1
                LDA #TextSpace
:1              STA TEXTBUF+0
                PLA
                AND #$0F
                STA TEXTBUF+1
                LDA #TextLineEnd
                STA TEXTBUF+2
                RTS
;
; On entry:
;   A: max input value
;
INPUT_SUB       STA SCRATCH
                LDA #$02
                JSR GET_NUMBER_LIMIT
:1              DEX
                BMI :4
                LDA TEXT_BUFFER+0
                DEX
                BMI :2
                ASL
                ASL
                ASL
                ASL
                ORA TEXT_BUFFER+1
:2              CMP SCRATCH
                BEQ :3
                BCS :5
:3              SEC
                RTS
:4              CLC
                RTS
:5              JSR REGET_INPUT
                JMP :1
