; TODO: clean up these equates

; LINENUM         =   $00
; SCRATCH         =   $01
TIMTAKE         =   $02
; COLUMN          =   $03
; COUNTER         =   $03
ENDLINE         =   $03

XSPOT           =   $11
TCURSOR         =   $17
ORIGRED         =   $1F

VALPTR          =   $20             ;$21
OLDPTR          =   VALPTR+2        ;+3
NEWPTR          =   VALPTR+4        ;+5

PLANNER         =   ZBLOCK_A+0
POINTR2         =   ZBLOCK_A+1
SUSABLE         =   ZBLOCK_A+2
MINOPT          =   ZBLOCK_A+3
MAXOPT          =   ZBLOCK_A+4
OPTSPOT         =   ZBLOCK_A+5
CURTIME         =   ZBLOCK_A+6
TIMLEFT         =   ZBLOCK_A+7

MAXCURS         =   ZBLOCK_B+0
CFLAG           =   ZBLOCK_B+1
MARGIN          =   ZBLOCK_B+2
MARGIN2         =   ZBLOCK_B+3
COMPNTR         =   ZBLOCK_B+4
COMCNT          =   ZBLOCK_B+5
USEDLOC         =   ZBLOCK_B+6
CURHOLD         =   ZBLOCK_B+7

SWTYPE          =   ZBLOCK_C+0
;PASTMOV        =   ZBLOCK_C+1
;LINECNT         =   ZBLOCK_C+2
;SCRACH2         =   ZBLOCK_C+3
*
*
INSTR1          =   ZBLOCK_C+6
INSTR2          =   ZBLOCK_C+7

********************************
                DUMMY   $9F00
********************************
TIMES           DS  7
OPT_LEGALS      DS  21
ADR_TABLE       DS  24              ;Used by TEXT_UPDATE
CHENTAB         DS  48
CTIMTAB         DS  16
ENERGY_DEF      DS  17
ENERGY_VALUE    =   ENERGY_DEF+2
PER_DEF         DS  17
PER_VALUE       =   PER_DEF+2
TOTAL_DEF       DS  17
TOTAL_VALUE     =   TOTAL_DEF+2
********************************
                DEND
********************************
