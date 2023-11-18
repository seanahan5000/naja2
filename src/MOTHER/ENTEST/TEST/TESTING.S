
TESTING         JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictSetPage2
                PictClearPage
                PictEnd

                JSR DOCOTAB
                JSR DRAW_SELMEMB

                JSR DRAW_PICT
                PictSetGreen
                PictRect $01;$73;$115;$B6
                PictMoveTo $01;125
                PictLineTo $115;125
                PictVMoveTo 117
                PictEnd

                LDA #$42
                JSR DRAW_STATS
                JSR SHOW_PAGE

                JSR RESET_CHLIST
                LDA #0
                STA LEGALS+7
                STA WHICH_CDEF+1
GOKCOMN         LDX #<WHICH_CDEF
                LDY #>WHICH_CDEF
                JSR MENU_INIT
                JSR MENU_SET_CANCEL
                JSR MENU_SELECT
                BCC LEAVE_TESTING
                CPX #$07
                BEQ LEAVE_TESTING
                JMP NO_LEAVE

LEAVE_TESTING   JSR DRAW_PICT
                PictSetPage1
                PictCall CLEAR_BOX
                PictShowPage
                PictEnd
                LDA #2
                JMP ENTEST_BACK

DRAW_SELMEMB    JSR DRAW_PICT
                PictClear $02;$00;$26;$6B
                PictSetViolet
                PictRect $36;$29;$E2;$44
                PictTextAt 75;47;"SELECT GROUP MEMBER TO"
                PictTextAt 63;56;"TAKE RANK ADVANCEMENT TEST"
                PictTextAt 16;185;"LEAVE"
                PictEnd
                RTS

*-------------------------------

WHICH_CDEF      DB  $08
                DB  $FF                 ; modified
                DW  :CURSIT

:CURSIT         LDX CURSOR
                LDY TYPOINTS,X
                LDX #3
                JMP DRAW_ARROW

MARKIT          LDX CURSOR
                LDY  TYPOINTS,X
                LDX #8
                JMP DRAW_MARKER

TYPOINTS        DB  128,137,146
                DB  155,164,173
                DB  0,185

*-------------------------------

NO_LEAVE        STX WHICH_CDEF+1
                TXA
                JSR SET_CHAR
                JSR MARKIT
                JSR DRAW_PICT
                PictClear 2;185;7;192   ; remove LEAVE
                PictEnd
                LDY #status
                LDA (CHARDL),Y
                CMP #healthy
                BNE NOT_HEALTHY
                JMP IS_HEALTHY

NOT_HEALTHY     JSR DRAW_PICT
                PictClear $02;$00;$26;$6B
                PictSetOrange
                ; rectangle with notch for space
                PictMoveTo 21;76
                PictLineTo 21;106
                PictLineTo 213;106
                PictLineTo 213;97
                PictLineTo 259;97
                PictLineTo 259;76
                PictLineTo 21;76
                PictTextAt 36;79;"YOU MUST BE HEALTHY IN ORDER FOR ME"
                PictTextAt 30;88;"TO ACCURATELY DETERMINE HOW MUCH YOUR"
                PictTextAt 60;97;"STATISTICS HAVE IMPROVED."
                PictTextAt 219;99;"<SPACE>"
                PictCall TSPACE_WAIT
                PictClear $02;$00;$26;$6B
                PictEnd

                INC WHICH_CDEF+1
                JMP PFCOMN2

IS_HEALTHY      JSR PASS_FAIL
                BCC FAILS_TEST
                JMP PASSES_TEST

FAILS_TEST      JSR DRAW_PICT
                PictClear $02;$00;$26;$6B
                PictSetBlue
                PictRect $1E;$00;$100;$51
                PictTextAt 45;6;"UPON REVIEWING "
                PictCall DRAW_TRIMMED_NAME
                PictText "'S TEST"
                PictTextAt 45;15;"PERFORMANCE, I HAVE DETERMINED"
                PictTextAt 45;24;"THAT THEY HAVE NOT MET THE"
                PictTextAt 45;33;"MINIMUM REQUIREMENTS FOR A LEVEL"
                PictMoveTo 45;42
                PictCall LEVEL_OUT
                PictText " "
                PictCall PROF_OUT
                PictText " AND SHOULD"
                PictTextAt 45;51;"ACCUMULATE AT LEAST "
                PictCall MORE_EXP
                PictText " MORE"
                PictEnd

                LDX #TextS
                LDA LEVTOTL
                ORA LEVTOTL+1
                ORA LEVTOTL+2
                BNE :1
                LDA LEVTOTL+3
                CMP #$01
                BNE :1
                LDX #TextEmpty
