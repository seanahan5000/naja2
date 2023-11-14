
LEFTCOL			=	LOCAL_TEMP                   ; *** CLEAN UP
RITECOL         =   LOCAL_TEMP+1

DELETE_CHAR     JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictImage DELETE_PIC
                PictTextAt 95;87;"SHUTTLE"
                PictTextAt 77;100;"NOW_LOADING"
                PictShowPage
                PictEnd
                LDA GRPNUMB
                BEQ :1
                JMP NOT0

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

NOT0            LDX #6
                LDA #0
:1              STA CNTABLE,X
                DEX
                BPL :1

                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall GROUP_DO
            do SMALL_GROUP
                PictTextAt 16;182;"LEAVE"
            else
                PictTextAt 16;185;"LEAVE"
            fin
                PictSetPage2
                PictEnd
                JSR GOSLIDE
                JSR ASK_IN

RESTART         LDA #-1
                STA DEL_CURPOS
REPEAT          JSR RESET_CHLIST
                LDX #<NOT_IN_LIMBO
                LDY #>NOT_IN_LIMBO
                JSR CSCAN_COMMON
                LDA #0
                STA LEGALS+7
                INC DEL_CURPOS
                LDX #<DEL_CDEF
                LDY #>DEL_CDEF
                JSR MENU_INIT
                JSR MENU_SELECT
                CPX #7
                BEQ DELETE_OUT
                STX DEL_CURPOS
                TXA
                JSR SET_CHAR

TEST1           JSR VITAL_TEST
                BCS REPEAT
                LDA ROBOT_FLAG
                BMI TEST2
                JSR SET_CHAR
                JSR VITAL_TEST
                BCS REPEAT
                LDA CURSOR
                JSR SET_CHAR

TEST2           LDA ROBOT_FLAG
                ASL
                BPL TEST3
                LSR
                AND #%00111111
                JSR SET_CHAR
                LDA #2                  ; Robot must be with you
                JSR WARNING
                JMP REPEAT

TEST3           LDY CURSOR
                LDA CNTABLE,Y
                BNE PASSES
                JSR HAS_EQUIPMENT
                BCS PASSES
                LDA ROBOT_FLAG
                BMI PASSES
                JSR SET_CHAR
                JSR HAS_EQUIPMENT

PASSES          LDY CURSOR
                JSR SMARKIT
                LDY ROBOT_FLAG
                BMI REPEAT
                JSR SMARKIT
                JMP REPEAT

DELETE_OUT      LDX #$06
:1              LDA CNTABLE,X
                BNE :2
                DEX
                BPL :1
                JMP NOTAONE

:2              JSR DRAW_PICT
                PictClear 1;15;18;30
                PictTextAt 27;15;"ARE YOU SURE?"
                PictTextAt 21;23;"A>CCEPT   R>EDO"
                PictEnd
:3              LDA KEYBRD
                BPL :3
                BIT UNSTROB
                CMP #"A"            ;A>CCEPT
                BEQ WILLACC
                CMP #"R"            ;R>EDO
                BNE :3
                JSR WHOS_RETURNING
                JMP RESTART

WHOS_RETURNING  JSR DRAW_PICT
                PictClear 1;15;18;30
                PictTextAt 9;15;"WHO IS RETURNING TO"
                PictTextAt 12;23;"THEIR HOME PLANET?"
                PictEnd
                RTS

WILLACC         LDA GRPNUMB
                STA YCOUNT
                DEC YCOUNT
ERALOOP         LDY YCOUNT
                LDA CNTABLE,Y
                BEQ NOERAS
                INC YCOUNT
                JSR ERASER
                DEC YCOUNT
NOERAS          DEC YCOUNT
                BPL ERALOOP
                JSR ASK_OUT
                JSR WRITE_OPEN
                JMP DELCOM
NOTAONE         JSR ASK_OUT
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

*-------------------------------

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

*-------------------------------------------------
* It can be assumed that any undropable equipment
*   has removed from the character by now.
*-------------------------------------------------

