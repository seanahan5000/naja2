
;-----------------------------------------------------------

PICK_A_ROBOT    STA THE_ROBOT           ; briefly hold message index
                JSR COUNT_ROBOTS
                STX CURSOR
                LDA ROBOT_COUNT
                CMP #1
                BNE :PICK_ONE
                JMP :GOT_ONE

:PICK_ONE       JSR PPEOR
                JSR ALL_ICONS
                JSR DRAW_GROUP

                JSR DRAW_PICT
                PictClear 0;87;40;107
                PictSwitch THE_ROBOT    ; message index
:0              PictCase :1
                PictTextAt 59;98;"REPLACE PARTS ON WHICH ROBOT?"
:1              PictCase :END
                PictTextAt 50;98;"WHICH ROBOT DO YOU WANT TO SELL?"
:END            PictSwitchEnd
                PictEnd

                JSR VIEWER
                LDA #$00
                STA LEGALS+7

                LDY #7
                STY CURSOR
:2              LDA RYPOINTS,Y
                STA LINTABL,Y
                DEY
                BPL :2

                LDA #$03
                STA XHOLD
                JSR KDOWN2
                JSR RCURSIT
                LDA CURSOR
                CMP #$07
                BNE :GOT_ONE
                JMP OPTIONS

:GOT_ONE        LDA CURSOR
                STA THE_ROBOT
                RTS

RYPOINTS        DB  128,137,146
                DB  155,164,173
                DB  0,185

;-----------------------------------------------------------

VOMAIN          LDX #$03
:1              LDA CAT1,X
                STA THE_PRICE,X
                DEX
                BPL :1

                LDX #$6B
                LDY CHYPS
                JSR MOVE_TO
                JSR SEVEN8

                LDX #$03
:2              LDA CAT0,X
                STA THE_PRICE,X
                DEX
                BPL :2
                LDY #$07
:3              LDX #$03
                CLC
:4              LDA CAT2,Y
                SED
                ADC THE_PRICE,X
                CLD
                STA THE_PRICE,X
                DEY
                DEX
                BPL :4
                TYA
                BPL :3

                LDX #$6B
                LDY CHYPS+1
                JSR MOVE_TO
                JSR SEVEN8

                LDX #1
:6              STX COUNT
                LDY CHYPS+1,X
                LDX #$6B
                JSR MOVE_TO
                LDA COUNT
                JSR VOSUB
                LDX COUNT
                INX
                CPX #scrnPROGRAM+1
                BNE :6
                RTS

VOSUB           CLC
                ADC #$01
                ASL
                ASL
                TAY
                DEY
                LDX #$03
:1              LDA BODTOT,Y
                STA THE_PRICE,X
                DEY
                DEX
                BPL :1
                ; fall through

SEVEN8          LDA PARTALL
                CMP #$EE
                BNE NOT78
SEVENX          LDA #$88                ; modified
                LDX #<THE_PRICE
                LDY #>THE_PRICE
                JSR MULTIPLY_14
                LDX #3
:1              LDA PRODUCT_5,X
                STA THE_PRICE,X
                DEX
                BPL :1
NOT78           NOP                     ; modified
                LDX #<THE_PRICE
                LDY #>THE_PRICE
                JMP DRAW_CREDITS

; draw left-justified, without gaps
DRAW_PRICE      LDX #4
:1              LDA THE_PRICE-1,X
                PHA
                DEX
                BNE :1
;               LDX #0
                LDA #4
                JSR DIGITS_L
                LDA #TextLineEnd
                STA TEXTBUF,X
                JMP DRAW_TEXTBUF

*-------------------------------

OPENUP          LDX #$6B
:1              LDA #$05
                LDY #$23
                JSR OCSUB1
:2              LDA RCOLUMN
                LDY LCOLUMN
                JSR OCSUB2
                INC LCOLUMN
                DEC RCOLUMN
                LDA RCOLUMN
                CMP #$13
                BNE :2
                CPX #$6B
                BEQ :4
                CPX #$BF
                BEQ :5
                LDY #$0F
                LDA #$00
:3              STA (SCREENL),Y
                INY
                CPY #$18
                BNE :3
:4              INX
                BNE :1
:5              RTS

CLOSEUP         LDX #$6B
:1              LDA #$0E
                LDY #$18
                JSR OCSUB1
:2              LDA LCOLUMN
                LDY RCOLUMN
                JSR OCSUB2
                DEC LCOLUMN
                INC RCOLUMN
                LDA RCOLUMN
                CMP #$28
                BNE :2
                LDY #$04
                LDA #$00
:3              STA (SCREENL),Y
                DEY
                BPL :3
                LDY #$27
:4              STA (SCREENL),Y
                DEY
                CPY #$23
                BNE :4
                CPX #$6B
                BEQ :5
                CPX #$BF
                BEQ :6
                LDY #$13
                STA (SCREENL),Y
                INY
                LDA (SCREENL),Y
                AND #$C0
                STA (SCREENL),Y
:5              INX
                BNE :1
:6              RTS

OCSUB1          STA LCOLUMN
                STY RCOLUMN
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                RTS

OCSUB2          PHA
                LDA (SCREENL),Y
                DEY
                DEY
                DEY
                DEY
                STA (SCREENL),Y
                PLA
                TAY
                LDA (SCREENL),Y
                INY
                INY
                INY
                INY
                STA (SCREENL),Y
                RTS

REVERSE         LDY #baseupreflex
                LDA (CHARDL),Y
                SED
                SEC
                SBC #$25
                CLD
                PHA
                LSR
                LSR
                LSR
                AND #%11111110
                TAX
                PLA
                AND #$0F
                BEQ SKIP12
                INX
SKIP12          STX UPREF
                INY                 ;baselwreflex
                LDA (CHARDL),Y
                SEC
                SBC #$20            ;Works w/o BCD
                PHA
                LSR
                LSR
                LSR
                TAX
                PLA
                AND #$0F
                BEQ SKIP34
                INX
SKIP34          STX LOWREF
                LDY #e1_HEAD+2
                LDA (CHARDL),Y
                PHA
                AND #$0F
                STA SPBODY
                PLA
                LSR
                LSR
                LSR
                LSR
                STA SEBODY
                DEY
                LDA (CHARDL),Y
                PHA
                AND #$0F
                STA SPHEAD
                PLA
                LSR
                LSR
                LSR
                LSR
                STA SEHEAD
                DEY
                LDA (CHARDL),Y
                PHA
                AND #$07
                SEC
                SBC #$02
                STA RRANGE
                LDX #$00
                PLA
                BPL SKIP56
                INX
