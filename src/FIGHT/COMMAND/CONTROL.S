FIGHT_COMMAND   JSR SET_PAGE1
                JSR CLEAR_WTIME
                LDA ROUND
                BNE NOTRAP

                ; TODO: different than normal stats box?
                ; TODO: should loader be doing this?
                JSR DRAW_PICT
                PictSetGreen
                PictRect $01;$00;$115;$44
                PictMoveTo $01;$0A
                PictLineTo $115;$0A
                PictEnd

                LDA MONS_TOTAL
                STA ATALLY

;                 LDA ALIEN1          ;*17
;                 CMP #$02            ;*17
;                 BEQ NOTRAP          ;*17
;                 CMP #$20            ;*17
;                 BEQ NOTRAP          ;*17
;                 CMP #$23            ;*17
;                 BEQ NOTRAP          ;*17
; GETKEY1         BIT KEYBRD
;                 BPL GETKEY1
NOTRAP          BIT UNSTROB

                LDA ROUND
                BNE SURPRISE_DONE
                LDA SURPRISED_FLAG
                BNE SURPRISE_DONE
                BMI :2
                LDX MONS_TOTAL
                DEX
                BNE :1
                JSR DRAW_PICT
                PictTextAt 124;152;(THE_ATTACKER_HAS_THE)
                PictEnd
                BNE :3                  ; always
:1              JSR DRAW_PICT
                PictTextAt 118;152;(THE_ATTACKERS_HAVE_THE)
                PictEnd
                BNE :3                  ; always
:2              JSR DRAW_PICT
                PictTextAt 148;152;(YOU_HAVE_THE)
                PictEnd
:3              JSR DRAW_PICT
                PictTextAt 130;161;(ELEMENT_OF_SUPRISE)
                PictEnd

SURPRISE_DONE   JSR SHOW_PAGE

                JSR REFRESH_STATS

                LDA SURPRISED_FLAG
                BEQ :6
                BMI :4
                LDX #0
:3              LDA #$8A
                STA COMMAND,X
                LDA #$72
                STA COMMAND+1,X
                TXA
                CLC
                ADC #$20
                TAX
                CMP #$E0
                BNE :3
                JMP SUPOVER

:4              LDA ROUND
                BNE :6
                LDX #$03
:5              LDA #0              ;*** THIS SHOULD BE
                JSR WAIT_KEY        ;  CHANGED TO A KEYPRESS LATER !!!
                BMI :6
                DEX
                BPL :5
:6
                JSR TUNITS_LABEL
                JSR TIME_NOTCH_IN
                BIT UNSTROB
                JSR CLEAR_WCANCEL
REDSPOT         LDX #$1F
                LDA #$FF
ENTLOOP         STA ENTABLE,X
                DEX
                BPL ENTLOOP
                LDA #$00
                STA PLANNER
                STA ORIGRED
NXTPLAN         LDA PLANNER
                JSR SET_CHAR
                JSR BAD_STATUS
                BEQ NEXTMAN
NOMNEXT         JSR GROUP_CURSOR1C
                LDX PLANNER
                JSR CHAR_SQUARE
                LDX PLANNER
                JSR CHAR_POINT
                JSR PLANSUB
                JSR GROUP_CURSOR1C
                LDX PLANNER
                JSR CHAR_POINT
NEXTMAN         INC PLANNER
                LDA PLANNER
                CMP GRPNUMB
                BEQ DOOVER
                JMP NXTPLAN

DOOVER          JSR CLEAR_TUNITS_BOX
                JSR CLEAR_WTIME
                JSR DRAW_PICT
                ; TIME_NOTCH_OUT
                PictSetBlack1
                PictMoveTo $105;$BE
                PictLineTo $105;$B7
                PictLineTo $114;$B7
                PictSetGreen
                PictMoveTo $106;$BF
                PictLineTo $115;$BF
                PictLineTo $115;$B8
                PictTextAt 97;140;(ORDER_ENTRY_PHASE_IS_COMPLETE)
                PictTextAt 97;159;(WILL_YOU_A>CCEPT_THESE_ORDERS)
                PictTextAt 133;169;(OR_R>EDO_THEM?_)
                PictEnd

                JSR GET_INPUT_KEY
KEYCHK          CMP #"A"
                BEQ HITA
                CMP #"R"
                BEQ HITR
                JSR REGET_INPUT
                JMP KEYCHK
HITA            JSR CLEAR_WTIME
                JSR UNFLIP_STATS
                JSR CLEAR_MARKERS
SUPOVER         LDA #$00
                STA PLANNER
