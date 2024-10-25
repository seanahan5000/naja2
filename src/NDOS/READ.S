
; NOTES:
; - this does not handle switching between slots
; - 32 cyles max between reading data latch
; - wrong sectors are included in retry count

SLOT_X0         =   $B0                 ; assumed to be zpage for timing
DISK_SIDE       =   $B1
SSTOREH         =   $B2

; must be contiguous in this order
TARGET_PSECTOR  =   $B3                 ; physical sector
TARGET_FTRACK   =   $B4
TARGET_VOLUME   =   $B5

LSECTOR         =   $B6                 ; used in READ_SECTORS
SECCOUNT        =   $B7                 ; used in READ_SECTORS
MONCNTL         =   $B8
MONCNTH         =   $B9
ZTEMP0          =   $BA
ZTEMP1          =   $BB
ZTEMP2          =   $BC
;
;
;

BUFFER1         =   $0200
BUFFER2         =   $0300

DRIVE_SM0       =   $C080               ; stepper motor positions 0-7
DRIVE_OFF       =   $C088
DRIVE_ON        =   $C089
DRIVE_ENABLE1   =   $C08A
DRIVE_ENABLE2   =   $C08B
DRIVE_READ      =   $C08C
DRIVE_WRITE     =   $C08D
DRIVE_READMODE  =   $C08E
DRIVE_WRITEMODE =   $C08F

VOLUME_MASK     =   %10111111           ; mask off volume bits
VOLUME_BITS     =   %01000000           ; apply volume bits

; motor on time in 100 microseconds (1 second total)
MOTOR_ON_DELAY  =   $D8EF               ; -0x2710 == #-10000

MAX_RECALS      =   2
MAX_RESEEKS     =   4
MAX_RETRIES     =   $30                 ; 48 retries of any kind

;---------------------------------------

INDEX           =   ZTEMP0

;
; On entry:
;   X: SLOT_X0
;
READ_DATA       LDY #$20                ; nibbles before header must be found
:1              DEY
                BEQ READ_ERROR
:2              LDA DRIVE_READ,X
                BPL :2
:3              EOR #$D5
                BNE :1
                NOP
:4              LDA DRIVE_READ,X
                BPL :4
                CMP #$AA
                BNE :3
                LDY #$56                ; nibble delay, too
:5              LDA DRIVE_READ,X
                BPL :5
                CMP #$AD
                BNE :3
                LDA #$00                ; init checksum
:6              DEY
                STY INDEX
:7              LDY DRIVE_READ,X
                BPL :7
                EOR DENIBBLE_TABLE,Y
                LDY INDEX
                STA BUFFER2,Y
                BNE :6
:8              STY INDEX
:9              LDY DRIVE_READ,X
                BPL :9
                EOR DENIBBLE_TABLE,Y
                LDY INDEX
                STA BUFFER1,Y
                INY
                BNE :8
:10             LDY DRIVE_READ,X        ; read checksum nibble
                BPL :10
                CMP DENIBBLE_TABLE,Y
                BNE READ_ERROR
:11             LDA DRIVE_READ,X
                BPL :11
                CMP #$DE
                BNE READ_ERROR
                NOP                     ; nibble delay
:12             LDA DRIVE_READ,X
                BPL :12
                SAME_PAGE_AS_ :2
                CMP #$AA
                BEQ READ_SUCCESS
READ_ERROR      DEC RETRY_COUNT
                BNE READ_ADDRESS
                JMP RETRIES_FAILED

;---------------------------------------

RCOUNT          =   ZTEMP0
CHECKSUM        =   ZTEMP0
LAST            =   ZTEMP1

;
; On entry:
;   X: SLOT_X0
;   TARGET_PSECTOR/TRACK/VOLUME set up
;
READ_ADDRESS    LDY #$FC                ; count ($400) for finding any address,
                STY RCOUNT              ;   not necessarily the correct one
:RETRY1         INY                     ; NOTE: count low byte
                BNE :1
                INC RCOUNT              ; NOTE: count high byte
                BEQ READ_ERROR
:1              LDA DRIVE_READ,X
                BPL :1
:RETRY2         CMP #$D5
                BNE :RETRY1
                NOP                     ; nibble delay
:2              LDA DRIVE_READ,X
                BPL :2
                CMP #$AA
                BNE :RETRY2
                LDY #2                  ; nibble delay, too
:3              LDA DRIVE_READ,X
                BPL :3
                CMP #$96
                BNE :RETRY2
                LDA #$00
:4              STA CHECKSUM            ;3
:5              LDA DRIVE_READ,X
                BPL :5
;               SEC                     ; set by CMP #$96
                ROL                     ; carry set before and after
                STA LAST
