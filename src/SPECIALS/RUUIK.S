
; TODO: make Ruuik's equipment demands random/scalable
; TODO: randomize password and green net code, save in game state

RIFLE_TOTAL     =   $C0

                DUMMY SCRATCH_PAGE
RIFTABL         DS  16,0
                DEND

RUUIK           JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictImage RU_MAIN_PIC
                PictCall MIRROR_SIDE
                PictImage RU_INSERT_PIC
                PictImage RU_KILROY_PIC
                PictShowPage
                PictSetPage1
                PictClearPage
                PictSetBlue
                PictRect $36;$00;$E2;$27
                PictTextAt_ 60;3
                TXC "I AM RUUIK, SUPREME EMPEROR\n"
                TXC "OF THIS PLANET. DO YOU SEEK\n"
                TXC "THE SECRET CODE NUMBER TO\n"
                TXT "THE GREEN NET BARRIERS? "
                PictSwap $07;$00;$21;$2A
                PictSetPage2
                PictEnd

                JSR GET_INPUT_KEY
:ASK_YN1        CMP #"Y"
                BEQ YESWANT
                CMP #"N"
                BEQ NOWANT
                JSR REGET_INPUT
                JMP :ASK_YN1

NOWANT          JSR DRAW_PICT
                PictImage RU_HAND_DOWN
                PictEnd
                JMP FSCREEN

YESWANT         JSR DRAW_PICT
                PictImage RU_HAND_DOWN
                PictClear $08;$01;$20;$27
                PictTextAt_ 60;3
                TXC "IN EXCHANGE FOR THE CODE, I\n"
                TXT "DEMAND FOUR LIGHT RIFLES."
                PictEnd

                JSR RIFLER
                LDX #0              ;***
                CPX #$FF
                BNE CSCREEN

BSCREEN         JSR DRAW_PICT
                PictTextAt_ 60;21
                TXC "SINCE YOU DON'T HAVE THEM,\n"
                TXT "I SUGGEST YOU GO GET SOME!"
                PictEnd

                LDY #$14
                JSR RU_WAITER
                JMP FSCREEN

CSCREEN         JSR DRAW_PICT
                PictTextAt_ 60;21
                TXC "I SEE THAT YOU HAVE THEM.\n"
                TXT "IS IT A DEAL? "
                PictEnd

                BIT UNSTROB
                JSR GET_INPUT_KEY
:ASK_YN2        CMP #"Y"
                BEQ YESIS
                CMP #"N"
                BEQ NOIS
                JSR REGET_INPUT
                JMP :ASK_YN2

NOIS            JMP ESCREEN

YESIS           JSR DRAW_PICT
                PictClear $08;$01;$20;$27
                PictTextAt 60;5;"I KNEW YOU WOULDN'T REFUSE!"
                PictTextAt 60;16;"THE NET CODE IS GN-28 AND"
                PictTextAt 60;27;"THE ROYAL PASSWORD IS CRUU"
                PictSetOrange
                PictMoveTo $9B;$18
                PictLineTo $B9;$18
                PictMoveTo $BF;$23
                PictLineTo $D7;$23
                PictMoveTo $D8;$1B
                PictEnd

                BIT UNSTROB
                JSR GET_INPUT_KEY
                JSR REMOVE_RIFLES
                JMP FSCREEN

ESCREEN         JSR DRAW_PICT
                PictClear $08;$01;$20;$27
                PictTextAt 60;5;"THEN YOU NEED THE RIFLES"
                PictTextAt 60;15;"MORE THAN I DO..."
                PictEnd

                LDY #$04
                JSR RU_WAITER
                BIT UNSTROB

                JSR DRAW_PICT
                PictTextAt 114;27;"GUARDS!!!"
                PictEnd

                ; generate an encounter with RUUIKs MEN
                ;
                ; LDA #$23
                ; STA ALIEN1
                ; LDA #$08
                ; STA HMANY1
                ; LDA #$42
                ; STA ALTYPE1
                ; LDA #$FF
                ; STA ALIEN2
                ; STA ALIEN3

;****************************************
; TODO: figure out how this is related to giving Ruuiks men the password
            do  0
                LDX #$05
XXLOOP          LDA XXDATA,X
                STA $1194,X
                DEX
                BPL XXLOOP
            fin
