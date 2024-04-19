
                EXP OFF
                PUT /NAJA/VARS/CONSTANTS

                ORG $BA00
                PUT /TEST/FAKE.STATE
                ERR $BD00-*

                PUT /TEST/CHAR.BLASTER
                PUT /TEST/CHAR.ETRON
                ; PUT /TEST/CHAR.ETRON2
                PUT /TEST/CHAR.ELECTRODE
                PUT /TEST/CHAR.RELAYER
                PUT /TEST/CHAR.CYBORG
                ; PUT /TEST/CHAR.CYBORG2
                PUT /TEST/CHAR.BLADE
                ERR $C000-*

                SAV FAKE.GAME.BA00
