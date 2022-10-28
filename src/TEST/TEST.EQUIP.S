
EPTR            =   $C0
EPTRH           =   $C1

TEST_EQUIPMENT  JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictMoveTo 4;2
                PictEnd

                LDA #<DATA_START
                STA EPTR
                LDA #>DATA_START
                STA EPTRH

:1              LDX #0
                LDY #0
:2              LDA (EPTR),Y
                STA ETABLE,X
                INY
                INX
                CPX #4
                BNE :2

                LDX #0
                TXA
:3              STA TEXT_BUFFER,X
                INX
                CPX #32
                BNE :3

                JSR ETABLE_TO_TEXT
                LDA #TextLineBreak
                STA TEXT_BUFFER,X
                LDA #TextLineEnd
                STA TEXT_BUFFER+1,X
                JSR DRAW_TEXTBUF

                LDA YCOORD
                CMP #185
                BNE :5

                BIT UNSTROB
:4              LDA KEYBRD
                BPL :4

                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictMoveTo 4;2
                PictEnd
:5
                LDA EPTR
                CLC
                ADC #4
                STA EPTR
                BCC :6
                INC EPTRH
:6              CMP #<DATA_END
                BNE :1
                LDA EPTRH
                CMP #>DATA_END
                BNE :1
                CLC
                RTS

; CODEOFF         DW  PISTCOD
;                 DW  RIFLCOD
;                 DW  CANNCOD
;                 DW  BEAMCOD
;                 DW  MWEACOD
;                 DW  ATTACOD
;                 DW  MARMCOD
;                 DW  MEDICOD
;                 DW  SCANCOD
;                 DW  MISCCOD
;                 DW  SHLDCOD
;                 DW  RHANCOD
;                 DW  RSWOCOD
;                 DW  RBLACOD
;                 DW  HELMCOD
;                 DW  ARMRCOD

DATA_START

;                                F
;                                L
;                    B           A
;                    I           G
;                    U           S
MISCCOD
                DB  $43,$00,$00,$EE     ; ROBOT_CONTROLLER
                DB  $03,$00,$00,$EE     ; ROBOT_CONTROLLER
                DB  $63,$01,$00,$EE     ; MUSCLE
                DB  $23,$01,$00,$EE     ; MAROON_POWDER
                DB  $63,$09,$00,$EE     ; REFLEX
                DB  $23,$09,$00,$EE     ; SILVER_POWDER
                DB  $43,$03,$00,$EE     ; COMPRESSD_PERSON
                DB  $03,$03,$00,$EE     ; COMPRESSD_PERSON
                DB  $43,$04,$00,$EE     ; DATA_CARD
                DB  $03,$04,$00,$EE     ; DATA_CARD
                DB  $43,$05,$00,$EE     ; JUNK
                DB  $03,$05,$00,$EE     ; JUNK

                DB  $43,$02,$00,$EE     ; TERRAN_KEY
                DB  $43,$0A,$00,$EE     ; TOUHTAAN_KEY
                DB  $43,$12,$00,$EE     ; ZINAN_KEY
                DB  $43,$1A,$00,$EE     ; !!!_KEY
                DB  $43,$22,$00,$EE     ; GILLOITAN_KEY

                DB  $03,$02,$00,$EE     ; WHITE_SAND
                DB  $03,$0A,$00,$EE     ; HEAVY_STONE
                DB  $03,$12,$00,$EE     ; CHANGING_CRYSTAL
                DB  $03,$1A,$00,$EE     ; PLASTEEL_CIRCUIT
                DB  $03,$22,$00,$EE     ; PETRIFIED_LEAF

BEAMCOD         DB  $48,$00,$00,$AD     ; BLUE_BEAM_DAGGER
                DB  $48,$01,$00,$8D     ; GREEN_BEAM_DAGGER
                DB  $48,$04,$08,$21     ; BLUE_BEAM_SWORD
                DB  $48,$05,$28,$01     ; GREEN_BEAM_SWORD
                DB  $48,$06,$28,$21     ; RED_BEAM_SWORD
                DB  $48,$07,$08,$21     ; LASBEAM_SWORD
                DB  $48,$0B,$08,$01     ; LASER_WHIP

PISTCOD         DB  $4C,$00,$00,$A7     ; FLY_PISTOL
                DB  $4C,$01,$00,$A5     ; LIGHT_PISTOL
                DB  $4C,$02,$08,$A1     ; MEDIUM_PISTOL
                DB  $4C,$03,$08,$A1     ; HEAVY_PISTOL
                DB  $4C,$05,$08,$21     ; ZIFFER'S_PISTOL

RIFLCOD         DB  $4D,$00,$20,$A1     ; LIGHT_RIFLE
                DB  $4D,$01,$28,$21     ; MEDIUM_RIFLE
                DB  $4D,$03,$2C,$21     ; HEAVY_RIFLE
                DB  $4D,$05,$2D,$01     ; ULTRA_RIFLE

CANNCOD         DB  $4E,$00,$2D,$01     ; LIGHT_CANNON
                DB  $4E,$01,$2D,$01     ; HEAVY_CANNON

