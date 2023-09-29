
; TODO: clean up zpage usage
LNUMB1          =   $01
LNUMB2          =   $02
; COUNTER       =   $03
; SCRATCH       =   $04
ENDLINE         =   $06
; LINENUM       =   $07
MHOLDER         =   $08
; COUNT         =   $96

DEAD_GROUP      JSR SET_DEAD_STATUS

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictSetWhite1
                PictMoveTo $00;$5F
                PictLineTo $117;$5F
                PictMoveTo $00;$1C
                PictLineTo $10A;$1C
                PictMoveTo $12;$00
                PictLineTo $12;$5D
                PictMoveTo $2F;$00
                PictLineTo $2F;$5D
                PictImage HALL_LINES
                PictCall ORANGE_LINES
                PictImage CORNERS
                PictSetBlue
                PictFillRect $4D;$75;$F5;$79
                PictSetWhite2
                PictMoveTo $4D;$73
                PictLineTo $F5;$73
                PictMoveTo $4D;$7B
                PictLineTo $F5;$7B
                PictImage MUG
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                JSR BEEP
                LDA #0
                JSR WAIT
                JSR BEEP
                JSR BUILD_SCREEN
                JSR SCROLL_SCREEN
                JSR FACE_FADER

                LDA #0
                STA COUNT
                JSR GO_TALK
                JSR BUILD_SCREEN
                JSR SHOW_EACH_STATS
                JSR FACE_FADER

                LDA #1
                STA COUNT
:1              JSR GO_TALK
                INC COUNT
                LDA COUNT
                CMP #$04
                BNE :1

                JSR BUILD_SCREEN
                DEC CLMOD1+2
                DEC CLMOD2+2
                JSR FADER
                JSR SET_PAGE1

;               LDA #side_MS
;               STA DISK_SIDE
;               LDA #$90
;               STA SSTOREH
;               LDX #<$00F0             ; MTESSINFO
;               LDY #>$00F0
;               LDA #6
;               JSR SLOADER
;               JMP $9000
                RTS

SET_DEAD_STATUS LDX #0
:1              STX CHAR_INDEX
                TXA
                JSR SET_CHAR
                LDY #status
                LDA (CHARDL),Y
                CMP #dead               ; Make dead and broken characters
                BEQ :2                  ;  into lost characters
                CMP #broken
                BNE :4
:2              LDY #miscflags          ; Auto-compress dead and broken
                LDX #compressd          ;  characters that have implants
                LDA (CHARDL),Y
                BMI :3
                LDX #lost
:3              TXA
                LDY #status
;               STA (CHARDL),Y
:4              CMP #compressd          ; Convert all compressed
                BNE :5                  ;  characters in group to
                LDA #intracc            ;  intracc status
;               STA (CHARDL),Y
                INC LOST_CHARS          ; Make another character findable
:5              LDX CHAR_INDEX
                INX
                ; NOTE: can't use NEXT_CHAR which is based on GROUP_SIZE
                CPX GRPCONT
                BNE :1
                RTS

ORANGE_LINES    LDX #$61
:1              JSR SET_SOURCE_LINE
                LDY #39
:2              LDA #$D5
                STA (SCREENL),Y
                DEY
                LDA #$AA
                STA (SCREENL),Y
                DEY
                BPL :2
                INX
                INX
                CPX #$C1
                BNE :1
                RTS

BEEP            LDX #$00
:1              STA CLICK
                LDA #$08
                JSR WAIT
                DEX
                BNE :1
                RTS

BUILD_SCREEN    JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictImage SCREEN
                PictSetBlack2
                PictMoveTo $4A;$08
                PictLineTo $102;$08
                PictSetWhite2
                PictMoveTo $50;$0D
                PictLineTo $D8;$0D
                PictMoveTo $50;$74
                PictLineTo $D8;$74
                PictEnd
                RTS

SCROLL_SCREEN   LDX #$74
:1              STX LINENUM
                JSR DRAW_SCREEN
                LDX LINENUM
                DEX
                DEX
                CPX #$02
                BNE :1
                RTS

DRAW_SCREEN     STX LNUMB1
                LDA #$04
                STA LNUMB2
SLOOP1          JSR SET_DEST_OFF
                LDX LNUMB2
                JSR SET_SOURCE_LINE
                LDY #$25
                CPX #$09
                BCC SLOOP2X
                LDA (DESTINL),Y
                ORA #$80
                AND #$FE
                STA (DESTINL),Y
