
VARIATION       =   $C0

VIEWPORT_MOD    DB  modViewport

DO_AIRLOCK      JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictSetBlack1
                PictMoveTo $43;$66
                PictLineTo $55;$66
                PictImage ALET          ; and INFINT, LLET
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd
                BIT UNSTROB
KEYER           LDA KEYBRD
                BPL KEYER
                JSR CHECK_TURN
                BEQ NOLSOUT
                JSR CHECK_UP
                BNE KEYER
                ;***SUCKED OUT!!!!
                BEQ KEYER           ;TEMP
NOLSOUT         SEC
                RTS                     ; return back to halls

VP_IS_OPEN      DB  $00                 ; TODO: move this
;
; On entry:
;   A: SPECIAL_DIR bits
;
DO_VIEWPORT     STA VARIATION
                BIT VARIATION
                BVC :LR_ONLY

:HAS_CENTER     JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictSetWhite1
                PictMoveTo $00;$01
                PictLineTo $116;$01
                PictMoveTo $00;$66
                PictLineTo $116;$66
                PictMoveTo $00;$BD
                PictLineTo $116;$BD
                PictMoveTo $15;$01
                PictLineTo $15;$BD
                PictMoveTo $101;$01
                PictLineTo $101;$BD
                PictImage MPORT         ; and WRITING, BUTTONS
                PictEnd
                JSR COPY_TOP
                LDA VP_IS_OPEN
                BEQ :COMMON
                JSR DRAW_PICT
                PictImageFill STARST    ; and STARSB
                PictEnd
                JMP :COMMON

:LR_ONLY        JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictEnd

:COMMON         BIT VARIATION
                BPL :NO_LEFT
                JSR DRAW_PICT
                PictImage LPORT         ; left port picture
                PictEnd

:NO_LEFT        LDA VARIATION
                AND #%00100000
                BEQ :NO_RIGHT
                JSR DRAW_PICT
                PictImage RPORT         ; right port picture
                PictEnd

:NO_RIGHT       JSR DRAW_PICT
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                BIT VARIATION
                BVC VP_NOASK
                LDA VP_IS_OPEN
                BNE VP_NOASK

VP_ASK          JSR DRAW_PICT
                PictTextAt $20;$06;(NO_ONE_CAN_TRANSLATE_THE_WRITING._DO)
                PictTextAt $20;$0F;(YOU_WANT_TO_TRY_PRESSING_BUTTONS?_)
                PictEnd

                JSR GET_INPUT_KEY
RECHECK         CMP #"Y"
                BEQ YES
                CMP #"N"
                BEQ NO
                JSR REGET_INPUT
                JMP RECHECK

NO              JSR DRAW_PICT
                PictClear 4;6;36;22     ; clear message
                PictEnd
                SEC
                RTS                     ; return back to halls

YES             JSR ANIMATE
                LDA #$FF
                STA VP_IS_OPEN
VP_NOASK        LDA KEYBRD
                BPL VP_NOASK
                JSR CHECK_TURN
                BNE VP_NOASK
                SEC
                RTS                     ; return back to halls

ENDLINU         =   LOCAL_TEMP+0
ENDLIND         =   LOCAL_TEMP+1

ANIMATE         JSR DRAW_PICT
                PictClear 4;6;36;22     ; clear message
                PictSetPage2
                PictClearPage
                PictImage STARST        ; and STARSB
                PictSetPage1
                PictEnd

                LDX #$06
                LDA #$22
                JSR SET_LINE_BOUNDS

                LDA #$58
                STA ENDLINU
                LDA #$74
                STA ENDLIND

UDLOOP          JSR GOUP1
                JSR GODOWN1
                INC ENDLIND
                DEC ENDLINU
                LDA ENDLIND
                CMP #$96
                BNE UDLOOP
                JSR UWINDOW
                JMP DWINDOW

