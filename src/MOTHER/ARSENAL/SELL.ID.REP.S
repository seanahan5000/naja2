SELL_ID_REP     LDX #$0A
                LDA #$FF
:1              STA VISIBLE,X
                DEX
                BPL :1

                JSR DRAW_PICT
                PictClear 0;69;40;192
                PictEnd

                LDA WHOPIC
                JSR SET_CHAR
                LDY #profrace
                LDA (CHARDL),Y
                BMI IROBOT
                AND #%00001111
                CMP #deneb
                BEQ ISDENEB

                JSR DRAW_PICT
                PictTextAt 8;89;" L:"
                PictTextAt 8;97;" R:"
                PictEnd
                LDA #105
                BNE RDNCOMN             ; always

ISDENEB         JSR DRAW_PICT
                PictTextAt 8;89;"UL:"
                PictTextAt 8;97;"UR:"
                PictTextAt 8;105;"LL:"
                PictTextAt 8;113;"LR:"
                PictEnd
                LDA #121
                BNE RDNCOMN             ; always

IROBOT          JSR DRAW_PICT
                PictTextAt 8;89;" L:"
                PictTextAt 8;97;"  :"
                PictTextAt 8;105;" R:"
                PictTextAt 8;113;"  :"
                PictEnd
                LDA #121
RDNCOMN         STA LINECNT

                LDA #$00
                STA VISIBLE
                STA VISIBLE+1
                LDX LINECNT
                CPX #105
                BEQ ONLY2
                STA VISIBLE+2
                STA VISIBLE+3
ONLY2           LDX #$03
BACLOOP         LDA BACLETS,X
                STA TEXTBUF,X
                DEX
                BPL BACLOOP
HELOOP1         LDX #$08
                LDY LINECNT
                JSR DRAW_TEXTBUF_XY
                LDA TEXTBUF+1
                CLC
                ADC #$03
                TAX
                LDA #$00
                STA VISIBLE,X
                LDA LINECNT
                CLC
                ADC #$08
                STA LINECNT
                LDA TEXTBUF+1
                INC TEXTBUF+1
                LDY #back
                CMP (CHARDL),Y
                BNE HELOOP1
                LDA #$00
                STA VISIBLE+10
                LDA #$59
                STA LINECNT
                LDX #$00
HELOOP3         LDA VISIBLE,X
                BNE VISKIP1
                LDA LINECNT
                STA LINTABL,X
                CLC
                ADC #$08
                STA LINECNT
VISKIP1         INX
                CPX #$0B
                BNE HELOOP3

                LDA LINTABL+10
                CLC
                ADC #2
                STA LINTABL+10
                ; STA LEAVMOD
                ADC #10
                STA :MOD2+1

                JSR DRAW_PICT
                PictSetOrange
                PictMoveTo $03;$4B
                PictLineTo $B9;$4B
:MOD2           PictVLineTo $FF
                PictHLineTo $03
                PictVLineTo $4B
                PictTextAt 56;79;"EQUIPMENT"
                PictEnd

                JSR DRAW_PICK_ITEM

; TEXT26          PictTextAt 56;79;"EQUIPMENT"
; LEAVMOD         =   *+2
;                 PictTextAt 35;171;"LEAVE"

                LDA #$00
                STA ON1
                STA ON1+1

                LDY #$34
                LDX SOURCE
                DEX
                BEQ :SKIPA
                DEY
:SKIPA          ; JSR TEXTER

; TEXT33          PictTextAt 144;79;"COST"

; TEXT34          PictTextAt 141;79;"VALUE"

                JSR ISHERE
                JSR MARKIT
                LDY SOURCE
                LDA MASKTAB-1,Y
                STA MASK
                LDA LEGLTAB-1,Y
                STA THELEGL
                LDA FACTABL-1,Y
                STA FACTOR
                JSR LEGLSUB
                LDA #$00
                STA BOX_PRESENT
                JMP ZDOWN2

MASKTAB         DB  $C0,$40,$C0
LEGLTAB         DB  $40,$00,$C0
FACTABL         DB  $88,$25,$13     ;SIR
BACLETS         TXT "B1:"

