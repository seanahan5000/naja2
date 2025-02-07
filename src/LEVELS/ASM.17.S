
BIG_MAP         =   1
SHELLNUM        =   1

                PUT CONTROL
                PUT FILES1
                PUT LEVEL17

                PUT /SPECIALS/LOAD.ELEVATOR
                PUT /SPECIALS/LOAD.VIEWPORT
                PUT /SPECIALS/LOAD.RUUIK
                ; PUT /SPECIALS/FINDMENT  ; TODO: make a module?
                ; PUT /SPECIALS/ORB.GREEN
                PUT /SPECIALS/GREEN.NET
                ; PUT /SPECIALS/DOOR.SIGN

                PUT /SPECIALS/LOAD.KEY.CRYSTAL
                PUT /SPECIALS/LOAD.KEY.SAND ; *** MOVE

DOOR_SIGN
; KEY_PEDESTAL

SHIP_SOUND
ROTATE
IN_ONE_WAY
DATACARD_COMP
WEAPON_FOUND
KILROY
IS_DOOR
NOT_DOOR
KEY_GUARD
                CLC
                RTS

                SAV CONTROL17.7000

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

                ORG $A000
KEY_CRYSTAL_FILE DB  fileKeyCrystal
                PUT /SPECIALS/KEY.CRYSTAL
                SAV KEY.CRYSTAL

; *** MOVE
                ORG $A000
KEY_SAND_FILE   DB  fileKeySand
                PUT /SPECIALS/KEY.SAND
                SAV KEY.SAND
