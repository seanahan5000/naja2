
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
FIGHT_LOADER    =   $8400

LOAD_FIGHT      LDA #NOT_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                LDA #fileFightLoader
                LDY #>FIGHT_LOADER
                JSR LOAD_FILE
                JMP FIGHT_LOADER


                DO 0

NO_SPECIAL      LDA #$00
                STA PICHERE
                LDA ENCODDS
                CMP #$EE
                BNE :SKIPA
                LDA #$5F            ;TEMP***????
                STA ENCODDS
:SKIPA

TAKE_ENERGY     JSR FIRST_CHAR
:1              LDY #status
                LDA (CHARDL),Y
                CMP #dead
                BEQ :2
                CMP #broken
                BEQ :2
                JSR DRAINER_FRACT
                BPL :2
                JSR OUT_OF_ENERGY
:2              JSR NEXT_CHAR
                BCC :1

TAKE_DAMAGE     JSR FIRST_CHAR
:1              LDY #inflictnums
                LDA (CHARDL),Y
                BEQ :SKIPD
                LDY #inflictcount
                LDA (CHARDL),Y
                SEC
                SBC #$01
                STA (CHARDL),Y
                BEQ :SKIPE
                BCS :SKIPB
:SKIPE          LDY #inflictnums
                LDA (CHARDL),Y
                SEC
                SBC #$01
                STA (CHARDL),Y
                LDY #inflictdelay
                LDA (CHARDL),Y
                DEY                 ;inflictcount
                STA (CHARDL),Y
                LDY #status
                LDA (CHARDL),Y
                STA :MOD1+1
                LDY #inflictamount
                LDA (CHARDL),Y
                TAX                 ;low
                LDY #$00            ;high
                SEC
                JSR INFLICTER
                BCC :SKIPA
:MOD1           LDA #$FF            ;Modified
                LDY #status
                STA (CHARDL),Y
                LDA #$FF
                JMP OC_COM1
:SKIPA          BVC :SKIPC
                JSR GONE_CRITICAL
:SKIPC          LDY #inflictnums
                LDA (CHARDL),Y
                BNE :SKIPB
                LDY #status
                LDA (CHARDL),Y
                AND #%00111111
                CMP #healthy
                BEQ :SKIPD
                LDX #GREEN
                LDA #$02
                JSR OC_COM2
                LDY #status
                LDA (CHARDL),Y
                AND #%11000000
                STA (CHARDL),Y
                JSR CALC_STATS
                JMP :SKIPD
:SKIPB          JSR CONTAGIOUS
:SKIPD          JSR NEXT_CHAR
                BCC :1

FIND_ENCOUNTR
            do  DEBUG_KEYS
                BIT $C061               ; left-option/alt
                BMI :FORCE_ENCOUNTER
                BIT $C062               ; right-option/alt
                BPL :NORMAL
                LDA :TOGGLE
                EOR #$FF
                STA :TOGGLE
                BMI :FORCE_ENCOUNTER
                BPL :FORCE_EQUIPMENT    ; always
:TOGGLE         DB  $00
:NORMAL
            fin

            ;*** TODO: need to put random encounters back in ***
            do 0
                JSR RANDOM
                AND #$7F
                CMP ENCODDS
                BCS FIND_ENCOUNTR
                CMP #$01
                BNE :FIND_EQUIPMNT
            else
                JMP NORMAL_MOVE
            fin

:FORCE_ENCOUNTER
                JSR PICK_HALLTYPE
            do ORIGINAL
            else
                LDA DISK_SIDE
                EOR #%00000110
                STA DISK_SIDE
            fin
                JSR SET_FGHTFILES
                LDX #fLoader1
                JSR SLOADER_FILE

                JMP FIGHT_LOADER

            do 0
:FIND_EQUIPMNT
                JSR RANDOM          ;Can't find equipment if
                                    ;   the random number isn't right...
                AND #$3F            ;????????
                CMP #$13            ;temp?
                BNE NORMAL_MOVE
            else
                DS  5
            fin