SLOOP2X         DEY
                CPX #$08
                BCS SLOOP2
                LDA (DESTINL),Y
                AND TCDATA-4,X
                ORA (SCREENL),Y
                STA (DESTINL),Y
                DEY
SLOOP2          LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                CPY #$0A
                BNE SLOOP2
                LDX LNUMB1
                CPX #$76
                BCC NOBCORN
                LDA #$FF
                CPX #$79
                BNE NOTSKIP
                LDA #$FE
NOTSKIP         AND (SCREENL),Y
                STA (DESTINL),Y
                DEY
                LDA (SCREENL),Y
                AND BCDATA-118,X
                ORA (DESTINL),Y
                STA (DESTINL),Y
                JMP REMERGE
NOBCORN         LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                LDA (SCREENL),Y
                STA (DESTINL),Y
REMERGE         INC LNUMB2
                INC LNUMB1
                LDX LNUMB1
                CPX #$7A
                BNE SLOOP1
                LDX #$70
SLOWER          CPX LNUMB2
                BCC SCROUT
                LDA #$06
                JSR WAIT
                DEX
                BNE SLOWER
SCROUT          RTS

TCDATA          DB  $FF,$FC,$F0,$C0
BCDATA          DB  $F8,$E0,$80,$80

FACE_FADER      JSR DRAW_PICT
                PictImage GUY
                PictEnd
FADER           LDA #$08
                STA COUNTER
FLOOP1          LDA #$10
                STA LINENUM
FLOOP2          TAX
                JSR SET_DEST_OFF
                JSR SET_SOURCE_LINE
                TXA
                CLC
                ADC COUNTER
                AND #$07
                TAX
                LDY #$1E
FLOOP3          LDA (SCREENL),Y
                EOR (DESTINL),Y
                AND MASKS,X
                EOR (DESTINL),Y
                STA (DESTINL),Y
                INX
                TXA
                AND #$07
                TAX
                DEY
CLMOD1          LDA CLICK
CLMOD2          LDA CLICK
                CPY #$0A
                BNE FLOOP3
                LDA LINENUM
                CLC
                ADC #$05
                STA LINENUM
                CMP #$73
                BCC FLOOP2
                SEC
                SBC #$62
                STA LINENUM
                CMP #$15
                BNE FLOOP2
                DEC COUNTER
                BNE FLOOP1
                LDA #$BF                ; #>(CLICK-1), if assembler supported it
                STA CLMOD1+2
                STA CLMOD2+2
                RTS

MASKS           DB  $01,$10,$02
                DB  $20,$04,$40
                DB  $08,$80

TALKER          LDA #$10
                STA LINENUM
                LDA TEOFF,X
                STA COUNTER
TELOOP1         LDY COUNTER
                LDA TEDATA,Y
                STA SCRATCH
                BPL TESKIP1
                CMP #$FF
                BEQ TALKOUT
                CPY #$16
                BEQ DELAY
                CPY #$06
                BNE NODELAY
DELAY           PHA
                LDA #$00
                JSR WAIT_KEY
                PLA
NODELAY         AND #$7F
                STA SCRATCH
                LDA LINENUM
                TAX
                CLC
                ADC #$09
                STA LINENUM
                BNE TESKIP2
TESKIP1         LDA LINENUM
                TAX
                CLC
                ADC #$09
TESKIP2         STA ENDLINE
                INC SCRATCH
                TXA
                PHA
                JSR MOUTH_UP
                PLA
                TAX
                LDY COUNTER
                LDA TEDATA-1,Y
                BPL GOSTORE
                LDA #$FF
GOSTORE         STA TESMOD+1
TELOOP2         JSR SET_SOURCE_OFF
                JSR SET_DEST_LINE
TESMOD          LDY #$00
                INY
TELOOP3         LDA (DESTINL),Y
                STA (SCREENL),Y
                INY
                CPY SCRATCH
                BNE TELOOP3
                INX
                CPX ENDLINE
                BNE TELOOP2
                JSR MOUTH_DOWN
                INC COUNTER
                BNE TELOOP1
TALKOUT         RTS

TEOFF           DB  $00,$0C,$1A
                DB  $26
                DB  $FF                 ; must be here***???

