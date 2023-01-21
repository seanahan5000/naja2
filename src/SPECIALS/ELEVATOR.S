*------------------------------*
*                              *
*         ELEVATOR 1-5         *
*                              *
*     Written:  2/15/1987      *
*   Rewritten: 10/18/2022      *
*                              *
*------------------------------*

                EXP OFF
                PUT /NAJA/VARS/CONSTANTS

CrossHeight     =   37
ScrollDY        =   5
FinalDY         =   4                   ; (192 + CrossHeight) % ScrollDY
FinalCopyCount  =   2                   ; CrossHeight % ScrollDY

CROSSL          =   $C0
CROSSH          =   $C1
CROSS_COUNT     =   $C2
ON_LINE         =   $C3
OFF_LINE        =   $C4
COPY_COUNT      =   $C5

ELEVATOR_CMN    STA FLAG_345
                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall GET_NSEW
                PictCall DRAW_HALL
                PictSetBlack1
                PictMoveTo $45;$66
                PictLineTo $D2;$66
                PictSetWhite1
                PictRect $4F;$41;$C7;$89
                PictMoveTo $50;$41
                PictLineTo $50;$89
                PictMoveTo $C8;$41
                PictLineTo $C8;$89
                PictImage PANEL
                PictTextAt 140;80;(PRESS)
                PictTextAt 122;88;(SHELL-NUMBER)
                PictEnd

; NOTE: This is a duplicate of the code in LOAD.ELEVATOR.S
;   because it cannot be called back to from here.  The address
;   may differ between CONTROL17 to CONTROL9, for example.

                LDX #<DIAG_DATA_CLOSE
                LDY #>DIAG_DATA_CLOSE
                STX XYDATAL
                STY XYDATAH
                LDX #<DIAGS_CLOSE
                LDY #>DIAGS_CLOSE
                JSR DRAW_SEGMENTS

                LDA FLAG_345
                BNE :1
                JSR DRAW_PICT
                PictImage BUTTONS_123
                PictEnd
                JMP :2
:1              JSR DRAW_PICT
                PictImage BUTTONS_345
                PictEnd
:2              JSR DRAW_PICT
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                ; build cross section buffer
                PictSetPage2
                PictClear 0;0;40;CrossHeight
                PictImage CROSS_SECTION
                PictCall COPY_CROSS
                PictSetPage1
                PictEnd

:KEY_LOOP       LDA KEYBRD
                BPL :KEY_LOOP
                JSR CHECK_TURN
                BNE :4
                SEC
                RTS

:4              BIT UNSTROB
                SEC
                SBC #"0"
                BEQ :KEY_LOOP           ; shell 0 illegal
                CMP #$06
                BCS :KEY_LOOP           ; shell >5 illegal
                CMP SHELL
                BEQ :KEY_LOOP           ; same shell illegal
                LDX FLAG_345
                BNE :5
                CMP #$04
                BCS :KEY_LOOP
                BCC :6                  ; always
:5              CMP #$03
                BCC :KEY_LOOP
:6              STA DEST_SHELL
                JSR LOAD_SHELL

                BIT UNSTROB
                LDA DEST_SHELL
                TAX
                SEC
                SBC SHELL
                STX SHELL
                TAX
                BMI UPPER

DOWNER          DEX
                BEQ :1
                BIT UNSTROB
                ; DEC XPOS
                ; DEC YPOS
                LDA #1
                JSR MIDDLER
                JSR :UP_SUB
:1              ; DEC XPOS
                ; DEC YPOS
                JSR GET_NSEW
                JSR :UP_SUB
                JMP BACK_TO_HALL

:UP_SUB         JSR HALL_ON2
                BIT KEYBRD
                BMI :2
                JMP DOWN
:2              RTS

UPPER           INX
                BEQ :1
                ; INC XPOS
                ; INC YPOS
                LDA #0
                JSR MIDDLER
                JSR :DOWN_SUB
