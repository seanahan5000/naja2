
PNEW			=	$C2					; +1
PVAL			=	$C4					; +1
PTXT			=	$C6					; +1

                DUMMY   SCRATCH_PAGE
ENEW1           DS  3
EVAL1           DS  3
ETEXT1          DS  8

ENEW2           DS  3
EVAL2           DS  3
ETEXT2          DS  8

DVAL            DS  2
DNEW            DS  2
                DEND

; Common code for I.TRANSFER.S and I.REGENERATE.S

RT_START        STX ITARGET_CHAR

                JSR DRAW_PICT
                PictClear 24;80;39;105
                PictSetBlack1
                PictFillRect 2;11;276;78
                PictSwap $00;$50;$28;$32
                PictSetGreen
                PictMoveTo $01;$30
                PictLineTo $115;$30
                PictClear 24;80;39;105
                PictClear 0;49;40;50
                PictEnd

RT_START2       LDA ITARGET_CHAR
                JSR SET_CHAR
                LDY #14
                JSR VMOVE_TO
                JSR STATS_LINE

                LDA ISOURCE_CHAR
                JSR SET_CHAR
                LDY #38
                JSR VMOVE_TO
                JSR STATS_LINE

                LDA #>ENEW1
                STA PNEW+1
                STA PVAL+1
                STA PTXT+1

                LDX #7
                LDA #TextSpace
:2              STA ETEXT1,X
                STA ETEXT2,X
                DEX
                BPL :2
                RTS

FROMJ_TRANSFER	JSR	BIG_STATS_BOX

				JSR DRAW_PICT
				PictTextAt 177;84;(TRANSFER_ENERGY)
				PictTextAt 198;93;(TO_WHOM?)
				PictEnd

				LDX	ISOURCE_CHAR
				LDA	#$FF
				STA	LEGALS,X
				LDY YPOINTS,X
                LDX #$06
   				JSR DRAW_MARKER

				JSR	PRE_ARROW
				JSR	MENU_SELECT
				CPX	#7
				BNE	:NO_CANCEL
                JMP HIDE_BIG_STATS      ; return back to C.ISTATS.S

:NO_CANCEL      JSR RT_START
                JMP TRANSFER_CMN

TOJ_TRANSFER    JSR DRAW_PICT
                PictSetPage1
                PictClear 0;0;39;50
                PictSetGreen
                PictRect 1;0;$115;48
                PictMoveTo $01;$0A
                PictLineTo $115;$0A
                PictVMoveTo 2
                PictCall STATS_HEADER
                PictEnd
                JSR RT_START2
                JSR DRAW_PICT
                PictSwap 0;0;40;49
                PictSetPage2
                PictEnd

TRANSFER_CMN    JSR DRAW_PICT
				PictTextAt 48;26;(ENERGY_TRANSFER_AMOUNT:)
                PictTextAt 195;51;(C>ANCEL)
				PictEnd

                LDA ITARGET_CHAR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:1              LDA (CHARDL),Y
                STA ENEW1,X
                DEY
                DEX
                BPL :1

                LDA ISOURCE_CHAR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:2              LDA (CHARDL),Y
                STA ENEW2,X
                DEY
                DEX
                BPL :2

                JSR TUPDATE_FIRST

                ; set cursor based on juicer energy level
                LDY #0
                LDX #0
:4              LDA ETEXT2,X
                CMP #TextSpace
                BNE :5
                INX
                INY
                CPY #5
                BNE :4
:5              STY CURSOR

                JSR TR_CURSIT

TRBLINK         LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI :GOTKEY
                JSR TR_CURSIT
                LDA #$00
                JSR WAIT_KEY
                JSR TR_CURSIT
                BIT KEYBRD
                BPL TRBLINK
:GETKEY         LDA KEYBRD
                BPL :GETKEY
:GOTKEY         BIT UNSTROB
                JSR CHECK_LEFT
                BEQ :LEFT
                JSR CHECK_RIGHT
                BEQ :RIGHT
                JSR CHECK_UP
                BEQ :UP
                JSR CHECK_DOWN
                BEQ :DOWN
                CMP #"C"
                BEQ :CANCEL
                JSR CHECK_ENTER
                BNE :GETKEY

:ENTER        	LDA ITARGET_CHAR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:1              LDA ENEW1,X
                STA (CHARDL),Y
                DEY
                DEX
                BPL :1
                JSR CALC_ALL

                LDA ISOURCE_CHAR
                JSR SET_CHAR
                LDY #energylev+2
                LDX #2
:2              LDA ENEW2,X
                STA (CHARDL),Y
                DEY
                DEX
                BPL :2
                JSR CALC_ALL

:CANCEL			JSR DRAW_PICT
				PictClear 27;51;34;58
				PictSwap $00;$31;$28;$00
				PictEnd
                RTS                     ; back to C.ISTATS.S

:LEFT           LDA CURSOR
                BEQ :GETKEY
                JSR TR_CURSIT
                DEC CURSOR
                JSR TR_CURSIT
                JMP :GETKEY

:RIGHT          LDA CURSOR
                CMP #5
                BEQ :GETKEY
                JSR TR_CURSIT
                INC CURSOR
                JSR TR_CURSIT
                JMP :GETKEY

:UP             LDA ITARGET_CHAR
                JSR SET_CHAR
                JSR SET_ELEFT
                JSR ADD_ENERGY
                BCC :RIGHT
                JSR SET_ERIGHT
                JSR SUB_ENERGY
                BCC :RIGHT
                JSR TUPDATE
                JMP :GETKEY

