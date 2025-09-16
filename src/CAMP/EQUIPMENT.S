; renamed from NCOMMONS.EQUI.S

; POINTL			=	LOCAL_TEMP+0
; POINTH			=	LOCAL_TEMP+1
ETEMP			=	LOCAL_TEMP+2

_GET_KEY_STRING LDX #<GROUP_KEY
                LDY #>GROUP_KEY
                PLA
                PHA
                JMP GET_IND_STRING

_EQUIP_IND_TO_TEXT						; was EQUIPR
				ASL
				ASL
				CLC
				ADC	#e1_HEAD
				TAY
_CEQUIP_TO_TEXT	LDX	#$00
:LOOP1			LDA	(CHARDL),Y
				STA	ETABLE,X
				INY
				INX
				CPX	#$04
				BNE	:LOOP1
_ETABLE_TO_TEXT							; was EQUIP1
				LDX	#$00
_ETABLE_TO_TEXT_X						; was EQUIP2, called by fight BLASTER.S
				TXA
				CLC
				ADC	#15
				STA	TRUNC_MOD+1
				LDA	ETABLE
				CMP	#$FF				; empty item
				BNE	EQUIP3
				JMP WORD_EXIT
EQUIP3			LDY	#$00
:LOOP1			LDA	ETABLE+0
				AND	#%00011111
				CMP	BLOCKS,Y
				BEQ	:SKIPA
				INY
				INY
				INY
				INY
				BNE	:LOOP1			;Always
				RTS
:SKIPA			LDA	BLOCKS+3,Y
				PHA
				LDA	BLOCKS+2,Y
				PHA
				LDA	BLOCKS+1,Y
				STY	ETEMP
				TAY
				AND	#$0F
				BIT	ETABLE+0
				BVC	GROUPER
				TYA
				LSR
				LSR
				LSR
				LSR
GROUPER			ASL
				TAY
				LDA	GROUPS,Y
				STA	POINTL
				LDA	GROUPS+1,Y
				STA	POINTH
				RTS

*** Type, Identified name group (high nibble),
*** Unidentified name group (low nibble), specific handler
*** The order of the first 7 groups should not be changed.

BLOCKS
				DB	$01,$98			;MEDICAL
				DW	MEDICAL-1

				DB	$02,$32			;SCANNERS
				DW	FROM_TABLE-1

				DB	$08,$71			;BEAM
				DW	FROM_TABLE-1

				DB	$0C,$01			;PISTOL
				DW	FROM_TABLE-1

				DB	$0D,$01			;RIFLE
				DW	FROM_TABLE-1

				DB	$0E,$01			;CANNON
				DW	FROM_TABLE-1

				DB	$0F,$D1			;MISC WEAP
				DW	FROM_TABLE-1

				DB	$00,$C2			;ATTACHMENTS
				DW	ATTACH-1

				DB	$03,$55			;MISC
				DW	MISC-1

				DB	$04,$44			;ARMOR
				DW	ARMOR-1

				DB	$05,$44			;HELMET
				DW	HELMET-1

				DB	$06,$44			;SHIELD
				DW	SHIELD-1

				DB	$07,$C2			;MISC PROTECT
				DW	MISCPRO-1

				DB	$18,$66			;ROBO BEAM
				DW	ROBEAM-1

				DB	$19,$66			;HAND ATTACHMENT
				DW	HANDATT-1

				DB	$1A,$66			;PROGRAM
				DW	PROGRAM-1

				DB	$1C,$66			;ROBO BLASTER
				DW	ROBLAST-1


GROUPS			DW	GROUP_BLAST		;0
				DW	UGROUP_WEAP		;1
				DW	UGROUP_SCAN		;2
				DW	GROUP_SCAN		;3
				DW	GROUP_ARMHELM	;4
				DW	GROUP_MISC		;5
				DW	GROUP_ROBO		;6
				DW	GROUP_BEAM		;7
				DW	UGROUP_MEDIC	;8
				DW	GROUP_MEDIC		;9
				DW	GROUP_ANTI		;A
				DW	GROUP_KEY		;B
				DW	GROUP_ATTACH	;C
				DW	GROUP_MSCWEAP	;D


MEDICAL			LDA	ETABLE+1
				AND	#%00001111
				CMP	#9
				BNE	:SKIPB
				LDY	#$F4			;/CAPSULE
				BIT	ETABLE+0
				BVC	:SKIPA
				LDA	#$0A			;GROUP_ANTI
				JSR	GROUPER
				LDY	#$F0			;/ANTI-
				JSR	WORD_SUB
				LDA	ETABLE+1
				AND	#%01110000
				CLC
				ADC	#$1F
				TAY
