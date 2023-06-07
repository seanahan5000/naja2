*===============================
*
*===============================

MASK_BITS       =   TEMP+0

CREATE_MGRID    JSR INIT_AGRID

                LDX #0
:2              STX POINTER
                LDA PECKS,X
                BEQ :4
                BMI :3
                JSR SET_MONSTER
**** CHECK FOR SPECIAL THINGS LIKE BEING INVISIBLE, ETC.
                LDY #monSTATUS
                LDA (MONS_PTR),Y
                CMP #dead
                BEQ :3
                JSR MONS_TOGRID
                LDY #monCRNTCMD
                LDA (MONS_PTR),Y
                AND #%00001111
                CMP #cmdMOVE
                BNE :3
                INY
                LDA (MONS_PTR),Y
                JSR SET_AGRID_AUX

:3              LDX POINTER
                INX
                BNE :2              ;Always
:4              RTS

INIT_AGRID      LDY #0
                LDX #0
:1              STX COUNT
                LDA GRID_BITS+0,X
                STA MASK_BITS
                LDX #0
:2              LSR MASK_BITS
                ROR
                ROR
                ROR
                AND #%00100000          ; inaccessible cell
:3              STA AGRID_MAIN,Y
                STA AGRID_AUX,Y
                INY
                INX
                CPX #5
                BNE :2
                LDX COUNT
                INX
                CPX #5
                BNE :1
                RTS

*===============================
*
*===============================

MONS_FROMGRID   LDX #24
:1              LDA AGRID_AUX,X
                BPL :2
                AND #%00011111
                CMP MONSTER_INDEX
                BNE :2
                LDA #0
                STA AGRID_AUX,X
                LDA AGRID_MAIN,X
                BPL :2
                AND #%00011111
                CMP MONSTER_INDEX
                BNE :2
                LDA #0
                STA AGRID_MAIN,X
:2              DEX
                BPL :1
                RTS

*======================================
*
*======================================

MONS_TOGRID     LDY #monPOSITION
                LDA (MONS_PTR),Y
                JSR SET_AGRID_MAIN

                LDX #24
:1              LDA AGRID_MAIN,X
                BPL :2
                TAY
                AND #%00011111
                CMP MONSTER_INDEX
                BNE :2
                TYA
                STA AGRID_AUX,X
:2              DEX
                BPL :1
                RTS

;----------------------------------
;
; On entry:
;               A: alien position
;   MONSTER_INDEX: alien to set
;     TVIEW_WIDTH: alien width
;    TVIEW_HEIGHT: alien height
;
;----------------------------------

CHECK_AGRID_AUX LDX #<AGRID_AUX
                LDY #>AGRID_AUX
                BNE CHECK_AGRID_CMN     ; always

CHECK_AGRID_MAIN LDX #<AGRID_MAIN
                LDY #>AGRID_MAIN

CHECK_AGRID_CMN STX :MOD2+1
                STY :MOD2+2
                JSR MONPOS_TO_I25

                LDA TVIEW_WIDTH
                CLC
                ADC MOD5,Y
                CMP #6
                BCS :NOT_OKAY

                LDA TVIEW_HEIGHT
                STA YCOUNT
                CLC
                ADC DIV5,Y
                CMP #6
                BCS :NOT_OKAY

:1              LDX TVIEW_WIDTH
:MOD2           LDA $FFFF,Y
                BEQ :OKAY
                BPL :NOT_OKAY
                AND #%00011111
                CMP MONSTER_INDEX
                BNE :NOT_OKAY
:OKAY           INY
                DEX
                BNE :MOD2
                TYA
                CLC
                ADC #5+1                ; grid width
                SBC TVIEW_WIDTH
                TAY
                DEC YCOUNT
                BNE :1
                CLC
                RTS
:NOT_OKAY       SEC
                RTS

;----------------------------------
;
;               A: alien position
;   MONSTER_INDEX: alien to set
;     TVIEW_WIDTH: alien width
;    TVIEW_HEIGHT: alien height
;
;----------------------------------

SET_AGRID_AUX   LDX #<AGRID_AUX
                LDY #>AGRID_AUX
                BNE SET_AGRID_CMN       ; always

SET_AGRID_MAIN  LDX #<AGRID_MAIN
                LDY #>AGRID_MAIN

SET_AGRID_CMN   STX :MOD2+1
                STY :MOD2+2
                JSR MONPOS_TO_I25

                LDA TVIEW_HEIGHT
                STA YCOUNT
                LDX TVIEW_WIDTH
                LDA MONSTER_INDEX
                ORA #%10000000
                STA :MOD1+1
                ORA #%01000000
                BNE :MOD2               ; always

:1              LDX TVIEW_WIDTH
:MOD1           LDA #$FF
:MOD2           STA $FFFF,Y
                INY
                DEX
                BNE :MOD1
                TYA
                CLC
                ADC #5+1                ; grid width
                SBC TVIEW_WIDTH
                TAY
                DEC YCOUNT
                BNE :1
                RTS

*===============================
*
*===============================

CHANGE_CGRID    JSR CAPTURE_CGRID
                JSR CREATE_CGRID
                JMP UPDATE_CGRID

*-------------------------------

CREATE_CGRID    LDX #24
:LOOP1          LDA #$FF
                STA MASTER_CGRID,X
                DEX
                BPL :LOOP1

                JSR FIRST_CHAR
:LOOP2          JSR BAD_STATUS
                BEQ :SKIPA
                LDX CHAR_INDEX
                LDA TEMPCHAR_XY,X
                JSR CHAR_INDEXER
                STX TEMP
                LDA CHAR_INDEX
                STA MASTER_CGRID,Y
                TAX
                LDA IMAGENS,X
                BEQ :SKIPA
                LDA TEMP
                CMP #$04
                BEQ :SKIPA
                INY
                LDA MASTER_CGRID,Y
                CMP #$FF
                BNE :SKIPA
                LDA CHAR_INDEX
                ORA #$80
                STA MASTER_CGRID,Y
:SKIPA          JSR NEXT_CHAR
                BCC :LOOP2
                LDA CHAR_NUMBER     ;Take note of this
                JMP SET_CHAR

*-------------------------------

CAPTURE_CGRID   LDX #$18
:LOOP1          LDA MASTER_CGRID,X
                STA OLD_CGRID,X
                DEX
                BPL :LOOP1
                RTS

*-------------------------------

UPDATE_CGRID    LDA #0
                STA XCOUNT
                STA YCOUNT
                STA COUNT
:LOOP1          LDX COUNT
                LDA OLD_CGRID,X
                CMP MASTER_CGRID,X
                BEQ :SKIPA
                PHA
                LDX XCOUNT
                LDY YCOUNT
                JSR CGRID_MOVETO
                PLA
                JSR :SUBA
                LDX COUNT
                LDA MASTER_CGRID,X
                JSR :SUBA
:SKIPA          INC XCOUNT
                LDA XCOUNT
                CMP #5
                BNE :SKIPB
                LDA #0
                STA XCOUNT
                INC YCOUNT
:SKIPB          INC COUNT
                LDA COUNT
                CMP #25
                BNE :LOOP1
                LDA CHAR_NUMBER     ;Take note of this
                JSR SET_CHAR
                RTS

:SUBA           TAY
                CMP #$FF
                BEQ :2
                TYA
                AND #$7F
                JSR SET_CHAR
                TYA
                BMI :1
                JMP DRAW_PROF_TOPVIEW
:1              JMP DRAW_PROF_IMAGEN
:2              RTS

*-------------------------------
