
; TODO: use LOCAL_TEMP?
TEMP_COLOR      =   $00
TEMP_TOGGLE     =   $01

;-------------------------------------------------------------------------------

;
; On Entry:
;   X: pointer to hook table (low)
;   Y: pointer to hook table (high)
;
SET_PICT_HOOKS  ENT
                STX OP_PTR
                STY OP_PTR_H
                LDY #0
:1              LDA (OP_PTR),Y
                STA OP_HOOKS,Y
                INY
                CPY #4
                BNE :1
                RTS
;
; On entry:
;   Return address points to list of Pict ops
;
; On exit:
;   BNE always true
;
DRAW_PICT       ENT
                PLA
                STA OP_PTR
                PLA
                STA OP_PTR_H
                LDY #1                  ; adjust for return address

:DISPATCH       LDA (OP_PTR),Y
                CMP #OpEnd
                BEQ :DONE
                BCS :ERROR
                INY
                ASL A
                TAX
                LDA OP_TABLE+0,X
                STA :OP_MOD+1
                LDA OP_TABLE+1,X
                STA :OP_MOD+2
                STY OP_INDEX
:OP_MOD         JSR $FFFF
                LDA OP_PTR
                CLC
                ADC OP_INDEX
                STA OP_PTR
                LDY #0
                BCC :DISPATCH
                INC OP_PTR_H
                BCS :DISPATCH           ; always

:ERROR          BRK
:DONE           LDA OP_PTR_H
                PHA
                LDA OP_PTR
                PHA
                LDA #TextLineHeight     ; restore text height on PictEnd
                STA TEXT_HEIGHT
                RTS                     ; BNE always true

OP_TABLE        DW  OP_SET_COLOR
                DW  OP_MOVE
                DW  OP_MOVE_TO
                DW  OP_MOVE_TO_H
                DW  OP_HMOVE
                DW  OP_HMOVE_TO
                DW  OP_HMOVE_TO_H
                DW  OP_VMOVE
                DW  OP_VMOVE_TO
                DW  OP_HLINE_TO
                DW  OP_HLINE_TO_H
                DW  OP_VLINE_TO
                DW  OP_HSAVE
                DW  OP_HRESTORE
                DW  OP_RECT
                DW  OP_RECT_H
                DW  OP_FILLRECT
                DW  OP_FILLRECT_H
                DW  OP_SET_TEXT_HEIGHT
                DW  OP_SET_TEXTBOX
                DW  OP_SET_TEXTBOX_H
                DW  OP_TEXT
                DW  OP_TEXT_AT
                DW  OP_TEXT_IN
                DW  OP_TEXT_ROWS
                DW  OP_TEXTBUF
                DW  OP_TEXTBUF_X
                DW  OP_TEXTBUF_XY
                DW  OP_TEXTBUF_RET
                DW  OP_IMAGE
                DW  OP_IMAGE_FILL
                DW  OP_TILE
                DW  OP_CLEAR
                DW  OP_COPY_TO
                DW  OP_SWAP
                DW  SET_PAGE1
                DW  SET_PAGE2
                DW  SET_PAGEX
                DW  SHOW_PAGE
                DW  SHOW_PAGE1
                DW  SHOW_PAGE2
                DW  CLEAR_PAGE
                DW  CLEAR_PAGE1
                DW  CLEAR_PAGE2
                DW  COPY_TO_PAGE
                DW  COPY_TO_PAGE1
                DW  COPY_TO_PAGE2
                DW  OP_CALL

                DW  OP_SWITCH
                DW  OP_CASE

OP_HOOKS        DW  $FFFF               ; OP_HOOK0
                DW  $FFFF               ; OP_HOOK1

OP_CALL         LDA (OP_PTR),Y
                TAX
                INY
                LDA (OP_PTR),Y
                INY
                STY OP_INDEX
OP_CALL_PROC    STX :CALL_MOD+1
                STA :CALL_MOD+2
                LDA OP_PTR
                PHA
                LDA OP_PTR_H
                PHA
                LDA OP_INDEX
                PHA
:CALL_MOD       JSR $FFFF
                PLA
                STA OP_INDEX
                PLA
                STA OP_PTR_H
                PLA
                STA OP_PTR
                RTS

OP_SWITCH       LDA (OP_PTR),Y
                STA :MOD+1
:MOD            LDA $FF
                STA SWITCH_INDEX
                INY
                STY OP_INDEX
                RTS

OP_CASE         LDA SWITCH_INDEX
                BEQ :1
                TYA
                CLC
                ADC (OP_PTR),Y
                TAY
