
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                ; PUT /CAMP/VARS
                PUT /CAMP/EXT

                PUT /NDOS/EXT

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
                CLC
                RTS

; TODO: Needs to have checked DISPATCH first for any specials
:GO_MAP         JSR SHOW_MAP
                SEC
                RTS

; TODO: Needs to have checked DISPATCH first for any specials
:GO_CAMP        JSR ENTER_CAMP
                SEC
                RTS

                PUT DISPATCH
