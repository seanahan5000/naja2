*-------------------------------

ASELLER         JSR EARN_PRICE
                LDA WHOPIC
                JSR SET_CHAR
                JSR EDRASUB
                JSR PDRASUB
                PLA
                TAY
                LDX #$03
                LDA #$FF
ZELOOP4         STA (CHARDL),Y
                INY
                DEX
                BPL ZELOOP4
                LDX CHUNK
                CPX #$16
                BCS :3
                LDA STOCK_PTRS,X
                STA TEMP
                LDA STOCK_PTRS+1,X
                STA TEMP+1

                LDY DSPLACE
                LDA (TEMP),Y
                BMI :1                  ; first seen
                CMP #$7F                ; infinite supply
                BEQ :3
                BNE :2                  ; always
:1              LDA #0
:2              CLC
                ADC #1
                STA (TEMP),Y
:3
                LDA CURSOR
                CMP #$04
                BCC NOSCROL
                SBC #$03
                LDY #back
                CMP (CHARDL),Y
                BEQ NOSCROL
                BCC BSCROLL
                LDY #e15_PROGRAM+1
                LDA (CHARDL),Y
                AND #$77
                CLC
                ADC #$04
                CMP CURSOR
                BEQ NOSCROL
                BNE CSCROLL             ; always

NOSCROL         JSR NOISE
                JMP ZESKIP2
BSCROLL         LDA (CHARDL),Y
                CLC
                ADC #$03
CSCROLL         PHA
                TAX
                LDA LINTABL,X
                CLC
                ADC #$08
                STA ENDLINE
                LDX CURSOR
                LDA LINTABL,X
                STA BEGLINE
                LDA #$07
                STA COUNT
SCLOOP0         LDA BEGLINE
                STA LINENUM
                INC LINENUM
SCLOOP1         LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                DEX
                LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                LDY #$05
SCLOOP2         LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY #$19
                BNE SCLOOP2
                INC LINENUM
                LDA LINENUM
                CMP ENDLINE
                BNE SCLOOP1
                DEC COUNT
                BPL SCLOOP0
                PLA
                TAY
                LDA CORESP,Y
                CLC
                ADC #$04
                STA ENDLINE
                LDY CURSOR
                LDA CORESP,Y
                TAY
                BNE SNEAKY
SLIDES          LDA (CHARDL),Y
                DEY
                DEY
                DEY
                DEY
                STA (CHARDL),Y
                INY
SNEAKY          INY
                INY
                INY
                INY
                CPY ENDLINE
                BNE SLIDES
                TYA
                SEC
                SBC #$04
                TAY
                LDX #$04
                LDA #$FF
ERASEM          STA (CHARDL),Y
                INY
                DEX
                BNE ERASEM
                JSR NOISE
ZESKIP2         LDA #$AD
                STA HALT1
                STA HALT2
                STA HALT3
                JSR LEGLSUB
                LDA #$20                ; JSR
                STA HALT1
                STA HALT2
                STA HALT3
                JSR ERASE_CONFIRM
                JSR DRAW_PICK_ITEM
                JMP ZDOWN2

*-------------------------------
