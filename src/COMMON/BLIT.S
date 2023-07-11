;
; On entry:
;   X: left byte
;   A: right byte, exclusive
;
SET_LINE_BOUNDS ENT
                STX CLEAR_MOD_A+1
                STX COPY_MOD_A+1
                STA CLEAR_MOD_B+1
                STA COPY_MOD_B+1
                RTS
;
; On entry:
;   X: line number (y coordinate)
;
; On exit:
;   X,Y: unchanged
;
SET_SOURCE_LINE ENT
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                RTS

SET_SOURCE_OFF  ENT
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                EOR #$60
                STA SCREENH
                RTS

SET_DEST_LINE   ENT
                LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                RTS

SET_DEST_OFF    ENT
                LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                EOR #$60
                STA DESTINH
                RTS

COPY_LINE       ENT
COPY_MOD_A      LDY #$FF
CPLOOP1         LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
COPY_MOD_B      CPY #$FF
                BNE CPLOOP1
                SAME_PAGE_AS CPLOOP1
                RTS

COPY_FULL_LINE  ENT
                LDY #39
:1              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :1
                SAME_PAGE_AS :1
                RTS

CLEAR_LINE      ENT
CLEAR_MOD_A     LDY #$FF
                LDA #$00
CLLOOP1         STA (DESTINL),Y
                INY
CLEAR_MOD_B     CPY #$FF
                BNE CLLOOP1
                SAME_PAGE_AS CLLOOP1
                RTS

CLEAR_FULL_LINE ENT
                LDY #39
                LDA #$00
:1              STA (DESTINL),Y
                DEY
                BPL :1
                SAME_PAGE_AS :1
                RTS
