
BIG_MAP         =   0
SHELLNUM        =   5

                PUT CONTROL
                PUT FILES2
                PUT LEVEL9

                PUT /SPECIALS/LOAD.ELEVATOR
                PUT /SPECIALS/LOAD.KEY.DOOR
                PUT /SPECIALS/GREEN.NET

KEY_PEDESTAL
KEY_GUARD
NAJA_DOOR
SHIP_SOUND
GRAFFITI
ROTROOM
NET
QUICKD
ESTATION
VDOORS
HDOORS
CDFOUND
INFROOM
AUTOEN
NOENCNT
NOTDOOR
                CLC
                RTS

                SAV CONTROL9.7000

                ORG $A000
ELEVATOR_FILE   DB  fileElevator
                PUT /SPECIALS/ELEVATOR
                SAV ELEVATOR

                ORG $A000
KEY_DOOR_FILE   DB  fileKeyDoor
                PUT /SPECIALS/KEY.DOOR
                SAV KEY.DOOR
