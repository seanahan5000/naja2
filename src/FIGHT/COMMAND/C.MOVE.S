
; TODO: known bug with multiple moves, followed by BACK1 command,
;   followed by MOVE command B>ACK ONE COMMAND

MOVE            JSR UNDERS
                JSR CLEAR_WTIME

                JSR DRAW_PICT
                PictTextAt 108;132;(SELECT_DESTINATION_SQUARE)
                PictTextAt 126;180;(L>EAVE_MOVE_COMMAND)
                PictEnd

                LDA #$00
                STA PAST_MOVE
                STA LETBACK+1
MOVE2           LDA COMCNT
                BEQ FAILS2
                LDY COMPNTR
                LDA COMMAND-2,Y
                AND #$0F
                CMP #$07
                BNE FAILS2
                LDA LETBACK+1
                CMP #"B"
                BEQ PS2

                JSR DRAW_PICT
                PictTextAt 132;171;(B>ACK_ONE_COMMAND)
                PictEnd
                LDA #"B"
                BNE PS2                 ; always

FAILS2          LDA LETBACK+1
                CMP #"B"
                BNE FSKIP2
                JSR DRAW_PICT
                PictClear 18;171;34;178
                PictEnd
FSKIP2          LDA #$FF
PS2             STA LETBACK+1

                CLC
                LDX #<FILTER_MOVE
                LDY #>FILTER_MOVE
                JSR SELECT_CELL

GOENTER         LDA CURSOR
                STA PAST_MOVE
                JSR DRAW_GROUP_CURSOR2
                LDX CURSOR
                LDY LEGAL_CURS,X
                JSR I25_TO_CPOS
                LDX PLANNER
                STA XYSPOTS,X
                LDY XYSPOTS,X
                LDX #cmdMOVE
                LDA TIMES+timeMOVE
                JSR GENERAL_POST
                LDX COMCNT
                LDA TIMLEFT
                STA CTIMTAB,X
                LDY PLANNER
                LDA XYSPOTS,Y
                JSR GROUP_CURSOR1
                LDA COMCNT
                CMP #$0F
                BEQ GOEND2
                LDA TIMLEFT
                CMP TIMES+timeMOVE
                BCC GOEND2
                JMP MOVE2

FILTER_MOVE
LETBACK         CMP #"B"
                BEQ GOBACK
                CMP #"L"
                BEQ GOEND
                RTS

GOBACK          PLA
                PLA
                JSR DRAW_GROUP_CURSOR2
                LDY PLANNER
                LDA XYSPOTS,Y
                JSR GROUP_CURSOR1

                ; TODO: do something better than this hack
                LDA #$60                ; RTS
                STA NOBAKS
                JSR BACK1
                LDA #$20                ; JSR
                STA NOBAKS
                JMP MOVE2

GOEND           PLA
                PLA
                JSR DRAW_GROUP_CURSOR2
GOEND2          JSR UNDERS
                JSR CLEAR_WTIME
                JSR OPTIONS
                JMP GETOP2

XYSPOTS         DS  7
PAST_MOVE       DB  0

; draw underline cursor for each position in move path
UNDERS          LDA PLANNER
                ASL
                ASL
                ASL
                ASL
                ASL
                STA COUNTER
                CMP COMPNTR
                BEQ UNDOUT
UND2            LDY COUNTER
                LDA COMMAND,Y
                INC COUNTER
                CMP #$07
                BNE DONTDRW
                INY
                LDA COMMAND,Y
                JSR GROUP_CURSOR1
DONTDRW         INC COUNTER
                LDA COUNTER
                CMP COMPNTR
                BNE UND2
UNDOUT          RTS

;---------------------------------------

; TODO: move this to CURSORS.S?

;
; On entry:
;   Carry clear: plus-shaped pattern for MOVE
;   Carry Set: T-shaped pattern for USE
;
SELECT_CELL     PHP
                STX :FILTER+1
                STY :FILTER+2

                JSR INIT_CGRID

                LDY PLANNER
                LDA XYSPOTS,Y
                JSR POS_TO_I25

                PLP
                JSR BUILD_LEGAL_CURS

                LDX PAST_MOVE
                LDY #0
:1              LDA LEGAL_CURS,X
                BPL :2
                INX
                TXA
                AND #3
                TAX
                INY
                CPY #4
                BNE :1
:2              STX CURSOR
                JSR DRAW_GROUP_CURSOR2

:BLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI :GOT_KEY
                JSR DRAW_GROUP_CURSOR2
                LDA #$00
                JSR WAIT_KEY
                JSR DRAW_GROUP_CURSOR2
:KEY_LOOP       LDA KEYBRD
                BPL :BLINK
:GOT_KEY        BIT UNSTROB

                JSR CHECK_LEFT
                BEQ :CCWISE
                JSR CHECK_RIGHT
                BEQ :CWISE
                JSR CHECK_ENTER
                BEQ :ENTER
:FILTER         JSR $FFFF
                BNE :KEY_LOOP
:ENTER          RTS

:CCWISE         JSR DRAW_GROUP_CURSOR2
                LDY CURSOR
:3              DEY
                TYA
                AND #3
                TAY
                LDX LEGAL_CURS,Y
                BMI :3
                STY CURSOR
                JSR DRAW_GROUP_CURSOR2
                JMP :KEY_LOOP

:CWISE          JSR DRAW_GROUP_CURSOR2
                LDY CURSOR
:4              INY
                TYA
                AND #3
                TAY
                LDX LEGAL_CURS,Y
                BMI :4
                STY CURSOR
                JSR DRAW_GROUP_CURSOR2
                JMP :KEY_LOOP

LEGAL_CURS      DS  4                   ; TODO: move to scratch data area

;
; On entry:
;   CURSOR: pointing to position
;
DRAW_GROUP_CURSOR2
                LDY CURSOR
                LDX LEGAL_CURS,Y
                BMI :1
                JSR I25_MOVETO_CGRID
                LDX #<GROUP_SHAPE
                LDY #>GROUP_SHAPE
                JMP NEW_DRAW_SHAPE
:1              RTS
;
; On entry:
;   Y: I25 character position
;   Carry clear: plus-shaped pattern for MOVE
;   Carry Set: T-shaped pattern for USE
;
; TODO: support diagonals?
;
BUILD_LEGAL_CURS
                PHP

                LDX #3
                LDA #-1
:1              STA LEGAL_CURS,X
                DEX
                BPL :1

                CPY #5
                BCC :2
                TYA
;               SEC
                SBC #5
                TAX
                LDA CGRID_MAIN,X
                AND #cellBlocked
                BNE :2
                STX LEGAL_CURS+0
:2
                TYA
                PLP
                BCS :3
                CPY #20
                BCS :4
;               CLC
                ADC #5
:3              TAX
                LDA CGRID_MAIN,X
                AND #cellBlocked
                BNE :4
                STX LEGAL_CURS+2
:4
                LDA MOD5,Y
                BEQ :6
                DEY
                LDA CGRID_MAIN,Y
                AND #cellBlocked
                BNE :5
                STY LEGAL_CURS+3
:5              INY
                LDA MOD5,Y
:6
                CMP #4
                BEQ :8
                INY
                LDA CGRID_MAIN,Y
                AND #cellBlocked
                BNE :7
                STY LEGAL_CURS+1
:7              DEY
:8
                RTS

;---------------------------------------
