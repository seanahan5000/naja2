; enter showing and drawing to page 1

; TEMP            =   LOCAL_TEMP+0        ; +1

ZBLOCK_A0       =   $A0
PATIENT         =   ZBLOCK_A0+0
TREATMENT       =   ZBLOCK_A0+1
FLAGS           =   ZBLOCK_A0+2

                DUM SCRATCH_PAGE
PRICE_TABLE     DS  28
                DEND

INFIRMARY       JSR DRAW_PICT
                PictTextAt 130;26;"PLEASE \"SCAN IN\" FOR"
                PictTextAt 139;34;"IMMEDIATE MEDICAL"
                PictTextAt 163;42;"ATTENTION"
                PictEnd

                JSR BLINK_HAND
                BCS :1
                JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictShowPage
                PictSetPage1
                PictEnd
                JMP LEAVE_INFIRMARY

:1              LDA #$00
                STA PATIENT
                STA TREATMENT

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictEnd

                LDY #0
PILOOP1         STY COUNT
                TYA
                ASL
                ASL
                ASL
                JSR SET_PIC_X
                LDA PIC_TABLE,Y
                TAY
                JSR PICKER
                LDY COUNT
                INY
                CPY #5
                BNE PILOOP1

                JSR DRAW_PICT
                PictSetGreen
                PictMoveTo $01;$11
                PictLineTo $117;$11

                PictMoveTo $01;$34
                PictLineTo $117;$34

                PictMoveTo $6F;$11
                PictLineTo $6F;$34

                PictMoveTo $A7;$11
                PictLineTo $A7;$34

                PictMoveTo $37;$11
                PictLineTo $37;$34
                PictMoveTo $DF;$11
                PictLineTo $DF;$34
                PictEnd

                JSR DRAW_PICT
                PictSetGreen
                PictRect $01;115;$115;182
                PictMoveTo $01;125
                PictLineTo $115;125
                PictMoveTo 16;117
                PictText "NAME"
                PictHMoveTo 75
                PictText "PROF"
                PictHMoveTo 171
                PictText "HEALTH"
                PictHMoveTo 231
                PictText "STATUS"
                PictHMoveTo 108
                PictText "IMPLANTED"
                PictCall DRAW_GROUP
                PictEnd

TREAT_WHO       JSR DRAW_PICT
                PictClear 8;53;32;112
                PictTextAt 56;105;"WHO IS TO RECEIVE TREATMENT?"
                PictTextAt 16;184;"LEAVE"
                PictShowPage
                PictEnd

                JSR RESET_CHRLIST
                JSR EXCLUDE_GONE
                JSR PICK_PATIENT
                BCC LEAVE_INFIRMARY
                LDA CURSOR
                CMP #$07
                BNE PICK_TREATMENT
LEAVE_INFIRMARY RTS

PICK_TREATMENT  STA PATIENT
                JSR SET_CHAR
                JSR MARKIT

                LDA TREATMENT
                STA CURSOR

                JSR DRAW_PICT
                PictClear 2;184;8;191   ; erase LEAVE
                PictSetPage1
                PictClearPage
                PictSetOrange
                PictRect $3D;$3D;$D9;$5D
                PictImage ORANGE_ARROW

                PictTextAt 67;65;"TREATMENT COST:"
                PictTextAt 79;73;"YOUR CREDITS:"
                PictTextAt 118;83;"C>ANCEL"

                PictTextAt 92;97;"SELECT TREATMENT"

                PictMoveTo $A3;$49
                PictCall DRAW_GCREDITS
                PictEnd

                JSR CALC_COST
                JSR DRAW_COST

                JSR DRAW_PICT
                PictSetPage2
                PictCopyTo $08;53;$21;112
                PictEnd

                LDY CURSOR
                JSR DRAW_TREATMENT

                LDA #$00
                STA FLAGS
                JSR UPDATE_FLAGS

BBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI BKEYER

                JSR DRAW_PICT
                PictSetWhite1
                PictRect $6E;$11;$A6;$34
                PictEnd

                LDA #$00
                JSR WAIT_KEY

                JSR DRAW_PICT
                PictSetGreen
                PictMoveTo $6E;$11
                PictLineTo $A6;$11
                PictMoveTo $6E;$34
                PictLineTo $A6;$34
                PictSetBlack1
                PictMoveTo $6E;$11
                PictLineTo $6E;$34
                PictMoveTo $A6;$11
                PictLineTo $A6;$34
                PictEnd

