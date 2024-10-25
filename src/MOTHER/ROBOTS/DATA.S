PUTON           LDY COUNTER
LETPNT          LDA LETR0,Y
                LDY XHOLD
                STA (SCREENL),Y
                INC COUNTER
                RTS

LETOFF          DW  LETR0
                DW  LETR1
                DW  LETR2
                DW  LETR3
                DW  LETR4
                DW  LETR5
                DW  LETR6
                DW  LETR7
                DW  LETR8
                DW  LETR9
                DW  LETRY
                DW  LETRE
                DW  LETRS
                DW  LETRN
                DW  LETRO
                DW  LETRX
                DW  LETR

POINTAT         ASL
                TAY
                LDA POINTS,Y
                STA VALUEL
                LDA POINTS+1,Y
                STA VALUEH
                LDA POINTS+2,Y
                CLC
                SBC VALUEL
                STA NUMTYPE
                RTS

POINTS          DW  ATSLOTS
                DW  SRANGES
                DW  HESS
                DW  HPSS
                DW  UPREFS
                DW  BESS
                DW  BPSS
                DW  ECAPS           ;Must be ECAPS
                DW  0
                DW  ECAPS
                DW  LOWREFS
                DW  PROGS
                DW  ASTARTS
                DW  DUMMY

TEXTER          TYA
                ASL
                TAY
                LDA TEXTS,Y
                STA POINTL
                LDA TEXTS+1,Y
                STA POINTH
                JMP TEXTOUT

TEXTS           DW  TEXT0
                DW  TEXT1
                DW  TEXT2
                DW  TEXT3
                DW  TEXT4
                DW  TEXT5
                DW  TEXT6
                DW  TEXT9
                DW  TEXT7
                DW  TEXTC
                DW  TEXTB
                DW  TEXT8
                DW  TEXTA
                DW  0
                DW  TEXTE
                DW  TEXT11
                DW  TEXTF
                DW  TEXT14
                DW  TEXT13
                DW  TEXT10
                DW  TEXT12
                DW  TEXT15
                DW  TEXT16
                DW  TEXT17
                DW  TEXT18
                DW  TEXT19
                DW  TEXT1A
                DW  TEXT1B
                DW  TEXT1C
                DW  TEXT1D
                DW  TEXT1E
                DW  TEXT1F
                DW  TEXT20
                DW  TEXT21
                DW  0
                DW  TEXT23
                DW  TEXT24
                DW  TEXT25
                DW  0
                DW  TEXT27
                DW  TEXT28
                DW  TEXT29
                DW  TEXT2A
                DW  TEXT2B
                DW  TEXT2C
                DW  TEXT2D
                DW  TEXT2E
                DW  TEXT2F
                DW  TEXT30
                DW  TEXT31
                DW  TEXT32
                DW  TEXT33

LINER           TYA
                ASL
                TAY
                LDA LINES,Y
                STA POINTL
                LDA LINES+1,Y
                STA POINTH
                JMP LINEOUT

LINES           DW  LINE0
                DW  LINE1
                DW  LINE2X
                DW  LINE3
                DW  LINE4
                DW  LINE5
                DW  LINE6
                DW  LINE7
                DW  LINE8
                DW  LINE9
                DW  LINEA
                DW  LINEB
                DW  LINEC
                DW  LINED
                DW  LINEE
                DW  LINEF
                DW  LINE10
                DW  LINE11
                DW  LINE12
                DW  LINE13
                DW  LINE14
                DW  LINE15

TEXT0           PictTextAt 60;2;"HEADS"
                PictTextAt 126;35;"BODIES"
                PictTextAt 191;2;"WEAPONS"
                PictTextAt 188;45;"PROGRAMS"
                PictTextAt 60;45;"ENERGY"
                PictTextAt 120;78;"MOVEMENT"

TEXT1           PictTextAt 68;113;"AVAILABLE OPTIONS ARE:"
                PictTextAt 86;124;"REPLACE ROBOT PARTS"
                PictTextAt 86;135;"BUY A COMPLETE ROBOT"
                PictTextAt 86;144;"SELL A COMPLETE ROBOT"
                PictTextAt 86;155;"LEAVE"

TEXT2           PictTextAt 16;185;"CANCEL"

TEXT3           PictTextAt 59;93;"WHICH CYBERNATE WILL THIS NEW"
                PictTextAt 83;102;"ROBOT BE ASSIGNED TO?"

