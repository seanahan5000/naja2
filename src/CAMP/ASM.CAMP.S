
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
                PUT C.TRADE.S

; TODO: move later
CALC_ALL        RTS
                ; JSR CALC_STATS
                ; JSR CALC_SHIELDIN
                ; JMP CALC_POWRUSE

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
                PUT C.REFORMAT.S
                SAV CAMP.D000.M1

