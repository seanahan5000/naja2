; enter with page 1 visible

ENERGY_CENTER   JSR DRAW_PICT
                PictSetPage1
                PictClear $0C;$07;$1D;$18
                PictTextAt 87;8;"PLEASE STEP FORWARD"
                PictTextAt 87;16;"INTO CUBICLE FIVE "
                PictEnd

                JSR GET_INPUT_KEY
                CMP #$9B                ; escape
                BNE :1
                JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictShowPage
                PictEnd
                JMP LEAVE_ENERGY

:1              JSR DRAW_PICT
                PictSetPage2
                PictShowPage
                PictEnd

                LDA #$00
                STA BCURSOR

MAIN1           JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictEnd

                LDA #$BB
                STA BUYSELL
                JSR DRAW_GROUP
                JSR FADE_GROUP

REPEAT1         JSR DRAW_PICT
                PictSetPage2
                PictTextAt 30;4;"WHO IS MAKING AN ENERGY TRANSACTION?"
                PictTextAt 120;14;"L>EAVE"
                PictEnd
                JSR RESET_CHRLIST
                JSR WHO_MENU
                PHP
                JSR DRAW_PICT
                PictClear 4;4;35;21
                PictEnd
                PLP
                BCS NOLEAVE
                JMP LEAVE_ENERGY

NOLEAVE         LDA CURSOR
                STA BCURSOR
                STA WHO_MDEF+1

                JSR DRAW_PICT
                PictSetPage1
                PictCall FADE_GROUP
                PictClearPage
                PictTextAt 26;182;"<SPACE>-FINISH TRANSACTION     C>ANCEL"
                PictCall DRAW_VLINS
                PictEnd

                LDY #$B4
                JSR DRAW_HLIN
                LDY #$BE
                JSR DRAW_HLIN

                JSR SET_PAGE2

                LDA #$BF
                STA ENDLINE
                LDA #$B3
                STA FADEMOD+1
                JSR GFADE2
                LDA #$79
                STA FADEMOD+1

                JSR DRAW_PICT
                PictTextAt 40;0;"NAME"
                PictTextAt 127;0;"ENERGY"
                PictTextAt 211;0;"CREDITS"
                PictTextAt 106;17;"100000"
                PictTextAt 232;17;"1000"
                PictEnd

                LDX #$63
                JSR DRAW_PLUS_MINUS
                LDX #$E1
                JSR DRAW_MINUS_PLUS

                LDA BCURSOR
                JSR SET_CHAR
                JSR CNAME_TO_TEXT
                LDX #$16
                LDY #$09
                JSR DRAW_TEXTBUF_XY

                JSR DRAW_PICT
                PictTextAt 92;75;"BUY"
                PictEnd

                JSR SETSUP
KEYLOOP         LDA KEYBRD
                BPL KEYLOOP
                BIT UNSTROB
                JSR CHECK_ENTER
                BEQ ENTER
                JSR CHECK_LEFT
                BEQ LEFT
                JSR CHECK_RIGHT
                BEQ RIGHT
                JSR CHECK_CANCEL
                BEQ CANHALF
                JSR CHECK_UP
                BNE NOWDUP
                JMP WEEDUP
NOWDUP          JSR CHECK_DOWN
                BNE KEYLOOP
                JMP WEEDWN
RIGHT           LDA ECURSOR
                BEQ RIGNOR
                DEC ECURSOR
                BNE NMATR
                BIT BUYSELL
                BVC NMATR
                INC ECURSOR
                BNE RIGNOR
NMATR           JSR NUM_CURSOR
RIGNOR          JMP KEYLOOP
LEFT            LDA ECURSOR
                CMP #$03
                BEQ LIGNOR
                INC ECURSOR
                JSR NUM_CURSOR
LIGNOR          JMP KEYLOOP

ENTER           LDX #3
:1              LDA CRCUR,X
                STA GROUP_CREDITS,X
                DEX
                BPL :1

                LDA #$FF
                LDX BCURSOR
                STA DIRTY_CHARS,X
                STA DIRTY_STATE
                TXA
                JSR SET_CHAR

                LDY #energylev+2
                LDX #2
:2              LDA ENCUR,X
                STA (CHARDL),Y
                DEY
                DEX
                BPL :2

CANHALF         JSR DRAW_PICT
                PictClear $03;$00;$25;$18
                PictEnd
                LDA BUYSELL
                CMP #$BB
                BNE SELERAS
                JSR DRAW_PICT
                PictTextAt 92;75;"BUY"
                PictEnd
                JMP GOMAIN1
SELERAS         JSR DRAW_PICT
                PictTextAt 89;75;"SELL"
                PictEnd
