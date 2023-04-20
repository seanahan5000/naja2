
smartXfrontCaps =   1           ; if 0, use classic flat caps
                                ; if 1, use corner caps
farLeftRightCaps =  1           ; if 1, also use open caps

useXLines       =   1

; hall constants
BUFFER_WIDTH    =   2
XYDATA_SIZE     =   $32         ; 50 bytes per depth

; for map scanning only
DATA_LEFT       =   $01
DATA_CENTER     =   $02
DATA_RIGHT      =   $03
        do farLeftRightCaps
DATA_FARLEFT    =   $04
DATA_FARRIGHT   =   $05
        fin
TEMP_PTR        =   $06
TEMP_PTR_H      =   $07
DATA_TEMP1      =   $08
DATA_TEMP2      =   $09

; for hall scanning and drawing
BLOCK_COUNT     =   $66

; for hall drawing only
BLOCK_INDEX     =   $67
BLOCK_DATA      =   $68
CUR_DEPTH       =   $69
; RANGE           =   $F7

XYDATAL         =   $0D
XYDATAH         =   $0E

; line drawing zpage
HMASK           =   $51
DY              =   $52
QDRNT           =   $53         ; not used for thin line drawing
DY_OPCODE       =   $53         ; same as QDRNT
EL              =   $54
EH              =   $55
DXL             =   $56
DXH             =   $57
HNDX            =   $58
CLIP_SKIP       =   $59
YO              =   $5A
XOL             =   $5B
XOH             =   $5C
YCRD            =   $5D
CLIP_ENABLE     =   $5E
LAST_X          =   $5F

; for line drawing
; TODO: pick different range
LINE_SIDE       =   $60
LINE_PTR        =   $61
LINE_PTRH       =   $62
LINE_INDEX      =   $63
LINE_MOVE       =   $64
LINES_CLIPPED   =   $65

; external zpage

COUNTL          =   $1C             ; TODO: briefly used -- consider PHA/PLA
COUNTH          =   $1D

; SCREENL         =   $26
; SCREENH         =   $27

; COLOR           =   $E4

; PAGE            =   $E6

; KEYBRD          =   $C000
; UNSTROB         =   $C010
; CLICK           =   $C030
; GRAPHICS        =   $C050
; NOMIXED         =   $C052
; PRIMARY         =   $C054
; SCNDARY         =   $C055
; HIRES           =   $C057

BLACK1          =   $00
WHITE1          =   $7F

; coordinate constants

ORD_A           =   $00
ORD_B           =   $01
ORD_C           =   $02
ORD_D           =   $03
ORD_E           =   $04
ORD_F           =   $05
ORD_G           =   $06
ORD_H           =   $07
ORD_I           =   $08
ORD_J           =   $09
ORD_K           =   $0A
ORD_L           =   $0B
ORD_M           =   $0C
ORD_N           =   $0D
ORD_O           =   $0E
ORD_P           =   $0F
ORD_Q           =   $10
ORD_R           =   $11
ORD_S           =   $12
ORD_T           =   $13
ORD_U           =   $14
ORD_V           =   $15
ORD_AA          =   $16
ORD_BB          =   $17
ORD_CC          =   $18
ORD_DD          =   $19
ORD_EE          =   $1A
ORD_FF          =   $1B
ORD_GG          =   $1C
ORD_HH          =   $1D
ORD_II          =   $1E
ORD_JJ          =   $1F
ORD_KK          =   $20
ORD_LL          =   $21
ORD_MM          =   $22
ORD_NN          =   $23
ORD_OO          =   $24
ORD_PP          =   $25
ORD_QQ          =   $26
ORD_RR          =   $27
ORD_SS          =   $28
ORD_TT          =   $29
ORD_UU          =   $2A
ORD_VV          =   $2B
ORD_FC0         =   $2C
ORD_FC1         =   $2D
ORD_FC2         =   $2E
ORD_FC3         =   $2F
ORD_FC4         =   $30
ORD_FC5         =   $31

ORD_STOP        =   $80
ORD_MOVE        =   $81
ORD_FLIP        =   $82
ORD_INC         =   $83
ORD_DEC         =   $84
ORD_CLIP        =   $85             ; must be last of special ORDs
