
BIG_MAP         =   0
SHELLNUM        =   3

                PUT COMMON
                PUT CONTROL13
                PUT LEVEL13

                PUT /SPECIALS/LOAD.ELEVATOR
                PUT /SPECIALS/GREEN.NET
                SAV CONTROL13

                ORG $A000
ELEVATOR_FILE   DB  fileElevator
                PUT /SPECIALS/ELEVATOR
                SAV ELEVATOR
