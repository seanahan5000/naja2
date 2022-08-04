
; XCOORD:
; YCOORD:
; XCOUNT:
; YCOUNT:
; DATPNTL,H:

DRAW_SHAPE      ENT
                STX XCOUNT
                STY YCOUNT
                LDA #<CELL_BUFFER
                STA CELL_SRC_MOD+1
                LDA #>CELL_BUFFER
                STA CELL_SRC_MOD+2

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
:3              STA CELL_BUFFER,X
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
                JSR DRAW_CELL

                DEC XCOUNT
                BEQ :5
                INC XCOORD          ; advance by 7 pixels
                BNE NEXT_TCOL       ; always

:5              LDA YCOORD
                CLC
                ADC #7
                STA YCOORD
                PLA                 ; pull XCOORD
                TAX
                PLA                 ; pull XCOUNT
                DEC YCOUNT
                BNE NEXT_TLINE
                RTS

; TODO: move this?
CELL_BUFFER     DS  7

;-------------------------------------------------------------------------------
; Input:
;   YCOORD: current Y position
;
; Output:
;   TABLER_L,H: list of 7 hires line pointers
;-------------------------------------------------------------------------------

; TODO: make this private again once MAP.S stops using it
TABLER          ENT
                LDY YCOORD
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

TABLER_Y        DB  $FF
; TODO: move these?
TABLER_L        DS  7
TABLER_H        DS  7

;-------------------------------------------------------------------------------
; Choose a letter of the font and set it as the current tile.
;
;   A: index of letter
;-------------------------------------------------------------------------------

SET_LETTER      LDX #<FONT
                LDY #>FONT
                ; fall through

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
;   CELL_SRC_MOD+1,2: pointer to selected tile
;
;-------------------------------------------------------------------------------

; NOTE: only public for HALLS/MAP.S to use
SET_CELL        ENT
                STX :LOW_MOD+1
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
                STA CELL_SRC_MOD+1
                BCS :2
                DEY
:2              STY CELL_SRC_MOD+2
                RTS

;-------------------------------------------------------------------------------
; Draw the cell either previously set with by SET_CELL or DRAW_SHAPE.
;
; Input:
;   XCOORD: current X byte column position (0 to #39)
;   XSHIFT: current X right shift (0 to 6)
;   TABLER_L,H: list of 7 hires line pointers
;   CELL_SRC_MOD+1,2: pointer to source data
;
; Uses:
;   SCREENL,H
;   SCRATCH
;-------------------------------------------------------------------------------

SHIFT_BITS      =   LOCAL_TEMP

; NOTE: only public for HALLS/MAP.S to use
DRAW_CELL       ENT
                LDX #6
DCLOOP1         LDA #0
                STA SHIFT_BITS
                LDA TABLER_L,X
                STA SCREENL
                LDA TABLER_H,X
                STA SCREENH
CELL_SRC_MOD    LDA $FFFF,X
                BEQ :3
                LDY XSHIFT
                BEQ :2                  ;*** recheck the value of this ***
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
                BPL DCLOOP1
                SAME_PAGE_AS DCLOOP1
                RTS

;-------------------------------------------------------------------------------
