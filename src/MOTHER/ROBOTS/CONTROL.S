scrnHEAD        =   0
scrnBODY        =   1
scrnWEAPONL     =   2
scrnWEAPONR     =   3
scrnENERGY      =   4
scrnMOVEMENT    =   5
scrnPROGRAM     =   6

TEMP            =   LOCAL_TEMP+0        ; +1

ZBLOCK_80       =   $80
ZBLOCK_88       =   $88
ZBLOCK_A0       =   $A0
ZBLOCK_A8       =   $A8

; LINENUM         =   ZBLOCK_80+0
; SCRATCH         =   ZBLOCK_80+1
; COUNTER         =   ZBLOCK_80+2
VALUEL          =   ZBLOCK_80+3
VALUEH          =   ZBLOCK_80+4
POINTER         =   ZBLOCK_80+5
LCOLUMN         =   ZBLOCK_80+6

RCOLUMN         =   ZBLOCK_88+0
CDPNTL          =   ZBLOCK_88+1
CDPNTH          =   ZBLOCK_88+2
CURHOLD         =   ZBLOCK_88+3
*
*
PARTALL         =   ZBLOCK_88+6     ;00 = First pass after complete buy
                                    ;D0 = Adjust after complete buy
                                    ;E0 = Too expensive after complete buy
                                    ;EE = REPLACEing area
XHOLD           =   ZBLOCK_88+7

MINIMUM         =   ZBLOCK_A0+0
MAXIMUM         =   ZBLOCK_A0+1
NUMTYPE         =   ZBLOCK_A0+2
PICK            =   ZBLOCK_A0+3
ON1             =   ZBLOCK_A0+4
ON2             =   ZBLOCK_A0+5
SCRPICK         =   ZBLOCK_A0+6
ASSIGN2         =   ZBLOCK_A0+7

SWITCH          =   ZBLOCK_A8+0         ; used for PictSwitch values
*
THE_ROBOT       =   ZBLOCK_A8+2
SAMFLAG         =   ZBLOCK_A8+3
MINLOW          =   ZBLOCK_A8+4
MINUPR          =   ZBLOCK_A8+5
LIMIT           =   ZBLOCK_A8+6
EXPFLAG         =   ZBLOCK_A8+7

; enter with page 1 visible

ROBOT_REPAIR    JSR DRAW_PICT
                PictSetPage1
                PictSetGreen
                PictRect $21;$00;$C3;$0A
                PictTextAt 37;2;"PLEASE TURN TO THE RIGHT "
                PictEnd
                JSR GET_INPUT_KEY
                JSR CHECK_CANCEL
                BNE NOESC
                JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictShowPage
                PictEnd
; TODO: make sure module header byte is reset
                RTS                     ; return to mother control

NOESC           JSR DRAW_PICT
                PictSetPage2
                PictRect $49;$34;$CD;$40
                PictTextAt 80;55;"PLEASE STEP CLOSER "
                PictShowPage
                PictEnd
                JSR GET_INPUT_KEY
                JSR CHECK_CANCEL
                BNE ISRET
; TODO: make sure module header byte is reset
                RTS                     ; return to mother control

ISRET           LDA #$FF
                STA ON1
                STA ON2
                LDA #$01
                STA PICK

OPTIONS         JSR PPEOR
                LDX PICK
                LDA ON1,X
                CMP #$10
                BNE :1
                JMP OPTCOM

:1              JSR ALL_ICONS
                JSR DRAW_PICT
                PictClear 0;87;40;192
                PictSetBlue
                PictRect $28;$6B;$F6;$A8
                PictEnd

                JSR COUNT_CYBS
                BCC :2
                JMP OPTION2

:2              JSR DRAW_PICT
                PictTextRows 48;114;10
                TXC "AN ABLE-BODIED CYBERNATE MUST BE\n"
                TXC "PRESENT TO MAKE ANY TRANSACTIONS\n"
                TXC "HERE AT THE ROBOT ORDERING AND\n"
                TXT "REPLACEMENT CENTER."
                PictTextAt 198;155;"<SPACE>"
                PictEnd

                JSR VIEWER
                BIT UNSTROB
