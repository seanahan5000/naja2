
; files for disk 2

FILE_TABLE      DB  fileAlienPics345, $00,$00,$C0   ; trim
                DB  fileAlienDesc345, $0C,$00,$10   ; trim

                DB  fileControl17,    $10,$00,$10   ; (disk 1), trim
                DB  fileControl15,    $11,$00,$10   ; (disk 1), trim
                DB  fileControl13,    $10,$00,$10   ; trim
                DB  fileControl11,    $11,$00,$10   ; trim
                DB  fileControl9,     $12,$00,$10   ; trim

                DB  fileDiagnose,     $14,$00,$0E
                DB  fileAlienId,      $15,$00,$06
                DB  fileElevator,     $15,$08,$08

                ; shell 9
                DB  fileKeyDoor,      $16,$00,$0D   ; trim
