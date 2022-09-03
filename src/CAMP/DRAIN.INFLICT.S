DRAIN_DIRECT2	LDA	#0
DRAIN_DIRECT3	PHP
				STX	DRAIN_AMOUNT+2
				STY	DRAIN_AMOUNT+1
				STA	DRAIN_AMOUNT+0
				JMP	DRAIN_MERGE

*------------------------------------------------------
* On Entry:
*   X = Address of amount to drain low
*   Y = Address of amount to drain high
*   (amount to drain is high to low)
*   Carry Set = Update energy level and status in
*               character data
*   Carry Clear = Report changes that would occur if
*                 energy level and status were updated
*
* On Exit:
*   A = New status
*   BMI true = Character became rundown
*   BPL true = Character didn't change rundown status
*   Carry Set = Had enough energy
*   Carry Clear = Did NOT have enough energy

DRAINER_MAIN	PHP
				STX	TEMP
				STY	TEMP+1
				LDY	#$02
:LOOP1			LDA	(TEMP),Y
				STA	DRAIN_AMOUNT,Y
				DEY
				BPL	:LOOP1

DRAIN_MERGE		LDY	#status
				LDA	(CHARDL),Y
				STA	NEW_STATUS
				STA	OLD_STATUS

				LDA	#$38			;Set Carry
				STA	:MOD1

				LDY	#energylev+2
				LDX	#$02
				SEC
				SED
:LOOP2			LDA	(CHARDL),Y
				SBC	DRAIN_AMOUNT,X
				STA	DRAIN_AMOUNT,X
				DEY
				DEX
				BPL	:LOOP2
				CLD
				BCC	:SKIPA
				ORA	DRAIN_AMOUNT+1
				ORA	DRAIN_AMOUNT+2
				BNE	:SKIPB
				BEQ	:SKIPD			;Always
:SKIPA			LDA	#$18			;Clear Carry
				STA	:MOD1
:SKIPD			LDA	NEW_STATUS		;Character has become rundown
				ORA	#rundown
				STA	NEW_STATUS
				LDA	#$00
				STA	DRAIN_AMOUNT+0
				STA	DRAIN_AMOUNT+1
				STA	DRAIN_AMOUNT+2
:SKIPB			PLP
				BCC	:SKIPC
				LDY	#energylev+2
				LDX	#$02
:LOOP3			LDA	DRAIN_AMOUNT,X
				STA	(CHARDL),Y
				DEY
				DEX
				BPL	:LOOP3
				JSR	CALC_ALL
:SKIPC			LDA	NEW_STATUS
				TAX
				EOR	OLD_STATUS
				PHP
				TXA
				PLP
:MOD1			SEC					;Modified
				RTS

; TODO: use zpage to reduce code size
DRAIN_AMOUNT	DB	$00,$00,$00

; Set energy level to a specific value
;
; On entry:
;
;	X: address of energy level low
;	Y: address of energy level high
;
SET_ENERGY_LEVEL
				STX :MOD+1
				STY :MOD+2
				LDX #2
				LDY #energylev+2
:MOD			LDA $FFFF,X
				STA (CHARDL),Y
				DEY
				DEX
				BPL :MOD
				; fall through

ENERGY_CHANGED	LDY	#status
				LDA	(CHARDL),Y
				AND	#%01111111			; clear rundown
				STA	(CHARDL),Y
				LDY #energylev+2
				LDX #2
:1				LDA (CHARDL),Y
				BNE :2
				DEY
				DEX
				BPL :1
				BMI :3					; always
:2				LDY	#status
				LDA	(CHARDL),Y
				ORA	#rundown			; set rundown
				STA	(CHARDL),Y
:3				; TODO: check for change in rundown status
				;	and skip this if no change
				RTS

*---------------------------------------------------------
* On Entry:
*   X = Infliction amount low
*   Y = Infliction amount high
*   Carry Set = Inflict the damage and change stat
*   Carry Clear = See what damage will do and report back
*
* On Exit:
*   A = New status byte
*   X = New damage level low
*   Y = New damage level high
*   Carry Set = Killed him
*   Carry Clear = Didn't kill him
*   Overflow Set = Made him go critical
*   Overflow Clear = Didn't change critical state

INFLICTER		STX	TEMP
				STY	TEMP+1
				PHP
				LDY	#status
				LDA	(CHARDL),Y
				STA	NEW_STATUS
				STA	OLD_STATUS

				LDY	#damagelev+1
				LDA	(CHARDL),Y
				CLC
				SED
				ADC	TEMP
				STA	TEMP
				DEY
				LDA	(CHARDL),Y
				ADC	TEMP+1
				STA	TEMP+1
				CLD
				BCS	:SKIPA
				SED
				LDY	#damagemax+1
				LDA	(CHARDL),Y
				SEC
				SBC	TEMP
				TAX
				DEY
				LDA	(CHARDL),Y
				SBC	TEMP+1
				CLD

				BCC	:SKIPA
				BNE	:SKIPB
				TXA
				BEQ	:SKIPA
				CMP	#critical_amnt+1
				BCS	:SKIPB

				LDA	NEW_STATUS		;Character went critical
				ORA	#critical
				STA	NEW_STATUS
				BNE	:SKIPB			;Always

:SKIPA			LDA	#dead			;Character died
				STA	NEW_STATUS
				LDY	#damagemax
				LDA	(CHARDL),Y
				STA	TEMP+1
				INY
				LDA	(CHARDL),Y
				STA	TEMP

:SKIPB			LDX	TEMP
				LDY	TEMP+1
				PLP
				BCC	:SKIPC
				LDY	#status
				LDA	NEW_STATUS
				STA	(CHARDL),Y
				LDY	#damagelev
				LDA	TEMP+1
				PHA
				STA	(CHARDL),Y
				INY
				LDA	TEMP
				PHA
				STA	(CHARDL),Y
				JSR	CALC_ALL
				PLA
				TAX
				PLA
				TAY
:SKIPC			LDA	OLD_STATUS
				EOR	NEW_STATUS
				STA	TEMP
				BIT	TEMP
				LDA	NEW_STATUS
				CMP	#dead
				BEQ	:EXIT
				CLC
:EXIT			RTS

; set damage to a specific level
;
; On entry:
;	X = damage level low
;	Y = damage level high
;
SET_DAMAGE_LEVEL
				TYA
				PHA
				LDY #damagelev+1
				TXA
				STA (CHARDL),Y
				DEY
				PLA
				STA (CHARDL),Y
				; fall through

; update critical status
DAMAGE_CHANGED	LDY	#status
				LDA	(CHARDL),Y
				AND	#%10111111			; clear critical
				STA	(CHARDL),Y
				LDY #damagemax
				LDA (CHARDL),Y
				PHA
				INY
				LDA (CHARDL),Y
				SEC
				SED
				LDY #damagelev+1
				SBC (CHARDL),Y
				TAX
				DEY
				PLA
				SBC (CHARDL),Y
				BNE :NOCRIT
				CPX	#critical_amnt+1
				BCS :NOCRIT
				LDY	#status
				LDA	(CHARDL),Y
				ORA #critical			; set critical
				STA	(CHARDL),Y
:NOCRIT			CLD
				; TODO: check for change in critical status
				;	and skip this if no change
				JMP	CALC_ALL

; TODO: use zpage to reduce code size
NEW_STATUS		DB	0
OLD_STATUS		DB	0
