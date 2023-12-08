STATUP          JSR GET_STAT
STATUPA         LDA COUNT
                CMP STATUS
                BEQ :1
                JSR ERASE_STAT
                LDA COUNT
                STA STATUS
                JMP DRAW_STAT
:1              RTS

DRAW_STAT       LDA #OpColorOrange
                BNE STAT_CMN            ; always
ERASE_STAT      LDA #OpColorBlack1
STAT_CMN        JSR SET_COLOR
                LDA STATUS
                BEQ SAME1
                JSR DRAW_PICT
                PictMoveTo $B1;$B9
                PictLineTo $F9;$B9
                PictMoveTo $B9;$BB
                PictLineTo $F1;$BB
                PictSwitch STATUS
:0              PictCase :1
:1              PictCase :2
                PictTextAt 177;169;"INCOMPATIBLE"
                PictTextAt 183;177;"PROFESSION"
:2              PictCase :3
                PictTextAt 204;169;"TOO"
                PictTextAt 186;177;"EXPENSIVE"
:3              PictCase :4
                PictTextAt 195;169;"OUT OF"
                PictTextAt 198;177;"STOCK"
:4              PictCase :END
                PictTextAt 192;169;"FULL OF"
                PictTextAt 186;177;"EQUIPMENT"
:END            PictSwitchEnd
                PictEnd
SAME1           RTS

GET_STAT        LDA WHOPIC
                JSR SET_CHAR
                JSR RESET_EQLIST
                JSR ESCAN_PUTABLE
                LDA #$FF            ;IS THIS NEEDED ??
                STA OPEN_SLOT       ;IS THIS NEEDED ??
                LDA #4              ;(4) Full of equipment
                STA COUNT
                BCC SAME1           ;Just an RTS
                STY OPEN_SLOT
                DEC COUNT           ;(3) Out of stock
                LDA WANTED1
                CMP #$0D
                BEQ :SKIPA
                CMP #$0E
                BEQ :SKIPA

                JSR OFF_CALC
                LDA STOCK_PTRS,X
                STA TEMP
                LDA STOCK_PTRS+1,X
                STA TEMP+1
                LDA (TEMP),Y
                BEQ :EXIT

                LDA PRICOFF,X
                STA TEMP
                LDA PRICOFF+1,X
                TAX
                INY
                TYA
                STA TEMP+1
                ASL
                CLC
                ADC TEMP+1
                TAY
                DEY
                STX TEMP+1

                LDX #2
:LOOP1          LDA (TEMP),Y
                STA THE_PRICE+1,X
                DEY
                DEX
                BPL :LOOP1
                LDA #0
                STA THE_PRICE

                JSR OFF_CALC
                LDA CODEOFF,X
                STA TEMP
                LDA CODEOFF+1,X
                STA TEMP+1
                INY
                TYA
                ASL
                ASL
                TAY
                DEY
                LDA (TEMP),Y
                JMP :SKIPB

:SKIPA          LDA WANTED1
                SEC
                SBC #$0D
                ASL
                ASL
                TAY
                LDA FORMS+3,Y

:SKIPB          STA TEMP
                DEC COUNT           ;(2) Too expensive

                SED
                LDX #3
                SEC
:LOOP2          LDA GROUP_CREDITS,X
                SBC THE_PRICE,X
                STA REMAINS,X
                DEX
                BPL :LOOP2
                CLD
                BCC :EXIT

                DEC COUNT           ;(1) Incompatible profession
                LDY #profrace
                LDA (CHARDL),Y
                LSR
                LSR
                LSR
                LSR
                TAX
                LDA TEMP
                AND PROUSAB,X
                BEQ :EXIT

                DEC COUNT           ;(0) <no message>
:EXIT           RTS

OFF_CALC        LDA LINECNT
                ASL
                TAY
                LDA CURTABL,Y
                TAX
                INY
                LDA CURTABL,Y
                TAY
                RTS