MWEACOD         DB  $4F,$01,$08,$01     ; GYRO_BOOMERANG
                DB  $4F,$04,$0D,$01     ; DISINTEGRATOR
                DB  $4F,$05,$00,$01     ; BRAIN_JAMMER
                DB  $4F,$06,$00,$89     ; IMMOBILIZER
                DB  $4F,$07,$00,$89     ; SONIC_GRENADE
                DB  $4F,$08,$00,$84     ; ROBOT_RESTRAINER

ATTACOD         DB  $40,$08,$00,$F7     ; 2%_DISSIPATOR
                DB  $40,$14,$00,$F7     ; 5%_DISSIPATOR
                DB  $40,$1C,$00,$F7     ; 7%_DISSIPATOR
                DB  $40,$01,$00,$EE     ; IMAGE_GENERATOR
                DB  $40,$02,$00,$8D     ; BLAST_VISOR

MARMCOD         DB  $47,$09,$04,$57     ; 2%_GROUNDERS
                DB  $47,$15,$04,$57     ; 5%_GROUNDERS
                DB  $47,$1D,$04,$57     ; 7%_GROUNDERS
                DB  $47,$03,$0E,$89     ; EXOSKELETON

MEDICOD         DB  $41,$00,$00,$50     ; DIAGNOSER
                DB  $61,$01,$00,$50     ; CELL_REGENERATOR
                DB  $61,$02,$00,$40     ; CIRCUIT_REPAIRER
                DB  $41,$03,$00,$50     ; ATOM_COMPRESSOR
                DB  $41,$04,$00,$50     ; CAUTERIZER
                DB  $41,$06,$00,$50     ; SIGHT_RESTORER
                DB  $41,$07,$00,$50     ; BRAIN_EQUALIZER
                DB  $41,$08,$00,$50     ; DRUG_INFUSOR
                DB  $41,$09,$00,$50     ; ANTI-POISON
                DB  $41,$19,$00,$50     ; ANTI-FUNGUS
                DB  $41,$29,$00,$50     ; ANTI-PARASITE
                DB  $41,$39,$00,$50     ; ANTI-VIRUS
                DB  $41,$49,$00,$50     ; ANTI-BACTERIA
                DB  $41,$59,$00,$50     ; ANTI-PENGUIN

SCANCOD         DB  $42,$00,$00,$02     ; I.D._SCANNER
                DB  $42,$01,$00,$02     ; FACE_TRACKER
                DB  $42,$02,$00,$02     ; ORGANIC_DETECTOR
                DB  $42,$03,$00,$02     ; ROBOTIC_DETECTOR
                DB  $42,$04,$00,$02     ; DOOR_UNLOCKER
                DB  $42,$05,$04,$02     ; VIBRATION_SENSOR

SHLDCOD         DB  $46,$01,$00,$56     ; _5%_FORCE_SHIELD
                DB  $46,$02,$00,$56     ; 10%_FORCE_SHIELD
                DB  $46,$03,$00,$56     ; 15%_FORCE_SHIELD
                DB  $46,$04,$00,$56     ; 20%_FORCE_SHIELD
                DB  $46,$05,$00,$56     ; 25%_FORCE_SHIELD
                DB  $46,$06,$00,$56     ; 30%_FORCE_SHIELD
                DB  $46,$07,$00,$56     ; 35%_FORCE_SHIELD
                DB  $46,$08,$00,$56     ; 40%_FORCE_SHIELD
                DB  $46,$09,$00,$56     ; 45%_FORCE_SHIELD
                DB  $46,$0A,$00,$56     ; 50%_FORCE_SHIELD
                DB  $46,$0B,$00,$56     ; 55%_FORCE_SHIELD
                DB  $46,$0C,$00,$56     ; 60%_FORCE_SHIELD

RHANCOD         DB  $59,$00,$00,$00     ; HAND_ATTACHMENT

RSWOCOD         DB  $58,$00,$00,$A7     ; ROBO-DAGGER
                DB  $58,$04,$18,$21     ; ROBO-SWORD

RBLACOD         DB  $5C,$00,$00,$A7     ; ROBO-BLASTER_C
                DB  $5C,$01,$00,$A5     ; ROBO-BLASTER_B
                DB  $5C,$02,$08,$A1     ; ROBO-BLASTER_A

HELMCOD         DB  $45,$00,$00,$DF     ; BENDER-C_HELMET
                DB  $45,$01,$00,$DF     ; BENDER-B_HELMET
                DB  $45,$02,$00,$DF     ; BENDER-A_HELMET

                DB  $45,$04,$00,$DF     ; MIRAGE-C_HELMET
                DB  $45,$05,$00,$DF     ; MIRAGE-B_HELMET
                DB  $45,$06,$00,$DF     ; MIRAGE-A_HELMET

                DB  $45,$08,$00,$DF     ; IMAGE-C_HELMET
                DB  $45,$09,$00,$DF     ; IMAGE-B_HELMET
                DB  $45,$0A,$00,$DF     ; IMAGE-A_HELMET

                DB  $45,$0C,$00,$DF     ; MIRROR-C_HELMET
                DB  $45,$0D,$00,$DF     ; MIRROR-B_HELMET
                DB  $45,$0E,$00,$DF     ; MIRROR-A_HELMET

