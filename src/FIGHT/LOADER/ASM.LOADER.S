
                ; TODO: move this
                ORG $8400

                PUT LOADER/EQUATES
                PUT LOADER/A.CONTROL
                PUT LOADER/A.PICK.ALIENS
                PUT LOADER/A.PICK.NUMBER
                PUT LOADER/A.DRAW.PICTUR

                ; DS  \,$EE

                ; DUMMY   *
POSSIBLE        DS  18
                ; DEND

                PUT SUBROUTINES/FLN.POINTERS
                PUT SUBROUTINES/FLN.TOPVIEWS
                PUT SUBROUTINES/FLN.GRIDS
                PUT /CAMP/TOPVIEWS

                PUT LOADER/B.LOAD.DATA
                PUT LOADER/B.MAKE.MONS
                PUT LOADER/B.PICK.POSITN
                PUT LOADER/B.FIGHT.SCRN
                ; PUT B.SUPRISE.SUB

                DS  \,$EE

                DUMMY   *
GRID            DS  25
POSITION_LIST   DS  25
FILLED_GRID     DS  25
GROUP_BUFF0     DS  bytespergroup
GROUP_BUFF1     DS  bytespergroup
GROUP_BUFF2     DS  bytespergroup
GROUP_BUFF3     DS  bytespergroup
NEW_MONSTER     DS  bytespermons
                DEND

                SAV FIGHT.LOADER
