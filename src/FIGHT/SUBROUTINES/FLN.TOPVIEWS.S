*-------------------------------
*
*-------------------------------

DRAW_ALIEN		LDY	#monPOSITION
				LDA	(MONS_PTR),Y
DRAW_ALIEN_AT	JSR	ADJUST_XYPNTS
				LDX	TVIEW_HOLDPTR
				LDY	TVIEW_HOLDPTR+1
				LDA	TVIEW_DIMENS


*-------------------------------------------------------------
* On Entry:
*         X,Y: Address of shape to be drawn
*           A: High/low nibble width/height of shape in chars
*   XPNT,YPNT: X and Y screen coordinate to draw shape at
*-------------------------------------------------------------

DRAW_TOPVIEW	STX DATPNTL
				STY DATPNTH
				TAX
				LDA XPNT
				STA XCOORD
				LDA YPNT
				STA YCOORD
				TXA
				AND	#%00001111
				TAY
				TXA
				LSR
				LSR
				LSR
				LSR
				TAX
				JMP DRAW_SHAPE

*---------------------------------------------
* On Entry:
*   A: Grid position byte
*
* On Exit:
*   XPNT,YPNT: Screen coordinates of top view
*---------------------------------------------

ADJUST_XYPNTS	SEC
				SBC	#$05
				JSR	POS_TO_XY
				LDA	GRID_XPNTS,X
				STA	XPNT
				LDA	GRID_YPNTS,Y
				SEC
				SBC	#$37
				STA	YPNT
				LDA	TVIEW_OFFSET
				TAX
				AND	#%00001111
				CLC
				ADC	YPNT
				STA	YPNT
				TXA
				LSR
				LSR
				LSR
				LSR
				CLC
				ADC	XPNT
				STA	XPNT
				RTS

*-------------------------------
