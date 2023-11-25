
; uninitialized buffer space before game state?

; *** 68 bytes (or more?) of arsenal equipment stock
; *** 6(7?) bytes of characters -- roster indexes
; *** group name?
; *** directory of allocated characters?
    ; *** or just use character records themselves?
; *** currently selected group


MAP_VISITED_17  DS  217 ;,$FF     ;*** ; cleared by default
                DS  39
MAP_VISITED_15  DS  169
MAP_VISITED_13  DS  127
MAP_VISITED_11  DS  91
MAP_VISITED_9   DS  61

KNOWN_ALIENS_12 HEX FFFFFF      ; 72 bits
                HEX FFFFFF
                HEX FFFFFF

KNOWN_ALIENS_345                ; 65 of 72 bits
                HEX FFFFFF
                HEX FFFFFF
                HEX FFFF80

ENCOUNTER_SPAWNS
                HEX 00000000    ; 32 bits per shell, for now
                HEX 00000000
                HEX 00000000
                HEX 00000000
                HEX 00000000

ORBS_FOUND                      ; TODO: get rid of this
KEYS_FOUND      DB  0
KEY_DOOR_BITS   DB  0

                DS  3

GROUP_CREDITS   HEX 00010000

ROSTER_BITS     DB  %00111001,%10000011 ; see TEST.ROSTER.S for indexes

; TODO: Since these are only valid while in TRACC,
;   consider moving to CAMP and/or ZPAGE.

TOTAL_KILLS     DS  4
TOTAL_CREDITS   DS  4
TOTAL_EXP       DS  4

LOST_CHARS      DB  0           ; $BCFD
GRPCONT         DB  6           ; $BCFE ; number of characters, including dead/compressed?
GRPNUMB         DB  6           ; $BCFF ; number of living characters in group