; TEXT4           PictTextAt 37;2;"PLEASE TURN TO THE RIGHT "

; TEXT5           PictTextAt 80;55;"PLEASE STEP CLOSER "

; TEXT6           PictTextAt 65;94;"WHOSE CREDITS WILL BE USED?"
;                 PictTextAt 14;109;"PROF"
;                 PictTextAt 58;109;"NAME"
;                 PictTextAt 114;109;"CREDITS"
;                 PictTextAt 16;177;"POOLED CREDITS"

TEXT7           PictTextAt 30;35;"BODIES"
                PictTextAt 17;56;"UPPER"
                PictTextAt 14;64;"REFLEX/STRENGTH"
                PictTextAt 130;56;"ELECTRICAL"
                PictTextAt 133;64;"SHIELDING"
                PictTextAt 219;56;"PHYSICAL"
                PictTextAt 216;64;"SHIELDING"
TEXT29          PictTextAt 146;131;"25/25"
                PictTextAt 188;131;"E:10 P:10"

TEXT8           PictTextAt 22;35;"MOVEMENT"
                PictTextAt 131;57;"LOWER"
                PictTextAt 128;65;"REFLEX"
                PictTextAt 181;57;"MOVEMENT"
                PictTextAt 193;65;"TYPE"
                PictTextAt 191;81;"TREAD"
TEXT2C          PictTextAt 146;169;"TREAD"
                PictTextAt 212;169;"LR:20"

TEXT9           PictTextAt 29;2;"HEADS"
                PictTextAt 14;56;"ATTACHMENT"
                PictTextAt 32;64;"SLOT"
                PictTextAt 97;56;"SIGHT"
                PictTextAt 97;64;"RANGE"
                PictTextAt 144;56;"ELECTRICAL"
                PictTextAt 147;64;"SHIELDING"
                PictTextAt 219;56;"PHYSICAL"
                PictTextAt 216;64;"SHIELDING"
TEXT28          PictTextAt 146;111;"2"
                PictTextAt 146;120;"NO"
                PictTextAt 188;120;"E:4  P:5"

TEXTA           PictTextAt 20;2;"PROGRAMS"
                PictTextAt 127;56;"PROGRAM"
                PictTextAt 133;64;"LEVEL"
                PictTextAt 197;56;"AUTO-"
                PictTextAt 197;64;"START"
TEXT2D          PictTextAt 146;180;"LEVEL 1"

TEXTB           PictTextAt 28;2;"ENERGY"
                PictTextAt 139;57;"ENERGY CAPACITY"
TEXT2B          PictTextAt 146;160;"1000/3000"

TEXTC           PictTextAt 23;2;"WEAPONS"
                PictTextAt 142;53;"ROBO-DAGGER"
                PictTextAt 142;61;"ROBO-SWORD"
                PictTextAt 142;69;"ROBO-BLASTER C"
                PictTextAt 142;77;"ROBO-BLASTER B"
                PictTextAt 142;85;"ROBO-BLASTER A"
                PictTextAt 142;93;"NOTHING"

TEXTE           PictTextAt 172;14;"PRICE:"

TEXTF           PictTextAt 106;14;"ROBOT BODY"

TEXT10          PictTextAt 118;14;"MOVEMENT"

TEXT11          PictTextAt 106;14;"ROBOT HEAD"

TEXT12          PictTextAt 124;14;"PROGRAM"

TEXT13          PictTextAt 100;14;"ENERGY SUP."

TEXT14          PictTextAt 130;14;"WEAPON"

TEXT15          PictTextAt 100;4;"AVAILABLE CREDITS:"

TEXT16          PictTextAt 62;111;"SIGHT RANGE:"
                PictTextAt 74;120;"HEAD SLOT:"
                PictTextAt 74;131;"BODY TYPE:"
                PictTextAt 68;142;"WEAPON <L>:"
                PictTextAt 68;151;"WEAPON <R>:"
                PictTextAt 56;180;"PROGRAM CARD:"
                PictTextAt 50;160;"ENERGY SUPPLY:"
                PictTextAt 50;169;"MOVEMENT TYPE:"

TEXT17          PictTextAt 205;107;"C>ANCEL"

TEXT18          PictTextAt 191;81;"TREAD"
STOP18          PictTextAt 146;169;"TREAD"

TEXT19          PictTextAt 179;81;"LEVITATOR"
STOP19          PictTextAt 146;169;"LEVITATOR"

