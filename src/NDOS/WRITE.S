
;---------------------------------------

WRITEPRO_ERROR  STA DRIVE_OFF,X
                LDA DISK_SIDE
                JSR UN_WRITE_PRO
                JSR SAME_DRIVE
                JMP WRITE_DATA

;---------------------------------------

WTEMP           =   ZTEMP0
SLOTZ           =   ZTEMP1

;
; On entry:
;   X: SLOT_X0
;
WRITE_DATA      STX SLOTZ               ; zpage timing
                STX SLOTABS             ; abs timing
                LDA DRIVE_WRITE,X       ; Q6H
                LDA DRIVE_READMODE,X    ; Q7L sense write protect
                SEC                     ; write-protected error flag
                BMI WRITEPRO_ERROR
                LDA BUFFER2
                STA WTEMP
                LDA #$FF                ; sync data
                STA DRIVE_WRITEMODE,X   ;5 Q7H
                ORA DRIVE_READ,X        ;4 Q6L
                PHA                     ;3
                PLA                     ;4
                NOP                     ;2
                LDY #4                  ;2
:1              PHA                     ;3
                PLA                     ;4
                JSR WRITE7              ;13,9,6 write sync byte
                DEY                     ;2
                BNE :1                  ;3/2
                LDA #$D5                ;2
                JSR WRITE9              ;15,9,6
                LDA #$AA                ;2
                JSR WRITE9              ;15,9,6
                LDA #$AD                ;2
                JSR WRITE9              ;15,9,6
                TYA                     ;2 Y=0 from above
                LDY #$56                ;2
                BNE :3                  ;3 always
:2              LDA BUFFER2,Y           ;4
:3              EOR BUFFER2-1,Y         ;5
                TAX                     ;2
                LDA NIBBLE_TABLE,X      ;4
                LDX SLOTZ               ;3
                STA DRIVE_WRITE,X       ;5 Q6H
                LDA DRIVE_READ,X        ;4 Q6L
                DEY                     ;2
                BNE :2                  ;3
                LDA WTEMP               ;3
                NOP                     ;2
:4              EOR BUFFER1,Y           ;5
                TAX                     ;2
                LDA NIBBLE_TABLE,X      ;4
                LDX SLOTABS             ;4
                STA DRIVE_WRITE,X       ;5 Q6H
                LDA DRIVE_READ,X        ;4 Q6L
                LDA BUFFER1,Y           ;4
                INY                     ;2
                BNE :4                  ;3/2
                SAME_PAGE_AS_ :1
                TAX                     ;2
                LDA NIBBLE_TABLE,X      ;4
                LDX SLOTZ               ;3
                JSR WRITE               ;6,9,6
                LDA #$DE                ;2
                JSR WRITE9              ;15,9,6
                LDA #$AA                ;2
                JSR WRITE9              ;15,9,6
                LDA #$EB                ;2
                JSR WRITE9              ;15,9,6
                LDA #$FF                ;2 turn off byte
                JSR WRITE9              ;15,9,6
;               CLC                     ; (cleared by WRITE9)
                LDA DRIVE_READMODE,X    ; Q7L out of write mode
:5              LDA DRIVE_READ,X        ; Q6L to read mode
                RTS

; assumed to not change Y register
WRITE9          CLC                     ;2 nine cycles, then write
WRITE7          PHA                     ;3 seven cycles, then write
                PLA                     ;4
WRITE           STA DRIVE_WRITE,X       ;5 Q6H
                ORA DRIVE_READ,X        ;4 Q6L
                RTS

SLOTABS         DS  1                   ; copy for timing purposes

;---------------------------------------
