
; valid for all I.XXX.S source files
ISOURCE_CHAR	=	$C0
ITARGET_CHAR	=	$C1

DIRECTION		=	$C3
PROFRACE_CHANGE	=	$C4
STATS_VISIBLE	=	$C5

DOSTATS			LDA	CURSOR
				STA	ISOURCE_CHAR
				LDA	#0
				STA	ICURPOS

RESTATS			JSR DRAW_PICT
				PictSetPage2
				PictClearPage
				PictSetGreen
				PictRect $A5;$00;$115;$BF
				PictCall DRAW_CHAR_ROBO
				PictTextAt 171;116;(EQUIPMENT_OPTIONS)
				PictTextAt 198;125;()-
				USR (MOVE\n)-
				USR (DROP\n)-
				USR (USE\n)-
				USR (EXAMINE)
				PictTextAt 180;162;()-
				USR (TRANSFER_ENERGY\n)-
				USR (SEE_STATISTICS)
				PictTextAt 180;181;(LEAVE)
				PictShowPage
				PictEnd

; TODO: draw arrow instructions

IMENU			LDX	#<ISTAT_MENU
				LDY	#>ISTAT_MENU
				JSR	MENU_INIT
				LDA #0
				STA STATS_VISIBLE
				LDX #<ISTAT_FILTER
				LDY #>ISTAT_FILTER
				JSR MENU_SET_FILTER
				JSR MENU_SELECT
				STX ICURPOS
				JSR	IMARKER
				JSR MENU_TARGET
				LDX ICURPOS
				JSR	IMARKER
				LDA ISOURCE_CHAR
				JSR SET_CHAR
				JMP IMENU

*-------------------------------
ISTAT_MENU		DB	$87
ICURPOS			DB	$00
				DW	:ISTAT_CURS
				DW	:ISTAT_JUMPS

:ISTAT_JUMPS	DW	TO_MOVER
				DW	TO_DROPPER
				DW	TO_USE
				DW	TO_EXAMINE
				DW	TO_TRANSFER
				DW	SEESTAT
				DW	TO_RECAMP

:ISTAT_CURS		JSR	XY_SUB
				JMP	DRAW_ARROW
*-------------------------------

ISTAT_FILTER	LDA KEYBRD
				JSR CHECK_LEFT
				CLC
				BEQ :LEFT_RIGHT
				JSR CHECK_RIGHT
				SEC
				BEQ :LEFT_RIGHT
;				SEC						; set to continue
				RTS

:LEFT_RIGHT		PLA
				PLA
				BIT UNSTROB
				PHP
				JSR MENU_DRAW_CURSOR
				PLP
				BCS :1
				JSR DO_PREV_CHAR
				JMP :2
:1				JSR DO_NEXT_CHAR
:2				PLA
				PLA
				LDA STATS_VISIBLE
				BNE :3
				JMP IMENU
:3				JMP IMENU_SEE

*-------------------------------

TO_MOVER		JSR BANK_2
				JMP MOVESUB

TO_DROPPER		JSR BANK_2
				JMP DROPSUB

TO_RECAMP		PLA
				PLA
				JMP RECAMP

TO_USE          LDA SHELL
                BNE :CAN_USE
				JSR DRAW_PICT
				PictSetGreen
				PictMoveTo $AB;$32
				PictLineTo $10F;$32
				PictMoveTo $AB;$67
				PictLineTo $10F;$67
		        PictTextAt 177;63;(NOT_ALLOWED_IN)
                PictTextAt 189;72;(MOTHERSHIP)
                PictTextAt 198;84;(<SPACE>)
				PictEnd
                BIT UNSTROB
:KEYLOOP        LDA KEYBRD
                BPL :KEYLOOP
                BIT UNSTROB
                JSR CHECK_ENTER
                BNE :KEYLOOP
                JSR DRAW_PICT
                PictClear 24;50;39;104
                PictEnd
:GO_BACK        RTS

:CAN_USE        LDY #status
                LDA (CHARDL),Y
                CMP #dead
                BEQ :GO_BACK
				JSR BANK_2
				JMP USER

TO_EXAMINE		JSR BANK_2
				JMP EXAMINE

TO_TRANSFER		LDY	#profrace
				LDA	(CHARDL),Y
				AND	#$F0
				CMP	#juicer*16
				BNE	:NOJUICER
				JMP	FROMJ_TRANSFER

:NOJUICER		JSR FIRST_CHAR
:1				LDY #profrace
				LDA (CHARDL),Y
				AND #$F0
				CMP #juicer*16
				BEQ :2
				JSR NEXT_CHAR
				BCC :1
				RTS
:2				LDA ISOURCE_CHAR
				STA ITARGET_CHAR
				LDA CHAR_INDEX
				STA ISOURCE_CHAR
				JSR TOJ_TRANSFER
				LDA ITARGET_CHAR
				STA ISOURCE_CHAR
				RTS
