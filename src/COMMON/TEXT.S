
; DRAW_STRING
;   include support for character name, other escapes
;   support text box, auto linefeed
;   support word break/wrap

; (generalize shape drawing to support text and topviews?)
; SET_SHAPE
; DRAW_SHAPE (with and without shift?)
; shape decompression?
; topview shape support?

; (TEXT)   T,E,X,T,$8D
; (TEXT)+  T,E,X,T,$8D,$FF
; (TEXT)-  T,E,X,T
; (TEXT)=  T,E,X,T^$80

; TODO: change these
SCRATCH         =   $00
SCRATCH1        =   $01

TEXT_PTR        =   $30
TEXT_PTR_H      =   $31
TEXT_INDEX      =   $32

; TODO: SHARE WITH ALL GRAPHICS?
LEFT_DIV7       =   $33
LEFT_MOD7       =   $34
RIGHT_DIV7      =   $35
MAX_DIV7        =   $37

WORD_DIV7       =   $38
WORD_MOD7       =   $39
WORD_INDEX      =   $3A

;-------------------------------------------------------------------------------
; On entry:
;   XCOORD: current X byte column
;   XSHIFT: current X shift position
;   YCOORD: current Y line position
;   X: Address of string (low)
;   Y: Address of string (high)
;-------------------------------------------------------------------------------

DRAW_TEXT       ENT
                STX TEXT_PTR
                STY TEXT_PTR_H

                LDA XCOORD
                STA LEFT_DIV7
                LDA XSHIFT
                STA LEFT_MOD7
                JSR TABLER

                LDY #0
:NEXT_CHAR      LDA (TEXT_PTR),Y
                BMI :SPECIAL_CHAR
                INY
                CMP #CharSpace
                BEQ :1
                STY TEXT_INDEX
                JSR SET_LETTER
                JSR DRAW_SHAPE
                LDY TEXT_INDEX
:1              JSR ADVANCE
                BNE :NEXT_CHAR      ; always

:SPECIAL_CHAR   INY
                CMP #CharLineEnd
                BEQ :DONE
                CMP #CharEmpty
                BEQ :NEXT_CHAR
                STY TEXT_INDEX
                CMP #CharLineBreak
                BEQ :NEXT_LINE
                CMP #CharInsert
                BCC :DONE

                AND #CharInsertMask
                TAX
:NEXT_INSERT    LDA INSERT_BUFFER,X
                INX
                CMP #CharLineEnd
                BEQ :NEXT_CHAR
                CMP #CharEmpty
                BEQ :NEXT_INSERT
                CMP #CharSpace
                BEQ :2
                STX WORD_INDEX
                JSR SET_LETTER
                JSR DRAW_SHAPE
                LDX WORD_INDEX
:2              JSR ADVANCE
                LDY TEXT_INDEX
                BNE :NEXT_INSERT    ; always

:NEXT_LINE      LDA LEFT_DIV7
                STA XCOORD
                LDA LEFT_MOD7
                STA XSHIFT

                LDA YCOORD
                CLC
                ADC #LineHeight
                CMP #192-7
                BCC :3
                LDA #192-7
:3              STA YCOORD
                JSR TABLER
                LDY TEXT_INDEX
                BNE :NEXT_CHAR      ; always

:DONE           TYA
                CLC
                ADC TEXT_PTR
                STA TEXT_PTR
                BCC :4
                INC TEXT_PTR_H
:4              RTS

;-------------------------------------------------------------------------------
; On entry:
;   X: left in pixels
;   Y: top in lines
;   A: width in pixels
;
; On exit:
;   LEFT_DIV7, LEFT_MOD7
;   RIGHT_DIV7
;
; NOTE: Right edge of text box is only to the byte, not shift position.
;-------------------------------------------------------------------------------

SET_TEXTBOX     ENT
                STY YCOORD
                STA RIGHT_DIV7
                LDA DIV7,X
                STA LEFT_DIV7
                LDA MOD7,X
                STA LEFT_MOD7
                TXA
                CLC
                ADC RIGHT_DIV7
                TAX
                LDA DIV7,X
                STA RIGHT_DIV7
                RTS

;-------------------------------------------------------------------------------
; On entry:
;   SET_TEXTBOX called
;   X: Address of string (low)
;   Y: Address of string (high)
;-------------------------------------------------------------------------------

WRAP_TEXTBOX    ENT
                LDA #$38            ; SEC
                BNE TEXTBOX_CMN     ; always

DRAW_TEXTBOX    ENT
                LDA #$18            ; CLC

TEXTBOX_CMN     STA WRAP_MOD
                STX TEXT_PTR
                STY TEXT_PTR_H
                JSR FIRST_LINE

:FIRST_WORD     LDY #0
:NEXT_WORD      LDA XCOORD
                STA WORD_DIV7
                LDA XSHIFT
                STA WORD_MOD7
                LDX #0
:NEXT_CHAR      LDA (TEXT_PTR),Y
                BMI :SPECIAL_CHAR
                CMP #CharSpace
                BEQ :BREAK_WORD
                INY
                STA WORD_BUFFER,X
                INX
                PHA
                JSR ADVANCE
                PLA
                CMP #CharFirstSymbol
                BCC :NEXT_CHAR
:BREAK_WORD     STY TEXT_INDEX
                TXA
                BEQ :DONE
                LDA #$FF
                STA WORD_BUFFER,X

                LDA XCOORD
                CMP MAX_DIV7
                BCC :WORD_FITS
                JSR NEXT_LINE
                JMP :DRAW_WORD

