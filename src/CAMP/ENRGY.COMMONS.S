
********************************
*
********************************

ENERGY_USAGE	ENT
				DB	$00,$00,$00		;Must be consecutive
PERWHAT			ENT
				DB	$00				;   in this order

; On entry:
;	A: TextSpace or TextEmpty
;	XCOORD/XSHIFT/YCOORD: position to draw text
;
DRAW_ENERGY_PER	ENT
				STA :FILL_MOD+1
				LDX #6
				LDA	ETABLE+0
				AND	#eq_identified
				BEQ	:4

; TODO: maybe convert back to using DIGITS_L or DIGITS_R

				LDY	#0
				LDX #0
:1				LDA	ENERGY_USAGE,Y
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
				CPY #3
				BNE :1
				LDA #TextLineEnd
				STA TEXT_BUFFER,X

				LDX #0
:2				LDA TEXT_BUFFER,X
				BNE :3
:FILL_MOD		LDA #$FF
				STA TEXT_BUFFER,X
				INX
				CPX #5
				BNE :2
:3				JSR DRAW_TEXTBUF

				LDX PERWHAT
:4				TXA
				LDX #<PERTEXTS
				LDY #>PERTEXTS
				LDA PERWHAT
				JSR GET_IND_STRING
				JMP DRAW_TEXTBUF

PERTEXTS		TXI	"/SWING"
				TXI	"/SHOT"
				TXI	"/USE"
				TXI	"/HEAL"
				TXI	"/ROUND"
				TXI	"/THROW"
				TXI	"??????/?????"

PARSTAT			ENT
				LDA	#TextLT
				STA	TEXTBUF
				LDA	#TextGT
				STA	TEXTBUF+2
				LDA	#TextLineEnd
				STA	TEXTBUF+3
				LDX	#TextDash
				LDA	ETABLE+0
				CMP	#$FF
				BEQ	NISKIP
				LDX	#Text1
				LDA	ETABLE+2
				AND	#eq_hands12
				BEQ	HOSKIP
				INX
HOSKIP			LDA	ETABLE+2
				AND	#eq_faulty
				BEQ	NFSKIP
				LDX	#$10
NFSKIP			LDY	#profrace
				LDA	(CHARDL),Y
				LSR
				LSR
				LSR
				LSR
				TAY
				LDA	PROUSAB,Y
				AND	ETABLE+3
				BNE	NUSKIP
				LDX	#$22
NUSKIP			LDA	ETABLE+0
				AND	#eq_broken
				BEQ	NBSKIP
				LDX	#$0C
NBSKIP			LDA	ETABLE+0
				AND	#eq_identified
				BNE	NISKIP
				LDX	#TextQuestion
NISKIP			STX	TEXTBUF+1
				RTS

; "profession usable" table
; TODO: this belongs with equipment-related code
; TODO: rename
PROUSAB			ENT
				DB	$01,$02,$04
				DB	$08,$10,$FF
				DB	$40,$80,$20

; TODO: rename
ENERUSE			ENT
				LDX	#$00
:LOOP1			LDA	(CHARDL),Y
				STA	ETABLE,X
				INY
				INX
				CPX	#$04
				BNE	:LOOP1

; TODO: rename
ENERGY2			ENT
				LDA	#$00
				LDX	#$02
:LOOP0			STA	ENERGY_USAGE,X
				DEX
				BPL	:LOOP0
				STX	PERWHAT

				LDA	ETABLE+0		;Called from in ARSENAL
				AND	#$1F
				CMP	#$04
				BEQ	:EXARMOR
				CMP	#$05			;HELMET
				BEQ	:EXIT
				CMP	#$1A			;PROGRAM
				BEQ	:EXIT

				LDX	#$00
:LOOP1			CMP	SETS,X
				BEQ	:SKIPA
				BCC	:EXIT
				INX
				BNE	:LOOP1			;Always

:SKIPA			LDA	ETABLE+0
				AND	#$1F
				CMP	#$03			;Misc equipment
				BNE	:SKIPB
				LDA	ETABLE+1
				AND	#%00000111
				CMP	#$06			;COMPRESSD PERSON, DATA CARD,
				BCS	:SKIPB			;   JUNK
				CMP	#$03
				BCS	:EXIT

:SKIPB			TXA
				ASL
				TAX
				LDA	SUBSETS,X
				STA	TEMP
				LDA	SUBSETS+1,X
				STA	TEMP+1
				LDY	#$00
:LOOP2			LDA	ETABLE+1
				CMP	(TEMP),Y
				BEQ	:SKIPC
				INY
				INY
				INY
				INY
				BNE	:LOOP2			;Always

:SKIPC			INY
				LDA	(TEMP),Y
				STA	PERWHAT
				LDX	#0
:LOOP4			INY
				LDA	(TEMP),Y
				STA	ENERGY_USAGE+1,X
				INX
				CPX	#2
				BNE	:LOOP4
				RTS

:EXARMOR		LDA	#0
				STA	TOTAL
				STA	TOTAL+1
				JSR	POWUSE_ARMORS
				LDA	TOTAL+1
				STA	ENERGY_USAGE+1
				LDA	TOTAL
				STA	ENERGY_USAGE+2
:EXIT			LDA	#Round
				STA	PERWHAT
				RTS