;-----------------------------------------------------------

DRAW_PICK_ITEM  LDA #OpColorBlue
                BNE PICK_ITEM_CMN       ; always
ERASE_PICK_ITEM LDA #OpColorBlack1
PICK_ITEM_CMN   JSR SET_COLOR
                JSR DRAW_PICT
                PictRect $C4;$4B;$114;$6B
                PictEnd

                LDX SOURCE
                DEX
                BNE :1
                JSR DRAW_PICT
                PictTextAt 219;79;"SELECT"
                PictTextAt 210;88;"EQUIPMENT"
                PictTextAt 207;97;"TO BE SOLD"
                PictEnd
                RTS

:1              JSR DRAW_PICT
                PictTextAt 204;79;"SELECT ITEM"
                PictTextAt 222;88;"TO BE"
                PictEnd

                LDA SOURCE
                CMP #2
                BNE :2
                JSR DRAW_PICT
                PictTextAt 207;97;"IDENTIFIED"
                PictEnd
                RTS

:2              JSR DRAW_PICT
                PictTextAt 213;97;"REPAIRED"
                PictEnd
                RTS

;-----------------------------------------------------------

DRAW_CONFIRM    LDA #OpColorGreen
                BNE CONFIRM_CMN         ; always
ERASE_CONFIRM   LDA #OpColorBlack1
CONFIRM_CMN     JSR SET_COLOR
                JSR DRAW_PICT
                PictRect 193;75;277;115
                PictTextAt 197;78;"PRESS <SPACE>"
                PictTextAt 206;86;"TO CONFIRM"
                PictTextAt 215;106;"C>ANCEL"
                PictSwitch SOURCE
:0              PictCase :1
:1              PictCase :2
                PictTextAt 212;95;">>SALE<<"
:2              PictCase :3
                PictTextAt 200;95;">>IDENTIFY<<"
:3              PictCase :END
                PictTextAt 206;95;">>REPAIR<<"
:END            PictSwitchEnd
                PictEnd
                RTS

;-----------------------------------------------------------

LEGLSUB         LDA WHOPIC
                JSR SET_CHAR
                LDX #$0A
LELOOP1         LDA VISIBLE,X
                STA LEGALS,X
                DEX
                BPL LELOOP1
                LDA #$00
                STA COUNT
                LDY #e3_UPLFT
                STY APOINTER
LELOOP2         LDX COUNT
                LDA LEGALS,X
                BEQ LELS2
                JMP LELSKIP
LELS2           LDA (CHARDL),Y
                CMP #$FF
                BEQ NOOK1
                AND MASK
                CMP THELEGL
                BNE NOOK2
                JSR OKAYSUB
                LDA COUNT
                PHA
                JSR CALC_VALUE
                PLA
                STA COUNT
                LDY APOINTER
                BPL LESKIPA         ;Always
NOOK2           LDA #$FE
NOOK1           LDX COUNT
                STA LEGALS,X
                BPL OKAY            ;Always
LESKIPA         LDY #profrace
                LDA (CHARDL),Y
                BPL OKAY
                LDY APOINTER
                CPY #e3_UPLFT
                BEQ ISAOF2
                CPY #e5_LWLFT
                BNE OKAY
ISAOF2          LDA (CHARDL),Y
                AND #$1F
                CMP #$19
                BNE OKAY
                INY
                INY
                INY
                INY
                LDA (CHARDL),Y
                CMP #$FF
                BEQ OKAY
                LDY APOINTER
                LDA #$FF
                BNE NOOK1           ;Always
OKAY            LDY APOINTER
                JSR OKAYSUB
                JSR ETABLE_TO_TEXT
                LDX COUNT
                LDY LINTABL,X
                LDX #$23
HALT1           JSR DRAW_TEXTBUF_XY
                LDX COUNT
                LDA LEGALS,X
                CMP #$FF
                BEQ NOVALUR
                CMP #$FE
                BNE BCCAN
                JSR STAT_WORD
                JMP NOVALUR

BCCAN           LDX COUNT
                LDY LINTABL,X
                LDX #122