:FORCE_EQUIPMENT
                LDA BUFFER+4        ;   or they're facing a wall...
                CMP #$FF
                BEQ NORMAL_MOVE

                LDX FLAG12          ;   or if they just turned
                DEX                 ;   left, right or around...
                BEQ NORMAL_MOVE

                JSR RESET_CHRLIST   ;   or if they have no room
                JSR CSCAN_PUTABLE   ;   for equipment.
                BCC NORMAL_MOVE

                JSR PICK_HALLTYPE
                JSR SET_CAMPFILES
                LDX #cFindment
                JSR SLOAD_FILE
                JMP EQUIP_FINDER

NORMAL_MOVE     LDA HALL_UPDATED
                BEQ :EXIT
                LDA #$FF
:EXIT           RTS

CONTAGIOUS      LDY #status
                LDA (CHARDL),Y
                AND #%00111111
                CMP #illD
                BNE :EXIT
                JSR RANDOM
                AND #$1F
                BNE :EXIT
                LDA COUNT
                PHA
                LDY #inflictdelay
                LDA (CHARDL),Y
                STA :MOD1+1
                INY                 ;inflictamount
                LDA (CHARDL),Y
                STA :MOD2+1
                JSR RESET_CHLIST
                LDX #<NOSTATS
                LDY #>NOSTATS
                JSR CSCAN_COMMON
                TAY
                BEQ :SKIPA
                TXA
                JSR POINTIT
                LDY #status
                LDA (CHARDL),Y
                ORA #illD
                STA (CHARDL),Y
                LDY #inflictcount
:MOD1           LDA #$FF            ;MOD
                STA (CHARDL),Y
                INY                 ;inflictdelay
                STA (CHARDL),Y
:MOD2           LDA #$FF            ;MOD
                INY                 ;inflictamount
                STA (CHARDL),Y
                INY
                LDA #illDlength     ;number of inflictions of illD
                STA (CHARDL),Y
                JSR CALC_STATS
                LDA #$03
                JSR OC_COM1
:SKIPA          PLA
                STA COUNT
:EXIT           RTS

NOSTATS         LDY #status
                LDA (CHARDL),Y
                AND #%00111111
                RTS


DRAINER_FRACT   LDY #powerconsumpt
                LDA (CHARDL),Y
                STA TEMP+1
                INY
                LDA (CHARDL),Y
                STA TEMP

                LDX #3
                LDA #$00
:LOOP1          ASL TEMP
                ROL TEMP+1
                ROL
                DEX
                BPL :LOOP1
                PHA

                LDY #powerfraction+1
                LDA (CHARDL),Y
                SEC
                SED
                SBC TEMP
                STA (CHARDL),Y
                DEY
                LDA (CHARDL),Y
                SBC TEMP+1
                STA (CHARDL),Y
                CLD

                PLA
                TAX
                BCS :SKIPA
                INX
                CPX #$0A
                BNE :SKIPA
                LDX #$10
:SKIPA          LDY #0
                SEC
                JMP DRAIN_DIRECT2

PICK_HALLTYPE   LDA HALL_UPDATED
                BNE :EXIT
                DEC HALL_UPDATED
                LDA FLAG12
                CMP #$02
                BNE :SKIPA
                JMP SCANONE
:SKIPA          JSR HGR
                JMP NOSCAN
:EXIT           RTS

HALL_UPDATED    DB  $00


GONE_CRITICAL   LDA #$00
                BEQ OC_COM1         ;Always
OUT_OF_ENERGY   LDA #$01
OC_COM1         LDX #RED
OC_COM2         STX MESSAGE_COLOR
                TAX
                LDA COUNT
                PHA
                TXA
                PHA
                LDX #<COMMON_TEXT
                LDA #>COMMON_TEXT
                JSR SET_TEXT
                LDX #<MESSAGE_BOX
                LDY #>MESSAGE_BOX
                JSR INIT_BOX
                JSR PICK_HALLTYPE
                LDA #$40
                STA PAGE
                JSR CLEAR_OUTSIDE
                JSR DRAW_BOX
                PLA
                BPL :SKIPA
                PLA
                JMP DYIN_VECTOR
