*** Any status or mind control that would prevent the
***   character from moving has already been filtered
***   out and narrated.

*** Illegal moves caused by characters being moved
***   against their wills should have already been
***   altered or removed.  It's not trapped here
***   because which way they were moved can't be
***   be determined from info available here.

CHR_MOVE        JSR CCMD_INDEXER
                LDA CGRID_MAIN,Y
                BMI :SKIPB

                LDX CHAR_NUMBER     ;If character is presently
                LDA TEMPCHAR_XY,X   ;   in the front row...
                AND #%00001111
                CMP #$05
                BNE :SKIPA

                CPY #5              ;   and is moving to the
                BCC :SKIPA          ;   second row...
                CPY #10
                BCS :SKIPA

                LDX #5              ;   make sure someone else
:LOOP1          DEX                 ;   is in the front row.
                BMI :SKIPB
                LDA CGRID_MAIN,X
                BEQ :LOOP1              ; empty
                ASL
                BMI :LOOP1              ; image gen
                ASL
                BMI :LOOP1              ; cellBlocked
                LSR
                LSR
                AND #%00000111
                CMP CHAR_NUMBER
                BEQ :LOOP1              ; current character

:SKIPA          ; LDX CHAR_NUMBER     ;Destination is okay
                ; LDA TEMPCHAR_XY,X   ;   so do the move
                ; JSR XYTEXT
                JSR GET_CMD_XY
                LDX CHAR_NUMBER
                STA TEMPCHAR_XY,X
                ; JSR XYTEXT
                JSR CHANGE_CGRID
                JMP CCOM

:SKIPB          LDX CHAR_NUMBER     ;Some one is in the way
                LDA #$01            ;   so wait 1 time unit
                STA CTIME_COUNTS,X  ;   and try again later
                RTS