GODOWN1         LDX #$95+1
:1              DEX
                JSR SET_SOURCE_LINE
                INX
                JSR SET_DEST_LINE
                JSR COPY_LINE
                DEX
                CPX ENDLIND
                BNE :1
DWINDOW         LDX ENDLIND
:2              JSR ASUB
                DEX
                CPX #$73
                BNE :2
                RTS

GOUP1           LDX #$37-1
:1              INX
                JSR SET_SOURCE_LINE
                DEX
                JSR SET_DEST_LINE
                JSR COPY_LINE
                INX
                CPX ENDLINU
                BNE :1
UWINDOW         LDX ENDLINU
:2              JSR ASUB
                INX
                CPX #$59
                BNE :2
                RTS

ASUB            LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                EOR #$60
                STA SCREENH
                LDY #$06
:1              LDA (SCREENL),Y
                STA (DESTINL),Y
                STA CLICK
                STA CLICK
                INY
                CPY #$22
                BNE :1
                RTS

; replicate lines $2E through $60 to $6C through $9E

COPY_TOP        LDX #$04
                LDA #$24
                JSR SET_LINE_BOUNDS
                LDX #$2E
:1              JSR SET_SOURCE_LINE
                LDA LOBYTES+$3E,X
                STA DESTINL
                LDA HIBYTES+$3E,X
                STA DESTINH
                JSR COPY_LINE
                INX
                CPX #$61
                BNE :1
                RTS

MPORT           DB  $04,$2E,$20,$33
                HEX 80542404FBC324542A55007D3C6D2C2DFB9B2C6D3C7D0055
                HEX 2A552A007F5555577D4D4D6DB34D0D4DC704084D7D575555
                HEX 7F002A552A55827F2A897F3B3B7FB33B003BC706083B9707
                HEX 0382552A552A827F55897F77777FB3770077C70808779709
                HEX 03822A552A558297072B6E6E6F8B6E7F93970B09006EC70A
                HEX 086E970B0382552A552A8297092B5D5D7FB35D005DC70C08
                HEX 5D970D03822A552A5582EF0703B39F062A82552A552A82EF
                HEX 0903B39F082A822A552A55829F0B037FB3970B177FB39F0B
                HEX 2982552A552A82EF0D03B39F0C2A822A552A5582EF0F03B3
                HEX 9F0E2A82552A552A829F1003957F937791007799AF180E9F
                HEX 102A822A552A5582EF1303B39F122A82552A552A82EF1503
                HEX B39F142A822A552A5582EF1703B39F162A82552A552A82EF
                HEX 1103B39F182A822A552A5582EF1B03B39F1A2A82552A552A
                HEX 82EF1D03B39F1C2A822A552A55829F1F037B8B9F1F239726
                HEX 0A971E18BF260A9F1E2A82552A552A82EF2103B39F202A82
                HEX 2A552A5582EF2303B39F222A82552A552A82EF2503B39F24
                HEX 2A822A552A5582EF1F03B39F262A82552A552A82EF2903B3
                HEX 9F282A822A552A5582EF2B03B39F2A2A82552A552A829F2D
                HEX 037D8B9F2D2397340A972C18BF340A9F2C2A822A552A5582
                HEX EF2F03B39F2E2A82552A552A82EF3103B39F302A822A552A
                HEX 55007F2A6A3A2F2CBF031E912DB32C2C2F3A6A2A7F00552A
                HEX 552A002F0F2D0DFBA32D0F2F002A550A0908FBC3090A
                ; chain
WRITING         DB  $0B,$22,$13,$0A
                HEX 80555505654565350555552A2A003F711833002A2A555500
                HEX 3663361C0055552A2A007C5F0C6F002A2A5555007D197B1F
                HEX 0055552A2A007E607F18002A2A555500406060400055552A
                HEX 2A000F46764D002A2A555500765D43790055552A2A006C7F
                HEX 413F002A2A5555007C6E47430055552A2A00367133971206
                HEX 5555005B1F4E370055552A2A004377437E002A2A55550003
                HEX 0603070055559712007C7C6C002A2A5555005D387E610055
                HEX 552A2A282B282829282A2A94
                ; chain