HALT2           JSR DRAW_PRICE_AT
NOVALUR         LDY APOINTER
LELSKIP         LDA COUNT
                INC COUNT
                CMP #$09
                BEQ LELOUT
                LDY APOINTER
                INY
                INY
                INY
                INY
                STY APOINTER
                JMP LELOOP2
LELOUT          LDA #$0A
                STA CURSOR
                RTS

;-----------------------------------------------------------

STAT_WORD       LDX COUNT
                LDY LINTABL,X
                LDX #138
                JSR MOVE_TO
                LDY #0
                BIT ETABLE
                BVC :SKIPA
                PHP
                INY
                PLP
                BMI :SKIPA
                INY
:SKIPA          CPY #2
                BNE :2
                LDA SOURCE
                CMP #$03
                BNE :2
                LDY #3
:2              TYA
                LDX #<STAT_WORDS
                LDY #>STAT_WORDS
                JSR GET_IND_STRING
HALT3           JSR DRAW_TEXTBUF        ; must be JSR for mod
                RTS

STAT_WORDS      TXI "??????"
                TXI "BROKEN"
                TXI " KNOWN"
                TXI " OKAY"

;-----------------------------------------------------------

OKAYSUB         LDX #$00
:1              LDA (CHARDL),Y
                STA ETABLE,X
                INY
                INX
                CPX #$04
                BNE :1
                RTS

*-------------------------------

ZBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI ZKEYGOT
                JSR ZCURSIT
                LDA #$00
                JSR WAIT_KEY
                JSR ZCURSIT
ZGETKEY         LDA KEYBRD
                BPL ZBLINK
ZKEYGOT         BIT UNSTROB
                JSR CHECK_UP
                BEQ ZUP1
                JSR CHECK_DOWN
                BEQ ZDOWN1
                JSR CHECK_ENTER
                BEQ ZENTER
                CMP #$9B
                BNE ZGETKEY
                JMP ARSOUT
ZUP1            JSR ZCURSIT
ZUP2            DEC CURSOR
                BPL ZUP3
                LDA #$0A
                STA CURSOR
ZUP3            LDY CURSOR
                LDA LEGALS,Y
                BNE ZUP2
                JSR ZCURSIT
                JSR UPDATE_BOX
                JMP ZGETKEY
ZDOWN1          JSR ZCURSIT
ZDOWN2          INC CURSOR
                LDA CURSOR
                CMP #$0B
                BNE ZDOWN3
                LDA #$00
                STA CURSOR
ZDOWN3          TAY
                LDA LEGALS,Y
                BNE ZDOWN2
                JSR ZCURSIT
                JSR UPDATE_BOX
                JMP ZGETKEY
ZENTER          LDA CURSOR
                CMP #$0A
                BNE NOZLEAV
                JSR ZCURSIT
ZLEAVE          JSR MARKIT

;                 LDY DISPLAY
;                 DEY
;                 BNE :SKIPA
;                 JSR MOVETO2
;                 JMP :SKIPB
; :SKIPA          JSR MOVETO1
; :SKIPB
                LDA #$01
                STA WANTED1
                JSR DRAW_SCREEN
                JMP MAIN_LOOP

NOZLEAV         LDA #$01
                STA COUNT
:LOOP1          LDY BOX_PRESENT
                BEQ :SKIPA
                ; JSR TEXTER
                LDA #$00
                JSR WAIT_KEY
                LDY BOX_PRESENT
                ; JSR TEXTER
                LDA #$00
                JSR WAIT_KEY
                BMI :SKIPB
                DEC COUNT
                BPL :LOOP1
:SKIPB          JMP ZGETKEY
:SKIPA          JSR NOISE
                JSR ERASE_PICK_ITEM
                BIT UNSTROB
                JSR DRAW_CONFIRM
:KEYLOOP        LDA KEYBRD
                BPL :KEYLOOP
                BIT UNSTROB
                JSR CHECK_ENTER
                BEQ :SKIPC
                CMP #"C"
                BNE :KEYLOOP
                JSR ERASE_CONFIRM
                JSR DRAW_PICK_ITEM
                JMP ZGETKEY