:SKIPA			JMP	WORD_SUB
:SKIPB			ORA	#$10
				JMP	TABLE_MERGE


FROM_TABLE		LDA	ETABLE+0
				ASL
				ASL
				ASL
				ASL
				EOR	ETABLE+1
				AND	#$F0
				EOR	ETABLE+1
TABLE_MERGE		PHA
				LDA	ETEMP
				LSR
				LSR
				TAY
				LDA	STARTS,Y
				TAY
				PLA
:LOOP1			CMP	IU_TABLE,Y
				BEQ	:SKIPA
				INY
				INY
				INY
				BNE	:LOOP1			;Always
:SKIPA			BIT	ETABLE+0
				BVS	:SKIPB
				INY
:SKIPB			LDA	IU_TABLE+1,Y
				TAY
				JMP	WORD_SUB

STARTS			DB	$00
				DB	BLOCK1-IU_TABLE
				DB	BLOCK2-IU_TABLE
				DB	BLOCK3-IU_TABLE
				DB	BLOCK4-IU_TABLE
				DB	BLOCK5-IU_TABLE
				DB	BLOCK6-IU_TABLE
				DB	BLOCK7-IU_TABLE

IU_TABLE
				DB	$10,$F1,$F5		;Diagnoser
				DB	$11,$F2,$F1		;Cell Regenerator
				DB	$12,$F3,$F2		;Circuit Repairer
				DB	$13,$F4,$F2		;Atom Compressor
				DB	$14,$F5,$F1		;Cauterizer
				DB	$16,$F6,$20		;Sight Restorer
				DB	$17,$F7,$F3		;Brain Equalizer
				DB	$18,$F8,$F1		;Drug Infusor
BLOCK1
				DB	$20,$01,$F7		;I. D. Scanner
				DB	$21,$F2,$F7		;Face Tracker
				DB	$22,$53,$F7		;Organic Detector
				DB	$23,$54,$F7		;Robotic Detector
				DB	$24,$F6,$F2		;Door Unlocker
				DB	$25,$F7,$50		;Vibration Sensor
BLOCK2
				DB	$80,$02,$53		;Blue Beam Dagger
				DB	$81,$03,$53		;Green Beam Daggr
				DB	$84,$12,$53		;Blue Beam Sword
				DB	$85,$13,$53		;Green Beam Sword
				DB	$86,$14,$53		;Red Beam Sword
				DB	$87,$15,$64		;Lasbeam Sword
				DB	$8B,$67,$54		;Laser Whip
BLOCK3
				DB	$C0,$60,$04		;Fly Pistol
				DB	$C1,$61,$04		;Light Pistol
				DB	$C2,$62,$04		;Medium Pistol
				DB	$C3,$63,$04		;Heavy Pistol
				DB	$C5,$65,$0C		;Ziffer's Pistol
BLOCK4
				DB	$D0,$71,$14		;Light Rifle
				DB	$D1,$72,$14		;Medium Rifle
				DB	$D3,$73,$14		;Heavy Rifle
				DB	$D5,$74,$1C		;Ultra Rifle
BLOCK5
				DB	$E0,$81,$17		;Light Cannon
				DB	$E1,$83,$17		;Heavy Cannon
BLOCK6
				DB	$F1,$F0,$B8		;Gyro Boomerang
				DB	$F4,$F1,$57		;Disintegrator
				DB	$F5,$F2,$09		;Daser
				DB	$F6,$F3,$BA		;Immobilizer
				DB	$F7,$F4,$BA		;Sonic Grenade
				DB	$F8,$F5,$0D		;Memory Eraser
BLOCK7


ATTACH			LDA	ETABLE+1
				AND	#%00000011
				ASL
				BPL	ATTMSCOM		;Always
MISCPRO			LDA	ETABLE+1
				AND	#%00000011
				ASL
				CLC
				ADC	#4
ATTMSCOM		TAY
				INY
				BIT	ETABLE+0
				BVC	:SKIPB
				DEY
				TYA
				BEQ	:SKIPA
				CMP	#6
				BNE	:SKIPB
:SKIPA			LDA	ETABLE+1
				AND	#%00011100
				LSR
				LSR
				STA	TEXTBUF,X
				INX