BUTTONS         DB  $0F,$62,$0A,$09
                HEX 508D53508D2A2A026289022A2A5555825D898255552A2A82
                HEX 3B89822A2A55558277898255552A2A826E89822A2A555582
                HEX 5D898255552A2A823B89822A2A55554047894055550A8D4A
                HEX 0A8D
                DB  $FF

LPORT           DB  $00,$2E,$02,$71
                HEX 80552A003F3D3735FD9D373D3F002A550091817F00919F01
                HEX 00FD9D9F002D2A2520FBC3252A96970300FBBB252A
                DB  $FF

RPORT           DB  $26,$2E,$02,$71
                HEX 80552901FBC3295596970100FBBB29552A15003F2F3B2BFD
                HEX 9D3B2F7F00552A0091813F00919F0300FD9D9F022D
                DB  $FF

STARST          DB  $06,$36,$1C,$23
                HEX 818DFD8D8A40BA8801A4800800A1820000CD406030080402
                HEX 00A100A901067C9106030100B5848104008D4030180C0603
                HEX 0191030400AD810800008A020100A18108A4AC4098A08004
                HEX 96088C8481909C01A2C69A088620A29020AE2084A2408C01
                HEX 94C68440A481849408848283045450A080BC828306522AD5
                HEX AAD080B420828283074A25AAA9CAD5A09201880298822A80
                HEX 252A528955B68283072A29A5A49494D492800896048A8283
                HEX 084949292529158080B48283081214290A01808001B48281
                HEX 85970C0688202854242A4A521428209E8C018605122A2A52
                HEX 524A2915058840948E01B6C02084802C9D2D2CE5
                ; chain
STARSB          DB  $06,$74,$1C,$23
                HEX 800DD54D4D9700138D0D8D9C81088E2A2A3535555A5A262A
                HEX 25695582AC00053555555A2A2B892A2A82848104AC00050A
                HEX 15806A2D2D2A2D82A608940103050582AC04988C8182B420
                HEX 828000A520B08681088C00AA8002048202C48000C9106089
                HEX 30180402009D00BD20100C0603890400A98E8020B02084A2
                HEX 08A28A08A80890C6A008A48A209802A0C68610B0028C9C60
                HEX 3080408E029400A1406080765B5C565755A482308C8306AA
                HEX AAEA3F2A6A892A9E088490818182555501015554A6942A2A
                HEX 2082020A88049C94010515860886089CBE0486802CF52E2C
                HEX 8D
                DB  $FF

ALET            DB  $12,$2E,$05,$23
                HEX 80282A2A0AA92A8D97010AB1555500B1A7020001AD2A2A00
                HEX B1970400C115555450A95455970601BD00FD8D
                ; chain
INFINT          DB  $0A,$56,$15,$21
                HEX 80008D406070787C7C7E7E7FA17E7E7C7C78706040008D00
                HEX 60787F1F0F0703018900A9018903070F1F7F7C60007E7F07
                HEX 00E9077F7E1F7F4000E9407F1F000F7F7000E1707F0F0097
                HEX 041B3F7000D1703F9704020091031F784000B940781F0300
                HEX 91009901073C7000A9703C0701009900A5030F7860009160
                HEX 780F0300A500B1971016701E0300B100B56038970E18B500
                HEX A940789F12121EB70D0700A1703E0700A1073E7000A10095
                HEX 607C0F0100B1010F7C600095A71805C99F1915004078970A
                HEX 1CD5073F784000607F0F00E90F7F607F7F00F17F7F031F7F
                HEX 7897001BCD4097020103971E190F1F3F7E7C8978A97C897E
                HEX 3F1F0F971410009D0101030307A10303AF0209
                ; chain
LLET            DB  $12,$7E,$04,$23
                HEX 800AD12AB12800D501A9555500F9892A2A00F9891515
                DB  $FF