ERASER          LDX YCOUNT
                DEX
                TXA
                JSR SET_CHAR
                LDY #status         ;Update LOST_CHAR count
                LDA (CHARDL),Y
                AND #%00111111
                CMP #intracc
                BNE :1
                DEC LOST_CHARS
:1              LDY #disklocation
                LDA (CHARDL),Y
                PHA
                AND #$7F
                TAX
                PLA
                AND #$80
                BNE :2
                LDA #$0F
                BNE :3
:2              LDA #$F0
:3              AND OPENBUF,X
                STA OPENBUF,X

                LDA GRPNUMB
                DEC GRPNUMB
                CMP YCOUNT
                BEQ :6
                LDA YCOUNT
                STA COUNT
:4              LDX COUNT
                DEX
                TXA
                JSR SET_CHAR
                LDA CHARDL
                STA TEMP
                LDA CHARDH
                STA TEMP+1
                LDA COUNT
                JSR SET_CHAR
                LDY #$7F
:5              LDA (CHARDL),Y
                STA (TEMP),Y
                DEY
                BPL :5
                LDA COUNT
                INC COUNT
                CMP GRPNUMB
                BNE :4
:6              RTS

*-------------------------------

DEL_CDEF        DB  $08                 ; max cursor, without high bit
DEL_CURPOS      DB  $00
                DW  DCURSIT             ; cursor drawing routine

DCURSIT         LDA CURSOR
                LDX #$80
                CMP #7
                BEQ :2
                JSR SET_CHAR
                LDY #profrace
                LDA (CHARDL),Y
                AND #%11110000
                CMP #cybernate*16
                BNE :2
                LDY #robotcyblink
                LDA (CHARDL),Y
                CMP #$FF
                BEQ :2
                STA :MOD+1
                JSR FIRST_CHAR
:1              LDY #disklocation
                LDA (CHARDL),Y
:MOD            CMP #$FF
                BEQ :2
                JSR NEXT_CHAR
                BCC :1
                LDX #$C0
:2              STX ROBOT_FLAG
                ; fall through

DCURSIT2        LDX CURSOR
                JSR :SUB
                LDX ROBOT_FLAG
                BPL :SUB
                RTS
:SUB            LDY GYPNTS,X
                LDX #3
                JMP DRAW_ARROW

*-------------------------------

*-------------------------------------
* $00-$06 Group position of robot
* $80 Char has no robot
* $C0 Char has robot but not in group
*-------------------------------------

ROBOT_FLAG      DB  0

*-------------------------------

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
                JSR DCURSIT2
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
                PictTextAt 8;3;"YOUR_ROBOT, "
                PictCall DRAW_TRIMMED_NAME
                PictText ", MUST EITHER BE SOLD"
                PictTextAt 8;12;"OR HERE WITH YOU BEFORE YOU CAN LEAVE."
                PictEnd
:4              JSR :SWAP
                BIT UNSTROB
:5              LDA KEYBRD
                BPL :5
                BIT UNSTROB
                JSR CHECK_ENTER
                BNE :5
                JSR :SWAP
                JSR ASK_IN
                JMP DCURSIT2

:SWAP           JSR DRAW_PICT
                PictSwap $00;$00;$28;$20
                PictEnd
                RTS

*-------------------------------

            do SMALL_GROUP
GYPNTS          DB  128,137,146
                DB  155,164,173
                DB  182,182
            else
GYPNTS          DB  $7F,$87,$8F
                DB  $97,$9F,$A7
                DB  $AF,$B9
            fin

SMARKIT         LDA CNTABLE,Y
                EOR #$FF
                STA CNTABLE,Y
                LDA GYPNTS,Y
                TAY
                LDX #$03
                JSR MOVE_TO
                JSR :SUBA
                LDX #-1                 ; DRAW_TILE advances X by 7 (one byte)
                JSR HMOVE
:SUBA           LDX #<:SHAPE
                LDY #>:SHAPE
                JMP DRAW_TILE

