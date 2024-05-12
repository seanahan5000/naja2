                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /NDOS/EXT
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /CAMP/EXT
                PUT /MOTHER/EXT

ZBLOCK_A0       =   $A0

ENDLINE         =   $14

; LINENUM         =   $00             ;Used in CONTROL
; COUNTER         =   $03
START           =   $08
CYCLE           =   $09
CHNFLAG         =   ZBLOCK_A0+0
; MEMBNUM         =   ZBLOCK_A0+1
BCURSOR         =   ZBLOCK_A0+2
; PCURSOR         =   ZBLOCK_A0+3
BUYSELL         =   ZBLOCK_A0+4
ECURSOR         =   ZBLOCK_A0+5
; *
; *

                ORG $8000
                PUT LOAD
                DS  \,$EE
                ERR *-$9500

                ORG $8000
                PUT CONTROL
                DS  \,$EE
                ERR *-$8800

********************************
                DUMMY   SCRATCH_PAGE
********************************

ENCUR           DB  $00,$00,$00
ECSPLIT         DB  $00,$00,$00
                DB  $00,$00,$00
ENTEMP          DB  $00,$00,$00
ETSPLIT         DB  $00,$00,$00
                DB  $00,$00,$00
ENTEMP2         DB  $00,$00,$00

CRCUR           DB  $00,$00,$00,$00
CCSPLIT         DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00

CRTEMP          DB  $00,$00,$00,$00
CTSPLIT         DB  $00,$00,$00
                DB  $00,$00,$00
                DB  $00,$00

; must be contiguous
CROLD           DB  $0A,$0A,$0A,$0A
ECOLD           DB  $0A,$0A,$0A
                DB  $0A,$0A,$0A

; must be contiguous
CRNEW           DB  $0A,$0A,$0A,$0A
ECNEW           DB  $0A,$0A,$0A
                DB  $0A,$0A,$0A

NPMX            DB  $00
OPMX            DB  $00
NMPX            DB  $00
OMPX            DB  $00

********************************
                DEND
********************************

                SAV ENERGY.CENTER
