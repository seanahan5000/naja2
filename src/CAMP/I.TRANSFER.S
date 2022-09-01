
JUICER_CHAR     =   ISOURCE_CHAR

; TODO: pick ZPAGE location
ENEW			=	$C2					; +1
EVAL			=	$C4					; +1
ETXT			=	$C6					; +1

                DUMMY   SCRATCH_PAGE
ENEW1           DS  3
EVAL1           DS  3
ETEXT1          DS  8

ENEW2           DS  3
EVAL2           DS  3
ETEXT2          DS  8
                DEND

TRANSFER		JSR	BIG_STATS_BOX

				JSR DRAW_PICT
				PictTextAt 177;84;(TRANSFER_ENERGY)
				PictTextAt 198;93;(TO_WHOM?)
				PictEnd

				LDX	JUICER_CHAR
				LDA	#$FF
				STA	LEGALS,X
				LDY YPOINTS,X
                LDX #$06
   				JSR DRAW_MARKER
				JSR	PRE_ARROW
				JSR	MENU_SELECT
				CPX	#7
				BNE	NOCANC2
                JMP HIDE_BIG_STATS      ; return back to C.ISTATS.S

NOCANC2			STX	ITARGET_CHAR

				JSR DRAW_PICT
				PictClear 24;80;39;105
				PictCall BOX_CLEAR
				PictSwap $00;$50;$28;$32
				PictSetGreen
				PictMoveTo $01;$30
				PictLineTo $115;$30
				PictClear 24;80;39;105
				PictClear 0;49;40;50
				PictEnd

				LDA ITARGET_CHAR
				JSR SET_CHAR
				LDY #14
				JSR VMOVE_TO
				JSR STATS_LINE

				JSR DRAW_PICT
				PictTextAt 48;26;(ENERGY_TRANSFER_AMOUNT:)
				PictEnd

				LDA JUICER_CHAR
				JSR SET_CHAR
				LDY #38
				JSR VMOVE_TO
				JSR STATS_LINE

				JSR DRAW_PICT
				PictTextAt 195;51;(C>ANCEL)
				PictEnd

                LDA #>ENEW1
                STA ENEW+1
                STA EVAL+1
                STA ETXT+1

                LDA #$04
                STA CURSOR

                LDA ITARGET_CHAR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:2              LDA (CHARDL),Y
                STA ENEW1,X
                DEY
                DEX
                BPL :2

                LDA JUICER_CHAR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:3              LDA (CHARDL),Y
                STA ENEW2,X
                DEY
                DEX
                BPL :3

                LDX #5
                LDA #TextSpace
:1              STA ETEXT1,X
                STA ETEXT2,X
                DEX
                BPL :1

                JSR TUPDATE_FIRST
                JSR ZCURSIT

ZBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI ZGOTKEY
                JSR ZCURSIT
                LDA #$00
                JSR WAIT_KEY
                JSR ZCURSIT
                BIT KEYBRD
                BPL ZBLINK
ZKEY            LDA KEYBRD
                BPL ZKEY
ZGOTKEY         BIT UNSTROB
                JSR CHECK_LEFT
                BEQ ZLEFT
                JSR CHECK_RIGHT
                BEQ ZRIGHT
                JSR CHECK_UP
                BEQ ZUP
                JSR CHECK_DOWN
                BEQ ZDOWN
                CMP #"C"
                BEQ ZCANCEL
                JSR CHECK_ENTER
                BNE ZKEY

ZENTER        	LDA ITARGET_CHAR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:2              LDA ENEW1,X
                STA (CHARDL),Y
                DEY
                DEX
                BPL :2
                JSR CALC_ALL

                LDA JUICER_CHAR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:3              LDA ENEW2,X
                STA (CHARDL),Y
                DEY
                DEX
                BPL :3
                JSR CALC_ALL

ZCANCEL			JSR DRAW_PICT
				PictClear 27;51;34;58
				PictSwap $00;$31;$28;$00
				PictEnd
                RTS                     ; back to C.ISTATS.S

