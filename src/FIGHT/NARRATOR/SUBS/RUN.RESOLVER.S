*=========================================
* This is called from the CONTROL routine
*   at the end of a round and should
*   only directly return if neither the
*   monster nor the character front rows
*   are empty.
*=========================================

OPEN_FRONTS     JSR MONS_OPENROWS
                JSR CHAR_OPENROWS
                LDA COFFSET
                ORA MOFFSET
                BNE :0
                RTS                 ;No front row empty so return

:0              LDA #$7F            ;Retreat
                STA CHAR_ADVFLAG

                JSR DRAW_PICT
                PictTextAt 99;143;"THERE IS SPACE IN THE FRONT"
                PictTextAt 99;152;"ROW TO BE OCCUPIED. WILL THE"
                PictTextAt 99;161;"GROUP A>DVANCE OR"
                PictTextAt 135;170;"R>ETREAT? "
                PictEnd

                JSR GET_INPUT_KEY
:1              CMP #"A"
                BEQ :3
                CMP #"R"
                BEQ :4
:2              JSR REGET_INPUT
                JMP :1
:3              LDA #$FF            ;Advance
                STA CHAR_ADVFLAG
:4              JSR CLRBOX
                ; fall through

*-------------------------------
*
*-------------------------------

topLine         =   71
bottomLine      =   190

RUN_RESOLVER    JSR MRUN_DECIDER
                JSR RUN_BEGIN

                LDX MOFFSET         ;Calc MONS_GAP and MSRC_BOT
                JSR TIMES_CELL_HEIGHT
                STA MONS_GAP
                LDA #127
                STA DIVIDER_Y       ;Init DIVIDER_Y
                CLC
                SBC MONS_GAP
                STA MSRC_BOT
                STA MDST_BOT

                LDX COFFSET         ;Calc CHAR_GAP and CSRC_TOP
                JSR TIMES_CELL_HEIGHT
                STA CHAR_GAP
                SEC
                ADC DIVIDER_Y
                STA CSRC_TOP
                STA CDST_TOP

DO_CHARODDS     LDA #0
                STA TEMP
                STA TEMP+1
                JSR FIRST_CHAR
:1              LDY #lwreflex
                LDA (CHARDL),Y
                SED
                CLC
                ADC TEMP
                CLD
                STA TEMP
                BCC :2
                INC TEMP+1
:2              JSR NEXT_CHAR
                BCC :1
                LDA GRPNUMB
                JSR CMODDS_SUB      ;On entry A = GRPNUMB
                TAX
                BNE :3              ;Make sure character
                INX                 ;  odds are non-zero
:3              STX CHAR_ODDS

DO_MONODDS      LDA #0
                PHA
                PHA
                STA COUNT
                JSR FIRST_MONSTER
:1              LDY #monSTATUS
                LDA (MONS_PTR),Y
                BEQ :2
                CMP #dead
                BNE :3
                BEQ :4              ;Always
:2              LDY #monLOREF
                PLA
                TAX
                PLA
                SED
                CLC
                ADC (MONS_PTR),Y
                PHA
                TXA
                ADC #0
                PHA
                CLD
:3              SED
                LDA COUNT
                CLC
                ADC #1
                STA COUNT
                CLD
:4              JSR NEXT_MONSTER
                BCC :1
                PLA
                STA TEMP+1
                PLA
                STA TEMP
                LDA COUNT
                JSR CMODDS_SUB
                STA MONS_ODDS

CMODDS_DONE     LDA #0
                STA C_HEADSTART
                STA M_HEADSTART

                LDA MONS_ADVFLAG
                BEQ :1
                BPL :2
:1              LDA CHAR_ADVFLAG
                BMI BOTH_ADVANCE
                JMP M_CHASE_C
:2              LDA CHAR_ADVFLAG
                BMI C_CHASE_M

BOTH_RETREAT
:1              JSR C_BACKWARD
                JSR M_BACKWARD
                BEQ :1
                JSR RUN_UPDATE
                LDA MDST_BOT
                CMP #topLine
                BEQ :2
                LDA CDST_TOP
                CMP #bottomLine
                BNE :1
:2              LDA #%10000000
                STA GROUP_STATUS
                PLA
                PLA
                JMP BATTLE_OVER

*-------------------------------

