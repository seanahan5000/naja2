
                EXP OFF

TEMP            =   $00                 ; ,$01

POINTL          =   $12
POINTH          =   $13

; TODO: fix these
ZBLOCK_28       =   $78 ;$28             ;Narrate, Command, Loader

ZBLOCK_30       =   $80 ;$30             ;Narrate, Command, Loader
ZBLOCK_38       =   $88 ;$38             ;Narrate, Command, Loader

ZBLOCK_40       =   $A0 ;$40             ;Fight common
ZBLOCK_48       =   $A8 ;$48             ;All fight

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

                PUT LOADER/ASM.LOADER
                PUT AWARDER/ASM.AWARDER

                ORG $A000
DEAD_GROUP_FILE DB  $00                 ; TODO: just so module ID is overwritten
                PUT DEAD/DEAD.GROUP
                SAV DEAD.GROUP
