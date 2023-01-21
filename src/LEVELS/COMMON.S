
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                ; PUT /CAMP/VARS
                PUT /CAMP/EXT

                PUT /NDOS/EXT

                ORG $7400

                JSR INIT_RANDOM
                JSR SET_PAGE1
                JSR CLEAR_PAGE

                STA $C05F           ;Clear double hires
                STA $C05A           ;Disable VBL interrupt
                STA $C058           ;Disable mouse interrupts
                STA $C00E           ;Normal character set
                STA $C00C           ;40 column
                STA $C008           ;Use main pages 0,1
                STA $C002           ;Use main 48K
                STA $C000           ;Page 2 switches page 1 and 2

                STA $C050           ;graphics mode
                STA $C057           ;hires mode

                STA $C08B           ;read/write $D000-$FFFF, BANK 1
                STA $C08B

                LDA #$FF            ; reset module present value
                STA $A000

                LDA #side_T1
                JSR SET_DISK_SIDE

                ; LDA #side_MS
                ; STA DISK_SIDE
                ; LDA #0
                LDA #1
                STA SHELL

                LDX #<FILE_HOOK
                LDY #>FILE_HOOK
                JSR SET_FILE_HOOK

                LDX #<FILE_TABLE
                LDY #>FILE_TABLE
                JSR SET_FILE_TABLE

                ; LDA #6
                ; STA GROUP_SIZE

                LDX #<MAP_DATA
                LDY #>MAP_DATA
                JSR SET_MAP_DATA

                LDA #5
                STA MAP_FACE
                LDA #2
                STA MAP_X
                LDA #4
                STA MAP_Y
                LDA #3
                STA MAP_DIR
                JSR COMPUTE_MAP_PTR

                JSR RESTORE_MAPPED
                JSR MARK_MAPPED         ; force current position as mapped

                LDA #6
                STA RANGE

                LDX #<:KEY_FILTER
                LDY #>:KEY_FILTER
                JSR SET_KEY_FILTER

                LDX #<DISPATCH
                LDY #>DISPATCH
                JSR SET_HALL_FILTER

                JSR GET_NSEW
                JSR DRAW_HALL
                JMP HALL_KEYS

:KEY_FILTER     CMP #"S"
                BEQ :GO_CAMP
                CMP #"M"
                BEQ :GO_MAP
                CLC
                RTS

:GO_MAP         JSR SHOW_MAP
                SEC
                RTS

:GO_CAMP        JSR ENTER_CAMP
                SEC
                RTS

SHELL           DB  $00                 ; TODO: move this someplace real

                PUT DISPATCH
