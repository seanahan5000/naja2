; WANTED screen numbers

;   1: "WHICH OPTION WOULD YOU LIKE?"
;   2.0: "WHO IS BUYING EQUIPMENT?"
;   2.1: "WHO IS SELLING EQUIPMENT?"
;   2.2: "WHO IS IDENTIFYING EQUIPMENT?"
;   2.3: "WHO IS REPAIRING EQUIPMENT?"
;   3: "WHOSE CREDITS WILL BE USED?"
;   4: (unused)
;   5: "WHAT TYPE OF EQUIPMENT ARE YOU BUYING?"
;   6: "WHAT TYPE OF WEAPON ARE YOU BUYING?"
;   7: "WHAT TYPE OF PROTECTION ARE YOU BUYING?"
;   8: "WHAT TYPE OF MISCELLANEOUS EQUIPMENT ARE YOU BUYING?"

;   9: ???
;   A: DRAW_EQUIPMNT (BEAM-WEAPONS)
;   B: DRAW_EQUIPMNT (BLASTING-WEAPONS)
;   C: DRAW_EQUIPMNT (MISC-WEAPONS)

;   D: DRAW_ARMHELM
;   E: DRAW_ARMHELM

;   F: DRAW_EQUIPMNT (FORCE-SHIELDS)
;  10: DRAW_EQUIPMNT (HELMET-ATTACHMNTS)
;  11: DRAW_EQUIPMNT (MISC-PROTECTION)
;  12: DRAW_EQUIPMNT (MEDICAL-EQUIPMNT)
;  13: DRAW_EQUIPMNT (SCANNERS)
;  14: DRAW_EQUIPMNT (MISCELLANEOUS)

DRAW_SCREEN     LDA DISPLAY
                ASL
                ASL
                ASL
                ASL
                ASL
                EOR #$60
                JSR SET_PAGE

                LDA DISPLAY
                EOR #$03
                STA DISPLAY
                TAX
                DEX
                LDA WANTED1
                CMP ON1,X
                BEQ ISHERE
                CMP #$09
                BCC NOT_SPECIAL

SPECIAL         BEQ :1
                CMP #$0D
                BCC :2
                CMP #$0F
                BCS :2
:1              JMP DRAW_ARMHELM
:2              JMP DRAW_EQUIPMNT

NOT_SPECIAL     LDA ON1,X
                CMP #$09
                BCS CHKON
                CMP #$03
                BNE NOWANT2
CHKON           TXA
                EOR #$01
                TAX
                LDA ON1,X
                CMP #$09
                BCS NOWANT2

                JSR DRAW_PICT
                PictCopyTo 0;0;40;69
                PictEnd

NOWANT2         JSR DRAW_PICT
                PictClear 0;69;40;192
                PictEnd

                LDA WANTED1
                CMP #$04
                BNE :SKIPA
                JMP SELL_ID_REP

:SKIPA          LDA WANTED1
                CMP #2
                BNE :1
                JSR DRAW_WHOBOX
                JMP ISHERE
:1              JSR DRAW_BLUEBOX

ISHERE          LDA DISPLAY
                CMP #$01
                BNE NOTONE
                STA PRIMARY
                BEQ NOISE               ; always
NOTONE          STA SCNDARY

NOISE           LDA #$20
                STA COUNT
:1              STA CLICK
                LDA #$08
                JSR WAIT
                DEC COUNT
                BNE :1
                RTS

*-------------------------------

; TODO: adjust box tops so they're all the same, shrink box bottoms

DRAW_BLUEBOX    JSR DRAW_PICT
                PictSetBlue
                PictSwitch WANTED1

:0              PictCase :1
                ; unused

:1              PictCase :2
                PictRect $2E;99;$E8;165
                PictTextAt 56;105;"WHICH OPTION WOULD YOU LIKE?"
                PictTextRows 119;117;9
                TXC "BUY\n"
                TXC "SELL\n"
                TXC "IDENTIFY\n"
                TXC "REPAIR\n"
                TXT "EXIT"

:2              PictCase :3
                ; unused

:3              PictCase :4
                ; unused

:4              PictCase :5
                ; unused

