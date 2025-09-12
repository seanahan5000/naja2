BUY_ARMHELM     BIT UNSTROB
                LDA #$00
                STA CURSPNT
                JSR DRAW_WHITE_BOX
                LDX DISPLAY
                DEX
                LDA WANTED1
                STA ON1,X
                LDA #$00
                STA STATUS
                JSR STATUP
BBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI BIGKEY
                JSR ERASE_WHITE_BOX
                LDA #$00
                JSR WAIT_KEY
                JSR DRAW_WHITE_BOX
BIGKEY          LDA KEYBRD
                BPL BBLINK
                BIT UNSTROB
                JSR CHECK_UP
                BEQ GOBIG_UP
                JSR CHECK_DOWN
                BEQ GOBIG_DOWN
                JSR CHECK_LEFT
                BEQ BIG_LEFT
                JSR CHECK_RIGHT
                BEQ BIG_RIGHT
                JSR CHECK_ENTER
                BEQ GOBENTR
                JSR CHECK_CANCEL
                BNE BIGKEY
                JSR ERASE_STAT
                LDA #$00
                STA STATUS
                JSR ERASE_WHITE_BOX
                LDA #$07
                STA WANTED1
                JSR DRAW_SCREEN
                JMP MAIN_LOOP

GOBIG_UP        JMP BIG_UP
GOBIG_DOWN      JMP BIG_DOWN
GOBENTR         JMP BIG_ENTER

BIG_LEFT        JSR ERASE_WHITE_BOX
                LDA CURSPNT
                BNE :1
                LDA #$02
                STA CURSPNT
                LDA WANTED1
                CMP #$0E
                BNE :2
                LDA #$01
                STA CURSPNT
                BNE :2                  ; always
:1              DEC CURSPNT
:2              JSR DRAW_WHITE_BOX
                JMP BIGKEY

BIG_RIGHT       JSR ERASE_WHITE_BOX
                INC CURSPNT
                LDA WANTED1
                SEC
                SBC #$0C
                EOR #$03
                CMP CURSPNT
                BCS RBCOMN
                LDA #$00
                STA CURSPNT
RBCOMN          JSR DRAW_WHITE_BOX
                JMP BIGKEY

BIG_UP          JSR DRAW_BIG_ARROW
                LDX CURSPNT
                DEC BRNCURS,X
                LDA BRNCURS,X
                CMP MINTABL,X
                BPL BIG_COMN
                LDA #$04
                STA BRNCURS,X
                BNE BIG_COMN            ; always

BIG_DOWN        JSR DRAW_BIG_ARROW
                LDX CURSPNT
                INC BRNCURS,X
                LDA BRNCURS,X
                CMP #$05
                BCC BIG_COMN
                LDA MINTABL,X
                STA BRNCURS,X
BIG_COMN        JSR DRAW_BIG_ARROW
                JSR WILFLIP
                JSR UPDATER
                JSR DRAW_ENUSE
                JSR CREATE_ITEM
                JSR DRAW_ENUSE
                JSR STATUP
                JMP BIGKEY

GOBIGKY         JSR BLINKEM
                JMP BIGKEY

BIG_ENTER       LDA STATUS
                CMP #$02
                BCS GOBIGKY
                BIT UNSTROB
                JSR NOISE

                JSR DRAW_PICT
                PictClear 4;164;36;191
                PictTextAt 46;168;"PRESS <SPACE> TO VERIFY PURCHASE"
                PictTextAt 124;180;"C>ANCEL"
                PictEnd

CONFIRM         LDA KEYBRD
                BPL CONFIRM
                BIT UNSTROB
                JSR CHECK_ENTER
                BEQ BUY_ARMOR
                JSR CHECK_CANCEL
                BNE CONFIRM
                JSR GOSCOMN
                JMP BIGKEY

BUY_ARMOR       LDX #$9C
                LDY #$13
                JSR UPDATE_CREDIT
                LDA WHOPIC
                JSR SET_CHAR
                LDY OPEN_SLOT
                LDX #0
:1              LDA ETABLE,X
                STA (CHARDL),Y
                INY
                INX
                CPX #4
                BNE :1
                JSR NOISE
                JSR GOSCOMN
                JMP BIGKEY

BLINKEM         LDA #$02
                PHA
