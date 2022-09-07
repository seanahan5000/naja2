
NameBoxTopY     =   11

MaxNameListCount =  13                  ; max window height in names
NameListMidIndex =  MaxNameListCount/2
NameListTopY     =  NameBoxTopY+8       ; in lines
NameListBottomY  =  MaxNameListCount*9+NameListTopY-1

NameBoxBottomY  =   NameListBottomY+6

ImageCornerWidth  = 22
ImageCornerLeft   = 40-ImageCornerWidth
ImageCornerTop    = 1
ImageCornerHeight = 153

STRACK          =   $B1
SSTOREH         =   $B2
DISK_SIDE       =   $B3

; TODO: switch to ENT-derived symbols
READ_VECTOR     =   $0406
ON_OFF_FLAG     =   $07F8

OFFSET_BUFFER   =   $9000
ALIEN_COUNT     =   $9000
OFFSET_TABLE    =   $9001
KNOWN_LIST      =   $9100
DATA_TABLE      =   $9200

KNOWN_INDEX     =   $C0
KNOWN_COUNT     =   $C1
ALIEN_SET       =   $C2

state_missing   =   0                   ; assumed to be zero
state_empty     =   1
state_drawn     =   2
state_overflow  =   3

ALIEN_STATE     =   $C3
DESC_STATE      =   $C4

; TODO: share with common?
PPIC            =   $C5
PPIC_H          =   $C6

; $C7
; $C8
; $C9
; $CA
WINDOW_TOP_ALIEN =  $CB                 ; alien index
WINDOW_HEIGHT   =   $CC                 ; <= MaxNameListCount
CURSOR_LINE     =   $CD                 ; index from 0 to WINDOW_HEIGHT-1
INDEX           =   $CE
ARROWS_VISIBLE  =   $CF

ALIEN_BASE_12   =   $0000           ; 12
ALIEN_BASE_345  =   $0100           ;  345

; TODO: Use typing to fast-scroll to alien? (just first letter? ignore quote)
; - page up and page down?
; - alphabetize names?
; - maybe pre-alphabetize?
; - loop list around?
; - load names from disk

IDENTIFIED_ALIENS
                LDA #0
                STA ALIEN_SET

                LDA #state_missing
                STA DESC_STATE
                LDA #state_overflow
                STA ALIEN_STATE

                JSR LOAD_OFFSETS
                ;*** leave drive spinning ***

                JSR BUILD_KNOWN_LIST

                LDA KNOWN_COUNT
                BNE :1
                JMP NO_KNOWN

:1              LDA #0
                STA WINDOW_TOP_ALIEN
                STA KNOWN_INDEX

                ; adjust offset and height when KNOWN_COUNT < max window height
                LDX #0
                LDY #MaxNameListCount
                CPY KNOWN_COUNT
                BCC :2
                LDY KNOWN_COUNT
:2              STX CURSOR_LINE
                STY WINDOW_HEIGHT

                LDX #$01+1
                LDA #$0F+1          ;***
                JSR SET_LINE_BOUNDS

AMAIN_LOOP      LDX ALIEN_STATE
;               CPX #state_missing
                BEQ :2
                CPX #state_drawn
                BEQ :1
                JSR COMPOSITE_EMPTY
                JMP :2

:1              JSR CLEAR_ALIEN
:2              LDA #state_missing
                STA ALIEN_STATE

                LDX DESC_STATE
                CPX #state_drawn
                BNE :4
                LDX #state_empty
                STX DESC_STATE
                JSR CLEAR_DESC
:4
                ;*** DO DRIVE SPIN-UP SEPARATELY AND ABORTABLY ***

                JSR LOAD_ALIEN
                BCS AKEY_LOOP

                JSR POSITION_ALIEN

                LDX #state_drawn
                LDA ALIEN_BOTTOM
                CMP #151
                BCS :5
                LDA ALIEN_LEFT
                CMP #ImageCornerLeft
                BCS :6
:5              LDX #state_overflow
:6              STX ALIEN_STATE
                CPX #state_overflow
                BNE :NO_OVERFLOW

                JSR COMPOSITE_ALIEN
                ;*** CHECK FOR ABORT?
                JMP :7

