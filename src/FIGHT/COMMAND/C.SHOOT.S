SHOOT           JSR CLEAR_CANCEL_IN
                JSR DRAW_PICT
                PictTextAt 105;133;"CONFIRM WEAPON TO BE AIMED"
                PictEnd
                LDA #$01
                JSR SELECT_HAND
                JSR GETUSCO
                JSR DRAW_PICT
                PictTextAt 123;142;"AIM AT WHICH SQUARE?"
                PictEnd
                JSR BOTTOMR
                JSR GRID_AIM
                BCS :SKIPA
                JSR DRAW_GCURSOR
                JMP DID_CANCEL

:SKIPA          JSR DRAW_PICT
                PictClear 17;142;35;149
                PictEnd
                LDY CURSOR
                JSR I25_TO_APOS
                TAY
                LDX #cmdAIM
                LDA TIMES+timeAIM
                JSR GENERAL_POST
                LDX COMCNT
                LDA TIMLEFT
                STA CTIMTAB,X
                JSR DRAW_PICT
                PictTextAt 123;132;"FIRE HOW MANY TIMES?"
                PictTextAt 131;143;"="
                PictTextAt 147;143;"OF SHOTS:"
                PictEnd
                LDX #$85
                LDY #$8F
                JSR NUMBER_SIGN
                LDX #<LIMIT_SWNSHT
                LDY #>LIMIT_SWNSHT
                JSR GET_MULTIPLE
                BCS :SKIPB
                JSR DRAW_GCURSOR
                JSR CANCEL_OUT
                JSR DOTIME
                JSR SWNSHT_UNDO
                JMP BACK1

:SKIPB          LDA #cmdSHOOT
                STA INSTR1
                JSR CHANDER
                LDA HOWCUR1
                ASL
                ASL
                ASL
                ASL
                ORA HOWCUR2
                STA INSTR2
                LDX USEDLOC
                LDA HANDTAB,X
                LSR
                AND #$01
                CLC
                ROR
                ROR
                ORA INSTR2
                STA INSTR2
                LDA #0
                STA TIMTAKE
                JSR POST_COMMAND
                JSR DRAW_GCURSOR
                JMP DID_CANCEL
