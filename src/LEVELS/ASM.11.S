
BIG_MAP         =   0
SHELLNUM        =   4

                PUT COMMON
                PUT CONTROL11
                PUT LEVEL11

                PUT /SPECIALS/LOAD.ELEVATOR
                PUT /SPECIALS/GREEN.NET
                SAV CONTROL11

                ORG $A000
ELEVATOR_FILE   DB  fileElevator
                PUT /SPECIALS/ELEVATOR
                SAV ELEVATOR
