
; (TEXT)   T,E,X,T,$8D
; (TEXT)+  T,E,X,T,$8D,$FF
; (TEXT)-  T,E,X,T
; (TEXT)=  T,E,X,T^$80

;*** THESE ARE ALL USED FOR WORD-WRAP CASE ***
WORD_DIV7       =   $31
WORD_MOD7       =   $32
WORD_INDEX      =   $33

;-------------------------------------------------------------------------------

OP_SET_TEXT_HEIGHT
                LDA (OP_PTR),Y
                BNE :1
                LDA #LineHeight
:1              INY
                STA TEXT_HEIGHT
                STY OP_INDEX
                RTS

TEXT_HEIGHT     DB  LineHeight

;-------------------------------------------------------------------------------
; On entry:
;   XCOORD: current X byte column
;   XSHIFT: current X shift position
;   YCOORD: current Y line position
;   X: Address of string (low)
;   Y: Address of string (high)
;-------------------------------------------------------------------------------

DRAW_TEXTBUF_RET ENT
                JSR DTB_CMN
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
DTB_CMN         LDX #<TEXT_BUFFER
                LDY #>TEXT_BUFFER

DRAW_TEXT       ENT
                STX OP_PTR
                STY OP_PTR_H
                LDY #0
                BEQ OP_TEXT     ; always

OP_TEXT_AT      JSR OP_MOVE_TO
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
                CMP #CharSpace
                BEQ :SKIP_SPACE1
                STY OP_INDEX
                JSR DRAW_LETTER
                LDY OP_INDEX
                BNE :NEXT_CHAR      ; always

:SKIP_SPACE1    JSR ADVANCE
                BNE :NEXT_CHAR      ; always

:SPECIAL_CHAR   INY
                CMP #CharLineEnd
                BEQ :DONE
                CMP #CharEmpty
                BEQ :NEXT_CHAR
                STY OP_INDEX
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
                BEQ :SKIP_SPACE2
                STX WORD_INDEX
                JSR DRAW_LETTER
                LDX WORD_INDEX
                LDY OP_INDEX
                BNE :NEXT_INSERT    ; always

:SKIP_SPACE2    JSR ADVANCE
                LDY OP_INDEX
                BNE :NEXT_INSERT    ; always

:NEXT_LINE      JSR NEXT_LINE
                LDY OP_INDEX
                BNE :NEXT_CHAR      ; always

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
                BCS OP_STB_CMN      ; always

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
                BCC :2              ; always
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

DRAW_TEXTBOX    ENT
                STX OP_PTR
                STY OP_PTR_H
                LDY #0
;                 BEQ OP_TEXT_IN      ; always

; OP_TEXT_AT      JSR OP_MOVE_TO
; OP_TEXT         LDA XCOORD
;                 STA LEFT_DIV7
;                 LDA XSHIFT
;                 STA LEFT_MOD7
;                 LDA #40
;                 STA RIGHT_DIV7
;                 LDA #192-7
;                 STA BOTTOM
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
                CMP #CharSpace
                BNE :0
                CPX #0              ; leading space should not cause break
                BNE :BREAK_WORD
:0              INY
                STA WORD_BUFFER,X
                INX
                PHA
                JSR ADVANCE
                PLA
                CMP #CharFirstSymbol
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

:SPECIAL_CHAR   CMP #CharLineEnd
                BEQ :BREAK_WORD
                CMP #CharLineBreak
                BEQ :BREAK_WORD
                INY
                CMP #CharEmpty
                BEQ :NEXT_CHAR
                STY OP_INDEX
                CMP #CharInsert
                BCS :START_INSERT
                BCC :BREAK_WORD     ; always

:FLUSH_TEXT     PLA
                PLA
:DONE           LDA (OP_PTR),Y
                INY
                CMP #CharLineEnd
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
                BNE :1              ; always

:TRIM_SPACE     LDY OP_INDEX
:2              LDA (OP_PTR),Y
                CMP #CharLineBreak
                BEQ :FORCE_BREAK
                CMP #CharSpace
                BNE :3
                JSR ADVANCE
                INY
                BNE :2              ; always

:FORCE_BREAK    INY
                STY OP_INDEX
                BNE :33             ; always

:3              STY OP_INDEX
                LDA XCOORD
                CMP RIGHT_DIV7
                BCC :4
:33             JSR :NEXT_LINE
:4              JMP :NEXT_WORD

:START_INSERT   AND #CharInsertMask
                TAY
:NEXT_INSERT    LDA INSERT_BUFFER,Y
                CMP #CharLineEnd
                BEQ :INSERT_DONE
                INY
                CMP #CharEmpty
                BEQ :NEXT_INSERT
                STA WORD_BUFFER,X
                JSR ADVANCE
                INX
                BNE :NEXT_INSERT    ; always

:INSERT_DONE    LDY OP_INDEX
                JMP :NEXT_CHAR

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

; TODO: use this somewhere
RETREAT         ;ENT
                LDA XSHIFT
                CMP #6
                BEQ :1
                DEC XCOORD
;               CLC
                ADC #1
                STA XSHIFT
                RTS
:1              LDA #0
                STA XSHIFT
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
