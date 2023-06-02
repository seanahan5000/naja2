
; files for disk side 3 (fight files)

; TODO: most of these need length trimming

FILE_TABLE_3    ENT

                DB  fileControl17,    $10,$00,$10   ; (disk side 1)
                DB  fileControl15,    $11,$00,$10   ; (disk side 1)
                DB  fileControl13,    $10,$00,$10   ; (disk side 2)
                DB  fileControl11,    $11,$00,$10   ; (disk side 2)
                DB  fileControl9,     $12,$00,$10   ; (disk side 2)

                DB  fileFightLoader2, $0E,$00,$06
                DB  fileFightShared,  $0F,$00,$10
                DB  fileFightCommand, $10,$00,$30
                DB  fileFightNarrator,$14,$00,$40
                DB  fileFightHalls,   $1B,$00,$15
                DB  fileFightAwarder, $1D,$00,$10
                DB  fileDeadGroup,    $1E,$00,$0D
