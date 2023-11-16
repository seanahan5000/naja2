                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /NDOS/EXT
                PUT /NDOS/VARS
                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /CAMP/EXT

                ORG $8000
                PUT LOAD
                DS  \,$EE
                ERR *-$8C00

                ORG $8000
                PUT CONTROL
                DS  \,$EE
                ERR *-$8400

;                 ERR *-$8500
;                 PUT ENROLL/ENROLLMENT
;                 PUT ENROLL/DEFINE.CHAR
;                 PUT ENROLL/SAVE.CHAR
;                 PUT ENROLL/TEXT
;                 PUT ENROLL/DATA
;                 DS  \,$EE
;                 ERR *-$9F00

;                 ORG $8500
;                 PUT TEST/TESTING
;                 PUT TEST/UP.DAMAGE
;                 PUT TEST/PASS.FAIL
;                 PUT TEST/DATA
;                 DS  \,$EE

;                 DUMMY   *
; CONTAB          DS  51
;                 DEND

                SAV ENROLL.TEST
