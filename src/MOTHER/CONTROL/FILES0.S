
; files for disk side 0 (mothership)

FILE_TABLE      DB  fileDeleteChar,        $0E,$00,$09
                DB  fileGuard,             $0E,$0B,$05
                DB  fileInfoSeller,        $0F,$00,$07
                DB  fileTesserport,        $0F,$0C,$04
                DB  fileEnroll_Load,       $13,$00,$0C
                DB  fileEntest_Control,    $13,$0C,$04
                DB  fileEntest_Enroll,     $14,$00,$17
                DB  fileEntest_Test,       $15,$07,$0A
                DB  fileAssembly_Load,     $11,$00,$06
                DB  fileAssembly_Control,  $11,$06,$0A
                DB  fileInfirmary_Load,    $17,$00,$08
                DB  fileInfirmary_Control, $17,$08,$0C
                DB  fileEnergy_Load,       $18,$08,$15
                DB  fileEnergy_Control,    $19,$0D,$08
                DB  fileArsenal_Load,      $1B,$00,$0E
                DB  fileArsenal_Control,   $1C,$00,$1F
                DB  fileRobotRep_Load,     $1F,$00,$0A
                DB  fileRobotRep_Control,  $1F,$0A,$28  ;***

                DB  fileSaveGame,          $10,$00,$10  ;*** shorter
