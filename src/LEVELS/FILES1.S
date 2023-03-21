
; files for disk 1

; TODO: most of these need length trimming

FILE_TABLE      DB  fileAlienPics12,  $00,$00,$B0
                DB  fileAlienDesc12,  $0C,$00,$10
                DB  fileAlienData12,  $0D,$00,$30

                DB  fileControl17,    $10,$00,$10
                DB  fileControl15,    $11,$00,$10
                DB  fileControl13,    $10,$00,$10   ; (disk 2)

                DB  fileFightLoader,  $13,$00,$0C

                DB  fileDiagnose,     $14,$00,$0E
                DB  fileAlienId,      $15,$00,$06
                DB  fileElevator,     $15,$08,$08

                ; shell 17
                DB  fileViewport,     $16,$00,$09
                DB  fileRuuik,        $17,$00,$0D
