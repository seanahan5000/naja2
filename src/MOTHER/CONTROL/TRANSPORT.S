
; 0 - tesserport (green)
; 1 - infirmary  (orange)
; 2 - arsenal    (violet)
; 3 - enrollment (blue)
; 4 - arsenal2   (implicit)

; *** rename WHICHT ****
; TEMP			=	LOCAL_TEMP                     ; ,+1 TODO: clean this up

;
; On entry:
;   A: direction bits (xxxx.dddd)
;   X: step type (1=turn, 2=through-door, 3=scan-forward)
;
TRANSPORT       STA WHICHT

                ; LDA COUNTER   ; *** WHAT IS THIS FOR???
                ; BNE :1
                LDA GRPNUMB
                BNE SHOW_TRANS
                JSR UPDATE_HALL
                JSR DRAW_PICT
                PictSetBlue
                PictRect $44;$24;$D2;$42
                PictTextAt 77;39;"UNENROLLED CADETS ARE"
                PictTextAt 80;48;"NOT ALLOWED TO LEAVE"
                PictTextAt 74;57;"THE ENROLLMENT COMPLEX"
                PictEnd
                SEC
                RTS

SHOW_TRANS      JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall GET_NSEW
                PictCall DRAW_HALL
                PictImage TRANSPORT_PIC
                PictSetTextHeight 8
                PictTextAt 137;63;"T\nR\nA\nN\nS\nP\nO\nR\nT\n"
                PictShowPage
                PictEnd

PICK_DSTS       LDX #-1                 ; (hidden)
                STX LEGALS+0            ; Tesserport
                STX LEGALS+2            ; Arsenal
                INX                     ; (visible)
                STX LEGALS+1            ; Infirmary
                STX LEGALS+3            ; Enrollment
                JSR LOST_IN_GROUP
                BCS :1
                LDA #$00                ; (visible)
                STA LEGALS+2            ; Arsenal
                BEQ :2                  ; always

:1              LDA WHICHT
                BNE :3
:2              STA LEGALS+0            ; TESSERPORT
:3

SHOW_DSTS       LDX #0
:1              STX COUNT
                LDA LEGALS,X
                BNE :2
                JSR TRANS_TEXT
:2              LDX COUNT
                INX
                CPX #4
                BNE :1

FIRST_DST       LDY #0
:1              LDA LEGALS,Y
                BNE :2
                CPY WHICHT
                BNE :3
:2              INY
                CPY #4
                BNE :1                  ; always
:3              STY CURSOR

                LDY CURSOR              ;***
                JSR DRAW_TRECT
                JMP MOVKEY

BLINK           LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI GOTAKEY
                LDY CURSOR
                JSR ERASE_TRECT
                LDA #$00
                JSR WAIT_KEY
                LDY CURSOR
                JSR DRAW_TRECT
MOVKEY          LDA KEYBRD
                BPL BLINK
GOTAKEY         JSR CHECK_DOWN
                BNE NOZ
                SEC
                RTS

NOZ             BIT UNSTROB
                JSR CHECK_LEFT
                BEQ MRIGHT
                JSR CHECK_RIGHT
                BEQ MLEFT
                LDY CURSOR
                JSR CHECK_ENTER
                BNE MOVKEY
                JMP TCOMMON

MLEFT           LDY CURSOR
                JSR ERASE_TRECT
:1              LDY CURSOR
                INY
                CPY #4
                BNE :2
                LDY #0
:2              STY CURSOR
                LDA LEGALS,Y
                BNE :1
                JSR DRAW_TRECT
                JMP MOVKEY

MRIGHT          LDY CURSOR
                JSR ERASE_TRECT
:1              LDY CURSOR
                DEY
                BPL :2
                LDY #3
:2              STY CURSOR
                LDA LEGALS,Y
                BNE :1
                JSR DRAW_TRECT
                JMP MOVKEY

TCOMMON         CPY WHICHT
                BNE :2

                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall GET_NSEW
                PictCall DRAW_HALL
                PictShowPage
                PictEnd
                SEC
                RTS

:2              TYA
                PHA
                JSR SET_TRANS_DEST
                JSR TRANS_NOISE
                PLA
                CMP #$02                ; arsenal
                BNE TLEAVE
                ; LDA FLAG12
                ; CMP #$02
                ; BNE TLEAVE
                JSR RANDOM
                AND #$1F
                CMP #$13
                BNE TLEAVE
                ; JSR RESET_CHRLIST   ;Check for not full chars
                ; JSR CSCAN_PUTABLE
                ; BCC TLEAVE          ;No room
                ; JSR POOL_TO_TOTAL
                ; LDX #<MIN_PRICE     ;Check for minimum credits
                ; LDY #>MIN_PRICE
                ; CLC
                ; JSR GROUP_SPEND
                ; BCC TLEAVE          ;Not enough

                LDA #fileInfoSeller
                CMP INFO_FILE
                BEQ :3
                LDY #>INFO_SELLER
                JSR LOAD_FILE
:3              JMP INFO_SELLER

