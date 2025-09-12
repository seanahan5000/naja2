
COMPLETE_SELL   LDA #1
                JSR PICK_A_ROBOT
                BCS :1
                JMP OPTIONS
:1              LDA THE_ROBOT
                JSR SET_CHAR
                JSR REVERSE
                JSR TOTALUP
                JSR ADDBODS
                JSR PACSUB
                JSR ROSTAT2
                JSR NOTCH_OUT

                LDY #e2_SLOT
                LDA (CHARDL),Y
                LDY #e7_BACK1
                AND (CHARDL),Y
                CMP #$FF
                BNE CANNOT_SELL
                LDA LWEAPON
                CMP #$06                ; HAND_ATTACHMENT
                BEQ CANNOT_SELL
                LDA RWEAPON
                CMP #$06                ; HAND_ATTACHMENT
                BNE CAN_SELL

CANNOT_SELL     JSR DRAW_PICT
                PictCall CNAME_TO_TEXT
                PictTextbufXY 57;89
                PictText " HAS EQUIPMENT THAT"
                PictTextAt 57;98;"MUST BE SOLD AT THE ARSENAL"
                PictEnd
                JSR SPACE_IN
                JSR SHOW_SCREEN
                JSR ANY_KEY
                JMP OPTIONS

CAN_SELL        LDA #TradeInPercent
                LDX #<RTOTAL
                LDY #>RTOTAL
                JSR MULTIPLY_14
                LDX #3
:1              LDA PRODUCT_5,X
                STA THE_PRICE,X
                STA RTOTAL,X
                DEX
                BPL :1

                JSR CANCEL_IN
                JSR DRAW_PICT
                PictMoveTo 44;89
                PictCall DRAW_CNAME
                PictText " IS WORTH "
                PictCall DRAW_PRICE_L
                PictText " CREDITS"
                PictTextAt 50;98;"PRESS <SPACE> TO SELL IT"
                PictEnd

                LDA #$EE
                STA PARTALL
                JSR OPENUP
                JSR VOMAIN
                JSR SHOW_SCREEN
                LDX PICK
                LDA #$1F
                STA ON1,X
                BIT UNSTROB
:2              LDA KEYBRD
                BPL :2
                BIT UNSTROB
                JSR CHECK_ENTER
                BEQ YES_SELL
                JSR CHECK_CANCEL
                BNE :2
                JMP OPTIONS

YES_SELL        JSR SET_PAGE1
                LDA PICK
                BEQ :1
                JSR DRAW_PICT
                PictCopyToPage
                PictShowPage
                PictEnd
                LDA #$00
                STA PICK
:1              LDA #$FF
                STA ON2
;
; remove robot from roster
;
                LDA THE_ROBOT
                JSR SET_CHAR
                LDY #rosterLocation
                LDA (CHARDL),Y
                AND #$0F
                STA :MOD+1
                JSR CLEAR_ROSTER_LOC
;
; clear robot link in cybernate
;
                JSR FIRST_CHAR
:2              LDY #roboCyberLink
                LDA (CHARDL),Y
:MOD            EOR #$FF
                AND #$0F
                BNE :3
                LDA #$00
                STA (CHARDL),Y
                BNE :4
:3              JSR NEXT_CHAR
                BCC :2
:4
;
; give group money for robot
;
                LDX #<RTOTAL
                LDY #>RTOTAL
                JSR GROUP_EARN
;
; flush group and roster state to disk
;
                JSR SAVE_GAME
;
; remove robot from group
;
REMOVE_BOT      LDX THE_ROBOT
                DEC GROUP_SIZE
                BPL :3                  ; always
:1              TXA
                JSR SET_CHAR
                LDA CHARDL
                STA TEMP
                LDA CHARDH
                STA TEMP+1
                INX
                TXA
                JSR SET_CHAR
                LDY #$7F
:2              LDA (CHARDL),Y
                STA (TEMP),Y
                DEY
                BPL :2
:3              CPX GROUP_SIZE
                BNE :1
                JMP OPTIONS

ADDBODS         LDA #$00
                LDX #$03
:1              STA RTOTAL,X
                DEX
                BPL :1
                LDY #$1B
:2              LDX #$03
                CLC
:3              LDA BODTOT,Y
                SED
                ADC RTOTAL,X
                CLD
                STA RTOTAL,X
                DEY
                DEX
                BPL :3
                TYA
                BPL :2
                RTS
