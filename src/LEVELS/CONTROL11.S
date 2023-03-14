
DOOR_SIGN
EMPTY_CELL
KEY_GUARD
KEY_PEDESTAL
NO_ENCOUNTER
PRESSURE_SUIT
PRISONER
SHIP_SOUND
SPECDOOR
DECONTAM
ESTATION
IVISDOOR
NOISYDOR
SCANGENT
                CLC
                RTS

FILE_TABLE      DB  fileAlienPics345, $00,$00,$C0   ; trim
                DB  fileAlienDesc345, $0C,$00,$10   ; trim

                DB  fileControl13,    $10,$00,$10   ; trim
                DB  fileControl11,    $11,$08,$10   ; trim
                DB  fileControl9,     $12,$00,$10   ; trim

                DB  fileDiagnose,     $14,$00,$0E
                DB  fileAlienId,      $15,$00,$06
                DB  fileElevator,     $15,$08,$08
