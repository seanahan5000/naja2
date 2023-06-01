                EXP OFF

                PUT /NAJA/VARS/CONSTANTS

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

                PUT /LEVELS/FILES3

GET_KEY_STRING  ENT
                TAX
                JSR BANK_1
                TXA
                JSR _GET_KEY_STRING
                JMP BANK_2

EQUIP_IND_TO_TEXT ENT
                TAX
                JSR BANK_1
                TXA
                JSR _EQUIP_IND_TO_TEXT
                JMP BANK_2

CEQUIP_TO_TEXT  ENT
                JSR BANK_1
                JSR _CEQUIP_TO_TEXT
                JMP BANK_2

ETABLE_TO_TEXT  ENT
                JSR BANK_1
                JSR _ETABLE_TO_TEXT
                JMP BANK_2

ETABLE_TO_TEXT_X ENT
                JSR BANK_1
                JSR _ETABLE_TO_TEXT_X
                JMP BANK_2

STATUS_TO_TEXT_C ENT
                TAX
                JSR BANK_1
                TXA
                JSR _STATUS_TO_TEXT_C
                JMP BANK_2

; TODO: move later
BANK_1          LDA $C08B
                LDA $C08B
                RTS

BANK_2          LDA $C083
                LDA $C083
                RTS

                SAV CAMP.E000

                ORG $D000           ; bank 1
                PUT C.TRADE         ; calls EQUIPMENT directly
                PUT EQUIPMENT
                PUT STATS2
                SAV CAMP.D000.M1

                ORG $D000           ; bank 2
                PUT I.MOVE
                PUT I.USE           ; must be in same bank as I.MOVE
                PUT I.EXAMINE       ; must be in same bank as I.MOVE
                PUT I.COMPRESS
                PUT C.ISTATS.DATA
                SAV CAMP.D000.M2

                ORG $1A00
                PUT CHARACTERS
                PUT STATS
                DS  \,$EE
                ERR $1E00-*
                SAV CAMP.1A00

                ORG $A000
REFORMAT_FILE   DB  fileReformat
REFORMAT        ;*** TEMP
;                 PUT C.REFORMAT
;                 PUT /FIGHT/SHARED/TOPVIEWS
;                 DS  \,$EE
;                 ERR $A700-*
                SAV REFORMAT

                ORG $A000
DIAGNOSE_FILE   DB  fileDiagnose
                PUT I.DIAGNOSE
                SAV DIAGNOSE

                ORG $A000
ALIEN_ID_FILE   DB  fileAlienId
                PUT C.ALIEN.ID
                SAV ALIEN.ID