TEXT1A          PictTextAt 179;81;"TETRA-LEG"
STOP1A          PictTextAt 146;169;"TETRA-LEG"

TEXT1B          PictTextAt 188;81;"BI-LEG"
STOP1B          PictTextAt 146;169;"BI-LEG"

TEXT1C          PictTextAt 59;98;"REPLACE PARTS ON WHICH ROBOT?"

TEXT1D          PictTextAt 32;89;"YOU HAVE OVERSPENT BY "
                PictTextAt 56;98;"WHAT AREA DO YOU WANT TO REDO?"

TEXT1E          PictTextAt 50;126;"YOUR ROBOT IS BEING REGISTERED"
                PictTextAt 50;135;"UNDER THE NAME "
ROBOT_NAME      USR (ROBOT-   1.)

TEXT1F          PictTextAt 116;126;"IS BEING"
                PictTextAt 116;126;"HAS BEEN"
                PictTextAt 50;148;"YOU CAN PICK THE ROBOT UP AT THE"
                PictTextAt 50;157;"GROUP ASSEMBLY OFFICE AND CHANGE"
                PictTextAt 50;166;"ITS NAME TO WHAT EVER YOU WISH."
                PictTextAt 188;179;"<SPACE>"

TEXT20          PictTextAt 44;89;" IS WORTH "
TEXCRED         USR (00000000 CREDITS)
                PictTextAt 50;98;"PRESS <SPACE> TO SELL IT"

TEXT21          PictTextAt 50;98;"WHICH ROBOT DO YOU WANT TO SELL?"

TEXT23          PictTextAt 89;94;"REPLACE WHICH PART?"

TEXT24          PictTextAt 188;120;"E:   P:"
                PictTextAt 188;131;"E:   P:"
                PictTextAt 212;169;"LR:"
                PictTextAt 158;131;"/"
                PictTextAt 146;160;"1000/"
                PictTextAt 146;180;"LEVEL"

TEXT25          PictTextAt 100;24;"TOTAL ROBOT PRICE:"

TEXT27          PictTextAt 57;89;" HAS EQUIPMENT THAT"
                PictTextAt 57;98;"MUST BE SOLD AT THE ARSENAL"

TEXT2A          PictTextAt 41;89;"YOU HAVE OVERSPENT BY "
TEXOVER         USR (00000000 CREDITS-)
                PictTextAt 41;98;"SELECT AN AREA TO BE REDONE"

TEXT2E          PictTextAt 31;89;"PRESS <SPACE> TO VERIFY ROBOT PURCHASE"
                PictTextAt 61;98;"OR A>DJUST TO CHANGE AN AREA"

TEXT2F          PictTextAt 57;93;"SELECT AN AREA TO BE ADJUSTED"

TEXT30          PictTextAt 48;114;"AN ABLE BODIED CYBERNATE MUST BE"
                PictTextAt 48;124;"PRESENT TO MAKE ANY TRANSACTIONS"
                PictTextAt 48;134;"HERE AT THE ROBOT ORDERING AND"
                PictTextAt 48;144;"REPLACEMENT CENTER."
                PictTextAt 198;155;"<SPACE>"

TEXT31          PictTextAt 133;37;">>TOO EXPENSIVE<<"

TEXT32          PictTextAt 118;24;"MINUS TRADE-IN:"

TEXT33          PictTextAt 205;107;"<SPACE>"




LINE0           PictMoveTo $29;$00
                PictLineTo $29;$2B
                PictLineTo $6F;$2B
                PictLineTo $6F;$00
                ; DB  $FE
                PictMoveTo $2A;$2B
                PictLineTo $2A;$00
                PictLineTo $70;$00
                PictLineTo $70;$2B
                PictEnd

LINE1           PictMoveTo $6F;$00
                PictLineTo $6F;$2B
                PictLineTo $B1;$2B
                PictLineTo $B1;$00
                ; DB  $FE
                PictMoveTo $70;$2B
                PictLineTo $70;$00
                PictLineTo $B2;$00
                PictLineTo $B2;$2B
                PictEnd

LINE2X          PictMoveTo $B1;$00
                PictLineTo $B1;$2B
                PictLineTo $F5;$2B
                PictLineTo $F5;$00
                ; DB  $FE
                PictMoveTo $B2;$2B
                PictLineTo $B2;$00
                PictLineTo $F6;$00
                PictLineTo $F6;$2B
                PictEnd

