
                EXP OFF

SAME_PAGE_AS    MAC
                ERR >(*-1!]1)
                EOM

Text0           =   0
Text9           =   9
TextSpace       =   10
TextA           =   11
TextZ           =   36
TextFirstSymbol =   37              ; first symbol after {0-9 A-Z}
TextSlash       =   $2E
TextColon       =   $2F
TextEmpty       =   $EE
TextLineBreak   =   $8B
TextLineEnd     =   $8D
TextInsert      =   $C0
TextInsertMask  =   $3F

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

; HALLS use $50-$5F
; HALLS use $60-$6A

; TODO: move these character-only vars
SELECT          =   $90         ; only used in STATS.S -- get rid of
CHARDL          =   $91
CHARDH          =   $92
XPNT            =   $93
YPNT            =   $94
CURSOR          =   $95
COUNT           =   $96
SELECT_FLIP     =   $96         ; only used in T.CAMP.S when flipping stats
CHAR_INDEX      =   $97

SCRATCH_PAGE    =   $BB00       ; TODO: place somewhere else

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
COLOR           =   $E4
PAGE            =   $E6

; HALLS use $F0-$F7

KEYBRD          =   $C000
UNSTROB         =   $C010
CLICK           =   $C030
GRAPHICS        =   $C050
NOMIXED         =   $C052
PRIMARY         =   $C054
SCNDARY         =   $C055
HIRES           =   $C057

OpSetColor      =   0
OpMoveTo        =   1
OpHMoveTo       =   2
OpHMoveToHigh   =   3
OpVMoveTo       =   4
OpVMove         =   5
OpHLineTo       =   6
OpHLineToHigh   =   7
OpVLineTo       =   8
OpRect          =   9
OpRectHigh      =   10
OpSetTextHeight =   11
OpSetTextBox    =   12
OpSetTextBoxHigh =  13
OpText          =   14
OpTextAt        =   15
OpTextIn        =   16
OpImage         =   17
OpClear         =   18
OpSwap          =   19

OpSetPage1      =   20
OpSetPage2      =   21
OpShowPage1     =   22
OpShowPage2     =   23
OpClearPage     =   24
OpCopyToPage1   =   25
OpCall          =   26

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
            DO ]1/256
                DB  OpHMoveToHigh,<]1
            ELSE
                DB  OpHMoveTo,<]1
            FIN
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

PictSwap        MAC
                DB  OpSwap
                DB  ]1,]2,]3,]4
                EOM

PictSetPage1    MAC
                DB  OpSetPage1
                EOM

PictSetPage2    MAC
                DB  OpSetPage2
                EOM

PictShowPage1   MAC
                DB  OpShowPage1
                EOM

PictShowPage2   MAC
                DB  OpShowPage2
                EOM

PictClearPage   MAC
                DB  OpClearPage
                EOM

PictCopyToPage1 MAC
                DB  OpCopyToPage1
                EOM

PictCall        MAC
                DB  OpCall
                DW  ]1
                EOM

PictEnd         MAC
                DB  OpEnd
                EOM
