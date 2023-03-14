
BIG_MAP         =   0
SHELLNUM        =   5

                PUT COMMON
                PUT CONTROL9
                PUT LEVEL9

                PUT /SPECIALS/LOAD.ELEVATOR
                PUT /SPECIALS/LOAD.KEY.DOOR
                PUT /SPECIALS/GREEN.NET
                SAV CONTROL9

                ORG $A000
ELEVATOR_FILE   DB  fileElevator
                PUT /SPECIALS/ELEVATOR
                SAV ELEVATOR

                ORG $A000
KEY_DOOR_FILE   DB  fileKeyDoor
                PUT /SPECIALS/KEY.DOOR
                SAV KEY.DOOR