ZLEFT           LDA CURSOR
                BEQ :1
                JSR ZCURSIT
                DEC CURSOR
                JSR ZCURSIT
:1              JMP ZKEY

ZRIGHT          LDA CURSOR
                CMP #4
                BEQ :1
                JSR ZCURSIT
                INC CURSOR
                JSR ZCURSIT
:1              JMP ZKEY

ZUP             LDA ITARGET_CHAR
                JSR SET_CHAR
                JSR SET_ELEFT
                JSR ADDSUB
                BCC :BADUP
                JSR SET_ERIGHT
                JSR SUBSUB
                BCC :BADUP
                JSR TUPDATE
:BADUP          JMP ZKEY

ZDOWN           LDA JUICER_CHAR
                JSR SET_CHAR
                JSR SET_ERIGHT
                JSR ADDSUB
                BCC :BADOWN
                JSR SET_ELEFT
                JSR SUBSUB
                BCC :BADOWN
                JSR TUPDATE
:BADOWN         JMP ZKEY

ZCURSIT         LDX #0
                LDA CURSOR
                BEQ :2
                LDA #TextSpace
:1              STA TEXT_BUFFER,X
                INX
                CPX CURSOR
                BNE :1
:2              LDA #1
                STA TEXT_BUFFER,X
                LDA #0
                INX
                BNE :4                  ; always
:3              STA TEXT_BUFFER,X
                INX
:4              CPX #6
                BNE :3
                LDA #TextLineEnd
                STA TEXT_BUFFER,X
                LDX #$C6
                LDY #$1A
                JSR DRAW_TEXTBUF_XY

                LDX CURSOR
                LDA :X_POSITIONS,X
                TAX
                JSR HMOVE_TO
                LDX #<PLUS_MINUS
                LDY #>PLUS_MINUS
                JMP DRAW_TILE

:X_POSITIONS	DB	191,197,203,209,215

PLUS_MINUS      DB  %00001100
                DB  %00001100
                DB  %00111111
                DB  %00001100
                DB  %00001100
                DB  %00000000
                DB  %00111111

SET_ELEFT       LDX #<ENEW1
                BEQ SET_ECMN            ; always
SET_ERIGHT      LDX #<ENEW2
SET_ECMN        STX ENEW
                INX
                INX
                INX
                STX EVAL
                INX
                INX
                INX
                STX ETXT
                RTS

TUPDATE_FIRST	LDA #$38				; SEC
				BNE TUPDATE_CMN			; always
TUPDATE         LDA #$18				; CLC
TUPDATE_CMN		STA :MOD
				JSR SET_ELEFT
                LDY #$0E
                JSR :UPDATE
                JSR SET_ERIGHT
                LDY #$26
                ; fall through
:UPDATE         JSR VMOVE_TO
                LDY #0
                LDX #0
:1              LDA (ENEW),Y
                STA (EVAL),Y
                PHA
                LSR
                LSR
                LSR
                LSR
                STA TEXT_BUFFER+8,X
                INX
                PLA
                AND #$0F
                STA TEXT_BUFFER+8,X
                INX
                INY
                CPX #6
                BNE :1

                LDX #0
:2              LDA TEXT_BUFFER+8,X
                BNE :3
                LDA #TextSpace
                STA TEXT_BUFFER+8,X
                INX
                CPX #5
                BNE :2
:3
                LDY #0
:4              LDA (ETXT),Y
                CMP TEXT_BUFFER+8,Y
                BEQ :5
                STA TEXT_BUFFER,Y
                LDA TEXT_BUFFER+8,Y
                STA (ETXT),Y
                BPL :6                  ; always

:5              LDA #TextSpace
                STA TEXT_BUFFER,Y
                STA TEXT_BUFFER+8,Y