BOTH_ADVANCE
:1              JSR C_FORWARD
                JSR M_FORWARD
                BEQ :1
                JSR RUN_UPDATE
                LDA MONS_GAP
                ORA CHAR_GAP
                BNE :1
                JMP RUN_CONCLUDE

*-------------------------------

C_CHASE_M
                LDA #2
                STA M_HEADSTART
:1              JSR C_FORWARD
                JSR M_BACKWARD
                BEQ :1
                JSR RUN_UPDATE
                LDA MONS_GAP
                BEQ MONS_CAUGHT
                LDA MDST_BOT
                CMP #topLine
                BNE :1

MONS_AWAY       LDA #2
                JSR CLEAR_TLINE
                LDY #55             ;S>55 The.Alien.Has.Successfully.RET
                LDA ATALLY          ;      Retreated.
                CMP #1
                BEQ :1
                INY                 ;S>56 The.Aliens.Have.Successfully.RET
:1              JSR SENTENCE_PRET   ;      Retreated.
                JSR DELAYER
                JSR CLRBOX
                PLA
                PLA
                JMP BATTLE_OVER

MONS_CAUGHT     LDA #2
                JSR CLEAR_TLINE
                LDY #xThe
                LDA #xAlien
                JSR WORD2_INC
                LDA #$28            ;apostrophe
                STA TEXTBUF-1,X
                STA TEXTBUF,X
                LDA #$1D            ;s
                LDY ATALLY
                DEY
                BNE :1
                STA TEXTBUF,X
                BEQ :2              ;Always
:1              STA TEXTBUF-1,X
:2              LDA #%10000000
                INX
                INX
                BNE COME_BACK       ;Always

*-------------------------------

M_CHASE_C       LDA #2
                STA C_HEADSTART
:1              JSR C_BACKWARD
                JSR M_FORWARD
                BEQ :1
                JSR RUN_UPDATE
                LDA CHAR_GAP
                BEQ CHAR_CAUGHT
                LDA CDST_TOP
                CMP #bottomLine
                BNE :1

CHAR_AWAY       LDA #2
                JSR CLEAR_TLINE
                LDY #57             ;S>57 The.Group.Has.Successfully.RET
                JSR SENTENCE_PRET   ;     Retreated.
                JSR DELAYER
                JSR CLRBOX
                LDA #%10000000
                STA GROUP_STATUS
                PLA
                PLA
                JMP BATTLE_OVER

CHAR_CAUGHT     LDA #2
                JSR CLEAR_TLINE
                LDY #xThe
                LDA #zGroup
                JSR WORD2
                JSR APOSTROPHE_S
                LDA #%01000000
COME_BACK       STA SURPRISED_FLAG
                LDY #58             ;S>58 Attempt.To.Retreat.RET
                JSR SENTENCE_PRET   ;     Is.Unsuccessful.
                JSR DELAYER
                JSR CLRBOX
                JMP RUN_CONCLUDE

*-------------------------------

M_FORWARD       LDA MONS_ADVFLAG
                BEQ :2
:1              JSR RANDOM
                AND #%00001111
                CMP #10
                BCS :1
                CMP MONS_ODDS
                BCS :2
                DEC CHANGE_FLAG
                DEC MONS_GAP
                BPL :2
                INC MONS_GAP
                INC DIVIDER_Y
                DEC CHAR_GAP
                BPL :2
                INC CHAR_GAP
:2              LDA CHANGE_FLAG
                RTS

M_BACKWARD      DEC M_HEADSTART
                BPL :2
:1              JSR RANDOM
                AND #%00001111
                CMP #10
                BCS :1
                CMP MONS_ODDS
                BCS :3
:2              DEC CHANGE_FLAG
                INC MONS_GAP
:3              LDA CHANGE_FLAG
                RTS

C_FORWARD       LDA #0
                STA CHANGE_FLAG
:1              JSR RANDOM
                AND #%00001111
                CMP #10
                BCS :1
                CMP CHAR_ODDS
                BCS :2
                DEC CHANGE_FLAG
                DEC CHAR_GAP
                BPL :2
                INC CHAR_GAP
                DEC DIVIDER_Y
                DEC MONS_GAP
                BPL :2
                INC MONS_GAP
:2              RTS

C_BACKWARD      DEC C_HEADSTART
                BPL :2
                LDA #0
                STA CHANGE_FLAG
