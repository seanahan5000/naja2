                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /NDOS/EXT
                PUT /NDOS/VARS
                PUT /HALLS/VARS
                PUT /HALLS/EXT

                ORG $8000
                PUT LOAD
                PUT SCROLLA
                DS  \,$EE
                ERR *-$8E00

                ; ORG $7000
                ; PUT CONTROL
                ; PUT PART2
                ; PUT BUY.EQUIPMNT
                ; PUT BUY.ARMHELM
                ; PUT DRAW.EQUIPMNT
                ; PUT DRAW.ARMHELM
                ; PUT STATUS.BOX
                ; PUT SELL.ID.REP
                ; PUT SELL.ITEM
                ; PUT CALC.VALUE
                ; PUT DATA
                ; PUT PICTURES
                ; PUT WEAPONS
                ; PUT EXIT            ;Must be at $8000 or greater
                ; LST ON
                ; DS  \,$EE
                ; LST OFF

                ; DUMMY   *
                ; PUT TABLES
                ; DEND

                SAV ARSENAL
