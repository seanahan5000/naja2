
                EXP OFF

                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                PUT /CAMP/EXT

                PUT /NAJA/VARS/CONSTANTS

                PUT /FIGHT/FIGHT.CONSTS
                PUT /FIGHT/FIGHT.ZPAGE

                ORG $A000
F_SHARED_FILE   DB  $00               ; no real file number

                PUT SHARED
                PUT FLN.POINTERS
                PUT FLN.TOPVIEWS
                PUT TOPVIEWS
                PUT MNAMES

GRID_HALLS      DS  6                   ; TODO: consider ZPAGE for this

                PUT BUILD.GRID          ; TODO: move to loader?
                PUT DRAW.GRID

                SAV FIGHT.SHARED
