
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                ; PUT /CAMP/VARS
                PUT /CAMP/EXT

                ORG $7400

                JSR INIT_RANDOM
                JSR SET_PAGE1
                JSR CLEAR_PAGE1

                STA $C05F           ;Clear double hires
                STA $C05A           ;Disable VBL interupt
                STA $C058           ;Disable mouse interupts
                STA $C00E           ;Normal character set
                STA $C00C           ;40 column
                STA $C008           ;Use main pages 0,1
                STA $C002           ;Use main 48K
                STA $C000           ;Page 2 switches page 1 and 2

                STA $C050           ;graphics mode
                STA $C057           ;hires mode

                STA $C08B           ;read/write $D000-$FFFF, BANK 1
                STA $C08B

                ; LDA #side_MS
                ; STA DISK_SIDE
                ; LDA #0
                ; STA SHELL

                LDA #6
                STA GROUP_SIZE

                LDX #<MAP_DATA
                LDY #>MAP_DATA
                LDA #17
                JSR SET_MAP_DATA

                LDA #0
                STA MAP_FACE
                LDA #6
                STA MAP_X
                LDA #9
                STA MAP_Y
                LDA #3
                STA MAP_DIR
                JSR COMPUTE_MAP_PTR

                ; JSR RESTORE_MAPPED
                ; JSR MARK_MAPPED

                LDA #6
                STA RANGE

                LDX #<:HALL_FILTER
                LDY #>:HALL_FILTER
                JSR HALL_SET_FILTER

                JSR GET_NSEW
                JSR DRAW_HALL
                JMP HALL_KEYS

:HALL_FILTER    CMP #"S"
                BEQ :GO_CAMP
                CMP #"M"
                BEQ :GO_MAP
                CMP #"X"
                BEQ :GO_ALIEN
                CLC
                RTS

:GO_MAP         JSR SHOW_MAP
                SEC
                RTS

:GO_CAMP        JSR ENTER_CAMP
                SEC
                RTS

:GO_ALIEN       JSR ALIEN_DIRECTORY
                SEC
                RTS

                PUT ALIEN.ID

MAP_DATA        DW  MAP_FACE_0
                DW  MAP_FACE_1
                DW  MAP_FACE_2
                DW  MAP_FACE_3
                DW  MAP_FACE_4
                DW  MAP_FACE_5

                DW  18*0
                DW  18*1
                DW  18*2
                DW  18*3
                DW  18*4
                DW  18*5
                DW  18*6
                DW  18*7
                DW  18*8
                DW  18*9
                DW  18*10
                DW  18*11
                DW  18*12
                DW  18*13
                DW  18*14
                DW  18*15
                DW  18*16
                DW  18*17

MAP_FACE_0      HEX 7030d030303010f010f0303030f030b030c0
                HEX c000c0f02030c0c000c00000c00030c000c0
                HEX c000c0c00000c0f020b030a0f03030203040
                HEX c000f0f02030308000c000c0c0f020e030c0
                HEX c00000c000000020f030303000c000c000c0
                HEX c000000000000000c0f03030308000f0b0c0
                HEX c000000000000000c0c000b030c000c0c0c0
                HEX c0000000b030c00080c0f0c0003020c0c0c0
                HEX c000000030c0c00080e000f0f0303000c0c0
                HEX c000e0c000200000c0c0f0c03080000080c0
                HEX 4000c03080000000c0c0c0800020f03000c0
                HEX c000303000000000c0c0c0c0000030c000c0
                HEX f080000000000000c0c030c000000030c0c0
                HEX c0f03030c0000000c0f0c030e0f0302020c0
                HEX c0c000003030303000c0308000c0f0308040
                HEX e0c00000f0b0f0b0c03030303000c000c0c0
                HEX c0b0303080c080c0b030b03030c0303000c0
                HEX 303030303030303030103030303030303000

MAP_FACE_1      HEX f0f030f03030f03030d0b0f0f0f0f0f0f0c0
                HEX c080008000008000e000c0300000003000c0
                HEX c03030c0e030f020c0f03030303030b03040
                HEX c0f03030b0f00000c0c000000000f0f0b0c0
                HEX c0c00000c0c0f030003030303030c0c0c0c0
                HEX c03030c0c0c0c0f020e0e03030c0e0e0e0c0
                HEX c030c0c0c0c0c0c000c0c00000c0c080c0c0
                HEX 70c0c0c0c0c0c0c0f080b030f0003030e0c0
                HEX c0c000c0c000c0c0c0c0c0f0c0f030c0c0c0
                HEX c0303020303000303030303000c0c0c0c0c0
                HEX f02030c0f030f03030c0e0303000c0c0c0c0
                HEX c00000c08000800000c0c0f02030c0c0c0c0
                HEX f03000c0f020f0b03080c0f0303080c0c0c0
                HEX c03030c0c00080c0f000c0f0303080c0c0c0
                HEX c00000c0e0f03030c0f000b0303080202040
                HEX f03030c08030800080c0b030f030f030c0c0
                HEX f02030c0c000f020c0c030202030302000c0
                HEX 301030103030303010303010303030303000