OPTKEY          LDA KEYBRD
                BPL OPTKEY
                BIT UNSTROB
                JSR CHECK_ENTER
                BEQ LEAVE_ROBOTS
                JSR CHECK_CANCEL
                BNE OPTKEY
                ; fall through

; TODO: make sure module header byte is reset
LEAVE_ROBOTS    LDA PICK
                BNE :1
                JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictShowPage
                PictEnd
:1              RTS                     ; return to mother control

OPTION2         JSR DRAW_PICT
                PictTextAt 68;113;"AVAILABLE OPTIONS ARE:"
                PictTextAt 86;124;"REPLACE ROBOT PARTS"
                PictTextAt 86;135;"BUY A COMPLETE ROBOT"
                PictTextAt 86;144;"SELL A COMPLETE ROBOT"
                PictTextAt 86;155;"LEAVE"
                PictEnd

OPTCOM          JSR COUNT_ROBOTS
                JSR COUNT_CYBS
                LDA #4
                JSR SET_LEGALS
;
; must have a robot in the group in order to
;   replace parts or sell it
;
                LDA ROBOT_COUNT
                BNE :1
                LDA #$FF
                STA LEGALS
                STA LEGALS+2
;
; must have a cybernate in the group without a robot
;   and space in the group and roster in order to buy one
;
:1              LDA CYB_COUNT
                BEQ :2
                LDA GRPNUMB
                CMP #maxGroupSize
                BCS :2
                JSR IS_ROSTER_FULL
                BCC :3
:2              LDA #$FF
                STA LEGALS+1
:3
STOPPER         NOP
                JSR VIEWER
                BIT UNSTROB
                LDY #3
                STY CURSOR
LTLOOP          LDA OPTYPNT,Y
                STA LINTABL,Y
                DEY
                BPL LTLOOP
                LDA #$48
                STA XHOLD
                JSR KDOWN2
                JSR RCURSIT
                LDX PICK
                LDA #$10
                STA ON1,X
                LDA CURSOR
                ASL
                TAY
                LDA JUMPS+1,Y
                PHA
                LDA JUMPS,Y
                PHA
                RTS

JUMPS           DW  REPLACE-1
                DW  COMPLETE_BUY-1
                DW  COMPLETE_SELL-1
                DW  LEAVE_ROBOTS-1

;-----------------------------------------------------------

DRAW_SCREEN     STA SCRPICK
                TAY
                CPY #3
                BCC :0
                DEY
:0              STY SWITCH

                JSR DRAW_PICT
                PictClear 0;0;40;107
                PictEnd

                LDA PARTALL
                CMP #$EE
                BNE NOTRADN

                JSR DRAW_PICT
                PictTextAt 118;24;"MINUS TRADE-IN:"
                PictEnd

NOTRADN         LDA PARTALL
                BNE NOROBTM
                LDX PICK
                LDA ON1,X
                ORA #$0F
                STA ON1,X
                JSR ROBSTAT
NOROBTM         LDA SCRPICK
                AND #%11111110
                CMP #scrnWEAPONL
                BNE NOT6C

                JSR DRAW_PICT
                PictSetViolet
                PictRect $7A;$32;$F2;$66
                PictEnd

NOT6C           JSR DRAW_PICT
                PictSetOrange
                PictRect $5D;$00;$10D;$22
                PictTextAt 100;4;"AVAILABLE CREDITS:"
                PictTextAt 172;14;"PRICE:"
                PictEnd

                LDA PARTALL
                BNE PASKIP1

                JSR DRAW_PICT
                PictTextAt 100;24;"TOTAL ROBOT PRICE:"
                PictEnd

PASKIP1         JSR DRAW_PICT
                PictSetGreen
                PictRect 13;0;81;43
                PictMoveTo 100;14
                PictSwitch SWITCH

:0              PictCase :1

                PictText " ROBOT HEAD"
                PictTextAt 29;2;"HEADS"

                PictTextAt 14;56;"ATTACHMENT"
                PictTextAt 32;64;"SLOT"
                PictTextAt 97;56;"SIGHT"
                PictTextAt 97;64;"RANGE"
                PictTextAt 144;56;"ELECTRICAL"
                PictTextAt 147;64;"SHIELDING"
                PictTextAt 219;56;"PHYSICAL"
                PictTextAt 216;64;"SHIELDING"