TEDATA          DB  $04,$8F,$06
                DB  $0B,$8F,$05
                DB  $90,$05,$8D
                DB  $05,$0E,$FF

                DB  $08,$8F,$05
                DB  $0A,$90,$06
                DB  $0B,$90,$01
                DB  $0B,$8F,$04
                DB  $0F,$FF

                DB  $05,$8F,$03
                DB  $07,$8B,$03
                DB  $8E,$05,$8D
                DB  $06,$0C,$FF

                DB  $04,$0F,$13
                DB  $FF

mouthA          =   0
mouthB          =   1
mouthC          =   2

MOUTH_DOWN      LDY MHOLDER
                DEY
                JSR MUDSUB
                LDA MHOLDER
                CMP #mouthA
                BNE MOUTH_DOWN
MTOUT           RTS

MOUTH_UP        LDY #mouthB
                JSR MUDSUB
                JSR RANDOM
                BPL MTOUT
                LDY #mouthC
MUDSUB          STY MHOLDER

                DEY
                BPL :1
                JSR DRAW_PICT
                PictSetPage1
                PictImage MOUTHA
                PictSetPage2
                PictEnd
                BNE :3                  ; always
:1              DEY
                BPL :2
                JSR DRAW_PICT
                PictSetPage1
                PictImage MOUTHB
                PictSetPage2
                PictEnd
                BNE :3                  ; always
:2              JSR DRAW_PICT
                PictSetPage1
                PictImage MOUTHC
                PictSetPage2
                PictEnd
:3              LDA #$80
                JMP WAIT_KEY

SHOW_EACH_STATS LDX #0
:1              STX CHAR_INDEX
                TXA
                JSR SET_CHAR
                JSR DRAW_STATS
                LDA CHAR_INDEX
                BEQ :2
                JSR DRAW_PICT
                PictSetPage1
                PictCopyTo 13;22;30;108
                PictSetPage2
                PictEnd
                BNE :3                  ; always
:2              JSR FADER
:3              BIT UNSTROB
:KEYLOOP        LDA KEYBRD
                BPL :KEYLOOP
                BIT UNSTROB
                JSR CHECK_ENTER
                BNE :KEYLOOP
                LDX CHAR_INDEX
                INX
                ; NOTE: can't use NEXT_CHAR which is based on GROUP_SIZE
                CPX GRPCONT
                BNE :1
                JSR DRAW_PICT
                PictClear 13;22;30;108
                PictEnd
                RTS

DRAW_STATS      JSR DRAW_PICT
                PictClear 13;22;30;108
                PictSetTextHeight 9
                PictTextAt_ 100;22
                TXC "NAME:\n"
                TXC "PROF:\n"
                TXC "RACE:\n"
                TXC "EXPR:\n"
                TXT "LEVL:"
                PictMoveTo 136;22
                PictCall CNAME_TO_TEXT
                PictTextbufRet
                PictCall CPROF_TO_TEXT
                PictTextbufRet
                PictCall CRACE_TO_TEXT
                PictTextbufRet
                PictCall CEXP_TO_TEXT
                PictTextbufRet
                PictCall CLEVEL_TO_TEXT
                PictTextbufRet
                PictTextAt 116;75;"MISSING AND"
                PictTextAt 130;101;"<SPACE>"
                PictEnd
                LDY #status
                LDA (CHARDL),Y
                CMP #lost
                BEQ :1
                JSR DRAW_PICT
                PictTextAt 92;84;"PRESUMED COMPRESSED"
                PictEnd
                RTS
:1              JSR DRAW_PICT
                PictTextAt 110;84;"PRESUMED LOST"
                PictEnd
                RTS

GO_TALK         JSR CLEAR_PAGE

                LDX #$00
                LDA #$14
                JSR SET_LINE_BOUNDS
                JSR SAVE_PATCH

                LDX COUNT
                JSR DRAW_MESSAGE
                LDX COUNT
                JSR TALKER
                BIT UNSTROB

                LDY COUNT
                LDX WAITS,Y
:1              LDA #$C0
                JSR WAIT_KEY
                BMI :2
                DEX
                BPL :1
:2              BIT UNSTROB

RESTORE_PATCH   LDX #$10
:1              JSR SET_DEST_OFF
                JSR SET_SOURCE_LINE
                LDA SCREENL
                ORA #$14
                STA SCREENL
                JSR COPY_LINE
                INX
                CPX #$3D
                BNE :1
                RTS

