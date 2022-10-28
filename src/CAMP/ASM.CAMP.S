
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                PUT /NDOS/EXT

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
                PUT I.TRANSFER
                PUT I.REGENERATE    ; must be in same bank as I.TRANSFER

; TODO: move later
BANK_1          LDA $C08B
                LDA $C08B
                RTS

BANK_2          LDA $C083
                LDA $C083
                RTS

SHELL           DB  $1              ; TODO: move later
                SAV CAMP.E000

                ORG $D000           ; bank 1
                PUT C.TRADE
                PUT C.REFORMAT
                PUT TOPVIEWS
                SAV CAMP.D000.M1

                ORG $D000           ; bank 2
                PUT I.MOVE
                PUT I.USE           ; must be in same bank as I.MOVE
                PUT I.EXAMINE       ; must be in same bank as I.MOVE
                PUT I.COMPRESS
                PUT C.ISTATS.DATA
                SAV CAMP.D000.M2

                ORG $9000
                PUT /TEST/CHARACTERS
                PUT /TEST/EQUIPMENT
                PUT /TEST/STATS
                SAV CAMP.9000

                ORG $A000
DIAGNOSE_MOD    DB  modDiagnose
                PUT I.DIAGNOSE
                SAV DIAGNOSE
