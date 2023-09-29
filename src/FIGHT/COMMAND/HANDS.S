*===============================
*
*===============================

DRAW_HAND       TAY
                LDA HAND_DATA,Y
                PHA
                BIT ROBDEN_FLAG
                BVC :1
                LSR
                LSR
                JSR GET_HAND_STRING
                JSR DRAW_TEXTBUF
:1              PLA
                AND #$03
                CLC
                ADC #2
                JSR GET_HAND_STRING
                JMP DRAW_TEXTBUF

HAND_DATA       DB  $00,$01,$04
                DB  $05,$02,$06

GET_HAND_STRING LDX #<:HAND_STRINGS
                LDY #>:HAND_STRINGS
                JMP GET_IND_STRING

:HAND_STRINGS   TXI "UPPER "
                TXI "LOWER "
                TXI "LEFT"
                TXI "RIGHT"
                TXI "LEFT/RIGHT"

*===============================
*
*===============================
;
; On entry:
;   A: attack type
;      0 = swing
;      1 = shoot
;      2 = throw
;      3 = use
;

ATTACK_TYPE     =   SWTYPE

SELECT_HAND     STA ATTACK_TYPE
                JSR EQUIP_DRAW
                LDA ATTACK_TYPE
                JSR EQUIP_TYPER
                LDA ATTACK_TYPE
                JSR LEGAL_HANDS
                LDA ATTACK_TYPE
                BEQ :1
                JSR CONFIRM_SELECT
:1              LDX #<HAND_CDEF
                LDY #>HAND_CDEF
                JSR FULL_GETKEY
                BCS NOTCANC
                LDA ATTACK_TYPE
                BNE :2
                JSR SWING_BOX_3
:2              PLA
                PLA
                JMP DID_CANCEL
NOTCANC         JMP CLEAR_WCANCEL

HAND_CDEF       DB  $05
                DB  $00
                DW  HAND_CURSOR
;
; Count number of usable items in hands.
;   If many, ask player to select one.
;
CONFIRM_SELECT  LDX #$00
                LDY #$09
:1              LDA LEGALS,Y
                BNE :2
                INX
:2              DEY
                BPL :1
                CPX #$02
                BCC :3
                LDY ATTACK_TYPE
                LDX :XPOS-1,Y
                LDY #133
                JSR MOVE_TO
                JSR DRAW_PICT
                PictHSave
                PictText "CONFIRM"
                PictHRestore
                PictText " SELECT"
                PictEnd
:3              RTS

:XPOS           DB  105,102,108,96

*===============================
*
*===============================

EQUIP_DRAW      BIT ROBDEN_FLAG
                BMI :ROBOT
                BVS :DENEB

:NORMAL         JSR DRAW_PICT
                PictTextAt 111;146;"LEFT:"
                PictTextAt 105;154;"RIGHT:"
                PictEnd
                BNE :COMMON            ; always

:DENEB          JSR DRAW_PICT
                PictSetTextHeight 8
                PictTextAt 123;146;"UL:\nUR:\nLL:\nLR:"
                PictEnd
                BNE :COMMON            ; always

:ROBOT          JSR DRAW_PICT
                PictSetTextHeight 8
                PictTextAt 123;146;"_L:\n__:\n_R:\n__:"
                PictEnd

:COMMON         LDX #0
:1              STX COUNT
                LDY HAND_YPNTS,X
                JSR VMOVE_TO
                JSR ONE_EQLINE
                LDA TEXTBUF
                CMP #TextLineEnd
                BEQ :2
                LDX #$96
                JSR DRAW_TEXTBUF_X
                JSR PARSTAT
                LDX #$FC
                JSR DRAW_TEXTBUF_X
:2              LDX COUNT
                INX
                CPX #2
                BCC :1
                LDA ROBDEN_FLAG
                BEQ :3
                CPX #4
                BCC :1
:3              RTS