LINE3           PictMoveTo $29;$2B
                PictLineTo $29;$56
                PictLineTo $6F;$56
                PictLineTo $6F;$2B
                ; DB  $FE
                PictMoveTo $2A;$56
                PictLineTo $2A;$2B
                PictLineTo $70;$2B
                PictLineTo $70;$56
                PictEnd

LINE4           PictMoveTo $6F;$2B
                PictLineTo $6F;$56
                PictLineTo $B1;$56
                PictLineTo $B1;$2B
                ; DB  $FE
                PictMoveTo $70;$56
                PictLineTo $70;$2B
                PictLineTo $B2;$2B
                PictLineTo $B2;$56
                PictEnd

LINE5           PictMoveTo $B1;$2B
                PictLineTo $B1;$56
                PictLineTo $F5;$56
                PictLineTo $F5;$2B
                ; DB  $FE
                PictMoveTo $B2;$56
                PictLineTo $B2;$2B
                PictLineTo $F6;$2B
                PictLineTo $F6;$56
                PictEnd

LINE6           PictRect $28;$6B;$F6;$BF
                PictEnd

LINE7           PictRect $01;$73;$115;$B7
                PictMoveTo $01;$7D
                PictLineTo $115;$7D
                PictEnd

LINE8           PictRect $21;$00;$C3;$0A
                PictEnd

LINE9           PictRect $49;$34;$CD;$40
                PictEnd

LINEA           PictRect $01;$6B;$115;$AF
                PictMoveTo $01;$75
                PictLineTo $115;$75
                PictEnd

LINEB           PictRect $5D;$00;$10D;$22
                PictEnd

LINEC           PictRect $0D;$00;$53;$2B
                PictEnd

LINED           PictRect $0D;$00;$4F;$2B
                PictEnd

LINEE           PictRect $09;$00;$4D;$2B
                PictEnd

LINEF           PictRect $7A;$32;$F2;$66
                PictEnd

LINE10          PictMoveTo $C8;$6B
                PictLineTo $C8;$73
                PictLineTo $F6;$73
                PictEnd

LINE11          PictMoveTo $C7;$6B
                PictLineTo $F6;$6B
                PictLineTo $F6;$73
                PictEnd

; *** heavily modified ***
LINE12          PictMoveTo $00;$36
                PictLineTo $00;$36
                PictLineTo $00;$48
                PictLineTo $00;$48
                PictLineTo $00;$36
                PictEnd

LINE13          PictRect $7A;$36;$EE;$5E
                PictMoveTo $80;$4A
                PictLineTo $E8;$4A
                PictEnd

LINE14          PictRect $86;$36;$E8;$56
                PictMoveTo $8C;$42
                PictLineTo $E2;$42
                PictEnd

LINE15          PictRect $28;$6B;$F6;$A8
                PictEnd



LETR0           DB  $D0,$8A
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D0
                DB  $8A
LETR1           DB  $80,$8A
                DB  $80,$8A,$C0
                DB  $8A,$C0,$8A
                DB  $C0,$8A,$80
                DB  $8A,$80,$8A
                DB  $80,$8A,$80
                DB  $8A,$80,$8A
                DB  $80,$8A,$80
                DB  $8A,$C0,$AA
                DB  $C0,$AA,$C0
                DB  $AA
LETR2           DB  $D0,$8A
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $80,$A8,$80
                DB  $A8,$D0,$AA
                DB  $D4,$AA,$D4
                DB  $8A,$94,$80
                DB  $94,$80,$94
                DB  $80,$D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA
LETR3           DB  $D0,$8A
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $80,$A8,$80
                DB  $A8,$C0,$AA
                DB  $C0,$8A,$C0
                DB  $AA,$80,$A8
                DB  $80,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D0
                DB  $8A
LETR4           DB  $94,$A8
                DB  $94,$A8,$94
                DB  $A8,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA,$80,$A8
                DB  $80,$A8,$80
                DB  $A8,$80,$A8
                DB  $80,$A8,$80
                DB  $A8
LETR5           DB  $D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA,$94,$80
                DB  $94,$80,$94
                DB  $80,$D4,$8A
                DB  $D4,$AA,$D4
                DB  $AA,$80,$A8
                DB  $80,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D0
                DB  $8A
LETR6           DB  $D0,$8A
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $94,$80,$94
                DB  $80,$D4,$8A
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D0
                DB  $8A
