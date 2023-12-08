CODEOFF         DW  PISTCOD
                DW  RIFLCOD
                DW  CANNCOD
                DW  BEAMCOD
                DW  MWEACOD
                DW  ATTACOD
                DW  MARMCOD
                DW  MEDICOD
                DW  SCANCOD
                DW  MISCCOD
                DW  SHLDCOD
                DW  RHANCOD
                DW  RSWOCOD
                DW  RBLACOD

PRICOFF         DW  PISTPRI
                DW  RIFLPRI
                DW  CANNPRI
                DW  BEAMPRI
                DW  MWEAPRI
                DW  ATTAPRI
                DW  MARMPRI
                DW  MEDIPRI
                DW  SCANPRI
                DW  MISCPRI
                DW  SHLDPRI
                DW  RHANPRI
                DW  RSWOPRI
                DW  RBLAPRI

PISTCOD         DB  $4C,$00,$00,$A7
                DB  $4C,$01,$00,$A5
                DB  $4C,$02,$08,$A1
                DB  $4C,$03,$08,$A1
                DB  $4C,$05,$08,$21
RIFLCOD         DB  $4D,$00,$20,$A1
                DB  $4D,$01,$28,$21
                DB  $4D,$03,$2C,$21
                DB  $4D,$05,$2D,$01
CANNCOD         DB  $4E,$00,$2D,$01
                DB  $4E,$01,$2D,$01
BEAMCOD         DB  $48,$00,$00,$AD
                DB  $48,$01,$00,$8D
                DB  $48,$04,$08,$21
                DB  $48,$05,$28,$01
                DB  $48,$06,$28,$21
                DB  $48,$07,$08,$21
                DB  $48,$0B,$08,$01
MWEACOD         DB  $4F,$01,$08,$01
                DB  $4F,$04,$0D,$01
                DB  $4F,$05,$00,$01
                DB  $4F,$06,$00,$89
                DB  $4F,$07,$00,$89
                DB  $4F,$08,$00,$84
ATTACOD         DB  $40,$08,$00,$F7
                DB  $40,$14,$00,$F7
                DB  $40,$1C,$00,$F7
                DB  $40,$01,$00,$EE
                DB  $40,$02,$00,$8D
MARMCOD         DB  $47,$09,$04,$57
                DB  $47,$15,$04,$57
                DB  $47,$1D,$04,$57
                DB  $47,$03,$0E,$89
MEDICOD         DB  $41,$00,$00,$50
                DB  $61,$01,$00,$50
                DB  $61,$02,$00,$40
                DB  $41,$03,$00,$50
                DB  $41,$04,$00,$50
                DB  $41,$06,$00,$50
                DB  $41,$07,$00,$50
                DB  $41,$08,$00,$50
                DB  $41,$09,$00,$50
                DB  $41,$19,$00,$50
                DB  $41,$29,$00,$50
                DB  $41,$39,$00,$50
                DB  $41,$49,$00,$50
                DB  $41,$59,$00,$50
SCANCOD         DB  $42,$00,$00,$02
                DB  $42,$01,$00,$02
                DB  $42,$02,$00,$02
                DB  $42,$03,$00,$02
                DB  $42,$04,$00,$02
                DB  $42,$05,$04,$02
MISCCOD         DB  $43,$00,$00,$84
                DB  $63,$01,$00,$DF
                DB  $63,$09,$00,$DF
SHLDCOD         DB  $46,$01,$00,$56
                DB  $46,$02,$00,$56
                DB  $46,$03,$00,$56
                DB  $46,$04,$00,$56
                DB  $46,$05,$00,$56
                DB  $46,$06,$00,$56
                DB  $46,$07,$00,$56
                DB  $46,$08,$00,$56
                DB  $46,$09,$00,$56
                DB  $46,$0A,$00,$56
                DB  $46,$0B,$00,$56
                DB  $46,$0C,$00,$56
RHANCOD         DB  $59,$00,$00,$00
RSWOCOD         DB  $58,$00,$00,$A7
                DB  $58,$04,$18,$21
RBLACOD         DB  $5C,$00,$00,$A7
                DB  $5C,$01,$00,$A5
                DB  $5C,$02,$08,$A1

PROGS           DB  $01
                DB  $02,$03,$04
                DB  $05,$06,$07
                DB  $10
                DB  $15,$20,$25
                DB  $30,$35,$40
                DB  $45,$50,$55
                DB  $60,$65,$70
                DB  $75

PISTPRI         HEX 000100
                HEX 000220
                HEX 009000
                HEX 040000
                HEX 090000
RIFLPRI         HEX 000900
                HEX 002550
                HEX 100000
                HEX 500000
CANNPRI         HEX 750000
                HEX 900000
BEAMPRI         HEX 000060
                HEX 000100
                HEX 000300
                HEX 006000
                HEX 010000
                HEX 100000
                HEX 050000
MWEAPRI         HEX 200000
                HEX 999000
                HEX 075000
                HEX 005000
                HEX 001000
ATTAPRI         HEX 000200
                HEX 000900
                HEX 004000
                HEX 175000
                HEX 008000
MARMPRI         HEX 000500
                HEX 001000
                HEX 005000
                HEX 920000
MEDIPRI         HEX 000025
                HEX 000060
                HEX 025000
                HEX 000370
                HEX 010000
                HEX 020000
                HEX 020000
                HEX 000140
                HEX 001111          ;TEMP
                HEX 001111          ;TEMP
                HEX 001111          ;TEMP
                HEX 001111          ;TEMP
                HEX 001111          ;TEMP
                HEX 001111          ;TEMP
SCANPRI         HEX 000085
                HEX 000080
                HEX 020000
                HEX 007500
                HEX 000020
                HEX 065000
MISCPRI         HEX 000085
                HEX 107828
                HEX 147828
SHLDPRI         HEX 001000
                HEX 001000
                HEX 001000
                HEX 001000
                HEX 001000
                HEX 001000
                HEX 001000
                HEX 001000
                HEX 001000
                HEX 001000
                HEX 001000
                HEX 001000
RHANPRI         HEX 010000
RSWOPRI         HEX 000060
                HEX 000300
RBLAPRI         HEX 000100
                HEX 000220
                HEX 009000
RPROPRI         HEX 000020
                HEX 000080
                HEX 000120
                HEX 000170
                HEX 000230
                HEX 000290
                HEX 000370
                HEX 000750
                HEX 002000
                HEX 004000
                HEX 006000
                HEX 010000
                HEX 017500
                HEX 027500
                HEX 045000
                HEX 065000
                HEX 090000
                HEX 115000
                HEX 150000
                HEX 190000
                HEX 250000

STOCK_PTRS      DW  PISTOL_STOCK
                DW  RIFLE_STOCK
                DW  CANNON_STOCK
                DW  BEAM_STOCK
                DW  MWEAPON_STOCK
                DW  ATTACH_STOCK
                DW  MARMOR_STOCK
                DW  MEDIC_STOCK
                DW  SCANNER_STOCK
                DW  MISC_STOCK
                DW  SHIELD_STOCK
