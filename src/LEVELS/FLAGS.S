
gamePrisonerMet         = 0
gamePrisonerQuestGiven  = 1
gamePrisonerGone        = 2
gameKeyCrystalGone      = 3

;
; On entry:
;   A: game flag number
;
; On exit:
;   C: game flag state
;  All registers changed
;
TEST_GAME_FLAG  JSR GET_DIV_MOD_8
                LDA GAME_FLAGS,X
                AND BIT_TABLE,Y
                CMP BIT_TABLE,Y
                RTS
;
; On entry:
;   A: game flag number
;
; On exit:
;  All registers changed
;
SET_GAME_FLAG   JSR GET_DIV_MOD_8
                LDA GAME_FLAGS,X
                ORA BIT_TABLE,Y
                STA GAME_FLAGS,X
                RTS
