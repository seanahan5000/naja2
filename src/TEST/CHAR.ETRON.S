
CHAR_1          TXC "ETRON_____"
                DFB healthy
                HEX 0040            ;Level
                DFB robot*16+none
                HEX 00000000        ;Experience

                HEX EE

                HEX 00000000        ;Credit
                HEX 99              ;Strength
                HEX 99              ;Upper Reflex
                HEX 99              ;Lower Reflex
                HEX 99              ;Intelligence
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

                HEX 88              ; roster index (8)
                HEX 84              ; robot/cybernate link (4 CYBORG)

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
