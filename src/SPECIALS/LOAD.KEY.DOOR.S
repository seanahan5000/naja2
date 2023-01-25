
KEY_DOOR        LDA MAP_DIR
                CMP #EAST
                BEQ FAKE_FC_OUT
                JSR LOAD_KEY_DOOR
                BCS :1
                JSR AT_KEY_DOOR
                SEC
                RTS
:1              CLC
                RTS
;
; face change out of core
;
FAKE_FC_OUT     JSR STEP_HALL
:1              LDA KEYBRD
                BPL :1
                JSR CHECK_TURN
                BEQ :2
                JSR CHECK_UP
                BNE :1
                BIT UNSTROB
                LDY #4
                JSR SET_FC_POS
                JSR CLEAR_PAGE
                JSR DRAW_HALL
:2              SEC
                RTS
;
; face change into key door/core
;
FAKE_FC_IN      JSR STEP_HALL
                JSR LOAD_KEY_DOOR
                PHP
:1              LDA KEYBRD
                BPL :1
                JSR CHECK_TURN
                BEQ :3
                JSR CHECK_UP
                BNE :1
                BIT UNSTROB
:2              LDY #0
                JSR SET_FC_POS
                PLP
                BCS :DOOR_OPEN
                JSR AT_KEY_DOOR
                PHP
:3              PLP
                SEC
                RTS

:DOOR_OPEN      JSR CLEAR_PAGE
                JSR DRAW_HALL
                SEC
                RTS

; TODO: should become a general hall routine
STEP_HALL       CPX #3
                BEQ :1
                JSR CLEAR_PAGE
                JMP DRAW_HALL
:1              JMP SCAN_HALL

; TODO: should probably become a general hall routine
SET_FC_POS      LDX #0
:1              LDA :FC_PNTS,Y
                STA MAP_FACE,X
                INY
                INX
                CPX #4
                BNE :1
                JSR COMPUTE_MAP_PTR
                JMP GET_NSEW

                ;   F,X,Y,DIR
:FC_PNTS        DB  6,6,4,WEST          ; into core
                DB  5,1,4,EAST          ; out of core
;
; On exit:
;   C: 0=door closed, 1=door open
;
LOAD_KEY_DOOR   SEC
                LDA KEY_DOOR_BITS
                BMI :2                  ; door already open
                LDA #fileKeyDoor
                CMP KEY_DOOR_FILE
                BEQ :1
                LDY #>KEY_DOOR_FILE
                JSR LOAD_FILE
:1              CLC
:2              RTS