SKIP56          STX SLOT
                LDY #e1_HEAD+3
                LDA (CHARDL),Y
                STA ECAPAC
                LDA #$00
                STA PLEVEL
                STA AUTO
                LDY #e15_PROGRAM+1
                LDA (CHARDL),Y
                BPL NOAUT
                INC AUTO
                AND #$7F
NOAUT           LDY #$00
NCLOOP1         CMP PROGS,Y
                BEQ NCSKIP1
                INY
                BNE NCLOOP1
NCSKIP1         STY PLEVEL
                LDY #e3_ROBLFT
                JSR LRWEAPR
                STA LWEAPON
                LDY #e5_ROBRGT
                JSR LRWEAPR
                STA RWEAPON
                RTS

LRWEAPR         LDX #$00
LRLOOP1         LDA (CHARDL),Y
                CMP ROBWEPS,X
                BEQ LRSKIP1
                INX
                INX
LRSKIP2         CPX #$0E
                BNE LRLOOP1
                LDA #$FF
                RTS
LRSKIP1         INX
                INX
                INY
                LDA (CHARDL),Y
                DEY
                CMP ROBWEPS-1,X
                BNE LRSKIP2
                TXA
                LSR
                SEC
                SBC #$01
                RTS

TOTALUP         LDA #$0C
                STA COUNT
TOLOOP1         LDX COUNT
                LDY SLOT,X
                JSR VALUSUB
                DEC COUNT
                BPL TOLOOP1
                LDX #27
                LDA #0
TOLOOP2         STA BODTOT,X
                DEX
                BPL TOLOOP2
                LDA #scrnPROGRAM
                STA COUNT
TOLOOP5         LDY COUNT
                LDA BEGCATS,Y
                TAX
                CLC
                ADC NUMCATS,Y
                STA SCRATCH
TOLOOP3         LDA #$03
                STA COUNTER
                TXA
                PHA
                CLC
                ADC #$01
                ASL
                ASL
                TAX
                DEX
                LDY COUNT
                INY
                TYA
                ASL
                ASL
                TAY
                DEY
                CLC
TOLOOP4         LDA BODTOT,Y
                SED
                ADC CAT0,X
                CLD
                STA BODTOT,Y
                DEX
                DEY
                DEC COUNTER
                BPL TOLOOP4
                PLA
                TAX
                INX
                CPX SCRATCH
                BNE TOLOOP3
                DEC COUNT
                BPL TOLOOP5
                RTS

GBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI GKEYIN
                JSR CURSUB
                LDA #$00
                JSR WAIT_KEY
                JSR CURSUB
GKEYIN          LDA KEYBRD
                BPL GBLINK
                BIT UNSTROB
                JSR CHECK_UP
                BEQ GLEFT
                JSR CHECK_LEFT
                BEQ GLEFT
                JSR CHECK_DOWN
                BEQ GRIGHT
                JSR CHECK_RIGHT
                BEQ GRIGHT
                JSR CHECK_ENTER
                BEQ GENTER
                JSR CHECK_CANCEL
                BNE GKEYIN
                LDX PICK
                LDA ON1,X
                ORA #$0F
                STA ON1,X
                JSR ERASE_CBOX
                LDA CURSUB
                CMP #$EA
                BEQ GOOPTS
                JSR CURFLIP
GOOPTS          LDA PARTALL
                CMP #$D0
                BEQ GOPBACK
                JMP OPTIONS
GOPBACK         JMP PBACK

GENTER          JSR ERASE_CBOX
                JMP CURSUB              ; undo cursor draw

GLEFT           JSR ERASE_CBOX
:1              LDY CURSOR
                DEY
                BPL :2
                LDY #8
:2              STY CURSOR
                LDA LEGALS,Y
                BNE :1
                BEQ GBOXSUB             ; always

GRIGHT          JSR ERASE_CBOX
:1              LDY CURSOR
                INY
                CPY #9
                BNE :2
                LDY #0
:2              STY CURSOR
                LDA LEGALS,Y
                BNE :1
                ; fall through

GBOXSUB         JSR DRAW_CBOX
                JMP GKEYIN

DRAW_CBOX       LDA #OpColorWhite1
                JSR CBOX_SUB
                JMP CURSUB

ERASE_CBOX      LDA #OpColorGreen
                JSR CBOX_SUB
                LDX #0
:1              STX LINENUM
                JSR SET_SOURCE_LINE
                LDX #0
:2              LDY :COLUMNS,X
                LDA (SCREENL),Y
                AND :MASKS,X
                STA (SCREENL),Y
                INX
                CPX #4
                BNE :2
                LDX LINENUM
                INX
                CPX #87
                BNE :1
                JMP CURSUB

:COLUMNS        DB  6,15,25,34
:MASKS          DB  $2A,$55,$55,$2A

CBOX_SUB        JSR SET_COLOR
                JSR DRAW_PICT
                PictSwitch CURSOR
:0              PictCase :1
                PictRect 42;0;108;43
:1              PictCase :2
                PictRect 110;0;176;43
:2              PictCase :3
                PictRect 178;0;244;43
:3              PictCase :4
                PictRect 178;0;244;43
:4              PictCase :5
                PictRect 42;43;108;86
:5              PictCase :6
                PictRect 110;43;176;86
:6              PictCase :7
                PictRect 178;43;244;86
:7              PictCase :END
:END            PictSwitchEnd
                PictEnd
                RTS

BOXCURS         LDY SCRPICK
                LDA BEGCATS,Y
                STA MINIMUM
                LDA NUMCATS,Y
                STA MAXIMUM
                LDA #$00
                STA POINTER
                LDA #$03
                STA COUNTER
                JMP BSTOP

VBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI BSTOP
                JSR ERASE_VBOX
                LDA #$00
                JSR WAIT_KEY
                JSR DRAW_VBOX
BSTOP           DEC COUNTER
                BMI VKEYIN
                BIT KEYBRD
                BPL VBLINK
VKEYIN          LDA KEYBRD
                BPL VKEYIN
                BIT UNSTROB
                JSR CHECK_UP
                BEQ GOVUP
                JSR CHECK_DOWN
                BEQ GOVDOWN
                JSR CHECK_LEFT
                BEQ VLEFT
                JSR CHECK_RIGHT
                BEQ VRIGHT
                JSR CHECK_ENTER
                BEQ GOVENT
                CMP #$C3
                BNE VKEYIN
