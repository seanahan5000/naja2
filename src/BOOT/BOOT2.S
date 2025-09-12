
                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /MOTHER/EXT

CONTROL_MODULE  =   $7000
SET_CONTROL     =   $7001

FINISH_BOOT     LDX #<BOOT2_TABLE
                LDY #>BOOT2_TABLE
                JSR SET_FILE_TABLE

; TODO: Consider moving camp loading to here in order
;   to give more immediate feedback to player on boot.
;   (would require disk layout change)

                LDA #fileHalls
                LDY #$60
                JSR LOAD_FILE

                ; NOTE: This must be located at $8000 or greater,
                ;   else file load will overwrite it.
                LDA #fileControlMS
                LDY #>CONTROL_MODULE
                JSR LOAD_FILE

; set up character data, equipment, specials, possibly fake/restore

INIT_GAME
                ; *** what are these? ***
                ; LDA #$C7        ;;;???
                ; STA $03F2
                ; LDA #$03
                ; STA $03F3
                ; LDA #$A6
                ; STA $03F4       ;;;???

                LDA #0
                STA SHELL
                LDA #6
                STA RANGE
                JSR SET_CONTROL

                LDA #fileSaveGame
                JSR SET_FILE
; TODO: should this just load GAME_STATE_MS?
                LDA #stateSectors
                LDY #>GAME_STATE
                JSR READ_FILE

                LDA #0
                STA GRPNUMB
                STA GRPCONT

                LDY #3                  ; enrollment
                JSR SET_TRANS_DEST
                JSR TRANS_NOISE
                JMP HALL_KEYS

BOOT2_TABLE     DB  fileHalls,      $09,$00,$10
                DB  fileControlMS,  $0A,$00,$10
