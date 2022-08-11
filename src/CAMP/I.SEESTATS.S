SEESTAT			JSR	DRAW_PICT
				PictSetPage1
				PictClearPage
				PictSetGreen
				PictRect $A5;$00;$115;$BF
				PictTextAt 171;54;()-
				USR	(STATUS:\n)-
				USR	(DAMAGE:\n)-
				USR	(SHIELD:_E-___P-\n)-
				USR	(CREDIT:)
				PictTextAt 204;95;(ENERGY)
				PictTextAt 171;118;()-
				USR	(INTELLIGENCE:\n)-
				USR	(____STRENGTH:\n)-
				USR	(UPPER_REFLEX:\n)-
				USR	(LOWER_REFLEX:\n)-
				USR	(___%_ORGANIC:\n)-
				USR	(_%_INORGANIC:)

				PictMoveTo 171;$32
				PictLineTo 271;$32

				PictMoveTo 171;$5B
				PictLineTo 271;$5B

				PictMoveTo 171;$72
				PictLineTo 271;$72

				PictMoveTo 171;$AD
				PictLineTo 271;$AD

				PictMoveTo 171;$AF
				PictLineTo 271;$AF

				PictMoveTo 171;$B1
				PictLineTo 271;$B1

				PictMoveTo $DB;$36
				PictEnd

				JSR STATUS_TO_TEXT
				JSR DRAW_TEXTBUF_RET

				; TODO: change this to HEALTH
				JSR DAMAGE_TO_TEXT_L
				JSR DRAW_TEXTBUF_RET

				LDY	#Eshielding
				JSR CSTAT_TO_TEXT_L
				LDX	#$E7
				JSR DRAW_TEXTBUF_X

				JSR DRAW_PICT
				PictHMoveTo $105
				PictEnd
				LDY	#Pshielding
				JSR CSTAT_TO_TEXT_L
				JSR DRAW_TEXTBUF_RET

				; TODO: switch this over to pooled credits
; 				LDY	#profrace
; 				LDA	(CHARDL),Y
; 				BMI	OVRCRED
; 				LDA	#$51
; 				STA	YPNT
; 				LDA	#$DB
; 				STA	XPNT
; 				JSR	CHAR_CREDOUT
; OVRCRED
				JSR	ENERGY_TO_TEXT
				LDX	#$B7
				LDY	#$68
				JSR	DRAW_TEXTBUF_XY

				LDX #$FF
				LDY #$76
				JSR MOVE_TO
				LDX #0
NEXSTAT			STX COUNT
				LDY	:STAT_LIST,X
				JSR CSTAT_TO_TEXT_R
				JSR DRAW_TEXTBUF_RET
				LDX COUNT
				INX
				CPX #5
				BNE	NEXSTAT

				; draw inorganic (100 - organic) stat
				LDY	#organic
				LDA (CHARDL),Y
				STA COUNT
				LDA	#$00
				SEC
				SED
				SBC	COUNT
				CLD
				STA (CHARDL),Y
				JSR CSTAT_TO_TEXT_R
				JSR DRAW_TEXTBUF_RET
				LDY	#organic
				LDA COUNT
				STA (CHARDL),Y

				JSR DRAW_PICT
				PictSwap $17;$32;$28;$B4
				PictEnd
				BIT	UNSTROB
				JSR SET_PAGE2
				LDX	#<:STAT_DEF
				LDY	#>:STAT_DEF
				JSR	MENU_INIT
				JSR	MENU_SELECT
				JSR DRAW_PICT
				PictSwap $17;$B3;$28;$31
				PictEnd
				LDX	#5
				JSR	IMARKER
				JMP	IMENU

:STAT_LIST		DB	intelligence
				DB	strength
				DB	upreflex
				DB	lwreflex
				DB	organic

*-------------------------------
:STAT_DEF		DB	$00
				DB	$80
				DW	:STAT_CURS

:STAT_CURS		LDX	#$A7
				LDY	#$B5
				JMP	DRAW_ARROW
*-------------------------------