:1              PictCase :2

                PictText " ROBOT BODY"
                PictTextAt 30;35;"BODIES"

                PictTextAt 17;56;"UPPER"
                PictTextAt 14;64;"REFLEX/STRENGTH"
                PictTextAt 130;56;"ELECTRICAL"
                PictTextAt 133;64;"SHIELDING"
                PictTextAt 219;56;"PHYSICAL"
                PictTextAt 216;64;"SHIELDING"

:2              PictCase :3

                PictText "     WEAPON"
                PictTextAt 23;2;"WEAPONS"

                PictTextAt 142;53;"ROBO-DAGGER"
                PictTextAt 142;61;"ROBO-SWORD"
                PictTextAt 142;69;"ROBO-BLASTER C"
                PictTextAt 142;77;"ROBO-BLASTER B"
                PictTextAt 142;85;"ROBO-BLASTER A"
                PictTextAt 142;93;"NOTHING"

:3              PictCase :4

                PictText "ENERGY SUP."
                PictTextAt 28;2;"ENERGY"

                PictTextAt 139;57;"ENERGY CAPACITY"

:4              PictCase :5

                PictText "   MOVEMENT"
                PictTextAt 22;35;"MOVEMENT"

                PictTextAt 131;57;"LOWER"
                PictTextAt 128;65;"REFLEX"
                PictTextAt 181;57;"MOVEMENT"
                PictTextAt 193;65;"TYPE"
                PictTextAt 191;81;"TREAD"

:5              PictCase :END

                PictText "    PROGRAM"
                PictTextAt 20;2;"PROGRAMS"

                PictTextAt 127;56;"PROGRAM"
                PictTextAt 133;64;"LEVEL"
                PictTextAt 197;56;"AUTO-"
                PictTextAt 197;64;"START"

:END            PictSwitchEnd
                PictEnd

                LDY SWITCH
                JSR DRAW_ICON
                JSR DELABLE

                LDX #214
                LDY #4
                JSR DRAW_GCREDITS_AT

                LDA SCRPICK
                TAY
                SEC
                SBC #scrnWEAPONL
                BCC NOSCRT
                CMP #2
                BCS NOSCRT
                PHA
                ADC #7              ;Carry assumed clear
                TAX
                LDY #5              ;Empty hand slot
                JSR VALUSUB
                LDX #3
                PLA
                CLC
                ADC #1
                ASL
                ASL
                TAY
XXLOOP          DEY
                LDA CAT7,Y
                STA CATT,X
                DEX
                BPL XXLOOP
                JMP INITSUB

NOSCRT          LDX BEGCATS,Y
                JSR DRAW_FIRST_VBOX
                JSR CATTOTL
                JSR INITSUB
                LDY #3
                LDA #0
PVLOOPA         STA POINTLV,Y
                DEY
                BPL PVLOOPA
                LDY SCRPICK
                LDA NUMCATS,Y
                STA SCRATCH
                LDA #$00
                STA POINTER
PBLOOP          JSR BIGSUB
                INC POINTER
                LDA POINTER
                CMP SCRATCH
                BNE PBLOOP
                LDA SCRPICK
                CMP #scrnENERGY
                BNE SCROUT

                JSR TRICKY
                JSR TRICKY
TRICKY          LDA #$00
                JSR DRAW_BIGNUM
SCROUT          RTS

;-----------------------------------------------------------

DELABLE         JSR DRAW_PICT
                PictSwitch SCRPICK
:0              PictCase :1
                PictTextAt 146;111;"2"
                PictTextAt 146;120;"NO"
                PictTextAt 188;120;"E:4  P:5"
:1              PictCase :2
                PictTextAt 146;131;"25/25"
                PictTextAt 188;131;"E:10 P:10"
:2              PictCase :3
:3              PictCase :4
:4              PictCase :5
                PictTextAt 146;160;"1000/3000"
:5              PictCase :6
                PictTextAt 146;169;"TREAD"
                PictTextAt 212;169;"LR:20"
:6              PictCase :END
                PictTextAt 146;180;"LEVEL 1"
:END            PictSwitchEnd
                PictEnd
                RTS