:6              LDA DRIVE_READ,X        ;4
                BPL :6                  ;2
                AND LAST                ;3
                CMP TARGET_PSECTOR,Y    ;4 (ABS,Y) carry set
                BNE WRONG_VTS           ;2
                EOR CHECKSUM            ;3
                DEY                     ;2
                BPL :4                  ;3
                STA CHECKSUM            ;3
:7              LDA DRIVE_READ,X
                BPL :7
;               SEC                     ; set by CMP TARGET_PSECTOR,Y
                ROL                     ; carry set before and after
                STA LAST
:8              LDA DRIVE_READ,X
                BPL :8
                AND LAST
                EOR CHECKSUM
                BNE READ_ERROR          ; bad checksum
:9              LDA DRIVE_READ,X
                BPL :9
                CMP #$DE
                BNE READ_ERROR
                NOP                     ; nibble delay
:10             LDA DRIVE_READ,X
                BPL :10
                SAME_PAGE_AS_ :1
                CMP #$AA
                BNE READ_ERROR
READ_SUCCESS    RTS
;
; On entry:
;   Drive spinning
;   Y: target index (0,1,2 = S,T,V)
;   A: mismatching value found
;
WRONG_VTS       DEY
                BMI :SECTOR
                BEQ :TRACK

:VOLUME         LDY CUR_DRIVE
                AND #VOLUME_MASK        ; volume to side
                STA CUR_SIDES,Y
                JMP NEXT_DRIVE

:TRACK          DEC RESEEK_COUNT
                BEQ RETRIES_FAILED
                LDY CUR_DRIVE
                STA CUR_FTRACKS,Y
                BPL RETRY_TRACK         ; always

:SECTOR         DEC RETRY_COUNT
                BNE RETRY_SECTOR

RETRIES_FAILED  DEC RECAL_COUNT
                BNE :1
                JMP NEXT_DRIVE

:1              LDA #MAX_RESEEKS
                STA RESEEK_COUNT

                LDY CUR_DRIVE
                LDA #$30                ; full tracks
                STA CUR_FTRACKS,Y
                LDA #$00
                JSR SEEK                ; recalibrate

RETRY_TRACK     LDA TARGET_FTRACK
                JSR SEEK
                LDA #MAX_RETRIES
                STA RETRY_COUNT
RETRY_SECTOR    JMP READ_ADDRESS

;---------------------------------------

TRKCNT          =   ZTEMP0              ; half track count
PRIOR           =   ZTEMP1              ; previous half track
TRKN            =   ZTEMP2              ; target half track

CURTRK          DB  $00                 ; current half track during seek

;
; On entry:
;   A: target full track
;   X: SLOT_X0
;
SEEK            ASL
                STA TRKN
                LDY CUR_DRIVE
                LDA CUR_FTRACKS,Y
                ASL
                STA CURTRK
                CMP TRKN
                BEQ SEEK_EXIT
                LDA TRKN
                LSR
                STA CUR_FTRACKS,Y
                LDA #0
                STA TRKCNT
:1              LDA CURTRK
                STA PRIOR
                SEC
                SBC TRKN
                BEQ SEEK_END
                BCS :2
                EOR #$FF
                INC CURTRK
                BCC :3                  ; always
:2              ADC #$FE
                DEC CURTRK
:3              CMP TRKCNT
                BCC :4
                LDA TRKCNT
:4              CMP #$0C
                BCS :5
                TAY
:5              SEC                     ; phase on
                JSR SET_PHASE
                LDA ON_TABLE,Y
                JSR MSWAIT
                LDA PRIOR
                CLC                     ; phase off
                JSR CLEAR_PHASE
                LDA OFF_TABLE,Y
                JSR MSWAIT
                INC TRKCNT
                BNE :1                  ; always
                SAME_PAGE_AS_ :1

SEEK_END        LDA #0                  ; wait 25 MS settle
                JSR MSWAIT
                CLC
                ; fall through
;
; turn head stepper phase on/off
;
; On entry:
;   C=0: phase off
;   C=1: phase on
;
SET_PHASE       LDA CURTRK
CLEAR_PHASE     AND #3
                ROL
                ORA SLOT_X0
                TAX
                LDA DRIVE_SM0,X
                LDX SLOT_X0             ; restore slot
SEEK_EXIT       RTS
;
; phase on/off time tables in 100-usec intervals
;
ON_TABLE        DB  $01,$30,$28
                DB  $24,$20,$1E
                DB  $1D,$1C,$1C
                DB  $1C,$1C,$1C
                SAME_PAGE_AS_ ON_TABLE

OFF_TABLE       DB  $70,$2C,$26
                DB  $22,$1F,$1E
                DB  $1D,$1C,$1C
                DB  $1C,$1C,$1C
                SAME_PAGE_AS_ OFF_TABLE

