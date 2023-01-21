
KEY_DOOR        LDA MAP_DIR
                CMP #EAST
                BEQ FAKE_FC_OUT
                JSR LOAD_KEY_DOOR
                BCC :1
                JSR AT_KEY_DOOR
                ; TODO: look at carry status to know what happens next
:1              RTS
;
; face change out of core
;
FAKE_FC_OUT
                ;draw current hall
                ;wait for step forward or turn away

                LDY #4
                JSR SET_FC_POS
                ;draw hall
                RTS
;
; face change into key door/core
;
FAKE_FC_IN
                ;draw current hall
                JSR LOAD_KEY_DOOR
                PHP

                ;wait for step forward or turn away

                LDY #0
                JSR SET_FC_POS
                PLP
                BCC :1
                ;do key door
:1              RTS

SET_FC_POS      LDX #0
                LDA :FC_PNTS,Y
                STA MAP_FACE,X
                INY
                INX
                CPX #4
                BNE :1
                JMP COMPUTE_MAP_PTR

                ;   F,X,Y,DIR
:FC_PNTS        DB  6,7,4,WEST          ; into core
                DB  5,1,4,EAST          ; out of core

LOAD_KEY_DOOR   CLC
                LDA KEY_DOOR_BITS
                BMI :2                  ; door already open
                LDA #fileKeyDoor
                CMP KEY_DOOR_FILE
                BEQ :1
                LDY #>KEY_DOOR_FILE
                JSR LOAD_FILE
:1              SEC
:2              RTS