;-----------------------------------------------------------

INITSUB         LDA #$00
                STA EXPFLAG
                LDX #$03
                CLC
STLOOPA         LDA CATT,X
                SED
                ADC RTOTNUM,X
                CLD
                STA RTOTNEW,X
                DEX
                BPL STLOOPA
                LDX #$03
                SEC
STLOOPB         LDA CATT,X
                SED
                SBC ETRDNUM,X
                CLD
                STA EVALNEW,X
                DEX
                BPL STLOOPB
                LDX #$07
                LDA #$0A
STLOOPC         STA EVALSCN,X
                DEX
                BPL STLOOPC
                LDX #$03
                LDA #$00
STLOOPD         STA EVALNUM,X
                DEX
                BPL STLOOPD
                JSR TRADSUB
                LDA PARTALL
                CMP #$EE
                BNE STSKIPD
                JSR TRSUBY
                LDA #$00
                STA EXPFLAG
STSKIPD         LDA EXPFLAG
                BEQ STSKIPE
                JSR DRAW_EXPENSIVE
STSKIPE         LDX #$03
STLOOPE         LDA RTOTNUM,X
                STA RTOTAL,X
                DEX
                BPL STLOOPE
                JSR RTSUB
                JMP UPDATER

TRADSUB         LDA PARTALL
                CMP #$EE
                BNE TRADOUT
                LDX #$03
                SEC
TRLOOPX         LDA EVALNEW,X
                SED
                SBC TRADEIN,X
                CLD
                STA RTOTNEW,X
                DEX
                BPL TRLOOPX
                BCS TRADUM
                JSR TRSUBY
TRADUM          LDX #$03
                SEC
TRLOOPW         LDA GROUP_CREDITS,X
                SED
                SBC RTOTNEW,X
                CLD
                DEX
                BPL TRLOOPW
                LDA #$00
                BCS TRADO1
                LDA #$EE
TRADO1          STA EXPFLAG
                LDY #$00
                LDA SCRPICK
                AND #%11111110
                CMP #scrnWEAPONL
                BNE TRSKIPW
                LDX SCRPICK
                LDA LWEAPON-scrnWEAPONL,X
                CMP CURSOR
                BNE TRADO2
                DEY
                BNE TRADO2          ;Always
TRSKIPW         LDX SCRPICK
                LDA NUMCATS,X
                TAX
                DEX
TRLOOPV         LDA POINTLV,X
                CMP DUPNTLV,X
                BNE TRADO2
                DEX
                BPL TRLOOPV
                JSR TRSUBY
                STA EXPFLAG
                DEY
TRADO2          STY SAMFLAG
TRADOUT         RTS

TRSUBY          LDX #$03
                LDA #$00
TRLOOPY         STA RTOTNEW,X
                DEX
                BPL TRLOOPY
                RTS

;-----------------------------------------------------------

DRAW_GROUP      LDX PICK
                LDA ON1,X
                AND #$0F
                CMP #$02
                BNE :1
                JSR DRAW_PICT
                PictClear 0;87;40;107
                PictEnd
                RTS

:1              TXA
                EOR #$01
                TAX
                LDA ON1,X
                AND #$0F
                CMP #$02
                BNE :2
                JMP MTBOTM_CLRMID

:2              JSR DRAW_PICT
                PictClear 0;87;40;192
                PictSetGreen
                PictRect $01;$73;$115;$B7
                PictMoveTo $01;$7D
                PictLineTo $115;$7D
                PictTextAt 16;185;"CANCEL"
                PictVMoveTo 117
                PictEnd
                LDA #$42                ; SELECT
                JSR DRAW_STATS

                LDX PICK
                LDA ON1,X
                AND #$F0
                ORA #$02
                STA ON1,X
                RTS

;-----------------------------------------------------------

ROBSTAT         LDX PICK
                LDA ON1,X
                AND #$0F
                CMP #$03
                BEQ NOCANC
                CMP #$04
                BNE NORHERE

                JSR DRAW_PICT
                PictClear 0;87;40;107
                PictEnd
                RTS

NOCANC          JSR CANCEL_IN
                JSR DRAW_PICT
                PictClear 0;87;40;107
                PictEnd
                RTS

