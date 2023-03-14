
ADD_DOOR
CODEDOOR
CROSSWALK
DNUMBER
INFCORE
KEY_GUARD
KEY_PEDESTAL
LIBRARY
NETCODE
NO_ENCOUNTER
QUICKD
REMOVE_DOOR
ROTCUBE
SHIP_SOUND
STOREROOM
TELEPORT
TPDATAC
WEAPON_CABINET
                CLC
                RTS

FILE_TABLE      DB  fileAlienPics345, $00,$00,$C0   ; trim
                DB  fileAlienDesc345, $0C,$00,$10   ; trim

                DB  fileControl17,    $10,$00,$10   ; different disk, trim
                DB  fileControl15,    $11,$00,$10   ; different disk, trim
                DB  fileControl13,    $10,$00,$10   ; trim
                DB  fileControl11,    $11,$00,$10   ; trim
                DB  fileControl9,     $12,$00,$10   ; trim

                DB  fileDiagnose,     $14,$00,$0E
                DB  fileAlienId,      $15,$00,$06
                DB  fileElevator,     $15,$08,$08
