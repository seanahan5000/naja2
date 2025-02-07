
ORIGINAL		=	1
DEBUG_KEYS		=	1				; enable debug features tied to alt/option keys
SMALL_GROUP     =   1
NAME_FIRST      =   1
MINI_CAMP       =   0

human			=	0
orn				=	1
stilicx			=	2
xxtys			=	3
deneb			=	4
none			=	9

warrior			=	0
android			=	1
cybernate		=	2
juicer			=	3
physician		=	4
mutant			=	5
electromedic	=	6
genius			=	7
robot			=	8               ; assumed to be high bit in profrace

healthy			=	$00				;00 00 0000
dead			=	$01				;00 00 0001
abandoned		=	$02				;00 00 0010
broken			=	$03				;00 00 0011
intracc			=	$04				;00 00 0100
compressd		=	$05				;00 00 0101
inlimbo			=	$06				;00 00 0110
lost			=	$07				;00 00 0111
corroding		=	$10				;00 01 0000
poisoned		=	$11				;00 01 0001
bleeding		=	$12				;00 01 0010
radiated		=	$13				;00 01 0011
illA			=	$14				;00 01 0100
illB			=	$15				;00 01 0101
illC			=	$16				;00 01 0110
illD			=	$17				;00 01 0111
blind			=	$18				;00 01 1000
confused		=	$19				;00 01 1001
smotherin		=	$20				;00 10 0000
fast			=	$21				;00 10 0001
strong			=	$22				;00 10 0010
slipping		=	$24				;00 10 0100
numb			=	$25				;00 10 0101
ranaway			=	$2F				;00 10 1111
onfire			=	$38				;00 11 1000
dizzy			=	$39				;00 11 1001
stunned			=	$3A				;00 11 1010
immobile		=	$3B				;00 11 1011
controlld		=	$3C				;00 11 1100
choking			=	$3D				;00 11 1101
critical		=	$40				;01 00 0000
rundown			=	$80				;10 00 0000

critical_amnt	=	5				;Damage at which char. goes critical
illDlength		=	15				;Number of inflictions of illD

*** Used in BOX.COMMONS
notchless		=	%00000000
wspace			=	%10000000
wyesno			=	%11000000

charNameLength  =   10

*** For character data tables
name			=	$00
status			=	$0A
level			=	$0B                 ; TODO: trim to 1 byte
profrace		=	$0D
experience		=	$0E                 ; TODO: trim to 3 bytes
*
credits			=	$13                 ; TODO: trim to 3 bytes, move to common state
strength		=	$17
upreflex		=	$18
lwreflex		=	$19
intelligence	=	$1A
Eshielding		=	$1B
Pshielding		=	$1C
back			=	$1D
position		=	$1E
damagelev		=	$1F
damagemax		=	$21
organic			=	$23
energylev		=	$24
energymax		=	$27
powerconsumpt	=	$2A
*

; 1000.iiii
;   i: roster index
; $00: undefined/unused
rosterLocation  =   $2D
roboCyberLink 	=	$2E

disklocation	=	$2D                ;*** phase this out
robotcyblink	=	$2E                ;*** phase this out

powerfraction	=	$2F
basepowercons	=	$31
baseshielding	=	$33
e1_HEAD			=	$35
e2_SLOT			=	$39
e3_UPLFT		=	$3D
e4_UPRGT		=	$41
e5_LWLFT		=	$45
e6_LWRGT		=	$49
e7_BACK1		=	$4D
e8_BACK2		=	$51
e9_BACK3		=	$55
e10_BACK4		=	$59
e11_BACK5		=	$5D
e12_BACK6		=	$61
e13_ARMOR		=	$65
e14_FEET		=	$69
e15_PROGRAM		=	$6D
e16_UNUSED		=	$71
inflictcount	=	$75
inflictdelay	=	$76
inflictamount	=	$77
inflictnums		=	$78
basestrength	=	$79
baseupreflex	=	$7A
baselwreflex	=	$7B
baseintellig	=	$7C
*
flaglimbo		=	$7E
;  igg000xx
;   i: implant
;   g: gender
;   x: something used in INFIRMARY:power
miscflags		=	$7F

e3_ROBLFT		=	e3_UPLFT
e4_ROBLWITH		=	e4_UPRGT
e5_ROBRGT		=	e5_LWLFT
e6_ROBRWITH		=	e6_LWRGT

*** For ESCAN routines
head			=	0
slot			=	1
back1			=	2
back2			=	3
back3			=	4
back4			=	5
back5			=	6
back6			=	7
uplft			=	8
uprgt			=	9
lwlft			=	10
lwrgt			=	11
armor			=	12
feet			=	13
program			=	14
unused			=	15
roblft			=	uplft
roblwith		=	uprgt
robrgt			=	lwlft
robrwith		=	lwrgt


*** For equipment data
eq_broken		=	%10000000
eq_identified	=	%01000000
eq_usable		=	%00100000

*** THESE HAVE BEEN CHANGED
eq_usesenergy	=	%01000000
eq_undropable	=	%00100000
eq_vital		=	%00010000
eq_open2		=	%00001000		;***
eq_stateffect	=	%00000100
eq_faulty		=	%00000010
eq_hands12		=	%00000001

side_MS         =   0
side_F1         =   1
side_T1         =   2
side_T2         =   3

; charTrack		=	$0100		;Track/Sector for character data


statsXY         =   %10000000           ; TODO: get rid of this
statsShielding  =   %01000000
statsDamage     =   %00000010
statsStatus     =   %00000001

; fight narration delay time
defaultDelayTime      = $25

; TODO: move these into separate file

fileAlienPics12  =  $10
fileAlienDesc12  =  $11
fileAlienData12  =  $12

fileAlienPics345 =  $20
fileAlienDesc345 =  $21
fileAlienData345 =  $22

fileDiagnose    =   $30
fileAlienId     =   $31

; NOTE: must be consecutive in this order
fileControlMS   =   $32
fileControl17   =   $33
fileControl15   =   $34
fileControl13   =   $35
fileControl11   =   $36
fileControl9    =   $37

fileFightLoader1      = $38

fileFightLoader2      = $40
fileFightShared       = $41
fileFightCommand      = $42
fileFightNarrator     = $43
fileFightHalls        = $44
fileFightAwarder      = $45
fileDeadGroup         = $46
fileReformat          = $47

fileMap               = $50
fileElevator          = $51
fileViewport          = $52
fileRuuik             = $53
filePrisoner          = $54
fileKeyCrystal        = $55
fileKeySand           = $56

fileKeyDoor           = $60

fileTesserport        = $6E
fileGuard             = $6F
fileDeleteChar        = $70
fileInfoSeller        = $71
fileEnroll_Load       = $72
fileEntest_Control    = $73
fileEntest_Enroll     = $74
fileEntest_Test       = $75
fileAssembly_Load     = $76
fileAssembly_Control  = $77
fileInfirmary_Load    = $78
fileInfirmary_Control = $79
fileEnergy_Load       = $7A
fileEnergy_Control    = $7B
fileArsenal_Load      = $7C
fileArsenal_Control   = $7D
fileRobotRep_Load     = $7E
fileRobotRep_Control  = $7F

fileSaveGame          = $80

fileGraphics          = $B0
fileCampE000          = $B1
fileCampD000_1        = $B2
fileCampD000_2        = $B3
fileTitle             = $B4
fileHalls             = $B5
