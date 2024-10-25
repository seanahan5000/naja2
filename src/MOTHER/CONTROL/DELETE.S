
; - ask yes/no instead of A>CCEPT or R>EDO
; - hide LEAVE while asking this
; ? adjust panel size/location when < 6 in group


; TODO: clean up ZPAGE usage
LEFTCOL			=	LOCAL_TEMP
RITECOL         =   LOCAL_TEMP+1
CHARPTR         =   LOCAL_TEMP+2        ; +3

                DUM SCRATCH_PAGE
DEL_TABLE       DS  maxGroupSize        ; flags above
LOC_TABLE       DS  maxGroupSize        ; rosterLocation values
                DEND

DELETE_CHAR     JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictImage DELETE_PIC
                PictTextAt 95;82;"SHUTTLE"
                PictTextAt 77;95;"NOW_LOADING"
                PictShowPage
                PictEnd
                LDA GRPNUMB
                BEQ :1
                JMP HAS_MEMBERS

:1              JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictSetViolet
                PictMoveTo $00;$8E
                PictLineTo $117;$8E
                PictMoveTo $00;$BF
                PictLineTo $117;$BF
                PictTextAt 17;155;"THE GROUP ASSEMBLY OFFICE THAT YOU ARE"
                PictTextAt 17;164;"LOOKING FOR IS BACK OUT THE HALL YOU JUST"
                PictTextAt 17;173;"CAME IN AND STRAIGHT AHEAD."
                PictEnd
                LDX #$8D
                JSR GOSLIDE1

:2              BIT UNSTROB
:3              LDA KEYBRD
                BPL :3
                JSR CHECK_TURN
                BNE :2

                LDX #$8D
                LDA #$01
                JSR GOSLIDE2
                JSR DRAW_PICT
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd
                SEC
                RTS

HAS_MEMBERS     JSR BUILD_TABLES
                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall GROUP_DO
                PictTextAt 16;182;"LEAVE"
                PictSetPage2
                PictEnd
                JSR GOSLIDE
                JSR ASK_IN

RESTART         LDA #-1
                STA DEL_CURPOS
REPEAT          JSR RESET_CHLIST        ; NOTE: not robots
                LDX #<NOT_IN_LIMBO
                LDY #>NOT_IN_LIMBO
                JSR CSCAN_COMMON
                LDA #0
                STA LEGALS+7
                INC DEL_CURPOS
                LDX #<DEL_MDEF
                LDY #>DEL_MDEF
                JSR MENU_INIT
                JSR MENU_SELECT
                CPX #7
                BEQ DELETE_OUT
                STX DEL_CURPOS
                LDA DEL_TABLE,X
                BMI PASSES
                TXA
                JSR SET_CHAR

TEST1           JSR VITAL_TEST
                BCS REPEAT

TEST2           LDY #profrace
                LDA (CHARDL),Y
                AND #$F0
                CMP #cybernate*16
                BNE TEST3
                LDY #roboCyberLink
                LDA (CHARDL),Y
                BEQ TEST3
                LDA #2
                JSR WARNING
                JMP REPEAT

TEST3           JSR HAS_EQUIPMENT
                BCS PASSES

PASSES          LDX CURSOR
                JSR DEL_MARKIT
                JMP REPEAT

DELETE_OUT      LDX #0
:1              LDA DEL_TABLE,X
                BMI HAS_DELETES
                INX
                CPX GRPNUMB
                BNE :1
                JMP NO_DELETES

HAS_DELETES     JSR DRAW_PICT
                PictClear 1;15;18;30
                PictTextAt 27;15;"ARE YOU SURE?"
                PictTextAt 21;23;"A>CCEPT   R>EDO"
                PictEnd
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB
                CMP #"A"
                BEQ DID_ACCEPT
                CMP #"R"
                BNE :1
                JSR WHOS_RETURNING
                JMP RESTART