SAVE_PATCH      LDX #$10
:1              JSR SET_SOURCE_OFF
                JSR SET_DEST_LINE
                LDA DESTINL
                ORA #$14
                STA DESTINL
                JSR COPY_LINE
                INX
                CPX #$3D
                BNE :1
                RTS

WAITS           DB  $0D,$0D,$0D,$03

DRAW_MESSAGE    DEX
                BPL :1
                JSR DRAW_PICT
                PictTextAt_ 0;17
                TXC "TRACC INTELLIGENCE\n"
                TXC "DIVISION HERE, MR.\n"
                TXC "LELVK.  INFORMATION\n"
                TXC "ON THE FOLLOWING\n"
                TXT "CADETS JUST IN..."
                PictEnd
                RTS
:1              DEX
                BPL :2
                JSR DRAW_PICT
                PictTextAt_ 0;17
                TXC "THE DEATHS WILL BE\n"
                TXC "ENTERED HERE SO THE\n"
                TXC "COMPUTER FILES WILL\n"
                TXC "BE UP TO DATE.  OF\n"
                TXT "COURSE YOU WILL..."
                PictEnd
                RTS
:2              DEX
                BPL :3
                JSR DRAW_PICT
                PictTextAt_ 0;17
                TXC "INFORM NEXT OF KIN\n"
                TXC "THAT THEY HAVE\n"
                TXC "BEEN POSTHUMOUSLY\n"
                TXC "AWARDED THE T.F.\n"
                TXT "MEDAL OF HONOR."
                PictEnd
                RTS
:3              JSR DRAW_PICT
                PictTextAt_ 0;17
                TXT "TRACC INTELLIGENCE OUT."
                PictEnd
                RTS

HALL_LINES      DB  $26,$00,$02,$5E
                HEX 4089208D10910891048D0291019102950491089110952091
                HEX 4095BCFE82FF001A
                DB  $FF

CORNERS         DB  $07,$73,$04,$09
                HEX 8302E5808E83057F8FBCF0CA8883097F80AAA9A79EF9E095
                HEX 7F8000558D54037F
                DB  $23,$73,$04,$09
                HEX 807F402A9100817F28030E3965155500817F8851071C707F
                HEX 8C2A0023
                DB  $FF

MOUTHA          DB  $14,$50,$02,$0E
                HEX 7B5B7B7B3B3707776F895F5F5E7F6F7D7F7737823D5D5F5F
                HEX 6D6F6F
                DB  $FF

MOUTHB          DB  $14,$50,$02,$0F
                HEX 5B7B7B3B3307896F895F5F5E3E6F7D7F77378180895D5D5F
                HEX 6F6D6F77
                DB  $FF

MOUTHC          DB  $14,$50,$02,$0E
                HEX 7B7B3B330307890F6F6F5F5F5E7D7F773781808D405D5D6F
                HEX 6F6D
                DB  $FF

MUG             DB  $03,$85,$0C,$3B
                HEX 8880156035584D4C3676767B91830BE61C7C6C2C2C3EF3CB
                HEX BBFBF984627C1F677B7D8981130E79077F95830BF8473D75
                HEX 5555577C639FFFF1830585F09F607F8D83098F50154481FF
                HEX C0BFFF9580601F7A2A893F70800F7FED830DF09FE0FF716A
                HEX 6A31802A28222A82A7050D40803F7555897F60801F7FE97F
                HEX 007F807F8D8255451155504580007F007F9900807F2A8D83
                HEX 037F80FFE91F202F1F7F716A0A202A0A22220AB7080E558D
                HEX 970A0FE57E017D7E7F894015555514541580603F407F953F
                HEX 80409708196AF70B1E830781FF80716A6A71807F97070840
                HEX 7F82BF0B117789379D77077FB9830CD481BFF0CFBFFFFFFE
                HEX 6115059706009583109FE03F2B2A2A6ABFC1FC87F8F38EB9
                HEX E797061F7C433E611F7FB18428030F3E6D5B1B1B6C77797E
                HEX 970C14830EDF67795E5755753D4FF39CE7F8FF8D7E79671C
                HEX 734F3F7F78473C635F5F3FA58C5401530356064D0D8B5603
                HEX 538B03570D4C0C4C0D4B064D1B376F5F9706107C7B766D6D
                HEX 5B5B5A59595BA5C02A002903260D1B1B37C9
                DB  $FF

