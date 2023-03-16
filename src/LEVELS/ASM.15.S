
BIG_MAP         =   0
SHELLNUM        =   2

                PUT CONTROL
                PUT FILES1
                PUT LEVEL15

                PUT /SPECIALS/LOAD.ELEVATOR
                PUT /SPECIALS/GREEN.NET
                SAV CONTROL15

                ORG $A000
ELEVATOR_FILE   DB  fileElevator
                PUT /SPECIALS/ELEVATOR
                SAV ELEVATOR
