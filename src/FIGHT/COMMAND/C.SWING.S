
SWING_X         DB  0                   ; TODO: move to per-command ZPAGE

SWING           JSR CLEAR_CANCEL_IN
                JSR DRAW_PICT
                PictTextAt 111;133;(SWING_WITH_WHICH_HAND/S?)
                PictEnd

                LDX PLANNER
                LDA XYSPOTS,X
                LSR
                LSR
                LSR
                LSR
                TAX
                DEX
                DEX                     ; character X - 1
                STX SWING_X

                JSR SWING_BOX_3

                LDA #$00
                JSR SELECT_HAND
                JSR GETUSCO
                JSR SET_LEGALS
                LDA #$00
                STA LEGALS
                STA LEGALS+1
                STA LEGALS+2
                LDX USEDLOC
                LDA HANDTAB,X
                BEQ HAND_SWING
                CMP #5              ;robo sword/dagger
                BNE :SKIPB
                LDY CONVERT_TABLE,X
                INY
                LDX #1              ;dagger
                LDA (CHARDL),Y
                BEQ :SKIPA
                INX                 ;sword
:SKIPA          TXA
:SKIPB          CMP #3
                BNE NONWHIP_SWING

WHIP_SWING      LDA #$FF
                STA LEGALS+2
                JSR PICK_SWING
                JSR SWING_BOX_3
                JSR SBOTTOMR
                LDY #7
                LDA #1
                LDX SWTYPE
                BNE SWING_COMMON
                DEY
                LDA #3
                BNE SWING_COMMON    ;Always

HAND_SWING      JSR SWING_BOX_3       ;Hand ignores SWTYPE value
                JSR SBOTTOMR
                LDY #1
                TYA
                BNE SWING_COMMON    ;Always

NONWHIP_SWING   JSR PICK_SWING
                JSR SBOTTOMR
                LDY #3
                TYA
                LDX SWTYPE
                BEQ SWING_COMMON
                JSR SWING_BOX_3

                LDX SWTYPE
                DEX
                BNE :1
                JSR DRAW_PICT
                PictTextAt 117;142;(SWING_AT_WHICH_SQUARE?)
                PictEnd
                BNE :2                  ; always
:1              JSR DRAW_PICT
                PictTextAt 114;142;(THRUST_AT_WHICH_SQUARE?)
                PictEnd
:2              JSR PICK_OF_3
                JSR DRAW_PICT
                PictClear 16;142;36;149
                PictEnd
                LDY TCURSOR
                TYA
SWING_COMMON    STY DEBOXMOD+1
                ASL
                ASL
                ASL
                STA INSTR2
                CPY #3
                BEQ :SKIPA
                JSR SWING_BOX_Y
:SKIPA          JSR DRAW_PICT
                PictTextAt 120;132;(SWING_HOW_MANY_TIMES?)
                PictTextAt 125;143;(=)
                PictTextAt 141;143;(OF_SWINGS:)
                PictEnd
                LDX #$7F
                LDY #$8F
                JSR NUMBER_SIGN
                LDX #<LIMIT_SWNSHT
                LDY #>LIMIT_SWNSHT
                JSR GET_MULTIPLE
                PHP
DEBOXMOD        LDY #$FF            ;Modified
                JSR SWING_BOX_Y
                JSR SWNSHT_UNDO
                PLP
                BCS :SKIPA
                JMP DID_CANCEL
:SKIPA          LDA #cmdSWING
                STA INSTR1
                LDX USEDLOC
                LDA HANDTAB,X
                ASL
                ASL
                ASL
                ASL
                ASL
                ORA INSTR2
                STA INSTR2
                LDX PLANNER
                LDA XYSPOTS,X
                LSR
                LSR
                LSR
                LSR
                AND #%00000111
                ORA INSTR2
                STA INSTR2
                LDA SWTYPE
                ASL
                ASL
                ASL
                AND #%00010000
                ORA INSTR1
                STA INSTR1
                JSR CHANDER
                LDA TIMES+timeSWING
                STA TIMTAKE
                LDA HOWCUR1
                ASL
                ASL
                ASL
                ASL
                ORA HOWCUR2
:LOOP1          STA HOWCUR1
                JSR POST_COMMAND
                JSR TAKE_ENERUSE
                LDA COMCNT
                CMP #15
                BEQ :EXIT
                LDA HOWCUR1
                SEC
                SED
                SBC #1
                CLD
                BNE :LOOP1
:EXIT           JMP DID_CANCEL

*-------------------------------

PICK_OF_3       JSR INIT_AGRID_LEGAL
                ;
                ; block top 4 rows
                ;
                LDX #0
                LDA #cellBlocked
:1              STA AGRID_LEGAL,X
                INX
                CPX #20
                BNE :1
                ;
                ; mark bottom row cells that aren't already blocked
                ;
:2              LDA AGRID_LEGAL,X
                CMP #cellBlocked
                BEQ :3
                LDA #$80
                STA AGRID_LEGAL,X
