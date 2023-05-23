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

GET_UL_EZONE    LDA #$29
                STA CURSOR
                LDX #<EZONE_CURSOR
                LDY #>EZONE_CURSOR
                JSR SET_GCURSOR
                LDA #$00            ;Don't allow wrap-around
                STA EZONE_FLAG
                LDX #$1A
                LDY #$56
                BNE GET_GRIDCURS    ;Always

*-------------------------------
* Used by ENERGY to select lower
*   right of energy strike zone.
*   (It assumes GET_UL_EZONE was
*   called first.)
*-------------------------------

GET_LR_EZONE    LDA #$FF
                STA EZONE_FLAG
                LDA #$00
                LDX CURSOR
                STX MARGIN
                LDY #$56
                BNE GET_GRIDCURS    ;Always

*-------------------------------
* Used by AIM, THROW and IDENTIFY
*   to select destination square
*   for those commands.
*-------------------------------

GET_AIM         LDA #$38
                STA CURSOR
                LDX #<BOX_CURSOR
                LDY #>BOX_CURSOR
                JSR SET_GCURSOR
                LDA #$FF            ;Allow wrap-around
                LDX #$1A
                LDY #$56

*-------------------------------
* Common entry point for all grid
*   cursor routines.
*-------------------------------

GET_GRIDCURS    STA WRAP_FLAG
                STX LIMIT_UL
                STY LIMIT_LR
                JSR DRAW_GRIDCURS
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
                JSR DRAW_GRIDCURS
                LDA #$00
                JSR WAIT_KEY
                JSR DRAW_GRIDCURS
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

GRID_LEFT       LDX #$F0
                LDA CURSOR
                EOR LIMIT_UL
                AND #%11110000
                BNE GRID_COMMON1
                BIT WRAP_FLAG
                BPL GRID_LOOP
                LDA CURSOR
                EOR LIMIT_LR
                AND #%00001111
                EOR LIMIT_LR
                BNE GRID_COMMON2    ;Always

GRID_RIGHT      LDX #$10
                LDA CURSOR
                EOR LIMIT_LR
                AND #%11110000
                BNE GRID_COMMON1
                BIT WRAP_FLAG
                BPL GRID_LOOP
                LDA CURSOR
                EOR LIMIT_UL
                AND #%00001111
                EOR LIMIT_UL
                BNE GRID_COMMON2    ;Always

GRID_UP         LDX #$01
                LDA CURSOR
                EOR LIMIT_UL
                AND #%00001111
                BNE GRID_COMMON1
                BIT WRAP_FLAG
                BPL GRID_LOOP
                LDA CURSOR
                EOR LIMIT_LR
                AND #%11110000
                EOR LIMIT_LR
                BNE GRID_COMMON2    ;Always

GRID_DOWN       LDX #$FF
                LDA CURSOR
                EOR LIMIT_LR
                AND #%00001111
                BNE GRID_COMMON1
                BIT WRAP_FLAG
                BPL GRID_COMMON3
                LDA CURSOR
                EOR LIMIT_UL
                AND #%11110000
                EOR LIMIT_UL
                BNE GRID_COMMON2    ;Always
GRID_COMMON1    TXA
                CLC
                ADC CURSOR
GRID_COMMON2    PHA
                JSR DRAW_GRIDCURS
                PLA
                STA CURSOR
                JSR DRAW_GRIDCURS
GRID_COMMON3    JMP GRID_LOOP

*-------------------------------

SET_GCURSOR     STX DRAW_GRIDCURS+1
                STY DRAW_GRIDCURS+2
                RTS

DRAW_GRIDCURS   JMP $FFFF

WRAP_FLAG       DB  0
LIMIT_UL        DB  0
LIMIT_LR        DB  0

*-------------------------------

; TODO: share with /FIGHT/NARRATOR/ENERGY.S

EZONE_CURSOR    LDA CURSOR
                SEC
                SBC #$05
                JSR POS_TO_XY

                LDA GRID_XPNTS,X
                PHA
                TAX
                LDA AGRID_YPNTS,Y
                PHA
                TAY
                DEX
                BIT EZONE_FLAG
                BPL :1
                TXA
                CLC
                ADC #15                 ; GCELL_WIDTH
                TAX
:1              JSR MOVE_TO
                LDX #<EZONE_VERT
                LDY #>EZONE_VERT
                JSR NEW_DRAW_SHAPE

                PLA
                TAY
                PLA
                TAX
                DEY
                BIT EZONE_FLAG
                BPL :2
                TYA
                CLC
                ADC #11                 ; GCELL_HEIGHT
                TAY
:2              JSR MOVE_TO
                LDX #<EZONE_HORZ
                LDY #>EZONE_HORZ
                JMP NEW_DRAW_SHAPE

EZONE_FLAG      DB  0

EZONE_VERT      DB  $12,$00
                DB  %10000001
                DB  %00000001
                DB  %00000001
                DB  %00000001
                DB  %10000000

EZONE_HORZ      DB  $21,$00
                DB  %01111111
                DB  %10000000
                DB  %01111111
                DB  %10000000

*-------------------------------

BOX_CURSOR      LDY #%01111110
                LDA CURSOR
                SEC
                SBC #$05
                TAX
                AND #$0F
                CMP #$01
                BNE :1
                INY                     ; #%01111111
:1              STY BOX_MOD
                TXA
                JSR POS_TO_XY
                LDA GRID_XPNTS,X
                TAX
                DEX
                LDA AGRID_YPNTS,Y
                TAY
                DEY
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

GROUP_CURSOR2   LDY CURSOR
                LDA CURCORD,Y
                JSR POS_TO_XY
                LDA GRID_XPNTS,X
                TAX
                LDA CGRID_YPNTS,Y
                TAY
                JSR MOVE_TO
                LDX #<GROUP_SHAPE
                LDY #>GROUP_SHAPE
                JMP NEW_DRAW_SHAPE

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