;                 LDA #$62
;                 PHA
;                 LDA #$FF
;                 PHA
;                 LDX #fReNarrate
;                 LDA ROUND
;                 BNE :1
;                 LDX #fNarrate
; :1              JMP SLOAD_FILE
                RTS

; put time notch in lower right corner box
TIME_NOTCH_IN   JSR DRAW_PICT
                PictSetBlack1
                PictMoveTo $106;$BF
                PictLineTo $115;$BF
                PictLineTo $115;$B8
                PictSetGreen
                PictMoveTo $105;$BE
                PictLineTo $105;$B7
                PictLineTo $114;$B7
                PictEnd
                RTS

DRAW_TUNITS_BOX JSR CLEAR_TUNITS_BOX
                ; fall through
TUNITS_LABEL    JSR DRAW_PICT
                PictTextAt 208;76;(T.UNITS)
                PictTextAt 253;76;(=)
                PictEnd
                RTS

CLEAR_TUNITS_BOX JSR DRAW_PICT
                PictSetBlack1
                PictFillRect 204;72;276;126
                PictEnd
                RTS

; remove marker square from each character in stats box
CLEAR_MARKERS   JSR FIRST_CHAR
:1              JSR BAD_STATUS
                BEQ :2
                LDX CHAR_INDEX
                JSR CHAR_SQUARE
:2              JSR NEXT_CHAR
                BCC :1
                RTS

HITR            JSR CLEAR_WTIME
                JSR DRAW_PICT
                PictTextAt 124;139;(DO_YOU_WANT_TO_REDO)
                PictTextAt 136;153;(THE_ENTIRE_GROUP)
                PictTextAt 136;163;(ONE_GROUP_MEMBER)
                PictTextAt 136;173;(CANCEL)
                PictEnd

                LDX #<REDO_CDEF
                LDY #>REDO_CDEF
                JSR MENU_INIT
                JSR MENU_SELECT
                DEX
                BMI ENTIRE
                DEX
                BMI ONEMEMB
                JSR CLEAR_WTIME
                JMP DOOVER

*-------------------------------

REDO_CDEF       DB  $83
                DB  $00
                DW  :REDO_CURS

:REDO_CURS      LDY :YTABLE,X
                LDX #$7A
                JMP DRAW_ARROW

:YTABLE         DB  $99,$A3,$AD

*-------------------------------

ENTIRE          JSR TIME_NOTCH_IN
                JSR CLEAR_MARKERS
                JSR TUNITS_LABEL
                JMP REDSPOT

ONEMEMB         JSR CLEAR_WTIME
                JSR TIME_NOTCH_IN
                JSR CANCEL_IN
                JSR DRAW_PICT
                PictTextAt 118;152;(REDO_WHOSE_FIGHT_PLAN?)
                PictEnd
                JSR OTHER_SUB
                LDA #$EE
                STA ORIGRED
                LDA PLANNER
                JSR SELECT_CHAR
                BCS :SKIPA
                JSR CHAR_CURSOR2
                JSR CANCEL_OUT
                JMP DOOVER
:SKIPA          JSR CHAR_CURSOR2
                JSR CANCEL_OUT
                JSR CLEAR_WTIME
                LDA PLANNER
                PHA
                JSR TUNITS_LABEL
                LDA CURSOR
                STA PLANNER
                JSR SET_CHAR
                JSR DENERGY
                JSR PLANSUB
                LDA PLANNER
                STA CURSOR
                PLA
                STA PLANNER
                JSR CHAR_CURSOR2
                JMP DOOVER

PLANSUB         LDA PLANNER
                ASL
                ASL
                ASL
                ASL
                ASL
                STA COMPNTR
                LDA #$00
                STA COMCNT
                LDA #$72
                STA TIMLEFT
                JSR DOTIME3
                LDX PLANNER
                LDY #position
                LDA (CHARDL),Y
                STA XYSPOTS,X
                JSR CLEAR_WTIME
                JSR OPTIONS
                LDX #$3F
                LDA #$FF
CHTOFF          STA CHENTAB,X
                DEX
                BPL CHTOFF
                JSR GETOPTS
                JSR ENUDATE
                LDY #$26
                LDX #$02
TOCHEN1         LDA CHENTAB,X
                STA (CHARDL),Y
                DEY
                DEX
                BPL TOCHEN1
                JMP ENUDATE

DID_CANCEL      JSR CLEAR_WCANCEL
                JSR CANCEL_OUT
                JSR DOTIME
                JSR OPTIONS
                JMP GETOP2

