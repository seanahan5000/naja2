
; XCOORD:
; YCOORD:
; XCOUNT:
; YCOUNT:
; DATPNTL,H:

DRAW_SHAPE      ENT
                STX XCOUNT
                STY YCOUNT
                LDA #<TILE_BUFFER
                STA TILE_SRC_MOD+1
                LDA #>TILE_BUFFER
                STA TILE_SRC_MOD+2

FIRST_TLINE     LDA XCOUNT
                LDX XCOORD

NEXT_TLINE      PHA
                STA XCOUNT
                TXA
                PHA

                LDA DIV7,X
                STA XCOORD
                LDA MOD7,X
                STA XSHIFT

                JSR TABLER

NEXT_TCOL       LDY #0
                LDX #0
:1              LDA (DATPNTL),Y
                BPL :2
                AND #$7F
                CPX #6
                BNE :3
:2              INY
:3              STA TILE_BUFFER,X
                INX
                CPX #7
                BNE :1

                ; advance data pointer to next cell

                TYA
                CLC
                ADC DATPNTL
                STA DATPNTL
                BCC :4
                INC DATPNTH
:4
                JSR BLIT_TILE
                DEC XCOUNT
                BNE NEXT_TCOL

                LDA YCOORD
                CLC
                ADC #7
                STA YCOORD
                PLA                 ; pull XCOORD
                TAX
                PLA                 ; pull XCOUNT
                DEC YCOUNT
                BNE NEXT_TLINE
                RTS

; TODO: move this? maybe to page $02?
TILE_BUFFER     DS  7

;-------------------------------------------------------------------------------
; Input:
;   YCOORD: current Y position
;
; Output:
;   TABLER_L,H: list of 7 hires line pointers
;-------------------------------------------------------------------------------

TABLER          LDY YCOORD
                CPY TABLER_Y
                BEQ :2
                STY TABLER_Y
                LDX #0
:1              LDA LOBYTES,Y
                STA TABLER_L,X
                LDA HIBYTES,Y
                STA TABLER_H,X
                INY
                INX
                CPX #7
                BNE :1
:2              RTS

; this gets reset when the page changes
TABLER_Y        DB  $FF
; TODO: move these? maybe to page $02?
TABLER_L        DS  7
TABLER_H        DS  7

;-------------------------------------------------------------------------------
; Choose a letter of the font and set it as the current tile.
;
; On entry:
;   A: index of letter
;   XCOORD,XSHIFT: set to x position
;   TABLER_L,H: set to y position
;
; On exit:
;   XCOORD: advanced to next x position
;-------------------------------------------------------------------------------

DRAW_LETTER     LDX #<FONT
                LDY #>FONT
                JSR SET_TILE
                JSR BLIT_TILE
                ; XCOORD has been incremented to advance by 7 pixels,
                ;   but letters are only 6 wide, so retreat by 1 here.
                LDX XSHIFT
                DEX
                BPL :1
                LDX #6
                DEC XCOORD
:1              STX XSHIFT
                RTS

;-------------------------------------------------------------------------------
; Compute pointer into indexed list of 7-byte tiles.
;   Multiply by 7 using (index << 3) - index
;
; Input:
;   X: low address of tile list
;   Y: high address of tile list
;   A: index of tile (assumed to be < #64)
;
; Output:
;   TILE_SRC_MOD+1,2: pointer to selected tile
;-------------------------------------------------------------------------------

SET_TILE        STX :LOW_MOD+1
                STA :HIGH_MOD+1
                ASL
                ASL                 ; (63 * 4 = 252)
                ASL                 ; (63 * 8 > 255 ?)
                BCC :LOW_MOD
                INY
                CLC
:LOW_MOD        ADC #$FF
                BCC :1
                INY
:1              SEC
:HIGH_MOD       SBC #$FF
                STA TILE_SRC_MOD+1
                BCS :2
                DEY
:2              STY TILE_SRC_MOD+2
                RTS

;-------------------------------------------------------------------------------
; On entry:
;   X: pointer to tile data (low)
;   Y: pointer to tile data (high)
;   A: index into tile data
;   XCOORD,XSHIFT: set to x position
;   YCOORD: set to y position
;
DRAW_TILE_A     ENT
                JSR SET_TILE
                JSR TABLER
                JMP BLIT_TILE

;-------------------------------------------------------------------------------
; On entry:
;   X: pointer to tile data (low)
;   Y: pointer to tile data (high)
;   XCOORD,XSHIFT: set to x position
;   YCOORD: set to y position
;
DRAW_TILE       ENT
                STX TILE_SRC_MOD+1
                STY TILE_SRC_MOD+2
                JSR TABLER
                ; fall through

;-------------------------------------------------------------------------------
; Draw the cell either previously set with by SET_TILE or DRAW_SHAPE_GROUP.
;
; Input:
;   XCOORD: current X byte column position (0 to #39)
;   XSHIFT: current X right shift (0 to 6)
;   TABLER_L,H: list of 7 hires line pointers
;   TILE_SRC_MOD+1,2: pointer to source data
;
; Uses:
;   SCREENL,H
;   LOCAL_TEMP
;-------------------------------------------------------------------------------

SHIFT_BITS      =   LOCAL_TEMP

BLIT_TILE       LDX #6
BLTLOOP1        LDA #0
                STA SHIFT_BITS
                LDA TABLER_L,X
                STA SCREENL
                LDA TABLER_H,X
                STA SCREENH
TILE_SRC_MOD    LDA $FFFF,X
                BEQ :3
                LDY XSHIFT
                BEQ :2
                ASL
:1              ASL
                ROL SHIFT_BITS
                DEY
                BNE :1
                LSR
:2              LDY XCOORD
                EOR (SCREENL),Y
                STA (SCREENL),Y
                LDA SHIFT_BITS
                BEQ :3
                INY
                EOR (SCREENL),Y
                STA (SCREENL),Y
:3              DEX
                BPL BLTLOOP1
                SAME_PAGE_AS BLTLOOP1
                INC XCOORD
                RTS

;-------------------------------------------------------------------------------
