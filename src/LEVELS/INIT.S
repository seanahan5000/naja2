
                PUT /NAJA/VARS/CONSTANTS
                PUT /NDOS/EXT
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                PUT /CAMP/EXT

CONTROL_MODULE  =   $7000
SET_CONTROL     =   $7001

                ORG $AF00
CONTROL_BOOT    JSR INIT_RANDOM
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

                STA $C00D           ;*** enable 80 column text

                STA $C050           ;graphics mode

                STA $C07E           ;*** enable double switch
                STA $C05E           ;*** enable double graphics

                STA $C057           ;hires mode

                STA $C05F           ;*** disable double graphics

                STA $C08B           ;read/write $D000-$FFFF, BANK 1
                STA $C08B

                LDA #$FF            ; reset module present value
                STA $A000

                LDA CONTROL_MODULE
                SEC
                SBC #fileControlMS
                TAX
                STX SHELL
                LDA DISK_SIDES,X
                JSR SET_DISK_SIDE

                LDA #0                  ; clear expedition totals
                LDX #11                 ; assumes 4 bytes per field
:1              STA TOTAL_KILLS,X
                DEX
                BPL :1

                LDA SHELL
                ASL
                ASL
                TAY
                LDX #0
:2              LDA POSITIONS,Y
                STA MAP_FACE,X
                INY
                INX
                CPX #4
                BNE :2

                LDA #6
                STA RANGE

                JSR SET_CONTROL
                JSR COMPUTE_MAP_PTR

                JSR GET_NSEW
                JSR DRAW_HALL
                JMP HALL_KEYS

POSITIONS       DB  0,9,9,NORTH         ; mothership
                ;DB  0,5,4,EAST         ; mothership
                DB  5,7,15,EAST         ; shell 17
                DB  5,2,4,3             ; shell 15
                DB  5,2,4,3             ; shell 13
                DB  0,9,3,EAST          ; shell 11 (prison)
                DB  5,2,4,3             ; shell 9

                SAV INIT.AF00