VCANC           LDA PARTALL
                CMP #$E0
                BEQ :1
                CMP #$D0
                BNE NOPGO
:1              RTS                 ;Carry assumed set
NOPGO           LDX PICK
                LDA #$FF
                STA ON1,X
                JMP OPTIONS
GOVUP           JMP VUP
GOVDOWN         JMP VDOWN
GOVENT          JMP VENTER

VLEFT           JSR ERASE_VBOX
                LDX POINTER
                BNE :1
                LDX MAXIMUM
:1              DEX
                BPL VLR_CMN             ; always

VRIGHT          JSR ERASE_VBOX
                LDX POINTER
                INX
                CPX MAXIMUM
                BNE VLR_CMN
                LDX #0
VLR_CMN         STX POINTER
                JSR DRAW_VBOX
                LDA MINIMUM
                CLC
                ADC POINTER
                JSR POINTAT
                JMP VKEYIN

VUP             LDX POINTER
                LDA POINTLV,X
                CMP NUMTYPE
                BEQ GOVKEY
                LDY SCRPICK
                CPY #scrnPROGRAM
                BNE NOTPROG
                CMP LIMIT
                BEQ GOVKEY
NOTPROG         JSR UPDBOX
                LDX POINTER
                INC POINTLV,X
                JSR UPDBOX
                JSR BIGSUB
                JSR UPDSUB
                LDA SCRPICK
                CMP #scrnMOVEMENT
                BNE GOVKEY
                JSR UPMOVE
                JMP VKEYIN

VDOWN           LDX POINTER
                LDA POINTLV,X
                BEQ GOVKEY
                LDY SCRPICK
                CPY #scrnBODY
                BNE NOTA1
                CMP MINUPR
                BEQ GOVKEY
NOTA1           CPY #scrnMOVEMENT
                BNE NOTA4
                CMP MINLOW
                BEQ GOVKEY
NOTA4           JSR UPDBOX
                LDX POINTER
                DEC POINTLV,X
                JSR UPDBOX
                JSR BIGSUB
                JSR UPDSUB
                LDA SCRPICK
                CMP #scrnMOVEMENT
                BNE GOVKEY
                JSR DWNMOVE
GOVKEY          JMP VKEYIN

VENTER          LDA EXPFLAG
                BEQ CANPIC
                JSR EBLINK
                JMP VKEYIN

CANPIC          LDA SCRPICK
                ASL
                ASL
                TAX
                LDY #$00
TOTOT           LDA EVALNUM,Y
                STA BODTOT,X
                INX
                INY
                CPY #$04
                BNE TOTOT
                CLC
                RTS

DRAW_EXPENSIVE  JSR DRAW_PICT
                PictTextAt 133;37;">>TOO EXPENSIVE<<"
                PictEnd
                RTS

EBLINK          LDA #$02
                STA COUNT
EXPLOOP         LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI EXGOT
                JSR DRAW_EXPENSIVE
                LDA #$00
                JSR WAIT_KEY
                JSR DRAW_EXPENSIVE
                DEC COUNT
                BNE EXPLOOP
EXGOT           BIT UNSTROB
                RTS

UPMOVE          LDA #$40                ; threshold
                STA PUTMOD+1
                JSR UPDOWN
                PHA
                JSR DRAW_MOVEMENTS
                PLA
                CLC
                ADC #1
                JMP DRAW_MOVEMENTS

DWNMOVE         LDA #$35                ; threshold
                STA PUTMOD+1
                JSR UPDOWN
                PHA
                CLC
                ADC #1
                JSR DRAW_MOVEMENTS
                PLA
                JMP DRAW_MOVEMENTS

UPDOWN          LDY POINTER
                LDA POINTLV,Y
                TAY
                LDA (VALUEL),Y
                TAX
PUTMOD          LDA #$40
                STA SCRATCH

                LDY #0                  ; TREAD
UDLOOP          CPX SCRATCH
                BNE NOTAT
                TYA
                RTS

NOTAT           LDA SCRATCH
                CLC
                ADC #$20
                STA SCRATCH
                INY
                CPY #3                  ; BI-LEG
                BNE UDLOOP
                PLA                     ; prevent caller from drawing
                PLA
                RTS

DRAW_MOVEMENT_T TAY
                LDX :XPNTS,Y
                LDY #81
                BNE MOVEMENT_CMN        ; always

:XPNTS          DB  191,179,179,188

DRAW_MOVEMENTS  PHA
                JSR DRAW_MOVEMENT_T
                PLA
DRAW_MOVEMENT_B LDX #146
                LDY #169
MOVEMENT_CMN    PHA
                JSR MOVE_TO
                PLA
                LDX #<:MOVEMENT_TYPES
                LDY #>:MOVEMENT_TYPES
                JSR GET_IND_STRING
                JMP DRAW_TEXTBUF

:MOVEMENT_TYPES TXI "TREAD"
                TXI "LEVITATOR"
                TXI "TETRA-LEG"
                TXI "BI-LEG"

UPDSUB          LDY SCRPICK
                LDA BEGCATS,Y
                CLC
                ADC POINTER
                TAX
                LDY POINTER
                LDA POINTLV,Y
                TAY
                JSR VALUSUB
                JSR CATTOTL
                LDX #$03
                CLC
UPLOOPA         LDA RTOTAL,X
                SED
                ADC CATT,X
                CLD
                STA RTOTNEW,X
                DEX
                BPL UPLOOPA
                LDX #$03
                SEC
UPLOOPB         LDA CATT,X
                SED
                SBC ETRDNUM,X
                CLD
                STA EVALNEW,X
                DEX
                BPL UPLOOPB
                LDA EXPFLAG
                PHA
                JSR TRADSUB
                PLA
                CMP EXPFLAG
                BEQ TOUPDAT
                JSR DRAW_EXPENSIVE
TOUPDAT         JMP UPDATER

UPDSUB2         LDA SCRPICK
                SEC
                SBC #scrnWEAPONL-1
                PHA
                CLC
                ADC #6
                TAX
                LDY CURSOR
                JSR VALUSUB
                PLA
                ASL
                ASL
                PHA
                TAY
                LDX #3
                CLC
