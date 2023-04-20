THROW           JSR CLEAR_CANCEL_IN
                JSR DRAW_PICT
                PictTextAt 102;133;(CONFIRM_OBJECT_TO_BE_THROWN)
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
                PictTextAt 96;142;(THROW_OBJECT_TO_WHICH_SQUARE?)
                PictEnd
                LDX USEDLOC
                LDA #$FF
                STA HANDTAB,X
                JSR BOTTOMR
                JSR GET_AIM
                BCC :EXIT
                LDY CURSOR
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
:EXIT           JSR DRAW_GRIDCURS
                JMP DID_CANCEL
