
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
                LDA #1
                STA SHELL

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

                LDX #<:HALL_FILTER
                LDY #>:HALL_FILTER
                JSR SET_HALL_FILTER

                JSR GET_NSEW
                JSR DRAW_HALL
                JMP HALL_KEYS

:HALL_FILTER    JSR DISPATCH
                CLC
                RTS

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

:GO_ALIEN       JSR IDENTIFIED_ALIENS
                SEC
                RTS

SHELL           DB  $00                 ; TODO: move this someplace real

BIG_MAP         =   1
                PUT DISPATCH
                PUT MAP17

ELEVATOR_123    RTS
ELEVATOR_FAR    RTS
SHIP_SOUND      RTS
GREEN_NET       RTS
AIRLOCK         RTS
VIEWPORT        RTS
ROTATE          RTS
IN_ONE_WAY      RTS
DOOR_SIGN       RTS
DATACARD_COMP   RTS
WEAPON_FOUND    RTS
KING_RUUIK      RTS
KILROY          RTS
IS_DOOR         RTS
NOT_DOOR        RTS
ORB_GUARD       RTS
ORB_PEDESTAL    RTS

                PUT ALIEN.ID
                SAV CONTROL
