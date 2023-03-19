
                EXP OFF

TEMP            =   $00

; TODO: fix these
ZBLOCK_28       =   $78 ;$28             ;Narrate, Command, Loader

ZBLOCK_30       =   $80 ;$30             ;Narrate, Command, Loader
ZBLOCK_38       =   $88 ;$38             ;Narrate, Command, Loader

ZBLOCK_40       =   $90 ;$40             ;Fight common
ZBLOCK_48       =   $98 ;$48             ;All fight

                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                PUT /NDOS/VARS
                PUT /NDOS/EXT

                PUT /NAJA/VARS/CONSTANTS

                PUT /FIGHT/FIGHT.CONSTS
                PUT /FIGHT/FIGHT.ZPAGE

                ; TODO: move this
                ORG $8800

                PUT EQUATES
                PUT A.CONTROL
                PUT A.PICK.ALIENS
                PUT A.PICK.NUMBER
                PUT A.DRAW.PICTUR

                DS  \,$EE

                DUMMY   *
POSSIBLE        DS  18
                DEND

;                 ORG $6000
;                 PUT /FIGHT/SUBROUTINES/FLN.POINTERS
;                 PUT /FIGHT/SUBROUTINES/FLN.TOPVIEWS
;                 PUT /FIGHT/SUBROUTINES/FLN.GRIDS
;                 PUT /FIGHT/SUBROUTINES/FLN.LISTS

;                 DS  \,$EE
;                 ERR *-$6300

;                 PUT B.LOAD.DATA
;                 PUT B.MAKE.MONS
;                 PUT B.PICK.POSITN
;                 PUT B.FIGHT.SCRN
;                 PUT B.SUPRISE.SUB

;                 DS  \,$EE

;                 DUMMY   *
; GRID            DS  25
; POSITION_LIST   DS  25
; FILLED_GRID     DS  25
; GROUP_BUFF0     DS  bytespergroup
; GROUP_BUFF1     DS  bytespergroup
; GROUP_BUFF2     DS  bytespergroup
; GROUP_BUFF3     DS  bytespergroup
; NEW_MONSTER     DS  bytespermons
;                 DEND

                SAV FIGHT.LOADER
