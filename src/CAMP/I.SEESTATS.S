SEESTAT			JSR	DRAW_PICT
				PictSetPage1
				PictClearPage
				PictSetGreen
				PictRect $A5;$00;$115;$BF
				PictTextAt_ 171;54
				TXC	"STATUS:\n"
				TXC	"HEALTH:\n"
				TXC	"SHIELD:\n"
				TXT	"CREDIT:"
				PictTextAt 204;95;"ENERGY"
				PictTextAt_ 171;118
				TXC	"INTELLIGENCE:\n"
				TXC	"    STRENGTH:\n"
				TXC	"UPPER REFLEX:\n"
				TXC	"LOWER REFLEX:\n"
				TXC	"   % ORGANIC:\n"
				TXT	" % INORGANIC:"

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
				PictEnd

				JSR DRAW_STATS_VALS

				JSR DRAW_PICT
				PictSwap $17;$32;$28;$B3
				PictSetPage2
				PictEnd
				BIT	UNSTROB
IMENU_SEE		LDX	#<STAT_DEF
				LDY	#>STAT_DEF
				JSR	MENU_INIT
				LDA #1
				STA STATS_VISIBLE
				LDX #<ISTAT_FILTER
				LDY #>ISTAT_FILTER
				JSR MENU_SET_FILTER
				JSR	MENU_SELECT
				JSR DRAW_PICT
				PictSetPage1
				PictCopyToPage
				PictShowPage
				PictEnd
				PLA
				PLA
				JMP	RESTATS

STAT_LIST		DB	intelligence
				DB	strength
				DB	upreflex
				DB	lwreflex
				DB	organic

*-------------------------------
STAT_DEF		DB	$81
				DB	$00
				DW	:STAT_CURS

:STAT_CURS		LDX	#$A7
				LDY	#$B5
				JMP	DRAW_ARROW
*-------------------------------

DRAW_STATS_VALS JSR DRAW_PICT
				PictMoveTo $DB;$36
				PictCall CSTATUS_TO_TEXT_L
				PictTextbufRet
				PictCall HEALTH_TO_TEXT_L
				PictTextbuf
				PictTextAt 219;72;"E-   P-\n"
				PictMoveTo 231;72
				PictEnd

				LDY	#Eshielding
				JSR CSTAT_TO_TEXT_L

				JSR DRAW_PICT
				PictTextbuf
				PictHMoveTo $105
				PictEnd

				LDY	#Pshielding
				JSR CSTAT_TO_TEXT_L
				JSR DRAW_TEXTBUF

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
				JSR DRAW_PICT
				PictMoveTo $B7;$68
				PictTextbuf
				PictMoveTo $FF;$76
				PictEnd

				LDX #0
NEXSTAT			STX COUNT
				LDY	STAT_LIST,X
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
				RTS

;-------------------------------------------------------------------------------
