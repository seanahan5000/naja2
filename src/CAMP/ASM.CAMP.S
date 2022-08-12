
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                ; C.REFORMAT.S uses $C0-$C9

                ORG $E000
                PUT T.CAMP.S
                PUT KEY.COMMONS.S
                PUT SCAN.COMMONS.S

                PUT C.ISTATS.S
                PUT I.SEESTATS.S

                PUT /TEST/CHARACTERS
                PUT /TEST/EQUIPMENT
                PUT /TEST/STATS

SHELL           DB  $1              ; TODO: move later
                SAV CAMP.E000

                ORG $8000
                PUT C.REFORMAT.S
                PUT /TEST/TOPVIEWS
                SAV CAMP.8000
