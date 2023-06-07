
FIRST_MONSTER	ENT
				LDA #0
				BEQ SET_MONSTER			; always

NEXT_MONSTER	ENT
				INC MONSTER_INDEX
				LDA MONSTER_INDEX
				CMP MONSTER_COUNT
				BCS :1
				JSR SET_MONSTER
				CLC
:1  			RTS
;
; On entry:
;	A: monster index (0-24)
;
; Called directly by loader when making monsters
;
				ERR	20-bytespermons
SET_MONS_PTR	ENT
				LDY #>MONSTR0
				CMP #$0D
				BCC :1
				INY
:1				STY MONS_PTR_H
				ASL
				ASL
				STA MONS_PTR
				ASL
				ASL
				CLC
				ADC MONS_PTR
				STA MONS_PTR
				RTS
;
; On entry:
;	A: monster index (0-24)
;
; On exit:
;	MONS_PTR,+1: Address of monster instance data
;
SET_MONSTER		ENT
				AND	#%00011111			; isolate monster index
				STA MONSTER_INDEX
				JSR SET_MONS_PTR
				LDY	#monNUMBER
				LDA	(MONS_PTR),Y
				TAX
				; fall through
;
; On entry:
;	X: alien class index (0-2)
;
; On exit:
;	ALIEN_PTR,+1: Address of alien class data
;	X,Y: unchanged
;
SET_ALIEN_CLASS	ENT
				STX ALIEN_INDEX
				LDA ALIEN_PTRS_L,X
				STA ALIEN_PTR
				LDA ALIEN_PTRS_H,X
				STA ALIEN_PTR_H

				LDA TV_WIDTHS,X
				STA TVIEW_WIDTH
				LDA TV_HEIGHTS,X
				STA TVIEW_HEIGHT
				RTS
