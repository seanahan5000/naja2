CHAR_NUMBER     =   ZBLOCK_40+0
MONS_NUMBER     =   ZBLOCK_40+1
ALIEN_PTR       =   ZBLOCK_40+2     ;+3
MONS_PTR        =   ZBLOCK_40+4     ;+5
ZCOUNT          =   ZBLOCK_40+7

; XCOUNT          =   ZBLOCK_48+0     ;not needed between fight modes
; YCOUNT          =   ZBLOCK_48+1     ;not needed between fight modes
GROUP_STATUS    =   ZBLOCK_48+2
SURPRISED_FLAG  =   ZBLOCK_48+3     ;mc000000
*
*
ROUND           =   ZBLOCK_48+6
MONS_TOTAL      =   ZBLOCK_48+7     ;Was MNUMBER

; TODO: used to be $60 -- fix these
DIRHOLD         =   $C0
ALIEN1          =   $C1
ALIEN2          =   $C2
ALIEN3          =   $C3
HMANY1          =   $C4
HMANY2          =   $C5
HMANY3          =   $C6
ALTYPE1         =   $C7
ALTYPE2         =   $C8
ALTYPE3         =   $C9
ALIENID         =   $CA
ATALLY          =   $CB
ENERGY_INDEX    =   $CC
ATOTAL1         =   $CD
ATOTAL2         =   $CE
ATOTAL3         =   $CF

*---------------------------------
* GROUP_STATUS
*   AB......
*
* A = Run away group
* B = All dead, broken, abandoned
*---------------------------------