; TODO: use existing smaller marker
:SHAPE          DB  %00111111
                DB  %00111111
                DB  %00111111
                DB  %00111111
                DB  %00111111
                DB  %00111111
                DB  %00111111

; TODO: make this a dummy
CNTABLE         DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00

DELETE_PIC      DB  $07,$5A,$0E,$0A     ; arrow
                HEX 9040828E202A828C50555582888180282A89818086505591
                HEX 8220282A99828A558D828A2A8D828A558D828A2A8D828A55
                HEX 8D828A2A8D828A558D828A2A8D82

                ; DB  $23,$49,$05,$2D     ; old control panel
                ; HEX 88601818585818585818588997000CA7000CA70106189B78
                ; HEX 8260180782831370700303707303E07F016FE07F0177E07F
                ; HEX 017B970214830B60637B807373807373807F9B06070E1E1E
                ; HEX 3636767656E9767636361E1E0E06079201030306060E0E1A
                ; HEX 3A3A6A892A6A893A3A1A0E0E060603030192AA311F03AA

                DB  $23,$49,$05,$2F     ; new control panel
                HEX 88601818585818585819595A5C1C5889189700119F00111E
                HEX 5997001B18935C1C7A010182601807828313707003037073
                HEX 03E07F016FE07F0177E07F017B970214830B60637B807373
                HEX 807373807F9B8406070E1E1E3636767656E9767636361E1E
                HEX 0E0607849201030306060E0E1A3A3A6A892A6A893A3A1A0E
                HEX 0E060603030196AA01330F01AC

                ; DB  $13,$0E,$0F,$AD     ; old guy
                ; HEX E681CF40A1FEE2BC8000406060707058585C8D5689575743
                ; HEX 038D01A10303060C186000FED4B860382E2B2B2AB92800C5
                ; HEX 030C3040FECEB200605E55B95D7595707078786C6C46434E
                ; HEX 183060404000950106186000E9405F408D60910040400040
                ; HEX 40970770A50060783889303038892CA938A92C2C2E6E3B2F
                ; HEX 2B7FB000782F2AF12B9D2F2E892C2C38706060637C7060A1
                ; HEX A7078A2E2E2F2F2B2B7F01013B017131803D0D6D6D0F6D6D
                ; HEX 0F9F086E3D2D7D3177435F0D7D317F80007F55F9895F7555
                ; HEX 557F008D40603089609706687038996C6C6F2D2D6D3D7D55
                ; HEX FDA57F2A8D7F55DD7F000077007F00807F031B8B2B3B6B3B
                ; HEX 2B7F638B7F81807971777537363676477680407F2A2A6AA5
                ; HEX 3A891A890E0E0606A703310395785C565755917F08897F55
                ; HEX 7D0D0D070703635957757D077F007F37363A6A2AFD8D7A7A
                ; HEX 7F758D7F7A7A2AD52B3E6000800E1F581B438B1B41194159
                ; HEX 417C6C7E3038181F0C06070703899F0AA4800195008DB27F
                ; HEX 2A9D7F11897F2A7F0089821F6A2A3F607F007F827F5B897F
                ; HEX 55FD8D7F7F6E957F7F55D15D895F5C895D8B767776636341
                ; HEX 890091E403070D1D3575970E4222897F555756565C5C5858
                ; HEX 737D75575C7F407F3D2D2B2A9D1A1A5A89524A3A724A2AC5
                ; HEX 3F3F7D5D8D7D3F3F2AFD912B95970942970A066C64464243
                ; HEX 6161604095BA00959F0D8D00970C864363233306063E9703
                ; HEX 2A55AD1565656D892D4C735E4D95D70A3AFDE97F970836A1
                ; HEX 9709412C97068861676C40956095B0000F7A2AB526912224
                ; HEX 272B2A956A957A89970B940E070303631F0703A106060E89
                ; HEX 1A8D3A3A7A6AA12AC56A9997124AF9897D5755557FB4033D
                ; HEX 55B95D579507070F0F1B1B3161390C06039F13070040300C
                ; HEX 0300DD603E00019503C5019903030F0E899F1456A90EA997
                ; HEX 145D6F7A6A7FB8030ECF0C200A00C560180697163FFEC283
                ; HEX 03018101BC00019710008D35897589555541408D00A1970A
                ; HEX 040C0300FED4D4971203910919133323639F022F0000FEDC

                DB  $13,$0E,$0E,$AD     ; new guy
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


                ; working guard image
            do 0
                DB  $12,$00,$13,$C0
                HEX FE867FE27FDC7FB8D88000954040608D30893838188D1C0D
                HEX 0C9D18183060400000C4807FDC7FB8D4800040705C5E5657
                HEX 5755A9544000BD010618600000BE807FDC7FB8CE80000070
                HEX 2E2B2AB16A2A91289F02303018704000A1030C304000F17F
                HEX 00F9408D97079260956F608D40A96060707058788B8ACC00
                HEX 407E55C157A556565C89595B5E5C5C7870896060409F044E
                HEX AD9F079A7070787858587C0D0C5C0C0C0E806E8D786C6C78
                HEX 6C6C9F087E6C0C3C1C7C6C6C0C7880067F2B9D2AA92BA92A
                HEX 897E2B2A2A7F8A9C00B940996060786F6A8D2AFDA12B7F56
                HEX 89577F2EA1BF09988324FF8080BB80FF837B185E1E585E5E
                HEX 585E5E781E7E187B824F0B3F2C3D3037333F3087FDD5C575
                HEX 7535351D890D951D1D1F1D1D1F8A9C406030382C970A637E
                HEX 44897E2F6B893B3B1B1B4E3E2E6A3A7E037F3D3555FD9D7F
                HEX 2A8D7F55DD5F70000780707F405F18598B0A4B0E4B0A6766
                HEX 770647407F67373F3B1B1B1F800C0F0C1F1A1A0E95068D03
                HEX 7B0301890000AC9C7F559D7F08897F55970674827856557D
                HEX 077F007F827F5B897E2AFD8D7F7F77957F7F2AD16A6A6B7E
                HEX 6060616D616C313C311C190C0D0C0706070303800101B07F
                HEX B89C801F3A9F0B2A7F11897F2A3F3030606041461A6B2E3F
                HEX 607F007F6D6D5D5755AD1555551555C97F7F6E957F7F55F9
                HEX A7084158899F0850A5831240402020101008080404020201
                HEX 0106083040B09C97044C03070D89070289070D1D99373777
                HEX 3535373C3F2B2AA529292D2D6D6D6C6B671C726A952AA92B
                HEX 2B97115C7F97089BFDB52B8D2E8D2D2D7F97107F91588D97
                HEX 094F60414608BF07558CC28308404020101083FDD5B93531
                HEX 368916263A5C5755549555AD753F1A897A3F1DA135357589
                HEX 55FDAD7D2F2AC59F138B2C952E6E3E2E2E7E8AAA83074040
                HEX 205050080897119F8C001F6A2AB96A3A9D7A7A5A5A0E0E4E
                HEX 66361E0F0F070389970CA66018060100B9018D0303070689
                HEX 6E0E911AC50E991A1A7F7589C7146475A99710797D55557F
                HEX 8A9497109797119C8001018A010102040408081020204040
                HEX 8680031D7555C905008D010103060300A140300C0300B483
                HEX 02700FC200A101A9602020100808040402018D0303060F0E
                HEX 6F8A9F109997161DB8830B0102020404888B8E9ABAEA912A
                HEX 9D0A00C1971656B880700FD4971196A7109CA60304182082
                HEX DE9F189A8007070B1717272D6D0C9118A10C06030300BA80
                HEX 700E01C09F1097971BA2CAFAA7181A10204040C4700E01AC
                HEX 9715219F1B03E0FE94B7181AA8601E0198AF1A9B0101F8FE
                HEX ACB720498C601E0184B72078FE92FEC4971A26641C07971E
                HEX 8BFEAA
                DB  $FF
            fin