*-------------------------------
* Pass hand 0 to 3 in X register
*-------------------------------

ONE_EQLINE      LDY CONVERT_TABLE,X
                BMI :EXIT
                LDX #0
:LOOP1          LDA (CHARDL),Y
                STA ETABLE,X
                INY
                INX
                CPX #4
                BNE :LOOP1
                LDA ETABLE
                CMP #$FF
                BEQ :EXIT
                JMP ETABLE_TO_TEXT
:EXIT           LDA #TextLineEnd
                STA TEXTBUF
                RTS


*-------------------------------
* ROBDEN_FLAG:
*   AB000000
*     A = Robot if set
*     B = Denebian if set
*-------------------------------

SET_HANDFLAGS   LDA #$00
                STA ROBDEN_FLAG
                LDY #profrace
                LDA (CHARDL),Y
                PHP
                AND #%00001111
                CMP #deneb
                BEQ :SKIPA
                CLC
:SKIPA          ROR ROBDEN_FLAG
                PLP
                CMP #robot
                ROR ROBDEN_FLAG
                RTS

ROBDEN_FLAG     DB  0


*-------------------------------
* Make table to convert between
*   the way the character's
*   equipment is now and how it
*   will be in battle.
*-------------------------------

MAKE_CONVERT    LDX #3
:LOOP1          TXA
                ASL
                ASL
                ADC #e3_UPLFT       ;Carry assumed clear
                STA CONVERT_TABLE,X
                DEX
                BPL :LOOP1

                LDA COMCNT
                BNE NOTFIRST
                RTS
NOTFIRST        LDA PLANNER
                ASL
                ASL
                ASL
                ASL
                ASL
                TAX
:LOOP2          LDA COMMAND,X
                STA TEMP
                INX
                INX
                STX TEMP+1
                ROL
                ROL
                ROL
                AND #%00000011
                TAY
                LDA TEMP
                AND #%00001111
                CMP #cmdUSE
                BEQ :SKIPC
                CMP #cmdTHROW
                BEQ :SKIPA
                CMP #cmdEXCHANGE
                BNE :SKIPB
                LDA TEMP
                LSR
                LSR
                LSR
                LSR
                AND #%00000011
                TAX
                LDA CONVERT_TABLE,Y
                PHA
                LDA CONVERT_TABLE,X
                STA CONVERT_TABLE,Y
                PLA
                STA CONVERT_TABLE,X
                JMP :SKIPB

:SKIPC          STY TEMP
                LDA CONVERT_TABLE,Y
                TAY
                LDA (CHARDL),Y
                CMP #$63
                BNE :SKIPB
                INY
                LDA (CHARDL),Y
                LDY TEMP
                CMP #$01
                BEQ :SKIPD
                CMP #$09
                BEQ :SKIPD
                BNE :SKIPB          ;Always

:SKIPA          LDA TEMP
                AND #%00010000
                BNE :SKIPB          ;Boomerang can be re-thrown
:SKIPD          LDA CONVERT_TABLE,Y
                ORA #$80
                STA CONVERT_TABLE,Y
:SKIPB          LDX TEMP+1
                CPX COMPNTR
                BNE :LOOP2
                RTS

CONVERT_TABLE   DB  0,0,0,0


*-------------------------------
*
*-------------------------------

EQUIP_TYPER     ASL
                TAY
                LDA TYPES_TABLE,Y
                STA :MOD1+1
                LDA TYPES_TABLE+1,Y
                STA :MOD1+2
                LDX #0
                STX COUNT
:LOOP1          LDY CONVERT_TABLE,X
                STY COUNTER
                LDX #0
                TYA
                BMI :SKIPA
                LDA (CHARDL),Y
                CMP #$FF
                BEQ :SKIPA
                LDX #7              ;unusable
