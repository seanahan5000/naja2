
TOTALS_OUT		JSR	RESET_CHLIST
				JSR	CSCAN_NOTDEAD
				STA	GOOD_MEN

				LDX #$0A
				LDY #$5E
				JSR MOVE_TO

				LDA	#TextLineEnd
				STA	TEXTBUF+16
				LDY	#0
				STY	COUNT
:LOOP0			LDX	ALIEN1,Y
				INX
				BEQ	:SKIPC
				TYA
				TAX
				JSR	SET_ALIEN_CLASS
				LDY	#aName+15
:LOOP3			LDA	(ALIEN_PTR),Y
				STA	TEXTBUF,Y
				DEY
				BPL	:LOOP3
				LDA	COUNT
				ASL
				STA	TEMP
				ASL
;				CLC
				ADC	TEMP
				TAX
				LDY	#aExperience
				LDA	#6
				STA	TEMP
:LOOP4			LDA	(ALIEN_PTR),Y
				STA	CREDIT_ALIEN,X
				INY
				INX
				DEC	TEMP
				BNE	:LOOP4
				JSR DRAW_TEXTBUF_RET
:SKIPC			INC	COUNT
				LDY	COUNT
				CPY	#3
				BNE	:LOOP0

				LDA	#0
				LDX	#3
:LOOP1			STA	CRED_TOTAL,X
				STA	EXPR_TOTAL,X
				DEX
				BPL	:LOOP1
				STA	KILL_TOTAL

				LDY	#$5E
				JSR VMOVE_TO

				LDY #0
:LOOP2			STY COUNT
				LDX	ALIEN1,Y
				INX
				BEQ	:SKIPA
				JSR	ALIEN_LINE
:SKIPA			LDY	COUNT
				INY
				CPY	#3
				BNE	:LOOP2

TOTAL_LINE		JSR DRAW_PICT			; Draw TOTALS heading
				PictSetOrange			;	and dividing line
				PictHMoveTo $09
				PictHLineTo $10D
				PictVMove 3
				PictHMoveTo $0A
				PictText (EXPEDITION_TOTALS)
				PictEnd

				LDX #3					; Total alien kills
				CLC
				SED
				LDY	KILL_TOTAL
:1				TYA
				ADC KILLS,X
				STA KILLS,X
				STA TOTAL_CREDITS,X
				LDY #0
				DEX
				BPL :1
				CLD
				LDX	#100
				JSR	TOTAL_CREDOUT

				LDX	#3					; Total credits
				CLC
				SED
:LOOP1			LDA	CRED_TOTAL,X
				ADC	CREDITS,X
				STA	CREDITS,X
				STA	TOTAL_CREDITS,X
				DEX
				BPL	:LOOP1
				CLD
				LDX	#150
				JSR	TOTAL_CREDOUT

				LDX	#3					; Total experience
				CLC
				SED
:LOOP2			LDA	EXPR_TOTAL,X
				ADC	EXPERIENCE,X
				STA	EXPERIENCE,X
				STA	TOTAL_CREDITS,X
				DEX
				BPL	:LOOP2
				CLD
				LDX	#204
				JSR	TOTAL_CREDOUT

GROUP_ADD		JSR FIRST_CHAR
:1				LDA	CHAR_LIST,X
				BNE	:4

				; TODO: add to group total instead
				; LDX	#<CRED_TOTAL
				; LDY	#>CRED_TOTAL
				; JSR	CHAR_EARN

				LDY	#experience+3
				LDX	#3
				CLC
:2				LDA	(CHARDL),Y
				SED
				ADC	EXPR_TOTAL,X
				CLD
				STA	(CHARDL),Y
				DEY
				DEX
				BPL	:2
				BCC	:4
				LDA	#$99
:3				INY						; #experience first time through
				STA	(CHARDL),Y
				CPY	#experience+3
				BNE	:3
:4				JSR NEXT_CHAR
				BCC :1
				RTS

*-------------------------------
*
*-------------------------------