:NO_OVERFLOW    JSR DRAW_ALIEN
                JSR SHOULD_ABORT
                BCS AKEY_LOOP

:7
                JSR DRAW_DESC
                LDX #state_drawn
                STX DESC_STATE

AKEY_LOOP       LDA KEYBRD
                BPL AKEY_LOOP
                BIT UNSTROB

                JSR CHECK_UP
                BNE :1

                JSR ON_UP
                BCC AKEY_LOOP
                JMP AMAIN_LOOP

:1              JSR CHECK_DOWN
                BNE :2

                JSR ON_DOWN
                BCC AKEY_LOOP
                JMP AMAIN_LOOP

:2              JSR CHECK_ENTER
                BNE :3
                JSR ON_FULLSCREEN
                JMP AKEY_LOOP

:3              JSR CHECK_CANCEL
                BNE AKEY_LOOP
                ;*** return to main camp screen
                RTS

NO_KNOWN        JSR COMPOSITE_EMPTY
; TODO: make this GET_CANCEL in UTILS.S?
                BIT UNSTROB
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB
                JSR CHECK_CANCEL
                BNE :1
                RTS

ON_FULLSCREEN   JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictEnd

                JSR DRAW_HALL

                LDX PPIC
                LDY PPIC_H
                JSR UNPACK

                JSR DRAW_PICT
                PictShowPage
                PictEnd

                BIT UNSTROB
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB

                JSR DRAW_PICT
                PictSetPage1
                PictShowPage
                PictEnd
                RTS

ON_UP           LDX CURSOR_LINE
                DEX
                BMI :1
                CPX #NameListMidIndex
                BCS :2

                LDA WINDOW_TOP_ALIEN
                BEQ :2
                DEC WINDOW_TOP_ALIEN
                JSR SCROLL_NAMES_DOWN
                JSR UPDATE_ARROWS

                JSR DRAW_PICT
                PictClear $01+1;NameListTopY;$0F+1;NameListTopY+9
                PictEnd

                LDX #0
                JSR DRAW_ALIEN_NAME
                JMP :3

:1              CLC
                RTS

:2              TXA
                PHA
                JSR DRAW_NAME_CURSOR
                PLA
                STA CURSOR_LINE
                JSR DRAW_NAME_CURSOR

:3              DEC KNOWN_INDEX
                SEC
                RTS

ON_DOWN         LDX CURSOR_LINE
                INX
                CPX #NameListMidIndex+1
                BCC :1

                LDA WINDOW_TOP_ALIEN
                CLC
                ADC WINDOW_HEIGHT
                CMP KNOWN_COUNT
                BCS :1
                INC WINDOW_TOP_ALIEN
                JSR SCROLL_NAMES_UP
                JSR UPDATE_ARROWS

                JSR DRAW_PICT
                PictClear $01+1;NameListBottomY-9;$0F+1;NameListBottomY
                PictEnd

                LDX WINDOW_HEIGHT
                DEX
                JSR DRAW_ALIEN_NAME
                JMP :3

:1              CPX WINDOW_HEIGHT
                BNE :2
                CLC
                RTS

:2              TXA
                PHA
                JSR DRAW_NAME_CURSOR
                PLA
                STA CURSOR_LINE
                JSR DRAW_NAME_CURSOR
:3              INC KNOWN_INDEX
                SEC
                RTS

COMPOSITE_EMPTY JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictEnd
                JMP COMPOSITE_CMN

COMPOSITE_ALIEN JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictEnd

                JSR DRAW_ALIEN
                ;*** abort?

                JSR DRAW_PICT
                PictClear 0;0;17;NameBoxBottomY+12
                PictClear 0;153;40;192
                PictEnd
                ; fall through

COMPOSITE_CMN   JSR DRAW_PICT
                PictTextAt 10;NameBoxTopY-9;(IDENTIFIED_ALIENS)
                PictSetViolet
                PictRect 4;NameBoxTopY;116;NameBoxBottomY
                PictSetGreen
                PictRect 3;154;277;191
                PictEnd

                LDA KNOWN_COUNT
                BEQ :1

                JSR DRAW_PICT
                PictTextAt 4;NameBoxBottomY+3;(FULL_SCREEN_<SPACE>)
                PictEnd

                JSR DRAW_ALIEN_NAMES
                ;*** abort?

                LDA #0
                STA ARROWS_VISIBLE
                JSR UPDATE_ARROWS

                JSR DRAW_NAME_CURSOR
                JMP :2

