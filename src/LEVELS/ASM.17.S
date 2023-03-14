
BIG_MAP         =   1
SHELLNUM        =   1

                PUT COMMON
                PUT CONTROL17
                PUT LEVEL17

                PUT /SPECIALS/LOAD.ELEVATOR
                PUT /SPECIALS/LOAD.VIEWPORT
                PUT /SPECIALS/LOAD.RUUIK
                ; PUT /SPECIALS/FINDMENT  ; TODO: make a module?
                ; PUT /SPECIALS/ORB.GREEN
                PUT /SPECIALS/GREEN.NET
                ; PUT /SPECIALS/DOOR.SIGN
                SAV CONTROL17

                ORG $A000
ELEVATOR_FILE   DB  fileElevator
                PUT /SPECIALS/ELEVATOR
                SAV ELEVATOR

                ORG $A000
VIEWPORT_FILE   DB  fileViewport
                PUT /SPECIALS/VIEWPORT
                SAV VIEWPORT

; TODO: add marker to preload Ruuik module before turning to face him
                ORG $A000
RUUIK_FILE      DB  fileRuuik
                PUT /SPECIALS/RUUIK
                SAV RUUIK
