
DRAW_EQUIPMNT   JSR DRAW_PICT
                PictClearPage
                PictCall DRAW_NPE
                PictSetGreen
                PictRect $01;$00;$117;$0C
                PictTextAt 125;3;"PRICE"
                PictTextAt 167;3;"STOCK"
                PictTextAt 209;3;"ENERGY-USE"
                PictEnd

                LDA WANTED1
                SEC
                SBC #$0A
                PHA
                LDX #<EGROUP_NAMES
                LDY #>EGROUP_NAMES
                JSR GET_IND_STRING
                LDX #13
                LDY #3
                JSR DRAW_TEXTBUF_XY

                PLA
                CMP #$01
                BNE SINGLES
                LDY #$00
DO4             TYA
                STA TABLE4,Y
                INY
                CPY #$03
                BNE DO4
                LDA #$0F
                STA TABLE4+3
                BNE MULTI               ; always

SINGLES         TAY
                LDA GROUPER,Y
                STA TABLE4
                LDA #$0F
                STA TABLE4+1
MULTI           LDA #$00
                JSR CNTDRAW
                JSR DOBOXES

                LDX LEAVLIN
                LDY LINTABL,X
                JSR VMOVE_TO
                LDX #$67
                JSR DRAW_GCREDITS_AT

                JSR DRAW_PICT
                PictHMoveTo 13
                PictText "LEAVE"
                PictHMoveTo 170
                PictText "YOUR CREDITS"
                PictEnd

                ; *** REVERSE ARROW ***
                ; LDA #$9C
                ; STA XPNT
                ; LDA TEXT2A+2
                ; STA YPNT
                ; LDA #1
                ; JSR SPCHARS
                ; LDA #$2C
                ; STA TEXTBUF
                ; LDA #TextLineEnd
                ; STA TEXTBUF+1
                ; LDA #$A3
                ; LDY YCOORD
                ; JSR LINE

                JSR ISHERE
                LDA #$FF
                JSR CNTDRAW
                RTS                 ;TEMP

EGROUP_NAMES    TXI "BEAM-WEAPONS"
                TXI "BLASTING-WEAPONS"
                TXI "MISC-WEAPONS"
                TXI " "
                TXI " "
                TXI "FORCE-SHIELDS"
                TXI "HELMET-ATTACHMNTS"
                TXI "MISC-PROTECTION"
                TXI "MEDICAL-EQUIPMNT"
                TXI "SCANNERS"
                TXI "MISCELLANEOUS"

CNTDRAW         STA DRAWFLG
                LDA #$00
                STA TABLCNT
                LDA #$0E
                STA LINUMB
                LDA #$00
                STA CTABCNT
                LDA #$00
                STA LINECNT
NXTGRP          LDY TABLCNT
                LDA LINECNT
                STA TABLE2,Y
                TAX
                LDA TABLE4,Y
                CMP #$0F
                BNE NOTLEAV
                LDA TABLE2,Y
                CMP TABLE2-1,Y
                BNE NOT3
                LDA LINUMB
                SEC
                SBC #$02
                STA LINUMB
NOT3            STX LEAVLIN
                LDY LINECNT
                LDA LINUMB
                STA LINTABL,Y
                RTS
NOTLEAV         JSR COUNTUP
                LDA TABLCNT
                INC TABLCNT
                CMP #$03
                BNE NXTGRP
                RTS

COUNTUP         LDY TABLCNT
                LDA TABLE4,Y
                TAY
                ASL
                TAX
                LDA STOCK_PTRS,X
                STA DATPNTL
                LDA STOCK_PTRS+1,X
                STA DATPNTH
                LDA MAXPER,Y
                STA NUMBIN
                LDY #$00
NEXTLP          LDA (DATPNTL),Y
                BMI NOTHERE
                BIT DRAWFLG
                BVC NOTDRAW
                JSR DRAWEQP
NOTDRAW         LDX LINECNT
                LDA LINUMB
                STA LINTABL,X
                CLC
                ADC #$08
                STA LINUMB
                INC LINECNT
NOTHERE         INY
                CPY NUMBIN
                BCC NEXTLP
                LDA LINUMB
                CLC
                ADC #$02
                STA LINUMB
                RTS

MAXPER          DB  $05,$04,$02
                DB  $07,$06,$05
                DB  $04,$0E,$06
                DB  $03,$0C