:DOWN           LDA ISOURCE_CHAR
                JSR SET_CHAR
                JSR SET_ERIGHT
                JSR ADD_ENERGY
                BCC :RIGHT
                JSR SET_ELEFT
                JSR SUB_ENERGY
                BCC :RIGHT
                JSR TUPDATE
                JMP :GETKEY

TR_CURSIT       LDX #198
                LDY #26
                LDA #191
                ; fall through
RT_CURSIT       PHA
                JSR MOVE_TO
                LDX #0
                LDA CURSOR
                BEQ :2
                LDA #TextSpace
:1              STA TEXT_BUFFER,X
                INX
                CPX CURSOR
                BNE :1
:2              LDA #1
                STA TEXT_BUFFER,X
                LDA #0
                INX
                BNE :4                  ; always
:3              STA TEXT_BUFFER,X
                INX
:4              CPX #6
                BNE :3
                LDA #TextLineEnd
                STA TEXT_BUFFER,X
                JSR DRAW_TEXTBUF

                LDX CURSOR
                PLA
                CLC
                ADC :XOFFSETS,X
                TAX
                JSR HMOVE_TO
                LDX #<PLUS_MINUS
                LDY #>PLUS_MINUS
                JMP DRAW_TILE

:XOFFSETS       DB  0,6,12,18,24,30

PLUS_MINUS      DB  %00001100
                DB  %00001100
                DB  %00111111
                DB  %00001100
                DB  %00001100
                DB  %00000000
                DB  %00111111

SET_ELEFT       LDX #<ENEW1
                BEQ SET_ECMN            ; always
SET_ERIGHT      LDX #<ENEW2
SET_ECMN        STX PNEW
                INX
                INX
                INX
                STX PVAL
                INX
                INX
                INX
                STX PTXT
                RTS

TUPDATE_FIRST	LDA #$38				; SEC
				BNE TUPDATE_CMN			; always
TUPDATE         LDA #$18				; CLC
TUPDATE_CMN		STA :MOD
				JSR SET_ELEFT
                LDY #$0E
                JSR :UPDATE
                JSR SET_ERIGHT
                LDY #$26
                ; fall through
:UPDATE         JSR VMOVE_TO
                JSR RT_DIFF_TEXT
:MOD            CLC
                BCS :1
                LDX #$C6
                JSR DRAW_TEXTBUF_X
                LDX #$C6
                JSR HMOVE_TO
                LDX #<TEXT_BUFFER+8
                LDY #>TEXT_BUFFER+8
                JMP DRAW_TEXT
:1              RTS

RT_DIFF_TEXT    LDY #0
                LDX #0
:1              LDA (PNEW),Y
                STA (PVAL),Y
                PHA
                LSR
                LSR
                LSR
                LSR
                STA TEXT_BUFFER+8,X
                INX
                PLA
                AND #$0F
                STA TEXT_BUFFER+8,X
                INX
                INY
                CPX #6
                BNE :1

                LDX #0
:2              LDA TEXT_BUFFER+8,X
                BNE :3
                LDA #TextSpace
                STA TEXT_BUFFER+8,X
                INX
                CPX #5
                BNE :2
:3
                LDY #0
:4              LDA (PTXT),Y
                CMP TEXT_BUFFER+8,Y
                BEQ :5
                STA TEXT_BUFFER,Y
                LDA TEXT_BUFFER+8,Y
                STA (PTXT),Y
                BPL :6                  ; always

:5              LDA #TextSpace
                STA TEXT_BUFFER,Y
                STA TEXT_BUFFER+8,Y
:6              INY
                CPY #6
                BNE :4
                LDA #TextLineEnd
                STA TEXT_BUFFER,Y
                STA TEXT_BUFFER+8,Y
                RTS
;
; On exit:
;   C=1: good add
;   C=0: bad add
;
ADD_ENERGY      LDY CURSOR
                LDX AM_OFFSETS,Y
                LDY #2
                SED
                CLC
:1              LDA (PVAL),Y
                ADC AMOUNTS,X
                STA (PNEW),Y
                STA TEXT_BUFFER,Y
                DEX
                DEY
                BPL :1
                BCS :3
                LDY #energymax+2
                LDX #2
                SEC
:2              LDA (CHARDL),Y
                SBC TEXT_BUFFER,X
                DEY
                DEX
                BPL :2
                BMI :4                  ; always
:3              CLC
:4              CLD
                RTS
;
; On exit:
;   C=1: good subtract
;   C=0: bad subtract
;
SUB_ENERGY      LDY CURSOR
                LDX AM_OFFSETS,Y
                LDY #2
                SED
                SEC
                LDA #0
:1              STA :MOD+1
                LDA (PVAL),Y
                SBC AMOUNTS,X
                STA (PNEW),Y
:MOD            ORA #$FF
                DEX
                DEY
                BPL :1
                BCC :2
                TAX
                BNE :2
                CLC
:2              CLD
                RTS

AM_OFFSETS      DB  0+2,3+2,6+2,9+2
                DB  12+2,15+2,18+2,21+2

AMOUNTS         DB  $10,$00,$00
                DB  $01,$00,$00
                DB  $00,$10,$00
                DB  $00,$01,$00
                DB  $00,$00,$10
                DB  $00,$00,$01
                DB  $00,$00,$00
