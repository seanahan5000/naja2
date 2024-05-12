
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

                ORG $A000
REFORMAT_FILE   DB  fileReformat
                PUT C.REFORMAT
                PUT /FIGHT/SHARED/TOPVIEWS
                SAV REFORMAT