:MOD1           JSR $FFFF           ;Modified
                CPX #7              ;unusable
                BEQ :SKIPA
                LDY COUNTER
                INY
                INY
                INY
                LDA (CHARDL),Y
                PHA
                LDY #profrace
                LDA (CHARDL),Y
                LSR
                LSR
                LSR
                LSR
                TAY
                PLA
                AND PROUSAB,Y
                BNE :SKIPA
                LDX #7              ;unusable
:SKIPA          TXA
                LDX COUNT
                STA HANDTAB,X
:SKIPB          INC COUNT
                LDX COUNT
                CPX #4
                BNE :LOOP1
                RTS

TYPES_TABLE     DW  SWING_TYPES
                DW  SHOOT_TYPES
                DW  THROW_TYPES
                DW  USE_TYPES

*-------------------------------
* 0 - empty
* 1 - dagger
* 2 - sword
* 3 - whip
* 4 - rifle
* 5 - robo-dagger/sword
* 6 - hand attachment
* 7 - unusable

SWING_TYPES     AND #$1F
                LDX #4              ;rifle
                CMP #$0D
                BEQ :EXIT
                INX                 ;5 - robo-dagger/sword
                CMP #$18
                BEQ :EXIT
                INX                 ;6 - hand attachment
                CMP #$19
                BEQ :EXIT
                INX                 ;7 - unusable
                CMP #$08
                BNE :EXIT
                INY
                LDA (CHARDL),Y
                LSR
                LSR
                AND #%00000011
                TAX
                INX
:EXIT           RTS


*-------------------------------
* 0 - empty
* 1 - pistol/rifle (one hand)
* 2 - daser/memory eraser (one hand)
* 3 - disintegrator (two hands)
* 4 - rifle/cannon (two hands)
* 5 - robo-blaster
* 6 - hand attachment
* 7 - unusable

SHOOT_TYPES     LDX #1              ;pistol/rifle (one hand)
                AND #%00011111
                CMP #$0C
                BEQ :EXIT
                LDX #4              ;rifle/cannon (two hand)
                CMP #$0E
                BEQ :EXIT
                CMP #$0D
                BNE :SKIPA
                INY
                INY
                LDA (CHARDL),Y
                AND #eq_hands12
                BNE :EXIT
                LDX #1
                BNE :EXIT           ;Always
:SKIPA          INX                 ;robo-blaster
                CMP #$1C
                BEQ :EXIT
                INX                 ;hand attachment
                CMP #$19
                BEQ :EXIT
                CMP #$0F
                BNE :SKIPC
                INY
                LDA (CHARDL),Y
                LDX #2              ;daser/memory eraser (one hand)
                CMP #$05            ;daser
                BEQ :EXIT
                CMP #$08            ;memory eraser
                BEQ :EXIT
                INX                 ;disintegrator
                CMP #$04
                BEQ :EXIT
:SKIPC          LDX #7              ;unusable
:EXIT           RTS


*-------------------------------
* 0 - empty
* 1 - throwable
* 7 - unusable

THROW_TYPES     AND #$5F
                CMP #$4F
                BNE :EXIT
                LDX #1              ;throwable
                INY
                LDA (CHARDL),Y
                AND #%00001110
                BEQ :EXIT           ;gyro boomerang
                CMP #$06            ;immobilizer, sonic grenade
                BEQ :EXIT
                LDX #7              ;unusable
:EXIT           RTS

*-------------------------------
* 0 - empty
* 1 - usable
* 7 - unusable

USE_TYPES       AND #eq_usable
                BEQ :EXIT
                LDX #1              ;usable
:EXIT           RTS


*===============================
*
*===============================

LEGAL_HANDS     PHA
                JSR SET_LEGALS
                LDA HANDTAB
                STA AREA1
                LDA HANDTAB+1
                STA AREA2
                PLA
                PHA
                TAY
                JSR HAND_CHECK
                LDA AREAX
                STA LEGALS
                LDA AREAY
                STA LEGALS+1
                LDA AREAZ
                STA LEGALS+4
                BIT ROBDEN_FLAG
                BMI :SKIPA
                BVC :EXIT