:1              INY
                STY OP_INDEX
                DEC SWITCH_INDEX
                RTS

;-------------------------------------------------------------------------------

; TODO: expand these out

SET_GREEN       ENT
                LDA #OpColorGreen
                BNE SET_COLOR           ; always

SET_WHITE1      ENT
                LDA #OpColorWhite1
                BNE SET_COLOR           ; always

OP_SET_COLOR    LDA (OP_PTR),Y
                INY
                STY OP_INDEX
;
; On entry:
;   A: new OpColor
;
; On exit:
;   X,Y: unchanged
;
SET_COLOR       ENT
                STA OP_COLOR            ; TODO: does this really need a zpage?
                RTS

;-------------------------------------------------------------------------------

; NOTE: also called by OP_TEXT_AT
OP_MOVE_TO      LDA (OP_PTR),Y
                INY
                TAX
                LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAY
;
; On entry:
;   X: new horizontal position
;   Y: new vertical position
;
; On exit:
;   X: unchanged
;   Y: unchanged
;
MOVE_TO         ENT
                LDA DIV7,X
                STA XCOORD
                LDA MOD7,X
                STA XSHIFT
                STY YCOORD
                RTS

OP_MOVE_TO_H    LDA (OP_PTR),Y
                INY
                TAX
                JSR HMOVE_TO_H
OP_VMOVE_TO     LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAY
;
; On entry:
;   Y: new vertical position
;
; On exit:
;   X: unchanged
;   Y: unchanged
;
VMOVE_TO        ENT                     ; X must be unchanged
                STY YCOORD
                RTS

OP_HMOVE_TO     LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAX
HMOVE_TO        ENT
                LDA DIV7,X
                STA XCOORD
                LDA MOD7,X
                STA XSHIFT
                RTS

OP_HMOVE_TO_H   LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAX
HMOVE_TO_H      ENT                     ; Y must be unchanged
                LDA DIV7HI,X
                STA XCOORD
                LDA MOD7HI,X
                STA XSHIFT
                RTS

OP_VMOVE        LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAY
VMOVE           ENT                     ; X must be unchanged
                TYA
                CLC
                ADC YCOORD
                STA YCOORD
                RTS

OP_HMOVE        LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAX
HMOVE           ENT
                TXA
                CLC
                ADC XSHIFT
                BMI :2
                TAX
                SEC
                SBC #7
                BCC :1
                TAX
                INC XCOORD
:1              STX XSHIFT
                RTS
:2              CLC
                ADC #7
                STA XSHIFT
                DEC XCOORD
                RTS

OP_MOVE         LDA (OP_PTR),Y
                INY
                TAX
                LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAY
MOVE            JSR VMOVE
                JMP HMOVE

OP_HSAVE
HSAVE           ENT
                LDA XCOORD
                STA XMOD0+1
                LDA XSHIFT
                STA XMOD1+1
                RTS

OP_HRESTORE
HRESTORE        ENT
XMOD0           LDA #$FF
                STA XCOORD
XMOD1           LDA #$FF
                STA XSHIFT
                RTS

;-------------------------------------------------------------------------------

OP_IMAGE_FILL   SEC
                DB  $24                 ; BIT ZPAGE
OP_IMAGE        CLC
                LDA (OP_PTR),Y
                INY
                TAX
                LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAY
                BCS :1
                JMP UNPACK
:1              JMP UNPACK_FILL

;-------------------------------------------------------------------------------

OP_TILE         LDA (OP_PTR),Y
                INY
                TAX
                LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAY
                JMP DRAW_TILE

;-------------------------------------------------------------------------------

OP_FILLRECT_H   SEC
                DB  $24                 ; BIT ZPAGE
OP_FILLRECT     CLC
                LDA #$38                ; SEC
                STA FILLRECT_MOD
                JSR OP_RECT_CMN
                LDA #$18                ; CLC
                STA FILLRECT_MOD
                RTS

OP_RECT_H       SEC
                DB  $24                 ; BIT ZPAGE
OP_RECT         CLC
OP_RECT_CMN     LDA (OP_PTR),Y
                INY
                TAX
                LDA DIV7,X
                STA LEFT_DIV7
                LDA MOD7,X
                STA LEFT_MOD7
                LDA (OP_PTR),Y
                INY
                STA TOP
                LDA (OP_PTR),Y
                INY
                TAX
                LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                STA BOTTOM
                BCS :1
                LDY DIV7,X
                LDA MOD7,X
                BCC :2                  ; always
:1              LDY DIV7HI,X
                LDA MOD7HI,X
:2              STY RIGHT_DIV7
                STA RIGHT_MOD7

