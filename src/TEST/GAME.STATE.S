
                EXP OFF
                PUT /NAJA/VARS/CONSTANTS

; uninitialized buffer space before game state?

                ORG $BB00

; TODO: map visited bits
; 17: 217 bytes
; 15: 169 bytes
; 13: 127 bytes
; 11:  91 bytes
;  9:  61 bytes
;   = 665 bytes
; TODO: make this handle more than just shell 17
MAP_VISITED     DS  217,$FF     ; cleared by default

                DS 39

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

                DS  85

LOST_CHARS      DB  0           ; $BC7D
GRPCONT         DB  6           ; $BC7E ; number of characters, including dead/compressed?
GRPNUMB         DB  6           ; $BC7F ; number of living characters in group

CHAR_0          USR (BLASTER___)-
                DFB healthy         ;healthy
                HEX 0001            ;Level
                DFB warrior*16+deneb
                HEX 00003999        ;Experience

                HEX EE

                HEX 00002543        ;Credit
                HEX CC              ;Strength
                HEX CC              ;Upper Reflex
                HEX CC              ;Lower Reflex
                HEX CC              ;Intelligence
                HEX 10              ;Electrical shielding
                HEX 21              ;Physical shielding
                HEX 03              ;Back slots
                HEX 25              ;XY

                HEX 0000            ;Damage level
                HEX 0075            ;Damage maximum
                HEX 45              ;Composition (organic)
                HEX 003750          ;Power level
                HEX 003750          ;Power maximum
                HEX CCCC            ;Power consumption

                HEX EE

                HEX 00              ;Sector/Segment ??????
                HEX FF              ;Robot/Cyb link ($FF if not either)
                HEX 0000            ;Power level extra digits

                HEX 0375            ;Base power consumption
                HEX 0102            ;Base shielding (e/p)

                HEX FFFFFFFF        ;e1_HEAD
                HEX FFFFFFFF        ;e2_SLOT
                HEX 4C0000A7        ;e3_UPLFT
                HEX 480000AD        ;e4_UPRGT
                HEX 4F070089        ;e5_LWLFT
                HEX FFFFFFFF        ;e6_LWRGT
                HEX 430200DF        ;e7_BACK1 (WHITE_SAND)
                HEX 430A00DF        ;e8_BACK2 (HEAVY_STONE)
                HEX 431200DF        ;e9_BACK3 (CHANGING_CRYSTAL)
                HEX FFFFFFFF        ;e10_BACK4
                HEX FFFFFFFF        ;e11_BACK5
                HEX FFFFFFFF        ;e12_BACK6
                HEX FFFFFFFF        ;e13_ARMOR
                HEX FFFFFFFF        ;e14_FEET
                HEX FFFFFFFF        ;e15_PROGRAM
                HEX FFFFFFFF        ;e16_UNUSED

                HEX 00000000        ;Illness damager

                HEX 21              ;Base strength
                HEX 95              ;20 ;Base upper reflex
                HEX 97              ;19 ;Base lower reflex
                HEX 06              ;Base intelligence

                HEX EE
                HEX EE
                HEX 00              ;Misc

CHAR_1          USR (ETRON_____)-
                DFB healthy
                HEX 0040            ;Level
                DFB robot*16+none
                HEX 00000000        ;Experience

                HEX EE

                HEX 00000000        ;Credit
                HEX CC              ;Strength
                HEX CC              ;Upper Reflex
                HEX CC              ;Lower Reflex
                HEX CC              ;Intelligence
                HEX 12              ;Electrical shielding
                HEX 18              ;Physical shielding
                HEX 01              ;Back slots
                HEX 34              ;XY

                HEX 0000            ;Damage level
                HEX 0075            ;Damage maximum
                HEX 01              ;Composition (organic)
                HEX 002905          ;Power level
                HEX 003000          ;Power maximum
                HEX CCCC            ;Power consumption

                HEX EE

                HEX 80              ;Sector/Segment ??????
                HEX 02              ;Robot/Cyb link ($FF if not either)
                HEX 0000            ;Power level extra digits

                HEX 0420            ;Base power consumption
                HEX 0000            ;Base shielding (e/p)  (WRONG)!!!

                HEX 13000000        ;e1_HEAD
                HEX FFFFFFFF        ;e2_SLOT
                HEX FFFFFFFF        ;e3_UPLFT
                HEX FFFFFFFF        ;e4_UPRGT
                HEX FFFFFFFF        ;e5_LWLFT
                HEX FFFFFFFF        ;e6_LWRGT
                HEX FFFFFFFF        ;e7_BACK1
                HEX FFFFFFFF        ;e8_BACK2
                HEX FFFFFFFF        ;e9_BACK3
                HEX FFFFFFFF        ;e10_BACK4
                HEX FFFFFFFF        ;e11_BACK5
                HEX FFFFFFFF        ;e12_BACK6
                HEX FFFFFFFF        ;e13_ARMOR
                HEX FFFFFFFF        ;e14_FEET
                HEX 5A400020        ;e15_PROGRAM
                HEX FFFFFFFF        ;e16_UNUSED

                HEX 00000000        ;Illness damager

                HEX 25              ;Base strength
                HEX 25              ;Base upper reflex
                HEX 20              ;Base lower reflex
                HEX 00              ;Base intelligence

                HEX EE
                HEX EE
                HEX 00              ;Misc

