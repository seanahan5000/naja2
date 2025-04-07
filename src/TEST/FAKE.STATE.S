
; game state loaded at boot (2-3 sectors)

; group characters written when removed (group assembly)
; group/roster characters written when renamed

; game state written at tesseract in/out of TRACC

; ? group characters written on leaving enroll/energy/arsenal/robot/infirmary


; uninitialized buffer space before game state?

; *** 68 bytes (or more?) of arsenal equipment stock
; *** 6(7?) bytes of characters -- roster indexes
; *** group name?
; *** directory of allocated characters?
    ; *** or just use character records themselves?
; *** currently selected group


; game state (3 sectors) at $BA00
;   arsenal stock data
;   roster allocation bits (2 bytes)
;       one bit per character slot
;       bit set means allocated
;   ? current tracc run data (GRPNUMB, etc.)
;
; character data (8 sectors max, 2 characters per sector)

; group characters (6 max) at $BD00



MAP_VISITED_17_ DS  217,$FF     ;*** ; cleared by default
                ; DS  39
                DS  3
MAP_VISITED_15_ DS  169
MAP_VISITED_13_ DS  127
MAP_VISITED_11_ DS  91
MAP_VISITED_9_  DS  61                  ;,$FF              ;***

KNOWN_ALIENS_12_
                HEX FFFFFF      ; 72 bits
                HEX FFFFFF
                HEX FFFFFF

KNOWN_ALIENS_345_               ; 65 of 72 bits
                HEX FFFFFF
                HEX FFFFFF
                HEX FFFF80

ENCOUNTER_SPAWNS_
                HEX 00000000    ; 32 bits per shell, for now
                HEX 00000000
                HEX 00000000
                HEX 00000000
                HEX 00000000

ORBS_FOUND_                     ; TODO: get rid of this
KEYS_FOUND_     DB  0
KEY_DOOR_BITS_  DB  0

                DS  3

EQUIP_STOCK_    DS  36
GROUP_CREDITS_  HEX 00010000

ROSTER_BITS_    DB  %00111001,%10000011 ; see TEST.ROSTER.S for indexes

GAME_FLAGS_     DS  12

; *** should this be zpage? ***
LOST_CHARS_     DB  0           ; $BCFD

DELAY_MODE_     DB  0           ; $BCFE - was GRPNUMB
DELAY_TIME_     DB  0           ; $BCFF - was GRPCONT