SCREEN          DB  $09,$04,$1C,$76
                HEX 8028220A2AFDFDFDD555895451FDFDFDD12AA51AFDFDFDA1
                HEX 2A9555A5FECE55952AA5FECE2A9555A5FECE55952AA5FECE
                HEX 2A9555A5FECE55952AA5FECE2A9555A5FECE55952AA5FECE
                HEX 2A9555A5FECE55952AA5FECE2A9555A5FECE55952AA5FECE
                HEX 2A9555A5FECE55952AA5FECE2A9555A5FECE55952AA5FECE
                HEX 2A9555A5FECE55952AA5FECE2A9555A58160FDFDFDA15595
                HEX 2AFDFDFDE155AD7F7F2FD97F2FD9EF2E0DD52E7D559D2AAD
                HEX 7F7F5555017E7F3F2FAD3C79055555CF300D2E3DE73021F7
                HEX 31212A9D55AD7F7F2A2A0097300C5545954141973209002A
                HEX 2AA7330D0015150000540400CF331E01151510C733351514
                HEX 8900150505A7324E559D2AAD1F7F555554534F5E5AAD5E4F
                HEX 50973153E73410F73510AD9F34502A9D0001051555FDFDFD
                HEX D1
                DB  $FF

GUY             DB  $0C,$10,$13,$63
                HEX BE7FB47F94830D7F8080BFF3EDF3BF808015802897004E83
                HEX 0380158089282A99BE7FAA303060895F823060408C830D7F
                HEX 8080C0EEEAEEC080802A805197024E8305802A808055A1BE
                HEX 7FA6607018607870611D030B0C7F8C7F84830A9FB9B6B99F
                HEX 808054802297044E97005B822A9DBE7F02C982736F897340
                HEX 3F4262301F82028D827F845C5C205C5C8428818005405054
                HEX 55B5BE7FA61E7F7F675B6D767B7D7C78760E76786C6C827F
                HEX 843B3B443B3B822029282AA9022A95884040508D549555A1
                HEX 14145414895150501010970A1B9F0B0E548803070F0F1F1F
                HEX 5F1F3F89823F8D827F847777081740559115954545555540
                HEX 15559120080A02894040608D7095728962624A4A2A2A6828
                HEX 8B682A6A8B970C1C282A4A896262707078A17B7070604088
                HEX 202027202028A52AA9822A918420282AA13A8D3B913F897F
                HEX 7F7DB37FA57B7B778D7B897D8D7C7D798D75896565555515
                HEX 5591458D158D970A2C01558D8254559D7599778D7FA1801F
                HEX 67777B3B897B77671F807F9D777763637FA5077B5B7B7B3B
                HEX 3707776F895F5F5E3E3C7C7A7A72726A0A2A89970C502097
                HEX 1056822AB12E2E6E9D7E7E7F8D80601F3F787589783F1F60
                HEX 807F917D7D78383F1D1D78787F9D827F6F7D7F7737823D5D
                HEX 5F5F6D6F6F77707F893F3F5F405599154550555582011555
                HEX 955DAD7D957F8D807F7F7E917F807FAD7E3E970E169D7E91
                HEX 3F891F1F2F2F272B2B29292A0A8D228D97105A822A8D1040
                HEX 408202020A0A1A8D970F12911F1F4F4F57575DB357574F89
                HEX 1F1F3F3F7F9F12187E893D3D1D0D010504041414970E57D1
                HEX 019711018497160428AD2A99222228208928A719172A9528
                HEX 943E8281809D827F8281806E6E826008289122950A0A2A2A
                HEX 0A202A9194019505A1019581FC88AF1B0A01800091555045
                HEX 1555A98283087F80801D1DC061C080051555B1825595BE81
                HEX FF40B182802A28022A89002A892802024242020242930081
                HEX 7F0000785F5551155F78848303420A2ABDBE7F9281408D82
                HEX 558954411500558D84830219198483111F808AD08A807F80
                HEX FEABA88AA8AAA2ABFE821908088041971B4E05559DBE81FF
                HEX 8870180C06030188802A95202A8D84803333843F828303D0
                HEX 8AD0827F80007F5554755F5554557F823311113B84830502
                HEX 6202282A9DBE7F887F9255A984806666847E828303828082
                HEX 8283177F80809FFAABAAAAFA9F8080E6A2A2F780D580DDD0
                HEX 05559D60F981EF608D81EF60A181EAA96060646460606460
                HEX 658B606F806064606163676361606460606A68896A606B6B
                HEX 608060626A95
                DB  $FF
