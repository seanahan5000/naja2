
ZBLOCK_A        =   $C0                 ; ($28) Narrate, Command
ZBLOCK_B        =   $C8                 ; ($30) Narrate, Command
ZBLOCK_C        =   $78                 ; ($38) Narrate, Command
ZBLOCK_D        =   $D0                 ; ($40) Fight common
ZBLOCK_E        =   $D8                 ; ($48) All fight
ZBLOCK_F        =   $60                 ; ($80) Narrate

; MONS_PTR points to individual monster instance
; ALIEN_PTR points to alien class information

CHAR_NUMBER     =   ZBLOCK_D+0          ; TODO: phase out and use CHAR_INDEX
MONSTER_INDEX   =   ZBLOCK_D+1
ALIEN_PTR       =   ZBLOCK_D+2          ;+3
ALIEN_PTR_H     =   ZBLOCK_D+3
MONS_PTR        =   ZBLOCK_D+4          ;+5
MONS_PTR_H      =   ZBLOCK_D+5
ALIEN_INDEX     =   ZBLOCK_D+6          ; TODO: phase in
; ZCOUNT          =   ZBLOCK_D+7          ; TODO: get rid of
MONSTER_COUNT   =   ZBLOCK_D+7


; XCOUNT          =   ZBLOCK_E+0        ;not needed between fight modes
; YCOUNT          =   ZBLOCK_E+1        ;not needed between fight modes
GROUP_STATUS    =   ZBLOCK_E+2
SURPRISED_FLAG  =   ZBLOCK_E+3      ;mc000000
*
*
ROUND           =   ZBLOCK_E+6
; MONS_TOTAL      =   ZBLOCK_E+7      ;Was MNUMBER

DIRHOLD         =   $80
ALIEN1          =   $81
ALIEN2          =   $82
ALIEN3          =   $83
HMANY1          =   $84
HMANY2          =   $85
HMANY3          =   $86
ALTYPE1         =   $87
ALTYPE2         =   $88
ALTYPE3         =   $89
ALIENID         =   $8A
ATALLY          =   $8B
ENERGY_INDEX    =   $8C
ATOTAL1         =   $8D
ATOTAL2         =   $8E
ATOTAL3         =   $8F

*---------------------------------
* GROUP_STATUS
*   AB......
*
* A = Run away group
* B = All dead, broken, abandoned
*---------------------------------