:1              JSR RANDOM
                AND #%00001111
                CMP #10
                BCS :1
                CMP CHAR_ODDS
                BCS :3
:2              DEC CHANGE_FLAG
                INC CHAR_GAP
:3              RTS

*-------------------------------

; Check open front row for purposes of advance/retreat.
;   cellBlocked cells are treated as open here.

MONS_OPENROWS   LDA #0
                STA MOFFSET
                LDX #24
:1              LDY #4
:2              LDA AGRID_MAIN,X
                BMI :3                  ; alien main and extra
                DEX
                DEY
                BPL :2
                INC MOFFSET
                TXA
                BPL :1
:3              RTS

*-------------------------------

; Check open front row for purposes of advance/retreat.
;   cellBlocked cells are treated as open here.

CHAR_OPENROWS   LDA #0
                STA COFFSET
                LDX #0
:1              LDY #4
:2              LDA CGRID_MAIN,X
                BMI :3                  ; character
                INX
                DEY
                BPL :2
                INC COFFSET
                CPX #25
                BNE :1
:3              RTS

*-------------------------------

TIMES_CELL_HEIGHT
                LDA #0
                CLC
:1              DEX
                BMI :2
                ADC #cellHeight
                BCC :1              ;Always
:2              RTS

*-------------------------------

CMODDS_SUB      LDX TEMP
                LDY TEMP+1
                JSR DIVIDE_12
                TXA
                SED
                CLC
                ADC #5
                TAX
                TYA
                ADC #0
                TAY
                CLD
                LDA #9
                TYA
                BNE :1
                TXA
                LSR
                LSR
                LSR
                LSR
:1              RTS

*-------------------------------
*
*-------------------------------

RUN_BEGIN       JSR ERASE_MNAMES
                JSR DRAW_PICT
                PictSetPage2
                PictClear 0;70;13;192
                PictSetGreen
                PictMoveTo 89;71
                PictLineTo 89;191
                PictCall REDRAW_CGRID
                PictCall DRAW_ALLMONS
                PictSetPage1
                PictCopyTo 0;70;13;192
                PictEnd
                RTS

RUN_CONCLUDE
:1              LDA DIVIDER_Y       ;Move divider back to center of grid
                CMP #127
                BEQ :4
                BCC :2
                DEC DIVIDER_Y
                BNE :3              ;Always
:2              INC DIVIDER_Y
:3              JSR FAST_UPDATE
                JMP :1
:4
                LDX #0              ;Update character Y-coordinates
:5              LDA TEMPCHAR_XY,X
                CLC
                ADC COFFSET
                STA TEMPCHAR_XY,X
                INX
                CPX GRPNUMB
                BNE :5

                JSR FIRST_MONSTER   ;Update monster Y-coordinates
:6              LDY #monSTATUS
                LDA (MONS_PTR),Y
                CMP #dead
                BEQ :7
                LDY #monCMDCOUNT    ;Forget all current commands
                LDA #1              ;  and parry for 1 time unit
                STA (MONS_PTR),Y
                INY
                LDA #cmdPARRY
                STA (MONS_PTR),Y
                LDY #monPOSITION
                LDA (MONS_PTR),Y
                SEC
                SBC MOFFSET
                STA (MONS_PTR),Y
:7              JSR NEXT_MONSTER
                BCC :6

                JSR CREATE_CGRID    ;Create new character
                JSR CREATE_MGRID    ;  and monster grids
                LDA MONS_ADVFLAG
                ORA MOFFSET
                BEQ :8
                JSR DRAW_MNAMES
:8              JSR DRAW_PICT
                PictSetPage2
                PictClear 0;70;13;192
                PictSetGreen
                PictMoveTo 89;71
                PictLineTo 89;191
                PictCall DRAW_GRID
                PictCall REDRAW_CGRID
                PictCall DRAW_ALLMONS
                PictSetPage1
                PictCopyTo 0;70;13;192
                PictEnd
                RTS

*-------------------------------
*
*-------------------------------

RUN_UPDATE      LDA #$30
                JSR WAIT_KEY
                BIT UNSTROB
