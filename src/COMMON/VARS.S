
SAME_PAGE_AS    MAC
                ERR >(*-1!]1)
                EOM

Char0           =   0
Char9           =   9
CharSpace       =   10
CharA           =   11
CharZ           =   36
CharFirstSymbol =   37              ; first symbol after [0-9 A-Z]
CharEmpty       =   $EE
CharLineBreak   =   $8B
CharLineEnd     =   $8D
CharInsert      =   $C0
CharInsertMask  =   $3F

LineHeight      =   9

TEXT_BUFFER     =   $0200
WORD_BUFFER     =   TEXT_BUFFER+$A0
INSERT_BUFFER   =   TEXT_BUFFER+$C0

SCREENL         =   $26
SCREENH         =   $27

; NOTE: UNPACK is currently using $30-$3F

; TODO: pick a safe/permanent range
SEED0           =   $40
SEED1           =   $41

XCOORD          =   $48
XSHIFT          =   $49
YCOORD          =   $4A

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
