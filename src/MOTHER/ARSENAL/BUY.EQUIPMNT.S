BUY_EQUIPMENT   LDA #$00
                STA LINECNT
                JSR CURSOR3
                LDA #$00
                STA STATUS
                JSR STATUP
                LDX DISPLAY
                DEX
                LDA WANTED1
                STA ON1,X
                BIT UNSTROB
BLINK3          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI KEYGOT3
                JSR CURSOR3
                LDA #$00
                JSR WAIT_KEY
                JSR CURSOR3
GETAKEY         BIT KEYBRD
                BPL BLINK3
KEYGOT3         LDA KEYBRD
                BIT UNSTROB
                JSR CHECK_UP
                BEQ GO_UP2
                JSR CHECK_DOWN
                BEQ GO_DOWN2
                JSR CHECK_ENTER
                BEQ ENTER2
                JSR CHECK_CANCEL
                BEQ GETOUT2
                JMP GETAKEY

GETOUT2         LDA #$01
                STA WANTED1
                JSR DRAW_SCREEN
                JMP MAIN_LOOP

GO_UP2          JSR CURSOR3
                DEC LINECNT
                BPL UPDOWN2
                LDA LEAVLIN
                STA LINECNT
                JMP UPDOWN2

GO_DOWN2        JSR CURSOR3
                LDA LINECNT
                INC LINECNT
                CMP LEAVLIN
                BNE UPDOWN2
                LDA #0
                STA LINECNT
UPDOWN2         JSR CURSOR3
                LDA LINECNT
                CMP LEAVLIN
                BNE GOSUP2
                LDA #0
                STA COUNT
                JSR STATUPA
                JMP GETAKEY
GOSUP2          JSR STATUP
                JMP GETAKEY

ENTER2          LDA LINECNT
                CMP LEAVLIN
                BNE NOLEAVN
                LDA WANTED1
                SEC
                SBC #$0A
                TAY
                LDA WANTS,Y
                STA WANTED1
                JSR CURSOR3
                JSR ERASE_STAT
                LDA #$00
                STA STATUS
                JSR DRAW_SCREEN
                JMP MAIN_LOOP

WANTS           DB  $06,$06,$06
                DB  $07,$07,$07
                DB  $07,$07,$08
                DB  $08,$08

NOLEAVN         LDA STATUS
                CMP #$02
                BCC :SKIPA
                JSR BLINKEM
                JMP GETAKEY
:SKIPA          LDA WHOPIC
                JSR SET_CHAR
                BIT UNSTROB
                JSR NOISE

                JSR DRAW_PICT
                PictClear 4;164;36;191
                PictTextAt 46;168;"PRESS <SPACE> TO VERIFY PURCHASE"
                PictTextAt 124;180;"C>ANCEL"
                PictEnd

SPACANC         LDA KEYBRD
                BPL SPACANC
                BIT UNSTROB
                JSR CHECK_ENTER
                BEQ BUYIT
                JSR CHECK_CANCEL
                BNE SPACANC
SPACOMN         JSR GOSCOMN
                JMP GETAKEY

BUYIT           JSR OFF_CALC
                LDA CODEOFF,X
                STA DATPNTL
                LDA CODEOFF+1,X
                STA DATPNTH
                TYA
                ASL
                ASL
                TAX
                LDA #$03
                STA COUNT
:1              TXA
                TAY
                LDA (DATPNTL),Y
                LDY OPEN_SLOT
                STA (CHARDL),Y
                INX
                INC OPEN_SLOT
                DEC COUNT
                BPL :1
                LDX LEAVLIN
                LDY LINTABL,X
                LDX #103
                JSR UPDATE_CREDIT
                JSR OFF_CALC
                LDA STOCK_PTRS,X
                STA DATPNTL
                LDA STOCK_PTRS+1,X
                STA DATPNTH

STOCK_INDEX1    =   TEMP+0
STOCK_INDEX2    =   TEMP+1

                LDA (DATPNTL),Y
                CMP #$7F
                BEQ :2
                JSR GET_STOCK_INDEX
                STX STOCK_INDEX1
                SEC
                SBC #1
                STA (DATPNTL),Y
                JSR GET_STOCK_INDEX
                CPX STOCK_INDEX1
                BEQ :2
                STX STOCK_INDEX2
                LDY STOCK_INDEX1
                JSR DRAW_STOCK
                LDY STOCK_INDEX2
                JSR DRAW_STOCK
:2              JSR NOISE
                JMP SPACOMN

GOSCOMN         JSR DRAW_PICT
                PictClear 4;164;36;191
                PictEnd
                JSR DRAW_NPE
                LDA #$00
                STA STATUS
                JMP STATUP

*-------------------------------

CURSOR3         LDX LINECNT
                LDY LINTABL,X
                LDX #5
                JSR DRAW_TRIANGLE
                LDA LINECNT
                CMP LEAVLIN
                BNE :1
                RTS

:1              LDX #155
                JSR HMOVE_TO
                JSR DRAW_BACK_ARROW
                LDX #<269
                JSR HMOVE_TO_H
DRAW_BACK_ARROW LDX #<:BACK_ARROW
                LDY #>:BACK_ARROW
                JMP DRAW_TILE

:BACK_ARROW     DB  %01100000
                DB  %01110000
                DB  %01111000
                DB  %01111110
                DB  %01111000
                DB  %01110000
                DB  %01100000

*-------------------------------
