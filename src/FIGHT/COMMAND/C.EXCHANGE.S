EXCHANGE        JSR CLEAR_CANCEL_IN
                JSR EQUIP_DRAW
                BIT ROBDEN_FLAG
                BVS DCHOICE

                JSR DRAW_PICT
                PictTextAt 114;131;(PRESS_<SPACE>_TO_VERIFY)
                PictEnd
                JSR SCROLLER
                JSR DRAW_PICT
                PictTextAt 120;139;(EXCHANGE_OF_EQUIPMENT)
                PictEnd
                JSR SPACE_WAIT
                BCS EXENT
                JMP DID_CANCEL

EXENT           LDA #$10
                JMP EXCOMN

DCHOICE         JSR DRAW_PICT
                PictTextAt 102;133;('EXCHANGE'_FROM_WHICH_HAND?)
                PictEnd

                LDA #$84
                JSR GET_EXCHANGE
                BCS :SKIPA
                JMP DID_CANCEL

:SKIPA          JSR DRAW_PICT
                PictClear 14;133;38;140
                PictTextAt 108;133;('EXCHANGE'_TO_WHICH_HAND?)
                PictEnd
                LDA CURSOR
                PHA
                TAX
                LDA #$FF
                STA LEGALS,X
                LDY HAND_YPNTS,X
                LDX #$8F
                JSR DRAW_MARKER

                LDA #$04
                JSR GET_EXCHANGE
                BCS :SKIPB
                PLA
                JMP DID_CANCEL
:SKIPB          PLA
                ROR
                ROR
                ROR
                AND #$C0
                STA INSTR1
                LDA CURSOR
                ASL
                ASL
                ASL
                ASL
                ORA INSTR1
EXCOMN          ORA #cmdEXCHANGE
                TAX
                LDY #$00
                LDA TIMES+timeEXCHANGE
                JSR GENERAL_POST
                JMP DID_CANCEL

GET_EXCHANGE    STA EXCH_CDEF+0
                LDX #<EXCH_CDEF
                LDY #>EXCH_CDEF
                JMP FULL_GETKEY

*-------------------------------

EXCH_CDEF       DB  $04             ;Modified
                DB  $00
                DW  HAND_CURSOR

*-------------------------------

; TODO: this is way overkill just to slide down some text

SCROLLER        LDA #$91
                STA ENDLINE
:LOOP1          LDA #$BD
                STA LINENUM
:LOOP2          LDX LINENUM
                JSR SET_DEST_LINE
                DEX
                JSR SET_SOURCE_LINE
                LDY #$0D
:LOOP3          LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY #$1F
                BCC :LOOP3
                LDA LINENUM
                CMP #$B6
                BCS :SKIPA
                CPY #$28
                BNE :LOOP3
:SKIPA          LDA LINENUM
                DEC LINENUM
                CMP ENDLINE
                BNE :LOOP2
                LDA ENDLINE
                INC ENDLINE
                CMP #$94
                BNE :LOOP1
                RTS
