
;*** RENAME AND MOVE TO ZPAGE ***
SSECTOR         =   SECHOLD

READ_SECTORS    =   READ_SECTORS2


;
; On entry:
;   X: table address (low)
;   Y: table address (high)
;
SET_FILE_TABLE  ENT
                STX FILES
                STY FILESH
                RTS
;
; On entry:
;   A: on/off flag
;
SET_NEXT_ON_OFF ENT
                STA ON_OFF_FLAG
                RTS
;
; On entry:
;   A: file ID
;
; On exit:
;   C: 0=success, 1=failure
;
SET_FILE        ENT
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
                LDA FILE_TRACK
                STA STRACK
                LDA FILE_SECTOR
                STA SSECTOR
                LDA FILE_SIZE
                STA SECOUNT
                JSR READ_SECTORS
:1              LDA #%00000000          ; reset on/off flag
                STA ON_OFF_FLAG
                RTS
;
; On entry:
;   A: sector count
;   Y: load address (high)
;
READ_FILE       ENT
                STA SECOUNT
                STY SSTOREH
                LDA FILE_TRACK
                CLC
                ADC FILE_OFFSET+1
                STA STRACK
                LDA FILE_SECTOR
                CLC
                ADC FILE_OFFSET+0
                CMP #$10
                BCC :1
                AND #$0F
                INC STRACK
:1              STA SSECTOR
                JSR READ_SECTORS
                LDA #%00000000          ; reset on/off flag
                STA ON_OFF_FLAG
                RTS

FILE_TRACK      DB  0
FILE_SECTOR     DB  0
FILE_SIZE       DB  0
FILE_OFFSET     DW  0