;****************************************

                ; turn away from King Ruuik to give background for encounter
                ;
                ; LDA #$0F
                ; STA DIRECTN
                ; JSR GETNSEW

                JSR DRAW_PICT
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

;****************************************
; TODO: figure out how this is related to giving Ruuiks men the password
            do  0
                LDA #$77
                STA SSTOREH
                LDA #$00
                STA STRACK
                STA SSECTOR
                LDA #$19
                STA READNUM
                LDA #$11
                PHA
                LDA #$93
                PHA
                JMP SREADIT

AFTMANY         EQU $7706           ;IN FIGHT LOADER
RUUSTOP         EQU $791B           ;IN FIGHT LOADER

XXDATA          DFB $CE
                DW  RUUSTOP-1
                DFB $4C
                DW  AFTMANY
            else
                SEC
                RTS                     ; return to halls
            fin
;****************************************

FSCREEN         JSR DRAW_PICT
                PictClear $08;$01;$20;$27
                PictTextAt_ 60;3
                TXC "I HAVE NO OTHER INFORMATION\n"
                TXC "FOR YOU, SO LEAVE MY DOMAIN\n"
                TXC "WITH YOUR LIVES BEFORE I\n"
                TXT "CHANGE MY MIND!"
                PictEnd

                LDY #$16
                JSR RU_WAITER

                JSR DRAW_PICT
                PictSwap $07;$00;$21;$2A
                PictEnd

                JSR TURN_AWAY
                JSR DRAW_PICT
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                SEC
                RTS                     ; return to halls

TURN_AWAY       LDA KEYBRD
                BPL TURN_AWAY
                JSR CHECK_TURN
                BEQ :1
                BIT UNSTROB
                JMP TURN_AWAY
:1              RTS

RU_WAITER       BIT UNSTROB
:1              LDA #$00
                JSR WAIT_KEY
                BNE :2
                DEY
                BPL :1
:2              RTS
;
; find rifles across all characters
;
RIFLER          LDA #$00
                STA COUNT
                STA RIFLE_TOTAL
RILOOP1         LDA #$00
                STA COUNTER
                LDA COUNT
                JSR SET_CHAR
                LDY #status
                LDA (CHARDL),Y
                CMP #compressd
                BEQ RISKIP2
RILOOP2         LDA COUNTER
                JSR CORCALC
                LDA (CHARDL),Y
                AND #$7F
                CMP #$4D
                BNE RISKIP1
                INY
                LDA (CHARDL),Y
                DEY
                CMP #$00
                BNE RISKIP1
                LDA RIFLE_TOTAL
                ASL A
                TAX
                LDA COUNT
                STA RIFTABL,X
                INX
                TYA
                STA RIFTABL,X
                INC RIFLE_TOTAL
                LDA RIFLE_TOTAL
                CMP #$04
                BEQ RIFLOUT
RISKIP1         INC COUNTER
                LDA COUNTER
                CMP #$0A
                BNE RILOOP2
RISKIP2         INC COUNT
                LDA COUNT
                CMP GRPNUMB
                BNE RILOOP1
                LDX #$FF
                RTS
RIFLOUT         LDX #$00
                RTS
;
; remove all found rifles
;
REMOVE_RIFLES   LDX #$07
:1              STX COUNTER
                LDA RIFTABL-1,X
                JSR SET_CHAR
                LDX COUNTER
                LDA RIFTABL,X
                JSR REMOVE
                LDX COUNTER
                DEX
                DEX
                BPL :1
                RTS
;
; remove one of the found rifles
; TODO: use common function like REMOVE_ITEM
;
REMOVE          STA SCRATCH
                TAY
                CMP #$4D
                BCC SINGLE
                CPY #$61
                BEQ SINGLE
                LDY #profrace
                LDA (CHARDL),Y
                BPL NOTSING
                LDY SCRATCH
                CPY #$4D
                BEQ SINGLE
NOTSING         LDY #back
                LDA (CHARDL),Y
                CLC
                ADC #$03
                JSR CORCALC
                CLC
                ADC #$04
                STA ENDLINE
                LDY SCRATCH
                BNE SNEAKY
SLIDES          LDA (CHARDL),Y
                DEY
                DEY
                DEY
                DEY
                STA (CHARDL),Y
                INY
SNEAKY          INY
                INY
                INY
                INY
                CPY ENDLINE
                BNE SLIDES
                TYA
                SEC
                SBC #$04
                TAY
