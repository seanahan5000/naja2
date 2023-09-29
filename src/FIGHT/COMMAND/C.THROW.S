THROW           JSR CLEAR_CANCEL_IN
                JSR DRAW_PICT
                PictTextAt 102;133;"CONFIRM OBJECT TO BE THROWN"
                PictEnd

                LDA #$02
                JSR SELECT_HAND
                LDX CURSOR
                STX CURHOLD
                STX USEDLOC
                LDY CONVERT_TABLE,X
                INY
                LDX #cmdTHROW
                LDA (CHARDL),Y
                CMP #$01            ;Gyro boomerang
                BNE :SKIPA
                LDX #cmdTHROW+%00010000
:SKIPA          STX INSTR1
                JSR DRAW_PICT
                PictTextAt 96;142;"THROW OBJECT TO WHICH SQUARE?"
                PictEnd
                LDX USEDLOC
                LDA #$FF
                STA HANDTAB,X
                JSR BOTTOMR
                JSR GRID_AIM
                BCC :EXIT
                LDY CURSOR
                JSR I25_TO_APOS
                TAY
                LDA CURHOLD
                CLC
                ROR
                ROR
                ROR
                ORA INSTR1
                TAX
                LDA TIMES+timeTHROW
                JSR GENERAL_POST
                JSR TAKE_ENERUSE
:EXIT           JSR DRAW_GCURSOR
                JMP DID_CANCEL