CHAR_2          USR (ELECTRODE_)-
                DFB healthy
                HEX 0001            ;Level
                DFB juicer*16+orn
                HEX 00256666        ;Experience

                HEX EE

                HEX 00002854        ;Credit
                HEX CC              ;Strength
                HEX CC              ;Upper Reflex
                HEX CC              ;Lower Reflex
                HEX CC              ;Intelligence
                HEX 21              ;Electrical shielding
                HEX 32              ;Physical shielding
                HEX 04              ;Back slots
                HEX 53              ;XY

                HEX 0015            ;Damage level
                HEX 0048            ;Damage maximum
                HEX 35              ;Composition (organic)
                HEX 007612          ;Power level
                HEX 007700          ;Power maximum
                HEX CCCC            ;Power consumption

                HEX EE

                HEX 01              ;Sector/Segment ??????
                HEX FF              ;Robot/Cyb link ($FF if not either)
                HEX 0000            ;Power level extra digits

                HEX 0385            ;Base power consumption
                HEX 0000            ;Base shielding (e/p)

                HEX FFFFFFFF        ;e1_HEAD
                HEX FFFFFFFF        ;e2_SLOT
                HEX 4F0100FF        ;e3_UPLFT
                HEX FFFFFFFF        ;e4_UPRGT
                HEX FFFFFFFF        ;e5_LWLFT
                HEX FFFFFFFF        ;e6_LWRGT
                HEX FFFFFFFF        ;e7_BACK1
                HEX FFFFFFFF        ;e8_BACK2
                HEX FFFFFFFF        ;e9_BACK3
                HEX FFFFFFFF        ;e10_BACK4
                HEX FFFFFFFF        ;e11_BACK5
                HEX FFFFFFFF        ;e12_BACK6
                HEX FFFFFFFF        ;e13_ARMOR
                HEX FFFFFFFF        ;e14_FEET
                HEX FFFFFFFF        ;e15_PROGRAM
                HEX FFFFFFFF        ;e16_UNUSED

                HEX 00000000        ;Illness damager

                HEX 18              ;Base strength
                HEX 18              ;Base upper reflex
                HEX 18              ;Base lower reflex
                HEX 14              ;Base intelligence

                HEX EE
                HEX EE
                HEX 00              ;Misc

CHAR_3          USR (RELAYER___)-
                DFB healthy
                HEX 0001            ;Level
                DFB android*16+xxtys
                HEX 00256666        ;Experience

                HEX EE

                HEX 00002836        ;Credit
                HEX CC              ;Strength
                HEX CC              ;Upper Reflex
                HEX CC              ;Lower Reflex
                HEX CC              ;Intelligence
                HEX 09              ;Electrical shielding
                HEX 07              ;Physical shielding
                HEX 03              ;Back slots
                HEX 12              ;XY

                HEX 0000            ;Damage level
                HEX 0040            ;Damage maximum
                HEX 20              ;Composition (organic)
                HEX 003909          ;Power level
                HEX 004000          ;Power maximum
                HEX CCCC            ;Power consumption

                HEX EE

                HEX 81              ;Sector/Segment ??????
                HEX FF              ;Robot/Cyb link ($FF if not either)
                HEX 0000            ;Power level extra digits

                HEX 0400            ;Base power consumption
                HEX 0000            ;Base shielding (e/p)

                HEX FFFFFFFF        ;e1_HEAD
                HEX FFFFFFFF        ;e2_SLOT
                HEX 42010002        ;e3_UPLFT
                HEX 42000002        ;e4_UPRGT
                HEX FFFFFFFF        ;e5_LWLFT
                HEX FFFFFFFF        ;e6_LWRGT
                HEX FFFFFFFF        ;e7_BACK1
                HEX FFFFFFFF        ;e8_BACK2
                HEX FFFFFFFF        ;e9_BACK3
                HEX FFFFFFFF        ;e10_BACK4
                HEX FFFFFFFF        ;e11_BACK5
                HEX FFFFFFFF        ;e12_BACK6
                HEX FFFFFFFF        ;e13_ARMOR
                HEX FFFFFFFF        ;e14_FEET
                HEX FFFFFFFF        ;e15_PROGRAM
                HEX FFFFFFFF        ;e16_UNUSED

                HEX 0505020A        ;Illness damager

                HEX 10              ;Base strength
                HEX 17              ;Base upper reflex
                HEX 17              ;Base lower reflex
                HEX 25              ;Base intelligence

                HEX EE
                HEX EE
                HEX 00              ;Misc

