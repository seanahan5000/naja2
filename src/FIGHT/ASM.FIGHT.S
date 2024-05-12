
                EXP OFF

                PUT /NDOS/EXT
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /CAMP/EXT

                PUT /NAJA/VARS/CONSTANTS

                PUT /FIGHT/FIGHT.CONSTS
                PUT /FIGHT/FIGHT.ZPAGE

                PUT SHARED/EXT

                PUT AWARDER/ASM.AWARDER

                ORG $A000
DEAD_GROUP_FILE DB  $00                 ; no real file number
                PUT DEAD/DEAD.GROUP
                SAV DEAD.GROUP