;
; On entry:
;	X: CURSOR
;
IMARKER			JSR	XY_SUB
				INX
				INX
				INX
                JMP DRAW_MARKER
; On entry:
;	X: CURSOR
;
XY_SUB			LDY	:YPNTS,X
				LDA	#$B9
				CPX	#4
				BCC	:EXIT
				LDA	#$A7
:EXIT			TAX
				RTS

:YPNTS			DB	$7D,$86,$8F
				DB	$98,$A2,$AB
				DB	$B5

;-------------------------------------------------------------------------------

DO_NEXT_CHAR	LDX ISOURCE_CHAR
				INX
				CPX GROUP_SIZE
				BNE :1
				LDX #0
:1				STX ITARGET_CHAR
				LDA #1
				CPX ISOURCE_CHAR
				BNE PREV_NEXT_CMN
				RTS

DO_PREV_CHAR	LDX ISOURCE_CHAR
				BNE :1
				LDX GROUP_SIZE
:1				DEX
				STX ITARGET_CHAR
				LDA #-1
				CPX ISOURCE_CHAR
				BNE PREV_NEXT_CMN
				RTS

PREV_NEXT_CMN	STA DIRECTION
				JSR CHECK_PROFRACE
				JSR CLEAR_ITEMS

				LDA STATS_VISIBLE
				BEQ :1
				JSR DRAW_PICT
				PictClear 31;54;39;88		; status/shield
				PictClear 26;104;38;111		; energy
				PictClear 36;118;38;170		; 1 byte stats
				PictEnd
:1
				BIT PROFRACE_CHANGE
				BMI :2
				BVC :2
				JSR DRAW_PICT
				PictClear 5;107;8;138
				PictEnd
:2
				LDA ITARGET_CHAR
				STA ISOURCE_CHAR
				JSR SET_CHAR

				BIT PROFRACE_CHANGE
				BMI :3
				BVC :3
				JSR DRAW_HAND_LABELS
:3
				JSR REDRAW_INFO
				JSR SCROLL_INFO

				LDA PROFRACE_CHANGE
				BMI :4
				JSR DRAW_ITEMS
				JMP :5

:4				JSR DRAW_PICT
				PictSetPage1
				PictClearPage
				PictCall DRAW_CHAR_ROBO
				PictSetPage2
				PictCopyTo 0;0;23;192
				PictEnd

:5				LDA STATS_VISIBLE
				BEQ :6
				JSR DRAW_STATS_VALS
:6				RTS

CHECK_PROFRACE	LDA #$00
				STA PROFRACE_CHANGE
				JSR :CHECK_SUB
				LDA ITARGET_CHAR
				JSR SET_CHAR
				JSR :CHECK_SUB
				LDA ISOURCE_CHAR
				JMP SET_CHAR

:CHECK_SUB		LDY #profrace
				LDA (CHARDL),Y
				AND #$8F
				CMP #deneb
				BNE :1
				ORA #$40
:1				AND #$C0
				EOR PROFRACE_CHANGE
				STA PROFRACE_CHANGE
				RTS

REDRAW_INFO		JSR DRAW_PICT
				PictSetPage1
				PictClear 24;4;39;47
				PictCall DRAW_INFO
				PictSetPage2
				PictEnd
				RTS

FROM_Y			=	LOCAL_TEMP+0

SCROLL_INFO		LDA DIRECTION
				BMI SCROLL_RIGHT

SCROLL_LEFT		LDY #24
:1				STY FROM_Y

				LDX #4
:2				LDA LOBYTES,X
				STA SCREENL
				STA DESTINL
				LDA HIBYTES,X
				STA SCREENH
				EOR #$60
				STA DESTINH

				LDY #25
:3				LDA (SCREENL),Y
				DEY
				STA (SCREENL),Y
				INY
				INY
				CPY #39
				BNE :3

				LDY FROM_Y
				LDA (DESTINL),Y
				LDY #38
				STA (SCREENL),Y
				INX
				CPX #47
				BNE :2

				LDY FROM_Y
				INY
				CPY #39
				BNE :1
				RTS

SCROLL_RIGHT	LDY #38
:1				STY FROM_Y

				LDX #4
:2				LDA LOBYTES,X
				STA SCREENL
				STA DESTINL
				LDA HIBYTES,X
				STA SCREENH
				EOR #$60
				STA DESTINH

				LDY #37
:3				LDA (SCREENL),Y
				INY
				STA (SCREENL),Y
				DEY
				DEY
				CPY #23
				BNE :3

				LDY FROM_Y
				LDA (DESTINL),Y
				LDY #24
				STA (SCREENL),Y
				INX
				CPX #47
				BNE :2

				LDY FROM_Y
				DEY
				CPY #23
				BNE :1
				RTS