CHAR_4          USR (CYBORG____)-
                DFB healthy
                HEX 0001            ;Level
                DFB cybernate*16+stilicx
                HEX 00256666        ;Experience

                HEX EE

                HEX 00002940        ;Credit
                HEX CC              ;Strength
                HEX CC              ;Upper Reflex
                HEX CC              ;Lower Reflex
                HEX CC              ;Intelligence
                HEX 30              ;Electrical shielding
                HEX 29              ;Physical shielding
                HEX 03              ;Back slots
                HEX 31              ;XY

                HEX 0000            ;Damage level
                HEX 0037            ;Damage maximum
                HEX 50              ;Composition (organic)
                HEX 003616          ;Power level
                HEX 003700          ;Power maximum
                HEX CCCC            ;Power consumption

                HEX EE

                HEX 02              ;Sector/Segment ??????
                HEX 80              ;Robot/Cyb link ($FF if not either)
                HEX 0000            ;Power level extra digits

                HEX 0370            ;Base power consumption
                HEX 0000            ;Base shielding (e/p)

                HEX FFFFFFFF        ;e1_HEAD
                HEX FFFFFFFF        ;e2_SLOT
                HEX FFFFFFFF        ;e3_UPLFT
                HEX FFFFFFFF        ;e4_UPRGT
                HEX FFFFFFFF        ;e5_LWLFT
                HEX FFFFFFFF        ;e6_LWRGT
                HEX FFFFFFFF        ;e7_BACK1
                HEX FFFFFFFF        ;e8_BACK2
                HEX FFFFFFFF        ;e9_BACK3
                HEX FFFFFFFF        ;e10_BACK4
                HEX FFFFFFFF        ;e11_BACK5
                HEX FFFFFFFF        ;e12_BACK6
                HEX FFFFFFFF        ;e13_ARMOR
                HEX FFFFFFFF        ;e14_FEET
                HEX FFFFFFFF        ;e15_PROGRAM
                HEX FFFFFFFF        ;e16_UNUSED

                HEX 00000000        ;Illness damager

                HEX 14              ;Base strength
                HEX 11              ;Base upper reflex
                HEX 16              ;Base lower reflex
                HEX 22              ;Base intelligence

                HEX EE
                HEX EE
                HEX 00              ;Misc

CHAR_5          USR (BLADE_____)-
                DFB healthy
                HEX 0001            ;Level
                DFB physician*16+stilicx
                HEX 00256666        ;Experience

                HEX EE

                HEX 00002766        ;Credit
                HEX CC              ;Strength
                HEX CC              ;Upper Reflex
                HEX CC              ;Lower Reflex
                HEX CC              ;Intelligence
                HEX 20              ;Electrical shielding
                HEX 25              ;Physical shielding
                HEX 03              ;Back slots
                HEX 41              ;XY

                HEX 0000            ;Damage level
                HEX 0039            ;Damage maximum
                HEX 60              ;Composition (organic)
                HEX 002345          ;Power level
                HEX 002345          ;Power maximum
                HEX CCCC            ;Power consumption

                HEX EE

                HEX 82              ;Sector/Segment ??????
                HEX FF              ;Robot/Cyb link ($FF if not either)
                HEX 0000            ;Power level extra digits

                HEX 0390            ;Base power consumption
                HEX 0000            ;Base shielding (e/p)

                HEX FFFFFFFF        ;e1_HEAD
                HEX FFFFFFFF        ;e2_SLOT
                HEX 41000050        ;e3_UPLFT
                HEX 61010050        ;e4_UPRGT
                HEX FFFFFFFF        ;e5_LWLFT
                HEX FFFFFFFF        ;e6_LWRGT
                HEX 431A00DF        ;e7_BACK1 (PLASTEEL_CIRCUIT)
                HEX 432200DF        ;e8_BACK2 (PETRIFIED_LEAF)
                HEX 41030050        ;e9_BACK3 (ATOM_COMPRESSOR)
                HEX FFFFFFFF        ;e10_BACK4
                HEX FFFFFFFF        ;e11_BACK5
                HEX FFFFFFFF        ;e12_BACK6
                HEX FFFFFFFF        ;e13_ARMOR
                HEX FFFFFFFF        ;e14_FEET
                HEX FFFFFFFF        ;e15_PROGRAM
                HEX FFFFFFFF        ;e16_UNUSED

                HEX 00000000        ;Illness damager

                HEX 10              ;Base strength
                HEX 20              ;Base upper reflex
                HEX 21              ;Base lower reflex
                HEX 23              ;Base intelligence

                HEX EE
                HEX EE
                HEX 00              ;Misc

CHAR_6          DS  $80,0