GOMAIN1         LDA #$BF
                STA ENDLINE
                LDA #$B3
                STA FADEMOD+1
                JSR GFADE2
                LDA #$79
                STA FADEMOD+1
                ; force cursor to next member
                LDX WHO_MDEF+1
                INX
                CPX GRPNUMB
                BNE :1
                LDX #0
:1              STX WHO_MDEF+1
                JMP MAIN1

WEEDUP          BIT BUYSELL
                BVC GOUBUY
                JMP UPSELL
GOUBUY          JMP UPBUY
WEEDWN          BIT BUYSELL
                BVC GODBUY
                JMP DNSELL
GODBUY          JMP DNBUY

UPBUY           LDA #$00
                STA CHNFLAG
LOOP1           LDY ECURSOR
                LDA CROFF1,Y
                CLC
                ADC #$03
                TAY
                LDX #$03
                SEC
SUBCR1          LDA CRCUR,X
                SED
                SBC CRDATA1,Y
                STA CRTEMP,X
                CLD
                DEY
                DEX
                BPL SUBCR1
                BCC BADCOM1
                JSR ADDSUB
                LDA BCURSOR
                JSR SET_CHAR
                LDY #energymax+2
                LDX #$02
                SEC
OVCAP           LDA ENTEMP,X
                SED
                SBC (CHARDL),Y
                STA ENTEMP2,X
                CLD
                DEY
                DEX
                BPL OVCAP
                BCC GOGCM1
                LDA ENTEMP2
                ORA ENTEMP2+1
                ORA ENTEMP2+2
                BEQ GOGCM1
                SEC
                LDA ENTEMP2+2
                SED
                SBC #$00
                LDA ENTEMP2+1
                SBC #$01
                LDA ENTEMP2
                SBC #$00
                CLD
                BCS BADCOM1
                LDY #energymax+2
                LDX #$02
LEVLER          LDA (CHARDL),Y
                STA ENTEMP,X
                DEY
                DEX
                BPL LEVLER
GOGCM1          JMP GOODCM1
BADCOM1         LDA ECURSOR
                BEQ GOKEYL
                DEC ECURSOR
                JSR NUM_CURSOR
                JMP LOOP1
GOKEYL          JMP KEYLOOP

DNBUY           LDY ECURSOR
                LDA CROFF1,Y
                CLC
                ADC #$03
                TAY
                LDX #$03
                CLC
ADDCR1          LDA CRCUR,X
                SED
                ADC CRDATA1,Y
                STA CRTEMP,X
                CLD
                DEY
                DEX
                BPL ADDCR1
                JSR SUBSUB
                BCC NOGOOD2
                JSR LEVSUB
                BCS GOODCM2
NOGOOD2         JSR ORIGIN
                JSR NEWENER
                LDA #$CC
                STA BUYSELL
                JSR DRAW_PICT
                PictTextAt 92;75;"BUY"
                PictTextAt 89;75;"SELL"
                PictEnd
                JSR NUM_CURSOR
                JMP KEYLOOP
GOODCM2         JSR NEWENER
                JMP KEYLOOP

UPSELL          LDY ECURSOR
                LDA CROFF5,Y
                CLC
                ADC #$03
                TAY
                LDX #$03
                SEC
SUBCR5          LDA CRCUR,X
                SED
                SBC CRDATA5,Y
                STA CRTEMP,X
                CLD
                DEY
                DEX
                BPL SUBCR5
                JSR ADDSUB
                BCS NOGOOD3
                JSR LEVSUB
                BCC GOODCM3
NOGOOD3         JSR ORIGIN
                JSR NEWENER
                LDA #$BB
                STA BUYSELL
                JSR DRAW_PICT
                PictTextAt 89;75;"SELL"
                PictTextAt 92;75;"BUY"
                PictEnd
                JSR NUM_CURSOR
                JMP KEYLOOP
GOODCM3         JSR NEWENER
                JMP KEYLOOP

DNSELL          LDA #$00
                STA CHNFLAG
LOOP2           LDY ECURSOR
                LDA CROFF5,Y
                CLC
                ADC #$03
                TAY
                LDX #$03
                CLC
ADDCR5          LDA CRCUR,X
                SED
                ADC CRDATA5,Y
                STA CRTEMP,X
                CLD
                DEY
                DEX
                BPL ADDCR5
                BCS BADCOM2
                JSR SUBSUB
                BCC BADCOM2
                LDA ENTEMP
                ORA ENTEMP+1
                ORA ENTEMP+2
                BEQ BADCOM2
                JMP GOODCM1
