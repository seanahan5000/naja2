
                TXC "ELECTRODER"        ; extra "R" to pad out name
                DFB healthy
                HEX 0001            ;Level
                DFB juicer*16+orn
                HEX 00256666        ;Experience

                HEX EE

                HEX 00002854        ;Credit
                HEX 99              ;Strength
                HEX 99              ;Upper Reflex
                HEX 99              ;Lower Reflex
                HEX 99              ;Intelligence
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

                HEX 85              ; roster index (5)
                HEX 00              ; robot/cybernate link (none)

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
