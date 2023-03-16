
                PUT /NAJA/VARS/CONSTANTS

                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

                PUT /NDOS/EXT

CONTROL_MODULE  =   $7800
SET_CONTROL     =   $7801

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

                STA $C050           ;graphics mode
                STA $C057           ;hires mode

                STA $C08B           ;read/write $D000-$FFFF, BANK 1
                STA $C08B

                LDA #$FF            ; reset module present value
                STA $A000

                LDA CONTROL_MODULE
                SEC
                SBC #fileControl17-1
                TAX
                STX SHELL
                LDA :DISK_SIDES-1,X
                JSR SET_DISK_SIDE

                LDA #5
                STA MAP_FACE
                LDA #2
                STA MAP_X
                LDA #4
                STA MAP_Y
                LDA #3
                STA MAP_DIR

                LDA #6
                STA RANGE

                JSR SET_CONTROL
                JSR COMPUTE_MAP_PTR
                JSR RESTORE_MAPPED

                JSR GET_NSEW
                JSR DRAW_HALL
                JMP HALL_KEYS

:DISK_SIDES     DB  side_T1             ; 17
                DB  side_T1             ; 15
                DB  side_T2             ; 13
                DB  side_T2             ; 11
                DB  side_T2             ;  9