:SKIPA          LDA HANDTAB+2
                STA AREA1
                LDA HANDTAB+3
                STA AREA2
                PLA
                PHA
                TAY
                JSR HAND_CHECK
                LDA AREAX
                STA LEGALS+2
                LDA AREAY
                STA LEGALS+3
                LDA AREAZ
                STA LEGALS+5
:EXIT           PLA
                RTS


*-------------------------------
*
*-------------------------------

HAND_CHECK      LDA #0
                STA AREAX
                STA AREAY
                STA AREAZ
                LDX #$FF
                TYA
                BNE SHOOT_CHECK

*-------------------------------

SWING_CHECK     BIT ROBDEN_FLAG
                BMI ROBOT_SWING

CHAR_SWING      LDY #1
:LOOP1          LDA AREA1,Y
                CMP #5              ;rifle+1
                BCC :SKIPA
                TXA
                STA AREAX,Y
                STX AREAZ
:SKIPA          DEY
                BPL :LOOP1
                LDA AREAZ
                BNE :EXIT
                LDA AREA1
                ORA AREA2
                BEQ :SKIPB
                LDA AREA1
                BNE :EXIT
                LDA AREA2
                BNE :EXIT
:SKIPB          STX AREAZ
:EXIT           RTS

ROBOT_SWING     STX AREAZ
                LDA AREA1
                CMP #5              ;robo-dagger
                BEQ :SKIPA
                STX AREAX
                CMP #6              ;hand attachment
                BNE :SKIPA
                LDA AREA2
                CMP #5              ;rifle+1
                BCS :SKIPA
                CMP #3              ;whip
                BNE :EXIT
:SKIPA          STX AREAY
:EXIT           RTS

*-------------------------------

SHOOT_CHECK     DEY
                BNE THROW_CHECK
                BIT ROBDEN_FLAG
                BMI ROBOT_SHOOT

CHAR_SHOOT      LDY #0
                LDA AREA1
                BNE :SKIPA
                LDA AREA2
                BNE :SKIPC
                STX AREAX
                STX AREAY
                STX AREAZ
                RTS

:SKIPA          INY
                LDA AREA2
                BEQ :SKIPC
                STX AREAZ
:LOOP1          LDA AREA1,Y
                CMP #3              ;disintegrator
                BCC :SKIPB
                TXA
                STA AREAX,Y
:SKIPB          DEY
                BPL :LOOP1
                RTS

:SKIPC          TXA
                STA AREAX,Y
                TYA
                EOR #1
                TAY
                LDA AREA1,Y
                CMP #3              ;disintegrator
                BCC :EXIT
                PHA
                TXA
                STA AREAX,Y
                PLA
                CMP #5              ;robo-blaster
                BCC :EXIT
                STX AREAZ
:EXIT           RTS


ROBOT_SHOOT     STX AREAZ
                LDA AREA1
                CMP #6              ;hand attachment
                BNE :SKIPA
                LDY AREA2
                CPY #1              ;pistol/rifle (one hand)
                BEQ :SKIPB
:SKIPA          STX AREAY
                CMP #5              ;robo-blaster
                BEQ :EXIT
:SKIPB          STX AREAX
:EXIT           RTS

*-------------------------------

THROW_CHECK
USE_CHECK       STX AREAZ
                LDY #1
:LOOP1          LDA AREA1,Y
                CMP #1              ;throwable/usable object
                BEQ :SKIPA
                TXA
                STA AREAX,Y
:SKIPA          DEY
                BPL :LOOP1
                RTS

*-------------------------------

HANDTAB         DB  0,0,0,0

AREA1           DB  0
AREA2           DB  0
AREAX           DB  0
AREAY           DB  0
AREAZ           DB  0

*-------------------------------