DRAWEQP         LDX TABLCNT
                LDA TABLE4,X
                ASL
                TAX
                LDA CODEOFF,X
                STA TEMP
                LDA CODEOFF+1,X
                STA TEMP+1
                TYA
                PHA
                LDA CTABCNT
                INC CTABCNT
                ASL
                TAY
                TXA
                STA CURTABL,Y
                INY
                PLA
                PHA
                STA CURTABL,Y
                ASL
                ASL
                TAY
                LDX #$00
MOVEQP          LDA (TEMP),Y
                STA ETABLE,X
                INY
                INX
                CPX #$04
                BNE MOVEQP
                JSR ETABLE_TO_TEXT

                LDX LINECNT
                LDY LINTABL,X
                LDX #13
                JSR DRAW_TEXTBUF_XY

                PLA
                PHA
                JSR GET_STOCK
                JSR DRAW_STOCK

                LDX TABLCNT
                LDA TABLE4,X
                ASL
                TAX
                LDA PRICOFF,X
                STA TEMP
                LDA PRICOFF+1,X
                STA TEMP+1
                PLA
                PHA
                STA POINTL
                ASL
                CLC
                ADC POINTL
                TAY
                LDX #$01
TOBUFF          LDA (TEMP),Y
                STA THE_PRICE,X
                INY
                INX
                CPX #$04
                BNE TOBUFF
                LDA #$00
                STA THE_PRICE

                LDX #$67
                LDY YCOORD
                JSR DRAW_PRICE_AT

                LDX #$C5
                JSR HMOVE_TO
                JSR ENERGY2
                LDA #TextSpace
                JSR DRAW_ENERGY_PER

                PLA
                TAY                     ;*** ANYBODY USE THIS?
                RTS
;
; Draw stock word (many, some, low, out)
;
; On entry:
;   A: stock offset
;   YCOORD: vertical draw position
;
; On exit:
;   Y: stock word index
;
GET_STOCK       TAY
                LDA (DATPNTL),Y
                LDY #0
                CMP #8                  ; many
                BCS :1
                INY
                CMP #3                  ; some
                BCS :1
                INY
                CMP #1                  ; low
                BCS :1
                INY
:1              RTS
;
; Draw stock word (many, some, low, out)
;
; On entry:
;   Y: stock index
;   YCOORD: vertical draw position
;
DRAW_STOCK      LDX :XPNTS,Y
                JSR HMOVE_TO
                TYA
                LDX #<:STOCKS
                LDY #>:STOCKS
                JSR GET_IND_STRING
                JMP DRAW_TEXTBUF

:XPNTS          DB  170,170,173,173

:STOCKS         TXI "MANY"
                TXI "SOME"
                TXI "LOW"
                TXI "OUT"

;-----------------------------------------------------------

DOBOXES         LDA #$01
                STA COUNT
:1              LDY COUNT
                LDX TABLE2,Y
                LDA LINTABL,X
                SEC
                SBC #2
                TAY
                JSR VMOVE_TO
                JSR DRAW_PICT
                PictSetGreen
                PictHMoveTo 7
                PictHLineTo 273
                PictEnd
                LDY COUNT
                INC COUNT
                LDX TABLE2,Y
                CPX LEAVLIN
                BNE :1
                LDA LINTABL,X
                CLC
                ADC #8
                STA :MOD+1
                JSR DRAW_PICT
                PictMoveTo 1;12
:MOD            PictVLineTo $FF
                PictHLineTo 279
                PictVLineTo 12
                PictEnd
                RTS

;-----------------------------------------------------------

DRAW_NPE        JSR DRAW_PICT
                PictSetBlue
                PictRect $18;$A3;$FE;$BF
                PictTextAt 40;165;"NAME:"
                PictTextAt 40;174;"PROF:"
                PictTextAt 28;183;"ENERGY:"
                PictEnd

                ; *** do this just once ***
                LDA WHOPIC
                JSR SET_CHAR

                JSR DRAW_PICT
                PictCall CNAME_TO_TEXT
                PictTextbufXY 76;165
                PictCall CPROF_TO_TEXT
                PictTextbufXY 76;174
                PictCall ENERGY_TO_TEXT_L
                PictTextbufXY 76;183
                PictEnd
                RTS

;-----------------------------------------------------------
