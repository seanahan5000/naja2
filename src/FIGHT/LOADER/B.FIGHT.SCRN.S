*===============================
*
*===============================

FIGHT_SCREEN    JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictSetGreen
                PictRect $59;$47;$115;$BF
                PictMoveTo $59;$47
                PictLineTo $115;$47
                PictMoveTo $59;$7F
                PictLineTo $115;$7F
                PictMoveTo $CB;$48
                PictLineTo $CB;$7E
                PictSetTextHeight 11
                PictTextAt 92;74;(>\n>\n>\n>\n>)
                PictSetTextHeight 0
                PictEnd
                JSR DRAW_GRID
                JSR DRAW_ALLMONS
                JSR DRAW_MNAMES
                JMP DRAW_STATS_BOX_XY

*-------------------------------
*
*-------------------------------

DRAW_ALLMONS    LDA #0
                STA MONS_NUMBER
:LOOP1          JSR POINTTO
                JSR DRAW_ALIEN
                INC MONS_NUMBER
                LDA MONS_NUMBER
                CMP MONS_TOTAL
                BNE :LOOP1
                RTS

*-------------------------------
*
*-------------------------------

DRAW_MNAMES     LDA #$06
                STA YCOUNT
                LDA #4
                STA ZCOUNT
:LOOP1          LDA #$FF
                STA MNAME_HOLD
                STA XCOUNT

                LDA #0
                STA MONS_NUMBER
:LOOP2          JSR GET_MONSPTR
                LDY #monPOSITION
                LDA (TEMP),Y
                AND #%00001111
                CMP YCOUNT
                BNE :SKIPA
                LDA (TEMP),Y
                CMP XCOUNT
                BCS :SKIPA
                STA XCOUNT
                LDY #monNUMBER
                LDA (TEMP),Y
                TAX
                LDA ALTYPE1,X
                AND #%11000000
                STA MNAME_HOLD
:SKIPA          INC MONS_NUMBER
                LDA MONS_NUMBER
                CMP MONS_TOTAL
                BNE :LOOP2

                LDX ZCOUNT
                LDA MNAME_HOLD
                STA MNAME_TABLE,X
                CMP #$FF
                BEQ :SKIPC
                ROL
                ROL
                ROL
                CMP #%00000011
                BNE :SKIPB
                LDA #0
:SKIPB          LDX #<MONSTER_NAMES
                LDY #>MONSTER_NAMES
                JSR GET_IND_STRING
                LDX ZCOUNT
                LDA GRID_YPNTS,X
                SEC
                SBC #$36
                TAY
                LDX #102
                JSR DRAW_TEXTBUF_XY
:SKIPC          INC YCOUNT
                DEC ZCOUNT
                BPL :LOOP1
                RTS

MNAME_HOLD      DB  0

MONSTER_NAMES   USR (UNKNOWN)=
                USR (ALIEN)=
                USR (ROBOT)=

*-------------------------------