;---------------------------------------
;
; On entry:
;   X: track
;   Y: sector
;   A: sector count
;   C: 0=read, 1=write
;
RW_SECTORS      PHP
                JSR START_RW
                LDY LSECTOR
                BPL :2                  ; always

:1              STY LSECTOR
                JSR RESET_RETRIES
:2              LDA INTERLEAVE_L2P,Y
                STA TARGET_PSECTOR
                PLP
                PHP
                BCC :3
                LDA SSTOREH
                JSR PRENIBBLIZE         ; prep for write
:3              JSR READ_ADDRESS
                PLP
                PHP
                BCS :4
                JSR READ_DATA
                LDA SSTOREH
                JSR DENIBBLER
                BNE :5                  ; always

:4              JSR WRITE_DATA
:5              INC SSTOREH
                DEC SECCOUNT
                BEQ :6

                LDY LSECTOR
                INY
                CPY #16
                BNE :1

                INC TARGET_FTRACK
                LDA TARGET_FTRACK
                JSR SEEK
                LDY #0
                BEQ :1                  ; always

:6              STA DRIVE_OFF,X
                PLP
                LDY CUR_DRIVE           ; commit to disk side being in a drive
                LDA DISK_SIDE
                STA CUR_SIDES,Y
                RTS

;---------------------------------------
;
; On entry:
;   X: track
;   Y: sector
;   A: sector count
;   DISK_SIDE: disk side to read
;   SSTOREH: page to read to
;
; On exit:
;   CUR_DRIVE motor on and spun up to speed
;   TARGET_VOLUME/TRACK set up
;   X: SLOT_X0
;   RETRY_COUNT: #$30
;
START_RW        STX TARGET_FTRACK
                STY LSECTOR
                STA SECCOUNT
                LDA DISK_SIDE
                ORA #VOLUME_BITS
                STA TARGET_VOLUME

                LDA #2                  ; drives left to try
                STA DRIVE_COUNT

                LDY #0                  ; drive 1
                LDA DISK_SIDE
                CMP CUR_SIDES+0
                BEQ :1
                CMP CUR_SIDES+1
                BNE :1
                INY                     ; drive 2
:1              LDX SLOT_X0
                CPY CUR_DRIVE
                BNE SELECT_DRIVE

FAST_SPINUP     LDA DRIVE_ON,X          ; turn on motor, regardless
                LDA DRIVE_READMODE,X    ; Q7L read mode
                LDA DRIVE_READ,X        ; Q6L
                LDY #8
:1              LDA DRIVE_READ,X        ; Q6L
                PHA                     ; delay for disk data to change
                PLA
                PHA
                PLA
                STA DUMMY               ; to kill time
                CMP DRIVE_READ,X        ; Q6L
                BNE :2                  ; drive is on
                DEY
                BNE :1
                BEQ SLOW_SPINUP         ; always

:2              LDA TARGET_FTRACK
                JSR SEEK
                JMP RESET_RETRIES

SELECT_DRIVE    STY CUR_DRIVE
                TYA
                LSR
                BCS :1
                LDA DRIVE_ENABLE1,X
                BCC :2                  ; always
:1              LDA DRIVE_ENABLE2,X
:2              LDA DRIVE_ON,X          ; turn on motor

SLOW_SPINUP     LDA #<MOTOR_ON_DELAY
                STA MONCNTL
                LDA #>MOTOR_ON_DELAY
                STA MONCNTH

; wait before any seeking if drive was off
                LDY #7                  ; delay 150 MS
:1              JSR MSWAIT
                DEY
                BNE :1
                LDX SLOT_X0             ; restore slot number

; preseek to track to overlap with drive spin-up
                LDA TARGET_FTRACK
                JSR SEEK

; wait for spin up, minus any time spent seeking
                LDY MONCNTH
                BPL RESET_RETRIES
:2              LDY #$12
:3              DEY
                BNE :3
                INC MONCNTL
                BNE :2
                INC MONCNTH
                BNE :2
                ; fall through

RESET_RETRIES   LDA #MAX_RECALS         ; reset per-drive retry values
                STA RECAL_COUNT
                LDA #MAX_RESEEKS
                STA RESEEK_COUNT
                LDA #MAX_RETRIES
                STA RETRY_COUNT
                RTS                     ; X and Y must remain unchanged

NEXT_DRIVE      STA DRIVE_OFF,X
                LDA CUR_DRIVE
                EOR #$01
                TAY
                DEC DRIVE_COUNT         ; both drives checked?
                BNE CMN_DRIVE
                LDA #2                  ; check both drives again
                STA DRIVE_COUNT
                STY CUR_DRIVE
                LDA DISK_SIDE
                JSR ASK_FOR_SIDE
SAME_DRIVE      LDY CUR_DRIVE           ; (called after remove write protect)
                LDX SLOT_X0
