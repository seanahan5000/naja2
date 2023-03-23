
; (TEXT)   T,E,X,T,$8D
; (TEXT)+  T,E,X,T,$8D,$FF
; (TEXT)-  T,E,X,T
; (TEXT)=  T,E,X,T^$80

;*** THESE ARE ALL USED FOR WORD-WRAP CASE ***
WORD_DIV7       =   $31
WORD_MOD7       =   $32
WORD_INDEX      =   $33

;-------------------------------------------------------------------------------

SET_TEXT_HEIGHT ENT
                TAX
                BNE :1
                LDA #TextLineHeight
:1              STA TEXT_HEIGHT
                RTS

OP_SET_TEXT_HEIGHT
                LDA (OP_PTR),Y
                BNE :1
                LDA #TextLineHeight
:1              INY
                STA TEXT_HEIGHT
                STY OP_INDEX
                RTS

TEXT_HEIGHT     DB  TextLineHeight

;-------------------------------------------------------------------------------
; On entry:
;   XCOORD: current X byte column
;   XSHIFT: current X shift position
;   YCOORD: current Y line position
;   X: Address of string (low)
;   Y: Address of string (high)
;-------------------------------------------------------------------------------

OP_DRAW_TEXTBUF ENT
                LDX #<DRAW_TEXTBUF
                LDA #>DRAW_TEXTBUF
                JMP OP_CALL_PROC

OP_DRAW_TEXTBUF_RET ENT
                JSR OP_DRAW_TEXTBUF
                JMP NEXT_LINE

DRAW_TEXTBUF_RET ENT
                JSR DRAW_TEXTBUF
                JMP NEXT_LINE

; X: target X position
; Y: target Y position
DRAW_TEXTBUF_XY ENT
                STY YCOORD
; X: target X position
DRAW_TEXTBUF_X  ENT
                LDA DIV7,X
                STA XCOORD
                LDA MOD7,X
                STA XSHIFT
DRAW_TEXTBUF    ENT
                LDX #<TEXT_BUFFER
                LDY #>TEXT_BUFFER
DRAW_TEXT       ENT
                STX OP_PTR
                STY OP_PTR_H
                LDY #0
                BEQ OP_TEXT             ; always

OP_TEXT_AT      JSR OP_MOVE_TO
                LDY OP_INDEX
OP_TEXT         STY OP_INDEX
                LDA XCOORD
                STA LEFT_DIV7
                LDA XSHIFT
                STA LEFT_MOD7
                JSR TABLER
                LDY OP_INDEX

:NEXT_CHAR      LDA (OP_PTR),Y
                BMI :SPECIAL_CHAR
                INY
                CMP #TextSpace
                BEQ :SKIP_SPACE1
                STY OP_INDEX
                JSR DRAW_LETTER
                LDY OP_INDEX
                BNE :NEXT_CHAR          ; always

:SKIP_SPACE1    JSR HMOVE_6
                BNE :NEXT_CHAR          ; always

:SPECIAL_CHAR   INY
                CMP #TextLineEnd
                BEQ :DONE
                CMP #TextEmpty
                BEQ :NEXT_CHAR
                STY OP_INDEX
                CMP #TextLineBreak
                BNE :DONE               ; always

:NEXT_LINE      JSR NEXT_LINE
                LDY OP_INDEX
                BNE :NEXT_CHAR          ; always

:DONE           STY OP_INDEX
                RTS

NEXT_LINE       LDA LEFT_DIV7
                STA XCOORD
                LDA LEFT_MOD7
                STA XSHIFT
                LDA YCOORD
                CLC
                ADC TEXT_HEIGHT
                CMP #192-7
                BCC :1
                LDA #192-7
:1              STA YCOORD
                JMP TABLER

;-------------------------------------------------------------------------------

; X, Y, RIGHT (exclusive), BOTTOM (exclusive) in pixels/lines

OP_SET_TEXTBOX_H
                SEC
                BCS OP_STB_CMN          ; always

OP_SET_TEXTBOX  CLC
OP_STB_CMN      LDA (OP_PTR),Y
                INY
                TAX
                LDA DIV7,X
                STA LEFT_DIV7
                STA XCOORD
                LDA MOD7,X
                STA LEFT_MOD7
                STA XSHIFT
                LDA (OP_PTR),Y
                INY
                STA TOP
                STA YCOORD
                LDA (OP_PTR),Y
                INY
                TAX
                LDA (OP_PTR),Y
                INY
                STY OP_INDEX
                STA BOTTOM
                BCS :1
                LDA DIV7,X
                BCC :2                  ; always
:1              LDA DIV7HI,X
:2              STA RIGHT_DIV7
                LDA #0
                STA RIGHT_MOD7
                RTS