ARMRCOD         DB  $44,$00,$00,$DF     ; CLEAR-E_ARMOR
                DB  $44,$01,$00,$DF     ; CLEAR-D_ARMOR
                DB  $44,$02,$00,$DF     ; CLEAR-C_ARMOR
                DB  $44,$03,$00,$DF     ; CLEAR-B_ARMOR
                DB  $44,$04,$00,$DF     ; CLEAR-A_ARMOR

                DB  $44,$00,$80,$DF     ; SMART_CLEAR-E     ; trunc
                DB  $44,$01,$80,$DF     ; SMART_CLEAR-D     ; trunc
                DB  $44,$02,$80,$DF     ; SMART_CLEAR-C     ; trunc
                DB  $44,$03,$80,$DF     ; SMART_CLEAR-B     ; trunc
                DB  $44,$04,$80,$DF     ; SMART_CLEAR-A     ; trunc

                DB  $44,$08,$00,$DF     ; BENDER-E_ARMOR
                DB  $44,$09,$00,$DF     ; BENDER-D_ARMOR
                DB  $44,$0A,$00,$DF     ; BENDER-C_ARMOR
                DB  $44,$0B,$00,$DF     ; BENDER-B_ARMOR
                DB  $44,$0C,$00,$DF     ; BENDER-A_ARMOR

                DB  $44,$08,$80,$DF     ; SMART_BENDER-E    ; trunc
                DB  $44,$09,$80,$DF     ; SMART_BENDER-D    ; trunc
                DB  $44,$0A,$80,$DF     ; SMART_BENDER-C    ; trunc
                DB  $44,$0B,$80,$DF     ; SMART_BENDER-B    ; trunc
                DB  $44,$0C,$80,$DF     ; SMART_BENDER-A    ; trunc

                DB  $44,$10,$00,$DF     ; MIRAGE-E_ARMOR
                DB  $44,$11,$00,$DF     ; MIRAGE-D_ARMOR
                DB  $44,$12,$00,$DF     ; MIRAGE-C_ARMOR
                DB  $44,$13,$00,$DF     ; MIRAGE-B_ARMOR
                DB  $44,$14,$00,$DF     ; MIRAGE-A_ARMOR

                DB  $44,$10,$80,$DF     ; SMART_MIRAGE-E    ; trunc
                DB  $44,$11,$80,$DF     ; SMART_MIRAGE-D    ; trunc
                DB  $44,$12,$80,$DF     ; SMART_MIRAGE-C    ; trunc
                DB  $44,$13,$80,$DF     ; SMART_MIRAGE-B    ; trunc
                DB  $44,$14,$80,$DF     ; SMART_MIRAGE-A    ; trunc

                DB  $44,$18,$00,$DF     ; IMAGE-E_ARMOR
                DB  $44,$19,$00,$DF     ; IMAGE-D_ARMOR
                DB  $44,$1A,$00,$DF     ; IMAGE-C_ARMOR
                DB  $44,$1B,$00,$DF     ; IMAGE-B_ARMOR
                DB  $44,$1C,$00,$DF     ; IMAGE-A_ARMOR

                DB  $44,$18,$80,$DF     ; SMART_IMAGE-E     ; trunc
                DB  $44,$19,$80,$DF     ; SMART_IMAGE-D     ; trunc
                DB  $44,$1A,$80,$DF     ; SMART_IMAGE-C     ; trunc
                DB  $44,$1B,$80,$DF     ; SMART_IMAGE-B     ; trunc
                DB  $44,$1C,$80,$DF     ; SMART_IMAGE-A     ; trunc

                DB  $44,$20,$00,$DF     ; MIRROR-E_ARMOR
                DB  $44,$21,$00,$DF     ; MIRROR-D_ARMOR
                DB  $44,$22,$00,$DF     ; MIRROR-C_ARMOR
                DB  $44,$23,$00,$DF     ; MIRROR-B_ARMOR
                DB  $44,$24,$00,$DF     ; MIRROR-A_ARMOR

                DB  $44,$20,$80,$DF     ; SMART_MIRROR-E    ; trunc
                DB  $44,$21,$80,$DF     ; SMART_MIRROR-D    ; trunc
                DB  $44,$22,$80,$DF     ; SMART_MIRROR-C    ; trunc
                DB  $44,$23,$80,$DF     ; SMART_MIRROR-B    ; trunc
                DB  $44,$24,$80,$DF     ; SMART_MIRROR-A    ; trunc

;*** PROGRAM CARD ***

DATA_END

; PROGS           DB  $01
;                 DB  $02,$03,$04
;                 DB  $05,$06,$07
;                 DB  $10
;                 DB  $15,$20,$25
;                 DB  $30,$35,$40
;                 DB  $45,$50,$55
;                 DB  $60,$65,$70
;                 DB  $75