NORHERE         TXA
                EOR #$01
                TAX
                LDA ON1,X
                AND #$0F
                CMP #$04
                BNE DOROBS2
                JMP MTBOTM_CLRMID

DOROBS2         JSR DRAW_PICT
                PictClear 0;87;40;192
                PictSetBlue
                PictRect $28;$6B;$F6;$BF
                PictCall CANCEL_IN
                PictTextAt 62;111;"SIGHT RANGE:"
                PictTextAt 74;120;"HEAD SLOT:"
                PictTextAt 74;131;"BODY TYPE:"
                PictTextAt 68;142;"WEAPON <L>:"
                PictTextAt 68;151;"WEAPON <R>:"
                PictTextAt 56;180;"PROGRAM CARD:"
                PictTextAt 50;160;"ENERGY SUPPLY:"
                PictTextAt 50;169;"MOVEMENT TYPE:"
                PictEnd
                RTS

MTBOTM_CLRMID   JSR DRAW_PICT
                PictClear 0;87;40;107
                PictCopyTo 0;107;40;192
                PictEnd
                RTS

ROSTAT2         JSR DOROBS2
                JSR DRAW_PICT
                PictTextAt 188;120;"E:   P:"
                PictTextAt 188;131;"E:   P:"
                PictTextAt 212;169;"LR:"
                PictTextAt 158;131;"/"
                PictTextAt 146;160;"1000/"
                PictTextAt 146;180;"LEVEL"
                PictEnd

                JSR REVERSE
                LDA PLEVEL
                PHA
                LDA #$00
                STA SCRPICK
ROLOOP2         CMP #scrnWEAPONL
                BNE :1
                LDX LWEAPON
                LDY #$8E
                BNE :2              ;Always
:1              CMP #scrnWEAPONR
                BNE ROSKIP1
                LDX RWEAPON
                LDY #$97
:2              JSR VMOVE_TO
                TXA
                JSR WEASUB
                JMP ROSKIP2
ROSKIP1         JSR TOPLEVL
                LDA SCRPICK
                CMP #scrnPROGRAM
                BNE ROSKIP4
                LDY #e15_PROGRAM+1
                LDA (CHARDL),Y
                STA PLEVEL
ROSKIP4         LDA #$00
                STA POINTER
                LDY SCRPICK
                LDA NUMCATS,Y
                STA MAXMOD3+1
ROLOOP1         JSR UPDBOX
                LDA SCRPICK
                CMP #scrnPROGRAM
                BEQ ROSKIP2
                INC POINTER
                LDA POINTER
MAXMOD3         CMP #$FF
                BNE ROLOOP1
ROSKIP2         LDA SCRPICK
                CMP #scrnMOVEMENT
                BNE ROSKIP3
                LDA LOWREF
                LSR
                LSR
                JSR DRAW_MOVEMENT_B
ROSKIP3         INC SCRPICK
                LDA SCRPICK
                CMP #scrnPROGRAM+1
                BEQ NOROL2
                JMP ROLOOP2
NOROL2          PLA
                STA PLEVEL
                RTS

BTRANS          JSR DRAW_PICT
                PictCopyTo 0;107;40;192
                PictEnd
                RTS

;-----------------------------------------------------------

ALL_ICONS       LDX PICK
                LDA ON1,X
                AND #$F0
                CMP #$10
                BNE :1
                JSR DRAW_PICT
                PictClear 0;87;40;107
                PictEnd
                RTS

:1              TXA
                EOR #$01
                TAX
                LDA ON1,X
                AND #$F0
                CMP #$10
                BNE :2
                JSR DRAW_PICT
                PictCopyTo 0;0;40;87
                PictClear 0;87;40;107
                PictEnd
                RTS

:2              JSR DRAW_PICT
                PictClear 0;0;40;107
                PictSetGreen
                PictRect 41;0;245;86
                PictMoveTo 41;43
                PictLineTo 245;43
                PictMoveTo 109;0
                PictLineTo 109;86
                PictMoveTo 177;0
                PictLineTo 177;86
                PictTextAt 61;2;"HEADS"
                PictTextAt 126;35;"BODIES"
                PictTextAt 191;2;"WEAPONS"
                PictTextAt 188;45;"PROGRAMS"
                PictTextAt 58;45;"ENERGY"
                PictTextAt 120;78;"MOVEMENT"
                PictImage ICON0
                PictImage ICON1
                PictImage ICON2
                PictImage ICON3
                PictImage ICON4
                PictImage ICON5
                PictEnd
                LDX PICK
                LDA ON1,X
                AND #$0F
                ORA #$10
                STA ON1,X
                RTS

