
MAP_DATA        DB  13,6

                DW  MAP_0
                DW  MAP_1
                DW  MAP_2
                DW  MAP_3
                DW  MAP_4
                DW  MAP_5

                DW  14*0
                DW  14*1
                DW  14*2
                DW  14*3
                DW  14*4
                DW  14*5
                DW  14*6
                DW  14*7
                DW  14*8
                DW  14*9
                DW  14*10
                DW  14*11
                DW  14*12
                DW  14*13

MAP_0           HEX E0303030303030303030303030C0
                HEX F03030C0F03030C0F03030C0F0C0
                HEX C0E0C0C0C0E2C0C0C0E0C0C0C0C0
                HEX C0C0C0C0C0C0C0C0C0C0C0C080C0
                HEX C0C0C03000C0C03000C0C080C0C0
                HEX 6030303030303030F0303000F0C0
                HEX F0303030F0F030C0F030303000C0
                HEX 40F030C0C00000C0C030303030C0
                HEX C080F0C000C00280F030303000C0
                HEX C0F000C0C0C000C0F020C0E030C0
                HEX C0F02000303030C0F03000B03040
                HEX 4000F030B03080C0F030C0F030C0
                HEX C0303030303000C0F2A0002030C0
                HEX 3030302030303010303030303000

MAP_1           HEX F03030E0F0F0B0D0F0303030F0C0
                HEX C0F030C0C280C0C0C0F0800030C0
                HEX C0C0302020B000C0C0C0C00000C0
                HEX C0C0F2B0303232C0C0C03020F0C0
                HEX C000C0C2000000C0B000F030C0C0
                HEX C000C0C2020200C0F0C0C00020C0
                HEX 703230C2020000C0C02030203040
                HEX C0E0C0C0000002C0C0E0F02030C0
                HEX C0C0C0C0020202C0B000C000E0C0
                HEX 40C2C080020202C0F0C03030C0C0
                HEX C0E03030F03030C0C0C0F02030C0
                HEX C0E230C0000000C0C0C0800000C0
                HEX 40C000C0C00000C0C0300000F0C0
                HEX 1030303030103010303030303000

MAP_2           HEX F0F010303030303030B0303030C0
                HEX C0800000000000B0303030C00080
                HEX F030203030B0303030C000B03240
                HEX C03030B0303030C000B03202A280
                HEX C03030F030C000B03002A2A2A280
                HEX F0300080F0303000F0F2A2A2A280
                HEX 4030F20280B030B000002204A280
                HEX C0303080C0303030C0C2A282A280
                HEX F03000C030F030803032A2A2A280
                HEX C03030B0300000F030802222A280
                HEX C030303030B0300000F030802240
                HEX F0B02030303030B0300000F03080
                HEX C0C000000000003030B0300000C0
                HEX 3030103030303030303030303000

MAP_3           HEX F0303030B030303030303030E0C0
                HEX 8000F030303080000000000080C0
                HEX 72308000F0303030B030203030C0
                HEX A28232308000F0303030B03000C0
                HEX A2A2A28230308000F030F03000C0
                HEX A2A2A2B2F0C0303030E0C03030C0
                HEX A284220002323230C08030300040
                HEX A282A282C0F0303000C0F03000C0
                HEX A2A2A2B23000B030F020C03030C0
                HEX A2A22200B030C0003030B03000C0
                HEX 6200B030C0003030B030303000C0
                HEX B030C0003030B03030302030B0C0
                HEX C0003030B030000000000000C0C0
                HEX 3030303030303030303030302000

MAP_4           HEX F030F0F030D0F0103030301030C0
                HEX C0028030C0C0C0000000000000C0
                HEX C000C000C0C0E020E020E020C0C0
                HEX F0F00000C0C0F030303230B2C0C0
                HEX C03030C03080C002000200C0C0C0
                HEX C00000C0F0C0C002000200F0C0C0
                HEX 7020302000C0C002000200C00040
                HEX F02230E0C0C0C002000000F0C0C0
                HEX C00000C03080C000020202C0C0C0
                HEX C0F03000F0C0C200000000C0C040
                HEX F02030C0C0C0F0F030F022C0C0C0
                HEX C0000080C0C0C0C0C0C0C0C0C0C0
                HEX C00000F000C0C000C000C000C040
                HEX 3030303030103030101030301000

MAP_5           HEX 5030B03030D0F0D0F030303030C0
                HEX C0F03080F00030C0F020C0E030C0
                HEX C0C000F0C00000C0F03000B03040
                HEX 40F0C0C0C00000C0F030C0F030C0
                HEX 40C030E030C0F0C0F022022230C0
                HEX C0C0008000C280C0C2F03030C2C0
                HEX C0202030303000C0C2C00000C2C0
                HEX 7020303030303000C2C00000C2C0
                HEX F0303030303030300032323200C0
                HEX F02030F030F0C0F0F030F03030C0
                HEX F2C00080008030008000800000C0
                HEX C23000C000C0F0C0C000C00000C0
                HEX F0303030303000303030302030C0
                HEX 2030303030303030303030303000

SPECIAL_START   DB  SPECIAL_YX0-SPECIAL_YX
                DB  SPECIAL_YX1-SPECIAL_YX
                DB  SPECIAL_YX2-SPECIAL_YX
                DB  SPECIAL_YX3-SPECIAL_YX
                DB  SPECIAL_YX4-SPECIAL_YX
                DB  SPECIAL_YX5-SPECIAL_YX