:WORD_FITS      LDA WORD_DIV7
                STA XCOORD
                LDA WORD_MOD7
                STA XSHIFT

:DRAW_WORD      LDY #0
                STY WORD_INDEX
:1              LDA WORD_BUFFER,Y
                BMI :TRIM_SPACE
                INY
                STY WORD_INDEX
                JSR SET_LETTER
                JSR DRAW_SHAPE
                JSR ADVANCE
                LDY WORD_INDEX
                BNE :1              ; always

:TRIM_SPACE     LDY TEXT_INDEX
:2              LDA (TEXT_PTR),Y
                CMP #CharSpace
                BNE :3
                JSR ADVANCE
                INY
                BNE :2              ; always

:3              LDA XCOORD
                CMP MAX_DIV7
                BCC :NEXT_WORD
                STY TEXT_INDEX
                JSR NEXT_LINE
                JMP :FIRST_WORD

:SPECIAL_CHAR   INY
                CMP #CharEmpty
                BEQ :NEXT_CHAR
                BNE :BREAK_WORD
                ; TODO: support #CharInsert here?

:DONE           LDA TEXT_PTR
                CLC
                ADC TEXT_INDEX
                STA TEXT_PTR
                BCC :5
                INC TEXT_PTR_H
:5              RTS

NEXT_LINE       LDA TEXT_PTR
                CLC
                ADC TEXT_INDEX
                STA TEXT_PTR
                BCC :1
                INC TEXT_PTR_H
:1              LDA #0
                STA TEXT_INDEX

                LDA YCOORD
                CLC
                ADC #LineHeight
                CMP #192-7
                BCC :2
                LDA #192-7
:2              STA YCOORD

FIRST_LINE      LDA LEFT_DIV7
                STA XCOORD
                LDA LEFT_MOD7
                STA XSHIFT
                JSR TABLER
                LDA RIGHT_DIV7
                STA MAX_DIV7
WRAP_MOD        CLC
                BCS SCAN_MAX_X
                RTS

SCAN_MAX_X      LDX #6
:1              LDY LEFT_DIV7
                INY
:2              LDA TABLER_L,X
                STA SCREENL
                LDA TABLER_H,X
                STA SCREENH
                LDA (SCREENL),Y
                BNE :3
                INY
                CPY MAX_DIV7
                BCC :2
                BCS :4              ; always
:3              STY MAX_DIV7
:4              DEX
                BPL :1
                RTS

;-------------------------------------------------------------------------------
; Move position right by one 7 pixel character
;
; On exit:
;   X,Y: Assumed unchanged
;   Z: 1 (BNE true)
;-------------------------------------------------------------------------------

ADVANCE         DEC XSHIFT
                BMI :1
                INC XCOORD
                RTS                 ; always BNE
:1              LDA #6
                STA XSHIFT
                RTS                 ; always BNE

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

TABLER_Y        DB  $FF
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
;   Multiply by 7 using (index << 4) - index
;
; Input:
;   X: low address of tile list
;   Y: high address of tile list
;   A: index of tile (assumed to be < #64)
;
; Output:
;   SHAPE_SRC_MOD+1,2: pointer to selected tile
;
; Uses:
;   SCRATCH, SCRATCH1
;-------------------------------------------------------------------------------

SET_SHAPE       STX SCRATCH1
                STA SCRATCH
                ASL
                ASL                 ; (63 * 4 = 252)
                ASL                 ; (63 * 8 > 255 ?)
                BCC :1
                INY
                CLC
:1              ADC SCRATCH1
                BCC :2
                INY
:2              SEC
                SBC SCRATCH
                STA SHAPE_SRC_MOD+1
                BCS :3
                DEY
:3              STY SHAPE_SRC_MOD+2
                RTS

;-------------------------------------------------------------------------------
; Draw the shape either previously set with by SET_SHAPE or in CHAROUT.
;
; Input:
;   XCOORD: current X byte column position (0 to #39)
;   XSHIFT: current X right shift (0 to 6)
;   TABLER_L,H: list of 7 hires line pointers
;   SHAPE_SRC_MOD+1,2: pointer to source data
;
; Uses:
;   SCREENL,H
;   SCRATCH
;-------------------------------------------------------------------------------

DRAW_SHAPE      LDX #6
DSLOOP1         LDA #0
                STA SCRATCH
                LDA TABLER_L,X
                STA SCREENL
                LDA TABLER_H,X
                STA SCREENH
SHAPE_SRC_MOD   LDA $FFFF,X
                ; TODO: skip if 0?
                LDY XSHIFT
                BEQ :2
                ASL A
:1              ASL A
                ROL SCRATCH
                DEY
                BNE :1
                LSR A
:2              LDY XCOORD
                EOR (SCREENL),Y
                STA (SCREENL),Y
                LDA SCRATCH
                BEQ :3
                INY
                EOR (SCREENL),Y
                STA (SCREENL),Y
:3              DEX
                BPL DSLOOP1
                SAME_PAGE_AS DSLOOP1
                RTS

;-------------------------------------------------------------------------------
; On entry:
;   A: ASCII character
;
; On exit:
;   A: Naja-format character
;   C: Set if conversion succeeded
;      Clear if conversion failed
;
FROM_ASCII      ;ENT
                ; TODO: implement
                SEC
                RTS

;-------------------------------------------------------------------------------