DO_RECT         LDX OP_COLOR
                LDA TOGGLE_TABLE,X
                STA TEMP_TOGGLE
                LDA LEFT_DIV7
                LSR A
                LDA COLOR_TABLE,X
                BCC :1
                EOR TEMP_TOGGLE
:1              STA TEMP_COLOR

                LDY LEFT_DIV7
                CPY RIGHT_DIV7
                BNE :2
                JMP THIN_RECT
:2
                LDX TOP
RECT_LOOP       STX TOP
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH

                LDY LEFT_DIV7
                LDX LEFT_MOD7
                LDA (SCREENL),Y
                EOR TEMP_COLOR
                AND LEFT_MASKS,X
                EOR TEMP_COLOR
                STA (SCREENL),Y

                LDA TEMP_COLOR
                PHA
:1              EOR TEMP_TOGGLE
                INY
                CPY RIGHT_DIV7
                BEQ :2
                STA (SCREENL),Y
                BNE :1                  ; always

:2              STA TEMP_COLOR
                LDX RIGHT_MOD7
                LDA (SCREENL),Y
                EOR TEMP_COLOR
                AND RIGHT_MASKS,X
                EOR TEMP_COLOR
                STA (SCREENL),Y

                PLA
                STA TEMP_COLOR

                LDX TOP
                CPX BOTTOM
                BNE :3
                RTS

:3              INX
FILLRECT_MOD    CLC
                BCS RECT_LOOP

OR_MASK_L       =   LEFT_MASK
OR_MASK_R       =   RIGHT_MASK

                LDA TEMP_COLOR
                ASL
                BNE :COLOR

:BLACK          LDA #0
                ROR
                STA OR_MASK_L
                STA OR_MASK_R

                LDX LEFT_MOD7
                LDA BIT_TABLE,X
                ORA #$80
                EOR #$FF
                STA AND_MASK_L

                LDX RIGHT_MOD7
                LDA BIT_TABLE,X
                ORA #$80
                EOR #$FF
                STA AND_MASK_R
                BNE :1                  ; always

:COLOR          LDA #0
                ROR
                TAY
                LDX LEFT_MOD7
                ORA BIT_TABLE,X
                STA OR_MASK_L
                TYA
                LDX RIGHT_MOD7
                ORA BIT_TABLE,X
                STA OR_MASK_R

                LDA #$7F
                STA AND_MASK_L
                STA AND_MASK_R

:1              LDX TOP
:2              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH

                LDY LEFT_DIV7
                LDA (SCREENL),Y
                AND AND_MASK_L
                ORA OR_MASK_L
                STA (SCREENL),Y

                LDY RIGHT_DIV7
                LDA (SCREENL),Y
                AND AND_MASK_R
                ORA OR_MASK_R
                STA (SCREENL),Y

                INX
                CPX BOTTOM
                BNE :2
                JMP RECT_LOOP       ; always

THIN_RECT       LDX LEFT_MOD7
                LDA LEFT_MASKS,X
                LDX RIGHT_MOD7
                ORA RIGHT_MASKS,X
                STA :MASK_MOD+1
;               LDY LEFT_DIV7
                LDX TOP
                DEX
:1              INX
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDA (SCREENL),Y
                EOR TEMP_COLOR
:MASK_MOD       AND #$FF
                EOR TEMP_COLOR
                STA (SCREENL),Y
                CPX BOTTOM
                BNE :1
                RTS

; TODO: move these into TABLES.S???
COLOR_TABLE     DB  $00,$2A,$55,$7F
                DB  $80,$AA,$D5,$FF

TOGGLE_TABLE    DB  $00,$7F,$7F,$00
                DB  $00,$7F,$7F,$00

;-------------------------------------------------------------------------------

OP_HLINE_TO_H   LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAX
HLINE_TO_H      ENT
                LDY MOD7HI,X
                LDA DIV7HI,X
                BPL OP_HLINE_COM    ; always

OP_HLINE_TO     LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAX
HLINE_TO        ENT
                LDY MOD7,X
                LDA DIV7,X

OP_HLINE_COM    TAX
                LDA YCOORD
                STA TOP
                STA BOTTOM
                CPX XCOORD
                BCS :TO_RIGHT

:TO_LEFT        LDA XCOORD
                STA RIGHT_DIV7
                LDA XSHIFT
                STA RIGHT_MOD7
                STX XCOORD
                STX LEFT_DIV7
                STY XSHIFT
                STY LEFT_MOD7
                JMP DO_RECT

