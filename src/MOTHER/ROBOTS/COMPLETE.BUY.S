
COMPLETE_BUY    LDA #$00
                STA PARTALL
                STA MINUPR
                STA MINLOW
                STA EXPFLAG
                JSR COUNT_CYBS
                LDA CYB_COUNT
                CMP #1
                BEQ GOT_CYB

PICK_CYB        JSR NEXT_SCREEN
                JSR DRAW_ICONS
                JSR DRAW_GROUP
                JSR DRAW_PICT
                PictClear 0;87;40;107
                PictTextAt 59;93;"WHICH CYBERNATE WILL THIS NEW"
                PictTextAt 83;102;"ROBOT BE ASSIGNED TO?"
                PictEnd
                JSR SHOW_SCREEN
                JSR SELECT_CHAR
                STX ASSIGN2
                CPX #$07
                BNE GOT_CYB
                LDX PICK
                LDA #$FF
                STA ON1,X
                JMP OPTIONS

GOT_CYB         LDA #12
                STA COUNT
:1              LDX COUNT
                LDY #$00
                JSR VALUSUB
                DEC COUNT
                BPL :1
                JSR RTSUB
                LDA #$00
                STA COUNT
                LDA PICK
                EOR #$01
                TAX
                LDA ON1,X
                ORA #$0F
                STA ON1,X

NEXT_AREA       JSR NEXT_SCREEN
                LDA COUNT
                JSR DRAW_SCREEN
                LDX PICK
                LDA #$F4
                STA ON1,X
                JSR SHOW_SCREEN
                LDA COUNT
                AND #%11111110
                CMP #scrnWEAPONL
                BNE :2
                JSR EDIT_WEAPON
                BCS :3
:1              JMP OPTIONS             ; cancelled
:2              JSR LIMITER
                JSR EDIT_PART
                BCC :1
                JSR TOSLOT
:3              INC COUNT
                LDA COUNT
                CMP #scrnPROGRAM+1
                BNE NEXT_AREA

ALL_DONE        JSR MINISUB
                LDX #3
                SEC
                SED
:1              LDA RTOTNUM,X
                STA RTOTAL,X
                SBC GROUP_CREDITS,X
                STA THE_PRICE,X
                DEX
                BPL :1
                CLD
                BCC NOT_OVER

                LDX #3
:2              LDA THE_PRICE,X
                BNE :3
                DEX
                BPL :2
                BMI NOT_OVER            ; always
:3              JMP IS_OVER

NOT_OVER        LDA #$D0
                STA PARTALL
                JSR NEXT_SCREEN
                JSR BTRANS
                JSR DRAW_ICONS
                JSR OPENUP
                JSR VOMAIN
                JSR DRAW_CONFIRM
                JSR SHOW_SCREEN
                BIT UNSTROB
NOVKEY          LDA #7
                JSR SET_LEGALS
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB
                JSR CHECK_ENTER
                BNE :2
                JSR SPEND_RTOTNUM
                JMP SAVE_ROBOT

:2              CMP #"A"                ; NOTE: A>DJUST, not CHECK_UP
                BEQ ADJUST
                JSR CHECK_CANCEL
                BNE :1
                JMP OPTIONS

DRAW_CONFIRM    JSR DRAW_PICT
                PictClear 4;89;37;105
                PictTextAt 31;89;"PRESS <SPACE> TO VERIFY ROBOT PURCHASE"
                PictTextAt 61;98;"OR A>DJUST TO CHANGE AN AREA"
                PictEnd
                RTS

ADJUST          JSR DRAW_PICT
                PictClear 4;89;37;105
                PictTextAt 57;93;"SELECT AN AREA TO BE ADJUSTED"
                PictEnd
:1              JSR ADJOVER_SUB
                BCC :CANCEL
                JSR NEXT_SCREEN
                JSR SHOW_SCREEN
                JMP :1

:CANCEL         JSR DRAW_CONFIRM
                BIT UNSTROB
                JMP NOVKEY

IS_OVER         JSR NEXT_SCREEN
                LDA #$E0
                STA PARTALL
                JSR BTRANS
                JSR DRAW_ICONS
                JSR DRAW_PICT
                PictTextAt 41;89;"YOU HAVE OVERSPENT BY "
                PictCall DRAW_PRICE_L
                PictText " CREDITS"
                PictTextAt 41;98;"SELECT AN AREA TO BE REDONE"
                PictEnd
                JSR OPENUP
                JSR VOMAIN
                JSR SHOW_SCREEN