:1              ; INC XPOS
                ; INC YPOS
                JSR GET_NSEW
                JSR :DOWN_SUB
                JMP BACK_TO_HALL

:DOWN_SUB       JSR HALL_ON2
                BIT KEYBRD
                BMI :2
                JMP UP
:2              RTS

HALL_ON2        JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictSetPage1
                PictEnd
                RTS

BACK_TO_HALL    BIT UNSTROB
                JSR DRAW_PICT
                PictSetPage2
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictSetPage1
                PictShowPage
                PictEnd
                SEC
                RTS
;
; On entry:
;   A: 0=UP, 1=DOWN
;
MIDDLER
;                 EOR SHELL
;                 ASL
;                 TAX
;                 LDA MIDDLES-2,X
;                 STA POINTL
;                 LDA MIDDLES-1,X
;                 STA POINTH
;                 LDY #$00
;                 LDA (POINTL),Y
;                 TAX
; :1              INY
;                 LDA (POINTL),Y
;                 STA BLOCK_BUFFER-1,Y
;                 DEX
;                 BNE :1
                RTS

; MIDDLES         DW  UP_31
;                 DW  DOWN_13
;                 DW  UP_53
;                 DW  DOWN_35

; UP_31           DB  14
;                 DB  $00,$00,$C0
;                 DB  $C0,$C0,$C0
;                 DB  $C0,$C0,$C0
;                 DB  $C0,$D8,$1B
;                 DB  $FF,$C0

; DOWN_13         DB  6
;                 DB  $00,$00,$D8
;                 DB  $1B,$FF,$C0

; UP_53           DB  8
;                 DB  $00,$00,$C0
;                 DB  $C0,$1B,$D8
;                 DB  $FF,$80

; DOWN_35         DB  6
;                 DB  $00,$00,$1B
;                 DB  $D8,$FF,$C0

FLAG_345        DB  $00
DEST_SHELL      DB  $00

COPY_CROSS      LDA #<CROSS_BEGIN
                STA CROSSL
                LDA #>CROSS_BEGIN
                STA CROSSH
                LDX #0
:1              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #39
:2              LDA (SCREENL),Y
                STA (CROSSL),Y
                DEY
                BPL :2
                LDA CROSSL
                CLC
                ADC #40
                STA CROSSL
                BCC :3
                INC CROSSH
:3              INX
                CPX #CrossHeight
                BNE :1
                RTS

LOAD_SHELL      LDX DEST_SHELL
                LDA DISK_SIDES-1,X
                JSR SET_DISK_SIDE
            do 0
; Load control file based on DEST_SHELL
;   and file table in camp
                TXA
                CLC
                ADC #cControl17-1
                TAX
                JSR SLOAD_FILE

                LDX #$03
:1              LDA SHELL_INFO,X
                STA MAPSPOT,X
                DEX
                BPL :1
            fin
                RTS

DISK_SIDES
            do ORIGINAL
                DB  side_T1     ; 17
                DB  side_T2     ; 15
                DB  side_T3     ; 13
                DB  side_T4     ; 11
                DB  side_T5     ;  9
            else
                DB  side_T1     ; 17
                DB  side_T1     ; 15
                DB  side_T2     ; 13
                DB  side_T2     ; 11
                DB  side_T2     ;  9
            fin

;---------------------------------------
; scroll screen down (up elevator)
;---------------------------------------

UP              LDA #CrossHeight
                STA CROSS_COUNT
                LDA #<CROSS_END
                STA CROSSL
                LDA #>CROSS_END
                STA CROSSH
                LDA #192
                STA OFF_LINE

ULOOP           BIT KEYBRD
                BMI :1
                LDA OFF_LINE
                CMP #FinalDY
                BEQ USCROLL_FINAL
                BCS USCROLL
:1              RTS

USCROLL_FINAL   LDX #192
:1              DEX
                LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                LDA LOBYTES-FinalDY,X
                STA SCREENL
                LDA HIBYTES-FinalDY,X
                STA SCREENH
                LDY #39
