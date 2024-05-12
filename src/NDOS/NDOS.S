;
; On entry:
;    X: file hook address low
;    Y: file hook address high
;
SET_FILE_HOOK   ENT
                STX TO_FILE_HOOK+1
                STY TO_FILE_HOOK+2
                RTS

UN_WRITE_PRO    SEC
                BCS TO_FILE_HOOK        ; always
ASK_FOR_SIDE    CLC
TO_FILE_HOOK    JMP DEFAULT_HOOK        ; modified
DEFAULT_HOOK    RTS
;
; On entry:
;    A: new disk side
;
; On exit:
;    X: unchanged
;    Y: unchanged
;
SET_DISK_SIDE   ENT
                STA DISK_SIDE
                RTS
;
; On entry:
;   A: disk controller slot number * 16
;
SET_SLOT_X0     ENT
                STA SLOT_X0
                RTS
;
; On entry:
;   X: table address (low)
;   Y: table address (high)
;
SET_FILE_TABLE  ENT
                STX SET_FILE_MOD1+1
                STY SET_FILE_MOD2+1
                RTS

FILES           =   ZTEMP0
FILESH          =   ZTEMP1

;
; On entry:
;   A: file ID
;
; On exit:
;   C: 0=success, 1=failure
;
SET_FILE        ENT
SET_FILE_MOD1   LDY #$FF
                STY FILES
SET_FILE_MOD2   LDY #$FF
                STY FILESH
                LDY #0
:1              CMP (FILES),Y
                BEQ :2
                INY
                INY
                INY
                INY
                BNE :1
                SEC                     ; TODO: file not found should be fatal
                RTS
:2              INY
                LDA (FILES),Y
                STA FILE_TRACK
                INY
                LDA (FILES),Y
                STA FILE_SECTOR
                INY
                LDA (FILES),Y
                STA FILE_SIZE
                LDA #0
                STA FILE_OFFSET+0
                STA FILE_OFFSET+1
                CLC
                RTS
;
; On entry:
;   A: sector offset
;
SEEK_FILE       ENT
                LDY #0
                STY FILE_OFFSET+1
                TAX
                AND #$0F
                STA FILE_OFFSET+0
                TXA
                LDX #4
:1              ASL
                ROL FILE_OFFSET+1
                DEX
                BNE :1
                RTS
;
; On entry:
;   A: file ID
;   Y: load address (high)
;
; On exit:
;   C: 0=success, 1=failure
;
LOAD_FILE       ENT
                STY SSTOREH
                JSR SET_FILE
                BCS :1
                LDX FILE_TRACK
                LDY FILE_SECTOR
                LDA FILE_SIZE
                JMP READ_SECTORS
:1              RTS
;
; On entry:
;   A: sector count
;   Y: load address (high)
;
; NOTE: This does *not* advance the file position after read.
;
READ_FILE       ENT
                CLC
                BCC RW_FILE             ; always
WRITE_FILE      ENT
                SEC
RW_FILE         PHP
                PHA
                STY SSTOREH
                LDA FILE_TRACK
                CLC
                ADC FILE_OFFSET+1
                TAX
                LDA FILE_SECTOR
                CLC
                ADC FILE_OFFSET+0
                CMP #$10
                BCC :1
                AND #$0F
                INX
:1              TAY
                PLA
                PLP
                BCS :2
                JMP READ_SECTORS
:2              JMP WRITE_SECTORS

FILE_TRACK      DB  0
FILE_SECTOR     DB  0
FILE_SIZE       DB  0
FILE_OFFSET     DW  0
