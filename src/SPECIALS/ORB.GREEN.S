
; TODO: needs much better floating physics

ORB_LINE        =   $C0
LOCATION        =   $C1
INPUT_MODE      =   $C2                 ; 0 - turn, 1 - turn and space

ORB_PEDESTAL    JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall GET_NSEW
                PictCall DRAW_HALL
                PictImage ORB_BASE
                PictEnd

                LDA ORBS_FOUND
                AND #%00000001
                BEQ :ORB_HERE

                JSR DRAW_PICT
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd
                JMP KEYWAIT

:ORB_HERE       LDA #$76
                STA ORB_LINE
                JSR DRAW_ORB

                JSR DRAW_PICT
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictSetPage2
                PictClearPage
                PictSetGreen
                PictRect $01;$1C;$A7;$38
                PictTextAt 10;31;(YOU'VE_DISCOVERED_ONE_OF)
                PictTextAt 10;39;(THE_LOST_ORB_DOOR_KEYS!)
                PictTextAt 10;47;(PRESS_<SPACE>_TO_TAKE_IT.)
                PictSwap $00;$1B;$18;$3A
                PictSetPage1
                PictEnd

                ; find character and location for orb
;               JSR LOCATE
                LDA #$02                ;***
                ; LDA #$80              ;***
                STA LOCATION

                LDA #1
                STA INPUT_MODE          ; allow space and turn
                JSR ANIMATE_ORB

                LDA LOCATION
                BMI NOROOM
                LSR
                LSR
                LSR
                LSR
                JSR SET_CHAR
                LDA LOCATION
                AND #$0F
                TAX
                LDY CORESPS,X
                LDX #0
:GIVE_ORB       LDA GREEN_ORB_ITEM,X
                STA (CHARDL),Y
                INY
                INX
                CPX #4
                BNE :GIVE_ORB

                LDA ORBS_FOUND
                ORA #%00000001
                STA ORBS_FOUND

                JSR ERASE_ORB

                JSR DRAW_PICT
                PictClear $01;$1D;$17;$38
                PictMoveTo $0A;$27
                PictCall DRAW_TRIMMED_NAME
                PictText (_TAKES_THE_ORB.)
                PictEnd

                LDX #$05
WAITER          LDA #$00
                JSR WAIT_KEY
                DEX
                BPL WAITER

                JSR DRAW_PICT
                PictSwap $00;$1B;$18;$3A
                PictEnd

KEYWAIT         LDA KEYBRD
                BPL KEYWAIT
                JSR CHECK_TURN
                BEQ :1
                BIT UNSTROB
                JMP KEYWAIT
:1              SEC
                RTS                     ; back to halls

NOROOM          JSR DRAW_PICT
                PictClear $01;$1D;$17;$38
                PictTextAt 10;31;(NO_ONE_IN_THE_GROUP_CAN)
                PictTextAt 10;39;(CARRY_ANYTHING_ELSE.__YOU)
                PictTextAt 10;47;(MUST_DROP_SOMETHING_FIRST.)
                PictEnd

                LDA #0
                STA INPUT_MODE          ; allow just turn
                JSR ANIMATE_ORB
                SEC
                RTS                     ; back to halls

ANIMATE_ORB     LDA ORB_LINE
                CMP #$54
                BEQ :DOWN
                DEC ORB_LINE
                JSR DRAW_ORB
                JSR SPACER
                BIT UNSTROB
                LDA #$A0
                JSR WAIT
                JMP ANIMATE_ORB
:DOWN           LDA ORB_LINE
                CMP #$76
                BEQ ANIMATE_ORB
                INC ORB_LINE
                JSR DRAW_ORB
                JSR SPACER
                LDA #$A0
                JSR WAIT
                JMP :DOWN

SPACER          LDA KEYBRD
                BPL :EXIT
                JSR CHECK_TURN
                BEQ :TURN_AWAY
                BIT UNSTROB
                LDX INPUT_MODE
                BEQ :EXIT
                CMP #" "
                BEQ :SPACE
                BNE :EXIT               ; always
:TURN_AWAY      PLA
                PLA
:SPACE          PLA
                PLA
                SEC
:EXIT           RTS

GREEN_ORB_ITEM  DB  $43,$02,$00,$DF

DRAW_ORB        LDA ORB_LINE
                STA LINENUM
                LDA #$11
                STA COUNT
                LDX #$00
DRLOOP1         LDY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                CPY #$74
                BNE NORMAL
                JSR DRAW2
                JMP DRSKIP

NORMAL          LDY #$12
DRLOOP2         LDA ORBDATA,X
                STA (SCREENL),Y
                INX
                INY
                CPY #$16
                BNE DRLOOP2
DRSKIP          INC LINENUM
                DEC COUNT
                BNE DRLOOP1
                RTS

DRAW2           LDY ORB_LINE
                LDA ODOFFS-100,Y
                STA SCRATCH
                LDA #$12
                STA COUNTER
:LOOP1          LDY SCRATCH
                LDA ORBDATA,X
                ORA ODATA2,Y
                LDY COUNTER
                STA (SCREENL),Y
                INX
                INC SCRATCH
                INC COUNTER
                LDA COUNTER
                CMP #$16
                BNE :LOOP1
                RTS

ERASE_ORB       LDX ORB_LINE
                LDA #$11
                STA COUNTER
:1              JSR SET_SOURCE_LINE
                LDY #$12
                LDA #$00
                CPX #$74
                BNE :2
                LDA #$7F
:2              STA (SCREENL),Y
                INY
                CPY #$16
                BNE :2
                INX
                DEC COUNTER
                BNE :1
                RTS

ORBDATA         DB  $00,$00,$00,$00
                DB  $00,$50,$0A,$00
                DB  $00,$54,$2A,$00
                DB  $00,$55,$2E,$01
                DB  $00,$55,$3E,$01
                DB  $20,$55,$3A,$05
                DB  $20,$55,$2A,$05
                DB  $20,$55,$2A,$05
                DB  $20,$55,$2A,$05
                DB  $20,$55,$2A,$05
                DB  $20,$55,$2A,$05
                DB  $20,$55,$2A,$05
                DB  $00,$55,$2A,$01
                DB  $00,$55,$2A,$01
                DB  $00,$54,$2A,$00
                DB  $00,$50,$0A,$00
                DB  $00,$00,$00,$00

ODOFFS          DB  $00,$04,$08
                DB  $0C,$0C,$10
                DB  $10,$10,$10
                DB  $10,$10,$10
                DB  $0C,$0C,$08
                DB  $04,$00

ODATA2          DB  $7F,$7F,$7F,$7F
                DB  $7F,$07,$60,$7F
                DB  $7F,$01,$00,$7F
                DB  $3F,$00,$00,$7C
                DB  $0F,$00,$00,$70
                DB  $7F,$7F,$7F,$7F

ORB_BASE        DB  $10,$87,$08,$30
                HEX CE707E7F7F7E784084C44060707C7F991F60828270826040
                HEX A96095708D78897B7C7C7E7E7F8D3F3F5F5F6F777B7C7F7F
                HEX 407F89827B77BD7B9D7D917E897FA97F89825E6EBD5E9D3E
                HEX 917EB5010F010603A907950F8D1F895F3F3F7F897E897D7D
                HEX 7B7B776F5F3F7F7F03C20103070F3F7F957E790782CC0197
                HEX 0C243F0F0184
                DB  $FF