FAST_UPDATE     LDA CDST_TOP        ;Current top and bottom lines
                STA OLD_CDST_TOP    ;  become old top and bottom lines
                LDA MDST_BOT
                STA OLD_MDST_BOT

                LDA CHAR_GAP        ;Calculate new character top line
                SEC
                ADC DIVIDER_Y
                STA CDST_TOP
                SEC
                SBC OLD_CDST_TOP
                STA C_DELTA

                LDA DIVIDER_Y       ;Calculate new monster bottom line
                CLC
                SBC MONS_GAP
                STA MDST_BOT
                SEC
                SBC OLD_MDST_BOT
                STA M_DELTA
                ORA C_DELTA
                BEQ :EXIT           ;Leave if nothing moved

                LDA M_DELTA
                BPL :3
                JSR MONS_MOVED
                JMP CHAR_MOVED
:3              JSR CHAR_MOVED
                JMP MONS_MOVED
:EXIT           RTS


MONS_MOVED      LDA MSRC_BOT
                SEC
                SBC #topLine+1
                STA TEMP
                LDA MDST_BOT
                SEC
                SBC #topLine+1
                CMP TEMP
                BCS :1
                STA TEMP
:1              LDA MDST_BOT
                SEC
                SBC TEMP

                LDX M_DELTA
                BMI :3

                PHA                 ;Monster grid moves downward
                JSR MONS_MOVER
                PLA
                SEC
                SBC #topLine+1
                BEQ :5
                LDX #topLine+1
                JMP EMPTY_LINES

:3              LDA MDST_BOT
                CMP #topLine+1
                BCC :4
                JSR MONS_MOVER      ;Monster grid moves upward
:4              LDA DIVIDER_Y
                CLC
                SBC MDST_BOT
                BEQ :5
                BMI :5
                LDX MDST_BOT
                INX
                JMP EMPTY_LINES
:5              RTS


CHAR_MOVED      LDA #bottomLine-1
                SEC
                SBC CSRC_TOP
                STA TEMP
                LDA #bottomLine-1
                SEC
                SBC CDST_TOP
                CMP TEMP
                BCS :1
                STA TEMP
:1              LDA CDST_TOP
                CLC
                ADC TEMP

                LDX C_DELTA
                BMI :3

                LDA CDST_TOP
                CMP #bottomLine
                BCS :2
                JSR CHAR_MOVER      ;Move character grid downward
:2              LDA CDST_TOP
                CLC
                SBC DIVIDER_Y
                BEQ :5
                BMI :5
                LDX DIVIDER_Y
                INX
                JMP EMPTY_LINES

:3              PHA                 ;Move character grid upward
                JSR CHAR_MOVER
                PLA
                TAX
                STA TEMP
                LDA #bottomLine-1
                SEC
                SBC TEMP
                BEQ :5
                BMI :5
                INX
                JMP EMPTY_LINES
:5              RTS


*-------------------------------
* TEMP = number of lines to move
*-------------------------------

MONS_MOVER      LDA MSRC_BOT
                SEC
                SBC TEMP
                TAX
                LDA MDST_BOT
                SEC
                SBC TEMP
                STA TEMP+1
                INC TEMP
                JMP CM_MOVER

*-------------------------------
* TEMP = number of lines to move
*-------------------------------

CHAR_MOVER      INC TEMP
                LDX CSRC_TOP
                LDA CDST_TOP
                STA TEMP+1
                ; fall through

CM_MOVER        JSR SET_SOURCE_OFF
                LDY TEMP+1
                LDA LOBYTES,Y
                STA DESTINL
                LDA HIBYTES,Y
                STA DESTINH
                LDY #0
:1              LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY #12
                BNE :1
                INX
                INC TEMP+1
                DEC TEMP
                BNE CM_MOVER
                RTS

*-------------------------------
*
*-------------------------------

EMPTY_LINES     STA TEMP
:1              JSR SET_SOURCE_LINE
                LDY #0
                LDA #$00
:2              STA (SCREENL),Y
                INY
                CPY #12
                BNE :2
                INX
                DEC TEMP
                BNE :1
                RTS

*-------------------------------

* <CHARNAME>_GIVES_THE_RETREAT
* SIGNAL.

* THE_GROUP'S_ATTEMPT_TO_RETREAT
* IS_UNSUCCESSFUL.
*
* THE_ALIEN'S_ATTEMPT_TO_RETREAT
* IS_UNSUCCESSFUL.
*
* THE_ALIENS'_ATTEMPT_TO_RETREAT
* IS_UNSUCCESSFUL.

