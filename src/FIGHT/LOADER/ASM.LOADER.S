
                EXP OFF

                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                PUT /NDOS/VARS
                PUT /NDOS/EXT

                PUT /CAMP/EXT

                PUT /NAJA/VARS/CONSTANTS

                PUT /FIGHT/FIGHT.CONSTS
                PUT /FIGHT/FIGHT.ZPAGE

                PUT /FIGHT/SHARED/EXT

; ALIEN_INDEX     =   $C0
SRC_PTR         =   $C1
SRC_PTR_H       =   $C2
HEAP_PTR        =   $C3
HEAP_PTR_H      =   $C4
GBUFF_PTR       =   $C5
GBUFF_PTR_H     =   $C6
TILE_COUNT      =   $C7

RAREPNT         =   $C8
RARECNT         =   $C9
POSCNT          =   $CA

FIRST_ONE       =   $CB
LAST_ONE        =   $CC
RND_HOLD        =   $CD

START_INDEX     =   $CE
VALID_COUNT     =   $CF
SAVE_INDEX      =   TILE_COUNT

MASK_BITS       =   TEMP                ;***


alienClassSize  =   bytesperalien
animated        =   $E0             ;Also in /ALIENS/EQUATES/ALIEN.EQ

                ORG $8800
                PUT LOADER1
                PUT /FIGHT/SHARED/INIT.GRID
                SAV FIGHT.LOADER1

                DUMMY *
POSSIBLE        DS  18
                DEND

                ORG $6000
                PUT LOADER2
                PUT MAKE.ALIENS
                PUT PICK.POSITIONS
                ; PUT B.SUPRISE.SUB
                SAV FIGHT.LOADER2

                DUMMY $9800             ;***
GRID            DS  25
VALID_LIST      DS  25
POSITION_LIST   DS  25
GROUP_BUFF1     DS  bytespergroup
GROUP_BUFF2     DS  bytespergroup
GROUP_BUFF3     DS  bytespergroup
NEW_MONSTER     DS  bytespermons
                DEND
