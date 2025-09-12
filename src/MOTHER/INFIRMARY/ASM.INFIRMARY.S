                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /NDOS/EXT
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /CAMP/EXT
                PUT /MOTHER/EXT

                ORG $8000
                PUT LOAD
                DS  \,$EE
                ERR *-$8800

                ORG $8000
                PUT CONTROL
                DS  \,$EE
                ; TODO: remove paddding
                DS  256,$EE
                ERR *-$8C00

                SAV INFIRMARY