CMN_DRIVE       JSR SELECT_DRIVE
                JMP READ_ADDRESS

DRIVE_COUNT     DB  0
RECAL_COUNT     DB  0
RESEEK_COUNT    DB  0
RETRY_COUNT     DB  0
DUMMY           DB  0

;---------------------------------------

;
; On entry:
;   A: target page
;
DENIBBLER       STA :MOD+2
                LDY #$00
:1              LDX #$56
:2              DEX
                BMI :1
                LDA BUFFER1,Y
                LSR BUFFER2,X
                ROL
                LSR BUFFER2,X
                ROL
:MOD            STA $FF00,Y
                INY
                BNE :2
                SAME_PAGE_AS_ :1
                LDX SLOT_X0
                RTS

;---------------------------------------

                DS  \                   ; about $20 bytes

INTERLEAVE_L2P  DB  $00,$02,$04,$06,$08,$0A,$0C,$0E
                DB  $01,$03,$05,$07,$09,$0B,$0D,$0F

CUR_DRIVE       DB  $FF
CUR_SIDES       DB  0,2                 ; default to MS and T1
CUR_FTRACKS     DB  0,0

;---------------------------------------
;
; Delay a specified number of 100-usec intervals
;   for motor-on time.
;
MSWAIT          LDX #$11
:1              DEX                     ; delay 86 usec
                BNE :1
                INC MONCNTL
                BNE :2
                INC MONCNTH
:2              SEC
                SBC #$01
                BNE MSWAIT
                SAME_PAGE_AS_ MSWAIT
                RTS

;---------------------------------------

; NOTE: These are actually used for write but
;   placed here to better align table below.

NIBBLE_TABLE    DB  $96,$97,$9A
                DB  $9B,$9D,$9E
                DB  $9F,$A6,$A7
                DB  $AB,$AC,$AD
                DB  $AE,$AF,$B2
                DB  $B3,$B4,$B5
                DB  $B6,$B7,$B9
                DB  $BA,$BB,$BC
                DB  $BD,$BE,$BF
                DB  $CB,$CD,$CE
                DB  $CF,$D3,$D6
                DB  $D7,$D9,$DA
                DB  $DB,$DC,$DD
                DB  $DE,$DF,$E5
                DB  $E6,$E7,$E9
                DB  $EA,$EB,$EC
                DB  $ED,$EE,$EF
                DB  $F2,$F3,$F4
                DB  $F5,$F6,$F7
                DB  $F9,$FA,$FB
                DB  $FC,$FD,$FE
                DB  $FF
                SAME_PAGE_AS_ NIBBLE_TABLE

PRENIBBLIZE     STA :MOD+2
                LDX #$00
                LDY #$02
:1              DEY
:MOD            LDA $FF00,Y
                LSR
                ROL BUFFER2,X
                LSR
                ROL BUFFER2,X
                STA BUFFER1,Y
                INX
                CPX #$56
                BCC :1
                LDX #$00
                TYA
                BNE :1
                LDX #$55
:2              LDA BUFFER2,X
                AND #$3F
                STA BUFFER2,X
                DEX
                BPL :2
                SAME_PAGE_AS_ :1
                LDX SLOT_X0
                RTS

;---------------------------------------

; NOTE: this table is padded to end of page

PC_LOW          =   <*
                DS  $96-PC_LOW

DENIBBLE_TABLE  =   *-$96
                DB  $00,$01,$98
                DB  $99,$02,$03
                DB  $9C,$04,$05
                DB  $06,$A0,$A1
                DB  $A2,$A3,$A4
                DB  $A5,$07,$08
                DB  $A8,$A9,$AA
                DB  $09,$0A,$0B
                DB  $0C,$0D,$B0
                DB  $B1,$0E,$0F
                DB  $10,$11,$12
                DB  $13,$B8,$14
                DB  $15,$16,$17
                DB  $18,$19,$1A
                DB  $C0,$C1,$C2
                DB  $C3,$C4,$C5
                DB  $C6,$C7,$C8
                DB  $C9,$CA,$1B
                DB  $CC,$1C,$1D
                DB  $1E,$D0,$D1
                DB  $D2,$1F,$D4
                DB  $D5,$20,$21
                DB  $D8,$22,$23
                DB  $24,$25,$26
                DB  $27,$28,$E0
                DB  $E1,$E2,$E3
                DB  $E4,$29,$2A
                DB  $2B,$E8,$2C
                DB  $2D,$2E,$2F
                DB  $30,$31,$32
                DB  $F0,$F1,$33
                DB  $34,$35,$36
                DB  $37,$38,$F8
                DB  $39,$3A,$3B
                DB  $3C,$3D,$3E
                DB  $3F

;---------------------------------------
