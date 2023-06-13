*-------------------------------
*
*-------------------------------

FULL_GETKEY     JSR MENU_INIT
                JSR SET_INTERCEPT
                JMP MENU_SELECT

*-------------------------------
*
*-------------------------------

SET_INTERCEPT   LDX #<:LOOK_FOR_C
                LDY #>:LOOK_FOR_C
                JMP MENU_SET_FILTER

:LOOK_FOR_C     CMP #"C"
                BEQ :EXIT
                SEC
                RTS
:EXIT           CLC
                RTS

*-------------------------------
* Used by ENERGY to select upper
*   left of energy strike zone.
*-------------------------------

GET_UL_EZONE    JSR INIT_AGRID_LEGAL
                LDA #6              ; 1,1
                STA CURSOR
                LDX #<EZONE_CURSOR
                LDY #>EZONE_CURSOR
                JSR SET_GCURSOR
                LDA #$00                ; no wrap-around
                STA EZONE_FLAG
                BEQ GRID_SELECT         ; always

*-------------------------------
* Used by ENERGY to select lower
*   right of energy strike zone.
*   (It assumes GET_UL_EZONE was
*   called first.)
*-------------------------------

GET_LR_EZONE    LDX #0
                LDA #cellBlocked
:1              CPX CURSOR
                BEQ :2
                STA AGRID_LEGAL,X
                INX
                BNE :1                  ; always
:2              LDY MOD5,X
                BEQ :5
:3              DEY
                STY TEMP
:4              LDA #cellBlocked
                STA AGRID_LEGAL,Y
                TYA
                CLC
                ADC #5
                TAY
                CPY #25
                BCC :4
                LDY TEMP
                BNE :3
:5
                LDA #$FF
                STA EZONE_FLAG
                LDA #$00                ; no wrap-around
                BEQ GRID_SELECT         ; always

;---------------------------------------
; Used by AIM, THROW and IDENTIFY
;   to select destination square
;   for those commands.
;
; On Exit:
;   Carry clear: selection cancelled
;   Carry set: grid cell was selected
;   CURSOR: grid cell selected (0 to 24)
;---------------------------------------

GRID_AIM        JSR INIT_AGRID_LEGAL
                LDA #12                 ; (3, 8)
                STA CURSOR
                LDX #<BOX_CURSOR
                LDY #>BOX_CURSOR
                JSR SET_GCURSOR
                LDA #$FF                ; allow wrap-around
                ; fall through

;---------------------------------------
; Common entry point for all grid
;   cursor routines.
;
; On entry:
;   A: wrap-around flag
;       $00: no wrap-around
;       $FF: allow wrap-around
;   CURSOR: starting cell position (0 to 24)
;
; On Exit:
;   Carry clear: selection cancelled
;   Carry set: grid cell was selected
;   CURSOR: grid cell selected (0 to 24)
;---------------------------------------

GRID_SELECT     STA WRAP_FLAG
                JSR DRAW_GCURSOR
                BIT UNSTROB
                JMP GRID_LOOP

*------------------------------------------
* Actual grid movement routine.
*   On exit:
*      If carry set, <Space> was pressed
*      If carry clear, 'C'ancel was pressed
*------------------------------------------

GRID_BLINK      LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI GRID_KEY
                JSR DRAW_GCURSOR
                LDA #$00
                JSR WAIT_KEY
                JSR DRAW_GCURSOR
GRID_LOOP       LDA KEYBRD
                BPL GRID_BLINK
GRID_KEY        BIT UNSTROB
                JSR CHECK_LEFT
                BEQ GRID_LEFT
                JSR CHECK_RIGHT
                BEQ GRID_RIGHT
                JSR CHECK_UP
                BEQ GRID_UP
                JSR CHECK_DOWN
                BEQ GRID_DOWN
                JSR CHECK_ENTER
                BEQ :EXIT
                CMP #"C"
                BNE GRID_LOOP
                CLC
:EXIT           RTS

GRID_LEFT       LDX CURSOR
:1              LDA MOD5,X
                BNE :2
                BIT WRAP_FLAG
                BPL GRID_LOOP
                TXA
                CLC
                ADC #5
                TAX
:2              DEX
                LDA AGRID_LEGAL,X
                BEQ :3
                BIT WRAP_FLAG
                BMI :1
                BPL GRID_LOOP           ; always
:3              JMP UPDATE_GCURSOR

GRID_RIGHT      LDX CURSOR
:1              LDA MOD5,X
                CMP #4
                BNE :2
                BIT WRAP_FLAG
                BPL GRID_LOOP
                TXA
                SEC
                SBC #5
                TAX
:2              INX
                LDA AGRID_LEGAL,X
                BEQ :3
                BIT WRAP_FLAG
                BMI :1
                BPL GRID_LOOP           ; always
