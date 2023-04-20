
REFRESH_STATS   JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictSetGreen
        do SMALL_GROUP
                PictRect $01;$01;$115;$44
                PictMoveTo $01;11
                PictLineTo $115;11
                PictVMoveTo 3
        else
                PictRect $01;$00;$115;$44
                PictMoveTo $01;$0A
                PictLineTo $115;$0A
                PictVMoveTo 2
        fin
                PictHMoveTo 105
                PictText (EL)
                PictHMoveTo 121
                PictText (PH)
                PictHMoveTo 147
                PictText (STATUS)
                PictHMoveTo 192
                PictText (IQ_ST_LR_UR_OR)
        do SMALL_GROUP
                PictVMove 11
        else
                PictVMove 10
        fin
                PictEnd

                JSR FIRST_CHAR
:1              LDA #statsShielding+statsStatus
                JSR STATS_LINE2
                JSR MORE_STATS
                LDX #$C0
                JSR DRAW_TEXTBUF_X
        do SMALL_GROUP
                LDY #9
        else
                LDY #8
        fin
                JSR VMOVE
                JSR NEXT_CHAR
                BCC :1
                LDA #$00
                STA FLIPPED_FLAG
                JSR SET_PAGE1
                RTS

FLIPPED_FLAG    DB  0

MORE_STATS      LDY #$0D
                LDA #TextSpace
SPACOUT         STA TEXTBUF,Y
                DEY
                BPL SPACOUT
                LDA #TextLineEnd
                STA TEXTBUF+14
                LDA #$00
                STA COUNTER
                STA XSPOT
NEXTST          LDY COUNTER
                LDA STPICKR,Y
                TAY
                LDA (CHARDL),Y
                TAX
                AND #$F0
                BEQ FIRST0
                LSR
                LSR
                LSR
                LSR
                LDY XSPOT
                STA TEXTBUF,Y
FIRST0          INC XSPOT
                TXA
                AND #$0F
                LDY XSPOT
                STA TEXTBUF,Y
                LDA XSPOT
                CLC
                ADC #$02
                STA XSPOT
                LDA COUNTER
                INC COUNTER
                CMP #$05
                BNE NEXTST
                RTS

STPICKR         DB  intelligence
                DB  strength
                DB  lwreflex
                DB  upreflex
                DB  organic
