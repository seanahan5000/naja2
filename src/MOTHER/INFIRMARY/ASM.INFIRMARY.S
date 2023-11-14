                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /NDOS/EXT
                PUT /NDOS/VARS

; LINENUM         =   ZBLOCK_A0+0
; SCOLUMN         =   ZBLOCK_A0+1
; DCOLUMN         =   ZBLOCK_A0+2
; RECEIVER        =   ZBLOCK_A0+3
; PAYER           =   ZBLOCK_A0+4
; TREATYPE        =   ZBLOCK_A0+5
; FLAG            =   ZBLOCK_A0+6
; SCRATCH         =   ZBLOCK_A0+7

                ORG $8000
                PUT LOAD
                DS  \,$EE
                ERR *-$8800

;                 ORG $8000
;                 PUT CONTROL
;                 PUT TEXT
;                 PUT DATA
;                 DS  \,$EE
;                 ERR *-$8F00
; ********************************
;                 DUMMY   *
; ********************************
; THE_PRICE       DS  4
; PRICE_TABLE     DS  28
; ********************************
;                 DEND
; ********************************
                SAV INFIRMARY