:SKIPA          PHA
                LDX #<CRITICAL_TEXT+3
                LDY #>CRITICAL_TEXT+3
                JSR FLUSH_NAME
                LDX #9
:LOOP1          LDA CRITICAL_TEXT+3,X
                STA RUNDOWN_TEXT+3,X
                STA CURED_TEXT+3,X
                STA CONTAG_TEXT+3,X
                DEX
                BPL :LOOP1
                PLA
                PHA
                TAY
                JSR TEXTER
                PLA
                CMP #$02
                BNE :SKIPB
                LDY #status
                LDA (CHARDL),Y
                AND #%00111111
                JSR STATUSR2
                JSR LINE2
                LDA #$2D
                STA TEXTBUF
                LDA #$8D
                STA TEXTBUF+1
                JSR LINE2
:SKIPB          JSR SWAP_BOX
                JSR SPACE_KEY
                JSR SWAP_BOX
                LDA #$20
                STA PAGE
                PLA
                STA COUNT
                RTS

MESSAGE_BOX     DDB 53
                DB  34
                DDB 227
                DB  54
MESSAGE_COLOR   DB  RED
                DB  wspace

COMMON_TEXT     DW  CRITICAL_TEXT
                DW  RUNDOWN_TEXT
                DW  CURED_TEXT
                DW  CONTAG_TEXT
                DW  ENERGY_TEXT

CRITICAL_TEXT   ;PLOTAT  64;37;(XXXXXXXXXX_IS_IN_CRITICAL)
                ;PLOTAT  64;45;(CONDITION.)+

RUNDOWN_TEXT    ;PLOTAT  64;37;(XXXXXXXXXX_HAS_RUN_OUT_OF)
                ;PLOTAT  64;45;(ENERGY.)+

CURED_TEXT      ;PLOTAT  64;37;(XXXXXXXXXX_IS_NO_LONGER)
                ;PLOTAT  64;45;()+

CONTAG_TEXT     ;PLOTAT  64;37;(XXXXXXXXXX_IS_BEGINNING)
                ;PLOTAT  64;45;(TO_FEEL_ILL.)+

ENERGY_TEXT     ;PLOTAT  101;45;(OUT_OF_ENERGY)+

; Line data for elevator, included here to pad out to end of page
;
EV_LINES        DW  BLKLINE
                DW  EBOX
                DW  BLKLIN2
                DW  EBOX2

BLKLINE         DB  $00,$45,$65
                DB  $00,$D2,$65
                DB  $FF

EBOX            DB  $00,$4F,$41
                DB  $00,$4F,$89
                DB  $00,$C7,$89
                DB  $00,$D3,$65
                DB  $00,$C7,$41
                DB  $00,$C7,$89
                DB  $FE
                DB  $00,$C8,$89
                DB  $00,$C8,$41
                DB  $00,$50,$41
                DB  $00,$44,$65
                DB  $00,$50,$89
                DB  $00,$50,$41
                DB  $FF

BLKLIN2         DB  $00,$66,$74
                DB  $00,$AE,$74
                DB  $FF

EBOX2           DB  $00,$6D,$86
                DB  $00,$6D,$62
                DB  $00,$65,$74
                DB  $00,$6D,$86
                DB  $00,$A7,$86
                DB  $00,$AF,$74
                DB  $00,$A7,$62
                DB  $00,$A7,$86
                DB  $FE
                DB  $00,$6D,$62
                DB  $00,$A7,$62
                DB  $FF
                DS  \,$EE

ENCODDS         DB  $1F             ;$EE LATER ;$01 FOR NO ENCOUNTERS

                FIN