;-------------------------------------------------------------------------------
; On entry:
;   OP_SET_TEXTBOX called
;   X: Address of string (low)
;   Y: Address of string (high)
;-------------------------------------------------------------------------------

WRAP_TEXTBUF    ENT
                LDX #<TEXT_BUFFER
                LDY #>TEXT_BUFFER

DRAW_TEXTBOX    ENT
                STX OP_PTR
                STY OP_PTR_H
                LDY #0

OP_TEXT_IN      STY OP_INDEX
                JSR TABLER

:NEXT_WORD      LDY OP_INDEX
                LDA XCOORD
                STA WORD_DIV7
                LDA XSHIFT
                STA WORD_MOD7

                LDX #0
:NEXT_CHAR      LDA (OP_PTR),Y
                BMI :SPECIAL_CHAR
                CMP #TextSpace
                BNE :0
                CPX #0                  ; leading space should not cause break
                BNE :BREAK_WORD
:0              INY
                STA WORD_BUFFER,X
                INX
                PHA
                JSR HMOVE_6
                PLA
                CMP #TextFirstSymbol
                BCC :NEXT_CHAR
:BREAK_WORD     STY OP_INDEX
                TXA
                BEQ :DONE
                LDA #$FF
                STA WORD_BUFFER,X

                LDA XCOORD
                CMP RIGHT_DIV7
                BCC :WORD_FITS
                JSR :NEXT_LINE
                JMP :DRAW_WORD

:SPECIAL_CHAR   CMP #TextLineEnd
                BEQ :BREAK_WORD
                CMP #TextLineBreak
                BEQ :BREAK_WORD
                INY
                CMP #TextEmpty
                BEQ :NEXT_CHAR
                STY OP_INDEX
                BNE :BREAK_WORD         ; always

:FLUSH_TEXT     PLA
                PLA
:DONE           LDA (OP_PTR),Y
                INY
                CMP #TextLineEnd
                BNE :DONE
                STY OP_INDEX
                RTS

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
                JSR DRAW_LETTER
                LDY WORD_INDEX
                BNE :1                  ; always

:TRIM_SPACE     LDY OP_INDEX
:2              LDA (OP_PTR),Y
                CMP #TextLineBreak
                BEQ :FORCE_BREAK
                CMP #TextSpace
                BNE :3
                JSR HMOVE_6
                INY
                BNE :2                  ; always

:FORCE_BREAK    INY
                STY OP_INDEX
                BNE :33                 ; always

:3              STY OP_INDEX
                LDA XCOORD
                CMP RIGHT_DIV7
                BCC :4
:33             JSR :NEXT_LINE
:4              JMP :NEXT_WORD

:NEXT_LINE      LDA YCOORD
                CLC
                ADC TEXT_HEIGHT
                CMP BOTTOM
                BCS :FLUSH_TEXT
                STA YCOORD
                LDA LEFT_DIV7
                STA XCOORD
                LDA LEFT_MOD7
                STA XSHIFT
                JMP TABLER

;-------------------------------------------------------------------------------
; Move position right by one 6 pixel character
;
; On exit:
;   X,Y: Assumed unchanged
;   Z: 1 (BNE true)
;-------------------------------------------------------------------------------

HMOVE_6         ENT
                DEC XSHIFT
                BMI :1
                INC XCOORD
                RTS                     ; always BNE
:1              LDA #6
                STA XSHIFT
                RTS                     ; always BNE

;-------------------------------------------------------------------------------
; Find a high-bit-terminated string in a list by index
;
; On entry:
;   X: string list (low)
;   Y: string list (high)
;   A: string index
;
; On exit:
;   TEXT_BUFFER: holding indexed string
;   X: index of TextLineEnd
;
PTR             =   LOCAL_TEMP+0
PTR_H           =   LOCAL_TEMP+1

; TODO: consider putting pointer on the stack
GET_IND_STRING  ENT
                STX PTR
                STY PTR_H
                TAX
                BEQ :4
:1              LDY #-1
:2              INY
                LDA (PTR),Y
                BPL :2
                TYA
                SEC                 ; +1
                ADC PTR
                STA PTR
                BCC :3
                INC PTR_H
:3              DEX
                BNE :1
:4              LDY #0
;               LDX #0
:5              LDA (PTR),Y
                BMI :6
                STA TEXT_BUFFER,X
                INX
                INY
                BNE :5              ; always
:6              AND #$7F
                STA TEXT_BUFFER,X
                INX
                LDA #TextLineEnd
                STA TEXT_BUFFER,X
                RTS

;-------------------------------------------------------------------------------