;-------------------------------------------------------------------------------

DRAW_CHAR_ROBO	JSR BANK_2
				JSR IS_ROBOT
				BCS :ROBOT

:CHARACTER		JSR DRAW_PICT
				PictImage CHAR_IMAGE
				PictEnd
				JSR	DRAW_CHAR_EQUIP
				JMP	DRAW_CHAR_INFO

:ROBOT			JSR DRAW_PICT
				PictImage ROBOT_IMAGE
				PictEnd
				JSR	DRAW_ROBO_EQUIP
				JMP	DRAW_ROBO_INFO

DRAW_ITEMS		JSR IS_ROBOT
				BCC	DRAW_CHAR_ITEMS
				JMP DRAW_ROBO_ITEMS

DRAW_CHAR_EQUIP	JSR	DRAW_PICT
				PictTextAt 42;0;(HEAD)
				PictTextAt 50;9;(:)
				PictTextAt 50;17;(:)
				PictTextAt 42;33;(BACK)
				PictTextAt 42;98;(HANDS)
				PictTextAt 42;147;(ARMOR)
				PictTextAt 50;156;(:)
				PictTextAt 42;172;(FEET)
				PictTextAt 50;181;(:)
				PictEnd

				; draw variable number of back slots
				LDY	#back
				LDA	(CHARDL),Y
				BEQ :2
				TAX
:1				STX :TEXT_MOD+1
				LDY CEQUIP_LINES+6-1,X
				LDX #38+6
				JSR MOVE_TO
				JSR DRAW_PICT
:TEXT_MOD		PictText (1:)
				PictEnd
				LDX :TEXT_MOD+1
				DEX
				BNE :1
:2				JSR DRAW_HAND_LABELS
				; fall through

DRAW_CHAR_ITEMS	LDX #0
:1				STX COUNT
				TXA
				JSR	EQUIP_IND_TO_TEXT
				LDX COUNT
				LDY CEQUIP_LINES,X
				LDX #66
				JSR DRAW_TEXTBUF_XY
				LDX COUNT
				INX
				CPX #14
				BNE :1
				RTS

DRAW_HAND_LABELS
				LDY	#profrace
				LDA	(CHARDL),Y
				AND	#$0F
				CMP	#deneb
				BEQ	:DENEB

				JSR	DRAW_PICT
				PictSetTextHeight 8
				PictTextAt 38;107;(_L:\n_R:)
				PictEnd
				RTS

:DENEB			JSR	DRAW_PICT
				PictSetTextHeight 8
				PictTextAt 38;107;(UL:\nUR:\nLL:\nLR:)
				PictEnd
				RTS

CLEAR_ITEMS		JSR IS_ROBOT
				BCC	CLEAR_CHAR_ITEMS
				JMP CLEAR_ROBO_ITEMS

CLEAR_CHAR_ITEMS
				LDX #0
:1				STX COUNT
				LDA CEQUIP_LINES,X
				STA :MODY1
				CLC
				ADC #7
				STA :MODY2
				JSR	DRAW_PICT
				DB OpClear
				DB 9
:MODY1			DB $FF
				DB 23
:MODY2			DB $FF
				PictEnd
				LDX COUNT
				INX
				CPX #14
				BNE :1
				RTS

CEQUIP_LINES	DB	$09,$11,$6B
				DB	$73,$7B,$83
				DB	$2A,$32,$3A
				DB	$42,$4A,$52
				DB	$9C,$B5

DRAW_INFO		JSR IS_ROBOT
				BCC DRAW_CHAR_INFO
				JMP DRAW_ROBO_INFO

DRAW_CHAR_INFO	JSR DRAW_PICT
				PictTextAt 171;4;()-
				USR(NAME:\n)-
				USR(RACE:\n)-
				USR(PROF:\n)-
				USR(LEVL:\n)-
				USR(EXPR:)
				PictMoveTo $CC;4
				PictCall CNAME_TO_TEXT
				PictTextbufRet
				PictCall CRACE_TO_TEXT
				PictTextbufRet
				PictCall CPROF_TO_TEXT
				PictTextbufRet
				PictCall CLEVEL_TO_TEXT
				PictTextbufRet
				PictCall CEXP_TO_TEXT
				PictTextbufRet
				PictEnd
				RTS

DRAW_ROBO_EQUIP	LDX #9
				LDY	#e1_HEAD
				LDA	(CHARDL),Y
				BPL	:NOWITH
				JSR DRAW_PICT
				PictTextAt 26;9;(WITH:)
				PictEnd
				LDX #0
:NOWITH			STX :VMOVE_MOD+2
				JSR DRAW_PICT