SINGLE          LDX #$04
                LDA #$FF
ERASEM          STA (CHARDL),Y
                INY
                DEX
                BNE ERASEM
                RTS
CORCALC         ASL
                ASL
                CLC
                ADC #$3D
                TAY
                RTS

MBITS           =   LOCAL_TEMP+0
MCARRY          =   LOCAL_TEMP+1

MIRROR_SIDE     LDX #$00
:1              STX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #$00
                STY MCARRY
:2              LSR MCARRY
                LDA (SCREENL),Y
                BNE :3
                BCC :4
:3              STY COLUMN
                TAX
                ROL
                ASL
                ROL MCARRY
                ASL
                ROR MBITS
                ASL
                ROR MBITS
                ASL
                ROR MBITS
                ASL
                ROR MBITS
                ASL
                ROR MBITS
                ASL
                ROR MBITS
                ASL
                ROR MBITS
                ASL
                ROR MBITS
                LDA #$27
                SEC
                SBC COLUMN
                TAY
                TXA
                AND #$80
                ORA MBITS
                STA (SCREENL),Y
                LDY COLUMN
:4              INY
                CPY #$14
                BNE :2
                LDX LINENUM
                INX
                CPX #192
                BNE :1
                RTS

RU_KILROY_PIC   DB  $00,$75,$03,$1C
                HEX 8304C0C08080882068202090404060894081804083118080
                HEX 82828888547D4759677D257554545C8954433F475F435F40
                HEX 552C2C2E2A2A2B8D2A896A913A912E912B
                DB  $FF

RU_HAND_DOWN    DB  $10,$72,$04,$1E
                HEX 0602030101887F8801010302060440797C7D2C8908825581
                HEX 80A17F81809182406070687E39070F1B03635142528180A1
                HEX 4F6070787C7E7F1F0F07034101034246044C5C4717208982
                HEX 788270707E7F913F7E8D7C037E2A2A28220A0A027A
                DB  $FF

RU_INSERT_PIC   DB  $0F,$4D,$0A,$44
                HEX 8401010306050D0B1B376F771658095D0556025701558255
                HEX 408B752035101D080D04050603030141404060277C312163
                HEX 4346050C0D18153075822908698B082901967F2A822A822A
                HEX 781A1C36664243010140406020301018080C040406020301
                HEX 01883F880101030206040C7F8255826E826E825582967F55
                HEX 825582557F8A01017F01964456897E6E7D037E7840927F18
                HEX 1232326252425282967F2A822A822A7F8A40401110508B40
                HEX 408E01011D0F0382437F897C608C4001034246044C5C4717
                HEX 40967F55825582557F882A02282A323030600A2A4A084828
                HEX 208D827882707E7F953F7F8D7C037E2A2A28220A0A027A82
                HEX 967F2A822A822A7F88554015554C0D0C0750555310131505
                HEX 8D821F820F0F1F7F7F7E727D7E3F8D0F701F155545115454
                HEX 501740967F55825582557F8A020208080A8B02029C790307
                HEX 0F1F3F7F7C787060408297031C0E787A82967F2A822A822A
                HEX 7F8697021A3F30604040A07F8C0103055F67787C36303223
                HEX 0B012A82967F558255825507560E5B19503060604040419F
                HEX 0234080818103020604089827F849F031A82076F0F4D0D4D
                HEX 045182558297113158686C74767B7D3B1A46646E681A103A
                HEX 206A406A822A822B012B022E042C0828183097112741794F
                HEX 6321313018280C2C062A032B822A822A822A406A60
                DB  $FF

