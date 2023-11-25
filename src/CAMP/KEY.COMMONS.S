
; TODO: should this be used here?
TEMP			=	LOCAL_TEMP

*--------------------------------------------------------
* On entry:
*   X,Y point to a data structure:
*
*   Max cursor position, exclusive (byte)
*      If high bit set, clear out LEGALS for minmax range
*   Starting position (byte)
*   Address of cursor routine (word)
*   Address of destination table (word) optional
*
* On exit:
*   Carry Set if SPACE BAR pressed
*   Carry Clear if INTERCEPT routine caught something
*   DESTINATION set up with a jump to the address from
*      destination table that corresponds with the cursor
*   CURSOR holds the current position
*	X holds CURSOR value

MENU_INIT		ENT						; was INIT_CURSOR
				STX	TEMP
				STY	TEMP+1
				LDY	#$00
				LDA	(TEMP),Y
				PHP
				AND	#%01111111
				STA	MAXIMUM
				INY
				LDA	(TEMP),Y
				STA	CURSOR
				INY
				LDA	(TEMP),Y
				STA	DCUR_MOD+1
				INY
				LDA	(TEMP),Y
				STA	DCUR_MOD+2
				INY
				LDA	(TEMP),Y
				STA	JUMP_MOD+1
				INY
				LDA	(TEMP),Y
				STA	JUMP_MOD+2
				PLP
				BPL	:2
				LDX	#0
				TXA
:1   			STA	LEGALS,X
				INX
				CPX	MAXIMUM
				BNE	:1
:2				LDX CURSOR
				JSR	DOWN_SUB2
                LDA #$18                ; CLC
				STA CANCEL_MOD
				LDX	#<DEFAULT_FILTER
				LDY	#>DEFAULT_FILTER
				; fall through
MENU_SET_FILTER	ENT
				STX FILTER_MOD+1
				STY FILTER_MOD+2
DEFAULT_FILTER	RTS

BLINK_LOOP		LDA	#$10
				JSR	WAIT
				LDA	#$F0
				JSR	WAIT_KEY
				BMI	MENU_SELECT2
				CLC
				JSR	BLINK_CURSOR	; blink erase
				LDA	#$00
				JSR	WAIT_KEY
; On entry:
;   MENU_INIT called to set up menu
;
; On exit:
;   X: CURSOR
;   Status: based on CURSOR
;
MENU_SELECT 	ENT					; was GETKEY
				CLC
				JSR	BLINK_CURSOR	; blink draw
MENU_SELECT2	ENT
; GETKEY2			ENT					; legacy
				SEC
FILTER_MOD		JSR	$FFFF
				BCC	BLINK_OUT
				JSR RANDOM
				LDA	KEYBRD
				BPL	BLINK_LOOP
				BIT	UNSTROB
				JSR	CHECK_UP
				BEQ	UP
				JSR	CHECK_DOWN
				BEQ	DOWN
				JSR	CHECK_ENTER
                BEQ ENTER
CANCEL_MOD      CLC
                BCC MENU_SELECT2
				JSR CHECK_CANCEL
				BNE	MENU_SELECT2
				JSR	MENU_DRAW_CURSOR	; erase
				CLC
				RTS

ENTER           JSR	MENU_DRAW_CURSOR	; erase
				LDA CURSOR
				ASL
				TAX
				LDY #-2
JUMP_MOD		LDA $FFFF,X
				STA MENU_TARGET+1-254,Y
				INX
				INY
				BMI JUMP_MOD
				SEC
BLINK_OUT		LDX CURSOR
				RTS

UP				JSR	MENU_DRAW_CURSOR	; erase
				LDX	CURSOR
:1				TXA
  				BNE :2
				LDX MAXIMUM
:2				DEX
				LDA LEGALS,X
				BNE :1
				STX CURSOR
				JSR	MENU_DRAW_CURSOR	; draw
				JMP	MENU_SELECT2

DOWN			JSR	MENU_DRAW_CURSOR	; erase
MENU_SELECT_NEXT ENT
				JSR	DOWN_SUB1
				JSR	MENU_DRAW_CURSOR	; draw
				JMP	MENU_SELECT2

DOWN_SUB1		LDX	CURSOR
DOWN_LOOP		INX
				CPX	MAXIMUM
				BNE	DOWN_SUB2
				LDX #0
DOWN_SUB2		LDA	LEGALS,X
				BNE	DOWN_LOOP
				STX CURSOR
				RTS

; TODO: eventually move this into a flag in definition
MENU_SET_CANCEL ENT
                LDA #$38                ; SEC
				STA CANCEL_MOD
				RTS

MENU_DRAW_CURSOR ENT
				SEC
BLINK_CURSOR	LDX CURSOR
DCUR_MOD		JMP $FFFF

; DESTINATION							; legacy
MENU_TARGET		ENT
                JMP	$FFFF

MAXIMUM			DB	0
