TABLE2          DB  $FF,$FF,$FF
                DB  $FF
TABLE4          DB  $FF,$FF,$FF
                DB  $FF
LINTABL         DB  $FF,$FF,$FF         ; y positions for equipment in list
                DB  $FF,$FF,$FF
                DB  $FF,$FF,$FF
                DB  $FF,$FF,$FF
                DB  $FF,$FF,$FF
                DB  $FF,$FF,$FF
CURTABL         DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00
VISIBLE         DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00
MINTABL         DB  $00,$00,$00
FORMED          DB  $00,$00,$00
                DB  $00

; NOTE: unpacked sizes
USTOCK_BUFFER
PISTOL_STOCK    DS  6
RIFLE_STOCK     DS  4
CANNON_STOCK    DS  2
BEAM_STOCK      DS  8
MWEAPON_STOCK   DS  6
ATTACH_STOCK    DS  6
MARMOR_STOCK    DS  4
MEDIC_STOCK     DS  14
SCANNER_STOCK   DS  6
MISC_STOCK      DS  4
SHIELD_STOCK    DS  12

REMAINS         DS  4
OPEN_SLOT       DS  1               ;Destination of bought equipment
