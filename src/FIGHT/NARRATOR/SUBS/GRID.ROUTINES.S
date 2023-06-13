*===============================
*
*===============================

CREATE_MGRID    JSR INIT_AGRID

                LDX #24
:0              LDA AGRID_MAIN,X
                STA AGRID_AUX,X
                DEX
                BPL :0

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
                JSR APOS_TO_I25

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
                JSR APOS_TO_I25

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

CREATE_CGRID    JSR INIT_CGRID

                JSR FIRST_CHAR
:1              JSR BAD_STATUS
                BEQ :2
                LDX CHAR_INDEX
                LDA TEMPCHAR_XY,X
                JSR CHAR_INDEXER
                STX TEMP
                LDX CHAR_INDEX
                TXA
                ORA #%10000000
                STA CGRID_MAIN,Y
                LDA IMAGENS,X
                BEQ :2
                LDA TEMP
                CMP #$04                ; don't draw if in right column
                BEQ :2
                INY
                LDA CGRID_MAIN,Y
                BNE :2
                LDA CHAR_INDEX
                ORA #%01000000
                STA CGRID_MAIN,Y
:2              JSR NEXT_CHAR
                BCC :1
                LDA CHAR_NUMBER     ;Take note of this
                JMP SET_CHAR

*-------------------------------

CAPTURE_CGRID   LDX #$18
:LOOP1          LDA CGRID_MAIN,X
                STA OLD_CGRID,X
                DEX
                BPL :LOOP1
                RTS

*-------------------------------

UPDATE_CGRID    LDX #0
:1              STX COUNT
                LDA OLD_CGRID,X
                CMP CGRID_MAIN,X
                BEQ :2
                JSR :DRAW_SUB
                LDX COUNT
                LDA CGRID_MAIN,X
                JSR :DRAW_SUB
:2              LDX COUNT
                INX
                CPX #25
                BNE :1
                LDA CHAR_NUMBER         ; restore current character
                JMP SET_CHAR

:DRAW_SUB       PHA
                JSR I25_MOVETO_CGRID
                PLA
                BEQ :4                  ; skip empty
                CMP #cellBlocked
                BEQ :4                  ; skip cellBlocked
                TAY
                AND #%00000111
                JSR SET_CHAR
                TYA
                BPL :3
                JMP DRAW_PROF_TOPVIEW
:3              JMP DRAW_PROF_IMAGEN
:4              RTS

*-------------------------------
