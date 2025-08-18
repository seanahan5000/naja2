
COMPLETE_BUY    LDA #$00
                STA PARTALL
                STA MINUPR
                STA MINLOW
                STA EXPFLAG
                JSR COUNT_CYBS
                LDA CYB_COUNT
                CMP #1
                BEQ GOT_CYB

PICK_CYB        JSR PPEOR
                JSR ALL_ICONS
                JSR DRAW_GROUP
                JSR DRAW_PICT
                PictClear 0;87;40;107
                PictTextAt 59;93;"WHICH CYBERNATE WILL THIS NEW"
                PictTextAt 83;102;"ROBOT BE ASSIGNED TO?"
                PictEnd
                JSR VIEWER
                LDA #$07
                STA CURSOR
                LDY #$07
:1              LDA RYPOINTS,Y
                STA LINTABL,Y
                DEY
                BPL :1
                LDA #$03
                STA XHOLD
                JSR KDOWN2
                JSR RCURSIT
                LDA CURSOR
                STA ASSIGN2
                CMP #$07
                BNE GOT_CYB
                LDX PICK
                LDA #$FF
                STA ON1,X
                JMP POP_TO_OPTIONS

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
NEXT_AREA       JSR PPEOR
                LDA COUNT
                JSR DRAW_SCREEN
                LDX PICK
                LDA #$F4
                STA ON1,X
                JSR VIEWER
                LDA COUNT
                AND #%11111110
                CMP #scrnWEAPONL
                BNE NEXTC
NEXTB           JSR WEPONLY
                JMP NEXT
NEXTC           JSR LIMITER
                JSR BOXCURS
                JSR TOSLOT
NEXT            INC COUNT
                LDA COUNT
                CMP #scrnPROGRAM+1
                BNE NEXT_AREA

ALL_DONE        JSR MINISUB
                LDX #3
                SEC
:1              LDA RTOTNUM,X
                STA RTOTAL,X
                SED
                SBC GROUP_CREDITS,X
                CLD
                STA THE_PRICE,X
                DEX
                BPL :1
                BCC NOVER

                LDX #3
:2              LDA THE_PRICE,X
                BNE :3
                DEX
                BPL :2
                BMI NOVER               ; always
:3              JMP ISOVER

NOVER           LDA #$D0
                STA PARTALL
                JSR PPEOR
                JSR BTRANS
                JSR ALL_ICONS
                JSR OPENUP
                JSR VOMAIN
                JSR DRAW_CONFIRM
                JSR VIEWER
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
                JMP POP_TO_OPTIONS

PBACK           JSR DRAW_CONFIRM
                BIT UNSTROB
                JMP NOVKEY

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
                JSR PPEOR
                JSR VIEWER
                JMP :1

ISOVER          JSR PPEOR
                LDA #$E0
                STA PARTALL
                JSR BTRANS
                JSR ALL_ICONS
                JSR DRAW_PICT
                PictTextAt 41;89;"YOU HAVE OVERSPENT BY "
                PictCall DRAW_PRICE
                PictText " CREDITS"
                PictTextAt 41;98;"SELECT AN AREA TO BE REDONE"
                PictEnd

                JSR OPENUP
                JSR VOMAIN
                JSR VIEWER
:1              JSR ADJOVER_SUB
                JSR PPEOR
                JSR VIEWER
                JMP :1

ADJOVER_SUB     LDA #0
                STA CURSOR
                JSR GBOXSUB
                JSR TOTALUP
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
                JSR PPEOR
                JSR BTRANS
                JSR CLOSEUP
                LDA CURSOR
                JSR DRAW_SCREEN
                JSR DELABLE
                JSR DRAW_PICT
                PictTextAt 100;24;"TOTAL ROBOT PRICE:"
                PictEnd
                JSR TOPLEVL
                LDX PICK
                LDA #$F4
                STA ON1,X
                JSR PPEOR
                JSR CURSUB
                JSR PPEOR
                JSR VIEWER

                LDA SCRPICK
                AND #%11111110
                CMP #scrnWEAPONL
                BNE :2
                JSR WEPONLY
                BCC :4
                RTS

:2              JSR ZOOMUP
                JSR LIMITER
                JSR BOXCURS
                BCC :3
                RTS
:3              JSR TOSLOT
:4              PLA
                PLA
                JMP ALL_DONE

BACKEA          LDY #$02
                LDA #$EA
NOPLOOP         STA KUPMOD,Y
                STA KDOMOD,Y
                DEY
                BPL NOPLOOP
                RTS

WPYPNTS         DB  $35,$3D,$45
                DB  $4D,$55,$5D

WPSUB           LDA #$00
                STA CURSOR
                LDA #$05            ;????????
                STA CURHOLD
                LDA PARTALL
                BEQ WPSKIP1
                STX CURSOR
                STX CURHOLD
WPSKIP1         JSR RCURSIT
                JMP UPDSUB2

TOSLOT          LDY SCRPICK
                LDA BEGCATS,Y
                TAX
                CLC
                ADC NUMCATS,Y
                STA SCRATCH
                LDY #$00
TABLOOP         LDA POINTLV,Y
                STA SLOT,X
                INY
                INX
                CPX SCRATCH
                BNE TABLOOP
                RTS

WEPONLY         LDA #$20
                STA KUPMOD
                STA KDOMOD
                LDA #<UPDSUB2
                STA KUPMOD+1
                STA KDOMOD+1
                LDA #>UPDSUB2
                STA KUPMOD+2
                STA KDOMOD+2
                LDA #6
                JSR SET_LEGALS
                LDY #5
WPLOOP          LDA WPYPNTS,Y
                STA LINTABL,Y
                DEY
                BPL WPLOOP
                LDA #$80
                STA XHOLD
                LDY SCRPICK
                LDX LWEAPON-scrnWEAPONL,Y
                JSR WPSUB
                LDA #"C"
                STA CKEYMOD+1
WASKIPA         JSR KEYMOVE
                CMP #"C"
                BEQ WASKIP1
                LDX EXPFLAG
                BEQ WASKIP1
                JSR EBLINK
                JMP WASKIPA
WASKIP1         PHA
                JSR RCURSIT
                LDA #$00
                STA CKEYMOD+1
                JSR BACKEA
                PLA
                CMP #"C"
                BNE NOCANC1
                JMP VCANC
NOCANC1         LDX SCRPICK
                LDA CURSOR
                STA LWEAPON-scrnWEAPONL,X
                LDY #3
                LDA SCRPICK
                SEC
                SBC #scrnWEAPONL-1
                ASL
                ASL
                TAX
XLOOP1          LDA EVALNUM,Y
                STA CATT,Y
                DEX
                STA WEAPTOT,X
                LDA RTOTNUM,Y
                STA RTOTAL,Y
                DEY
                BPL XLOOP1
                RTS
