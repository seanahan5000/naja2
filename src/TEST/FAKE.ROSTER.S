
                EXP OFF
                PUT /NAJA/VARS/CONSTANTS

                ORG $0000

                PUT /TEST/FAKE.STATE

                PUT /TEST/CHAR.BLADE        ; 0
                DS  128

                DS  128
                PUT /TEST/CHAR.BLASTER      ; 3

                PUT /TEST/CHAR.CYBORG       ; 4
                PUT /TEST/CHAR.ELECTRODE    ; 5

                DS  128
                DS  128

                PUT /TEST/CHAR.ETRON        ; 8
                PUT /TEST/CHAR.RELAYER      ; 9

                DS  128
                PUT /TEST/CHAR.CYBORG2      ; 11
                PUT /TEST/CHAR.ETRON2       ; 12
                DS  128
                DS  128
                PUT /TEST/CHAR.EXTRA        ; 15

                SAV FAKE.ROSTER
