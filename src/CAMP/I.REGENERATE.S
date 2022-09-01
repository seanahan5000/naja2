
TBUFFER			=	$0210				;***

; MEDIC_CHAR		=	ISOURCE_CHAR

                DUMMY   SCRATCH_PAGE
DNEW1           DS  2
; DVAL1           DS  2
; ETEXT1          DS  8

ENEW2x          DS  3
; EVAL2           DS  3
; ETEXT2          DS  8
                DEND

********************************
* On Entry:
*   Acc = 0: Cell regenerator
*       = 1: Circuit repairer

REGENERATE		STA	HEAL_TYPE+1
				JSR	BIG_STATS_BOX

RECYCLE			JSR DRAW_PICT
				PictTextAt 180;84;(GIVE_TREATMENT)
				PictTextAt 198;93;(TO_WHOM?)
				PictEnd

HEAL_TYPE		LDA	#$FF				; modified
				BNE	CIRCUITS
				JSR	RESET_CHLIST
				JMP	BOTH_TYPES
CIRCUITS		JSR	RESET_CHRLIST
				LDA	#robot*16
				JSR	CSCAN_PROF
BOTH_TYPES		LDX	#<NEED_HEAL
				LDY	#>NEED_HEAL
				JSR	CSCAN_COMMON
				JSR	PRE_ARROW
				JSR	MENU_SELECT
				CPX #7
				BNE :NO_CANCEL
                JMP HIDE_BIG_STATS      ; return back to C.ISTATS.S

:NO_CANCEL		STX	ITARGET_CHAR

				;*** same as I.TRANSFER.S ***
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
				;*** clear energy ***
				JSR STATS_LINE

				JSR DRAW_PICT
				PictTextAt 48;26;(DAMAGE_TO_HEAL:)
				PictEnd

				LDA MEDIC_CHAR
				JSR SET_CHAR
				LDY #38
				JSR VMOVE_TO
				;*** clear damage ***
				JSR STATS_LINE

				JSR DRAW_PICT
				PictTextAt 195;51;(C>ANCEL)
				PictEnd

                LDA ITARGET_CHAR
                JSR SET_CHAR
                LDY #damagelev+1
                LDX #1
:2              LDA (CHARDL),Y
                STA DNEW1,X
                DEY
                DEX
                BPL :2

                LDA MEDIC_CHAR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:3              LDA (CHARDL),Y
                STA ENEW2x,X
                DEY
                DEX
                BPL :3




:HANG			JMP	:HANG

				;*** ERASE "GIVE_TREATMENT..."

				JSR	DEMARK

				LDA	ITARGET_CHAR
				JSR	SET_CHAR

				JSR DRAW_PICT
				PictTextAt 180;84;(GIVE_TREATMENT\nTO_)
				PictCall DRAW_TRIMMED_NAME
				PictEnd

				JSR	CALC_MAX
				LDA	#0
				STA	HBUFFER+0
				STY	HBUFFER+1
				STY	HHOLDER
				STX	HBUFFER+2
				STX	HHOLDER+1

				JSR DRAW_PICT
				PictSetPage1
				PictSetGreen
				PictRect $A5;$51;$115;$BF
				PictEnd

				LDA	MEDIC_CHAR
				JSR	SET_CHAR

				JSR DRAW_PICT
				PictMoveTo 171;110
				PictCall DRAW_TRIMMED_NAME
				PictText (_CAN)
				PictTextAt 171;118;(TREAT_UP_TO_)
				PictEnd

				; LDA	#$06
				; STA	MAXTEXT
				JSR	HACKUP
				; JSR	LINE2

				; LDY	#$2D
				; JSR	TEXTER2
