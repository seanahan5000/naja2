
MAP_DATA        DB  12,1

                DW  MAP_0

                DW  13*0
                DW  13*1
                DW  13*2
                DW  13*3
                DW  13*4
                DW  13*5
                DW  13*6
                DW  13*7
                DW  13*8
                DW  13*9
                DW  13*10
                DW  13*11
                DW  13*12

MAP_0           HEX F03030303030F03232B03030C0
                HEX C00000F030C030C0F0000000C0
                HEX C00000F002C000E2C0000000C0
                HEX C0F03000F0F0C0C0C0000000C0
                HEX F20000003002B2C2C0000000C0
                HEX F0C00000F030303000000000C0
                HEX F032F0C2C00000F2C0000000C0
                HEX C0F000E2F2C000E2C0000000C0
                HEX C0C00030E2303000C0F2C000C0
                HEX C2B2C00030C000003022C000C0
                HEX F030000000C2F03030C2C000C0
                HEX C00000F23022C00000E23032C0
                HEX 30303030303030303030303000

SPECIAL_START   DB  SPECIAL_YX0-SPECIAL_YX
SPECIAL_YX
SPECIAL_YX0     DB  $07,$08,$24
                DB  $27,$40,$45
                DB  $45,$46,$47
                DB  $61,$63,$67
                DB  $73,$74,$77
                DB  $84,$89,$90
                DB  $91,$99,$A5
                DB  $A9,$B3,$B3
                DB  $B5,$B9,$BB
                DB  $FF
SPECIAL_DIR
SPECIAL_DIR0    DB  $01,$92,$01
                DB  $81,$38,$01
                DB  $02,$0F,$04
                DB  $12,$14,$4F
                DB  $1F,$3F,$41
                DB  $31,$5F,$22
                DB  $2F,$51,$74
                DB  $74,$28,$02
                DB  $61,$61,$22
                DB  $00
SPECIAL_ID
SPECIAL_ID0     DB  $05,$01,$04
                DB  $01,$00,$03
                DB  $01,$02,$00
                DB  $00,$01,$02
                DB  $02,$02,$01
                DB  $01,$02,$01
                DB  $02,$01,$01
                DB  $01,$00,$06
                DB  $01,$01,$00

SPECIAL_LIST    DW  TRANSPORT
                DW  DOOR_SIGN
                DW  LOAD_AREA
                DW  GUARD
                DW  DELETE
                DW  TESSERPORT
                DW  INFO_SELLER

ENCOUNTER_START DB  ENCOUNTER_YX0-ENCOUNTER_YX
ENCOUNTER_YX
ENCOUNTER_YX0
                DB  $FF
ENCOUNTER_DIR
ENCOUNTER_DIR0
                DB  $00
ENCOUNTER_ID
ENCOUNTER_ID0
