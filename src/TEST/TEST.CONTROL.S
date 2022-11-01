
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

:GO_ALIEN       LDA ALIEN_ID_MOD        ; TODO: used common/fixed address
                CMP #modAlienId
                BEQ :1
                LDX #fileAlienId
                JSR LOAD_FILE
:1              JSR IDENTIFIED_ALIENS
                SEC
                RTS

SHELL           DB  $00                 ; TODO: move this someplace real

BIG_MAP         =   1
                PUT DISPATCH
                PUT MAP17

SHIP_SOUND
ROTATE
IN_ONE_WAY
DOOR_SIGN
DATACARD_COMP
WEAPON_FOUND
KING_RUUIK
KILROY
IS_DOOR
NOT_DOOR
ORB_GUARD
                CLC
                RTS

FILE_TABLE      DB  $19,$00,$0E,$A0     ; 0 - diagnose
                DB  $1A,$00,$06,$A0     ; 1 - alien.id
                DB  $1A,$08,$08,$A0     ; 2 - elevator
                DB  $1B,$00,$09,$A0     ; 3 - viewport

                PUT /SPECIALS/LOAD.ELEVATOR
                PUT /SPECIALS/LOAD.VIEWPORT
                ; PUT /SPECIALS/FINDMENT
                PUT /SPECIALS/ORB.GREEN
                PUT /SPECIALS/GREEN.NET
                SAV CONTROL

                ORG $A000
ALIEN_ID_MOD    DB  modAlienId
                PUT ALIEN.ID
                SAV ALIEN.ID

                ORG $A000
ELEVATOR_MOD    DB  modElevator
                PUT /SPECIALS/ELEVATOR
                SAV ELEVATOR

                ORG $A000
VIEWPORT_MOD    DB  modViewport
                PUT /SPECIALS/VIEWPORT
                SAV VIEWPORT
