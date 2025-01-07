
BIG_MAP         =   0
SHELLNUM        =   4

                PUT CONTROL
                PUT FILES2
                PUT LEVEL11

                PUT /SPECIALS/LOAD.ELEVATOR
                PUT /SPECIALS/GREEN.NET
                PUT /SPECIALS/LOAD.PRISONER

KEY_GUARD
KEY_PEDESTAL
NO_ENCOUNTER
PRESSURE_SUIT
SHIP_SOUND
SPECDOOR
DECONTAM
ESTATION
IVISDOOR
NOISYDOR
SCANGENT
                CLC
                RTS

                SAV CONTROL11.7000

                ORG $A000
ELEVATOR_FILE   DB  fileElevator
                PUT /SPECIALS/ELEVATOR
                SAV ELEVATOR

                ORG $A000
PRISON_FILE     DB  filePrisoner
                PUT /SPECIALS/PRISONER
                SAV PRISONER
