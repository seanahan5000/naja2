
; files for disk side 2

; TODO: most of these need length trimming

FILE_TABLE      DB  fileAlienPics345, $00,$00,$C0
                DB  fileAlienDesc345, $0C,$00,$10
                DB  fileAlienData345, $0D,$00,$30

                DB  fileControl17,    $10,$00,$10   ; (disk side 1)
                DB  fileControl15,    $11,$00,$10   ; (disk side 1)
                DB  fileControl13,    $10,$00,$10
                DB  fileControl11,    $11,$00,$10
                DB  fileControl9,     $12,$00,$10

                DB  fileFightLoader1, $13,$00,$05
                DB  fileDiagnose,     $14,$00,$0E
                DB  fileAlienId,      $15,$00,$06
                DB  fileElevator,     $15,$08,$08

                ; shell 9
                DB  fileKeyDoor,      $16,$00,$0D

                DB  fileReformat,     $20,$00,$07   ; (disk side 3)