BADCOM2         LDA ECURSOR
                CMP #$01
                BEQ GOKEYL2
                DEC ECURSOR
                JSR NUM_CURSOR
                JMP LOOP2
GOKEYL2         JMP KEYLOOP
GOODCM1         LDA CHNFLAG
                BEQ NOCHNG
                JSR NUM_CURSOR
                JMP KEYLOOP
NOCHNG          JSR NEWENER
                JMP KEYLOOP

ADDSUB          LDY ECURSOR
                LDA ENOFF,Y
                CLC
                ADC #$02
                TAY
                LDX #$02
                CLC
:1              LDA ENCUR,X
                SED
                ADC ENDATA,Y
                STA ENTEMP,X
                CLD
                DEY
                DEX
                BPL :1
                RTS

SUBSUB          LDY ECURSOR
                LDA ENOFF,Y
                CLC
                ADC #$02
                TAY
                LDX #$02
                SEC
:1              LDA ENCUR,X
                SED
                SBC ENDATA,Y
                STA ENTEMP,X
                CLD
                DEY
                DEX
                BPL :1
                RTS

LEVSUB          LDA BCURSOR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #$02
                SEC
:1              LDA ENTEMP,X
                SED
                SBC (CHARDL),Y
                STA ENTEMP2,X
                CLD
                DEY
                DEX
                BPL :1
                RTS

ORIGIN          LDA BCURSOR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:1              LDA (CHARDL),Y
                STA ENTEMP,X
                DEY
                DEX
                BPL :1
                LDX #3
:2              LDA GROUP_CREDITS,X
                STA CRTEMP,X
                DEX
                BPL :2
                RTS

LEAVE_ENERGY    LDA DIRTY_STATE
                BEQ :1
                JSR SAVE_GAMESTATE_MS
:1              LDX #0
:2              LDA DIRTY_CHARS,X
                EOR #$FF
                STA LEGALS,X
                INX
                CPX GRPNUMB
                BNE :2
                JSR SAVE_MEMBERS

                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall DRAW_HALL
                PictShowPage
                PictEnd
                SEC
                RTS

SETSUP          LDX #3
:1              LDA GROUP_CREDITS,X
                STA CRTEMP,X
                DEX
                BPL :1

                LDA BCURSOR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:2              LDA (CHARDL),Y
                STA ENTEMP,X
                DEY
                DEX
                BPL :2

                JSR ECSHRED
                JSR NTSUB

                LDX #$00
YETZERO         LDA CTSPLIT,X
                BNE ALASTZ
                CPX #$07
                BEQ ALASTZ
                LDA #TextSpace
                STA TEXTBUF,X
                INX
                JMP YETZERO
LASTZ           LDA CTSPLIT,X
ALASTZ          STA TEXTBUF,X
                INX
                CPX #$08
                BNE LASTZ
                LDA #TextLineEnd
                STA TEXTBUF,X

                LDX #$D0
                LDY #$09
                JSR DRAW_TEXTBUF_XY
                JSR ENERGY_TO_TEXT
                LDX #$6A
                LDY #$09
                JSR DRAW_TEXTBUF_XY
                LDA #$63
                STA OPMX
                LDA #$E1
                STA OMPX
                LDX #$09
STLOOP          LDA STARTUM,X
                STA CROLD,X
                DEX
                BPL STLOOP
                LDA #$03
                STA ECURSOR
                RTS

STARTUM         DB  $01,$00,$00,$00
                DB  $01,$00,$00
                DB  $00,$00,$00

NEWENER         JSR ECSHRED
                LDX #$05
ASERASE         LDA ECSPLIT,X
                CMP ETSPLIT,X
                BNE NOSAME1
                LDA #TextSpace
NOSAME1         STA TEXTBUF,X
                DEX
                BPL ASERASE
                LDA #TextLineEnd
                STA TEXTBUF+6
                LDX #$6A
                LDY #$09
                JSR DRAW_TEXTBUF_XY
                LDX #$05
ASDRAW          LDA ETSPLIT,X
                CMP ECSPLIT,X
                BNE NOSAME2
                LDA #TextSpace
NOSAME2         STA TEXTBUF,X
                DEX
                BPL ASDRAW
                LDX #$6A
                LDY #$09
                JSR DRAW_TEXTBUF_XY
                LDX #$07
BSERASE         LDA CCSPLIT,X
                CMP CTSPLIT,X
                BNE NOSAME3
                LDA #TextSpace
NOSAME3         STA TEXTBUF,X
                DEX
                BPL BSERASE
                LDA #TextLineEnd
                STA TEXTBUF+8
                LDX #$D0
                LDY #$09
                JSR DRAW_TEXTBUF_XY
                LDX #$07