BKEYER          LDA KEYBRD
                BPL BBLINK
                BIT UNSTROB
                JSR CHECK_RIGHT
                BEQ BLEFT1              ; NOTE: left/right swapped
                JSR CHECK_LEFT
                BEQ BRIGHT1             ; NOTE: left/right swapped
                JSR CHECK_ENTER
                BEQ BENTER1
                JSR CHECK_CANCEL
                BNE BKEYER

                LDY CURSOR
                STY TREATMENT
                JSR DRAW_TREATMENT

                LDA #$00
                JSR FDRAW
                JSR MARKIT
                JMP TREAT_WHO

BLEFT1          JSR SCROLL_LEFT
                LDY CURSOR
                JSR DRAW_TREATMENT
                JSR DRAW_COST
                INC CURSOR
                LDA CURSOR
                CMP #$07
                BCC BRIGHT2
                LDA #$00
                BEQ BRIGHT3             ; always

BRIGHT1         JSR SCROLL_RIGHT
                LDY CURSOR
                JSR DRAW_TREATMENT
                JSR DRAW_COST
                DEC CURSOR
                BPL BRIGHT2
                LDA #$06
BRIGHT3         STA CURSOR
BRIGHT2         LDY CURSOR
                JSR DRAW_TREATMENT
                JSR DRAW_COST
                JSR UPDATE_FLAGS
                JMP BKEYER

BENTER1         LDA FLAGS
                BEQ BENT2
                JSR BLINK_FLAGS
                JMP BKEYER
BENT2           LDA CURSOR
                STA TREATMENT
                BIT UNSTROB
                JSR DRAW_PICT
                PictClear 13;97;27;104
                PictTextAt 89;97;"<SPACE> TO VERIFY"
                PictEnd

BEKEY           LDA KEYBRD
                BPL BEKEY
                BIT UNSTROB
                JSR CHECK_ENTER
                BEQ TREAT
                JSR CHECK_CANCEL
                BNE BEKEY
                JSR DRAW_PICT
                PictClear 12;97;28;104
                PictTextAt 92;97;"SELECT TREATMENT"
                PictEnd
                JMP BBLINK

TREAT           JSR DRAW_PICT
                PictClear 8;53;32;104
                PictEnd
                LDX PATIENT
                INX
                STX PATIENT_MDEF+1
                JSR MARKIT
                JSR GIVE_TREATMENT
                JSR SPEND_PRICE
                LDA #$00
                JSR FDRAW
                LDY CURSOR
                JSR DRAW_TREATMENT
                JMP TREAT_WHO

;-----------------------------------------------------------
;
; On entry:
;   Y: treatment index
;
DRAW_TREATMENT  CPY #4
                BNE :1
                JSR DRAW_PICT
                PictSetTextHeight 8
                PictTextAt 119;1;" POWER\nFAILURE"
                PictEnd
                RTS
:1              TYA
                PHA
                LDX :XPNTS,Y
                LDY #5
                JSR MOVE_TO
                LDX #<:TREATMENTS
                LDY #>:TREATMENTS
                PLA
                JSR GET_IND_STRING
                JMP DRAW_TEXTBUF

:TREATMENTS     TXI "REJUVENATE"
                TXI "ILLNESS"
                TXI "DECOMPRESS"
                TXI "IMPLANTS"
                TXI "_"
                TXI "BLINDNESS"
                TXI "REPAIR"

:XPNTS          DB  110,119,110
                DB  116,119,113
                DB  122,125

;-----------------------------------------------------------

GIVE_TREATMENT  LDX PATIENT
                LDY IYPOINTS,X
                JSR VMOVE_TO

                LDA CURSOR
                ASL
                TAY
                LDA JUMPS+1,Y
                PHA
                LDA JUMPS,Y
                PHA
                RTS

JUMPS           DW  CLEAR_DAMAGE-1      ; rejuvenate
                DW  CLEAR_STATUS-1      ; illness
                DW  CLEAR_STATUS-1      ; decompress
                DW  IMPLANTER-1
                DW  POWER-1
                DW  CLEAR_STATUS-1      ; blind
                DW  CLEAR_DAMAGE-1      ; repair

IMPLANTER       JSR IMPLANTED_NO
                LDY #miscflags
                LDA (CHARDL),Y
                ORA #%10000000
                STA (CHARDL),Y
IMPLANTED_YES   JSR DRAW_PICT
                PictHMoveTo 123
                PictText "YES"
                PictEnd
                RTS

