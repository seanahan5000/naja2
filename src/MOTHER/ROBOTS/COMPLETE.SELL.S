
COMPLETE_SELL   LDA #1
                JSR PICK_A_ROBOT
                LDA THE_ROBOT
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
                BNE BADMENT
                LDA LWEAPON
                CMP #$06
                BEQ BADMENT
                LDA RWEAPON
                CMP #$06
                BNE ALLGOOD

BADMENT         JSR DRAW_PICT
                PictCall CNAME_TO_TEXT
                PictTextbufXY 57;89
                PictTextAt 57;89;" HAS EQUIPMENT THAT"
                PictTextAt 57;98;"MUST BE SOLD AT THE ARSENAL"
                PictEnd

                JSR SPACE_IN
                JSR VIEWER
                BIT UNSTROB
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB
                JSR CHECK_ENTER
                BNE :1
                JSR NOTCH_OUT
                JMP OPTIONS

ALLGOOD         LDX #$03
:1              LDA RTOTAL,X
                STA THE_PRICE,X
                DEX
                BPL :1
                LDA #$60                ; RTS
                STA NOT78
                LDA #$EE
                STA PARTALL
                JSR SEVEN8
                LDA #$EA                ; NOP
                STA NOT78
                LDX #$03
:2              LDA THE_PRICE,X
                STA RTOTAL,X
                DEX
                BPL :2
                JSR CANCEL_IN

                JSR DRAW_PICT
                PictMoveTo 44;89
                PictCall DRAW_CNAME
                PictText " IS WORTH "
                PictCall DRAW_PRICE
                PictText " CREDITS"
                PictTextAt 50;98;"PRESS <SPACE> TO SELL IT"
                PictEnd

                LDA #$EE
                STA PARTALL
                JSR OPENUP
                JSR VOMAIN
                JSR VIEWER
                LDX PICK
                LDA #$1F
                STA ON1,X
                BIT UNSTROB
:3              LDA KEYBRD
                BPL :3
                BIT UNSTROB
                JSR CHECK_ENTER
                BEQ YESSER
                JSR CHECK_CANCEL
                BNE :3
                JMP OPTIONS

YESSER          LDA PICK
                BEQ NOVIEWB

                ; JSR MOVETO1
                ; STA PRIMARY
                JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictShowPage
                PictEnd

NOVIEWB
                ; LDA #$20
                ; STA PAGE
                JSR SET_PAGE1

                LDA #$00
                STA PICK
                LDA #$FF
                STA ON2
                LDA THE_ROBOT
                JSR SET_CHAR
                LDY #disklocation
                LDA (CHARDL),Y
                PHA
                AND #$7F
                TAX
                PLA
                AND #$80
                LDY #$0F
                CMP #$80
                BEQ NOTE
                LDY #$F0
NOTE            TYA
                ; EOR OPENBUF,X
                ; STA OPENBUF,X
                LDA THE_ROBOT
                JSR SET_CHAR
                LDY #disklocation
                LDA (CHARDL),Y
                STA SCRATCH
                LDA #$00
                STA COUNT
COLOOPA         JSR SET_CHAR
                LDY #robotcyblink
                LDA (CHARDL),Y
                CMP SCRATCH
                BEQ AMATCH
                INC COUNT
                LDA COUNT
                CMP GRPNUMB
                BNE COLOOPA
AMATCH          LDA #$FF
                STA (CHARDL),Y
                LDX #<RTOTAL
                LDY #>RTOTAL
                ; JSR CHAR_EARN

                JSR RESET_CHRLIST
                LDX THE_ROBOT
                LDA #$FF
                STA LEGALS,X
                ; LDX #wMembers
                ; JSR CALL_WRITERS
                ; LDX #wOpen
                ; JSR CALL_WRITERS

                LDA THE_ROBOT
                STA COUNT
                DEC GRPNUMB
                CMP GRPNUMB
                BEQ NOTDEC
MOVIT2          LDX COUNT
                TXA
                JSR SET_CHAR
                LDA CHARDL
                STA TEMP
                LDA CHARDH
                STA TEMP+1
                INX
                TXA
                JSR SET_CHAR
                LDY #$7F
MOVEIT          LDA (CHARDL),Y
                STA (TEMP),Y
                DEY
                BPL MOVEIT
                INC COUNT
                LDA COUNT
                CMP GRPNUMB
                BNE MOVIT2
NOTDEC          JMP OPTIONS

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