:1              JSR DRAW_PICT
                PictTextAt 34;73;(NONE_YET)
                PictTextAt 37;82;(C>ANCEL)
                PictEnd

:2              JSR DRAW_PICT
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                LDA #state_empty
                STA DESC_STATE
                RTS

SCROLL_NAMES_UP LDX #NameListTopY
:1              JSR SET_DEST_LINE
                LDA LOBYTES+9,X
                STA SCREENL
                LDA HIBYTES+9,X
                STA SCREENH
                ; TODO: SetSourceLine +9
                JSR COPY_LINE
                INX
                CPX #NameListBottomY-9
                BNE :1
                RTS

SCROLL_NAMES_DOWN
                LDX #NameListBottomY-1
:1              JSR SET_DEST_LINE
                LDA LOBYTES-9,X
                STA SCREENL
                LDA HIBYTES-9,X
                STA SCREENH
                ; TODO: SetSourceLine -9
                JSR COPY_LINE
                DEX
                CPX #NameListTopY+8
                BNE :1
                RTS

UPDATE_ARROWS   LDX #0
                LDA WINDOW_TOP_ALIEN
                BEQ :1
                INX
:1              CLC
                ADC WINDOW_HEIGHT
                CMP KNOWN_COUNT
                BCS :2
                INX
                INX
:2              TXA
                EOR ARROWS_VISIBLE
                STX ARROWS_VISIBLE
                LSR
                BCC :3
                PHA
                JSR DRAW_UP_ARROW
                PLA
:3              LSR
                BCC :4
                JSR DRAW_DOWN_ARROW
:4              RTS

DRAW_UP_ARROW   JSR DRAW_PICT
                PictMoveTo 16;NameBoxTopY+2
                PictEnd
                LDX #<UP_ARROW
                LDY #>UP_ARROW
                JMP DRAW_TILE

DRAW_DOWN_ARROW JSR DRAW_PICT
                PictMoveTo 16;NameBoxBottomY-5
                PictEnd
                LDX #<DOWN_ARROW
                LDY #>DOWN_ARROW
                JMP DRAW_TILE

UP_ARROW        DB  %00001000
                DB  %00011100
                DB  %00111110
                DB  %01111111
                DB  %00000000
                DB  %00000000
                DB  %00000000

DOWN_ARROW      DB  %01111111
                DB  %00111110
                DB  %00011100
                DB  %00001000
                DB  %00000000
                DB  %00000000
                DB  %00000000
;
; On exit:
;   A: unchanged
;   X: unchanged
;   Y: unchanged
;   C: 1 when abort should happen
;
SHOULD_ABORT    PHA
                LDA KEYBRD
                BPL :NO_ABORT
                JSR CHECK_CANCEL
                BEQ :ABORT
                JSR CHECK_UP
                BNE :1
                LDA KNOWN_INDEX
                BNE :ABORT
:NO_ABORT       CLC
                PLA
                RTS
:1              JSR CHECK_DOWN
                BNE :NO_ABORT
                LDA KNOWN_INDEX
                CLC
                ADC #1
                CMP KNOWN_COUNT
                BEQ :NO_ABORT
:ABORT          SEC
                PLA
                RTS

LOAD_OFFSETS    LDA #$00
                STA DISK_SIDE
                LDA #>OFFSET_BUFFER
                STA SSTOREH
                LDA #%00000000          ; spin up/down
                STA ON_OFF_FLAG
                LDX #<ALIEN_BASE_12
                LDY #>ALIEN_BASE_12
                LDA ALIEN_SET
                BEQ :1
                LDX #<ALIEN_BASE_345
                LDY #>ALIEN_BASE_345
:1              LDA #1                  ; one sector
                JMP READ_VECTOR

BUILD_KNOWN_LIST
                LDX #KNOWN_ALIENS_12-KNOWN_ALIENS_12
                LDA #KNOWN_ALIENS_345-KNOWN_ALIENS_12
                LDY ALIEN_SET
                BEQ :1
                LDX #KNOWN_ALIENS_345-KNOWN_ALIENS_12
                LDA #KNOWN_ALIENS_END-KNOWN_ALIENS_12
