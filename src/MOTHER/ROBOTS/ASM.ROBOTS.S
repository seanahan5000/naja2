                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /NDOS/EXT
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /CAMP/EXT
                PUT /MOTHER/EXT

                DSK ROBOT.REPAIR

                ORG $8000
                PUT LOAD
                DS  \,$EE
                ERR *-$8A00

                ORG $8000
                PUT CONTROL
                PUT REPLACE
                PUT COMPLETE.BUY
                PUT COMPLETE.SELL
                PUT SUBROUTINES
                PUT SAVE.ROBOT
                DS  \,$EE
                ERR *-$A800             ;***

                ;*** MOVE TO SCRATCH_PAGE? ***
                DUMMY   *
LOADBUF         DS  256             ;Must be on page boundary
ROBOTBUF        DS  128             ;Must be on page boundary
                PUT TABLES
                DEND
