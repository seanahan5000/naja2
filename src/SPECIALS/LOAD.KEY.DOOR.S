
KEY_DOOR        LDA KEY_DOOR_BITS
                BMI :2                  ; door already open
                LDA KEY_DOOR_MOD
                CMP #modKeyDoor
                BEQ :1
                LDX #fileKeyDoor
                JSR LOAD_FILE
:1              JSR AT_KEY_DOOR
                ; TODO: look at carry status to know what happens next
:2              RTS
