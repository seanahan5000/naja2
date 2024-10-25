
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

;*** TEST THIS ***
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

;*** redraw problems? ***

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
:1              LDY #roboCyberLink
                LDA (CHARDL),Y
:MOD            EOR #$FF
                AND #$0F
                BNE :2
                LDA #$00
                STA (CHARDL),Y
                ; LDA #-1
                ; STA DIRTY_CHARS,X
                BNE :3
:2              JSR NEXT_CHAR
                BCC :1
:3
;
; give group money for robot
;
                LDX #<RTOTAL
                LDY #>RTOTAL
                JSR GROUP_EARN
;
; flush group and roster state to disk
;
                ; JSR SAVE_GAMESTATE_MS
                ; JSR SAVE_MEMBERS
;
; remove robot from group
;
; TODO: use shared code from DELETE.S?
;
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
NOTDEC
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