IMPLANT_SUB     LDY #miscflags
                LDA (CHARDL),Y
                BMI IMPLANTED_YES
IMPLANTED_NO    JSR DRAW_PICT
                PictHMoveTo 126
                PictText "NO"
                PictEnd
                RTS

POWER           LDY #miscflags
                LDA (CHARDL),Y
                CLC
                ADC #%00000001
                TAX
                AND #%00000011
                CMP #%00000011
                BEQ :1
                TXA
                STA (CHARDL),Y
                BNE :5                  ; always
:1              LDY #baseintellig
:2              LDA (CHARDL),Y
                SED
                SEC
                SBC #$05
                CLD
                BEQ :3
                BPL :4
:3              LDA #$01
:4              STA (CHARDL),Y
                DEY
                CPY #basestrength-1
                BNE :2
:5              JSR STATUS_SUB
                LDY #flaglimbo
                LDA (CHARDL),Y
                LDY #status
                STA (CHARDL),Y
                LDY #flaglimbo
                LDA #inlimbo
                STA (CHARDL),Y
                JSR CALC_ALL
                JMP STATUS_SUB

CLEAR_STATUS    JSR STATUS_SUB
                LDY #inflictnums
                LDA #0
                STA (CHARDL),Y
                LDY #status
                LDA #healthy
                STA (CHARDL),Y
                JSR CALC_ALL
STATUS_SUB      JSR CSTATUS_TO_TEXT_C
                LDX #222
                JMP DRAW_TEXTBUF_X

CLEAR_DAMAGE    JSR :SUB
                LDA #0
                LDY #damagelev
                STA (CHARDL),Y
                INY
                STA (CHARDL),Y
                JSR CALC_ALL
:SUB            JSR HEALTH_TO_TEXT
                LDA #TextLineEnd
                STA TEXTBUF+4
                LDX #162
                JMP DRAW_TEXTBUF_X

;-----------------------------------------------------------

DRAW_GROUP      LDY IYPOINTS+0
                JSR VMOVE_TO
                JSR FIRST_CHAR
:1              JSR CNAME_TO_TEXT
                LDX #16
                JSR DRAW_TEXTBUF_X
                JSR CPROF_TO_TEXT
                LDA #TextLineEnd
                STA TEXT_BUFFER+3
                LDX #78
                JSR DRAW_TEXTBUF_X
                LDY #profrace
                LDA (CHARDL),Y
                BMI :2
                JSR IMPLANT_SUB
:2              JSR HEALTH_TO_TEXT
                LDX #162
                JSR DRAW_TEXTBUF_X
                JSR CSTATUS_TO_TEXT_C
                LDX #222
                JSR DRAW_TEXTBUF_X
                LDY #9
                JSR VMOVE
                JSR NEXT_CHAR
                BCC :1
                RTS

;-----------------------------------------------------------

SCROLL_LEFT     JSR DRAW_PICT
                PictSetPage1
                PictClear 32;19;40;51
                PictEnd
                LDA #$20
                JSR SET_PIC_X
                LDA CURSOR
                CLC
                ADC #3
                CMP #7
                BCC :1
;               SEC
                SBC #7
:1              TAY
                JSR PICKER
                JSR SET_PAGE2

                LDX #19
:2              LDA LOBYTES,X
                STA DESTINL
                CLC
                ADC #8
                STA SCREENL
                LDA HIBYTES,X
                STA DESTINH
                STA SCREENH

                LDY #0
:3              LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY #31
                BNE :3

                LDA (SCREENL),Y
                ORA #%01000000
                STA (DESTINL),Y
                INY

                LDA DESTINL
                STA SCREENL
                LDA DESTINH
                EOR #$60
                STA SCREENH

:4              LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY #40
                BNE :4

                INX
                INX
                CPX #51
                BCC :2
                BNE :5
                LDX #20
                BNE :2                  ; always
:5              RTS

SCROLL_RIGHT    JSR DRAW_PICT
                PictSetPage1
                PictClear 0;19;8;51
                PictEnd
                LDA #$00
                JSR SET_PIC_X
                LDA CURSOR
                SEC
                SBC #3
                BCS :1
;               CLC
                ADC #7
:1              TAY
                JSR PICKER
                JSR SET_PAGE2

                LDX #19
:2              LDA LOBYTES,X
                STA SCREENL
                CLC
                ADC #8
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                STA SCREENH

                LDY #31
                LDA (SCREENL),Y
                AND #%10111111
                STA (DESTINL),Y
                DEY
