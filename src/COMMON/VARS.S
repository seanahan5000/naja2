
                EXP OFF

SAME_PAGE_AS    MAC
                ERR *!]1/256
                EOM

Text0           =   0
Text1           =   1
Text9           =   9
TextSpace       =   10
TextA           =   11
TextB           =   12
TextC           =   13
TextD           =   14
TextE           =   15
TextF           =   16
TextG           =   17
TextH           =   18
TextI           =   19
TextJ           =   20
TextK           =   21
TextL           =   22
TextM           =   23
TextN           =   24
TextO           =   25
TextP           =   26
TextQ           =   27
TextR           =   28
TextS           =   29
TextT           =   30
TextU           =   31
TextV           =   32
TextW           =   33
TextX           =   34
TextY           =   35
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

; *** reconcile with TEXT.S ***
OP_PTR          =   $50
OP_PTR_H        =   $51
OP_INDEX        =   $52
OP_COLOR        =   $53
; TODO: SHARE WITH ALL GRAPHICS?
LEFT_DIV7       =   $54
LEFT_MOD7       =   $55
RIGHT_DIV7      =   $56
RIGHT_MOD7      =   $57
TOP             =   $58
BOTTOM          =   $59
AND_MASK        =   $5A
AND_MASK_L      =   AND_MASK
AND_MASK_R      =   $5B
LEFT_MASK       =   $5C
RIGHT_MASK      =   $5D
SWITCH_INDEX    =   $5F

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

GRPNUMB         =   $FB                 ; number of living characters in group
GRPCONT         =   $FC                 ; number of characters, including dead/compressed?
GROUP_SIZE      =   GRPNUMB             ; TODO: use this in more places

SCRATCH_PAGE    =   $B900       ; TODO: place somewhere else

maxGroupSize    =   6

stateSectors    =   3
rosterSectors   =   8
maxRosterSize   =   rosterSectors*2

GAME_STATE      =   $BA00
GAME_STATE_MS   =   $BC00

                DUMMY GAME_STATE

MAP_VISITED_17  DS  217
                ; DS  39
                DS  3
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

                DS  3

EQUIP_STOCK     DS  36
GROUP_CREDITS   DS  4

ROSTER_BITS     DS  2           ; bitmap character slots filled in roster

; TODO: Since these are only valid while in TRACC,
;   consider moving to CAMP and/or ZPAGE.

TOTAL_KILLS     DS  4           ; expedition totals (assumed sequential)
TOTAL_CREDITS   DS  4
TOTAL_EXP       DS  4

LOST_CHARS      DS  1           ; $BCFD ; NOTE: not correctly being tracked anymore
DELAY_MODE      DS  1           ; $BCFE - was GRPCONT
DELAY_TIME      DS  1           ; $BCFF - WAS GRPNUMB

                ERR $BD00-*
CHAR_0          DS  $80
CHAR_1          DS  $80
CHAR_2          DS  $80
CHAR_3          DS  $80
CHAR_4          DS  $80
CHAR_5          DS  $80
                DEND

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
OpTextRows      =   24
OpTextbuf       =   25
OpTextbufX      =   26
OpTextbufXY     =   27
OpTextbufRet    =   28
OpImage         =   29
OpImageFill     =   30
OpTile          =   31
OpClear         =   32
OpCopyTo        =   33
OpSwap          =   34

OpSetPage1      =   35
OpSetPage2      =   36
OpSetPageX      =   37
OpShowPage      =   38
OpShowPage1     =   39
OpShowPage2     =   40
OpClearPage     =   41
OpClearPage1    =   42
OpClearPage2    =   43
OpCopyToPage    =   44
OpCopyToPage1   =   45
OpCopyToPage2   =   46
OpCall          =   47

OpSwitch        =   48
OpCase          =   49

OpHook0         =   50
OpHook1         =   51

OpEnd           =   52

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

PictVLineTo     MAC
                DB  OpVLineTo,]1
]Y              =   ]1
                EOM

PictHSave       MAC
                DB  OpHSave
                EOM

PictHRestore    MAC
                DB  OpHRestore
                EOM

; Draw a framed rectangle in the current color
;
;   left pixel
;   top line
;   right pixel (INCLUSIVE)
;   bottom line (INCLUSIVE)
PictRect        MAC
            DO ]3/256
                DB  OpRectHigh
            ELSE
                DB  OpRect
            FIN
                DB  ]1,]2,<]3,]4
                EOM

; Fill a pixel-aligned rectangle in the current color
;
;   left pixel
;   top line
;   right pixel (inclusive)
;   bottom line (inclusive)
PictFillRect    MAC
            DO ]3/256
                DB  OpFillRectHigh
            ELSE
                DB  OpFillRect
            FIN
                DB  ]1,]2,<]3,]4
                EOM

; Set text line height for current DRAW_PICT sequence
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

; Draw text at the given X and Y position and line height
PictTextRows    MAC
                DB  OpTextRows
                DB  ]1,]2,]3
                EOM

; Draw the text currently in the text buffer at the current position
PictTextbuf     MAC
                DB  OpTextbuf
                EOM

; Draw the text currently in the text buffer at the given X position
PictTextbufX    MAC
                DB  OpTextbufX
                DB  ]1
                EOM

; Draw the text currently in the text buffer at the given X and Y position
PictTextbufXY   MAC
                DB  OpTextbufXY
                DB  ]1,]2
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

; Clear a rectangle to black #$00
;
;   left byte
;   top line
;   right byte (exclusive)
;   bottom line (exclusive)
;
; NOTE: external dependencies on this format
PictClear       MAC
                DB  OpClear
                DB  ]1,]2,]3,]4
                EOM

; Copy an area of the screen to current page, from opposite page.
;   Unlike OP_SWAP, only top-to-bottom copy is supported here
;
;   left byte
;   top line
;   right byte (exclusive)
;   bottom line (exclusive)
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

; Display page 1
PictShowPage1   MAC
                DB  OpShowPage1
                EOM

; Display page 2
PictShowPage2   MAC
                DB  OpShowPage2
                EOM

; Clear the currently set drawing page to black
PictClearPage   MAC
                DB  OpClearPage
                EOM

; Clear page 1 to black
PictClearPage1  MAC
                DB  OpClearPage1
                EOM

; Clear page 2 to black
PictClearPage2  MAC
                DB  OpClearPage2
                EOM

; Copy to the current drawing page from the opposite page
PictCopyToPage  MAC
                DB  OpCopyToPage
                EOM

; Copy to page 1 from page 2
PictCopyToPage1 MAC
                DB  OpCopyToPage1
                EOM

; Copy to page 2 from page1
PictCopyToPage2 MAC
                DB  OpCopyToPage2
                EOM

; Call the given function
PictCall        MAC
                DB  OpCall
                DW  ]1
                EOM

; switch between sets of ops using given ZPAGE (cannot be nested)
PictSwitch      MAC
                DB  OpSwitch
                DB  ]1
                EOM

PictCase        MAC
                DB  OpCase
                DB  ]1-*-2
                EOM

PictSwitchEnd   MAC
                ; no code here
                EOM

; End the picture
; required end to every DRAW_PICT call
PictEnd         MAC
                DB  OpEnd
                EOM