UPLA            LDA RTOTAL,X
                SED
                DEY
                ADC CAT7,Y
                CLD
                STA RTOTNEW,X
                DEX
                BPL UPLA
                PLA
                TAY
                LDX #3
                SEC
UPLB            DEY
                LDA CAT7,Y
                SED
                SBC ETRDNUM,X
                CLD
                STA EVALNEW,X
                DEX
                BPL UPLB
                LDA EXPFLAG
                PHA
                JSR TRADSUB
                JSR UPDATER
                PLA
                CMP EXPFLAG
                BEQ TOUPD2
                JSR DRAW_EXPENSIVE
TOUPD2          LDX SCRPICK
                LDY YSPOTS+7-scrnWEAPONL,X
                JSR VMOVE_TO
                JSR WEANUMS
                LDA #$80
                STA XHOLD
                RTS

ETRDNUM         DB  $00,$00,$00
                DB  $00
EVALNUM         DB  $00,$00,$00
                DB  $00

UPDBOX          LDY SCRPICK
                LDA BEGCATS,Y
                CLC
                ADC POINTER
                TAX
                LDY YSPOTS,X
                JSR VMOVE_TO
                TXA
                JSR POINTAT
                LDY POINTER
                LDA POINTLV,Y
                TAY
                LDA (VALUEL),Y
                PHA
                TXA
                ASL
                TAX
                LDA NUMS+1,X
                PHA
                LDA NUMS,X
                PHA
                RTS

NUMS            DW  SLTNUMS-1
                DW  SRANUMS-1
                DW  BHENUMS-1
                DW  BHPNUMS-1
                DW  BODNUMS-1
                DW  BHENUMS-1
                DW  BHPNUMS-1
                DW  WEANUMS-1
                DW  WEANUMS-1
                DW  ENRNUMS-1
                DW  BHPNUMS-1
                DW  PRONUMS-1
                DW  AUTNUMS-1

BODNUMS         PLA
                JSR TWODIGI
                LDA #TextSpace
                STA TEXTBUF+2
                LDA #TextLineEnd
                STA TEXTBUF+5
                LDX #$92
                JMP DRAW_TEXTBUF_X

BHENUMS         PLA
                JSR GOTWO
                LDX #$C8
                BNE BHCOMN              ; always
BHPNUMS         PLA
                JSR GOTWO
                LDX #$E6                ; always
BHCOMN          JMP DRAW_TEXTBUF_X

GOTWO           JSR TWODIGI
                LDA #TextLineEnd
                STA TEXTBUF+2
                LDA TEXTBUF
                BNE GTOUT
                LDA #TextEmpty
                STA TEXTBUF
GTOUT           RTS

TWODIGI         TAY
                AND #$0F
                STA TEXTBUF+1
                STA TEXTBUF+4
                TYA
                LSR
                LSR
                LSR
                LSR
                STA TEXTBUF
                STA TEXTBUF+3
                RTS

WEANUMS         LDA CURHOLD
                JSR WEASUB
                LDA CURSOR
WEASUB          ASL
                TAX
                LDA ROBWEPS,X
                STA ETABLE
                LDA ROBWEPS+1,X
                STA ETABLE+1
                JSR ETABLE_TO_TEXT
                LDX #$92
                JMP DRAW_TEXTBUF_X

SLTNUMS         PLA
                AND #$01
                ASL
                ASL
                TAX
                LDY #$00
NYLOOP          LDA YNWORD,X
                STA TEXTBUF,Y
                INX
                INY
                CPY #$04
                BNE NYLOOP
                LDX #$92
                JMP DRAW_TEXTBUF_X

YNWORD          USR (YES)
                USR (NO)

SRANUMS         PLA
                AND #$0F
                STA TEXTBUF
                LDA #TextLineEnd
                STA TEXTBUF+1
                LDX #$92
                JMP DRAW_TEXTBUF_X

PRONUMS         LDA VALUEL
                STA VHOLD
                LDA VALUEH
                STA VHOLD+1
                LDY SCRPICK
                LDA BEGCATS,Y
                CLC
                ADC #$01
                JSR POINTAT
                LDY #$01
                LDA POINTLV,Y
                TAY
                LDA (VALUEL),Y
                TAX
                PLA
                AND #$F7
                TAY
                TXA
                PHA
                JMP PROCOMN

AUTNUMS         LDA VALUEL
                STA VHOLD
                LDA VALUEH
                STA VHOLD+1
                LDY SCRPICK
                LDA BEGCATS,Y
                JSR POINTAT
                LDA POINTLV
                TAY
                LDA (VALUEL),Y
                AND #$F7
                TAY
                DEC YPNT
PROCOMN         LDX #$00
                TYA
                AND #$F0
                BEQ DIG1
                TYA
                LSR
                LSR
                LSR
                LSR
                STA TEXTBUF,X
                INX
DIG1            TYA
                AND #$0F
                STA TEXTBUF,X
                INX
                PLA
                CMP #$AA
                BNE NOTAF
                LDA #$0B
                STA TEXTBUF,X
                INX
NOTAF           LDA #TextLineEnd
                STA TEXTBUF,X
                LDX #$B6
                JSR DRAW_TEXTBUF_X
                LDA VHOLD
                STA VALUEL
                LDA VHOLD+1
                STA VALUEH
                RTS

VHOLD           DB  $00,$00

ENRNUMS         PLA
                TAY
                LDX #$00
                CPY #$80
                BCC NORMNUM
                CPY #$90
                BCC PLUS80
                LDA #$01
                STA TEXTBUF,X
                INX
PLUS80          TYA
                AND #$0F
                STA TEXTBUF,X
                INX
                BNE ZERO3
NORMNUM         TYA
                LSR
                LSR
                LSR
                LSR
                BEQ NODIGT1
                STA TEXTBUF,X
                INX
NODIGT1         TYA
                AND #$0F
                STA TEXTBUF,X
                INX
                LDA #$00
                STA TEXTBUF,X
                TYA
                AND #$0F
                CMP #$02
                BEQ DOFIVE
                CMP #$07
                BNE NOFIVE
DOFIVE          LDA #$05
                STA TEXTBUF,X
NOFIVE          INX
ZERO3           LDY #$02
                LDA #$00
ZLOOP           STA TEXTBUF,X
                INX
                DEY
                BPL ZLOOP
                LDA #TextLineEnd
                STA TEXTBUF,X
                LDX #$B0
                JMP DRAW_TEXTBUF_X

