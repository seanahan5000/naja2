
; TODO: Should this boot loader check system requirements
;   such as Apple ][+ or newer, or 64K or greater?

LOAD_BASE       =   $8000

; boot sector at $800
;   read the next 15 sectors to LOAD_BASE+$0100 to LOAD_BASE+$0FFF
;   (need to apply sector interleave on reads)

                ORG $0800

                DB  $01

BOOT            CMP #$01                ; ACC holds sector read + 1
                BNE :1
                LDA #>LOAD_BASE+$0100
                STA $27                 ; next sector dst H
                LDA #$00
                STA $00
                TXA
                PHA                     ; save SLOT_X0
                LSR
                LSR
                LSR
                LSR
				ORA #$C0
				STA :MOD+2
:1              LDY $00
                INY
                CPY #16
                BEQ RELOCATE
                STY $00
                LDA INTERLEAVE_L2P,Y
                STA $3D                 ; physical sector
                TAY
                INY
                STY $0800
:MOD            JMP $CF5C               ; must not have altered X reg

; logical to physical interleave
INTERLEAVE_L2P  DB  $00,$02,$04,$06,$08,$0A,$0C,$0E
                DB  $01,$03,$05,$07,$09,$0B,$0D,$0F

; move this code up to LOAD_BASE so $0800 can be overwritten
RELOCATE        LDX #0
:1              LDA $0800,X
                STA LOAD_BASE,X
                INX
                BNE :1
                JMP CONTINUE

                ORG *-$0800+LOAD_BASE

CONTINUE        LDX #0                  ; clear primary screen
                TXA
:1              STA $2000,X
                INX
                BNE :1
                INC :1+2
                LDY :1+2
                CPY #$40
                BNE :1

                STA $C05F               ; Clear double hires
                STA $C05A               ; Disable VBL interupt
                STA $C058               ; Disable mouse interupts
                STA $C00E               ; Normal character set
                STA $C00C               ; 40 column
                STA $C008               ; Use main pages 0,1
                STA $C002               ; Use main 48K
                STA $C000               ; Page 2 switches page 1 and 2

                STA $C054               ; PRIMARY
                STA $C052               ; NOMIXED
                STA $C057               ; HIRES
                STA $C050               ; GRAPHICS

SHUFFLE_PAGES   LDX #0
:1              LDA LOAD_BASE+$0200,X
:2              STA $0400,X
                INX
                BNE :1
                INC :1+2
                INC :2+2
                LDA :2+2
                CMP #$12                ; ending address
                BNE :1

LOAD_FILES      PLA                     ; recover SLOT_X0
                JSR SET_SLOT_X0

                LDA #side_MS
                JSR SET_DISK_SIDE

                LDX #<BOOT1_TABLE
                LDY #>BOOT1_TABLE
                JSR SET_FILE_TABLE

                LDA #fileGraphics
                JSR SET_FILE
                LDA #8                  ; skip first 8 sectors loaded above
                JSR SEEK_FILE
                LDA #$0E                ; length $1600 - 8 sectors
                LDY #$12                ; address $0A00 + 8 sectors
                JSR READ_FILE           ; this also reads CAMP.1C00

                JSR INIT_RANDOM         ; TODO: INIT_GRAPHICS instead?

; TODO: Consider moving camp loading to after the
;   title animation in order to give more immediate
;   feedback to player on boot.
;   (would require disk layout change)

                LDA $C083               ; bank 2
                LDA $C083

                LDA #fileCampE000
                LDY #$E0
                JSR LOAD_FILE

                LDA #fileCampD000_2
                LDY #$D0
                JSR LOAD_FILE

                LDA $C08B               ; bank 1
                LDA $C08B

                LDA #fileCampD000_1
                LDY #$D0
                JSR LOAD_FILE

                LDA #$5F
                PHA
                LDA #$FF
                PHA
                LDA #fileTitle
                LDY #$60
                JMP LOAD_FILE

BOOT1_TABLE     DB  fileGraphics,   $00,$08,$12     ; includes CAMP.1C00
                DB  fileCampE000,   $02,$00,$20
                DB  fileCampD000_1, $04,$00,$10
                DB  fileCampD000_2, $05,$00,$10
                DB  fileTitle,      $06,$00,$2B

                DS  \,$00
                ERR *-LOAD_BASE-$0200