:1              STA :MOD+1
                LDA #0
                STA KNOWN_COUNT
                TAY
:2              DEY
                LDA KNOWN_ALIENS_12,X
                SEC
:3              INY
                ROL
                BCC :3
                BEQ :4
                PHA
                STX INDEX
                TYA
                LDX KNOWN_COUNT
                STA KNOWN_LIST,X
                INC KNOWN_COUNT
                LDX INDEX
                PLA
                CLC
                BCC :3                  ; always
:4              INX
:MOD            CPX #$FF
                BNE :2
                RTS

CLEAR_DESC      JSR DRAW_PICT
                PictClear $01;155;$27;191
                PictEnd
                RTS

DRAW_DESC       JSR DRAW_PICT
                PictSetPage2
                PictClear $01;155;$27;191
                PictSetTextBox 7;156;277;191
                PictTextIn (THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)
                PictTextIn (_THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)
                PictTextIn (_THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)
                PictSetPage1
                PictCopyTo 1;156;39;190
                PictEnd
                RTS

CLEAR_ALIEN     LDA ALIEN_LEFT
                CMP ALIEN_RIGHT
                BNE :1
                RTS
:1              JSR DRAW_PICT
                DB  OpClear
ALIEN_LEFT      DB  $00
ALIEN_TOP       DB  $00
ALIEN_RIGHT     DB  $00
ALIEN_BOTTOM    DB  $00
                PictEnd
                RTS

START_OFFSET_H  =   LOCAL_TEMP+0
END_OFFSET_L    =   LOCAL_TEMP+1
END_OFFSET_H    =   LOCAL_TEMP+2

LOAD_ALIEN      LDX KNOWN_INDEX
                LDA KNOWN_LIST,X
                ASL
                TAX
                LDA OFFSET_TABLE+0,X
                STA POSITION_ALIEN+1    ; START_OFFSET_L
                LDA OFFSET_TABLE+1,X
                STA START_OFFSET_H

                LDA OFFSET_TABLE+2,X
                STA END_OFFSET_L
                LDA OFFSET_TABLE+3,X
                STA END_OFFSET_H

                LDA #>DATA_TABLE
                STA SSTOREH
                LDA #%00000000          ; spin up/down
                STA ON_OFF_FLAG

                LDX END_OFFSET_H
                LDA END_OFFSET_L
                BEQ :2
                INX
:2              TXA
                SEC
                SBC START_OFFSET_H
                PHA                     ; SECTOR COUNT

                LDY #>ALIEN_BASE_12     ; T/S base high
                LDA #<ALIEN_BASE_12     ; T/S base low
                LDX ALIEN_SET
                BEQ :3
                LDY #>ALIEN_BASE_345    ; T/S base high
                LDA #<ALIEN_BASE_345    ; T/S base low
:3              CLC
                ADC START_OFFSET_H
                TAX
                BCC :4
                INY
:4              PLA
                JSR READ_VECTOR
                ;*** ONCE PER SECTOR ***
                JMP SHOULD_ABORT

POSITION_ALIEN  LDA #$FF                ; START_OFFSET_L
                STA PPIC
                LDA #>DATA_TABLE
                STA PPIC_H

                LDY #0
                LDA (PPIC),Y
                AND #$01
                STA XCOORD
                INY
                INY
                LDA #ImageCornerWidth
                SEC
                SBC (PPIC),Y
                BCC :1
                ADC #0
                LSR A
                CLC
:1              ADC #ImageCornerLeft
                BPL :2
                LDA #0               ; special case full width (THROWER)
:2              AND #$FE
                ORA XCOORD
                TAX
                CLC
                ADC (PPIC),Y
                STA ALIEN_RIGHT
                CMP #41
                BCC :22
                DEX
                DEX
                DEC ALIEN_RIGHT
                DEC ALIEN_RIGHT
:22             STX XCOORD
                STX ALIEN_LEFT
                LDA #0
                STA XSHIFT
                INY

                LDA #ImageCornerHeight
                SEC
                SBC (PPIC),Y
                BCC :3
                LSR A
                CLC
:3              ADC #ImageCornerTop
                BPL :4
                LDA #ImageCornerTop     ; special case full height (THROWER)