BSDRAW          LDA CTSPLIT,X
                CMP CCSPLIT,X
                BNE NOSAME4
                LDA #TextSpace
NOSAME4         STA TEXTBUF,X
                DEX
                BPL BSDRAW
                LDX #$D0
                LDY #$09
                JSR DRAW_TEXTBUF_XY
NTSUB           LDX #$08
:1              LDA ENTEMP,X
                STA ENCUR,X
                DEX
                BPL :1
                LDX #$0B
:2              LDA CRTEMP,X
                STA CRCUR,X
                DEX
                BPL :2
                RTS

ECSHRED         LDX #$00
                LDY #$00
:1              LDA ENTEMP,Y
                PHA
                LSR
                LSR
                LSR
                LSR
                STA ETSPLIT,X
                INX
                PLA
                AND #$0F
                STA ETSPLIT,X
                INX
                INY
                CPX #$06
                BNE :1

                LDX #$00
                LDY #$00
:2              LDA CRTEMP,Y
                PHA
                LSR
                LSR
                LSR
                LSR
                STA CTSPLIT,X
                INX
                PLA
                AND #$0F
                STA CTSPLIT,X
                INX
                INY
                CPX #$08
                BNE :2

                LDX #$00
:3              LDA ETSPLIT,X
                BNE :4
                LDA #TextSpace
                STA ETSPLIT,X
                INX
                CPX #$05
                BNE :3
:4
                LDX #$00
:5              LDA CTSPLIT,X
                BNE :6
                LDA #TextSpace
                STA CTSPLIT,X
                INX
                CPX #$07
                BNE :5
:6              RTS

DRAW_GROUP      LDY #124
                JSR VMOVE_TO
                LDA #$42                ; SELECT
                JSR DRAW_STATS

                JSR DRAW_PICT
                PictSetWhite1
                PictMoveTo $05;$7A
                PictLineTo $112;$7A
                PictMoveTo $05;$84
                PictLineTo $112;$84
                PictCall DRAW_VLINS
                PictEnd
                LDX GRPNUMB
                LDY ENERGY_YPNTS,X
                ; fall through

DRAW_HLIN       JSR VMOVE_TO
                JSR DRAW_PICT
                PictHMoveTo $05
                PictHLineTo $112
                PictEnd
                RTS

DRAW_VLINS      JSR DRAW_PICT
                PictSetWhite1
                PictMoveTo $02;$79
                PictLineTo $02;$BF
                PictMoveTo $03;$79
                PictLineTo $03;$BF
                PictMoveTo $115;$79
                PictLineTo $115;$BF
                PictMoveTo $114;$79
                PictLineTo $114;$BF
                PictEnd
                RTS

FADE_GROUP      LDY GRPNUMB
                LDA ENERGY_YPNTS,Y
                STA ENDLINE
                INC ENDLINE
GFADE2          LDA #$00
                STA COUNTER
FADER0          LDA #$27
                SEC
                SBC COUNTER
                STA START
FADEMOD         LDA #$79
                STA LINENUM
FADER1          LDA START
                STA CYCLE
                LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA SCREENH
                EOR #$60
                STA DESTINH
                LDY CYCLE
FADER2          LDA (SCREENL),Y
                TAX
                LDA (DESTINL),Y
                STA (SCREENL),Y
                TXA
                STA (DESTINL),Y
                TYA
                SEC
                SBC #$09
                TAY
                BPL FADER2
                LDA START
                DEC START
                CMP #$1F
                BNE NORESET
                LDA #$27
                STA START
NORESET         LDA LINENUM
                INC LINENUM
                CMP ENDLINE
                BNE FADER1
                LDA #$40
                JSR WAIT
                LDA COUNTER
                INC COUNTER
                CMP #$08
                BNE FADER0
                RTS

ENERGY_YPNTS    DB  135,144,153
                DB  162,171,180
                DB  189,198

;-----------------------------------------------------------

NUM_CURSOR      LDA BUYSELL
                CMP #$BB
                BEQ :1
                LDA ECURSOR
                BNE :1
                INC ECURSOR
:1              LDX #$09
                LDA #TextSpace
:2              STA CRNEW,X
                DEX
                BPL :2

NUM_ENERGY      LDA #$03
                SEC
                SBC ECURSOR
                TAX
                TAY
                LDA #$01
                STA ECNEW,X
                INX
                LDA #$00
:3              STA ECNEW,X
                INX
                CPX #$06
                BNE :3
                LDA PMXS,Y
                STA NPMX
                LDA #TextLineEnd
                STA TEXTBUF+6
                LDX #$05
