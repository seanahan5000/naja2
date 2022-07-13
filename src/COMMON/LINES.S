

; set color
; draw hline
; draw vline

; clear rect?
; fill rect?
; frame rect?
; (separate file?)



; * MOVE
; * MOVE_TO
; * XMOVE
; * XMOVE_POS7
; * XMOVE_NEG7
; * XMOVE_TO
; - YMOVE
; - YMOVE_TO
; - HLINE
; - HLINE_TO
; - VLINE
; - VLINE_TO
; - SET_COLOR
; - IMAGE
; - IMAGE_AT
; - IMAGES
; - RECT

;*** move from LINES.S? ***


;
; On entry:
;   X: new absolute X position in pixels
;   Y: new absolute Y position in lines
;
MOVE_TO         ENT
                STY YCOORD
XMOVE_TO        ;ENT
                LDA DIV7,X
                STA XCOORD
                LDA MOD7,X
                STA XSHIFT
                RTS
;
; On entry:
;   X: delta to move X position, in pixels
;   Y: delta to move Y position, in lines
;
MOVE            ;ENT
                TYA
                CLC
                ADC YCOORD
                STA YCOORD
;
; On entry:
;   X: delta to move X position, in pixels
;
XMOVE           ;ENT
                TXA
                BEQ :EXIT
                BMI :NEG_DX

:POS_DX         LDA XCOORD
                CLC
                ADC DIV7,X
                STA XCOORD
                LDA XSHIFT
;               CLC
                ADC MOD7,X
                TAX
;               CLC
                SBC #6
                BCC :1
                TAX
                INC XCOORD
:1              STX XSHIFT
                RTS

:NEG_DX         EOR #$FF
                TAX
                INX
                LDA XCOORD
                SEC
                SBC DIV7,X
                STA XCOORD
                LDA XSHIFT
;               SEC
                SBC MOD7,X
                BCS :2
;               CLC
                ADC #7
                DEC XCOORD
:2              STA XSHIFT
:EXIT           RTS

XMOVE_POS6      ;ENT
                LDX XSHIFT
                BEQ :1
                INC XCOORD
                DEX
                STX XSHIFT
                RTS
:1              LDX #6
                STX XSHIFT
                RTS

V2              DEC XSHIFT
                BMI :1
                INC XCOORD
                RTS
:1              LDA #6
                STA XSHIFT
                RTS

XMOVE_NEG6      ;ENT
                LDX XSHIFT
                CPX #6
                BEQ :1
                DEC XCOORD
                INX
                STX XSHIFT
                RTS
:1              LDX #0
                STX XSHIFT
                RTS