:6              INY
                CPY #6
                BNE :4
                LDA #TextLineEnd
                STA TEXT_BUFFER,Y
                STA TEXT_BUFFER+8,Y

:MOD            CLC
                BCS :7

	            LDX #$C6
                JSR DRAW_TEXTBUF_X

                LDX #$C6
                JSR HMOVE_TO
                LDX #<TEXT_BUFFER+8
                LDY #>TEXT_BUFFER+8
                JMP DRAW_TEXT
:7              RTS
;
; On exit:
;   C=1: good add
;   C=0: bad add
;
ADDSUB          LDY CURSOR
                LDX AM_OFFSETS,Y
                LDY #2
                SED
                CLC
:1              LDA (EVAL),Y
                ADC AMOUNTS,X
                STA (ENEW),Y
                STA TEXT_BUFFER,Y
                DEX
                DEY
                BPL :1
                BCS :3
                LDY #energymax+2
                LDX #2
                SEC
:2              LDA (CHARDL),Y
                SBC TEXT_BUFFER,X
                DEY
                DEX
                BPL :2
                BMI :4                  ; always
:3              CLC
:4              CLD
                RTS
;
; On entry:
;   Y: amount index
;
; On exit:
;   C=1: good subtract
;   C=0: bad subtract
;
SUBSUB          LDY CURSOR
                LDX AM_OFFSETS,Y
                LDY #2
                SED
                SEC
                LDA #0
:1              STA :MOD+1
                LDA (EVAL),Y
                SBC AMOUNTS,X
                STA (ENEW),Y
:MOD            ORA #$FF
                DEX
                DEY
                BPL :1
                BCC :2
                TAX
                BNE :2
                CLC
:2              CLD
                RTS

AM_OFFSETS      DB  0+2,3+2,6+2
                DB  9+2,12+2,15+2

AMOUNTS         DB  $10,$00,$00
                DB  $01,$00,$00
                DB  $00,$10,$00
                DB  $00,$01,$00
                DB  $00,$00,$10

; TODO: consider supporting a masked rectangle clear in PICT.S
BOX_CLEAR       LDX #$0B
:1              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #$27
                LDA (SCREENL),Y
                AND #$F0
                STA (SCREENL),Y
                DEY
                LDA #$00
:2              STA (SCREENL),Y
                DEY
                BNE :2
                LDA (SCREENL),Y
                AND #$83
                STA (SCREENL),Y
                INX
                CPX #$4F
                BNE :1
                RTS

;*** PUT THIS IN C.ISTATS.S ***
; also used by I.REGENERATE.S and I.DIAGNOSER.S loader
;*** can this be shared with other similar box code? ***
BIG_STATS_BOX	LDA #$42
				STA SELECT

				JSR DRAW_PICT
				PictSetPage1
				PictClearPage
				;*** only difference is here ***
				PictRect $01;$00;$115;$4F
				PictMoveTo $01;$0A
				PictLineTo $115;$0A
				PictVMoveTo 2
				PictCall STATS_HEADER
                PictVMove 10
				PictEnd

                JSR FIRST_CHAR
:1              JSR STATS_LINE
                JSR DRAW_PICT
                PictVMove 8
                PictEnd
                JSR NEXT_CHAR
                BCC :1

				JSR DRAW_PICT
				PictTextAt 16;70;(CANCEL)
				PictSetPage2
				PictSwap $00;$00;$28;$50
				PictMoveTo $AB;$68
				PictLineTo $10F;$68
				PictEnd

                ;*** RESET_CHRLIST? ***
				LDX	#$09
				LDA	#$FF
:2				STA	LEGALS,X
				DEX
				BMI	:3
				CPX	GRPNUMB
				BCS	:2
				LDA	#$00
				BEQ	:2					; always
:3				LDA	#$00
				STA	LEGALS+7
				RTS

HIDE_BIG_STATS  JSR DRAW_PICT
                PictClear 24;80;39;105
                PictSwap $00;$50;$28;$00
                PictEnd
                RTS

