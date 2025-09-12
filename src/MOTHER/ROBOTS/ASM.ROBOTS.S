                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /NDOS/EXT
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /CAMP/EXT
                PUT /MOTHER/VARS
                PUT /MOTHER/EXT

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
                DS  256,$EE
                ERR *-$A800

                SAV ROBOT.REPAIR

                DUM SCRATCH_PAGE
ROBOTBUF        DS  128                 ; must be on page boundary
                PUT TABLES
                DEND