ALIEN_LINE		LDA #0
				STA TOTAL_CREDITS+0
				STA TOTAL_CREDITS+1
				STA TOTAL_CREDITS+2

				LDY	COUNT			;Aliens killed
				LDA	ATOTAL1,Y
				CLC
				SED
				ADC	KILL_TOTAL
				CLD
				STA	KILL_TOTAL
				STA TOTAL_CREDITS+3
				LDX	#100
				JSR	TOTAL_CREDOUT

				LDA	COUNT
				ASL
				STA	TEMP
				ASL
;				CLC
				ADC	TEMP
				PHA
				TAY
				LDX	#2				;Alien credit value
:LOOP1			LDA	CREDIT_ALIEN,Y
				STA	TOTAL_CREDITS,X
				INY
				INX
				CPX	#4
				BNE	:LOOP1
				JSR	CALC_SUB
				LDX	#150
				JSR	TOTAL_CREDOUT

				LDX	#3
				SED
				CLC
:LOOP2			LDA	CRED_TOTAL,X
				ADC	TOTAL_CREDITS,X
				STA	CRED_TOTAL,X
				DEX
				BPL	:LOOP2
				CLD

				PLA
				TAY
				LDX	#2				;Alien experience value
:LOOP3			LDA	EXPERI_ALIEN,Y
				STA	TOTAL_CREDITS,X
				INY
				INX
				CPX	#4
				BNE	:LOOP3
				JSR	CALC_SUB
				LDX	#204
				JSR	TOTAL_CREDOUT
				LDX	#3
				SED
				CLC
:LOOP4			LDA	EXPR_TOTAL,X
				ADC	TOTAL_CREDITS,X
				STA	EXPR_TOTAL,X
				DEX
				BPL	:LOOP4
				CLD

				LDY #9
				JMP VMOVE

*-------------------------------
*
*-------------------------------

; TODO: trim to 3 byte values
CALC_SUB		LDY	COUNT
				LDA	ATOTAL1,Y
				BNE	:SKIPA
				STA	TOTAL_CREDITS+2				;Special case zero aliens
				STA	TOTAL_CREDITS+3
				RTS
:SKIPA			LDX	TOTAL_CREDITS+3
				LDY	TOTAL_CREDITS+2
				JSR	MULTIPLY_12
				LDA	GOOD_MEN
				CMP	#6
				BEQ	:SKIPB
				LDX	#<PRODUCT_3
				LDY	#>PRODUCT_3
				LDA	#6
				JSR	MULTIPLY_13
				LDA	GOOD_MEN
				CMP	#1
				BEQ	:SKIPB
				LDY	PRODUCT_4
				LDX	PRODUCT_4+1
				JSR	DIVIDE_12
				STY	TOTAL_CREDITS+0
				STX	TOTAL_CREDITS+1
				TAY
				LDX	PRODUCT_4+2
				LDA	GOOD_MEN
				JSR	DIVIDE_12
				STX	TOTAL_CREDITS+2
				TAY
				LDX	PRODUCT_4+3
				LDA	GOOD_MEN
				JSR	DIVIDE_12
				STX	TOTAL_CREDITS+3
				RTS
:SKIPB			LDX	#2
:LOOP1			LDA	PRODUCT_3,X
				STA	TOTAL_CREDITS+1,X
				DEX
				BPL	:LOOP1
				RTS

*-------------------------------

; TODO: leverage other number drawing code

;
; Draw 3 byte/6 digit number
;
; On entry:
;	X: x position
;
TOTAL_CREDOUT	JSR HMOVE_TO
				LDY #1					; TODO: skip first byte for now
				LDX #0
:1				LDA TOTAL_CREDITS,Y
				PHA
				LSR
				LSR
				LSR
				LSR
				STA TEXT_BUFFER,X
				INX
				PLA
				AND #$0F
				STA TEXT_BUFFER,X
				INX
				INY
				CPY #4
				BNE :1
				LDA #TextLineEnd
				STA TEXT_BUFFER,X
				LDX #0
:2				LDA TEXT_BUFFER,X
				BNE :3
				LDA #TextSpace
				STA TEXT_BUFFER,X
:3				INX
				CPX #5
				BNE :2
				JMP	DRAW_TEXTBUF

; TODO: ZPAGE like ETABLE?
TOTAL_CREDITS	DS	4					; TODO: trim to 3 bytes