* THE_ALIEN_IS_RETREATING.
* WILL_THE_GROUP_A>DVANCE OR
* _______________R>ETREAT?_
*
* THE ALIENS ARE RETREATING.
* WILL_THE_GROUP_A>DVANCE OR
* _______________R>ETREAT?_

* THE_GROUP_HAS_SUCCESSFULLY
* RETREATED.
*
* THE_ALIEN_HAS_SUCCESSFULLY
* RETREATED.
*
* THE_ALIENS_HAVE_SUCCESSFULLY
* RETREATED.


*-------------------------------
*
*-------------------------------

MRUN_DECIDER
*     - Clear NEVER_RET,_ADV, VOTE_RET,_ADV,_STAY
                LDX #4
                LDA #0
:0              STA NEVER_RET,X
                DEX
                BPL :0
                STX POINTER
* (1) - Get next monster
:1              INC POINTER
                LDX POINTER
                LDA PECKS,X
                BEQ :7
                BMI :1
                JSR SET_MONSTER
*     - If monster is dead then (1)
                LDY #monSTATUS
                LDA (MONS_PTR),Y
                CMP #dead
                BEQ :1
                TAX
*     - If alien run odds = 0 then NEVER_RET += 1
                LDY #aRetreatOdds
                LDA (ALIEN_PTR),Y
                BNE :2
                INC NEVER_RET
:2
*     - If alien advance odds = 0 then NEVER_ADV += 1
                LDY #aAdvanceOdds
                LDA (ALIEN_PTR),Y
                BNE :3
                INC NEVER_ADV
:3
*     - If monster is IMMOBILE/JAMMED/RESTRAINED then
*       - VOTE_STAY += 1
*       - Goto (1)
                CPX #immobile
                BEQ :4
                CPX #controlld
                BNE :5
:4              INC VOTE_STAY
                BNE :1              ;Always
:5
*     - If monster already running then VOTE_RET += 1, goto (1)
                LDY #monFLAGS
                LDA (MONS_PTR),Y
                BPL :6
                INC VOTE_RET
                BNE :1              ;Always
*
*     - Pick a random number
*
                JSR RANDOM
                BPL :6
*
*       - If random is true then
*         - Call RND_RET subroutine
*         - If result is false then
*           - Call RND_ADV subroutine
*         - Goto (1)
*
                JSR RND_RET
                BCS :1
                JSR RND_ADV
                JMP :1
*
*       - If random is false then
*         - Call RND_ADV subroutine
*         - If result is false then
*           - Call RND_RET subroutine
*         - Goto (1)
*
:6              JSR RND_ADV
                BCS :1
                JSR RND_RET
                JMP :1
*
* If ADV >= RET + STAY true and
*    NEVER_ADV false then MONS_ADVFLAG = Advance ($FF)
* If RET >= ADV + STAY true and
*    NEVER_RET false then MONS_ADVFLAG = Retreat ($7F)
* If neither of above are true then MONS_ADVFLAG = Stay ($00)
*
:7              LDA NEVER_ADV
                BNE :8
                LDX #$FF            ;Advance
                LDA VOTE_RET
                CLC
                ADC VOTE_STAY
                CMP VOTE_ADV
                BCC :10
:8              LDA NEVER_RET
                BNE :9
                LDX #$7F            ;Retreat
                LDA VOTE_ADV
                CLC
                ADC VOTE_STAY
                CMP VOTE_RET
                BCC :10
:9              LDX #$00            ;Stay
:10             STX MONS_ADVFLAG
                RTS


RND_RET
**** MAKE SURE IT'S NOT TOO SOON TO RUN
                LDY #aRetreatOdds
                LDA (ALIEN_PTR),Y
                TAY
                JSR FINAL_ODDS
                BCC :1
                INC VOTE_RET
:1              RTS

RND_ADV         LDY #aAdvanceOdds
                LDA (ALIEN_PTR),Y
                TAY
                JSR FINAL_ODDS
                BCC :1
                INC VOTE_ADV
:1              RTS

NEVER_RET       DB  0               ;These five must be consecutive
NEVER_ADV       DB  0               ;  in this order
VOTE_RET        DB  0
VOTE_ADV        DB  0
VOTE_STAY       DB  0