:1              LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI :2
                LDA STATUS
                PHA
                LDA #$00
                STA COUNT
                JSR STATUPA
                LDA #$00
                JSR WAIT_KEY
                PLA
                STA COUNT
                JSR STATUPA
                BMI :2
                PLA
                SEC
                SBC #$01
                PHA
                BNE :1
:2              PLA
                BIT UNSTROB
                RTS

WILFLIP         LDA WANTED1
                CMP #$0D
                BEQ :EXIT
                LDA BRNCURS
                CLC
                ADC CLSCURS
                AND #$01
                EOR #$01
                CLC
                ADC #$03
                CMP YNOCURS
                BEQ :EXIT
                LDA CURSPNT
                PHA
                LDA #$02
                STA CURSPNT
                JSR DRAW_BIG_ARROW
                LDA YNOCURS
                EOR #$07
                STA YNOCURS
                JSR DRAW_BIG_ARROW
                PLA
                STA CURSPNT
:EXIT           RTS

*-------------------------------

UPDATER         LDX CURSPNT
                CPX #2
                BEQ UPDOUT
                LDA WANTED1
                SEC
                SBC #$0D
                ASL
                CLC
                ADC CURSPNT
                TAY
                LDA HAOFF,Y
                PHA
                CLC
                ADC ELECT,X
                LDY WANTED1
                CPY #$0E
                BNE NOHELM1
                CLC
                ADC ELECT,X
NOHELM1         TAY
                LDA HADATA,Y
                STA TEXTBUF
                LDA HADATA+1,Y
                STA TEXTBUF+1
                LDA #TextLineEnd
                STA TEXTBUF+2
                LDA WANTED1
                CMP #$0E
                BEQ ISHELM1
                LDA #TextSpace
                STA TEXTBUF+1
ISHELM1         LDA HAX,X
                TAX
                LDY #$46
                JSR DRAW_TEXTBUF_XY
                LDX CURSPNT
                PLA
                CLC
                ADC BRNCURS,X
                LDY WANTED1
                CPY #$0E
                BNE NOHELM2
                CLC
                ADC BRNCURS,X
NOHELM2         TAY
                LDA HADATA,Y
                STA TEXTBUF
                LDA HADATA+1,Y
                STA TEXTBUF+1
                LDA WANTED1
                CMP #$0E
                BEQ ISHELM2
                LDA #TextSpace
                STA TEXTBUF+1
ISHELM2         LDA HAX,X
                TAX
                LDY #$46
                JSR DRAW_TEXTBUF_XY
                LDX CURSPNT
                LDA BRNCURS,X
                STA ELECT,X
UPDOUT          JSR :PRICE_SUB
                JSR AHPRICE
:PRICE_SUB      LDX #$9C
                LDY #$0B
                JMP DRAW_PRICE_AT

*-------------------------------

CREATE_ITEM     LDA WANTED1
                SEC
                SBC #$0D
                ASL
                ASL
                TAY
                LDX #0
:LOOP1          LDA FORMS,Y
                STA ETABLE,X
                INY
                INX
                CPX #4
                BNE :LOOP1
                LDA WANTED1
                CMP #$0E
                BEQ :SKIPA
                LDA CLSCURS         ;Create armor
                ORA ETABLE+1
                STA ETABLE+1
                LDA BRNCURS
                ASL
                BPL :SKIPB          ;Always
:SKIPA          LDA CLSCURS         ;Create helmet
                SEC
                SBC #$02
                ORA ETABLE+1
                STA ETABLE+1
                LDA BRNCURS
                SEC
                SBC #$01
:SKIPB          ASL
                ASL
                ORA ETABLE+1
                STA ETABLE+1
                LDA YNOCURS
                SEC
                SBC #$03
                AND #$01
                CLC
                ROR
                ROR
                ORA ETABLE+2
                STA ETABLE+2
                JMP ENERGY2

FORMS           DB  $44,$00,$00,$89         ; armor
                DB  $45,$00,$00,$DF         ; helmet

*-------------------------------

DRAW_ENUSE      LDA WANTED1
                CMP #$0D
                BNE :1
                LDA ENERGY_USAGE
                ORA ENERGY_USAGE+1
                ORA ENERGY_USAGE+2
                BNE :2
                JSR DRAW_PICT
                PictTextAt 182;2;"NONE"
                PictEnd
:1              RTS

:2              LDX #3
:3              LDA ENERGY_USAGE-1,X
                PHA
                DEX
                BNE :3
