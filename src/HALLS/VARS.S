
; TODO: get rid of this and move into COMMON/VARS.S

MAP_SIZE        =   $F0
MAP_FACE        =   $F1         ; must be sequential
MAP_X           =   $F2         ; must be sequential
MAP_Y           =   $F3         ; must be sequential
MAP_DIR         =   $F4         ; must be sequential
MAP_PTR         =   $F5         ; must be sequential
MAP_PTR_H       =   $F6         ; must be sequential
; TODO: do MAP_PTR_L/H really need permanent zpage?

RANGE           =   $F7         ; does this need a zpage?
SHELL           =   $F8         ; does this need a zpage?

; map field constants

OPEN            =   0               ; assumed to be zero
FACE            =   1
DOOR            =   2
WALL            =   3

NORTH           =   0               ; assumed to be zero
EAST            =   1
SOUTH           =   2
WEST            =   3

FRONT_MASK      =   %00000011
SIDE_MASK       =   %00001100
XFRONT_MASK     =   %00110000
XSIDE_MASK      =   %11000000

FRONT_OPEN      =   OPEN * 1
FRONT_FACE      =   FACE * 1
FRONT_DOOR      =   DOOR * 1
FRONT_WALL      =   WALL * 1

SIDE_OPEN       =   OPEN * 4
SIDE_FACE       =   FACE * 4
SIDE_DOOR       =   DOOR * 4
SIDE_WALL       =   WALL * 4

XFRONT_OPEN     =   OPEN * 16
XFRONT_FACE     =   FACE * 16
XFRONT_DOOR     =   DOOR * 16
XFRONT_WALL     =   WALL * 16

XSIDE_OPEN      =   OPEN * 64
XSIDE_FACE      =   FACE * 64
XSIDE_DOOR      =   DOOR * 64
XSIDE_WALL      =   WALL * 64
