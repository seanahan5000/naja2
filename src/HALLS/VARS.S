
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