:VMOVE_MOD		PictTextAt 26;9;(HEAD:)
				PictEnd
				JSR DRAW_PICT
				PictTextAt 42;33;(ARMS)
				PictSetTextHeight 8
				PictTextAt 44;42;(L:\n_:\nR:\n_:)
				PictTextAt 42;104;(BACK)
				PictTextAt 50;113;(:)
				PictTextAt 42;128;(PROGRAM)
				PictTextAt 50;137;(:)
				PictTextAt 42;152;(MOVEMENT_TYPE)
				PictTextAt 50;161;(:)
				PictEnd
				; fall through

DRAW_ROBO_ITEMS LDX #9
				LDY	#e1_HEAD
				LDA	(CHARDL),Y
				BPL :NOWITH
				LDX #0
:NOWITH			STX :VMOVE_MOD+2
				AND	#%00000111
				STA :RANGE_MOD
				JSR DRAW_PICT
				PictHMoveTo 26
:VMOVE_MOD		PictTextAt 66;9;(<SIGHT_RANGE-)-
:RANGE_MOD		USR	(_>)
				PictEnd

				LDX #0
:1				STX COUNT
				LDY :IND_TABLE,X
				JSR	CEQUIP_TO_TEXT
				LDX COUNT
				LDY REQUIP_LINES,X
				LDX #66
				JSR DRAW_TEXTBUF_XY
				LDX COUNT
				INX
				CPX #7
				BNE :1

				LDY	#e1_HEAD
				LDA	(CHARDL),Y
				AND	#%00011000
				LSR
				LSR
				LSR
				LDX #<RTREAD_NAMES
				LDY #>RTREAD_NAMES
				JSR GET_IND_STRING
				LDX #66
				LDY REQUIP_LINES+7
				JMP DRAW_TEXTBUF_XY

:IND_TABLE		DB	e2_SLOT
				DB	e3_UPLFT
				DB	e4_UPRGT
				DB	e5_LWLFT
				DB	e6_LWRGT
				DB	e7_BACK1
				DB	e15_PROGRAM

CLEAR_ROBO_ITEMS
				LDX #0
:1				STX COUNT
				LDA REQUIP_LINES,X
				STA :MODY1
				CLC
				ADC #7
				STA :MODY2
				JSR	DRAW_PICT
				DB OpClear
				DB 9
:MODY1			DB $FF
				DB 23
:MODY2			DB $FF
				PictEnd
				LDX COUNT
				INX
				CPX #8
				BNE :1
				RTS

REQUIP_LINES	DB	9
				DB	42
				DB	50
				DB	58
				DB	64
				DB	113
				DB	137
				DB  161					; movement type

RTREAD_NAMES	USR(TREAD)=
				USR(LEVITATOR)=
				USR(TETRA-LEG)=
				USR(BI-LEG)=

DRAW_ROBO_INFO	JSR DRAW_PICT
				PictTextAt 171;4;()-
				USR(NAME:\n)-
				USR(PROF:\n)-
				USR(LEVL:\n)-
				USR(OWNR:)
				PictMoveTo $CC;4
				PictCall CNAME_TO_TEXT
				PictTextbufRet
				PictCall CPROF_TO_TEXT
				PictTextbufRet
				PictEnd

				LDX #0
				LDY	#e15_PROGRAM+1
				LDA	(CHARDL),Y
				AND	#$08
				BNE	:1
				JSR CLEVEL_TO_TEXT
				LDY	#e15_PROGRAM+1
				LDA	(CHARDL),Y
				BPL	:2
				LDA	#$0B
				STA	TEXT_BUFFER,X
				INX
:1				LDA	#TextLineEnd
				STA	TEXT_BUFFER,X
:2				JSR DRAW_TEXTBUF_RET

				; find the owner cybernate linked to this robot
				;*** move this to CHARACTER.S?
				LDY	#robotcyblink
				LDA	(CHARDL),Y
				PHA
				LDX #0
:3				TXA
				JSR	SET_CHAR
				PLA
				PHA
				LDY	#disklocation
				CMP	(CHARDL),Y
				BEQ	:4
				INX
				BNE	:3
:4				PLA
				JSR CNAME_TO_TEXT
				JSR DRAW_TEXTBUF_RET

				LDA	ISOURCE_CHAR
				JMP	SET_CHAR

;-------------------------------------------------------------------------------

; used by I.COMPRESS, I.REGENERATE, I.TRANSFER, and I.USE

BIG_STATS_BOX	LDA #$42
				STA SELECT

				JSR DRAW_PICT
                PictClear 24;50;39;51
				PictSetPage1
				PictClearPage
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

				JSR RESET_CHRLIST
				LDA	#$00
				STA	LEGALS+7
				RTS

HIDE_BIG_STATS  JSR DRAW_PICT
                PictClear 24;80;39;105
                PictSwap $00;$50;$28;$00
                PictEnd
                RTS

;-------------------------------------------------------------------------------