TLEAVE          SEC
                RTS

** FILL THIS IN LATER !!!
; MIN_PRICE       HEX 00000099        ;Min credits for seller to appear

;
; On entry:
;   Y: index of transport destination
;
; NOTE: also called by TESSERPORT
;
SET_TRANS_DEST  LDA DESTX,Y
                STA MAP_X
                LDA DESTY,Y
                STA MAP_Y
                LDA NSEW,Y
                STA MAP_DIR
                JSR COMPUTE_MAP_PTR
                JMP GET_NSEW

; tesserport, infirmary, arsenal, enrollment, tesback
DESTX           DB  7,1,3,0,7
DESTY           DB  4,6,11,4,0
NSEW            DB  NORTH,WEST,EAST,EAST,SOUTH

;-------------------------------
; On entry:
;   X: transport index
;
TRANS_TEXT      DEX
                BPL :1
                JSR DRAW_PICT
                PictTextAt 51;89;"TESSERPORT"
                PictEnd
                RTS

:1              DEX
                BPL :2
                JSR DRAW_PICT
                PictTextAt 169;89;"INFIRMARY"
                PictEnd
                RTS

:2              DEX
                BPL :3
                JSR DRAW_PICT
                PictTextAt 169;107;"ARSENAL"
                PictTextAt 181;115;"COMPLEX"
                PictEnd
                RTS

:3              JSR DRAW_PICT
                PictTextAt 51;107;"ENROLLMENT"
                PictTextAt 63;115;"COMPLEX"
                PictEnd
                RTS

;-------------------------------
; On entry:
;   Y: transport index
;
ERASE_TRECT     LDA #OpColorBlack1
                BPL TRECT_CMN           ; always

DRAW_TRECT      LDA TRECT_COLORS,Y
                CPY WHICHT
                BNE TRECT_CMN
                LDA #OpColorWhite1
TRECT_CMN       JSR SET_COLOR           ; Y is unchanged
                DEY
                BPL :1
                JSR DRAW_PICT           ; tesserport (green)
                PictRect $2F;$56;$71;$62
                PictEnd
                RTS

:1              DEY
                BPL :2
                JSR DRAW_PICT           ; infirmary (orange)
                PictRect $A3;$56;$E3;$62
                PictEnd
                RTS

:2              DEY
                BPL :3
                JSR DRAW_PICT           ; arsenal (violet)
                PictRect $A4;$68;$E2;$7C
                PictEnd
                RTS

:3              JSR DRAW_PICT           ; enrollment (blue)
                PictRect $2E;$68;$72;$7C
                PictEnd
                RTS

TRECT_COLORS    DB  OpColorGreen
                DB  OpColorOrange
                DB  OpColorViolet
                DB  OpColorBlue

*-------------------------------

; NOTE: assumes page 2 is visible on entry

TRANS_NOISE     LDX #$30
                LDY #$60
                JSR :SOUND

                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall DRAW_HALL
                PictShowPage
                PictEnd

                LDX #$A0
                LDY #$40
                ; fall through

:SOUND          STX TEMP                ; pitch
                STY TEMP+1              ; length
                LDY #0
:1              LDA HALL_KEYS,Y
                LDX #8
:2              LSR
                BNE :3
                STA CLICK
:3              DEX
                BNE :2
                LDX TEMP
:4              DEX
                BNE :4
                LDX TEMP
:5              DEX
                BNE :5
                INY
                DEC TEMP+1
                BNE :1
                RTS

*-------------------------------

TRANSPORT_PIC   DB  $08,$1F,$18,$8D
                HEX 8000F5404060203030182C0C267EFECA00C5404060603058
                HEX 184C144612471144A37FFECA0095404060303018280C240E
                HEX 2309230822CB087FFECA7C97031A451144FB117FFECA7F22
                HEX 08FB9B227FFECA7F4411FB9B447FFECA7FDF09107E0406B3
                HEX 0407FECA7FE70611FED89F0404501878E708007FFEC49700
                HEX 1F1038082C0E220B23099F1013E70A003F6020FBBB672060
                HEX FBAB40400C1C3636734551CF0A17970C00FBFBFBD3220923
                HEX 0B260C2C0839113366464C0A1812382268629F0423970E00
                HEX E344007E06FDFDAD7E00D71707451346164C185911332366
                HEX 450FF70900001F18FDFDAD1F002208C36248622832181A4C
                HEX 446622333119287C970B00FBFBFBCB4451643134190C4D44
                HEX 67721359084C144613A707067FE714007F01FDB97901FDA9
                HEX 000006060F091B1832686248BF1D0AE70F00FEC600000101
                HEX 0302070C091C113431645144117FE71100FEDC0089010103
                HEX 07EF1300B36060FECA971500FB93087FFECA971700FB9311
                HEX 7FFECA0F9F148042971D7DEB227FFECA0099971E7D06050C
                HEX 1914312471445104CF0B16FECA00CD972A08040C0A183228
                HEX 6248971486937FFECA00FD01010306040D08191FFECA
                DB  $FF
