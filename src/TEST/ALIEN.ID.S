

STRACK          =   $B1
SSTOREH         =   $B2
DISK_SIDE       =   $B3

READ_VECTOR     =   $0406
ON_OFF_FLAG     =   $07F8

OFFSET_BUFFER   =   $9000
ALIEN_COUNT     =   $9000
OFFSET_TABLE    =   $9001
DATA_TABLE      =   $9100

ALIEN_INDEX     =   $60
START_OFFSET_L  =   $61
START_OFFSET_H  =   $62
END_OFFSET_L    =   $63
END_OFFSET_H    =   $64

; 0: missing
; 1: drawn
; 2: overflow
ALIEN_STATE     =   $65

; 0: missing
; 1: box empty
; 2: has description
DESC_STATE      =   $66

; TODO: share with common?
DATAL           =   $67
DATAH           =   $68

CORNER_WIDTH    =   22
CORNER_LEFT     =   40-CORNER_WIDTH
CORNER_TOP      =   1
CORNER_HEIGHT   =   151

; ALIEN_BASE      =   $0000           ; 123
ALIEN_BASE      =   $0100           ;  45

; TODO: Need bits to track if alien has been seen and/or identified
; TODO: Start with some aliens identified to start
; TODO: Find data about aliens before encountering them (data cards?)
; TODO: Option to show graphic full screen over a tunnel?

ALIEN_DIRECTORY LDA #$00
                STA ALIEN_INDEX
                STA DESC_STATE
                LDA #$02
                STA ALIEN_STATE

                JSR LOAD_OFFSETS
                ;*** leave drive spinning ***

:MAIN_LOOP
                LDX ALIEN_STATE
                BEQ :2
                DEX
                BEQ :1
                JSR CLEAR_PAGE
                JSR DRAW_PICT
                PictTextAt 12;8;(IDENTIFIED_ALIENS)
                PictEnd
                JSR DRAW_ALIEN_LIST
                LDA #0
                STA DESC_STATE
                BEQ :2              ; always
:1              JSR CLEAR_ALIEN
:2              LDA #0
                STA ALIEN_STATE

                LDX DESC_STATE
                BNE :3
                INX
                STX DESC_STATE
                JSR DRAW_PICT
                PictSetGreen
                PictRect 3;152;277;191
                PictEnd
                JMP :4
:3              DEX
                BEQ :4
                STX DESC_STATE
                JSR CLEAR_DESC
:4
                ;*** DO DRIVE SPIN-UP SEPARATELY AND ABORTABLY ***

                JSR LOAD_ALIEN
                BCS :KEY_LOOP

                JSR POSITION_ALIEN

                LDX #1              ; drawn
                LDA ALIEN_BOTTOM
                CMP #151
                BCS :5
                LDA ALIEN_LEFT
                CMP #CORNER_LEFT
                BCS :6
:5              LDX #2              ; overflow
:6              STX ALIEN_STATE

                JSR DRAW_ALIEN
                BCS :KEY_LOOP

                LDA ALIEN_STATE
                CMP #2
                BNE :7              ; overflow
                JSR DRAW_PICT
                PictClear $00;151;$28;192
                PictSetGreen
                PictRect 3;152;277;191
                PictEnd
                JSR SHOULD_ABORT
                BCS :KEY_LOOP
:7
                JSR DRAW_DESC
                LDX #2
                STX DESC_STATE

:KEY_LOOP       LDA KEYBRD
                BPL :KEY_LOOP
                BIT UNSTROB

                JSR CHECK_UP
                BNE :8
                LDX ALIEN_INDEX
                BEQ :KEY_LOOP
                DEX
                STX ALIEN_INDEX
                JMP :MAIN_LOOP

:8              JSR CHECK_DOWN
                BNE :9
                LDX ALIEN_INDEX
                INX
                CPX ALIEN_COUNT
                BEQ :KEY_LOOP
                STX ALIEN_INDEX
                JMP :MAIN_LOOP

