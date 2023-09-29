USE             JSR CLEAR_CANCEL_IN
                JSR DRAW_PICT
                PictTextAt 108;133;"CONFIRM OBJECT TO BE USED"
                PictEnd

                LDA #$03
                JSR SELECT_HAND
                JSR GETUSCO
                LDA CURSOR
                CLC
                ROR
                ROR
                ROR
                ORA #cmdUSE
                STA INSTR1
                LDA TIMES+timeUSE
                STA TIMTAKE
                LDX CURSOR
                LDY CONVERT_TABLE,X
                LDA (CHARDL),Y
                CMP #$63            ;Miscellaneous
                BNE :SKIPA
                JSR POST_COMMAND
                JMP DID_CANCEL

:SKIPA          JSR CLEAR_WCANCEL
                JSR DRAW_PICT
                PictTextAt 114;137;"SELECT SQUARE TO DIRECT"
                PictTextAt 132;146;"TREATMENT TOWARDS"
                PictEnd
                JSR BOTTOMR

                SEC
                LDX #<FILTER_USE
                LDY #>FILTER_USE
                JSR SELECT_CELL

NOUCANC         LDA CURSOR
                ASL
                ASL
                ASL
                ASL
                AND #$30
                ORA INSTR1
                STA INSTR1

                JSR DRAW_PICT
                PictClear 16;137;36;153
                PictTextAt 120;132;"HEAL HOW MUCH DAMAGE?"
                PictTextAt 117;143;"DAMAGE HEALED:"
                PictEnd
                LDX #<LIMIT_USE
                LDY #>LIMIT_USE
                JSR GET_MULTIPLE
                PHP
                JSR DRAW_GROUP_CURSOR2
                PLP
                BCS :SKIPA
                JSR DE_ENERLEV
                JMP DID_CANCEL
:SKIPA          LDA HOWCUR1
                ASL
                ASL
                ASL
                ASL
                ORA HOWCUR2
                STA INSTR2
                JSR POST_COMMAND
                JMP DID_CANCEL

FILTER_USE      JSR CHECK_CANCEL
                BNE :1
                PLA
                PLA
                JSR DRAW_GROUP_CURSOR2
                JMP DID_CANCEL
:1              RTS