:3              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :3

                LDA SCREENL
                STA DESTINL
                LDA SCREENH
                EOR #$60
                STA SCREENH

                LDY #7
                LDA (SCREENL),Y
                ORA #%01000000
                STA (DESTINL),Y
                DEY
:4              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :4

                INX
                INX
                CPX #51
                BCC :2
                BNE :5
                LDX #20
                BNE :2                  ; always
:5              RTS

;-----------------------------------------------------------

PICK_PATIENT    LDA #0
                STA LEGALS+7
                LDX #<PATIENT_MDEF
                LDY #>PATIENT_MDEF
                JSR MENU_INIT
                JSR MENU_SET_CANCEL
                JMP MENU_SELECT

PATIENT_MDEF    DB  $09
                DB  $00                 ; modified
                DW  :CURSOR

:CURSOR         LDX CURSOR
                LDY IYPOINTS,X
                LDX #$03
                JMP DRAW_ARROW

MARKIT          LDX PATIENT
                LDY IYPOINTS,X
                LDX #7
                JMP DRAW_MARKER

IYPOINTS        DB  128,137,146
                DB  155,164,173
                DB  184,184,184

;-----------------------------------------------------------

EXCLUDE_GONE    LDX #<:SUB
                LDY #>:SUB
                JMP CSCAN_COMMON

:SUB            LDX #-1
                LDY #status
                LDA (CHARDL),Y
                CMP #intracc
                BEQ :1
                CMP #lost
                BEQ :1
                INX
:1              TXA
                RTS

;-----------------------------------------------------------

CALC_COST       LDX #27
:1              LDA FLAT_FEES,X
                STA PRICE_TABLE,X
                DEX
                BPL :1

                LDY #level+1
                LDA (CHARDL),Y
                TAX
                DEY
                LDA (CHARDL),Y
                TAY
                LDA #$50            ;??? credits/level
                JSR MULTIPLY_12
                LDX #2
:2              LDA PRODUCT_3,X
                STA PRICE_TABLE+9,X
                DEX
                BPL :2

                LDY #damagelev+1
                LDA (CHARDL),Y
                TAX
                DEY
                LDA (CHARDL),Y
                TAY
                LDA #2              ;??? credits/hit
                JSR MULTIPLY_12
                LDX #2
:3              LDA PRODUCT_3,X
                STA PRICE_TABLE+1,X
                STA PRICE_TABLE+25,X
                DEX
                BPL :3
                INX

                LDY #status
                LDA (CHARDL),Y
                CMP #intracc
                BEQ :14
                CMP #lost
                BEQ :14
                CMP #compressd
                BNE :4
                STX PRICE_TABLE+8
                RTS
:4              CMP #inlimbo
                BNE :5
                STX PRICE_TABLE+16
                RTS
:5              AND #%00111111
                CMP #blind
                BNE :6
                STX PRICE_TABLE+20
:6              LDY #5
:7              CMP STATUSES,Y
                BEQ :8
                DEY
                BPL :7
                BMI :10                 ; always
:8              STX PRICE_TABLE+4
                TYA
                ASL
                ASL
                TAY
                INY
                LDX #1
:9              LDA ILL_PRICES,Y
                STA PRICE_TABLE+4,X
                INY
                INX
                CPX #4
                BNE :9
                LDX #0
:10             LDY #miscflags
                LDA (CHARDL),Y
                BMI :11
                STX PRICE_TABLE+12
:11             LDY #damagelev
                LDA (CHARDL),Y
                BNE :12
                INY
                LDA (CHARDL),Y
                BEQ :14
:12             LDY #profrace
                LDA (CHARDL),Y
                BMI :13
                STX PRICE_TABLE+0
                RTS
:13             STX PRICE_TABLE+24
:14             RTS

STATUSES        DB  illA                ; ???
                DB  illB                ; ???
                DB  illC                ; ???
                DB  illD                ; ???
                DB  poisoned            ; ???
                DB  radiated            ; ???

ILL_PRICES      HEX 00000011            ; illA
                HEX 00000022            ; illB
                HEX 00000033            ; illC
                HEX 00000044            ; illD
                HEX 00000055            ; poisoned
                HEX 00000066            ; radiated