:2              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :2
                CPX #FinalDY
                BNE :1
                BEQ UCROSS              ; always

USCROLL         LDX #192
:1              DEX
                LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                LDA LOBYTES-ScrollDY,X
                STA SCREENL
                LDA HIBYTES-ScrollDY,X
                STA SCREENH
                LDY #39
:2              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :2
                CPX #ScrollDY
                BNE :1

UCROSS          LDA CROSS_COUNT
                BEQ UOFF_END
                LDY #ScrollDY
                SEC
                SBC #ScrollDY
                BCS :0
                LDY #FinalCopyCount
                LDA #0
:0              STA CROSS_COUNT
                STY COPY_COUNT

:1              LDA CROSSL
                SEC
                SBC #40
                STA CROSSL
                BCS :2
                DEC CROSSH
:2              DEX
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #39
:3              LDA (CROSSL),Y
                STA (SCREENL),Y
                DEY
                BPL :3
                DEC COPY_COUNT
                BNE :1
                BEQ UOFF_END            ; always

UOFF            DEX
                LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                STX ON_LINE
                LDX OFF_LINE
                DEX
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                EOR #$60
                STA SCREENH
                STX OFF_LINE
                LDY #39
:1              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :1
                LDX ON_LINE
UOFF_END        CPX #0
                BNE UOFF
                JMP ULOOP

;---------------------------------------
; scroll screen up (down elevator)
;---------------------------------------

DOWN            LDA #CrossHeight
                STA CROSS_COUNT
                LDA #<CROSS_BEGIN
                STA CROSSL
                LDA #>CROSS_BEGIN
                STA CROSSH
                LDA #0
                STA OFF_LINE

DLOOP           BIT KEYBRD
                BMI :1
                LDA #192-FinalDY
                SEC
                SBC OFF_LINE
                BEQ DSCROLL_FINAL
                BCS DSCROLL
:1              RTS

DSCROLL_FINAL   LDX #0
:1              LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                LDA LOBYTES+FinalDY,X
                STA SCREENL
                LDA HIBYTES+FinalDY,X
                STA SCREENH
                LDY #39
:2              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :2
                INX
                CPX #192-FinalDY
                BNE :1
                BEQ DCROSS              ; always

DSCROLL         LDX #0
:1              LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                LDA LOBYTES+ScrollDY,X
                STA SCREENL
                LDA HIBYTES+ScrollDY,X
                STA SCREENH
                LDY #39
:2              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :2
                INX
                CPX #192-ScrollDY
                BNE :1

DCROSS          LDA CROSS_COUNT
                BEQ DOFF_END
                LDY #ScrollDY
                SEC
                SBC #ScrollDY
                BCS :0
                LDY #FinalCopyCount
                LDA #0
:0              STA CROSS_COUNT
                STY COPY_COUNT

:1              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #39
:2              LDA (CROSSL),Y
                STA (SCREENL),Y
                DEY
                BPL :2
                LDA CROSSL
                CLC
                ADC #40
                STA CROSSL
                BCC :3
                INC CROSSH
:3              INX
                DEC COPY_COUNT
                BNE :1
                BEQ DOFF_END            ; always

DOFF            LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                INX
                STX ON_LINE
                LDX OFF_LINE
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                EOR #$60
                STA SCREENH
                INX
                STX OFF_LINE
                LDY #39
:1              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :1
                LDX ON_LINE
DOFF_END        CPX #192
                BNE DOFF
                JMP DLOOP

DIAGS_CLOSE     DB  ORD_B, ORD_E
                DB  ORD_A, ORD_F
                DB  ORD_B, ORD_G
                DB  ORD_MOVE
                DB  ORD_C, ORD_E
                DB  ORD_D, ORD_F
                DB  ORD_C, ORD_G
                DB  ORD_STOP

;                    A   B   C   D   E   F   G
DIAG_DATA_CLOSE DB  $44,$4F,$C8,$D3,$41,$66,$89