:1              STX :PLURAL+19

                JSR DRAW_PICT
:PLURAL         PictTextAt 45;60;"EXPERIENCE POINTS BEFORE TAKING"
                PictTextAt 45;69;"THE TEST AGAIN."
                PictTextAt 209;72;"<SPACE>"
                PictEnd

                INC WHICH_CDEF+1
                JMP PFCOMN

PASSES_TEST     JSR DRAW_PICT
                PictSetOrange
                PictClear $02;$00;$26;$6B
                PictRect $1D;$00;$101;$68
                PictTextAt 45;6;"CONGRATULATIONS. "
                PictEnd

                LDY #profrace
                LDA (CHARDL),Y
                AND #%11110000
                CMP #physician*16
                BNE NO_EMED
                LDY #level
                LDA (CHARDL),Y
                BNE NO_EMED
                INY
                LDA (CHARDL),Y
                CMP #$14
                BNE NO_EMED

NOW_EMED        JSR DRAW_PICT
                PictCall DRAW_TRIMMED_NAME
                PictText " IS"
                PictTextAt 45;15;"NOW QUALIFIED TO BE A LEVEL "
                PictCall LEVEL_OUT
                PictTextAt 72;24;"*** ELECTRO-MEDIC ***"
                PictEnd

                JSR PROFFER
                LDY #profrace
                LDA (CHARDL),Y
                AND #%00001111
                ORA #electromedic*16
                STA (CHARDL),Y
                JSR PROFFER
                JMP PASS_CMN

; change profession in stats box

PROFFER         JSR CPROF_TO_TEXT
                LDA #TextLineEnd
                STA TEXTBUF+3
                LDX CURSOR
                LDY TYPOINTS,X
                LDX #78
                JMP DRAW_TEXTBUF_XY

NO_EMED         JSR DRAW_PICT
                PictCall DRAW_TRIMMED_NAME
                PictText " HAS"
                PictTextAt 45;15;"MET THE MINIMUM REQUIREMENTS"
                PictTextAt 45;24;"FOR A LEVEL "
                PictCall LEVEL_OUT
                PictText " "
                PictCall PROF_OUT
                PictText "."
                PictEnd

PASS_CMN        LDY #level
                LDA LEVCNT
                STA (CHARDL),Y
                INY
                LDA LEVCNT+1
                STA (CHARDL),Y

                JSR DRAW_PICT
                PictTextAt 45;36;"IT HAS ALSO BEEN STORED IN MY"
                PictTextAt 45;45;"MEMORY BANKS THAT THEIR"
                PictTextAt 45;54;"STATISTICS ARE NOW:"
                PictTextAt 75;65;"INTELLIGENCE:"
                PictTextAt 75;74;"UPPER REFLEX:"
                PictTextAt 75;83;"LOWER REFLEX:"
                PictTextAt 99;92;"STRENGTH:"
                PictTextAt 209;95;"<SPACE>"
                PictEnd

                JSR DRWSTAT
                JSR UPOWER
                JSR DAMINC

PFCOMN          JSR TSPACE_WAIT
PFCOMN2         JSR DRAW_SELMEMB
                JSR MARKIT
                JMP GOKCOMN

TSPACE_WAIT     BIT UNSTROB
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB
                JSR CHECK_ENTER
                BNE :1
                RTS

;---------------------------------------

LEVEL_OUT       LDY #level+1
                LDA (CHARDL),Y
                CLC
                SED
                ADC #1
                STA LEVCNT+1
                PHA
                DEY
                LDA (CHARDL),Y
                ADC #0
                STA LEVCNT
                PHA
                CLD
                LDA #2
                BNE DIGITS_OUT          ; always

MORE_EXP        LDX #3
:1              LDA LEVTOTL,X
                PHA
                DEX
                BPL :1
                LDA #4
                ; fall through

DIGITS_OUT      LDX #0
                JSR DIGITS_L
                LDA #TextLineEnd
                STA TEXTBUF,X
                JMP DRAW_TEXTBUF

;---------------------------------------