WHOS_RETURNING  JSR DRAW_PICT
                PictClear 1;15;18;30
                PictTextAt 9;15;"WHO IS RETURNING TO"
                PictTextAt 12;23;"THEIR HOME PLANET?"
                PictEnd
                RTS

DID_ACCEPT      JSR ASK_OUT
                JSR DELETE_MARKED
                JMP DELCOM

NO_DELETES      JSR ASK_OUT
DELCOM          JSR GOSLIDE
:1              LDA KEYBRD
                BPL :1
                JSR CHECK_TURN
                BEQ :2
                BIT UNSTROB
                JMP :1

:2              JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictShowPage
                PictEnd
                SEC
                RTS

DEL_MDEF        DB  $08                 ; max cursor, without high bit
DEL_CURPOS      DB  $00
                DW  DEL_CURSOR

;---------------------------------------

; TODO: this won't be needed once all quest items
;   have been moved to game state

VITAL_TEST      JSR RESET_EQLIST
                JSR ESCAN_FULSLOT
                LDX #<ECALL_NODROP
                LDY #>ECALL_NODROP
                JSR ESCAN_COMMON
                BCC :1
;               SEC
                LDA #1                  ; vital equipment
                JSR WARNING2
                SEC
:1              RTS

ECALL_NODROP    INY
                INY
                LDA (CHARDL),Y
                AND #eq_vital
                EOR #eq_vital
                RTS

*-------------------------------

HAS_EQUIPMENT   LDY #status
                LDA (CHARDL),Y
                CLC
                EOR #intracc
                BEQ :2
                EOR #lost!intracc       ; ! means EOR
                BEQ :2
                JSR RESET_EQLIST
                LDY #profrace
                LDA (CHARDL),Y
                BPL :1
                LDA #$FF
                STA EQUIP_LIST+program
:1              JSR ESCAN_FULSLOT
                BCC :2
;               SEC
                LDA #0                  ; equipment more useful to others
                JSR WARNING2
                SEC
:2              RTS

*-------------------------------

NOT_IN_LIMBO    LDX #0
                LDY #status
                LDA (CHARDL),Y
                CMP #inlimbo
                BNE :1
                DEX
:1              TXA
                RTS

;---------------------------------------

BUILD_TABLES    JSR FIRST_CHAR
:1              LDA #0
                STA DEL_TABLE,X
                LDY #rosterLocation
                LDA (CHARDL),Y
                STA LOC_TABLE,X
                JSR NEXT_CHAR
                BCC :1
                RTS
;
; On entry:
;   X: cursor index
;
DEL_CURSOR      LDY DEL_YPNTS,X
                CPX #7
                BEQ :2
                JSR VMOVE_TO
                LDA DEL_TABLE,X
                BMI :1
                LDX #$05
                JSR HMOVE_TO
                JSR DRAW_MARKER_TILE
:1              LDX #$0A
                JSR HMOVE_TO
                JMP DRAW_MARKER_TIP_TILE
:2              LDX #2
                JMP DRAW_ARROW
;
; On entry:
;   X: cursor index
;
DEL_MARKIT      LDA DEL_TABLE,X
                EOR #$FF
                STA DEL_TABLE,X
                LDY DEL_YPNTS,X
                LDX #$05
                JSR MOVE_TO
                JMP DRAW_MARKER_TILE

DEL_YPNTS       DB  128,137,146
                DB  155,164,173
                DB  182,182
;
; Clear deleted characters from roster
; Remove deleted characters from group
;
DELETE_MARKED   LDX #0
:1              STX COUNT
                LDA DEL_TABLE,X
                BPL :2
                LDA LOC_TABLE,X
                AND #$0F
                JSR CLEAR_ROSTER_LOC
:2              LDX COUNT
                INX
                CPX GRPNUMB
                BNE :1
;               LDX GRPNUMB
                DEX
:3              STX COUNT
                LDA DEL_TABLE,X
                BPL :7
                STX CHAR_INDEX
                TXA
                JSR SET_CHAR
