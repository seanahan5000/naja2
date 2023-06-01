susLIGHT        =   0
susHEAT         =   1
susELECTRICAL   =   2
susPHYSICAL     =   3
susDISINTEG     =   4
susGRENADE      =   5
susIMAGEN       =   6
susSIZE         =   7

** bits of monFLAGS byte
runningbit      =   %10000000
runtestedbit    =   %01000000

lastTextCol     =   29

; SCRATCH         =   $00
; COUNTER         =   $01

*** Short term variables
WIDTH           =   ZBLOCK_A+0     ;Topviews
HEIGHT          =   ZBLOCK_A+1     ;Topviews
*
*
*
*
*
*

*** Narrator term varibles
POINTER         =   ZBLOCK_B+0
THROUGH         =   ZBLOCK_B+1
*
*
*
*
*
*

ENTYPE          =   ZBLOCK_C+0          ;ONLY IN ENERGY??
*
COMPNTR         =   ZBLOCK_C+2
*
*
*
*
*

TOTAL_DAMAGEH   =   ZBLOCK_F+0
TOTAL_DAMAGEL   =   ZBLOCK_F+1
EL_DAMAGEH      =   ZBLOCK_F+2
EL_DAMAGEL      =   ZBLOCK_F+3
PH_DAMAGEH      =   ZBLOCK_F+4
PH_DAMAGEL      =   ZBLOCK_F+5
ENERGY_H        =   ZBLOCK_F+6
ENERGY_L        =   ZBLOCK_F+7
