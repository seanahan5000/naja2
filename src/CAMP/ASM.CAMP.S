
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                ; C.REFORMAT uses $C0-$C9

                ORG $E000
                PUT T.CAMP
                PUT MISC.COMMONS
                PUT KEY.COMMONS
                PUT SCAN.COMMONS
                PUT DRAIN.INFLICT
                PUT ENRGY.COMMONS
                PUT ENUSE.TABLES
                PUT CAMP.COMMONS

                PUT C.ISTATS
                PUT I.SEESTATS
                PUT I.TRANSFER      ;***
                PUT I.REGENERATE    ;***

; TODO: move later
; NOTE: these are swapped from original Naja code
BANK_1          LDA $C083
                LDA $C083
                RTS

BANK_2          LDA $C08B
                LDA $C08B
                RTS

SHELL           DB  $1              ; TODO: move later
                SAV CAMP.E000

                ORG $D000
                PUT /TEST/TOPVIEWS
                PUT C.REFORMAT
                PUT C.TRADE
                SAV CAMP.D000.M1

                ORG $D000
                PUT I.MOVE
                PUT I.USE           ; must be in same back as I.MOVER
                PUT I.EXAMINE       ; must be in same back as I.MOVER
                PUT I.COMPRESS      ;***
                SAV CAMP.D000.M2

                ORG $9000
                PUT /TEST/CHARACTERS
                PUT /TEST/EQUIPMENT
                PUT /TEST/STATS
                PUT I.DIAGNOSE
                SAV CAMP.9000
