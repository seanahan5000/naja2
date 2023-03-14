
; *** reconcile with TEXT.S ***

OP_PTR          =   $50
OP_PTR_H        =   $51
OP_INDEX        =   $52
OP_COLOR        =   $53

; TODO: SHARE WITH ALL GRAPHICS?
LEFT_DIV7       =   $54
LEFT_MOD7       =   $55
RIGHT_DIV7      =   $56
RIGHT_MOD7      =   $57
TOP             =   $58
BOTTOM          =   $59
AND_MASK        =   $5A
LEFT_MASK       =   $5B
RIGHT_MASK      =   $5C
MAX_DIV7        =   $5F             ; TEXT-only

; TODO: use LOCAL_TEMP
TEMP_COLOR      =   $00
TEMP_TOGGLE     =   $01

;-------------------------------------------------------------------------------

DRAW_PICT       ENT
                PLA
                STA OP_PTR
                PLA
                STA OP_PTR_H
                LDY #1              ; adjust for return address

:DISPATCH       LDA (OP_PTR),Y
                BMI :DONE
                INY
                ASL A
                TAX
                LDA OP_TABLE+0,X
                STA :OP_MOD+1
                LDA OP_TABLE+1,X
                STA :OP_MOD+2
                STY OP_INDEX
:OP_MOD         JSR $FFFF
                ; TODO: use Y here instead of OP_INDEX?
                LDA OP_PTR
                CLC
                ADC OP_INDEX
                STA OP_PTR
                LDY #0
                BCC :DISPATCH
                INC OP_PTR_H
                BCS :DISPATCH       ; always

:DONE           LDA OP_PTR_H
                PHA
                LDA OP_PTR
                PHA
                RTS

OP_TABLE        DW  OP_SET_COLOR
                DW  OP_MOVE_TO
                DW  OP_MOVE_TO_H
                DW  OP_HMOVE_TO
                DW  OP_HMOVE_TO_H
                DW  OP_VMOVE_TO
                DW  OP_VMOVE
                DW  OP_HLINE_TO
                DW  OP_HLINE_TO_H
                DW  OP_VLINE_TO
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
                DW  CLEAR_PAGE
                DW  COPY_TO_PAGE
                DW  OP_CALL

OP_CALL         LDA (OP_PTR),Y
                STA :CALL_MOD+1
                INY
                LDA (OP_PTR),Y
                STA :CALL_MOD+2
                INY
                STY OP_INDEX

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

;-------------------------------------------------------------------------------

; TODO: expand these out

OP_SET_COLOR    LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                STA OP_COLOR        ; TODO: does this really need a zpage?
                RTS

SET_GREEN       ENT
                LDA #OpColorGreen
                STA OP_COLOR
                RTS

SET_WHITE1      ENT
                LDA #OpColorWhite1
                STA OP_COLOR
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
MOVE_TO         ENT
                LDA DIV7,X
                STA XCOORD
                LDA MOD7,X
                STA XSHIFT
                STY YCOORD
                RTS

OP_VMOVE_TO     LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                TAY
VMOVE_TO        ENT
                STY YCOORD
                RTS

OP_MOVE_TO_H    LDA (OP_PTR),Y
                INY
                TAX
                LDA DIV7HI,X
                STA XCOORD
                LDA MOD7HI,X
                STA XSHIFT
                BPL OP_VMOVE_TO         ; always

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
HMOVE_TO_H      ENT
                LDA DIV7HI,X
                STA XCOORD
                LDA MOD7HI,X
                STA XSHIFT
                RTS

OP_VMOVE        LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                CLC
                ADC YCOORD
                STA YCOORD
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
                AND #$80
                EOR #$FF
                STA AND_MASK

                LDY LEFT_DIV7
                CPY RIGHT_DIV7
                BEQ THIN_RECT

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
:3              LDA TEMP_COLOR
                AND #$80
                ORA BIT_TABLE,X
                STA LEFT_MASK

                LDA TEMP_COLOR
                PHA
:4              EOR TEMP_TOGGLE
                INY
                CPY RIGHT_DIV7
                BEQ :5
                STA (SCREENL),Y
                BNE :4              ; always

:5              STA TEMP_COLOR
                LDX RIGHT_MOD7
                LDA (SCREENL),Y
                EOR TEMP_COLOR
                AND RIGHT_MASKS,X
                EOR TEMP_COLOR
                STA (SCREENL),Y
                PLA
                STA TEMP_COLOR
                AND #$80
                ORA BIT_TABLE,X
                STA RIGHT_MASK

                LDX TOP
                CPX BOTTOM
                BNE :6
                RTS

:6              INX
FILLRECT_MOD    CLC
                BCS RECT_LOOP

:7              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH

                LDY LEFT_DIV7
                LDA (SCREENL),Y
                AND AND_MASK
                ORA LEFT_MASK
                STA (SCREENL),Y

                LDY RIGHT_DIV7
                LDA (SCREENL),Y
                AND AND_MASK
                ORA RIGHT_MASK
                STA (SCREENL),Y

                INX
                CPX BOTTOM
                BNE :7
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

OP_VLINE_TO     LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                CMP YCOORD
                LDX YCOORD
                BCS :1
                STX BOTTOM
                TAX
                BCC :2              ; always
:1              STA BOTTOM
:2              STA YCOORD

        do 0    ; enable to allow for black vertical lines
                LDY XSHIFT
                LDA BIT_TABLE,Y
                ORA #$80
                STA LEFT_MASK
                LDY OP_COLOR
                LDA COLOR_TABLE,Y
                ; TODO: toggle color by column here
                TAY
                EOR #$FF
                AND LEFT_MASK
                EOR #$FF
                STA AND_MASK
                TYA
                AND LEFT_MASK
                STA LEFT_MASK
        else
                LDY OP_COLOR
                LDA COLOR_TABLE,Y
                AND #$80
                EOR #$FF
                STA AND_MASK
                EOR #$FF
                LDY XSHIFT
                ORA BIT_TABLE,Y
                STA LEFT_MASK
        fin

                LDY XCOORD
:3              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDA (SCREENL),Y
                AND AND_MASK
                ORA LEFT_MASK
                STA (SCREENL),Y
                INX
                CPX BOTTOM
                BCC :3
                BEQ :3
                RTS

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
                SAME_PAGE_AS :INX_MOD
                RTS

;-------------------------------------------------------------------------------