:3              JMP UPDATE_GCURSOR

GRID_UP         LDX CURSOR
:1              TXA
                SEC
                SBC #5
                BCS :2
;               CLC
                ADC #25
                BIT WRAP_FLAG
                BPL :3
:2              TAX
                LDA AGRID_LEGAL,X
                BEQ :4
                BIT WRAP_FLAG
                BMI :1
:3              JMP GRID_LOOP
:4              JMP UPDATE_GCURSOR

GRID_DOWN       LDX CURSOR
:1              TXA
                CLC
                ADC #5
                CMP #25
                BCC :2
;               SEC
                SBC #25
                BIT WRAP_FLAG
                BPL :3
:2              TAX
                LDA AGRID_LEGAL,X
                BEQ :4
                BIT WRAP_FLAG
                BMI :1
:3              JMP GRID_LOOP
:4              ;JMP UPDATE_GCURSOR

UPDATE_GCURSOR  CPX CURSOR
                BEQ :1
                TXA
                PHA
                JSR DRAW_GCURSOR
                PLA
                STA CURSOR
                JSR DRAW_GCURSOR
:1              JMP GRID_LOOP

INIT_AGRID_LEGAL
                JSR INIT_AGRID
                LDX #24
:1              LDA AGRID_MAIN,X
                AND #cellBlocked
                STA AGRID_LEGAL,X
                DEX
                BPL :1
                RTS

AGRID_LEGAL     DS  25                  ; TODO: move to data storage

*-------------------------------

SET_GCURSOR     STX DRAW_GCURSOR+1
                STY DRAW_GCURSOR+2
                RTS

DRAW_GCURSOR    JMP $FFFF

WRAP_FLAG       DB  0

*-------------------------------

BOX_CURSOR      LDY #%01111110
                LDX CURSOR
                LDA MOD5,X
                BNE :1
                INY                     ; #%01111111
:1              STY BOX_MOD

                LDY MOD5,X
                LDA GRID_XPNTS,Y
                PHA
                LDY DIV5,X
                LDA AGRID_YPNTS,Y
                TAY
                DEY                     ; adjust down 1
                PLA
                TAX
                DEX                     ; adjust right 1
                JSR MOVE_TO

                LDX #<BOX_SHAPE
                LDY #>BOX_SHAPE
                JMP NEW_DRAW_SHAPE

BOX_SHAPE       DB  $32,$00

                DB  %01111110
                DB  %10000001

                DB  %01111111
                DB  %10000000

                DB  %00000001
                DB  %10000010

                DB  %00000001
                DB  %00000001
                DB  %00000001
                DB  %00000001
BOX_MOD         DB  %01111110
                DB  %10000000

                DB  %00000000
                DB  %00000000
                DB  %00000000
                DB  %00000000
                DB  %01111111
                DB  %10000000

                DB  %00000010
                DB  %00000010
                DB  %00000010
                DB  %00000010
                DB  %00000001
                DB  %10000000

*-------------------------------

CHAR_CURSOR1    LDX CURSOR
                JSR CHAR_SQUARE
CHAR_CURSOR2    LDX CURSOR
                JSR CHAR_POINT
                LDA CURSOR
                JSR SET_CHAR
                JSR GROUP_CURSOR1C
                LDA PLANNER
                JMP SET_CHAR

CHAR_SQUARE     LDY YPOINTS,X
                LDX #$05
                JMP DRAW_MARKER

CHAR_POINT      LDY YPOINTS,X
                LDX #$0A
                JMP DRAW_MARKER_TIP

*-------------------------------

; NOTE: legacy name GROUP_CURSOR1, with CPOS_TO_XY already called
; TODO: rename this and call directly?

GROUP_CURSOR1C  JSR CPOS_TO_XY
                JMP DRAW_GRID_CURSOR_XY

GROUP_CURSOR1   JSR POS_TO_XY
                JMP DRAW_GRID_CURSOR_XY

*-------------------------------

GROUP_SHAPE     DB  $22,$00

                DB  %11111111
                DB  %11111111

                DB  %01111111
                DB  %01111110
                DB  %01111100
                DB  %10000000

                DB  %01111111
                DB  %00111111
                DB  %00011111
                DB  %10000000

*-------------------------------

HAND_CURSOR     LDX CURSOR
                CPX #4
                BCC :SKIPB
                BNE :SKIPA
                LDX #0
                JSR :SKIPB
                LDX #1
                BNE :SKIPB              ; always
:SKIPA          LDX #2
                JSR :SKIPB
                LDX #3
:SKIPB          LDY HAND_YPNTS,X
                LDX #$8E
                JMP DRAW_TRIANGLE

HAND_YPNTS      DB  $92,$9A,$A2,$AA

*-------------------------------