:SKIPB			LDA	ATTMSC_TBL,Y
				TAY
				JMP	WORD_SUB

ATTMSC_TBL		DB	$F0,$F1
				DB	$F2,$F2
				DB	$F3,$F3
				DB	$F1,$54
				DB	$FF,$FF
				DB	$F4,$F6

MISC			LDA	ETABLE+1
				AND	#%00000111
				CMP	#$02
				BEQ	:SKIPC
				CMP	#$01
				BNE	:SKIPA
				LDA	#$01
				LDY	ETABLE+1
				DEY
				BEQ	:SKIPA
				LDA	#$02
:SKIPA			ASL
				TAY
				BIT	ETABLE+0
				BVS	:SKIPB
				INY
:SKIPB			LDA	MISC_TABLE,Y
				TAY
				JMP	WORD_SUB
:SKIPC			LDA	#$0B			;GROUP_KEY
				JSR	GROUPER
				LDA	ETABLE+1
				AND	#%00111000
				LSR
				LSR
				LSR
				ORA	#$F0
				BIT	ETABLE+0
				BVC	:SKIPD
				CLC
				ADC	#$B5			; add KEY ($Fx->$Ax)
:SKIPD			TAY
				JMP	WORD_SUB

MISC_TABLE		DB	$09,$09			;Robot Controller
				DB	$F1,$53			;Muscle
				DB	$F2,$54			;Reflex
				DB	$F6,$F6			;Compressd person
				DB	$A7,$A7			;Data Card
				DB	$F8,$F8			;Junk


ARMOR			BIT	ETABLE+0
				BVS	:SKIPA
				LDY	#$58			;ARMOR/MECHANICAL
				BIT	ETABLE+2
				BMI	:SKIPD
				BPL	:SKIPC
:SKIPA			BIT	ETABLE+2
				PHP
				BPL	:SKIPB
				LDY	#$F9			;/SMART
				JSR	WORD_SUB
				LDA #TextSpace
				STA TEXTBUF,X
				INX
:SKIPB			LDA	ETABLE+1
				AND	#%00111000		;Brand
				LSR
				LSR
				LSR
				TAY
				LDA	ETABLE+1
				AND	#%00000111		;Class
				JSR	BRNDCLAS
				PLP
				BPL	:SKIPC
				RTS
:SKIPC			LDY	#$F5
:SKIPD			JMP	WORD_SUB


HELMET			BIT	ETABLE+0
				BVC	:SKIPA
				LDA	ETABLE+1
				AND	#%00001100		;Brand
				LSR
				LSR
				TAY
				INY
				LDA	ETABLE+1
				AND	#%00000011		;Class
				CLC
				ADC	#$02
				JSR	BRNDCLAS
:SKIPA			LDY	#$F6			;/HELMET
				JMP	WORD_SUB

BRNDCLAS		PHA
				TYA
				ORA	#$F0
				TAY
				JSR	WORD_SUB
				LDA	#TextDash
				STA	TEXTBUF,X
				INX
				PLA
				EOR	#$07
				CLC
				ADC	#$08
				STA	TEXTBUF,X
				INX
				LDA #TextSpace
				STA	TEXTBUF,X
				INX
				RTS


SHIELD			BIT	ETABLE+0
				BVC	:SKIPC
				LDA	ETABLE+1
				AND	#%00001111
				LSR
				PHP
				BNE	:SKIPA
				LDA	#TextSpace
:SKIPA			STA	TEXTBUF,X
				INX
				LDA	#$05
				PLP
				BCS	:SKIPB
				LDA	#$00
:SKIPB			STA	TEXTBUF,X
				INX
				LDA	#TextPercent
				STA	TEXTBUF,X
				INX
				LDA #TextSpace
				STA	TEXTBUF,X
				INX
:SKIPC			LDY	#$F7			;/FORCE_SHIELD
				JMP	WORD_SUB


ROBEAM			JSR	ROBO_SUB
				LDA	ETABLE+1
				LSR
				LSR
				CLC
				ADC	#$F7			;/DAGGER
				TAY
				JMP	WORD_SUB


HANDATT			LDY	#$43			;ATTACHMENT/HAND
				BIT	ETABLE+0
				BVS	:SKIPA
				LDY	#$35			;HAND/MECHANICAL
:SKIPA			JMP	WORD_SUB