;               LDX #0
                LDA #3
                JSR DIGITS_R
                LDA #TextLineEnd
                STA TEXTBUF,X
                LDX #172
                LDY #2
                JMP DRAW_TEXTBUF_XY

*-------------------------------

AHPRICE         LDY WANTED1
                LDA MPLYOFF-$0D,Y
                CLC
                ADC BRNCURS
                TAX
                LDA MPLIER,X
                PHA
                LDA BRNCURS+1
                ASL
                CLC
                ADC MCNDOFF-$0D,Y
                TAX
                LDY MPLCAND,X
                LDA MPLCAND+1,X
                TAX
                PLA
                PHA
                LSR
                LSR
                LSR
                LSR
                JSR MULTIPLY_12
                PLA
                AND #%00001111
                TAX
:1              LDY #4
:2              ASL PRODUCT_3+2
                ROL PRODUCT_3+1
                ROL PRODUCT_3+0
                DEY
                BNE :2
                DEX
                BNE :1

                LDY #1
                LDA WANTED1
                CMP #$0D
                BNE :3
                LDA BRNCURS+2
                CMP #$04
                BNE :3

                LDA #$50
                LDX #<PRODUCT_3
                LDY #>PRODUCT_3
                JSR MULTIPLY_13
                LDA #$03
                LDX #<PRODUCT_4
                LDY #>PRODUCT_4
                JSR MULTIPLY_14
                LDY #0
:3              LDX #0
:4              LDA PRODUCT_5,Y
                STA THE_PRICE,X
                INY
                INX
                CPX #4
                BNE :4
                RTS

MPLYOFF         DB  $00,$04
MPLIER          DB  $11,$51,$22
                DB  $42,$72
                DB  $11,$51,$12
                DB  $32

MCNDOFF         DB  $00,$06
MPLCAND         DB  $00,$10
                DB  $00,$50
                DB  $02,$00
                DB  $04,$00
                DB  $07,$00
                DB  $00,$05
                DB  $00,$75
                DB  $03,$00

*-------------------------------

HAOFF           DB  $00,$05,$08
                DB  $0E
HAX             DB  $B8,$E2
HADATA          DB  $01,$02,$03
                DB  $04,$06
                DB  $01,$02,$04
                DB  $06,$08
                DB  $0A,$04,$0A
                DB  $08,$01,$02
                DB  $01,$06
                DB  $0A,$01,$0A
                DB  $05,$01,$00

*-------------------------------

DRAW_WHITE_BOX  LDA #OpColorWhite1
                BNE WHITE_BOX_CMN       ; always
ERASE_WHITE_BOX LDA #OpColorBlack1
WHITE_BOX_CMN   JSR SET_COLOR
                JSR DRAW_PICT
                PictSwitch CURSPNT
:0              PictCase :1
                PictRect $28;$85;$53;$8F
                PictMoveTo $29;$86
                PictLineTo $29;$8E
                PictMoveTo $52;$86
                PictLineTo $52;$8E
:1              PictCase :2
                PictRect $76;$85;$A1;$8F
                PictMoveTo $77;$86
                PictLineTo $77;$8E
                PictMoveTo $A0;$86
                PictLineTo $A0;$8E
:2              PictCase :END
                PictRect $C4;$85;$EF;$8F
                PictMoveTo $C5;$86
                PictLineTo $C5;$8E
                PictMoveTo $EE;$86
                PictLineTo $EE;$8E
:END            PictSwitchEnd
                PictEnd
                RTS

*-------------------------------

DRAW_BIG_ARROW  LDX CURSPNT
                LDY BRNCURS,X
                LDA :WYES,Y
                TAY
                LDA :EXES,X
                TAX
                JSR MOVE_TO
                LDX #<:BIG_ARROW
                LDY #>:BIG_ARROW
                JMP NEW_DRAW_SHAPE

:EXES           DB  $17,$79,$B9
:WYES           DB  $28,$3B,$4E
                DB  $61,$74

:BIG_ARROW      DB  $22,$00

                DB  %00000011
                DB  %00001111
                DB  %00111111
                DB  %01111111
                DB  %01111111
                DB  %01111111
                DB  %00111111

                DB  %00000000
                DB  %00000000
                DB  %00000000
                DB  %00000001
                DB  %00000111
                DB  %00000001
                DB  %00000000

                DB  %00001111
                DB  %00000011
                DB  %10000000

                DB  %10000000

*-------------------------------