RU_MAIN_PIC     DB  $00,$01,$14,$BF
                HEX 7E2A957E2E2E3A3E6E6E2E893A956A952AA12E2C89282838
                HEX 30892020604089FEB2408960202030303828282C892E2A95
                HEX 6A913A912E916A7A2EA70000847F55957F559557577D0D1D
                HEX 893589758997020C915D95759555A157568954545C588950
                HEX 507060894089E24040608970505058585C54545689575599
                HEX 75915D91579197029335351D894D4D074707077FA703057F
                HEX 847F2A957F2A9D7F843E30067E8278185879017133337306
                HEX 46060E4E0E1A899701146B8D2B2B2E95BF01112B8DCF0024
                HEX 9297018E309F01942EA70448C700A22B6B8D9704841A1A0E
                HEX 896666036303795958788276363676827F616C7F847FA705
                HEX 057F84A703009D7F847F431B7F826F0C616F827B435B5B82
                HEX 7F6C6C7F823682363E827C0C607C0171013333032747474D
                HEX 6D89758959899F039B55B575358915151D0D8907061E7207
                HEX 05050D0D1D151535357555A9A7021E595975896D6D674747
                HEX 33333171016C6C0C6C821F43587F8277363076826D6D617D
                HEX 825F1B435B823F06307F84AF03B284C70500847F6D0C7D82
                HEX 3E36363F826F61212F825656466E606F333337383A3A2C2D
                HEX 2C97048C95AF009D2A2A3A1A890A0A0E068902020301899E
                HEX 011F70960189030206890E0A97042797093E2A952B912E97
                HEX 04503B383835356F606F40585B8237303077827F6C617F82
                HEX 5F435B5F84AF05B284AF0600158955896F606076895A585B
                HEX 5D89970289BF074875A7065A05050703890189BA831680C0
                HEX C0E0A0B0D888CCA7D7A6CC88D8D0B0E0C0C08080A2970873
                HEX 03AF0666BF076F56895C5C5A897075716D6D40405F1515A7
                HEX 0A00847F2A952F9F09322A9DDF0840C680008D970A601018
                HEX 4C24562A03292A91002A558B2A002A9129012B56244C2818
                HEX 3020970B6F00ACAF0873800ACF097E2B2A957F84970BB5AF
                HEX 0658A70B38DC8000970A5E305058686C666A2B2929282929
                HEX 686993682995B70F58A70F652828292B6A66646C6850970C
                HEX 790000BC970B85A70A899F0A92807F84010303060C081810
                HEX 30604040DAAF0C50800C1416131515141417150E3A0E1417
                HEX 5555158D17140E3A0E1017159597115814B7115EAF106B38
                HEX 0E5417151415151312160C0818109F0A6E00BE804060380C
                HEX 07018496970C99040C9F1006BC801038684C06020301017E
                HEX 0014051497103A406030101897123F0301010099971240A5
                HEX A7135A0F7840C7135901010306040C08970D789712749712
                HEX 84740C087830AC830560301C060388404010AC97120B8307
                HEX 0C081830206040AA00000103060C18303F10180C04971239
                HEX 0089C697056A83041F781850971213A40089010103020697
                HEX 108D3F380F0100A4830560301C07018620200808020089C0
                HEX 8001010306049F151A40EA97146E50480C74767A7B610E7E
                HEX 7F7F7E611F700F7E7E7D017B76746C0858971628A280008D
                HEX A09F10B78240401004049F13514040D8A7130B80206040BC
                HEX 404060305058686C461A3B7D7D70670F3F7F7E7863971965
                HEX 431F7F7F7C433E611F7F7E401F7F7F827F897E017D7B7A76
                HEX 0C6858971575AA9713B382802020080A0200959715B70200
                HEX 00EE970D989F17258E97156D8018286C747673654D1E3E7C
                HEX 7973674F1F3F7C7973471F3F7E78634F1F7F7C71071F5F5E
                HEX 60277717580F7C0D5B1B70376F6E405F3F3F827F8D827F89
                HEX 1F407E7D7B3A06746C5850971A3F8A6020380E038041A716
                HEX B24040109F16B39DFE86971720800E1A13352E6E5F5F3F3E
                HEX 7C7D971A5A5F1E3C971B5A3E3C3953476F2E30133B0B2C04
                HEX 2E022B012B822A822A406A607F606A402A822A822A012B03
                HEX 2A062D0D2B18373727605F5F1F03787F7F1F47717C7F7E3D
                HEX 5D633E0E8003219F19AD9F19B79D208908890202FEFEA483
                HEX 0D55035606540C5B1B776739CED3971AB2AF1BAF40891089
                HEX 04B71AB3FEFEA4802A822A822A822A822A7F8002A71CA9A7
                HEX 1CB70200B1208D0808FEFEA4805582558255825582557F80
                HEX 01AF1FAF4091108D04448D4151511151505454045454FEFE
                HEX A48052509B52431454558000088D228D28280828280A2A89
                HEX 02970D6289970D6B002A2AFEFEA480548254825482548254
                HEX 7E8680000055018B5555005555009727A39726AA9F27AA8D
                HEX 005555
                DB  $FF