:TO_RIGHT       LDA XCOORD
                STA LEFT_DIV7
                LDA XSHIFT
                STA LEFT_MOD7
                STX XCOORD
                STX RIGHT_DIV7
                STY XSHIFT
                STY RIGHT_MOD7
                JMP DO_RECT

;-------------------------------------------------------------------------------

OP_CLEAR        LDA (OP_PTR),Y
                INY
                STA :LEFT_MOD+1
                LDA (OP_PTR),Y
                INY
                TAX
                LDA (OP_PTR),Y
                INY
                STA :RIGHT_MOD+1
                LDA (OP_PTR),Y
                INY
                STA :BOTTOM_MOD+1
                STY OP_INDEX

:1              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
:LEFT_MOD       LDY #$FF
                LDA #$00
:2              STA (SCREENL),Y
                INY
:RIGHT_MOD      CPY #$FF
                BNE :2
                INX
:BOTTOM_MOD     CPX #$FF
                BNE :1
                SAME_PAGE_AS :1
                RTS

;-------------------------------------------------------------------------------

OR_MASK         =   LEFT_MASK

OP_VLINE_TO     LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAY
VLINE_TO        ENT
                TYA
                CMP YCOORD
                LDX YCOORD
                BCS :1
                STX BOTTOM
                TAX
                BCC :2                  ; always
:1              STA BOTTOM
:2              STA YCOORD

                LDY OP_COLOR
                LDA COLOR_TABLE,Y
                ASL
                BEQ :3

                LDA #$FF
                ROR
                STA AND_MASK
                AND #$80
                LDY XSHIFT
                ORA BIT_TABLE,Y
                STA OR_MASK

:4              LDY XCOORD
:5              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDA (SCREENL),Y
                AND AND_MASK
                ORA OR_MASK
                STA (SCREENL),Y
                INX
                CPX BOTTOM
                BCC :5
                BEQ :5
                SAME_PAGE_AS :5
                RTS

; NOTE: this is here to keep :5 loop on same page
:3              LDA #$00
                ROR
                STA OR_MASK
                EOR #$80
                LDY XSHIFT
                ORA BIT_TABLE,Y
                EOR #$FF
                STA AND_MASK
                BNE :4                  ; always

;-------------------------------------------------------------------------------
;
; Copy an area of the screen to current page, from opposite page.
;   Unlike OP_SWAP, only top-to-bottom copy is supported here
;
;   left byte
;   top line
;   right byte (exclusive)
;   bottom line (exclusive)

OP_COPY_TO      LDA (OP_PTR),Y
                INY
                STA :LEFT_MOD+1
                LDA (OP_PTR),Y
                INY
                TAX
                LDA (OP_PTR),Y
                INY
                STA :RIGHT_MOD+1
                LDA (OP_PTR),Y
                INY
                STA BOTTOM
                STY OP_INDEX

:1              LDA LOBYTES,X
                STA DESTINL
                STA SCREENL
                LDA HIBYTES,X
                STA DESTINH
                EOR #$60
                STA SCREENH
:LEFT_MOD       LDY #$FF
:2              LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
:RIGHT_MOD      CPY #$FF
                BNE :2
                INX
                CPX BOTTOM
                BNE :1
                SAME_PAGE_AS :1
                RTS

;-------------------------------------------------------------------------------
;
; Exchange an area of the screen between page 1 and 2
;
;   left byte
;   top line (INCLUSIVE)
;   right byte (exclusive)
;   bottom line (INCLUSIVE)
;
; If top > bottom, transfer happens in reverse order.

OP_SWAP         LDA (OP_PTR),Y
                INY
                STA :LEFT_MOD+1
                LDA (OP_PTR),Y
                INY
                TAX
                LDA (OP_PTR),Y
                INY
                STA :RIGHT_MOD+1
                LDA (OP_PTR),Y
                INY
                STA BOTTOM
                STY OP_INDEX

                LDY #$E8                ; INX
                CPX BOTTOM
                BCC :1
                LDY #$CA                ; DEX
:1              STY :INX_MOD
                BNE :2                  ; always

:INX_MOD        INX
:2              LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA SCREENH
                EOR #$60
                STA DESTINH
                STX TOP
:LEFT_MOD       LDY #$FF
:3              LDA (SCREENL),Y
                TAX
                LDA (DESTINL),Y
                STA (SCREENL),Y
                TXA
                STA (DESTINL),Y
                INY
:RIGHT_MOD      CPY #$FF
                BNE :3
                LDX TOP
                CPX BOTTOM
                BNE :INX_MOD
                ; SAME_PAGE_AS :INX_MOD
                RTS

;-------------------------------------------------------------------------------