;-----------------------------------------------------------

DRAW_ICON       TYA
                ASL
                PHA
                TAX
                LDY :PNTS+1,X
                LDA :PNTS+0,X
                TAX
                JSR MOVE_TO
                PLA
                TAY
                LDX ICONS,Y
                LDA ICONS+1,Y
                TAY
                JMP UNPACK_TO

:PNTS           DB  28,10
                DB  21,2
                DB  21,10
                DB  21,10
                DB  14,10
                DB  28,10

ICONS           DW  ICON0
                DW  ICON1
                DW  ICON2
                DW  ICON3
                DW  ICON4
                DW  ICON5

ICON0           DB  $08,$0A,$05,$20     ; heads
                HEX 9640603040824040827868286830408E707010787C7E7F2A
                HEX 3F2A7F89706F5B366D5B827F753F407F8E7F7F827F893F55
                HEX 65757F3F2F7F2F3F7F7E7D7877797E0F211E2E931E3F7F70
                HEX 7B7D7E7F9175757475757F8D3F4750558D5455505540820A
                HEX 0B0B0F0F1F1F0F3F02020702023F0F1F89820F891D913989
                DB  $FF

ICON1           DB  $11,$02,$06,$20     ; bodies
                HEX 8000C9606000A900C57E2B2B7E00A50089406030382C2E2B
                HEX 954B4B81607F55557F002C2C388D7030707C565755890571
                HEX 1D6D2D6D1C730B2B6B6A3A5B4E575055917F557D270F1A3A
                HEX 6A6A2A28636E6D896E63686B692AA93F6A2F79008D010303
                HEX 010000010000970A0703B9
                DB  $FF

ICON2           DB  $1B,$0A,$07,$20     ; weapons
                HEX 8000C5702A7000A900BD08627A527A020800A100B9180C3E
                HEX 5B5A5B33817E00A18C8304406070589D8306807F2A2A7F80
                HEX 806060408D866030382C2E2B2B0A6A8D621A5A5C5C56575D
                HEX 753F822A2A2B897B2F6F3F7F5591401F716E6A6E711F405A
                HEX 4E5653555455997F8B4A820103060E1A1A0E06060E060697
                HEX 0C071AA91B1E1A1F
                DB  $FF

ICON3           DB  $07,$35,$07,$20     ; energy
                HEX 289D486830956050105095703010202028285595827E433C
                HEX 7F7F60077F7F3C437E825A4E5653555455952A99686B662D
                HEX 896C6D6D666B686A2A896A6A2A99070D1D890D6780333939
                HEX 373B37392D91970709393380679706011D8000951F151D93
                HEX 05991D15931F009100995000C1500095008D02892A028900
                HEX B52A0095
                DB  $FF

ICON4           DB  $10,$35,$09,$11     ; movement
                HEX 98406089409260384E431C1C417F826089780E701C676108
                HEX 2A200E0E207F047F08087F827F0471710455104747107F82
                HEX 7F11117F827F023838022A086363087F827F22227F827F41
                HEX 1C1C41559706077F087F44447F827F97040C2A42701C0701
                HEX 8201071C7F403F706767380E03888A0396
                DB  $FF

ICON5           DB  $1C,$35,$04,$20     ; programs
                HEX 8040400040407E547E970004407E6A937E970000A17F6F6E
                HEX 7D6F6D7D6D6F7D0D6D6F6D0D7D0D6D89830C8FFD2623FDD5
                HEX FD81FFEDEDFF8320FF87FEF6B7FEF6B7F0FFE0EDFDE18CFF
                HEX 8CE1FF9BD8FF5555FFCAEFCCEFC6E6FF0F0C0D0D0C0D0D97
                HEX 07018B0C0F8B970606899706118B0C0F
                DB  $FF

;-----------------------------------------------------------