YSPOTS          DB  $78,$6F,$78
                DB  $78,$83,$83
                DB  $83,$8E,$97,$A0
                DB  $A9,$B4,$B5

;-----------------------------------------------------------

NUMCATS         DB  $04,$03,$01,$01
                DB  $01,$01,$02
BEGCATS         DB  $00,$04,$07,$08
                DB  $09,$0A,$0B

UPDATER         LDX #$00
                LDY #$00
MORTOT          LDA RTOTNEW,Y
                PHA
                LSR
                LSR
                LSR
                LSR
                STA SCNBUFF,X
                INX
                PLA
                AND #$0F
                STA SCNBUFF,X
                INX
                INY
                CPX #$08
                BNE MORTOT
                LDX #$00
SPRTOT          LDA SCNBUFF,X
                BNE TSPACED
                LDA #TextSpace
                STA SCNBUFF,X
                INX
                CPX #$07
                BNE SPRTOT
TSPACED         LDX #$07
ASERASE         LDA RTOTSCN,X
                CMP SCNBUFF,X
                BNE NOSAME1
                LDA #TextSpace
NOSAME1         STA TEXTBUF,X
                DEX
                BPL ASERASE

                LDX #$D6
                LDY #$18
                JSR MOVE_TO
                JSR DRAW_TEXTBUF_SPLIT

                LDX #$07
ASDRAW          LDA SCNBUFF,X
                CMP RTOTSCN,X
                BNE NOSAME2
                LDA #TextSpace
NOSAME2         STA TEXTBUF,X
                DEX
                BPL ASDRAW

                LDX #$D6
                JSR HMOVE_TO
                JSR DRAW_TEXTBUF_SPLIT

                LDX #$07
MVLOOPA         LDA SCNBUFF,X
                STA RTOTSCN,X
                DEX
                BPL MVLOOPA
                LDX #$03
MVLOOPB         LDA RTOTNEW,X
                STA RTOTNUM,X
                DEX
                BPL MVLOOPB
                LDX #$00
                LDY #$00
MORETOT         LDA EVALNEW,Y
                PHA
                LSR
                LSR
                LSR
                LSR
                STA SCNBUFF,X
                INX
                PLA
                AND #$0F
                STA SCNBUFF,X
                INX
                INY
                CPX #$08
                BNE MORETOT
                LDX #$00
SPETOT          LDA SCNBUFF,X
                BNE TSPACE2
                LDA #TextSpace
                STA SCNBUFF,X
                INX
                CPX #$07
                BNE SPETOT
TSPACE2         LDX #$07
BSERASE         LDA EVALSCN,X
                CMP SCNBUFF,X
                BNE NOSAME3
                LDA #TextSpace
NOSAME3         STA TEXTBUF,X
                DEX
                BPL BSERASE

                LDX #$D6
                LDY #$0E
                JSR MOVE_TO
                JSR DRAW_TEXTBUF_SPLIT

                LDX #$07
BSDRAW          LDA SCNBUFF,X
                CMP EVALSCN,X
                BNE NOSAME4
                LDA #TextSpace
NOSAME4         STA TEXTBUF,X
                DEX
                BPL BSDRAW

                LDX #$D6
                JSR HMOVE_TO
                JSR DRAW_TEXTBUF_SPLIT

                LDX #$07
MVLOOPC         LDA SCNBUFF,X
                STA EVALSCN,X
                DEX
                BPL MVLOOPC
                LDX #$03
MVLOOPD         LDA EVALNEW,X
                STA EVALNUM,X
                DEX
                BPL MVLOOPD
                RTS

MINISUB         LDA #$00
                STA MINLOW
                STA MINUPR
                LDY PLEVEL
                CPY #$15
                BCS MINIOUT
                CPY #$08
                BCS OVER9
                LDA LESS9,Y
                TAX
                AND #$0F
                STA MINUPR
                TXA
                LSR
                LSR
                LSR
                LSR
                STA MINLOW
MINIOUT         RTS

OVER9           TYA
                SEC
                SBC #$05
                STA MINLOW
                STA MINUPR
                DEC MINUPR
                RTS

LESS9           DB  $00,$00,$00
                DB  $10,$10,$11
                DB  $21,$21

LIMITER         LDY LOWREF
                CPY #$03
                BCS LISKIP1
                LDA MAXILOW,Y
                BNE LISKIP2
LISKIP1         TYA
                CLC
                ADC #$05
LISKIP2         STA SCRATCH
                LDY UPREF
                CPY #$02
                BCS LISKIP3
                LDA MAXIUP,Y
                BNE LISKIP4
LISKIP3         TYA
                CLC
                ADC #$06
LISKIP4         CMP SCRATCH
                BCC LIMOUT
                LDA SCRATCH
LIMOUT          STA LIMIT
                RTS

MAXIUP          DB  $04,$06
MAXILOW         DB  $02,$05,$06

CATTOTL         LDY #$03
                LDA #$00
CTLOOP1         STA CATT,Y
                DEY
                BPL CTLOOP1
                LDY SCRPICK
                LDA BEGCATS,Y
                STA COUNTER
                CLC
                ADC NUMCATS,Y
                STA TEMP
CTLOOP3         LDA COUNTER
                CLC
                ADC #$01
                ASL
                ASL
                TAX
                DEX
                LDY #$03
                CLC
CTLOOP2         LDA CAT0,X
                SED
                ADC CATT,Y
                CLD
                STA CATT,Y
                DEX
                DEY
                BPL CTLOOP2
                INC COUNTER
                LDA COUNTER
                CMP TEMP
                BNE CTLOOP3
                RTS

RTSUB           LDY #$07
                LDA #TextSpace
RTLOOP1         STA RTOTSCN,Y
                DEY
                BPL RTLOOP1
                LDY #$03
                LDA #$00
RTLOOP2         STA RTOTNUM,Y
                DEY
                BPL RTLOOP2
                RTS

*-------------------------------

COUNT_CYBS      JSR RESET_CHLIST
                LDA #cybernate*16
                JSR CSCAN_PROF
                PHP                 ;Carry clear if no cybs at all
                LDX #<CCALL_UNASS
                LDY #>CCALL_UNASS
                JSR CSCAN_COMMON
                STX ASSIGN2
                STA CYB_COUNT       ;Count of AVAILABLE cybs in group
                LDA #0
                STA LEGALS+7
                PLP
                RTS