:4              LDA CHARDL
                STA CHARPTR+0
                LDA CHARDH
                STA CHARPTR+1
                JSR NEXT_CHAR
                BCS :6
                LDY #$7F
:5              LDA (CHARDL),Y
                STA (CHARPTR),Y
                DEY
                BPL :5
                BMI :4                  ; always
:6              DEC GRPNUMB
:7              LDX COUNT
                DEX
                BPL :3
                RTS

;---------------------------------------

GOSLIDE         LDX #$72                ; top line
GOSLIDE1        LDA #$30                ; wait delay
GOSLIDE2        STX GOLOOPA+1
                STA VARY+1
                LDA #$00
                STA LEFTCOL
                LDA #$27
                STA RITECOL
GOLOOPA         LDX #$72                ; modified
GOLOOPB         STX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                EOR #$60
                STA SCREENH
                TXA
                LSR
                BCS TOLEFT
                LDY LEFTCOL
                JMP GOCOMN
TOLEFT          LDY RITECOL
GOCOMN          LDA (SCREENL),Y
                PHA
                LDA (DESTINL),Y
                STA (SCREENL),Y
                PLA
                STA (DESTINL),Y
                LDX LINENUM
                INX
                CPX #192
                BNE GOLOOPB
VARY            LDA #$30                ; modified
                JSR WAIT
                INC LEFTCOL
                DEC RITECOL
                BPL GOLOOPA
                RTS

GROUP_DO        JSR DRAW_PICT
                PictSetGreen
                PictRect $01;$73;$115;$73
                PictMoveTo $01;$7D
                PictLineTo $115;$7D
                PictVMoveTo $75
                PictEnd
                LDA #$42                ; SELECT value
                JMP DRAW_STATS

ASK_IN          JSR DRAW_PICT
                PictSetPage1
                PictClear $00;$00;$28;$30
                PictSetOrange
                PictRect $05;$0C;$7F;$20
                PictCall WHOS_RETURNING
                PictSetPage2
                PictSwap $00;$0B;$13;$21
                PictEnd
                RTS

ASK_OUT         JSR DRAW_PICT
                PictSwap $00;$0B;$13;$21
                PictEnd
                RTS

*-------------------------------

WARNING         CLC
WARNING2        PHA
                PHP
                JSR ASK_OUT
                JSR DRAW_PICT
                PictSetPage1
                PictClear $00;$00;$28;$30
                PictSetViolet
                PictMoveTo $02;$00
                PictLineTo $114;$00
                PictLineTo $114;$16
                PictLineTo $E4;$16
                PictLineTo $E4;$1E
                PictLineTo $02;$1E
                PictLineTo $02;$00
                PictTextAt 232;24;"<SPACE>"
                PictEnd
                PLP
                BCC :1
                JSR DRAW_PICT
                PictTextAt 8;3;"YOU ARE CARRYING EQUIPMENT THAT WILL BE"
                PictEnd
:1              PLA
                TAY
                BNE :2
                JSR DRAW_PICT
                PictTextAt 248;3;"OF"
                PictTextAt 8;12;"MORE USE TO OTHER CADETS.  CONSIDER TRADING"
                PictTextAt 8;21;"IT BEFORE YOU LEAVE."
                PictEnd
                JMP :4

:2              DEY
                BNE :3
                JSR DRAW_PICT
                PictTextAt 8;12;"VITAL IN THE STRUGGLE TO DEFEAT NAJA.  TRADE"
                PictTextAt 8;21;"IT TO ANOTHER CADET BEFORE LEAVING."
                PictEnd
                BNE :4                  ; always

:3              JSR DRAW_PICT
                PictTextAt 8;3;"COMBAT ROBOTS ARE NOT ALLOWED ON CIVILIAN"
                PictTextAt 8;12;"TRANSPORT SHUTTLES.  IT MUST BE SOLD BEFORE"
                PictTextAt 8;21;"YOU CAN LEAVE."
                PictEnd
:4              JSR :SWAP
                BIT UNSTROB
