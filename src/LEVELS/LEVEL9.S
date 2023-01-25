
MAP_DATA        DB  9,7

                DW  MAP_0
                DW  MAP_1
                DW  MAP_2
                DW  MAP_3
                DW  MAP_4
                DW  MAP_5
                DW  MAP_6

                DW  10*0
                DW  10*1
                DW  10*2
                DW  10*3
                DW  10*4
                DW  10*5
                DW  10*6
                DW  10*7
                DW  10*8
                DW  10*9

MAP_0           HEX F09010D02020E02010C0
                HEX C0F030B030F230303080
                HEX 60C000C000B030B030C0
                HEX C0E03030308000C00080
                HEX C000F020C030F030F040
                HEX F030000030808000C040
                HEX F02230C000C0F020E040
                HEX C0000280F0008000C040
                HEX C00000C0C0B030E020C0
                HEX 30303030101010101000

MAP_1           HEX F03030F0D0D010F03080
                HEX C0000280C03030A030C0
                HEX C00200C030F000C000C0
                HEX F02030000080C0B020C0
                HEX F030C000F000C0C000C0
                HEX 40C0302000F2C0B020C0
                HEX F0C0F0F2B02280C000C0
                HEX 40F00030C000C0B020C0
                HEX 7000F0003030C0C000C0
                HEX 30303030103010303000

MAP_2           HEX B0D010D010E030A030C0
                HEX C0F0F02230C000C000C0
                HEX C0F230303030302030C0
                HEX F202F030B03030C000C0
                HEX C2C0C002C202F03080C0
                HEX F000C2F03030C200C0C0
                HEX C0B032C00000E230C0C0
                HEX C0C002C00000C200C0C0
                HEX C030C2C00000C2F000C0
                HEX 30103030303030103000

MAP_3           HEX D0A2E4E2E4D0D010F0C0
                HEX C0B400C0C0C0E03080C0
                HEX C0B030C0F080C002C0C0
                HEX C0B430C0F2C0C0E0C0C0
                HEX C0B030C0E032308230C0
                HEX F0B430C0E2F0F0C0F0C0
                HEX C0B030303082C02200C0
                HEX C0B430F0F0C0C0B03080
                HEX C0B2C4C2C4C0C0C000C0
                HEX 10202020301030303000

MAP_4           HEX F03010F030F0F03030C0
                HEX C0F0308000C0820000C0
                HEX C2C000F0F000C00200C0
                HEX C0E030808000302030C0
                HEX C08000F030C000F030C0
                HEX C0F0208000E030E0C040
                HEX C0C000F030F0C0C0C0C0
                HEX 80E0308200C030003040
                HEX C0800030F000F0003040
                HEX 10303030301030303000

MAP_5           HEX F03030B0D0F0103030C0
                HEX C00000C0003030C03040
                HEX C00000F000F030023280
                HEX 72B030C0C030C2F030C0
                HEX F0423000F0B022C000C0
                HEX F030C0F000C002C000C0
                HEX F020308000F0303232C0
                HEX C000F0302000F0308040
                HEX 703000C0F032303030C0
                HEX 30303010202020201000

MAP_6           HEX F03030303030303030C0
                HEX C00000000000000000C0
                HEX C0000000F030308000C0
                HEX C0000000C000B2C000C0
                HEX C0000000C0F000303240
                HEX C0000000C0C0C0F030C0
                HEX C0000000C0E020C000C0
                HEX C00000002030300000C0
                HEX C00000000000000000C0
                HEX 30303030303030303000

SPECIAL_START   DB  SPECIAL_YX0-SPECIAL_YX
                DB  SPECIAL_YX1-SPECIAL_YX
                DB  SPECIAL_YX2-SPECIAL_YX
                DB  SPECIAL_YX3-SPECIAL_YX
                DB  SPECIAL_YX4-SPECIAL_YX
                DB  SPECIAL_YX5-SPECIAL_YX
                DB  SPECIAL_YX6-SPECIAL_YX
SPECIAL_YX
SPECIAL_YX0     DB  $15,$61,$72
SPECIAL_YX1     DB  $12,$21,$55
                DB  $63,$65