:4              STA YCOORD
                STA ALIEN_TOP
                CLC
                ADC (PPIC),Y
                STA ALIEN_BOTTOM
                RTS

DRAW_ALIEN      LDX PPIC
                LDY PPIC_H
                JMP UNPACK_TO

DRAW_NAME_CURSOR
                LDX CURSOR_LINE
                LDY ALIEN_NAME_LINES,X
                LDX #1+7
                JMP DRAW_TRIANGLE

DRAW_ALIEN_NAMES
                LDX #0
:1              STX INDEX
                JSR DRAW_ALIEN_NAME
                LDX INDEX
                INX
                CPX WINDOW_HEIGHT
                BNE :1
                RTS
;
; On entry:
;   X: cursor index
;
DRAW_ALIEN_NAME TXA
                PHA
                CLC
                ADC WINDOW_TOP_ALIEN
                JSR GET_ALIEN_NAME

                PLA
                TAX
                LDY ALIEN_NAME_LINES,X
                LDX #9+7
                JSR DRAW_TEXTBUF_XY
                RTS

ALIEN_NAME_LINES
                DB  0*9+NameListTopY
                DB  1*9+NameListTopY
                DB  2*9+NameListTopY
                DB  3*9+NameListTopY
                DB  4*9+NameListTopY
                DB  5*9+NameListTopY
                DB  6*9+NameListTopY
                DB  7*9+NameListTopY
                DB  8*9+NameListTopY
                DB  9*9+NameListTopY
                DB  10*9+NameListTopY
                DB  11*9+NameListTopY
                DB  12*9+NameListTopY
                ERR 13-MaxNameListCount
;
; On entry:
;   A: alien index
;
PTR             =   LOCAL_TEMP+0
PTR_H           =   LOCAL_TEMP+1

GET_ALIEN_NAME  TAX
                LDA KNOWN_LIST,X
                LDX #0
                STX PTR_H
:1              ASL
                ROL PTR_H
                INX
                CPX #4
                BNE :1
                STA PTR

                LDA #<ALIEN_NAMES_12
                LDY #>ALIEN_NAMES_12
                LDX ALIEN_SET
                BEQ :2
                LDA #<ALIEN_NAMES_345
                LDY #>ALIEN_NAMES_345
:2              CLC
                ADC PTR
                STA PTR
                TYA
                ADC PTR_H
                STA PTR_H

                LDY #0
:3              LDA (PTR),Y
                STA TEXT_BUFFER,Y
                INY
                CPY #16
                BNE :3

:4              DEY
                LDA TEXT_BUFFER,Y
                CMP #TextSpace
                BEQ :4
                LDA #TextLineEnd
                STA TEXT_BUFFER+1,Y
                RTS

