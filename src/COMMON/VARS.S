
                EXP OFF

SAME_PAGE_AS    MAC
                ERR >(*-1!]1)
                EOM

Char0           =   0
Char9           =   9
CharSpace       =   10
CharA           =   11
CharZ           =   36
CharFirstSymbol =   37              ; first symbol after {0-9 A-Z}
CharSlash       =   $2E
CharEmpty       =   $EE
CharLineBreak   =   $8B
CharLineEnd     =   $8D
CharInsert      =   $C0
CharInsertMask  =   $3F

LineHeight      =   9

TEXT_BUFFER     =   $0200
TEXTBUF         =   TEXT_BUFFER     ; for back-compat
WORD_BUFFER     =   TEXT_BUFFER+$A0
INSERT_BUFFER   =   TEXT_BUFFER+$C0

SCREENL         =   $26
SCREENH         =   $27

; UNPACK.S uses $30-$3F
; TEXT.S uses $31-$33

; TODO: pick a safe/permanent range
SEED0           =   $40
SEED1           =   $41

XCOORD          =   $48
XSHIFT          =   $49
YCOORD          =   $4A


; TODO: move these character-only vars
SELECT          =   $90         ; only used in STATS.S -- get rid of
CHARDL          =   $91
CHARDH          =   $92
CHAR_INDEX      =   $97

LOST_CHARS      =   $BC7D
GRPCONT         =   $BC7E       ; number of characters, including dead/compressed?
GRPNUMB         =   $BC7F       ; number of living characters in group

GROUP_SIZE      =   GRPNUMB
; TODO: move these character-only vars


;*** shape drawing
XCOUNT          =   $4B
YCOUNT          =   $4C
DATPNTL         =   $4D
DATPNTH         =   $4E
;*** shape drawing

; PICT.S uses $50-$5F

; TODO: eventually move these down to $00-$03
LOCAL_TEMP      =   $70         ; $70,$71,$72,$73

; TODO: does this need to be exposed to callers?
PAGE            =   $E6

KEYBRD          =   $C000
UNSTROB         =   $C010
CLICK           =   $C030
GRAPHICS        =   $C050
NOMIXED         =   $C052
PRIMARY         =   $C054
SCNDARY         =   $C055
HIRES           =   $C057

; BLACK1          =   $00
; WHITE1          =   $7F


OpSetColor      =   0
OpMoveTo        =   1
OpHMoveTo       =   2
OpVMoveTo       =   3
OpVMove         =   4
OpHLineTo       =   5
OpHLineToHigh   =   6
OpVLineTo       =   7
OpRect          =   8
OpRectHigh      =   9
OpSetTextHeight =   10
OpSetTextBox    =   11
OpSetTextBoxHigh =  12
OpText          =   13
OpTextAt        =   14
OpTextIn        =   15
OpImage         =   16
OpClear         =   17
OpEnd           =   $FF

; TODO: OpCall to insert function calls mid-picture

OpColorBlack1   =   0
OpColorGreen    =   1
OpColorViolet   =   2
OpColorWhite1   =   3
OpColorBlack2   =   4
OpColorOrange   =   5
OpColorBlue     =   6
OpColorWhite2   =   7

;*** SEPARATE OPCODE/SINGLE BYTE FOR EACH OF THESE ***
PictSetBlack1   MAC
                DB  OpSetColor,OpColorBlack1
                EOM

PictSetGreen    MAC
                DB  OpSetColor,OpColorGreen
                EOM

PictSetViolet   MAC
                DB  OpSetColor,OpColorViolet
                EOM

PictSetOrange   MAC
                DB  OpSetColor,OpColorOrange
                EOM

PictSetBlue     MAC
                DB  OpSetColor,OpColorBlue
                EOM

PictHMoveTo     MAC
                DB  OpHMoveTo,]1
]X              =   ]1
                EOM

PictVMoveTo     MAC
                DB  OpVMoveTo,]1
]Y              =   ]1
                EOM

PictVMove       MAC
                DB  OpVMove,]1
]Y              =   0
                EOM

PictMoveTo      MAC
                DB  OpMoveTo,]1,]2
]X              =   ]1
]Y              =   ]2
                EOM

PictLineTo      MAC
        DO ]1-]X
            DO ]1/256
                DB  OpHLineToHigh,<]1
            ELSE
                DB  OpHLineTo,<]1
            FIN
            ERR ]2-]Y
]X              =   ]1
        ELSE
                DB  OpVLineTo,]2
]Y              =   ]2
        FIN
                EOM

PictRect        MAC
            DO ]3/256
                DB  OpRectHigh
            ELSE
                DB  OpRect
            FIN
                DB  ]1,]2,<]3,]4
                EOM

PictSetTextHeight MAC
                DB  OpSetTextHeight
                DB ]1
                EOM

PictSetTextBox  MAC
            DO ]3/256
                DB  OpSetTextBoxHigh
            ELSE
                DB  OpSetTextBox
            FIN
                DB  ]1,]2,<]3,]4
]X              =   ]1
]Y              =   ]2
                EOM

PictText        MAC
                DB  OpText
                USR ]1
                EOM

PictTextAt      MAC
                DB  OpTextAt
                DB  ]1,]2
                USR ]3
]X              =   ]1
]Y              =   ]2
                EOM

PictTextIn      MAC
                DB  OpTextIn
                USR ]1
                EOM

PictImage       MAC
                DB  OpImage
                DW  ]1
                EOM

; NOTE: external dependencies on this format
PictClear       MAC
                DB  OpClear
                DB  ]1,]2,]3,]4
                EOM

PictEnd         MAC
                DB  OpEnd
                EOM
