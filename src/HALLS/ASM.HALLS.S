
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                ORG $6000
                PUT HALLS.EQU
                PUT VARS
;               PUT HALLS.DOC
                PUT HALLS
                PUT HALLS.DRAW
                PUT HALLS.DATA
                PUT LINES
                PUT XLINES
                SAV HALLS.6000

; TODO: use constant
                ORG $8000
; TODO: add module header byte
                PUT MAP
                SAV MAP.8000