; TEXT2D		PLOTAT	171;126;(OF_)-
; NAME2B		USR	(XXXXXXXXXX'S)
; 				PLOTAT	171;134;(DAMAGE.)
; 				PLOTAT	171;147;(TREAT_HOW_MUCH)
; 				PLOTAT	171;155;(DAMAGE?_)+

				LDX	#$68
				LDY	#$BF
				LDA	#$E6
				; JSR	STATCOM			;*** SWAP SCREEN BUFFERS

				JSR DRAW_PICT
				PictSetPage2
				PictMoveTo $AB;$68
				PictLineTo $10F;$68
				PictEnd

				; LDY	#$12
				; JSR	TEXTER2
; CANCER		PLOTAT	16;70;(CANCEL)+

				LDA #6
				LDX	#$DB
				LDY	#$9B
				JSR GET_INPUT_LIMIT

HEALIN			LDY	#$04
INLOOP0			LDA	TEXTBUF,Y
				STA	TBUFFER,Y
				DEY
				BPL	INLOOP0
				LDX	#$04
INLOOP1			LDA	TBUFFER,X
				CMP	#$8D
				BEQ	INSKIP0
				DEX
				BPL	INLOOP1
INSKIP0			CPX	#$00
				BEQ	GOHCANC
INLOOP2			LDA	TBUFFER-1,X
				CMP	#$0A
				BNE	INSKIP1
				DEX
				BNE	INLOOP2
INSKIP1			LDA	#$8D
				STA	TBUFFER,X
				LDA	TBUFFER
				CMP	#$8D
				BNE	INSKIP2
GOHCANC			JMP	HCANCEL
INSKIP2			LDX	#$01
INLOOP3			LDA	TBUFFER,X
				CMP	#$8D
				BEQ	INSKIP3
				INX
				BNE	INLOOP3
INSKIP3			LDY	#$04
INLOOP4			LDA	TBUFFER,X
				STA	TBUFFER,Y
				DEY
				BMI	INSKIP4
				DEX
				BPL	INLOOP4
				LDA	#$A0
INLOOP5			STA	TBUFFER,Y
				DEY
				BPL	INLOOP5
INSKIP4			LDX	#$00
INLOOP6			LDA	TBUFFER,X
				CMP	#$A0
				BNE	INSKIP5
				LDA	#$00
				STA	TBUFFER,X
				INX
				BNE	INLOOP6
INSKIP5			LDA	TBUFFER,X
				EOR	#$B0
				CMP	#$0A
				BCS	BADNUM
				STA	TBUFFER,X
				INX
				CPX	#$04
				BNE	INSKIP5
				LDX	#$00
				LDY	#$00
INLOOP7			LDA	TBUFFER,X
				ASL
				ASL
				ASL
				ASL
				INX
				ORA	TBUFFER,X
				INX
				STA	AMHOLD,Y
				INY
				CPY	#$02
				BNE	INLOOP7
				LDA	AMHOLD
				ORA	AMHOLD+1
				BEQ	BADNUM
				SEC
				SED
				LDA	HHOLDER+1
				SBC	AMHOLD+1
				LDA	HHOLDER
				SBC	AMHOLD
				CLD
				BCS	GOODNUM
BADNUM			;JSR	CHAROUT
				JSR	REGET_INPUT
				JMP	HEALIN

GOODNUM			JSR DRAW_PICT
				PictClear $18;$69;$27;$BF
				PictEnd

				BIT	UNSTROB

				; LDY	#$2F
				; JSR	TEXTER2
; TEXT2F		PLOTAT	171;110;(TREATING_)+

				LDA	#$00
				STA	HBUFFER
				LDA	AMHOLD
				STA	HBUFFER+1
				LDA	AMHOLD+1
				STA	HBUFFER+2
				JSR	HACKUP
				; JSR	LINE2

				; LDY	#$30
				; JSR	TEXTER2
; TEXT30		PLOTAT	171;118;(DAMAGE_REQUIRES)+

; TODO: make this fixed energy to damage heal rate variable?
				LDA	#$00
				STA	ENHOLD+2
				STA	HBUFFER+2
				CLC
				SED
				LDA	AMHOLD+1
				ADC	AMHOLD+1
				STA	ENHOLD+1
				STA	HBUFFER+1
				LDA	AMHOLD
				ADC	AMHOLD
				STA	ENHOLD
				STA	HBUFFER
				CLD
				JSR	HACKUP
				; LDA	#$AB
				; LDY	#$7E
				; JSR	LINE
				; LDA	XCOORD
				; STA	TEXT31
				; LDA	SHIFT
				; STA	TEXT31+1

				; LDY	#$31
				; JSR	TEXTER2
; TEXT31		PLOTAT	0;126;(_ENERGY.)

				JSR DRAW_PICT
				PictTextAt 171;139;(PRESS_<SPACE>_TO)
				PictTextAt 171;147;(VERIFY_TREATMENT.)
				PictTextAt 201;160;(C>ANCEL)
				PictEnd

INKEY			LDA	KEYBRD
				BPL	INKEY
				BIT	UNSTROB
				JSR	CHECK_ENTER
				BEQ	HSPACIN
				CMP	#"C"
				BNE	INKEY
				JMP	HCANCEL

HSPACIN			LDY	ITARGET_CHAR
				LDA	YPOINTS,Y
				STA	YPNT
				TYA
				JSR	SET_CHAR
				JSR	DODAMAG
				LDY	#damagelev+1	;Heal damage
				SEC
				SED
				LDA	(CHARDL),Y
				SBC	AMHOLD+1
				STA	(CHARDL),Y
				DEY
				LDA	(CHARDL),Y
				SBC	AMHOLD
				STA	(CHARDL),Y
				LDY	#damagemax+1	;Remove critical status
				LDA	(CHARDL),Y
				SEC
				LDY	#damagelev+1
				SBC	(CHARDL),Y
				TAX
				LDY	#damagemax
				LDA	(CHARDL),Y
				LDY	#damagelev
				SBC	(CHARDL),Y
				CLD
				BNE	:SKIPA
				CPX	#critical_amnt+1
				BCC	:SKIPB
:SKIPA			LDY	#status
				LDA	(CHARDL),Y
				AND	#%10111111
				STA	(CHARDL),Y
:SKIPB			JSR	CALC_ALL		;Update stats
				JSR	DODAMAG
				LDY	MEDIC_CHAR
				LDA	YPOINTS,Y
				STA	YPNT
				TYA
				JSR	SET_CHAR
				JSR	DOENER
				LDX	#<ENHOLD
				LDY	#>ENHOLD
				SEC
				JSR	DRAINER_MAIN
				JSR	DOENER

HCANCEL
				; LDY	#$12
				; JSR	TEXTER2
; CANCER		PLOTAT	16;70;(CANCEL)+

				JSR DRAW_PICT
				PictClear $18;$51;$27;$BF
				PictEnd

				LDX	#$BF
				LDY	#$51
				LDA	#$C6
				; JSR	STATCOM			;*** SWAP SCREEN BUFFERS
				JSR	DEMARK
				JMP	RECYCLE

DEMARK			LDY	MEDIC_CHAR
				; JSR	MARKSUB
				LDY	ITARGET_CHAR
				CPY	MEDIC_CHAR
				BEQ	:1
				; JSR	MARKSUB
:1				RTS

DODAMAG			; JSR	DAMAGR2
				LDA	#$8A
				LDY	YPNT
				; JMP	LINE

DOENER			; JSR	POWROUT
				LDA	#$8D
				STA	TEXTBUF+6
				LDA	#$C6
				LDY	YPNT
				; JMP	LINE

; 3-byte value in HBUFFER -> TEXT_BUFFER (left justified)
HACKUP			LDX	#$02
				LDY	#$05
HALOOP1			LDA	HBUFFER,X
				PHA
				AND	#$0F
				STA	TEXTBUF,Y
				DEY
				PLA
				LSR
				LSR
				LSR
				LSR
				STA	TEXTBUF,Y
				DEY
				DEX
				BPL	HALOOP1
				LDA	#TextLineEnd
				STA	TEXTBUF+6
				LDX	#$00
HALOOP2			LDA	TEXTBUF,X
				BNE	HASKIP1
				LDA	#TextEmpty
				STA	TEXTBUF,X
				; DEC	MAXTEXT
				INX
				BNE	HALOOP2
HASKIP1			RTS

HHOLDER			DB	0,0
HBUFFER			DB	0,0,0

CALC_MAX		LDA	MEDIC_CHAR
				JSR	SET_CHAR
				LDY	#energylev+1
				LDA	(CHARDL),Y
				TAX
				DEY
				LDA	(CHARDL),Y
				TAY
; TODO: make this fixed energy to damage heal rate variable?
				LDA	#$50
				JSR	PERCENT_OF
				STX	:MODA+1
				STY	:MODB+1
				LDA	ITARGET_CHAR
				JSR	SET_CHAR
				LDY	#damagelev+1
				SEC
				SED
				LDA	(CHARDL),Y
:MODA			SBC	#$FF
				TAX
				DEY
				LDA	(CHARDL),Y
:MODB			SBC	#$FF
				CLD
				BCS	:1
				LDA	(CHARDL),Y
				TAX
				INY
				LDA	(CHARDL),Y
:1				TAY
				RTS

NEED_HEAL		LDY	#damagelev
				LDX	#$00
				LDA	(CHARDL),Y
				BNE	:1
				INY
				LDA	(CHARDL),Y
				BNE	:1
				INX
:1				TXA
				RTS

AMHOLD			DB	$00,$00
ENHOLD			DB	$00,$00,$00
