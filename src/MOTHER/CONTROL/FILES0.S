
; files for disk side 0 (mothership)

FILE_TABLE      DB  fileDeleteChar,        $0E,$00,$09
                DB  fileTesserport,        $0E,$0C,$04
                DB  fileInfoSeller,        $0F,$00,$07
                DB  fileEnroll_Load,       $13,$00,$0C
                DB  fileEnroll_Control,    $13,$0C,$00
                DB  fileEnroll_Test,       $13,$00,$00
                DB  fileAssembly_Load,     $11,$00,$06
                DB  fileAssembly_Control,  $11,$06,$0A
                DB  fileInfirmary_Load,    $17,$00,$08
                DB  fileInfirmary_Control, $17,$08,$00
                DB  fileEnergy_Load,       $18,$08,$15
                DB  fileEnergy_Control,    $19,$0D,$00
                DB  fileArsenal_Load,      $1B,$00,$0E
                DB  fileArsenal_Control,   $1B,$0E,$00
                DB  fileRobotRep_Load,     $1F,$00,$0A
                DB  fileRobotRep_Control,  $1F,$0A,$00

                DB  fileSaveGame,          $10,$00,$10  ;*** shorter
