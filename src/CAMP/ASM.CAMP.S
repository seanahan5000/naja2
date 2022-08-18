
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                ; C.REFORMAT uses $C0-$C9

                ORG $E000
                PUT T.CAMP
                PUT KEY.COMMONS
                PUT SCAN.COMMONS
                PUT CAMP.COMMONS

                PUT C.ISTATS
                PUT I.SEESTATS

                PUT /TEST/CHARACTERS
                PUT /TEST/EQUIPMENT
                PUT /TEST/STATS

; TODO: get from ENRGY.COMMONS.S
; "profession usable" table
PROUSAB         DB  $01,$02,$04
                DB  $08,$10,$FF
                DB  $40,$80,$20

; TODO: hook this in
LESS_PERCENT    RTS

; TODO: move later
CALC_ALL        JSR CALC_STATS
                JSR CALC_SHIELDIN
                JMP CALC_POWRUSE

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
                ;*** NEEDS BANK_1 CALL ***
                PUT C.TRADE
                SAV CAMP.D000.M1

                ORG $D000
                ;*** NEEDS BANK_2 CALL ***
                PUT I.MOVER
                SAV CAMP.D000.M2
