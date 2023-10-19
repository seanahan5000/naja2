
                EXP OFF

SAME_PAGE_AS    MAC
                ERR >(*-1!]1)
                EOM

Text0           =   0
Text1           =   1
Text9           =   9
TextSpace       =   10
TextA           =   11
TextS           =   29
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

; TODO: eventually move these down to $00-$07
LOCAL_TEMP      =   $70         ; $70,$71,$72,$73
LINENUM         =   $74
COLUMN          =   $75
COUNTER         =   $76
SCRATCH         =   $77

; TODO: move these character-only vars
SELECT          =   $90         ; only used in STATS.S -- get rid of
CHARDL          =   $91
CHARDH          =   $92
XPNT            =   $93         ; TODO: phase out
YPNT            =   $94         ; TODO: phase out
CURSOR          =   $95
COUNT           =   $96
SELECT_FLIP     =   $96         ; only used in T.CAMP.S when flipping stats
CHAR_INDEX      =   $97

ETABLE          =   $9C         ; $9C,$9D,$9E,$9F

; NDOS.525 uses $B0-$BF
; CAMP uses $C0-$CF

; TODO: does this need to be exposed to callers?
COLOR           =   $E4
PAGE            =   $E6

; HALLS use $F0-$F8
; TODO: move contents of HALLS/VARS.S here

SCRATCH_PAGE    =   $B900       ; TODO: place somewhere else

                DUMMY $BA00

MAP_VISITED_17  DS  217
                DS  39
MAP_VISITED_15  DS  169
MAP_VISITED_13  DS  127
MAP_VISITED_11  DS  91
MAP_VISITED_9   DS  61

KNOWN_ALIENS_12  DS 9           ; 72 bits
KNOWN_ALIENS_345 DS 9           ; 65 of 72 bits
KNOWN_ALIENS_END

ENCOUNTER_SPAWNS DS 20          ; 5 shells * 4 bytes

ORBS_FOUND                      ; TODO: get rid of this
KEYS_FOUND      DS  1
KEY_DOOR_BITS   DS  1           ; a000bbbb - a open status, b order bits

                DS  9

KILLS           DS  4           ; expedition totals (assumed sequential)
CREDITS         DS  4
EXPERIENCE      DS  4

LOST_CHARS      DS  1           ; $BCFD
GRPCONT         DS  1           ; $BCFE ; number of characters, including dead/compressed?
GRPNUMB         DS  1           ; $BCFF ; number of living characters in group

                ERR $BD00-*
CHAR_0          DS  $80
CHAR_1          DS  $80
CHAR_2          DS  $80
CHAR_3          DS  $80
CHAR_4          DS  $80
CHAR_5          DS  $80
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
OpMove          =   1
OpMoveTo        =   2
OpMoveToHigh    =   3
OpHMove         =   4
OpHMoveTo       =   5
OpHMoveToHigh   =   6
OpVMove         =   7
OpVMoveTo       =   8
OpHLineTo       =   9
OpHLineToHigh   =   10
OpVLineTo       =   11
OpHSave         =   12
OpHRestore      =   13
OpRect          =   14
OpRectHigh      =   15
OpFillRect      =   16
OpFillRectHigh  =   17
OpSetTextHeight =   18
OpSetTextBox    =   19
OpSetTextBoxHigh =  20
OpText          =   21
OpTextAt        =   22
OpTextIn        =   23
OpTextbuf       =   24
OpTextbufRet    =   25
OpImage         =   26
OpImageFill     =   27
OpTile          =   28
OpClear         =   29
OpCopyTo        =   30
OpSwap          =   31

OpSetPage1      =   32
OpSetPage2      =   33
OpSetPageX      =   34
OpShowPage      =   35
OpClearPage     =   36
OpCopyToPage    =   37
OpCall          =   38

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

PictMove        MAC
                DB  OpMove,]1,]2
]X              =   0
]Y              =   0
                EOM

PictHMove       MAC
                DB  OpHMove,]1
]Y              =   0
                EOM

PictHMoveTo     MAC
            DO ]1/256
                DB  OpHMoveToHigh,<]1
            ELSE
                DB  OpHMoveTo,<]1
            FIN
]X              =   ]1
                EOM

PictVMove       MAC
                DB  OpVMove,]1
]Y              =   0
                EOM

PictVMoveTo     MAC
                DB  OpVMoveTo,]1
]Y              =   ]1
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

PictHLineTo     MAC
            DO ]1/256
                DB  OpHLineToHigh,<]1
            ELSE
                DB  OpHLineTo,<]1
            FIN
]X              =   ]1
                EOM

PictHSave       MAC
                DB  OpHSave
                EOM

PictHRestore    MAC
                DB  OpHRestore
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
                TXT ]1
                EOM

PictTextAt_     MAC
                DB  OpTextAt
                DB  ]1,]2
]X              =   ]1
]Y              =   ]2
                EOM

PictTextAt      MAC
                PictTextAt_
                TXT ]3
                EOM

PictTextIn      MAC
                DB  OpTextIn
                TXT ]1
                EOM

; Draw the text currently in the text buffer at the current position
PictTextbuf     MAC
                DB  OpTextbuf
                EOM

; Draw the text currently in the text buffer at the current position, followed by "\n"
PictTextbufRet  MAC
                DB  OpTextbufRet
                EOM

; Decompress image to current screen with transparency
PictImage       MAC
                DB  OpImage
                DW  ]1
                EOM

; Decompress image to current screen, filling transparent with black
PictImageFill   MAC
                DB  OpImageFill
                DW  ]1
                EOM

PictTile        MAC
                DB  OpTile
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

; Swap an area of the screen between page 1 and 2
;
;   left byte
;   top line (INCLUSIVE)
;   right byte (exclusive)
;   bottom line (INCLUSIVE)
;
; If top > bottom, transfer happens in reverse order.
PictSwap        MAC
                DB  OpSwap
                DB  ]1,]2,]3,]4
                EOM

; Set the drawing page to 1
PictSetPage1    MAC
                DB  OpSetPage1
                EOM

; Set the drawing page to 2
PictSetPage2    MAC
                DB  OpSetPage2
                EOM

; Set the drawing page to the opposite of the current drawing page
PictSetPageX    MAC
                DB  OpSetPageX
                EOM

; Display the currently set drawing page
PictShowPage    MAC
                DB  OpShowPage
                EOM

; Clear the currently set drawing page to black
PictClearPage   MAC
                DB  OpClearPage
                EOM

; Copy to the current drawing page from the opposite page
PictCopyToPage  MAC
                DB  OpCopyToPage
                EOM

; Call the given function
PictCall        MAC
                DB  OpCall
                DW  ]1
                EOM

; End the picture
; required end to every DRAW_PICT call
PictEnd         MAC
                DB  OpEnd
                EOM