SPECIAL_YX
SPECIAL_YX0     DB  $25,$86,$C8
SPECIAL_YX1     DB  $14,$32,$35
                DB  $36,$43,$53
                DB  $54,$55,$61
                DB  $63,$64,$76
                DB  $84,$85,$86
                DB  $91,$94,$95
                DB  $96,$B1
SPECIAL_YX2     DB  $2C,$3A,$3B
                DB  $3C,$49,$4A
                DB  $4B,$4C,$59
                DB  $5A,$5B,$5C
                DB  $62,$63,$6A
                DB  $6C,$79,$7A
                DB  $7B,$7C,$89
                DB  $8A,$8B,$8C
                DB  $9A,$9B,$9C
                DB  $AC
SPECIAL_YX3     DB  $20,$30,$31
                DB  $32,$40,$41
                DB  $42,$43,$50
                DB  $51,$52,$53
                DB  $60,$62,$64
                DB  $65,$66,$70
                DB  $71,$72,$73
                DB  $80,$81,$82
                DB  $83,$90,$91
                DB  $92,$A0
SPECIAL_YX4     DB  $11,$39,$3B
                DB  $47,$49,$57
                DB  $59,$67,$69
                DB  $71,$77,$88
                DB  $89,$8A,$96
                DB  $AA
SPECIAL_YX5     DB  $49,$4A,$4B
                DB  $55,$58,$5C
                DB  $68,$6C,$78
                DB  $7C,$89,$8A
                DB  $8B,$A0,$B0
                DB  $B0
                DB  $FF
SPECIAL_DIR
SPECIAL_DIR0    DB  $04,$0F,$08
SPECIAL_DIR1    DB  $0F,$04,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$04
SPECIAL_DIR2    DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $08,$08,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F
SPECIAL_DIR3    DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$02
                DB  $02,$02,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F
SPECIAL_DIR4    DB  $08,$0F,$02
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $01
SPECIAL_DIR5    DB  $0F,$0F,$0F
                DB  $01,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$0F,$0F
                DB  $0F,$01,$01
                DB  $02
                DB  $00
SPECIAL_ID
SPECIAL_ID0     DB  $14,$0E,$15
SPECIAL_ID1     DB  $0E,$07,$13
                DB  $13,$13,$13
                DB  $13,$13,$0F
                DB  $13,$13,$13
                DB  $13,$13,$13
                DB  $03,$13,$13
                DB  $13,$12
SPECIAL_ID2     DB  $0F,$0F,$0F
                DB  $0D,$0F,$0D
                DB  $0D,$10,$0F
                DB  $0D,$0F,$03
                DB  $01,$02,$0F
                DB  $10,$0F,$0D
                DB  $0F,$03,$0F
                DB  $0D,$0D,$0D
                DB  $0F,$0F,$0F
                DB  $0F
SPECIAL_ID3     DB  $0F,$0D,$0F
                DB  $0F,$0D,$0F
                DB  $0D,$0F,$03
                DB  $0F,$0D,$0F
                DB  $03,$0F,$08
                DB  $04,$09,$03
                DB  $0F,$0D,$0F
                DB  $10,$0F,$0D
                DB  $0F,$0D,$0F
                DB  $0F,$0F
SPECIAL_ID4     DB  $0A,$13,$0C
                DB  $13,$13,$13
                DB  $13,$13,$13
                DB  $14,$13,$13
                DB  $13,$13,$13
                DB  $06
SPECIAL_ID5     DB  $11,$11,$11
                DB  $05,$11,$11
                DB  $11,$11,$11
                DB  $11,$11,$11
                DB  $11,$00,$02
                DB  $0B

SPECIAL_LIST    DW  ELEVATOR_123
                DW  ELEVATOR_345
                DW  ELEVATOR_FAR
                DW  ADD_DOOR
                DW  CODEDOOR
                DW  CROSSWALK
                DW  DNUMBER
                DW  INFCORE
                DW  KEY_GUARD
                DW  KEY_PEDESTAL
                DW  LIBRARY
                DW  GREEN_NET
                DW  NETCODE
                DW  NO_ENCOUNTER
                DW  QUICKD
                DW  REMOVE_DOOR
                DW  ROTCUBE
                DW  SHIP_SOUND
                DW  STOREROOM
                DW  TELEPORT
                DW  TPDATAC
                DW  WEAPON_CABINET

ENCOUNTER_START DB  ENCOUNTER_YX0-ENCOUNTER_YX
                DB  ENCOUNTER_YX1-ENCOUNTER_YX
                DB  ENCOUNTER_YX2-ENCOUNTER_YX
                DB  ENCOUNTER_YX3-ENCOUNTER_YX
                DB  ENCOUNTER_YX4-ENCOUNTER_YX
                DB  ENCOUNTER_YX5-ENCOUNTER_YX
ENCOUNTER_YX
ENCOUNTER_YX0
ENCOUNTER_YX1
ENCOUNTER_YX2   DB  $6B
ENCOUNTER_YX3   DB  $61
ENCOUNTER_YX4
ENCOUNTER_YX5
                DB  $FF
ENCOUNTER_DIR
ENCOUNTER_DIR0
ENCOUNTER_DIR1
ENCOUNTER_DIR2  DB  $0F
ENCOUNTER_DIR3  DB  $0F
ENCOUNTER_DIR4
ENCOUNTER_DIR5
                DB  $00
ENCOUNTER_ID
ENCOUNTER_ID0
ENCOUNTER_ID1
ENCOUNTER_ID2   DB  $00
ENCOUNTER_ID3   DB  $01
ENCOUNTER_ID4
ENCOUNTER_ID5