PANEL           DB  $0F,$45,$0D,$41
                HEX 8028FDFD8955FDFD892AA1A62AA198830250408A2AA155A1
                HEX A655A1848028A52A892820848055A12AA1A62AA184800189
                HEX 415101915515050186802AA155A1A655A1848120970730A5
                HEX 8455A12AA1A62AA186800105155501915141018984802AA1
                HEX 55A1A655A1848128A59707318455A12AA1A62AA184BF0827
                HEX 862AA155A1A655A184BF0B278455A12AA1A62AA186970D28
                HEX A5842AA155A15499C0549D55A12ABDC02AC1
                DB  $FF

BUTTONS_123     DB  $0C,$45,$03,$41
                HEX 802AB9026262022A2A002A2A027289029700179DB7001299
                HEX 9F012E5555003C3C3839A1387F7F005555005555007F7F00
                HEX 141597021854541497021EB702137E7E0015159F03242AB9
                HEX 2027272097012920279D209F0416A70412B9202A2A
                DB  $FF

BUTTONS_345     DB  $0C,$45,$03,$41
                HEX 802A2A027289022A999F01020097000CA1022A9DB7001502
                HEX A7010C5555007F7F001415007E7E00151514970202555500
                HEX 5555046495607F7F6065910597031397020F545497022EA7
                HEX 030C2A2A2027B92097012928299521272721299128970513
                HEX 209705102027A1202A2A
                DB  $FF

CROSS_SECTION   DB  $00,$00,$28,$25
                HEX 8302FEB28B4C8B80325004005004009F0008A7010B970103
                HEX 7E8B7F668B81198B6600200A00200A9F0208A7030B970303
                HEX 7F8B7F4C8B81338B4C0410010410019F040897040E009704
                HEX 139705037F8B7F198B81668B19007F7F0077558997060C97
                HEX 070C9706089707037F8B7F338B814C8B331004401004409F
                HEX 0808A7090B9709037F8BA7030002280002289F0A08A70B0B
                HEX A7021DA704004510004510009F0C08A70D0BA7041DA70700
                HEX 08220008229F0E08A70F0BA7061DA708001440011440019F
                HEX 1008A7110BA7081DA70A000220080220089F1208A7130B66
                HEX 199F0A1FA70C005000055000059F1408A7150BA70C1DA70F
                HEX 007C7C005C548997160C97170C971608A70E1DA710005003
                HEX 03500302520203520202530202520300530300A7101DFF03
                HEX 008B971221A714004410014410019F1C08A71D0BA7141DA7
                HEX 16000200280200289F1E08A71F0BA7161DA7090041041041
                HEX 049F2008A7210BA7181DA71A00CF1B0A0020A71A1DA71C00
                HEX 4004114004119F2408A7250BA71C1DA71700727000725050
                HEX 52705052507052505072007072A7171CA72000004F0F004E
                HEX 0A0A4A0E0A4A0A0E4A0A0A4E000F4FA7191CFF12009F231E
                HEX FF1400339F241FA72600CF2B0A022019669F261FA72800D7
                HEX 100914A7281DA72A002208002208009F3208A7330BA72A1D
                HEX A72C000004510004519F3408A7350BA7241DA72E000A4040
                HEX 0A40404A40404A9F360C40004A4000A72E1DA729003F3F00
                HEX 3B2A8997380C97390C973808A7301DFF22009F131EFF2500
                HEX 8B973421A73600CF1F0A02A7271CA7390010450010459F40
                HEX 08A7410BA7381DFF33008B973A21A73C000140140140149F
                HEX 4408A7450BA73C1DA72F0020020820029F4608A7470BA73E
                HEX 1DA741007E7E006E2A8997480C97490C974808A7401DA742
                HEX 00200901200901210901219F4A0C09002109A7431CFF3500
                HEX 8B974421A7370020000A20009F4E08A74F0BA7461D
                DB  $FF

                DS  \,$EE

                DUMMY *
CROSS_BEGIN     DS  CrossHeight*40
CROSS_END
                DEND