:9              JSR CHECK_CANCEL
                BNE :KEY_LOOP
                RTS
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
                LDA ALIEN_INDEX
                BNE :ABORT
:NO_ABORT       CLC
                PLA
                RTS
:1              JSR CHECK_DOWN
                BNE :NO_ABORT
                LDA ALIEN_INDEX
                CLC
                ADC #1
                CMP ALIEN_COUNT
                BEQ :NO_ABORT
:ABORT          SEC
                PLA
                RTS

LOAD_OFFSETS    LDA #$00
                STA DISK_SIDE
                LDA #>OFFSET_BUFFER
                STA SSTOREH
                LDA #%00000000      ; spin up/down
                STA ON_OFF_FLAG
                LDX #<ALIEN_BASE
                LDY #>ALIEN_BASE
                LDA #1              ; one sector
                JMP READ_VECTOR

DRAW_ALIEN_LIST JSR DRAW_PICT
                PictMoveTo 12;46
                PictText ()-
                USR (SPACE_MAN______X\n)-
                USR ("AIR_SWIMMER"__X\n)-
                USR (SHIELDED_OOMAR_X\n)-
                USR (MONOPTIC_HOPPERX\n)-
                USR (MEERN_MUTATION_X\n)-
                USR (BURROWING_TAAN_X\n)-
                USR (JUNGLE_SWINGER_X\n)
                PictEnd
                RTS

CLEAR_DESC      JSR DRAW_PICT
                PictClear $01;153;$27;191
                PictEnd
                RTS

DRAW_DESC       JSR DRAW_PICT
                PictSetTextBox 7;155;277;191
                PictTextIn (THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)
                PictTextIn (_THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)
                PictTextIn (_THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)
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

LOAD_ALIEN      LDA ALIEN_INDEX
                ASL A
                TAX
                LDA OFFSET_TABLE+0,X
                STA START_OFFSET_L
                LDA OFFSET_TABLE+1,X
                STA START_OFFSET_H
                LDA OFFSET_TABLE+2,X
                STA END_OFFSET_L
                LDA OFFSET_TABLE+3,X
                STA END_OFFSET_H

                LDA #>DATA_TABLE
                STA SSTOREH
                LDA #%00000000      ; spin up/down
                STA ON_OFF_FLAG

                LDX END_OFFSET_H
                LDA END_OFFSET_L
                BEQ :2
                INX
:2              TXA
                SEC
                SBC START_OFFSET_H
                PHA                 ; SECTOR COUNT

                LDY #>ALIEN_BASE    ; T/S base high
                LDA #<ALIEN_BASE    ; T/S base low
                CLC
                ADC START_OFFSET_H
                TAX
                BCC :3
                INY
:3              PLA
                JSR READ_VECTOR
                ;*** ONCE PER SECTOR ***
                JMP SHOULD_ABORT

POSITION_ALIEN  LDA START_OFFSET_L
                STA DATAL
                LDA #>DATA_TABLE
                STA DATAH

                LDY #0
                LDA (DATAL),Y
                AND #$01
                STA XCOORD
                INY
                INY
                LDA #CORNER_WIDTH
                SEC
                SBC (DATAL),Y
                BCC :1
                ADC #0
                LSR A
                CLC
:1              ADC #CORNER_LEFT
                BPL :2
                LDA #0               ; special case full width (THROWER)
:2              AND #$FE
                ORA XCOORD
                TAX
                CLC
                ADC (DATAL),Y
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

                LDA #CORNER_HEIGHT
                SEC
                SBC (DATAL),Y
                BCC :3
                LSR A
                CLC
:3              ADC #CORNER_TOP
                BPL :4
                LDA #CORNER_TOP     ; special case full height (THROWER)
:4              STA YCOORD
                STA ALIEN_TOP
                CLC
                ADC (DATAL),Y
                STA ALIEN_BOTTOM
                RTS

DRAW_ALIEN      LDX DATAL
                LDY DATAH
                JSR UNPACK_TO
                JMP SHOULD_ABORT