CYB_COUNT       DB  0

CCALL_UNASS     LDY #robotcyblink
                LDA (CHARDL),Y
                CMP #$FF
                RTS

*-------------------------------

COUNT_ROBOTS    JSR RESET_CHRLIST
                LDA #robot*16
                JSR CSCAN_PROF
                STA ROBOT_COUNT
                RTS                 ;X valid on exit

ROBOT_COUNT     DB  0

*-------------------------------

PPEOR           JSR SET_PAGEX
                LDA PICK
                EOR #$01
                STA PICK
                RTS

VIEWER          BIT UNSTROB
                LDA PICK
                BEQ :1
                STA SCNDARY
                RTS
:1              STA PRIMARY
                RTS

PACSUB          JSR PPEOR
                JSR ALL_ICONS
                JSR DRAW_PICT
                PictClear 0;87;40;192
                PictEnd
                RTS

SPACE_IN        JSR NOTCH_IN
                JSR DRAW_PICT
                PictTextAt 205;107;"<SPACE>"
                PictEnd
                RTS

CANCEL_IN       JSR NOTCH_IN
                JSR DRAW_PICT
                PictTextAt 205;107;"C>ANCEL"
                PictEnd
                RTS

NOTCH_IN        JSR DRAW_PICT
                PictSetBlack1
                PictMoveTo $C7;$6B
                PictLineTo $F6;$6B
                PictLineTo $F6;$73
                PictSetBlue
                PictMoveTo $C8;$6B
                PictLineTo $C8;$73
                PictLineTo $F6;$73
                PictEnd
                RTS

NOTCH_OUT       JSR DRAW_PICT
                PictClear 28;107;36;116
                PictSetBlue
                PictMoveTo 196;107
                PictLineTo 246;107
                PictLineTo 246;115
                PictEnd
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
CKEYMOD         CMP #$00
                BEQ KEYOUT
                JSR CHECK_ENTER
                BNE KEYMOVE
KEYOUT          RTS

KUP             JSR RCURSIT
                LDA CURSOR
                STA CURHOLD
KUP2B           DEC CURSOR
                BPL KUP3
                LDA #$08
                STA CURSOR
KUP3            LDY CURSOR
                LDA LEGALS,Y
                BNE KUP2B
                JSR RCURSIT
KUPMOD          DB  $EA,$EA,$EA
                JMP KEYMOVE

KDOWN           JSR RCURSIT
KDOWN2          LDA CURSOR
                STA CURHOLD
KDOWN2B         INC CURSOR
                LDA CURSOR
                CMP #$09
                BNE KDOWN3
                LDA #$00
                STA CURSOR
KDOWN3          LDY CURSOR
                LDA LEGALS,Y
                BNE KDOWN2B
                JSR RCURSIT
KDOMOD          DB  $EA,$EA,$EA
                JMP KEYMOVE

RCURSIT         LDX CURSOR
                LDY LINTABL,X
                LDX XHOLD
                JMP DRAW_ARROW

CURFLIP         LDX #$02
CURLOOP         LDY CURSUB,X
                LDA CFSPOT,X
                STA CURSUB,X
                TYA
                STA CFSPOT,X
                DEX
                BPL CURLOOP
                RTS

CFSPOT          JMP CHURSIT
CURSUB          NOP
                NOP
                NOP
                LDY CURSOR
                LDA CHUNKS,Y
                PHA
                AND #$0F
                JSR CARP
                PLA
                LSR
                LSR
                LSR
                LSR
                CMP #$0F
                BEQ CHOUT
CARP            TAX

                ; LDA CHYPS,X
                ; STA YPNT
                ; LDA #$6E
                ; STA XPNT
                ; LDA #$03
                ; JSR SPCHARS
                ; LDA #$A3
                ; STA XPNT
                ; LDA #$02
                ; JMP SPCHARS

                LDY CHYPS,X
                LDX #$63
                JSR MOVE_TO
                ; *** DRAW REVERSE TRIANGLE ***
                LDY YCOORD
                LDX #$A3
                JMP DRAW_TRIANGLE

CHURSIT         LDY CURSOR
                LDA CHUNKS,Y
                PHA
                AND #$0F
                JSR CHURP
                PLA
                LSR
                LSR
                LSR
                LSR
                CMP #$0F
                BNE CHURP
CHOUT           RTS
CHURP           TAX
                LDY CHYPS,X
                LDX #$8A
                JMP DRAW_TRIANGLE

CHUNKS          DB  $10,$F2,$F3,$F4
                DB  $F5,$F6,$F7
CHYPS           DB  $6F,$78,$83
                DB  $8E,$97,$A0
                DB  $A9,$B4

SET_LEGALS      TAY
                LDX #15
                LDA #$FF
:LOOP1          STA LEGALS,X
                DEX
                BPL :LOOP1
                LDA #0
:LOOP2          DEY
                BMI :EXIT
                STA LEGALS,Y
                BPL :LOOP2          ;Always
:EXIT           RTS

OPTYPNT         DB  $7C,$87,$90
                DB  $9B

;-----------------------------------------------------------

DRAW_FIRST_VBOX LDA #OpColorViolet
                JSR SET_COLOR
                JMP VBOX_CMN2

DRAW_VBOX       LDA #OpColorViolet
                BNE VBOX_CMN1           ; always
ERASE_VBOX      LDA #OpColorBlack1
VBOX_CMN1       JSR SET_COLOR
                LDA MINIMUM
                CLC
                ADC POINTER
                TAX
VBOX_CMN2       CPX #$0A
                BNE :1

                JSR DRAW_PICT
                PictRect $7A;$36;$EE;$5E
                PictMoveTo $80;$4A
                PictLineTo $E8;$4A
                PictEnd
                RTS

:1              CPX #$09
                BNE :2
                JSR DRAW_PICT
                PictRect $86;$36;$E8;$56
                PictMoveTo $8C;$42
                PictLineTo $E2;$42
                PictEnd
                RTS

:2              TXA
                ASL
                TAX
                LDA :XDATA+0,X
                STA :MOD1+1
                STA :MOD2+1
                LDA :XDATA+1,X
                CMP #$FF
                BNE :3
                JSR DRAW_PICT
:MOD1           PictRect $FF;54;$112;72
                PictEnd
                RTS

:3              STA :MOD2+3
                JSR DRAW_PICT