MAP_FACE_2      HEX f03010f030f0303030303030f030d03030c0
                HEX c0f030203030e0f0f0f0e0f030203030c0c0
                HEX 40c000000000c0c0f0c0c0c000000000c040
                HEX c030302030300020c0e000303020303000c0
                HEX c0f020f0e030c0b0203080f020f0e030c0c0
                HEX c0c000c0c000c030e0f000c000c0c000c0c0
                HEX c03030c0f03000e0c0e0c03030c0f0300040
                HEX c0f0c03000c000c0f0c0c000c03000f0f0c0
                HEX c0c03030803030300030303000b03080c0c0
                HEX c0c0f03000f030f0c0f0f030c03030c0c0c0
                HEX c03000f0c00000c0f0c0c00000f0c03030c0
                HEX c0f030c0f030c020c0e000f030c0f030c0c0
                HEX c0c000c0c000c0b0203080c000c0c000c0c0
                HEX c030203020300030e0f000302030203000c0
                HEX 40f030203030c0e0c0e0c0f030203030c040
                HEX c0c000000000c0c0f0c0c0c000000000c0c0
                HEX c03030f0b03020303030203030b0f03000c0
                HEX 303010203020202020202020302010303000

MAP_FACE_3      HEX f030303030f03030d0f0d030303010f030c0
                HEX c00000f080f0c0f080c0c000000000c000c0
                HEX 70303080c080c0c0b0c0303030303000f040
                HEX f03030c080c0c030c0b0c000f0c0f0c0c0c0
                HEX c000003000f0000030c0b0f080b080b080c0
                HEX f0303030e0f0c00000f08080f0c0b0c0f0c0
                HEX 703030c0c080b0b0b080f03000f080f000c0
                HEX c00000c030f080c080b0c000f080f00000c0
                HEX f0303000f080f03030c0b0c0c0b0c00000c0
                HEX c0f0b0f080f0000000f080c030c0b0c0f0c0
                HEX f080c080f00000f0f080f0000030c0b08040
                HEX c0f030300000f08080f000f030c0f080f0c0
                HEX f030303030c0c0b0f000f00000c0c0b0c0c0
                HEX c00000f080c0f080b0c030c000c030c0b0c0
                HEX 70303080c0b080f0c0b0c030e030c0f080c0
                HEX f03030c080c0f00030c0b0c030c0c0c0b0c0
                HEX c000003000f000000030c0c000c0c030c0c0
                HEX 303030303030303030301030301030303000

MAP_FACE_4      HEX d030303030f0f030b030103030303030f0c0
                HEX c0000000f0f030b020303030303030f0f0c0
                HEX 400000f0f030b000f0e0f0303020f0f0c0c0
                HEX c000f0f030b00000c00000c0c0f0f080c0c0
                HEX c0f0f0c0f00000003030302030f000c0c0c0
                HEX f0f0c0e000b0303030303030c0b000c0c0c0
                HEX f0c0e00000c0b030303030c0c0f000c0c0c0
                HEX c0e0000000c0c0f03030c0c0c0c03080c040
                HEX e080f030c0c0c0c03030c0c0c0c030c080c0
                HEX c0c0b000c0c0c0c0303080c0c0303000e0c0
                HEX 40c0f000c0c0c03030300080c00000e0c0c0
                HEX c0c0c03080c03030303030008000e0c0f0c0
                HEX c0c0c030c03030303030303000e0c0f0f0c0
                HEX c0c080f0f0e0f03030c00000b000f0f000c0
                HEX c0c0f0f0000000c0c0c000b030f0f00000c0
                HEX c0f0f020303030203000b030f0f0000000c0
                HEX f0f030303030303020b030f0f000000000c0
                HEX 303030303030301030303030303010303000

MAP_FACE_5      HEX f01030d0f030f030d0f030103030303030c0
                HEX f02030c02030302000c0f03030c0f020c0c0
                HEX 7020f03030303030f0003030c0c0c000c040
                HEX c0f000b0303030203030303080c0e030f080
                HEX c0c0c0f0303030e0f0303030c0c0c000c0c0
                HEX c0c0c0c030c0f00030c0f000c0c0f020c080
                HEX c0c0c030c0c0c0f0c0c0c0f020008000c080
                HEX c0c0c0c0c0300000003000f03030e030c080
                HEX c0c0c0c0c0f0f0f0f0f0c0c00000c000c080
                HEX 40c0c0c0c0c0c0c0c0c0c0c00000c000c080
                HEX c0c000c0c0a080a080a080f03030a030c080
                HEX c03080c0c0e0c0e0c0e0c0c0e0c0c000c080
                HEX c0c0f000c0c0c0c0c0c0c0c0c0c0f020c0c0
                HEX c0c0f0c0c03030e0f03000c0c0c0c000c080
                HEX c0c000c03030f00030f03000c0c0e030f040
                HEX c0c0303030c0c03000c0f03000c0c000c0c0
                HEX c030303000c030c0f00030303000302000c0
                HEX 303030103030103030303030303030303000

                SAV CONTROL
