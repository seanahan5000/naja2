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
                PUT SCROLLA
                DS  \,$EE
                ERR *-$8E00
                DS  256
                DS  256

                ORG $8000
                PUT CONTROL
                PUT PART2
                PUT BUY.EQUIPMNT
                PUT BUY.ARMHELM
                PUT DRAW.EQUIPMNT
                PUT DRAW.ARMHELM
                PUT STATUS.BOX
                PUT SELL.ID.REP
                PUT SELL.ITEM
                PUT CALC.VALUE
                PUT WEAPONS
                DS  \,$EE
                ERR *-$9F00

                DUMMY SCRATCH_PAGE
                PUT TABLES
                DEND

                SAV ARSENAL
