
                PUT /COMMON/VARS
                PUT /COMMON/EXT

*-------------------------------
;
; On entry:
;   C=1: remove write-protect tab
;   C=0: ask for side
;   A: disk side to ask for
;
FILE_HOOK       ENT
                BCS MESS_CMN

:ASK_FOR_SIDE   TAX
                LDA SIDE_LETTERS+0,X
                STA MESSAGES+12
                LDA SIDE_LETTERS+4,X
                STA MESSAGES+13
                CLC

MESS_CMN        PHP
                JSR CLEAR_HOLES
                JSR SWAP_HOLES
                JSR DRAW_HOLE_BOX
                PLP
                PHP
                LDY #15
                BCC :1
                LDY #31
:1              LDX #15
:2              LDA MESSAGES,Y
                STA TEXTBUF,X
                DEY
                DEX
                BPL :2
                PLP
                LDX #98
                BCC :3
                LDX #95
:3              LDY #183
                JSR DRAW_TEXTBUF_XY
                JSR COPY_MESSAGE
                BIT UNSTROB
:4              LDA KEYBRD
                BPL :4
                BIT UNSTROB
;               JMP SWAP_HOLES

SWAP_HOLES      LDA HIBYTES
                LDX #$00
                JSR :SUB12
                LDX #$60
                TXA
                EOR HIBYTES
:SUB12          STX :MOD1+1
                STA :MOD2+2
                STA :MOD3+2
                LDA #$78
                PHA
                LDX #181            ; top line
:1              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
:MOD1           EOR #$00
                STA SCREENH
                INX
                STX :MOD4+1
                PLA
                TAX
                LDY #13             ; left column
:2              LDA (SCREENL),Y
                PHA
:MOD2           LDA $FF00,X
                STA (SCREENL),Y
                PLA
:MOD3           STA $FF00,X
                INX
                TXA
                ASL
                BNE :3
                ROR
                EOR #%01111000
                TAX
                INC :MOD2+2
                INC :MOD3+2
:3              INY
                CPY #27             ; right column
                BNE :2
                TXA
                PHA
:MOD4           LDX #$FF
                CPX #192            ; bottom line
                BNE :1
                PLA
                RTS

CLEAR_HOLES     LDA #$20
                JSR :SUB12
                LDA #$40
:SUB12          STA :MOD1+2
                STA :MOD2+2
                LDA #$00
                LDY #32
:1              LDX #$78
:MOD1           STA $FF00,X
:MOD2           STA $FF80,X
                INX
                BPL :MOD1
                INC :MOD1+2
                INC :MOD2+2
                DEY
                BNE :1
                RTS

DRAW_HOLE_BOX   LDX #181
:1              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #26
                CPX #181
                BEQ :2
                CPX #191
                BEQ :2
                LDA #%01100000
                STA (SCREENL),Y
                LDY #13
                LDA #%00000011
                STA (SCREENL),Y
                BNE :4                  ; always
:2              LDA #%01111111
:3              STA (SCREENL),Y
                DEY
                CPY #12
                BNE :3
:4              INX
                CPX #192
                BNE :1
                RTS

COPY_MESSAGE    LDX #181
:6              LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA SCREENH
                EOR #$60
                STA DESTINH
                LDY #26
:7              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                CPY #12
                BNE :7
                INX
                CPX #192
                BNE :6
                RTS

; TODO: Should these just be numbers (S1-S4)?
SIDE_LETTERS
;               TXC "MFTT"
                TXC "NNNN"
                TXC "0123"

MESSAGES        TXT "INSERT_SIDE_XX_"
                TXT "WRITE_PROTECTED"

*-------------------------------
