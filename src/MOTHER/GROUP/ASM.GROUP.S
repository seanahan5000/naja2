                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /NDOS/EXT
                PUT /NDOS/VARS
                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /CAMP/EXT
                PUT /MOTHER/EXT

                ORG $8000
                PUT LOAD
                DS  \,$EE
                ERR *-$8600

                ORG $8000
                PUT CONTROL
                PUT ROSTER
                DS  \,$EE
                ERR *-$8A00

                SAV GROUP.ASSEMBLY