PROGRAM			LDY	#$12			;CARD/PROGRAM
				JSR	WORD_SUB
				BIT	ETABLE+0
				BVC	:SKIPA
				INX
				LDA	ETABLE+1
				TAY
				AND	#%01111111
				LSR
				LSR
				LSR
				LSR
				BEQ	:SKIPA
				STA	TEXTBUF,X
				INX
:SKIPA			TYA
				AND	#%00001111
				STA	TEXTBUF,X
				INX
				TYA
				BPL	:SKIPB
				LDA	#TextA
				STA	TEXTBUF,X
				INX
:SKIPB			RTS


ROBLAST			JSR	ROBO_SUB
				LDY	#$F6			;/BLASTER
				JSR	WORD_SUB
				LDA #TextSpace
				STA TEXTBUF,X
				INX
				LDA	ETABLE+1
				AND	#%00000011
				EOR	#%00000011
				CLC
				ADC	#$0A
				STA	TEXTBUF,X
				INX
				LDA #TextLineEnd
				STA TEXTBUF,X
				RTS

ROBO_SUB		BIT	ETABLE+0
				BVC	:SKIPA
				LDY	#$F0			;/ROBOT
				JSR	WORD_SUB
				LDA	#TextDash
				STA	TEXTBUF-1,X
				RTS
:SKIPA			PLA
				PLA
				LDY	#$40			;ATTACHMENT/ROBOT

WORD_SUB		TYA
				PHA
				AND	#$0F
				PHA
				CMP	#$0F
				BEQ	:SKIPA
				JSR	:SUBA
:SKIPA			PLA
				TAY
				PLA
				LSR
				LSR
				LSR
				LSR
				CMP	#$0F
				BEQ	WORD_EXIT
				CPY	#$0F
				BEQ	:SUBA

				TAY
				LDA #TextSpace
				STA TEXTBUF,X
				INX
				TYA

:SUBA			STA	ETEMP
				LDY	#$FF
:LOOP1			INY
				DEC	ETEMP
				BMI	WORD_LOOP
:LOOP2			LDA	(POINTL),Y
				BMI	:LOOP1
				INY
				BNE	:LOOP2			;Always
WORD_LOOP		LDA	(POINTL),Y
				BMI	LAST_CHAR
				STA	TEXTBUF,X
				INY
TRUNC_MOD		CPX	#15					; modified
				BEQ	WORD_LOOP
				INX
				BNE	WORD_LOOP
LAST_CHAR		AND	#$7F
				STA	TEXTBUF,X
				INX
WORD_EXIT		LDA #TextLineEnd
				STA TEXTBUF,X
				RTS


GROUP_BLAST		TXI	"FLY" 					;*0          Group 0
				TXI	"LIGHT" 				;*1
				TXI	"MEDIUM" 				;*2
				TXI	"HEAVY" 				;*3
				TXI	"ULTRA" 				;*4
				TXI	"ZIFFER'S"       		;*5
UGROUP_WEAP		TXI	"PISTOL" 				;*6 *0       Group 1
				TXI	"RIFLE" 				;*7 *1
				TXI	"CANNON" 				;*8 *2
				TXI	"BEAM" 					;   *3
				TXI	"LASER" 				;   *4
				TXI	"WEAPON" 				;   *5
				TXI	"SWORD" 				;   *6
				TXI	"SHOULDER" 				;   *7
				TXI	"CURVED" 				;   *8
				TXI	"SMALL" 				;   *9
				TXI	"THROWABLE" 			;   *A
				TXI	"OBJECT" 				;   *B
				TXI	"LARGE" 				;   *C
UGROUP_SCAN		TXI	"ELECTRONIC" 			;*0 *D       Group 2
				TXI	"METAL_ROD" 			;*1
				TXI	"GADGET" 				;*2
				TXI	"VISOR" 				;*3
				TXI	"RUBBERY" 				;*4
				TXI	"BOOTS" 				;*5
				TXI	"STRANGE_ARMOR" 		;*6
GROUP_SCAN		TXI	"SCANNER" 				;*7 *0       Group 3
				TXI	"I.D." 					;   *1
				TXI	"FACE_TRACKER" 			;   *2
				TXI	"ORGANIC" 				;   *3
				TXI	"ROBOTIC" 				;   *4
				TXI	"DETECTOR" 				;   *5
				TXI	"DOOR_UNLOCKER" 		;   *6
				TXI	"VIBRATION_SENSOR" 		;   *7