:4              LDA ECOLD,X
                CMP ECNEW,X
                BNE :5
                LDA #TextSpace
:5              STA TEXTBUF,X
                DEX
                BPL :4

                LDX #$6A
                LDY #$11
                JSR DRAW_TEXTBUF_XY
                LDX OPMX
                JSR DRAW_PLUS_MINUS

                LDX #$05
:6              LDA ECNEW,X
                CMP ECOLD,X
                BNE :7
                LDA #TextSpace
:7              STA TEXTBUF,X
                DEX
                BPL :6

                LDX #$6A
                LDY #$11
                JSR DRAW_TEXTBUF_XY
                LDX NPMX
                JSR DRAW_PLUS_MINUS

NUM_CREDS       LDA #$03
                SEC
                SBC ECURSOR
                TAX
                TAY
                LDA BUYSELL
                CMP #$BB
                BEQ :1
                INY
                INX
                LDA #$05
                BNE :2
:1              LDA #$01
:2              STA CRNEW,X
                CPX #$03
                BEQ :4
                INX
                LDA #$00
:3              STA CRNEW,X
                INX
                CPX #$04
                BNE :3
:4              LDA MPXS,Y
                STA NMPX
                LDA #TextLineEnd
                STA TEXTBUF+4
                LDX #$03
:5              LDA CROLD,X
                CMP CRNEW,X
                BNE :6
                LDA #TextSpace
:6              STA TEXTBUF,X
                DEX
                BPL :5

                LDX #$E8
                LDY #$11
                JSR DRAW_TEXTBUF_XY
                LDX OMPX
                JSR DRAW_MINUS_PLUS

                LDX #$03
:7              LDA CRNEW,X
                CMP CROLD,X
                BNE :8
                LDA #TextSpace
:8              STA TEXTBUF,X
                DEX
                BPL :7

                LDX #$E8
                LDY #$11
                JSR DRAW_TEXTBUF_XY
                LDX NMPX
                JSR DRAW_MINUS_PLUS

                LDA NMPX
                STA OMPX
                LDA NPMX
                STA OPMX
                LDX #$09
:9              LDA CRNEW,X
                STA CROLD,X
                DEX
                BPL :9
                RTS

MPXS            DB  $E1,$E7,$ED,$F3
PMXS            DB  $63,$69,$6F,$75

;-----------------------------------------------------------

WHO_MENU        LDX #<WHO_MDEF
                LDY #>WHO_MDEF
                JSR MENU_INIT
                JSR MENU_SET_CANCEL
                LDX #<:FILTER
                LDY #>:FILTER
                JSR MENU_SET_FILTER
                JMP MENU_SELECT

:FILTER         CMP #"L"
                BNE :EXIT
                PLA
                PLA
                CLC                     ; same as cancel
                RTS
:EXIT           SEC
                RTS

WHO_MDEF        DB  $08
                DB  $00
                DW  :CURSOR

:CURSOR         LDY ENERGY_YPNTS,X
                LDX #4
                JMP DRAW_ARROW

;-----------------------------------------------------------

DRAW_PLUS_MINUS LDY #$11
                JSR MOVE_TO
                LDX #<:PLUS_MINUS
                LDY #>:PLUS_MINUS
                JMP DRAW_TILE

:PLUS_MINUS     DB  %00001100
                DB  %00001100
                DB  %00111111
                DB  %00001100
                DB  %00001100
                DB  %00000000
                DB  %00111111

DRAW_MINUS_PLUS LDY #$11
                JSR MOVE_TO
                LDX #<:MINUS_PLUS
                LDY #>:MINUS_PLUS
                JMP DRAW_TILE

:MINUS_PLUS     DB  %00111111
                DB  %00000000
                DB  %00001100
                DB  %00001100
                DB  %00111111
                DB  %00001100
                DB  %00001100

;-----------------------------------------------------------

ENOFF           DB  $00,$03,$06,$09
ENDATA          DB  $00,$01,$00
                DB  $00,$10,$00
                DB  $01,$00,$00
                DB  $10,$00,$00

CROFF1          DB  $00,$04,$08,$0C
CRDATA1         DB  $00,$00,$00,$01
                DB  $00,$00,$00,$10
                DB  $00,$00,$01,$00
                DB  $00,$00,$10,$00

CROFF5          DB  $00,$04,$08,$0C
CRDATA5         DB  $00,$00,$00,$00
                DB  $00,$00,$00,$05
                DB  $00,$00,$00,$50
                DB  $00,$00,$05,$00

;-----------------------------------------------------------

DIRTY_STATE     DB  $00
DIRTY_CHARS     DS  maxGroupSize,$00