:3              INX
                CPX #25
                BNE :2
                ;
                ; unmark 3 bottom row swing cells, except if cellBlocked
                ;
                LDY #3
                LDX SWING_X
:4              TXA
                BMI :5
                CPX #5
                BEQ :6
                LDA AGRID_LEGAL+20,X
                CMP #cellBlocked
                BEQ :5
                LDA #0
                STA AGRID_LEGAL+20,X
:5              INX
                DEY
                BNE :4
:6
                LDA SWING_X
                CLC
                ADC #21
                STA CURSOR

                LDX #<BOX_CURSOR
                LDY #>BOX_CURSOR
                JSR SET_GCURSOR

                LDA #$00                ; no wrap-around
                JSR GRID_SELECT
                PHP
                JSR DRAW_GCURSOR
                PLP
                BCC :CANCEL
                ;
                ; turn cursor X into relative left, center, right
                ;
                LDX CURSOR
                LDA MOD5,X
                SEC
                SBC SWING_X
                STA TCURSOR
                RTS

:CANCEL         PLA
                PLA
                JMP DID_CANCEL

*-------------------------------

PICK_SWING      JSR DRAW_PICT
                PictTextAt 111;134;(USE_WHICH_TYPE_OF_SWING?)
                PictTextAt 150;147;(HORIZONTAL)
                PictTextAt 150;157;(VERTICAL)
                PictTextAt 150;167;(THRUST)
                PictEnd
                LDX #<SWING_CDEF
                LDY #>SWING_CDEF
                JSR FULL_GETKEY
                LDA CURSOR
                STA SWTYPE
                BCS :EXIT
                JSR SWING_BOX_3
                PLA
                PLA
                JMP DID_CANCEL
:EXIT           JMP CLEAR_WCANCEL

SWING_CDEF      DB  $03
                DB  $00
                DW  :SWING_CURS

:SWING_CURS     LDY :YTABLE,X
                LDX #$88
                JMP DRAW_ARROW

:YTABLE         DB  $93,$9D,$A7

*-------------------------------

GETUSCO         LDX CURSOR
                CPX #$04
                BCC USEDCOM
                BNE NOTOP1
                LDX #$00
                LDA HANDTAB
                BNE USEDCOM
                INX
                BNE USEDCOM         ;Always
NOTOP1          LDX #$02
                LDA HANDTAB+2
                BNE USEDCOM
                INX
USEDCOM         STX USEDLOC
                LDA CURSOR
                STA CURHOLD
                RTS

*-------------------------------

CHANDER         LDA USEDLOC
                AND #$01
                BEQ LESKIP
                LDA #$40
                ORA INSTR1
                STA INSTR1
LESKIP          LDA CURHOLD
                CMP #$04
                BCC TWOSKIP
                LDA #$20
                ORA INSTR1
                STA INSTR1
                LDA CURHOLD
                AND #$01
                BEQ ULSKIP
LAZY            LDA #$80
                ORA INSTR1
                STA INSTR1
                BNE ULSKIP
TWOSKIP         LDA CURHOLD
                AND #$02
                BNE LAZY
ULSKIP          RTS

;------------------------------------------------------
;
; On Entry:
;   Y -> Box pattern number
;
;     +---+---+---+   +---+---+---+   +   +---+---+
;     | 0 | 1 | 2 |   |     3     |       |   4   |
;     +---+---+---+   +---+---+---+   +   +---+---+
;          <C>             <C>             <C>
;
;     +---+---+   +   @---+---+---+   +   +---+   +
;     |   5   |       |           |       |   |
;     +---+---+   +   +   +---+   +   +   + 7 +   +
;          <C>        |   | 6 |   |       |   |
;                     +---+---+---+   +   +---+   +
;                          <C>             <C>
;
; NOTE: reference point for all patterns relative to <C>
;   is marked with @ above
;
SWING_BOX_3     LDY #3
SWING_BOX_Y     LDX BOX_OFFSETS,Y
:1              STX COUNTER
                LDA BOX_DATA,X
                BMI :2
                JSR :DRAW_BOX
                LDX COUNTER
                INX
                BNE :1                  ; always
:2              AND #$7F
                ; fall through

:DRAW_BOX       TAY
                LDA SWING_X
                CLC
                ADC MOD5,Y
                BMI :3
                CMP #5
                BCS :3
                LDX DIV5,Y
                CLC
                ADC MUL5,X
                TAX
                LDA AGRID_LEGAL,X
                BNE :3
                STX CURSOR
                JMP BOX_CURSOR
:3              RTS

BOX_OFFSETS     DB  0,1,2,3
                DB  6,8,10,15

BOX_DATA        DB  20+$80
                DB  21+$80
                DB  22+$80
                DB  20,21,22+$80
                DB  21,22+$80
                DB  20,21+80
                DB  15,16,17,20,22+$80
                DB  16,21+$80
