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
                PictEnd
                JSR DRAW_GRID2
                JSR DRAW_ALLMONS
                JSR DRAW_MNAMES
                JMP DRAW_STATS_BOX

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

DRAW_MNAMES     LDX #4
                LDA #0
:1              STA MNAME_TABLE,X
                DEX
                BPL :1

                LDX #0
:2              TXA
                STA MONS_NUMBER
                JSR POINTTO

                LDY #monNUMBER
                LDA (MONS_PTR),Y
                TAX
                LDY TV_HEIGHTS,X
                DEY
                STY :MOD2+1

                LDY #monPOSITION
                LDA (MONS_PTR),Y
                AND #%00001111
                STA :MOD1+1
                LDA #10
                SEC
:MOD1           SBC #$FF
                CLC
:MOD2           ADC #$FF
                STA YCOUNT
                TAX

                LDA MNAME_TABLE,X
                BNE :4

                LDY #monNUMBER
                LDA (MONS_PTR),Y
                TAY
                LDA ALTYPE1,Y
                AND #%11000000
                STA MNAME_TABLE,X
                CLC
                ROL
                ROL
                ROL
                CMP #%00000011
                BNE :3
                LDA #0
:3              LDX #<MONSTER_NAMES
                LDY #>MONSTER_NAMES
                JSR GET_IND_STRING

                LDX YCOUNT
                LDY AGRID_YPNTS,X
                LDX #102
                JSR DRAW_TEXTBUF_XY
                LDX #92
                JSR HMOVE_TO
                JSR DRAW_SMALL_ARROW

:4              LDX MONS_NUMBER
                INX
                CPX MONS_TOTAL
                BNE :2
                RTS

MONSTER_NAMES   USR (UNKNOWN)=
                USR (ALIEN)=
                USR (ROBOT)=

; TODO: move this elsewhere
DRAW_SMALL_ARROW
                LDX #<SMALL_ARROW
                LDY #>SMALL_ARROW
                JMP DRAW_TILE

SMALL_ARROW     DB  %00000000
                DB  %00110000
                DB  %00111100
                DB  %00111111
                DB  %00111100
                DB  %00110000
                DB  %00000000

*-------------------------------