LETR7           DB  $D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $80,$A8,$80
                DB  $A8,$80,$A8
                DB  $80,$8A,$80
                DB  $8A,$C0,$82
                DB  $C0,$82,$C0
                DB  $82,$C0,$82
                DB  $C0,$82,$C0
                DB  $82
LETR8           DB  $D0,$8A
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D0,$8A,$D4
                DB  $AA,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D0
                DB  $8A
LETR9           DB  $D0,$8A
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D0
                DB  $AA,$80,$A8
                DB  $80,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D0
                DB  $8A

DIGITS_PIC
                ; horizontal
                DB  $00,$00,$14,$0F
                HEX 8050545414A15454500A2A2A28A12A2A0A00004089009940
                HEX 890AAD2A8997000000009F000054899F02002A2A0A00892A
                HEX 899F080097050297000B9F0B000A9F0B0214955489009528
                HEX 952AA7020154A708079F0C092A890089A70B00A709069F00
                HEX 09971606AF17049718069F0407959F13060A0A02959F1900
                HEX 509F1908BF0F00A71800509F1409A71A069F2308
                DB  $FF

                ; vertical
                DB  $00,$00,$02,$96
                HEX 8050545414A1545450000040890099408997000000009F00
                HEX 0054899F001E97011197000B14955489009554A700259F00
                HEX 36A701249F00099700609F0016959F015A509F0162A7005A
                HEX 509F00540A2A2A28A12A2A0AB12A899F02002A2A0A0089AF
                HEX 021B0A9F032028952AA702012A890089A7031E970251AF03
                HEX 4F9F03420A0A0295BF032DA702609F0380
                DB  $FF


LETRY           DB  $94,$A8
                DB  $94,$A8,$94
                DB  $A8,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA,$80,$A8
                DB  $80,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA
LETRE           DB  $D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $94,$80,$94
                DB  $80,$D4,$82
                DB  $D4,$82,$D4
                DB  $82,$94,$80
                DB  $94,$80,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA
LETRS           DB  $D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $94,$80,$94
                DB  $80,$D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA,$80,$A8
                DB  $80,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA


LETRN           DB  $94,$A8
                DB  $94,$A8,$94
                DB  $A8,$D4,$A8
                DB  $D4,$A8,$D4
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA,$94,$AA
                DB  $94,$AA,$94
                DB  $AA,$94,$A8
                DB  $94,$A8,$94
                DB  $A8
LETRO           DB  $D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$94,$A8
                DB  $94,$A8,$94
                DB  $A8,$D4,$AA
                DB  $D4,$AA,$D4
                DB  $AA


LETRX           DB  $80,$80
                DB  $80,$80,$80
                DB  $B8,$80,$BC
                DB  $80,$BE,$80
                DB  $9F,$C0,$8F
                DB  $E0,$87,$F0
                DB  $83,$F8,$81
                DB  $FC,$80,$BC
                DB  $80,$9C,$80
                DB  $80,$80,$80
                DB  $80

SLASH_PIC       DB  $00,$00,$02,$0F
                HEX 800095406070787C3C1C00000000383C3E1F0F0703010091
                DB  $FF

LETR            DB  $80,$80
                DB  $80,$80,$80
                DB  $80,$80,$80
                DB  $80,$80,$80
                DB  $80,$80,$80
                DB  $80,$80,$80
                DB  $80,$80,$80
                DB  $80,$80,$80
                DB  $80,$80,$80
                DB  $80,$80,$80
                DB  $80

EMPTY_PIC       DB  $00,$00,$02,$0F
                HEX 8000B900B9
                DB  $FF


ATSLOTS         DB  $FF,$AA
SRANGES         DB  $02,$03
                DB  $04,$05,$06
                DB  $07
HESS            DB  $04,$08
                DB  $12,$16
HPSS            DB  $05
                DB  $10,$15
UPREFS          DB  $25,$30
                DB  $35,$40,$45
                DB  $50,$55,$60
                DB  $65,$70,$75
                DB  $80,$85,$90
                DB  $95
BESS            DB  $10,$15
                DB  $20,$25,$30
                DB  $40,$50,$60
BPSS            DB  $10,$15,$20
                DB  $25,$30,$40
                DB  $50,$60,$70
                DB  $80
ECAPS           DB  $83,$86,$89
                DB  $92,$95,$03
                DB  $05,$07,$10
                DB  $12,$15,$17
                DB  $20,$22,$25
                DB  $27,$30,$32
                DB  $35,$37,$40
