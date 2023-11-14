
CHAR_4          TXC "CYBORG____"
                DFB healthy
                HEX 0001            ;Level
                DFB cybernate*16+human
                HEX 00256666        ;Experience

                HEX EE

                HEX 00002940        ;Credit
                HEX 99              ;Strength
                HEX 99              ;Upper Reflex
                HEX 99              ;Lower Reflex
                HEX 99              ;Intelligence
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

                HEX 84              ; roster index (4)
                HEX 88              ; robot/cybernate link (8 ETRON)

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
