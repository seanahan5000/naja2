
; files for disk side 1

; TODO: most of these need length trimming

FILE_TABLE      DB  fileAlienPics12,  $00,$00,$B0
                DB  fileAlienDesc12,  $0C,$00,$10
                DB  fileAlienData12,  $0D,$00,$30

                DB  fileControl17,    $10,$00,$10
                DB  fileControl15,    $11,$00,$10
                DB  fileControl13,    $10,$00,$10   ; (disk side 2)

                DB  fileFightLoader1, $13,$00,$05

                ; TODO: move to FILES3?
                DB  fileReformat,     $20,$00,$07   ; (disk side 3)

                DB  fileDiagnose,     $14,$00,$0E
                DB  fileAlienId,      $15,$00,$06
                DB  fileElevator,     $15,$08,$08

                ; shell 17
                DB  fileViewport,     $16,$00,$09
                DB  fileRuuik,        $17,$00,$0D
