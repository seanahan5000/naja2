ENERGY          JSR PICKECT
                JSR CLEAR_CANCEL_IN
                JSR DRAW_PICT
                PictTextAt 111;146;(SELECT_UPPER-LEFT_CORNER)
                PictTextAt 120;156;(OF_ENERGY_STRIKE_ZONE)
                PictEnd
                JSR GET_UL_EZONE
                BCS :SKIPA
                JSR DRAW_GCURSOR
                JMP DID_CANCEL

:SKIPA          JSR DRAW_PICT
                PictClear 15;146;37;153
                PictTextAt 108;146;(SELECT_LOWER-RIGHT_CORNER)
                PictEnd
                LDA CURSOR
                STA CURSOR_UL
                JSR GET_LR_EZONE
                BCS :SKIPB
                JMP ENERGY_EXIT

:SKIPB          JSR CLEAR_WCANCEL
                LDA CURSOR
                STA CURSOR_LR
                LDY CURSOR_UL
                JSR I25_TO_APOS
                TAY
                LDA ENERGY_INDEX
                ASL
                ASL
                ASL
                ASL
                ORA #cmdAIM
                TAX
                LDA TIMES+timeAIM
                JSR GENERAL_POST
                JSR DRAW_PICT
                PictTextAt 105;134;(EMIT_WHICH_TYPE_OF_ENERGY?)
                PictTextAt 150;147;(ELECTRICAL)
                PictTextAt 150;157;(HEAT)
                PictTextAt 150;167;(LIGHT)
                PictEnd
                LDX #<ENERGY_CDEF
                LDY #>ENERGY_CDEF
                JSR FULL_GETKEY
                LDA CURSOR
                STA ENTYPE
                BCS EPICKED
                JMP ENERGY_EXIT

*-------------------------------

ENERGY_CDEF     DB  $83
                DB  $00
                DW  :ENERGY_CURS

:ENERGY_CURS    LDX CURSOR
                LDY :YTABLE,X
                LDX #$88
                JMP DRAW_ARROW

:YTABLE         DB  $93,$9D,$A7

*-------------------------------

EPICKED         JSR CLEAR_WCANCEL
                JSR DRAW_PICT
                PictTextAt 120;135;(EMIT_HOW_MUCH_ENERGY?)
                PictTextAt 129;153;(PER_SQUARE:)
                PictTextAt 159;163;(TOTAL:)
                PictEnd

                LDX CURSOR_UL
                LDY CURSOR_LR
                LDA MOD5,Y
                SEC
                SBC MOD5,X
                STA DIMX
                LDA DIV5,Y
                SEC
                SBC DIV5,X
                STA DIMY
                TAY
                LDA #0
                SED
:1              SEC                     ; +1
                ADC DIMX
                DEY
                BPL :1
                CLD
                STA AREA

                LDA #$05
                STA CURSOR
                JSR AMOUNTS
                LDX #2
:LOOP1          LDA PER_AMOUNT,X
                STA PER_VALUE,X
                LDA TOTAL_AMOUNT,X
                STA TOTAL_VALUE,X
                DEX
                BPL :LOOP1
                LDA #$C9
                STA PER_DEF
                STA TOTAL_DEF
                LDA #$99
                STA PER_DEF+1
                LDA #$A3
                STA TOTAL_DEF+1
                LDX #<PER_DEF
                LDY #>PER_DEF
                LDA #1
                SEC
                JSR TEXT_INIT
                LDX #<TOTAL_DEF
                LDY #>TOTAL_DEF
                LDA #2
                SEC
                JSR TEXT_INIT
                JSR START_ENERLEV
                JSR VARROW_CURSOR
HBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI HGOTKEY
                JSR VARROW_CURSOR
                LDA #$00
                JSR WAIT_KEY
HMOVKEY1        JSR VARROW_CURSOR
HMOVKEY2        LDA KEYBRD
                BPL HBLINK
HGOTKEY         BIT UNSTROB
                JSR CHECK_LEFT
                BEQ HLEFT
                JSR CHECK_RIGHT
                BEQ HRIGHT
                JSR CHECK_UP
                BEQ GOHUP
                JSR CHECK_DOWN
                BEQ GOHDOWN
                JSR CHECK_ENTER
                BEQ HENTER
                CMP #"C"
                BEQ HCANCEL
                BNE HMOVKEY2        ;Always
GOHUP           JMP HUP
GOHDOWN         JMP HDOWN

HLEFT           LDA CURSOR
                CMP #$01
                BEQ HMOVKEY2
                JSR VARROW_CURSOR
                DEC CURSOR
                JSR AMOUNTS
                JMP HMOVKEY1

HRIGHT          LDA CURSOR
                CMP #$05
                BEQ HMOVKEY2
                JSR VARROW_CURSOR
                INC CURSOR
                JSR AMOUNTS
                JMP HMOVKEY1

; TODO: move to per-command ZPAGE
CURSOR_UL       DB  0
CURSOR_LR       DB  0
DIMX            DB  0
DIMY            DB  0
AREA            DB  0
ENTYPE          DB  0
ENCONV          DB  cmdENERGY+$40,cmdENERGY,cmdENERGY+$80