:MOD2           PictRect $FF;54;$FF;72
                PictEnd
                RTS

:XDATA          DB  $0A,$4C
                DB  $5C,$82
                DB  $8A,$D0
                DB  $D2,$FF
                DB  $0A,$6C
                DB  $7C,$C2
                DB  $D2,$FF
                DB  $00,$00
                DB  $00,$00
                DB  $00,$00
                DB  $00,$00
                DB  $7A,$AC
                DB  $C0,$E6

;-----------------------------------------------------------

HOLD_VALUE      =   LOCAL_TEMP+0        ;***
HOLD_CAT        =   LOCAL_TEMP+1

;*** move this header code and BXPNTS out of here? ***
BIGSUB          LDY SCRPICK
                LDA BEGCATS,Y
                CLC
                ADC POINTER
                STA HOLD_CAT
                JSR POINTAT
                LDY POINTER
                LDA POINTLV,Y
                TAY
                LDA (VALUEL),Y
                STA HOLD_VALUE
                LDY HOLD_CAT
                CPY #$09
                BEQ ENERNUM

NOTENER         LDA BXPNTS,Y
                STA XCOORD
                LDY #$4D
                STY YCOORD

                LDY #12                 ; NO
                LDA HOLD_VALUE
                CMP #$FF
                BEQ :1
                CMP #$AA
                BNE :2
                INY                     ; YES
:1              TYA
                JMP DRAW_BIGNUM

:2              LDY HOLD_CAT
                CPY #$04
                BNE :3
                JSR DIGIT2
                LDA #11                 ; /
                JSR DRAW_BIGNUM
                LDA HOLD_VALUE
:3              JMP DIGIT2

ENERNUM         LDA #$14
                STA XCOORD
                LDY #$45
                STY YCOORD

                LDA HOLD_VALUE
                BPL HIENER
                PHA
                AND #$7F
                LSR
                LSR
                LSR
                LSR
                BNE NOTWO0
                INC XCOORD
                INC XCOORD
                LDA #$0A                ; space
                JSR DRAW_BIGNUM
                JMP TWO0

NOTWO0          JSR DIGIT2
TWO0            PLA
                AND #$0F
                JMP DRAW_BIGNUM

HIENER          PHA
                JSR DIGIT2
                PLA
                AND #$0F
                CMP #$02
                BEQ USE5
                CMP #$07
                BEQ USE5
                LDA #$00
                BEQ GOBBR               ; always
USE5            LDA #$05
GOBBR           JMP DRAW_BIGNUM

BXPNTS          DB  $03,$0D,$17
                DB  $21,$03,$15
                DB  $21,$FF,$FF,$14
                DB  $13,$13,$1B

;-----------------------------------------------------------

DIGIT2          PHA
                LSR
                LSR
                LSR
                LSR
                BNE :1
                LDA #$0A                ; space
:1              JSR DRAW_BIGNUM
                PLA
                AND #$0F
;               JMP DRAW_BIGNUM

DRAW_BIGNUM     ASL
                TAY
                LDX BIG_PICS+0,Y
                LDA BIG_PICS+1,Y
                TAY
                JSR UNPACK_TO
                INC XCOORD
                INC XCOORD
                RTS

BIG_PICS        DW  NUM0_PIC
                DW  NUM1_PIC
                DW  NUM2_PIC
                DW  NUM3_PIC
                DW  NUM4_PIC
                DW  NUM5_PIC
                DW  NUM6_PIC
                DW  NUM7_PIC
                DW  NUM8_PIC
                DW  NUM9_PIC
                DW  SPACE_PIC           ; 10
                DW  SLASH_PIC           ; 11
                DW  NO_PIC              ; 12
                DW  YES_PIC             ; 13

NUM0_PIC        DB  $00,$00,$02,$0F
                HEX 8050545414A15454500A2A2A28A12A2A0A
                DB  $FF

NUM1_PIC        DB  $00,$00,$02,$0F
                HEX 8000004089009940890AAD2A89
                DB  $FF

NUM2_PIC        DB  $00,$00,$02,$0F
                HEX 805054541400009700008954890A2A2A28892A2A0A00892A
                HEX 89
                DB  $FF

NUM3_PIC        DB  $00,$00,$02,$0F
                HEX 8050545414000040890000145454500A2A2A28892A0A9703
                HEX 022A0A
                DB  $FF

NUM4_PIC        DB  $00,$00,$02,$0F
                HEX 8014955489009528952A892895
                DB  $FF

NUM5_PIC        DB  $00,$00,$02,$0F
                HEX 805489148954890000145454502A8900890A2A2A28892A2A
                HEX 0A
                DB  $FF

NUM6_PIC        DB  $00,$00,$02,$0F
                HEX 8050545414895489970103500A2A2A280000970200892A2A
                HEX 0A
                DB  $FF

NUM7_PIC        DB  $00,$00,$02,$0F
                HEX 80548914009140952A89288D0A0A0295
                DB  $FF

NUM8_PIC        DB  $00,$00,$02,$0F
                HEX 805054541489545097010254500A2A2A28892A0A9703022A
                HEX 0A
                DB  $FF

NUM9_PIC        DB  $00,$00,$02,$0F
                HEX 80505454148954545000009700050A2A2A28892A89970303
                HEX 0A
                DB  $FF

SPACE_PIC       DB  $00,$00,$02,$0F
                HEX 8000B900B9
                DB  $FF

SLASH_PIC       DB  $00,$00,$02,$0F
                HEX 800095406070787C3C1C00000000383C3E1F0F0703010091
                DB  $FF

NO_PIC          DB  $00,$4D,$06,$0F
                HEX 8000B914895495149528952A952889970206A15489970409
                HEX A12A8900B9
                DB  $FF

YES_PIC         DB  $00,$4D,$06,$0F
                HEX 8014955489000097000528952A899F020354899F00039F04
                HEX 0397020600000289000097020BA705069F00099F0600A703
                HEX 06
                DB  $FF

;-----------------------------------------------------------

POINTAT         ASL
                TAY
                LDA POINTS,Y
                STA VALUEL
                LDA POINTS+1,Y
                STA VALUEH
                LDA POINTS+2,Y
                CLC
                SBC VALUEL
                STA NUMTYPE
                RTS

