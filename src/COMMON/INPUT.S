
LineLength      =   $27             ; default maximum length of line of characters
CursorSpeed     =   $1001           ; cursor animation speed

MAX_TEXT        =   $05
INPUT_INDEX     =   $0F             ; TODO: move someplace safer?
CURSOR_CYCLE    =   $14
DELAYL          =   $15
DELAYH          =   $17

; TODO: option to allow <escape>?

;-------------------------------------------------------------------------------
; On entry:
;   A: maximum characters allowed
;
; On exit:
;   X: length of string
;   TEXT_BUFFER: string in Naja format
;
GET_NUMBER_LIMIT ENT
                LDY #$0A
                BNE INPUT_CMN1          ; always

;-------------------------------------------------------------------------------
; continue input process where it left off
;
REGET_INPUT     ENT
                JSR DRAW_CURSOR
                JMP INPUT_CMN2
;-------------------------------------------------------------------------------
; On exit:
;   A: key pressed in ASCII format
;
GET_INPUT_KEY   ENT
                LDA #0
                BEQ GET_INPUT_LIMIT     ; always
;-------------------------------------------------------------------------------
; On exit:
;   X: length of string
;   TEXT_BUFFER: string in Naja format
;
GET_INPUT       ENT
                LDA #LineLength
                ; fall through
;-------------------------------------------------------------------------------
; On entry:
;   A: maximum characters allowed
;
; On exit:
;   X: length of string
;   TEXT_BUFFER: string in Naja format, including $8D
;
GET_INPUT_LIMIT ENT
                LDY #$FF
INPUT_CMN1      STY IN_NUM_MOD+1
                STA MAX_TEXT

                LDA #0
                STA CURSOR_CYCLE
                STA INPUT_INDEX
                JSR SHOW_CURSOR

INPUT_CMN2
IN_KEYLOOP      JSR ANIMATE_CURSOR
                LDA KEYBRD
                BPL IN_KEYLOOP
                BIT UNSTROB
                CMP #$8D
                BEQ IN_RETURN
                CMP #$88                ; back arrow key
                BEQ IN_BACKSPACE
                CMP #$FF                ; delete key
                BEQ IN_BACKSPACE

                LDX INPUT_INDEX
                CPX MAX_TEXT
                BEQ IN_ATLIMIT

                CMP #$9B
                BEQ IN_ESCAPE

                JSR FROM_ASCII
                BCC IN_KEYLOOP

IN_NUM_MOD      CMP #$FF
                BCS IN_KEYLOOP

                STA TEXTBUF,X
                INX
                STX INPUT_INDEX

                PHA
                JSR DRAW_CURSOR     ; erase cursor
                JSR RESET_CURSOR
                PLA
                JSR DRAW_LETTER
                JMP IN_KEYLOOP

IN_BACKSPACE    LDX INPUT_INDEX
                BEQ IN_KEYLOOP        ; line is empty

                JSR DRAW_CURSOR     ; erase cursor
                JSR RESET_CURSOR
                JSR RETREAT
                DEC INPUT_INDEX
                LDX INPUT_INDEX
                LDA TEXTBUF,X
                JSR DRAW_LETTER
                JSR RETREAT
                JMP IN_KEYLOOP

IN_ATLIMIT      CPX #0
                BNE IN_KEYLOOP
                PHA
                JSR DRAW_CURSOR     ; erase cursor
                ; return ASCII key pressed in A
                PLA
                RTS

IN_ESCAPE       LDA #0
                STA INPUT_INDEX
IN_RETURN       JSR DRAW_CURSOR     ; erase cursor
                LDX INPUT_INDEX
                LDA #TextLineEnd
                STA TEXTBUF,X
                RTS

ANIMATE_CURSOR  DEC DELAYL
                BNE :1
                DEC DELAYH
                BEQ :2
:1              RTS

:2              JSR DRAW_CURSOR     ; erase cursor
                ; fall through

SHOW_CURSOR     JSR CLEAR_CURSOR

                LDA #%00011111      ; white line
                LDX CURSOR_CYCLE
                CPX #3
                BEQ :4
                LDA #6
                SEC
                SBC CURSOR_CYCLE
                TAY
                LDA #%01010101      ; violet line
                STA TILE_BUFFER,Y
                LDA #%00101010      ; green line
:4              STA TILE_BUFFER,X
                INX
                CPX #7
                BNE :5
                LDX #0
:5              STX CURSOR_CYCLE
                ; fall through

DRAW_CURSOR     LDX #<TILE_BUFFER
                LDY #>TILE_BUFFER
                JSR DRAW_TILE
                DEC XCOORD
                RTS

RESET_CURSOR    LDA #0
                STA CURSOR_CYCLE
CLEAR_CURSOR    LDA #<CursorSpeed
                STA DELAYL
                LDA #>CursorSpeed
                STA DELAYH
                LDX #6
                LDA #$00
:1              STA TILE_BUFFER,X
                DEX
                BPL :1
                RTS

; Unlike ADVANCE, this modifies X register
RETREAT         DEC XCOORD
                LDX XSHIFT
                INX
                CPX #7
                BNE :1
                LDX #0
                INC XCOORD
:1              STX XSHIFT
                RTS
;
; On entry:
;   A: ASCII character
;
; On exit:
;   A: Naja-format character
;   X: unchanged
;   C: Set if conversion succeeded
;      Clear if conversion failed
;
FROM_ASCII      CMP #"A"
                BCC :NOT_LETTER
                AND #%11011111      ; lower to upper case
                CMP #$DB            ; exclude [\^[_ and {|}~
                BCS :FAIL
                SBC #"A"-1-TextA
;               SEC
                RTS

:NOT_LETTER     TAY
                EOR #"0"
                CMP #$0A
                BCS :NOT_NUMBER
                SEC
                RTS

:NOT_NUMBER     CMP #" "!"0"
                BNE :NOT_SPACE
                LDA #TextSpace
;               SEC
                RTS

:NOT_SPACE      TYA
                EOR #$A9
                LDY #37
:1              CMP :ASCII-37,Y
                BEQ :FOUND
                CPY #$33
                BEQ :FAIL
                INY
                BNE :1
:FAIL           CLC
                RTS
:FOUND          TYA
                SEC
                RTS

:ASCII          DB  $08,$0B         ;!,"
                DB  $0C,$0E,$03     ;%,',*
                DB  $02,$05,$04     ;+,,,-
                DB  $07,$06         ;.,/
                DB  $13,$15,$14     ;:,<,=
                DB  $17,$16         ;>,?

;-------------------------------------------------------------------------------