HENTER          LDA DIMX
                ASL
                ASL
                ASL
                ASL
                ORA DIMY
                STA INSTR2
                LDY ENTYPE
                LDA ENCONV,Y
                STA INSTR1
                LDA ENERGY_INDEX
                ASL
                CLC
                ADC ENERGY_INDEX
                TAX
                LDY #$00
HENLOOP         LDA PER_VALUE,Y
                STA ENTABLE,X
                INX
                INY
                CPY #$03
                BNE HENLOOP
                INC ENERGY_INDEX
                LDA TIMES+timeENERGY
                STA TIMTAKE
                JSR POST_COMMAND
                LDX COMCNT
                LDA TIMLEFT
                STA CTIMTAB,X
                JMP HCANC2
HCANCEL         LDA #$60                ; RTS
                STA NOBAKS
                INC ENERGY_INDEX
                JSR BACK1
                LDA #$20                ; JSR
                STA NOBAKS
                JSR DE_ENERLEV
HCANC2          LDA CURSOR_LR
                STA CURSOR
ENERGY_EXIT     JSR DRAW_GCURSOR
                LDA #$00
                STA EZONE_FLAG
                LDA CURSOR_UL
                STA CURSOR
                JSR DRAW_GCURSOR
                JMP DID_CANCEL

HUP             LDX #$02
                CLC
HULOOP1         LDA TOTAL_AMOUNT,X
                SED
                ADC TOTAL_VALUE,X
                CLD
                STA TEMP_VALUE,X
                DEX
                BPL HULOOP1
                BCS BADUP
                LDX #$02
                SEC
HULOOP2         LDA ORIG_ELEVEL,X
                SED
                SBC TEMP_VALUE,X
                CLD
                DEX
                BPL HULOOP2
                BCC BADUP
                LDX #$02
                CLC
HULOOP3         LDA PER_AMOUNT,X
                SED
                ADC PER_VALUE,X
                CLD
                STA PER_VALUE,X
                LDA TEMP_VALUE,X
                STA TOTAL_VALUE,X
                DEX
                BPL HULOOP3
                BMI HUPDWN_COM      ;Always
BADUP           JMP HMOVKEY2

HDOWN           LDX #$02
                SEC
HDLOOP1         LDA PER_VALUE,X
                SED
                SBC PER_AMOUNT,X
                CLD
                STA TEMP_VALUE,X
                DEX
                BPL HDLOOP1
                BCC BADOWN
                LDA TEMP_VALUE
                ORA TEMP_VALUE+1
                ORA TEMP_VALUE+2
                BEQ BADOWN
                LDX #$02
                SEC
HDLOOP2         LDA TOTAL_VALUE,X
                SED
                SBC TOTAL_AMOUNT,X
                CLD
                STA TOTAL_VALUE,X
                LDA TEMP_VALUE,X
                STA PER_VALUE,X
                DEX
                BPL HDLOOP2
HUPDWN_COM      LDA #1
                JSR TEXT_UPDATE
                LDA #2
                JSR TEXT_UPDATE
                JSR NEW_ENERLEV
BADOWN          JMP HMOVKEY2

TEMP_VALUE      DB  0,0,0

*-------------------------------

AMOUNTS         LDX #5
                LDA #$00
:LOOP1          STA PER_AMOUNT,X
                DEX
                BPL :LOOP1

                LDA CURSOR
                LSR
                TAY
                LDA #$01
                BCS :SKIPA
                LDA #$10
:SKIPA          STA PER_AMOUNT,Y

                LDA CURSOR
                SEC
                SBC #$01
                LSR
                TAY
                BCS :SKIPB
                LDA AREA
                STA TOTAL_AMOUNT,Y
                RTS
:SKIPB          LDA AREA
                LSR
                LSR
                LSR
                LSR
                STA TOTAL_AMOUNT,Y
                LDA AREA
                ASL
                ASL
                ASL
                ASL
                STA TOTAL_AMOUNT+1,Y
                RTS

PER_AMOUNT      DS  3
TOTAL_AMOUNT    DS  3

*-------------------------------

VARROW_CURSOR   LDY CURSOR
                LDX :XTABLE,Y
                LDY #$91
                JSR MOVE_TO
                LDX #<VARROW_SHAPE
                LDY #>VARROW_SHAPE
                JMP DRAW_TILE

:XTABLE         DB  $C9,$CF,$D5
                DB  $DB,$E1,$E7

VARROW_SHAPE    DB  %00000100
                DB  %00000100
                DB  %00000100
                DB  %00000100
                DB  %00011111
                DB  %00001110
                DB  %00000100

*-------------------------------

PICKECT         LDX #$00
                LDY #$00
PKLOOP          LDA ENTABLE,Y
                CMP #$FF
                BEQ OPICKD
                CPX #$0A
                BEQ NOPICKD
                INX
                INY
                INY
                INY
                INY
                BNE PKLOOP
NOPICKD         LDA #$FF
                RTS
OPICKD          TXA
                STA ENERGY_INDEX
                RTS