POINTS          DW  ATSLOTS
                DW  SRANGES
                DW  HESS
                DW  HPSS
                DW  UPREFS
                DW  BESS
                DW  BPSS
                DW  ECAPS           ;Must be ECAPS
                DW  0
                DW  ECAPS
                DW  LOWREFS
                DW  PROGS
                DW  ASTARTS
                DW  DUMMY

ATSLOTS         DB  $FF,$AA
SRANGES         DB  $02,$03
                DB  $04,$05,$06
                DB  $07
HESS            DB  $04,$08
                DB  $12,$16
HPSS            DB  $05
                DB  $10,$15
UPREFS          DB  $25,$30
                DB  $35,$40,$45
                DB  $50,$55,$60
                DB  $65,$70,$75
                DB  $80,$85,$90
                DB  $95
BESS            DB  $10,$15
                DB  $20,$25,$30
                DB  $40,$50,$60
BPSS            DB  $10,$15,$20
                DB  $25,$30,$40
                DB  $50,$60,$70
                DB  $80
ECAPS           DB  $83,$86,$89
                DB  $92,$95,$03
                DB  $05,$07,$10
                DB  $12,$15,$17
                DB  $20,$22,$25
                DB  $27,$30,$32
                DB  $35,$37,$40
LOWREFS         DB  $20,$25
                DB  $30,$35,$40
                DB  $45,$50,$55
                DB  $60,$65,$70
                DB  $75,$80,$85
                DB  $90,$95
PROGS           DB  $01
                DB  $02,$03,$04
                DB  $05,$06,$07
                DB  $10
                DB  $15,$20,$25
                DB  $30,$35,$40
                DB  $45,$50,$55
                DB  $60,$65,$70
                DB  $75
ASTARTS         DB  $FF,$AA
DUMMY           DB  $00

;-----------------------------------------------------------

VALUSUB         TXA
                ASL
                TAX
                ASL
                PHA
                LDA CDATAS,X
                STA CDPNTL
                LDA CDATAS+1,X
                STA CDPNTH
                STY SCRATCH
                TYA
                ASL
                CLC
                ADC SCRATCH
                TAY
                PLA
                TAX
                LDA #$00
                STA CAT0,X
                INX
                LDA #$03
                STA LINENUM
LODLOOP         LDA (CDPNTL),Y
                STA CAT0,X
                INY
                INX
                DEC LINENUM
                BNE LODLOOP
                RTS

CDATAS          DW  SLT
                DW  SR
                DW  ESH
                DW  PSH
                DW  URS
                DW  ESB
                DW  PSB
                DW  WEA
                DW  WEA
                DW  EC
                DW  LR
                DW  PRO
                DW  AUT

SLT             DB  $00,$00,$00
                DB  $00,$50,$00
SR              DB  $00,$00,$10
                DB  $00,$08,$00
                DB  $00,$80,$00
                DB  $04,$00,$00
                DB  $08,$00,$00
                DB  $12,$50,$00
ESH             DB  $00,$00,$15
                DB  $00,$30,$00
                DB  $01,$50,$00
                DB  $05,$00,$00
PSH             DB  $00,$00,$15
                DB  $00,$40,$00
                DB  $02,$00,$00
URS             DB  $00,$00,$20
                DB  $00,$04,$00
                DB  $00,$20,$00
                DB  $00,$60,$00
                DB  $01,$20,$00
                DB  $02,$00,$00
                DB  $03,$50,$00
                DB  $05,$50,$00
                DB  $09,$00,$00
                DB  $13,$00,$00
                DB  $18,$00,$00
                DB  $23,$00,$00
                DB  $30,$00,$00
                DB  $38,$50,$00
                DB  $50,$00,$00
ESB             DB  $00,$00,$20
                DB  $00,$05,$00
                DB  $00,$20,$00
                DB  $01,$00,$00
                DB  $04,$00,$00
                DB  $08,$00,$00
                DB  $13,$00,$00
                DB  $21,$00,$00
PSB             DB  $00,$00,$20
                DB  $00,$05,$00
                DB  $00,$20,$00
                DB  $01,$00,$00
                DB  $02,$00,$00
                DB  $03,$00,$00
                DB  $05,$00,$00
                DB  $09,$00,$00
                DB  $14,$00,$00
                DB  $20,$00,$00
WEA             DB  $00,$00,$60
                DB  $00,$03,$00
                DB  $00,$01,$00
                DB  $00,$02,$20
                DB  $00,$90,$00
                DB  $00,$00,$00
                DB  $01,$00,$00
EC              DB  $00,$00,$50
                DB  $00,$02,$00
                DB  $00,$07,$50
                DB  $00,$20,$00
                DB  $00,$40,$00
                DB  $00,$60,$00
                DB  $01,$00,$00
                DB  $01,$75,$00
                DB  $02,$75,$00
                DB  $04,$50,$00
                DB  $06,$50,$00
                DB  $09,$00,$00
                DB  $11,$50,$00
                DB  $15,$00,$00
                DB  $19,$00,$00
                DB  $25,$00,$00
                DB  $30,$00,$00
                DB  $36,$00,$00
                DB  $42,$00,$00
                DB  $48,$00,$00
                DB  $50,$00,$00
LR              DB  $00,$00,$40
                DB  $00,$04,$00
                DB  $00,$15,$00
                DB  $00,$40,$00
                DB  $00,$80,$00
                DB  $01,$20,$00
                DB  $02,$00,$00
                DB  $03,$50,$00
                DB  $05,$50,$00
                DB  $09,$00,$00
                DB  $13,$00,$00
                DB  $18,$00,$00
                DB  $23,$00,$00
                DB  $30,$00,$00
                DB  $38,$50,$00
                DB  $50,$00,$00
PRO             DB  $00,$00,$20
                DB  $00,$00,$80
                DB  $00,$01,$20
                DB  $00,$01,$70
                DB  $00,$02,$30
                DB  $00,$02,$90
                DB  $00,$03,$70
                DB  $00,$07,$50
                DB  $00,$20,$00
                DB  $00,$40,$00
                DB  $00,$60,$00
                DB  $01,$00,$00
                DB  $01,$75,$00
                DB  $02,$75,$00
                DB  $04,$50,$00
                DB  $06,$50,$00
                DB  $09,$00,$00
                DB  $11,$50,$00
                DB  $15,$00,$00
                DB  $19,$00,$00
                DB  $25,$00,$00
AUT             DB  $00,$00,$00
                DB  $00,$50,$00

;-----------------------------------------------------------