:5              PictCase :6
                PictRect $2E;102;$E8;167
                PictTextAt 74;108;"WHAT TYPE OF EQUIPMENT"
                PictTextAt 95;116;"ARE YOU BUYING?"
                PictTextRows 101;128;9
                TXC "WEAPONS\n"
                TXC "PROTECTION\n"
                TXC "MISCELLANEOUS\n"
                TXT "LEAVE"

:6              PictCase :7
                PictRect $2E;102;$E8;167
                PictTextAt 83;108;"WHAT TYPE OF WEAPON"
                PictTextAt 95;116;"ARE YOU BUYING?"
                PictTextRows 101;128;9
                TXC "BEAM-TYPE\n"
                TXC "BLASTER-TYPE\n"
                TXC "MISCELLANEOUS\n"
                TXT "LEAVE"

:7              PictCase :8
                PictRect $2E;102;$E8;179
                PictTextAt 71;106;"WHAT TYPE OF PROTECTION"
                PictTextAt 95;114;"ARE YOU BUYING?"
                PictTextRows 101;124;9
                TXC "ARMOR\n"
                TXC "SHIELDS\n"
                TXC "HELMETS\n"
                TXC "ATTACHMENTS\n"
                TXC "MISCELLANEOUS\n"
                TXT "LEAVE"

:8              PictCase :END
                PictRect $2E;102;$E8;167
                PictTextAt 62;108;"WHAT TYPE OF MISCELLANEOUS"
                PictTextAt 65;116;"EQUIPMENT ARE YOU BUYING?"
                PictTextRows 101;128;9
                TXC "MEDICAL\n"
                TXC "SCANNERS\n"
                TXC "MISCELLANEOUS\n"
                TXT "LEAVE"

:END            PictSwitchEnd
                PictEnd
                RTS

DRAW_WHOBOX     JSR DRAW_PICT
                PictSetBlue
                PictRect $2E;102;$E8;120
                PictSwitch SOURCE

:0              PictCase :1
                PictTextAt 68;108;"WHO IS BUY"

:1              PictCase :2
                PictTextAt 65;108;"WHO IS SELL"

:2              PictCase :3
                PictTextAt 53;108;"WHO IS IDENTIFY"

:3              PictCase :END
                PictTextAt 59;108;"WHO IS REPAIR"

:END            PictSwitchEnd
                PictText "ING EQUIPMENT?"
                PictTextAt 16;70;"CANCEL"
                PictEnd
                RTS

*-------------------------------

UPDATE_CREDIT   JSR MOVE_TO
                JSR HSAVE
                JSR DRAW_GCREDITS_AT
                JSR TAKE_PRICE
                JSR HRESTORE
                JMP DRAW_GCREDITS

SHOW_CREDIT     JMP DRAW_GCREDITS_AT

DRAW_PRICE_AT   JSR MOVE_TO
                LDX #<THE_PRICE
                LDY #>THE_PRICE
                JMP DRAW_CREDITS

TAKE_PRICE      LDX #<THE_PRICE
                LDY #>THE_PRICE
                SEC
                JSR GROUP_SPEND
                ; *** MARK STATE_MS DIRTY ***
                RTS

*-------------------------------

CURSITA         LDY CURRENT
                LDX PICTABL-1,Y
                LDA YOFFS-1,X
                CLC
                ADC CURSOR
                TAX
                LDA YTABLE,X
                LDX CURSEX-1,Y
                TAY
                JMP DRAW_ARROW

CURSEX          DB  $69,$03,$03
                DB  $03,$57,$57
                DB  $57,$57
PICTABL         DB  $01,$02,$02
                DB  $02,$03,$03
                DB  $04,$03
YOFFS           DB  $00,$05,$0E
                DB  $12
YTABLE          DB  $75,$7E,$87
                DB  $90,$99

*-------------------------------

AYPOINTS        DB  14,23,32
                DB	41,50,59
                DB	68                   ; unused
                DB	71                   ; cancel
                DB  $4E                 ; unused TODO: why are these tabs uneven?

                DB  $80,$89,$92
                DB  $9B

                DB  $7C,$85,$8E
                DB  $97,$A0,$A9

MAXOPTS         DB  $05,$08,$09
                DB  $08,$04,$04
                DB  $06,$04

GROUPER         DB  $03,$00,$04
                DB  $FF,$FF,$0A
                DB  $05,$06,$07
                DB  $08,$09

*-------------------------------
