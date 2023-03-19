
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                ; PUT /CAMP/VARS
                PUT /CAMP/EXT

                PUT /NDOS/VARS
                PUT /NDOS/EXT

                PUT /NAJA/VARS/CONSTANTS

                ORG $7800

CONTROL_FILE    DB  fileControl17+SHELLNUM-1

SET_CONTROL     LDX #<FILE_HOOK
                LDY #>FILE_HOOK
                JSR SET_FILE_HOOK

                LDX #<FILE_TABLE
                LDY #>FILE_TABLE
                JSR SET_FILE_TABLE

                LDX #<DISPATCH
                LDY #>DISPATCH
                JSR SET_HALL_FILTER

                LDX #<:KEY_FILTER
                LDY #>:KEY_FILTER
                JSR SET_KEY_FILTER

                LDX #<MAP_DATA
                LDY #>MAP_DATA
                JMP SET_MAP_DATA

:KEY_FILTER     CMP #"S"
                BEQ :GO_CAMP
                CMP #"M"
                BEQ :GO_MAP
                CMP #"X"
                BEQ :GO_FIGHT
                CLC
                RTS

:GO_FIGHT       JMP LOAD_FIGHT

; TODO: Needs to have checked DISPATCH first for any specials
:GO_MAP         JSR SHOW_MAP
                SEC
                RTS

; TODO: Needs to have checked DISPATCH first for any specials
:GO_CAMP        JSR ENTER_CAMP
                SEC
                RTS

                PUT DISPATCH

; TODO: move this or use symbol directly
FIGHT_LOADER    =   $8800

LOAD_FIGHT      LDA #NOT_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                LDA #fileFightLoader
                LDY #>FIGHT_LOADER
                JSR LOAD_FILE
                JMP FIGHT_LOADER