GROUP_ARMHELM	TXI	"CLEAR" 				;*0          Group 4
				TXI	"BENDER" 				;*1
				TXI	"MIRAGE" 				;*2
				TXI	"IMAGE" 				;*3
				TXI	"MIRROR" 				;*4
				TXI	"ARMOR" 				;*5
				TXI	"HELMET" 				;*6
				TXI	"FORCE_SHIELD" 			;*7
				TXI	"MECHANICAL" 			;*8
				TXI	"SMART" 				;*9

GROUP_MISC		TXI	"CONTROLLER" 			;   *0       Group 5
				TXI	"MUSCLE" 				;   *1
				TXI	"REFLEX" 				;   *2
				TXI	"MAROON" 				;   *3
				TXI	"SILVER" 				;   *4
				TXI	"POWDER" 				;   *5
				TXI	"COMPRESSD_PERSON" 		;   *6
				TXI	"DATA" 					;   *7
				TXI	"JUNK" 					;   *8
GROUP_ROBO		TXI	"ROBOT" 				;*0 *9       Group 6
				TXI	"CARD" 					;*1 *A
				TXI	"PROGRAM" 				;*2
				TXI	"HAND" 					;*3
				TXI	"ATTACHMENT" 			;*4
				TXI	"MECHANICAL" 			;*5
				TXI	"BLASTER" 				;*6
GROUP_BEAM		TXI	"DAGGER" 				;*7 *0       Group 7
				TXI	"SWORD" 				;*8 *1
				TXI	"BLUE_BEAM" 			;   *2
				TXI	"GREEN_BEAM" 			;   *3
				TXI	"RED_BEAM" 				;   *4
				TXI	"LASBEAM" 				;   *5
				TXI	"WHIP" 					;   *6
UGROUP_MEDIC	TXI	"LASER" 				;   *7 *0    Group 8
				TXI	"MEDICAL_DEVICE" 		;      *1
				TXI	"GADGET" 				;      *2
				TXI	"HEAD_GEAR" 			;      *3
GROUP_MEDIC		TXI	"CAPSULE" 				;*0    *4    Group 9
				TXI	"DIAGNOSER" 			;*1    *5
				TXI	"CELL_REGENERATOR" 		;*2
				TXI	"CIRCUIT_REPAIRER" 		;*3
				TXI	"ATOM_COMPRESSOR" 		;*4
				TXI	"CAUTERIZER" 			;*5
				TXI	"SIGHT_RESTORER" 		;*6
				TXI	"BRAIN_EQUALIZER" 		;*7
				TXI	"DRUG_INFUSOR" 			;*8

GROUP_ANTI		TXI	"ANTI-" 				;*0          Group A
				TXI	"POISON" 				;*1
				TXI	"FUNGUS" 				;*2
				TXI	"PARASITE" 				;*3
				TXI	"VIRUS" 				;*4
				TXI	"BACTERIA" 				;*5
				TXI	"PENGUIN" 				;*6

;*** NOTE: also referenced indirectly by KEY.DOOR.S
GROUP_KEY		TXI	"WHITE_SAND" 			;*0          Group B
				TXI	"HEAVY_STONE" 			;*1
				TXI	"CHANGING_CRYSTAL" 		;*2
				TXI	"PLASTEEL_CIRCUIT" 		;*3
				TXI	"PETRIFIED_LEAF" 		;*4

; TODO: change these back once there's a way for
;	the player to know them at key door time
;				TXI	"TERRAN" 				;*5
;				TXI	"TOUHTAAN" 				;*6
;				TXI	"ZINAN" 				;*7
;				TXI	"!!!" 					;*8
;				TXI	"GILLOITAN" 			;*9
				TXI "EARTH" 				;*5
				TXI "ORN" 					;*6
				TXI "STILICX" 				;*7
				TXI "XXTYS" 				;*8
				TXI "DENEB" 				;*9

				TXI	"KEY" 					;*A

GROUP_ATTACH	TXI	"%_DISSIPATOR" 			;*0          Group C
				TXI	"%_GROUNDERS" 			;*1
				TXI	"IMAGE_GENERATOR" 		;*2
				TXI	"BLAST_VISOR" 			;*3
				TXI	"EXOSKELETON" 			;*4

GROUP_MSCWEAP	TXI	"GYRO_BOOMERANG" 		;*0          Group D
				TXI	"DISINTEGRATOR" 		;*1
				TXI	"BRAIN_JAMMER" 			;*2
				TXI	"IMMOBILIZER" 			;*3
				TXI	"SONIC_GRENADE" 		;*4
				TXI	"ROBOT_RESTRAINER" 		;*5
