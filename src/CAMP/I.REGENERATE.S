
HNEW			=	ENEW1
HVAL			=	EVAL1
HTEXT			=	ETEXT1

ENEW			=	ENEW2
EVAL			=	EVAL2
ETEXT			=	ETEXT2

; On Entry:
;   A: 0 = Cell regenerator
;      1 = Circuit repairer
;
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

:NO_CANCEL      JSR RT_START

				JSR DRAW_PICT
				PictTextAt 40;26-2;(DAMAGE_TO_HEAL:)
				PictEnd

                LDA ITARGET_CHAR
                JSR SET_CHAR
                LDY #damagelev+1
                LDX #1
:1              LDA (CHARDL),Y
                STA DVAL,X
                DEY
                DEX
                BPL :1

                ; force computation of HNEW (assumes ITARGET_CHAR set)
                LDA #6
                STA CURSOR
                JSR HEAL_DAMAGE

                LDA ISOURCE_CHAR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:2              LDA (CHARDL),Y
                STA ENEW2,X
                DEY
                DEX
                BPL :2

				JSR REG_UPDATE_FIRST

                ; set cursor based on target damage level
                LDY #0
                LDX #0
:4              LDA ETEXT1,X
                CMP #TextSpace
                BNE :5
                INX
                INY
                CPY #5
                BNE :4
:5              STY CURSOR

                JSR REG_CURSIT

RBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI :GOTKEY
                JSR REG_CURSIT
                LDA #$00
                JSR WAIT_KEY
                JSR REG_CURSIT
                BIT KEYBRD
                BPL RBLINK
:GETKEY         LDA KEYBRD
                BPL :GETKEY
:GOTKEY         BIT UNSTROB
                JSR CHECK_LEFT
                BEQ :LEFT
                JSR CHECK_RIGHT
                BEQ :RIGHT
                JSR CHECK_UP
                BEQ :UP
                JSR CHECK_DOWN
                BEQ :DOWN
                CMP #"C"
                BEQ :CANCEL
                JSR CHECK_ENTER
                BNE :GETKEY

:ENTER			LDA ITARGET_CHAR
                JSR SET_CHAR
                LDY DVAL+0
                LDX DVAL+1
                JSR HEALER

				LDA ISOURCE_CHAR
                JSR SET_CHAR
				LDX	#<EVAL
				LDY	#>EVAL
				SEC
				JSR	DRAINER_MAIN

:CANCEL			JSR DRAW_PICT
				PictClear 27;51;34;58
				PictSwap $00;$31;$28;$00
				PictEnd
                RTS                     ; back to C.ISTATS.S

:LEFT           LDA CURSOR
				CMP #2
                BEQ :GETKEY
                JSR REG_CURSIT
                DEC CURSOR
                JSR REG_CURSIT
	            JMP :GETKEY

:RIGHT          LDA CURSOR
                CMP #5
                BEQ :GETKEY
                JSR REG_CURSIT
                INC CURSOR
                JSR REG_CURSIT
             	JMP :GETKEY

:UP             LDA ITARGET_CHAR
                JSR SET_CHAR
                JSR HEAL_DAMAGE
                BCC :RIGHT
                JSR TAKE_ENERGY
                BCC :RIGHT
                JSR REG_UPDATE
                JMP :GETKEY

:DOWN           LDA ITARGET_CHAR
                JSR SET_CHAR
                JSR UNHEAL_DAMAGE
                BCC :RIGHT
                JSR TAKE_ENERGY
                BCC :RIGHT
                JSR REG_UPDATE
                JMP :GETKEY

REG_CURSIT		LDY #26-2
				LDX #126
				LDA #119
				JMP RT_CURSIT
;
; On exit:
;   C=1: successful heal
;   C=0: failed heal
;
HEAL_DAMAGE		LDY CURSOR
                LDX AM_OFFSETS,Y
				SED
				SEC
				LDY #1
:1				LDA DVAL,Y
				SBC AMOUNTS,X
				STA DNEW,Y
				DEX
				DEY
				BPL :1
				BCS HEAL_UNHEAL
				CLD
                RTS

UNHEAL_DAMAGE	LDY CURSOR
                LDX AM_OFFSETS,Y
				SED
				CLC
				LDY #1
:1				LDA DVAL,Y
				ADC AMOUNTS,X
				STA DNEW,Y
				DEX
				DEY
				BPL :1

HEAL_UNHEAL		SEC
				LDY #damagelev+1
				LDX #1
:1				LDA (CHARDL),Y
				SBC DNEW,X
				STA ENEW+1,X
				DEY
				DEX
				BPL :1
				LDA #0
				STA ENEW+0
				BCC :3

;				SEC
				LDY #damagemax+1
				LDX #1
:2				LDA (CHARDL),Y
				SBC DNEW,X
				STA HNEW+1,X
				DEY
				DEX
				BPL :2
				LDA #0
				STA HNEW+0
:3				CLD
                RTS
;
; On exit:
;   C=1: successful energy drain
;   C=0: failed energy drain
;
TAKE_ENERGY		LDA ISOURCE_CHAR
				JSR SET_CHAR

				SED
				LDX #2
				CLC
:1				LDA ENEW,X
				; 2 energy per 1 damage
				ADC ENEW,X
				STA ENEW,X
				DEX
				BPL :1

                LDY #energylev+2
				LDX #2
				SEC
				LDA #0
:2				STA :MOD+1
				LDA (CHARDL),Y
				SBC ENEW,X
				STA ENEW,X
:MOD			ORA #$FF
				DEY
				DEX
				BPL :2
				BCC :5
				TAX
				BEQ :4

				LDX #1
:3				LDA DNEW,X
				STA DVAL,X
				DEX
				BPL :3
				DB	$24					; BIT ZP
:4				CLC
:5				CLD
				RTS

REG_UPDATE_FIRST
				LDA #$38				; SEC
				BNE RUPDATE_CMN			; always
REG_UPDATE      LDA #$18				; CLC
RUPDATE_CMN		STA :FIRST_MOD
				JSR SET_ELEFT
				LDA #138-12
                LDY #$0E
                JSR :UPDATE
                JSR SET_ERIGHT
                LDA #$C6
                LDY #$26
                ; fall through
:UPDATE         PHA
				JSR VMOVE_TO
                JSR RT_DIFF_TEXT
:FIRST_MOD      CLC
                PLA
                BCS :1
                PHA
                TAX
                JSR DRAW_TEXTBUF_X
                PLA
                TAX
                JSR HMOVE_TO
                LDX #<TEXT_BUFFER+8
                LDY #>TEXT_BUFFER+8
                JMP DRAW_TEXT
:1              RTS

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