:SKIPC          LDA WHOPIC
                JSR SET_CHAR
                JSR ZCURSIT
                LDY CURSOR
                LDA CORESP,Y
                PHA
                TAY
                JSR OKAYSUB
                JSR CALC_VALUE
                LDA SOURCE
                CMP #$01
                BNE :SKIPE
                JMP ASELLER
:SKIPE          JSR TAKE_PRICE
                LDA WHOPIC
                JSR SET_CHAR
                LDA SOURCE
                CMP #$03
                BEQ :SKIPD
                JSR EDRASUB
:SKIPD          JSR PDRASUB
                PLA
                TAY
                LDA SOURCE
                CMP #$02
                BNE RPART
                LDA (CHARDL),Y
                ORA #eq_identified
                BNE IRCOMN          ;Always
RPART           LDA (CHARDL),Y
                AND #$7F
IRCOMN          STA (CHARDL),Y
                STA ETABLE
                LDA SOURCE
                CMP #$03
                BEQ :SKIPA
                JSR EDRASUB
:SKIPA          JSR STAT_WORD
                JSR NOISE
                JMP ZESKIP2

*-------------------------------

UPDATE_BOX      LDX CURSOR
                LDY #$00
                CPX #$0A
                BEQ :SKIPB
                LDY CORESP,X
                JSR OKAYSUB
                JSR CALC_VALUE
                LDX SOURCE
                DEX
                BEQ :SKIPA
                LDX #$03
                SEC
:LOOP1          LDA TOTAL_CREDITS,X
                SED
                SBC THE_PRICE,X
                STA REMAINS,X
                CLD
                DEX
                BPL :LOOP1
                LDY #$00
                BCS :SKIPB
                LDY #$35
                BNE :SKIPB          ;Always
:SKIPA          LDX #$03
                LDA #$00
:LOOP2          ORA REMAINS,X
                DEX
                BPL :LOOP2
                LDY #$00
                TAX
                BNE :SKIPB
                LDY #$36
:SKIPB          CPY BOX_PRESENT
                BEQ :EXIT
                LDA BOX_PRESENT
                BNE :SKIPC
                ; LDA #RED
                ; STA COLOR
                STY BOX_PRESENT
                ; JSR TEXTER

                ; LDY #$11
                ; JMP LINER
                RTS

; TEXT35          PictTextAt 228;118;"TOO"
;                 PictTextAt 210;126;"EXPENSIVE"

; TEXT36          PictTextAt 207;118;"UNSELLABLE"
;                 PictTextAt 225;126;"ITEM"

; RED_BOX         LINEAT  199;114
;                 LINEAT  199;136
;                 LINEAT  273;136
;                 LINEAT  273;114
;                 DB  $FE
;                 LINEAT  201;136
;                 LINEAT  201;114
;                 LINEAT  271;114
;                 LINEAT  271;136
;                 DB  $FF

:SKIPC          STY BOX_PRESENT
                CPY #$00
                BNE :SKIPD
                TAY
                ; JSR TEXTER
                ; LDA #BLACK1
                STA COLOR
                ; LDY #$11
                ; JMP LINER
                RTS
:SKIPD          TAY
                ; JSR TEXTER
                LDY BOX_PRESENT
                ; JMP TEXTER
:EXIT           RTS

*-------------------------------

BOX_PRESENT     DB  $00

CORESP          DB  $3D,$41,$45
                DB  $49,$4D,$51
                DB  $55,$59,$5D
                DB  $61

*-------------------------------

EDRASUB         JSR ETABLE_TO_TEXT
                LDX CURSOR
                LDY LINTABL,X
                LDX #35
                JMP DRAW_TEXTBUF_XY

PDRASUB         LDX #122
                LDY YCOORD
                JMP DRAW_PRICE_AT

*-------------------------------

ZCURSIT         LDX CURSOR
                LDY LINTABL,X
                LDX #27
                JSR DRAW_TRIANGLE
                LDA CURSOR
                CMP #$0A
                BEQ :1
                LDX #174
                JSR HMOVE_TO
                JMP DRAW_BACK_ARROW
:1              RTS

*-------------------------------
