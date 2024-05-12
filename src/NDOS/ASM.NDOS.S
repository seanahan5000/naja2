
                EXP OFF

; slightly different name to avoid COMMON/VARS version
SAME_PAGE_AS_   MAC
                ERR *!]1/256
                EOM

                ORG $0400
                PUT READ
                PUT NDOS
                PUT HOOKS
                SAV NDOS.0400

; TODO: try to put this back into main NDOS block
;   (will require moving GRAPHICS and/or CAMP.1C00)
                ORG $7F00
                PUT WRITE
                SAV NDOS.7F00
