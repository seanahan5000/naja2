                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /NDOS/EXT
                PUT /NDOS/VARS
                PUT /HALLS/VARS
                PUT /HALLS/EXT

                DSK ROBOT.REPAIR

                ORG $8000
                PUT LOAD
                DS  \,$EE
                ERR *-$8A00

;                 ORG $6000
;                 PUT CONTROL
;                 PUT REPLACE
;                 PUT COMPLETE.BUY
;                 PUT COMPLETE.SELL
;                 PUT SUBROUTINES
;                 PUT DATA
;                 PUT LEAVE
;                 PUT SAVE.ROBOT
;                 LST ON
;                 DS  \,$EE
;                 LST OFF

;                 DUMMY   *
; LOADBUF         DS  256             ;Must be on page boundary
; ROBOTBUF        DS  128             ;Must be on page boundary
;                 PUT TABLES
;                 DEND
