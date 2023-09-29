IDENTIFY        JSR CLEAR_CANCEL_IN
                JSR DRAW_PICT
                PictTextAt 112;141;"DO YOU WANT TO I.D. SCAN"
                PictTextAt 138;154;"AN INDIVIDUAL SQUARE"
                PictTextAt 138;164;"THE ENTIRE AREA"
                PictEnd
                LDX #<ID_CDEF
                LDY #>ID_CDEF
                JSR FULL_GETKEY
                BCC :SKIPB
                LDA #cmdIDENTIFY
                STA INSTR1
                LDA #$80
                STA INSTR2
                LDA CURSOR
                BNE :SKIPA
                JSR CLEAR_WCANCEL
                JSR DRAW_PICT
                PictTextAt 115;152;"I.D. SCAN WHICH SQUARE?"
                PictEnd
                JSR GRID_AIM
                PHP
                JSR DRAW_GCURSOR
                PLP
                BCC :SKIPB
                LDY CURSOR
                JSR I25_TO_APOS
                STA INSTR2
:SKIPA          LDA TIMES+timeIDENTIFY
                STA TIMTAKE
                LDY WHERE_IDSCAN
                JSR ENERUSE
                JSR TAKE_ENERUSE
                JSR POST_COMMAND
:SKIPB          JMP DID_CANCEL

WHERE_IDSCAN    DB  0

*-------------------------------

ID_CDEF         DB  $82
                DB  $00
                DW  :ID_CURS

:ID_CURS        LDY :YTABLE,X
                LDX #$7C
                JMP DRAW_ARROW

:YTABLE         DB  $9A,$A4

*-------------------------------