:5              LDA KEYBRD
                BPL :5
                BIT UNSTROB
                JSR CHECK_ENTER
                BNE :5
                JSR :SWAP
                JMP ASK_IN

:SWAP           JSR DRAW_PICT
                PictSwap $00;$00;$28;$20
                PictEnd
                RTS

;---------------------------------------

DELETE_PIC      DB  $07,$55,$0E,$0A     ; arrow
                HEX 9040828E202A828C50555582888180282A89818086505591
                HEX 8220282A99828A558D828A2A8D828A558D828A2A8D828A55
                HEX 8D828A2A8D828A558D828A2A8D82

                DB  $23,$49,$05,$2F     ; control panel
                HEX 88601818585818585819595A5C1C5889189700119F00111E
                HEX 5997001B18935C1C7A010182601807828313707003037073
                HEX 03E07F016FE07F0177E07F017B970214830B60637B807373
                HEX 807373807F9B8406070E1E1E3636767656E9767636361E1E
                HEX 0E0607849201030306060E0E1A3A3A6A892A6A893A3A1A0E
                HEX 0E060603030196AA01330F01AC

                DB  $13,$0E,$0E,$AD     ; guy
                HEX BC8000954040608D30893838188D1C0D0C9D181830604000
                HEX 00FED4B80040705C5E56575755A9544000BD010618600000
                HEX FECEB20000702E2B2AB16A2A91289F00223018704000A103
                HEX 0C30400000BE00ED408D97058460956F608D40A960607070
                HEX 58788BB000407E55C157A556565C89595B5E5C5C78708960
                HEX 60409F0240AD9F058C7070787858587C0D0C5C0C0C0E806E
                HEX 8D786C6C786C6C9F06706C0C3C1C7C6C6C0C7880067F2B9D
                HEX 2AA92BA92A897E2B2A2A7F00B940996060786F6A8D2AFDA1
                HEX 2B7F5689577F2EA1BF078A8324FF8080BB80FF837B185E1E
                HEX 585E5E585E5E781E7E187B824F0B3F2C3D3037333F3087FD
                HEX D5C5757535351D890D951D1D1F1D1D1F406030382C970855
                HEX 7E44897E2F6B893B3B1B1B4E3E2E6A3A7E037F3D3555FD9D
                HEX 7F2A8D7F55DD5F70000780707F405F18598B0A4B0E4B0A67
                HEX 66770647407F67373F3B1B1B1F800C0F0C1F1A1A0E95068D
                HEX 037B0301890000A27F559D7F08897F557F0089827856557D
                HEX 077F007F827F5B897E2AFD8D7F7F77957F7F2AD18319EAEA
                HEX EBFEE0E0E1EDE1ECB1BCB19C998C8D8C87868783830101E0
                HEX 1F3A9F091C7F11897F2A3F3030606041461A6B2E3F607F00
                HEX 7F6D6D5D5755AD1555551555C97F7F6E957F7F55F9A70633
                HEX 58899F0642A5CA97023E03070D89070289070D1D99373777
                HEX 3535373C3F2B2AA529292D2D6D6D6C6B671C726A952AA92B
                HEX 2B970F4E7F97068DFDB52B8D2E8D2D2D7F970E7191588D97
                HEX 074160414608970447AD82B0037D55B93531368916263A5C
                HEX 5755549555AD753F1A897A3F1DA13535758955FDAD7D2F2A
                HEX C59F117D2C952E6E3E2E2E7EB2001F6A2AB96A3A9D7A7A5A
                HEX 5A0E0E4E66361E0F0F070389970A986018060100B9018D03
                HEX 030706896E0E911AC50E991A1A7F7589C7125675A9970E6B
                HEX 7D55557FB6031D7555C905008D010103060300A140300C03
                HEX 00FA00A101A9602020100808040402018D0303060F0E6FBA
                HEX 080B0E1A3A6A912A9D0A00C1971448FED2C29F168C07070B
                HEX 1717272D6D0C9118A10C06030300FED8
                DB  $FF