ALIEN_NAMES_12  USR ("AIR_SWIMMER"___)-     ; AIR_SWIMMER
                USR (ARMORED_ALIEN___)-     ; ARMOR_ALIEN
                USR ("BARACKADE"_____)-     ; BARACKADER
                USR (WINGED_"BUG-EYE")-     ; BIRD_INSECT
                USR (AIMTAK_AMPHIBIAN)-     ; BLOW_DART
                USR (PSILOTIS_PEDETUM)-     ; BRANCHES
                USR ("FROWNER"_______)-     ; BTWN_LEGS
                USR (JUNGLE_SWINGER__)-     ; CEIL_SWINGER
                USR (TANDEM_TENTICLES)-     ; CEILING_FAN
                USR ("BLAST_CLAPPER"_)-     ; CLAPPER
                USR ("LOOP_HEAD"_____)-     ; CLUBBER
                USR (ANKAA_STRANGLER_)-     ; CONSTRICTOR
                USR (LANTHOSER_______)-     ; CROSS_BOW
                USR ("DIZZY"_________)-     ; DIZZY
                USR ("FINGERS"_______)-     ; FINGERS
                USR (K-60_FIRE_UNIT__)-     ; FIRE_MAN
                USR (FROBOT__________)-     ; FROG_BOT
                USR ("SHOVELER"______)-     ; FURNACE
                USR (ORGANISM_CLOUD__)-     ; GAS_CLOUD
                USR (MPC3_ROBOT______)-     ; HANGING_BOT
                USR (VEGAN_WARRIOR___)-     ; HOLSTER
                USR (GRUNTER_PACK_DOG)-     ; HORNED_DOG
                USR (ULLDA_NICH______)-     ; IN_WEB
                USR (WORKER_INSECT___)-     ; INSECT1         ;Duplicated
                USR (LEASHED_GRUNTER_)-     ; LEASHED_DOGS
                USR (POISONOUS_PEST__)-     ; LITTLE_BUG
                USR (SPICA_V_FIGHTER_)-     ; LITTLE_PLANES
                USR (ADHARAN_LIZARD__)-     ; LIZARD
                USR (LONG_ARMED_EPE__)-     ; LONG_ARM
                USR (METAL_MITES_____)-     ; METAL_MITES
                USR ("OILER"_________)-     ; OILER
                USR (AMOEBOID________)-     ; OMEBA
                USR (MONOPTIC_HOPPER_)-     ; ONE_EYE
                USR (PARTICLE_MAN____)-     ; PARTICLE_MAN
                USR (RIGELIAN_SNIPER_)-     ; PEEKER
                USR (BURROWING_TAAN__)-     ; PER_ALIEN
                USR ("DRAGON_FLY"____)-     ; PINK_WINGS
                USR (BETA_CENTAURIAN_)-     ; PLATFORM
                USR (POINTY_HEAD_____)-     ; POINTY_HEAD
                USR (PROBE_DROID_____)-     ; PROBOT
                USR (MEERN_MUTATION__)-     ; RAG_ALIEN
                USR (MEERN_MUTATION__)-     ; RAG_SWORD
                USR (REPAIR_UNIT_1000)-     ; REPAIR_UNIT
                USR (ROBIEN_BRAIN____)-     ; ROBIEN
                USR (ROBOTROID_______)-     ; ROBOT
                USR (RUUIK'S_SOLDIER_)-     ; RUUIKS_MEN
                USR (SCAVENGER_______)-     ; SCAVENGER
                USR (SHIELDED_OOMAR__)-     ; SHIELD
                USR ("HEXICLAW"______)-     ; SIX_ARM
                USR ("SNOOZER"_______)-     ; SLEEPY
                USR (SLICER_SPHERE___)-     ; SLICER
                USR (MUTANT_INSECTOID)-     ; SNOUT
                USR ("SUBZERO"_______)-     ; SNOW_JOB
                USR (SPACE_MAN_______)-     ; SPACE_MAN
                USR (FLYING_SAUCER___)-     ; SPACE_SHIP
                USR (NUNKI_BLUE_DEVIL)-     ; SPOOL_ALIEN
                USR (SPOOR_PLANT_____)-     ; SPOOR_PLANT
                USR ("SQUINTER"______)-     ; SQUINTER
                USR (SCEPTARIAN______)-     ; STAFF
                USR (NUNKI_STARBEAST_)-     ; STARBURST
                USR (????????????????)-     ; STICKY
                USR ("STINKY"________)-     ; STINKY
                USR (ACRUXITE________)-     ; STRINGY_HAND
                USR (TENTICLES_______)-     ; TENTICLE
                USR (PROTOTYPE_2000-7)-     ; TREADED_BOT
                USR (UNKNOWN_PLANT___)-     ; TREE_ALIEN
                USR (ELATION_TRAITOR_)-     ; TRUNK
                USR ("TWISTER"_______)-     ; TWISTER
                USR (ENERGY_UNLOADER_)-     ; UNLOADER
                USR (MOIKLER_________)-     ; WATER_TOWER
                USR (ROLLER_ALIEN____)-     ; WIERD_ALIEN
                USR (PHASE_WORM______)-     ; WORMS

ALIEN_NAMES_345 USR (ACID_SPITTER____)-     ; ACID_SPITTER
                USR (PORTABLE_AIRLOCK)-     ; AIRLOCK
                USR (TALUMA_AND_MOUNT)-     ; ALIEN_ON
                USR (ANTICIPATOR_____)-     ; ANTISIPATOR
                USR (ATOM_ARRANGER___)-     ; ATOM_SHIFTER
                USR (PLASMANOID______)-     ; BLACK_ALIEN
                USR (CARNIVORE_______)-     ; CARNIVORE
                USR (CENTAURIAN_ROBOT)-     ; CENTAUR
                USR (ENCEPHALOID_____)-     ; CLOAKED_ALIEN
                USR (COOLING_UNIT____)-     ; COOLER
                USR (NAJA_MIND_SLAVE_)-     ; CORE_ALIEN
                USR (TRIPED_IV_ROBOT_)-     ; CYLINDER_BOT
                USR (ION_DIODE_ROBOT_)-     ; DIODE_ROBOT
                USR (STATION_DRILLER_)-     ; DRILLER
                USR (DUALTRONIC_ROBOT)-     ; DUAL_HEAD
                USR (SOLICIAN________)-     ; EARS
                USR (VEGAN_EXPLODER__)-     ; EXPLODE
                USR (PSEUDOMORT______)-     ; FAKER
                USR (MECHANICO_450___)-     ; FOUR_SWORDS
                USR (TRACC_FUNGUS____)-     ; FUNGUS
                USR (TRANSPARENT_____)-     ; GLASS_GUY
                USR (INFRA-FLOURINOID)-     ; GLOWER
                USR (BLAST_BREATHER__)-     ; GODZILLA
                USR (CEREBROMORPH____)-     ; GREEN_HEAD
                USR (PUDDLE_CREATURE_)-     ; GREEN_PUDDLE
                USR (ADHARAN_GREMLIN_)-     ; GREMLIN
                USR (THERMAL_UNIT____)-     ; HEATER
                USR (HAMELER_HOT_HEAD)-     ; HOT_HEAD
                USR (INFORMER________)-     ; INFORMER
                USR (FIGHTER_INSECT__)-     ; INSECT2         ;Duplicated
                USR (INVERSION_ALIEN_)-     ; INVERSE
                USR (INVISIBLE_ALIEN_)-     ; INVISIBLE
                USR (INTRUDER_MISSILE)-     ; KAMAKAZE
                USR (SPECTRAMITE_____)-     ; LIGHT_ALIEN
                USR (LITTLE_MEN______)-     ; LITTLE_MEN
                USR (MAGNETIC_SWEEPER)-     ; MAGNET
                USR ("MISER"_________)-     ; MISER
                USR (ASYMMETRIC_ALIEN)-     ; ONE_ARM_BLOB
                USR (PHASOID_________)-     ; PHASOID
                USR ("GASSER"________)-     ; POISON_SUIT
                USR (MEM-PLACER_ROBOT)-     ; PROG_CHANGER
                USR ("SPIKE"_________)-     ; PUNKER
                USR (QUEEN_INSECT____)-     ; QUEEN_INSECT
                USR (SNARC___________)-     ; RABBIT_EARS
                USR ("SPEEDO"________)-     ; REFLEX_ALIEN
                USR (RICOCHET_MISSILE)-     ; RICOCHET
                USR (EBKAL'EE________)-     ; ROBED_SELLER
                USR (ALIEN_ASSASSIN__)-     ; RUNNING_BOT
                USR ("SCREECHER"_____)-     ; SCREAMER
                USR (ZETOC___________)-     ; SEVEN_CLAWS
                USR ("SHARP_SHOOTER"_)-     ; SHARP_SHOOTER
                USR (SHIFTER_________)-     ; SHIFTER
                USR (SPARKLE_________)-     ; SPARKLES
                USR (SLIME_CREATURE__)-     ; SWAMP_THING
                USR (BETEIGUESEN_____)-     ; TAILFIGHTER
                USR (TANGIBLE_GAS____)-     ; TANGIBLE_GAS
                USR (MAN_IN_LEVITATOR)-     ; TANK_HUMAN
                USR ("BLINKER"_______)-     ; TELEPORTER
                USR ("MAULER"________)-     ; TF_BAIT
                USR ("THROWER"_______)-     ; THROWER
                USR (TIME_WARP_______)-     ; TIME_WARP
                USR (OKKAR_MARSUPIAL_)-     ; TREE_HANGER
                USR (WANDERIN_THOUGHT)-     ; WANDERING
                USR (WEBBED_PARASITE_)-     ; WEB_THING
                USR (AIR_CIRCULATOR__)-     ; WIND_TUNNEL