LOWREFS         DB  $20,$25
                DB  $30,$35,$40
                DB  $45,$50,$55
                DB  $60,$65,$70
                DB  $75,$80,$85
                DB  $90,$95
PROGS           DB  $01
                DB  $02,$03,$04
                DB  $05,$06,$07
                DB  $10
                DB  $15,$20,$25
                DB  $30,$35,$40
                DB  $45,$50,$55
                DB  $60,$65,$70
                DB  $75
ASTARTS         DB  $FF,$AA
DUMMY           DB  $00

SLT             DB  $00,$00,$00
                DB  $00,$50,$00
SR              DB  $00,$00,$10
                DB  $00,$08,$00
                DB  $00,$80,$00
                DB  $04,$00,$00
                DB  $08,$00,$00
                DB  $12,$50,$00
ESH             DB  $00,$00,$15
                DB  $00,$30,$00
                DB  $01,$50,$00
                DB  $05,$00,$00
PSH             DB  $00,$00,$15
                DB  $00,$40,$00
                DB  $02,$00,$00
URS             DB  $00,$00,$20
                DB  $00,$04,$00
                DB  $00,$20,$00
                DB  $00,$60,$00
                DB  $01,$20,$00
                DB  $02,$00,$00
                DB  $03,$50,$00
                DB  $05,$50,$00
                DB  $09,$00,$00
                DB  $13,$00,$00
                DB  $18,$00,$00
                DB  $23,$00,$00
                DB  $30,$00,$00
                DB  $38,$50,$00
                DB  $50,$00,$00
ESB             DB  $00,$00,$20
                DB  $00,$05,$00
                DB  $00,$20,$00
                DB  $01,$00,$00
                DB  $04,$00,$00
                DB  $08,$00,$00
                DB  $13,$00,$00
                DB  $21,$00,$00
PSB             DB  $00,$00,$20
                DB  $00,$05,$00
                DB  $00,$20,$00
                DB  $01,$00,$00
                DB  $02,$00,$00
                DB  $03,$00,$00
                DB  $05,$00,$00
                DB  $09,$00,$00
                DB  $14,$00,$00
                DB  $20,$00,$00
WEA             DB  $00,$00,$60
                DB  $00,$03,$00
                DB  $00,$01,$00
                DB  $00,$02,$20
                DB  $00,$90,$00
                DB  $00,$00,$00
                DB  $01,$00,$00
EC              DB  $00,$00,$50
                DB  $00,$02,$00
                DB  $00,$07,$50
                DB  $00,$20,$00
                DB  $00,$40,$00
                DB  $00,$60,$00
                DB  $01,$00,$00
                DB  $01,$75,$00
                DB  $02,$75,$00
                DB  $04,$50,$00
                DB  $06,$50,$00
                DB  $09,$00,$00
                DB  $11,$50,$00
                DB  $15,$00,$00
                DB  $19,$00,$00
                DB  $25,$00,$00
                DB  $30,$00,$00
                DB  $36,$00,$00
                DB  $42,$00,$00
                DB  $48,$00,$00
                DB  $50,$00,$00
LR              DB  $00,$00,$40
                DB  $00,$04,$00
                DB  $00,$15,$00
                DB  $00,$40,$00
                DB  $00,$80,$00
                DB  $01,$20,$00
                DB  $02,$00,$00
                DB  $03,$50,$00
                DB  $05,$50,$00
                DB  $09,$00,$00
                DB  $13,$00,$00
                DB  $18,$00,$00
                DB  $23,$00,$00
                DB  $30,$00,$00
                DB  $38,$50,$00
                DB  $50,$00,$00
PRO             DB  $00,$00,$20
                DB  $00,$00,$80
                DB  $00,$01,$20
                DB  $00,$01,$70
                DB  $00,$02,$30
                DB  $00,$02,$90
                DB  $00,$03,$70
                DB  $00,$07,$50
                DB  $00,$20,$00
                DB  $00,$40,$00
                DB  $00,$60,$00
                DB  $01,$00,$00
                DB  $01,$75,$00
                DB  $02,$75,$00
                DB  $04,$50,$00
                DB  $06,$50,$00
                DB  $09,$00,$00
                DB  $11,$50,$00
                DB  $15,$00,$00
                DB  $19,$00,$00
                DB  $25,$00,$00
AUT             DB  $00,$00,$00
                DB  $00,$50,$00