:1              JSR ADJOVER_SUB
                BCC :CANCEL
                JSR NEXT_SCREEN
                JSR SHOW_SCREEN
                JMP :1

:CANCEL         JMP OPTIONS

ADJOVER_SUB     LDA #0
                STA CURSOR
                JSR GBOXSUB
                BCS :0
                RTS
:0              JSR TOTALUP
                JSR ADDBODS
                LDX CURSOR
                INX
                TXA
                ASL
                ASL
                TAX
                LDY #$03
                SEC
:1              LDA RTOTAL,Y
                SED
                DEX
                SBC BODTOT,X
                CLD
                STA RTOTAL,Y
                STA RTOTNUM,Y
                DEY
                BPL :1
                JSR NEXT_SCREEN
                JSR BTRANS
                JSR CLOSEUP
                LDA CURSOR
                JSR DRAW_SCREEN
                JSR DELABEL
                JSR DRAW_PICT
                PictTextAt 100;24;"TOTAL ROBOT PRICE:"
                PictEnd
                JSR TOPLEVL
                LDX PICK
                LDA #$F4
                STA ON1,X
                JSR NEXT_SCREEN
                JSR CURSUB
                JSR NEXT_SCREEN
                JSR SHOW_SCREEN

                LDA SCRPICK
                AND #%11111110
                CMP #scrnWEAPONL
                BNE :2
                JSR EDIT_WEAPON
                BCS :4
;               CLC
                RTS

:2              JSR ZOOMUP
                JSR LIMITER
                JSR EDIT_PART
                BCS :3
;               CLC
                RTS

:3              JSR TOSLOT
:4              PLA
                PLA
                JMP ALL_DONE

TOSLOT          LDY SCRPICK
                LDA BEGCATS,Y
                TAX
                CLC
                ADC NUMCATS,Y
                STA SCRATCH
                LDY #$00
:1              LDA POINTLV,Y
                STA SLOT,X
                INY
                INX
                CPX SCRATCH
                BNE :1
                RTS
;
; On exit:
;   CS: Weapon selected
;   CC: Cancelled
;
EDIT_WEAPON     LDA #6
                JSR SET_LEGALS
                LDA #$00
                STA CURSOR
                LDA #$05
                STA CURHOLD
                LDA PARTALL
                BEQ :1
                LDY SCRPICK
                LDX LWEAPON-scrnWEAPONL,Y
                STX CURSOR
                STX CURHOLD
:1              JSR RCURSIT
                JSR UPDSUB2
                JMP KEYMOVE

NOCANC1         JSR RCURSIT
                LDX SCRPICK
                LDA CURSOR
                STA LWEAPON-scrnWEAPONL,X
                LDY #3
                LDA SCRPICK
                SEC
                SBC #scrnWEAPONL-1
                ASL
                ASL
                TAX
:1              LDA EVALNUM,Y
                STA CATT,Y
                DEX
                STA WEAPTOT,X
                LDA RTOTNUM,Y
                STA RTOTAL,Y
                DEY
                BPL :1
                SEC                     ; success
                RTS

KBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI GOTKEY
                JSR RCURSIT
                LDA #$00
                JSR WAIT_KEY
                JSR RCURSIT
KEYMOVE         LDA KEYBRD
                BPL KBLINK
GOTKEY          BIT UNSTROB
                JSR CHECK_UP
                BEQ KUP
                JSR CHECK_DOWN
                BEQ KDOWN
                JSR CHECK_CANCEL
                BEQ KCANCEL
                JSR CHECK_ENTER
                BNE KEYMOVE
                LDA EXPFLAG
                BEQ NOCANC1
                JSR EBLINK
                JMP KEYMOVE

KCANCEL         JSR RCURSIT
                CLC
                RTS

KUP             JSR RCURSIT
                LDX CURSOR
                STX CURHOLD
:1              DEX
                BPL :2
                LDX #$08
:2              STX CURSOR
                LDA LEGALS,X
                BNE :1
                JSR RCURSIT
                JSR UPDSUB2
                JMP KEYMOVE

KDOWN           JSR RCURSIT
                LDX CURSOR
                STX CURHOLD
:1              INX
                CPX #$09
                BNE :2
                LDX #$00
:2              STX CURSOR
                LDA LEGALS,X
                BNE :1
                JSR RCURSIT
                JSR UPDSUB2
                JMP KEYMOVE

RCURSIT         LDX CURSOR
                LDY :YPNTS,X
                LDX #$80
                JMP DRAW_ARROW

:YPNTS          DB  $35,$3D,$45
                DB  $4D,$55,$5D