GETOPTS         LDA #$00
                STA OPTSPOT
                JSR DOTIME2
GETOP2          LDA COMCNT
                ASL
                CLC
                ADC COMCNT
                TAX
                LDY #$24
TOCHEN2         LDA (CHARDL),Y
                STA CHENTAB,X
                INX
                INY
                CPY #$27
                BNE TOCHEN2
                LDA ROUND
                BNE GETOP3
                LDY #$0D
                LDA (CHARDL),Y
                BPL GETOP3
                LDY #$6E
                LDA (CHARDL),Y
                BMI GETOP3
                JSR DOTIME2
                LDA #$0E
                STA OPTSPOT
                JSR DOTIME2
                JSR OPT_CURSOR
                JMP END
GETOP3          JSR OPT_CURSOR
                BIT UNSTROB
                JMP OPT_MOVEKEY
OPT_BLINK       LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI OPT_GOTKEY
                JSR OPT_CURSOR
                LDA #$00
                JSR WAIT_KEY
                JSR OPT_CURSOR
OPT_MOVEKEY     LDA KEYBRD
                BPL OPT_BLINK
OPT_GOTKEY      BIT UNSTROB
                JSR CHECK_LEFT
                BEQ OPT_LEFT
                JSR CHECK_RIGHT
                BEQ OPT_RIGHT
                JSR CHECK_UP
                BEQ OPT_UP
                JSR CHECK_DOWN
                BEQ OPT_DOWN
                JSR CHECK_ENTER
                BNE OPT_MOVEKEY

                LDY OPTSPOT
                LDA OPT_LEGALS,Y
                BPL CALL_COMMAND
                BMI OPT_MOVEKEY     ;Always

OPT_UP          JSR OPT_CURSOR
                JSR DOTIME
                JSR RANGER
                LDA OPTSPOT
                CMP MINOPT
                BNE :SKIPA
                LDA MAXOPT
                STA OPTSPOT
:SKIPA          DEC OPTSPOT
                BPL OPT_COM2        ;Always

OPT_DOWN        JSR OPT_CURSOR
                JSR DOTIME
                JSR RANGER
                INC OPTSPOT
                LDA OPTSPOT
                CMP MAXOPT
                BCC OPT_COM2
                LDA MINOPT
                STA OPTSPOT
                BPL OPT_COM2        ;Always

OPT_LEFT        JSR OPT_CURSOR
                JSR DOTIME
                LDA OPTSPOT
                SEC
                SBC #7
                BPL OPT_COM1
                CLC
                ADC #21
                BPL OPT_COM1        ;Always

OPT_RIGHT       JSR OPT_CURSOR
                JSR DOTIME
                LDA OPTSPOT
                CLC
                ADC #7
                CMP #21
                BCC OPT_COM1
;               SEC
                SBC #21
OPT_COM1        STA OPTSPOT
                JSR RANGER
OPT_COM2        JSR OPT_CURSOR
                JSR DOTIME2
                JMP OPT_MOVEKEY

CALL_COMMAND    LDA OPTSPOT
                ASL
                TAY
                LDA JMPNTS+1,Y
                PHA
                LDA JMPNTS,Y
                PHA
                RTS

JMPNTS          DW  SWING-1
                DW  SHOOT-1
                DW  ENERGY-1
                DW  THROW-1
                DW  USE-1
                DW  0               ;DUMMY
                DW  0               ;DUMMY
                DW  MOVE-1
                DW  IDENTIFY-1
                DW  EXCHANGE-1
                DW  PARRY-1
                DW  RUN-1
                DW  0               ;DUMMY
                DW  0               ;DUMMY
                DW  END-1
                DW  BACK1-1
                DW  REDO-1
                DW  OTHER-1
                DW  FLIP-1
                DW  DELAY-1

*-------------------------------

RANGER          LDA #$00
                LDY OPTSPOT
                CPY #$07
                BCC :SKIPA
                LDA #$07
                CPY #$0E
                BCC :SKIPA
                LDA #$0E
:SKIPA          STA MINOPT
                CLC
                ADC #$06
                STA MAXOPT
                RTS

*-------------------------------

OPT_CURSOR      LDX #$64
                LDA OPTSPOT
                CMP #7
                BCC :SKIPA
                LDX #$9F
;               SEC
                SBC #7
                CMP #7
                BCC :SKIPA
                LDX #$E6
;               SEC
                SBC #7
:SKIPA          TAY
                LDA OPTY,Y
                TAY
                JMP DRAW_ARROW

OPTY            DB  $81,$8A,$93
                DB  $9C,$A5,$AE
                DB  $B7