;-----------------------------------------------------------
; Rejuvenate = hits to heal * ???
;    Illness = fees (based on cost of capsules/infusor
;               and energy use of infusor)
; Decompress = level * ???
;   Implants = flat fee
; Power Fail = flat fee ?????
;  Blindness = fee (based on energy use of sight restorer)
;     Repair = hits to heal * ???
;-----------------------------------------------------------

FLAT_FEES       HEX FF000000            ; Rejuvenate
                HEX FF000000            ; Illness
                HEX FF000000            ; Decompress
                HEX FF000222            ; * Implants
                HEX FF000333            ; * Power Failure ???
                HEX FF000444            ; * Blindness
                HEX FF000000            ; Repair

DRAW_COST       LDA CURSOR
                ASL
                ASL
                TAY
                LDX #0
:1              LDA PRICE_TABLE,Y
                STA THE_PRICE,X
                CMP #$FF
                BEQ :2
                INY
                INX
                CPX #4
                BNE :1
                LDX #$A3
                LDY #$41
                JMP DRAW_PRICE_AT
:2              RTS

;-----------------------------------------------------------

UPDATE_FLAGS    LDA #$0F
                LDX THE_PRICE
                INX
                BEQ FDRAW
                JSR TEST_SPEND
                LDA #$F0
                BCC FDRAW
                LDA #$00
FDRAW           PHA
                JSR UPDATE_LEFT_FLAG
                PLA
                PHA
                JSR UPDATE_RIGHT_FLAG
                PLA
                STA FLAGS
                RTS

BLINK_FLAGS     LDA #$02
                STA COUNT
:1              BIT KEYBRD
                BMI :2
                JSR CLEAR_FLAGS
                LDA #$00
                JSR WAIT_KEY
                JSR DRAW_FLAGS
                LDA #$00
                JSR WAIT_KEY
                DEC COUNT
                BNE :1
:2              BIT UNSTROB
                RTS

CLEAR_FLAGS     LDA FLAGS
                BPL :1
                JSR CLEAR_LEFT_FLAG
:1              LDA FLAGS
                AND #$0F
                BEQ :2
                JMP CLEAR_RIGHT_FLAG
:2              RTS

DRAW_FLAGS      LDA FLAGS
                BPL :1
                JSR DRAW_LEFT_FLAG
:1              LDA FLAGS
                AND #$0F
                BEQ :2
                JMP DRAW_RIGHT_FLAG
:2              RTS

UPDATE_LEFT_FLAG TAX
                EOR FLAGS
                BPL CLEAR_LEFT_EXIT
                TXA
                BMI DRAW_LEFT_FLAG
                ; fall through
CLEAR_LEFT_FLAG JSR DRAW_PICT
                PictClear 1;2;15;15
                PictEnd
CLEAR_LEFT_EXIT RTS

DRAW_LEFT_FLAG  JSR DRAW_PICT
                PictSetViolet
                PictMoveTo 92;2
                PictLineTo 10;2
                PictLineTo 10;14
                PictLineTo 92;14
                PictImage DIAG_LEFT
                PictTextAt 14;5;"TOO EXPENSIVE"
                PictEnd
                RTS

UPDATE_RIGHT_FLAG TAX
                EOR FLAGS
                AND #$0F
                BEQ CLEAR_RIGHT_EXIT
                TXA
                AND #$0F
                BNE DRAW_RIGHT_FLAG
                ; fall through
CLEAR_RIGHT_FLAG JSR DRAW_PICT
                PictClear 25;2;40;15
                PictEnd
CLEAR_RIGHT_EXIT RTS

DRAW_RIGHT_FLAG JSR DRAW_PICT
                PictSetViolet
                PictMoveTo 188;14
                PictLineTo 274;14
                PictLineTo 274;2
                PictLineTo 188;2
                PictImage DIAG_RIGHT
                PictTextAt 193;5;"NOT NECESSARY"
                PictEnd
                RTS

DIAG_LEFT       DB  $0D,$03,$02,$0B
                HEX 0A28208A20280A840105145014050184
                DB  $FF

DIAG_RIGHT      DB  $19,$03,$02,$0B
                HEX 8620280A282086501405018601051450
                DB  $FF

;-----------------------------------------------------------

BLINK_HAND      LDX #<HAND_WHITE
                LDY #>HAND_WHITE
                JSR :BLINK_SUB
                BMI :1
                LDX #<HAND_BLACK
                LDY #>HAND_BLACK
                JSR :BLINK_SUB
                BPL BLINK_HAND
