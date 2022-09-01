
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                ; PUT /CAMP/VARS
                PUT /CAMP/EXT

                ORG $7400

                JSR INIT_RANDOM
                JSR SET_PAGE1
                JSR CLEAR_PAGE

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

                PUT MAP17
                PUT ALIEN.ID

                SAV CONTROL