PROF_OUT        LDY #profrace
                LDA (CHARDL),Y
                AND #$F0
                CMP #electromedic*16
                BEQ :1
                JSR CPROF_TO_TEXT
                JMP DRAW_TEXTBUF

:1              LDX #0
:2              LDA :ELECTRO,X
                STA TEXT_BUFFER,X
                INX
                CMP #TextLineEnd
                BNE :2
                JMP DRAW_TEXTBUF

:ELECTRO        TXC "ELECTRO-MEDIC"

;---------------------------------------

DRWSTAT

; randomly increase stats points

                LDX #0
UPSTATS         JSR RANDOM
                AND #$03
                CMP #$03
                BEQ UPSTATS
                STA PLUSTAB,X
                LDY LOCS,X
                SED
                CLC
                ADC (CHARDL),Y
                CLD
                BCC NOMAXD
                LDA #$00
                STA PLUSTAB,X
                LDA #$99
NOMAXD          STA (CHARDL),Y
                INX
                CPX #4
                BNE UPSTATS

; draw new stats values

                LDA #$8D
                STA TEXTBUF+2
                LDX #0
STLOOP          STX COUNT
                LDY LOCS,X
                LDA (CHARDL),Y
                PHA
                AND #$0F
                STA TEXTBUF+1
                PLA
                LSR
                LSR
                LSR
                LSR
                BNE NOT0
                LDA #TextSpace
NOT0            STA TEXTBUF
                LDY STATYS,X
                LDX #$9F
                JSR DRAW_TEXTBUF_XY
                LDX COUNT
                LDA PLUSTAB,X
                BEQ MARKED

; draw markers for increase in stats

                LDX #$AD
                JSR HMOVE_TO
MARLOOP         LDX #<TRIANGLE_SHAPE
                LDY #>TRIANGLE_SHAPE
                JSR DRAW_TILE
                LDX #1
                JSR HMOVE
                LDX COUNT
                DEC PLUSTAB,X
                BNE MARLOOP

MARKED          INX
                CPX #4
                BNE STLOOP

; increase number of back slots based on strength

                LDY #strength
                LDA (CHARDL),Y
                LDY #$03
                LDX #$00
BKLOOP1         CMP BACKUTS,X
                BCC GOTBACK
                INY
                INX
                CPX #$03
                BNE BKLOOP1
GOTBACK         TYA
                LDY #back
                STA (CHARDL),Y
                RTS

BACKUTS         DB  $40,$50,$60

TRIANGLE_SHAPE  DB  %00000000
                DB  %00000011
                DB  %00000111
                DB  %00001111
                DB  %00011111
                DB  %00111111
                DB  %00000000

LOCS            DB  intelligence
                DB  upreflex
                DB  lwreflex
                DB  strength

STATYS          DB  $41,$4A,$53,$5C

; update power value in stats box

UPOWER          JSR DOPOW
                LDY #organic
                LDA #$00
                SEC
                SED
                SBC (CHARDL),Y
                CLC
                ADC #$20
                CLD
                TAX
                ASL
                ASL
                ASL
                ASL
                STA LEVTOTL+2
                TXA
                LSR
                LSR
                LSR
                LSR
                SED
                CLC
                ADC #$30
                CLD
                STA LEVTOTL+1
                LDA #$00
                STA LEVTOTL
                LDY #profrace
                LDA (CHARDL),Y
                AND #%11110000
                CMP #juicer*16
                BNE NOJUICR
                LDX #$02
                CLC
LEVLOOP         SED
                LDA LEVTOTL,X
                ADC LEVTOTL,X
                STA LEVTOTL,X
                CLD
                DEX
                BPL LEVLOOP
NOJUICR         LDX #$02
                LDY #energymax+2
                CLC
ADDCONS         LDA (CHARDL),Y
                SED
                ADC LEVTOTL,X
                CLD
                STA (CHARDL),Y
                DEY
                DEX
                BPL ADDCONS
                BCC DOPOW
                LDY #energymax+2
                LDA #$00
                STA (CHARDL),Y
                DEY
                LDA #$99
                STA (CHARDL),Y
                DEY
                STA (CHARDL),Y
                ; fall through
DOPOW           JSR ENERGY_TO_TEXT
                LDX #6
                LDA #$EE
:LOOP1          STA TEXTBUF,X
                DEX
                BPL :LOOP1
                LDX CURSOR
                LDY TYPOINTS,X
                LDX #$F0
                JMP DRAW_TEXTBUF_XY

;---------------------------------------