SPECIAL_YX2     DB  $13,$21,$30
                DB  $31,$40,$43
                DB  $44,$45,$52
                DB  $56,$62,$66
                DB  $72,$76,$82
                DB  $86
SPECIAL_YX3     DB  $01,$03,$27
                DB  $34,$45,$47
                DB  $54,$65,$67
                DB  $81,$83
SPECIAL_YX4     DB  $16,$20,$27
                DB  $73
SPECIAL_YX5     DB  $27,$28,$30
                DB  $36,$41,$46
                DB  $56,$67,$68
                DB  $85
SPECIAL_YX6     DB  $36,$48
                DB  $FF
SPECIAL_DIR
SPECIAL_DIR0    DB  $0F,$04,$08
SPECIAL_DIR1    DB  $08,$01,$0F
                DB  $0F,$0F
SPECIAL_DIR2    DB  $08,$02,$04
                DB  $04,$04,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F
SPECIAL_DIR3    DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F
SPECIAL_DIR4    DB  $02,$0D,$01
                DB  $0F
SPECIAL_DIR5    DB  $0F,$0F,$0F
                DB  $0F,$08,$0F
                DB  $0F,$0F,$0F
                DB  $0F
SPECIAL_DIR6    DB  $08,$0A
                DB  $00
SPECIAL_ID
SPECIAL_ID0     DB  $0D,$09,$09
SPECIAL_ID1     DB  $09,$09,$10
                DB  $10,$0B
SPECIAL_ID2     DB  $0C,$0A,$01
                DB  $0A,$00,$08
                DB  $08,$08,$08
                DB  $08,$08,$08
                DB  $08,$08,$08
                DB  $08
SPECIAL_ID3     DB  $12,$0E,$13
                DB  $12,$05,$04
                DB  $12,$0D,$13
                DB  $12,$0E
SPECIAL_ID4     DB  $09,$03,$09
                DB  $0F
SPECIAL_ID5     DB  $08,$08,$12
                DB  $08,$02,$08
                DB  $08,$08,$08
                DB  $0D
SPECIAL_ID6     DB  $07,$06

SPECIAL_LIST    DW  ELEVATOR_345
                DW  ELEVATOR_FAR
                DW  FAKE_FC_IN
                DW  GRAFFITI
                DW  KEY_PEDESTAL
                DW  KEY_GUARD
                DW  KEY_DOOR
                DW  NAJA_DOOR
                DW  SHIP_SOUND
                DW  ROTROOM
                DW  NET
                DW  QUICKD
                DW  ESTATION
                DW  VDOORS
                DW  HDOORS
                DW  CDFOUND
                DW  INFROOM
                DW  AUTOEN
                DW  NOENCNT
                DW  NOTDOOR

ENCOUNTER_START DB  ENCOUNTER_YX0-ENCOUNTER_YX
                DB  ENCOUNTER_YX1-ENCOUNTER_YX
                DB  ENCOUNTER_YX2-ENCOUNTER_YX
                DB  ENCOUNTER_YX3-ENCOUNTER_YX
                DB  ENCOUNTER_YX4-ENCOUNTER_YX
                DB  ENCOUNTER_YX5-ENCOUNTER_YX
                DB  ENCOUNTER_YX6-ENCOUNTER_YX
ENCOUNTER_YX
ENCOUNTER_YX0
ENCOUNTER_YX1
ENCOUNTER_YX2
ENCOUNTER_YX3   DB  $02,$04,$11
                DB  $31,$51,$71
                DB  $82,$84
ENCOUNTER_YX4
ENCOUNTER_YX5
ENCOUNTER_YX6
                DB  $FF
ENCOUNTER_DIR
ENCOUNTER_DIR0
ENCOUNTER_DIR1
ENCOUNTER_DIR2
ENCOUNTER_DIR3  DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F
ENCOUNTER_DIR4
ENCOUNTER_DIR5
ENCOUNTER_DIR6
                DB  $00
ENCOUNTER_ID
ENCOUNTER_ID0
ENCOUNTER_ID1
ENCOUNTER_ID2
ENCOUNTER_ID3   DB  $00,$01,$02
                DB  $03,$04,$05
                DB  $06,$07
ENCOUNTER_ID4
ENCOUNTER_ID5
ENCOUNTER_ID6
