REDO            JSR CLEAR_CANCEL_IN
                JSR DRAW_PICT
                PictSetOrange
                PictMoveTo $9D;$9C
                PictLineTo $CF;$9C
                PictMoveTo $A1;$9E
                PictLineTo $CB;$9E
                PictTextAt 159;147;(>>REDO<<)
                PictTextAt 114;165;(PRESS_<SPACE>_TO_VERIFY)
                PictEnd

                JSR SPACE_WAIT
                BCC NOTSURE
                LDY COMPNTR
                LDA #$8A
                STA COMMAND,Y
                JSR DENERGY
                JSR CANCEL_OUT
                JSR CLEAR_WTIME
                JSR SHRINK_TUNITS
                PLA
                PLA
                JMP PLANSUB
NOTSURE         JMP DID_CANCEL

*-------------------------------

DENERGY         LDA PLANNER
                ASL
                ASL
                ASL
                ASL
                ASL
                STA COUNT
:LOOP1          LDY COUNT
                LDA COMMAND,Y
                CMP #$8A
                BEQ :EXIT
                AND #$0F
                CMP #$02
                BNE :SKIPA
                LDA COMMAND-2,Y
                LSR
                LSR
                LSR
                LSR
                JSR SPENSUB
:SKIPA          INC COUNT
                INC COUNT
                BNE :LOOP1
:EXIT           RTS
