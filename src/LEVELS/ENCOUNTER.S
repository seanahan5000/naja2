
; TODO: always track previous position and direction
;   (don't update if just direction changed)

CAN_ENCOUNTER   JSR PUSH_MAP_STATE

; check for open direction, return CLC if in 1x1 area

                JSR TRY_DIRECTION
                BEQ :1
                JSR TURN_LEFT
                JSR TRY_DIRECTION
                BEQ :1
                JSR TURN_RIGHT
                JSR TURN_RIGHT
                JSR TRY_DIRECTION
                BEQ :1
                JSR TURN_RIGHT
                JSR TRY_DIRECTION
                BEQ :1
                JSR PULL_MAP_STATE
                CLC                     ; no encounter
                RTS

:1              JSR SWAP_MAP_STATE
                JSR PULL_MAP_STATE
                SEC                     ; yes, encounter
                RTS

TRY_DIRECTION   JSR GET_NSEW
                LDA BLOCK_BUFFER+0
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                RTS

;*** TODO: move this or use symbol directly
FIGHT_LOADER1   =   $8800

LOAD_FIGHT      LDA #NOT_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                LDA #fileFightLoader1
                LDY #>FIGHT_LOADER1
                JSR LOAD_FILE
                JMP FIGHT_LOADER1
