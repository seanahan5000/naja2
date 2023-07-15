
DRAW_ALLMONS    ENT
				JSR FIRST_MONSTER
:1              LDY #monSTATUS
                LDA (MONS_PTR),Y
                CMP #dead
                BEQ :2
                JSR DRAW_ALIEN
:2              JSR NEXT_MONSTER
                BCC :1
                RTS

DRAW_ALIEN		ENT

				LDY	#monPOSITION
				LDA	(MONS_PTR),Y
				SEC
				SBC	#$05
				JSR	POS_TO_XY
				JSR MGRID_MOVETO

				; TODO: remove once all topviews are updated to wide grid
				LDX #1
				JSR HMOVE

				LDY	#monNUMBER
				LDA	(MONS_PTR),Y
				TAY
				LDX TV_PTRS_L,Y
				LDA TV_PTRS_H,Y
				TAY
				JMP NEW_DRAW_SHAPE

; TODO: move this SHARED/TOPVIEWS.S?

;
; On entry:
;   X: grid X position
;   Y: monster grid Y position
;
MGRID_MOVETO    LDA GRID_XPNTS,X
                TAX
                LDA AGRID_YPNTS,Y
                TAY
                JMP MOVE_TO