:1              LDA KEYBRD
                BIT UNSTROB
                CMP #$9B                ; escape
                CLC
                BEQ :2
                SEC
:2              RTS

:BLINK_SUB      JSR UNPACK
                LDA #$80
                JSR WAIT_KEY
                LDA #$00
                JMP WAIT_KEY

HAND_WHITE      DB  $1E,$9E,$03,$11
                HEX 80555D997977777F7D757555552B2B3B953F7F8D3F8D5555
                HEX 15155555578D5599
                DB  $FF

HAND_BLACK      DB  $1E,$9E,$03,$11
                HEX 80554595051511110105051515552828089500A155551515
                HEX 5555515150548D558D
                DB  $FF

;-----------------------------------------------------------

PIC_TABLE       DB  $05,$06,$00
                DB  $01,$02

SET_PIC_X       STA REJUVINATE+0
                STA ILLNESS+0
                STA DECOMPRESS+0
                STA IMPLANTS+0
                STA POWERFAIL+0
                STA BLINDNESS+0
                STA REPAIR+0
                RTS

PICKER          TYA
                ASL
                TAY
                LDX PICKS+0,Y
                LDA PICKS+1,Y
                TAY
                JMP UNPACK_FILL

PICKS           DW  REJUVINATE
                DW  ILLNESS
                DW  DECOMPRESS
                DW  IMPLANTS
                DW  POWERFAIL
                DW  BLINDNESS
                DW  REPAIR

REJUVINATE      DB  $08,$13,$08,$20
                HEX 9244825482448254A092228208822282089C404092118204
                HEX 8211820482209D088902026070619D718D196179897C9538
                HEX 407C8978077F7F3FA56F737C737F993F036C6F6F5F1F1F3F
                HEX 3C3D7CA178957C9560075F6F67595E1F4F6F6F23C9078982
                HEX 0F0F1F89821F3F3FA601990495
                DB  $FF

ILLNESS         DB  $18,$13,$08,$20
                HEX C0C0828000A560008D97050BAF040B6082780C06038D060C
                HEX 0C19188D19588D59588D9707155982070C18308D180C0C06
                HEX D1C0C0C0
                DB  $FF

DECOMPRESS      DB  $20,$18,$08,$18
                HEX B0962020289120208888405082545455B154548220282A89
                HEX 820A0A2AB10A0A5555154551549704141041414589054551
                HEX 11048602829707070A229706020A22080A028C8E019198B0
                DB  $FF

IMPLANTS        DB  $10,$13,$08,$20
                HEX C08E402020505068681010486844546010505068508C8A28
                HEX 727C7F917C797B7B7F7F3F2B516D7F1F0214204089208A55
                HEX 3F7F893F7F99721747776333406948622244247886404082
                HEX 050B172E2D5E5F8D2F2F13110B0893131027214F82827C77
                HEX 6131301CB2822F2F20B8820589B8
                DB  $FF

POWERFAIL       DB  $00,$13,$08,$20
                HEX 886040844060707830A6824062776F1F3C7B777B4130783C
                HEX 1E0F061830409882010301828314183C1E0D03070F1E0FAE
                HEX 8CB078787946384038789D80009540970603501405868001
                HEX 8D82033C41019980008920282A2A20282A0A0200AD83023F
                HEX 408C50545555155589050100B9807F8C97090997080AC17F
                HEX 8CB20F8C
                DB  $FF

BLINDNESS       DB  $00,$15,$08,$18
                HEX 92060C7636760C06908000A110040055820410009D00A940
                HEX 2A00A9008D60703034363B632355633B3634307060008D82
                HEX 81207C57559D2A5599577C802082555543800E3A6A6A2A91
                HEX 552A8D6A6A3A0E804355550A2A2A2882830E818387878FEF
                HEX F6F6EF8F8787838182282A2A0A8201058904880F8D880405
                HEX 890182
                DB  $FF

REPAIR          DB  $10,$13,$08,$20
                HEX AA3E38933E88AC115589118AA8183C6646067E8C86606070
                HEX 897891708960891870604060303182406086827C7FAD5F7D
                HEX 5F5D5D827F7F2A6E2E6E27735D4646407FA56F8D77777363
                HEX 634C47430191050509847FDD7E9D0FFD
                DB  $FF

ORANGE_ARROW    DB  $11,$35,$06,$09
                HEX 8000994055008D20280A02004050140501008D00020A2820
                HEX 008D008D0105145040009D2A
                DB  $FF

;-----------------------------------------------------------
