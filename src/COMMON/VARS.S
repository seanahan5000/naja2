
                EXP OFF

SAME_PAGE_AS    MAC
                ERR >(*-1!]1)
                EOM

Text0           =   0
Text1           =   1
Text9           =   9
TextSpace       =   10
TextA           =   11
TextZ           =   36
TextFirstSymbol =   37              ; first symbol after {0-9 A-Z}
TextPercent     =   $27
TextDash        =   $2C
TextPeriod      =   $2D
TextSlash       =   $2E
TextColon       =   $2F
TextLT          =   $30
TextGT          =   $32
TextQuestion    =   $33
TextEmpty       =   $EE
TextLineBreak   =   $8B
TextLineEnd     =   $8D

TextLineHeight  =   9

TEXT_BUFFER     =   $0200
TEXTBUF         =   TEXT_BUFFER     ; for back-compat
WORD_BUFFER     =   TEXT_BUFFER+$A0

SCREENL         =   $26
SCREENH         =   $27
DESTINL         =   $28
DESTINH         =   $29

; UNPACK.S uses $30-$3F
; TEXT.S uses $31-$33

; TODO: pick a safe/permanent range
SEED0           =   $40
SEED1           =   $41

XCOORD          =   $48
XSHIFT          =   $49
YCOORD          =   $4A

;*** shape drawing
XCOUNT          =   $4B
YCOUNT          =   $4C
DATPNTL         =   $4D
DATPNTH         =   $4E
;*** shape drawing

; PICT.S uses $50-$5F

; TODO: conflict here?

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

ETABLE          =   $9C         ; $9C,$9D,$9E,$9F

; TODO: eventually move these down to $00-$03
LOCAL_TEMP      =   $70         ; $70,$71,$72,$73

; NDOS.525 uses $B0-$BF

; TODO: does this need to be exposed to callers?
COLOR           =   $E4
PAGE            =   $E6

; HALLS use $F0-$F7
; TODO: move contents of HALLS/VARS.S here

SCRATCH_PAGE    =   $BA00       ; TODO: place somewhere else

                DUMMY $BB00

MAP_VISITED     DS  217

                DS 39

KNOWN_ALIENS_12  DS 9           ; 72 bits
KNOWN_ALIENS_345 DS 9           ; 65 of 72 bits
KNOWN_ALIENS_END

ENCOUNTER_SPAWNS DS 20          ; 5 shells * 4 bytes

                DS  87

LOST_CHARS      DS  1           ; $BC7D
GRPCONT         DS  1           ; $BC7E ; number of characters, including dead/compressed?
GRPNUMB         DS  1           ; $BC7F ; number of living characters in group

CHAR_0          DS  $80         ; $BC80
CHAR_1          DS  $80
CHAR_2          DS  $80
CHAR_3          DS  $80
CHAR_4          DS  $80
CHAR_5          DS  $80
CHAR_6          DS  $80
                DEND

GROUP_SIZE      =   GRPNUMB
; TODO: move these character-only vars

KEYBRD          =   $C000
UNSTROB         =   $C010
CLICK           =   $C030
GRAPHICS        =   $C050
NOMIXED         =   $C052
PRIMARY         =   $C054
SCNDARY         =   $C055
HIRES           =   $C057
PBUTTON0        =   $C061               ; open-apple

OpSetColor      =   0
OpMoveTo        =   1
OpMoveToHigh    =   2
OpHMoveTo       =   3
OpHMoveToHigh   =   4
OpVMoveTo       =   5
OpVMove         =   6
OpHLineTo       =   7
OpHLineToHigh   =   8
OpVLineTo       =   9
OpRect          =   10
OpRectHigh      =   11
OpFillRect      =   12
OpFillRectHigh  =   13
OpSetTextHeight =   14
OpSetTextBox    =   15
OpSetTextBoxHigh =  16
OpText          =   17
OpTextAt        =   18
OpTextIn        =   19
OpImage         =   20
OpImageFill     =   21
OpClear         =   22
OpCopyTo        =   23
OpSwap          =   24

OpSetPage1      =   25
OpSetPage2      =   26
OpShowPage      =   27
OpClearPage     =   28
OpCopyToPage    =   29
OpCall          =   30

OpEnd           =   $FF

OpColorBlack1   =   0
OpColorGreen    =   1
OpColorViolet   =   2
OpColorWhite1   =   3
OpColorBlack2   =   4
OpColorOrange   =   5
OpColorBlue     =   6
OpColorWhite2   =   7

PictSetBlack1   MAC
                DB  OpSetColor,OpColorBlack1
                EOM

PictSetGreen    MAC
                DB  OpSetColor,OpColorGreen
                EOM

PictSetViolet   MAC
                DB  OpSetColor,OpColorViolet
                EOM

PictSetWhite1   MAC
                DB  OpSetColor,OpColorWhite1
                EOM

PictSetBlack2   MAC
                DB  OpSetColor,OpColorBlack2
                EOM

PictSetOrange   MAC
                DB  OpSetColor,OpColorOrange
                EOM

PictSetBlue     MAC
                DB  OpSetColor,OpColorBlue
                EOM

PictSetWhite2   MAC
                DB  OpSetColor,OpColorWhite2
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
            DO ]1/256
                DB  OpMoveToHigh,<]1,]2
            ELSE
                DB  OpMoveTo,]1,]2
            FIN
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

PictFillRect    MAC
            DO ]3/256
                DB  OpFillRectHigh
            ELSE
                DB  OpFillRect
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

PictImageFill   MAC
                DB  OpImageFill
                DW  ]1
                EOM

; NOTE: external dependencies on this format
PictClear       MAC
                DB  OpClear
                DB  ]1,]2,]3,]4
                EOM

PictCopyTo      MAC
                DB  OpCopyTo
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

PictShowPage    MAC
                DB  OpShowPage
                EOM

PictClearPage   MAC
                DB  OpClearPage
                EOM

PictCopyToPage  MAC
                DB  OpCopyToPage
                EOM

PictCall        MAC
                DB  OpCall
                DW  ]1
                EOM

PictEnd         MAC
                DB  OpEnd
                EOM
