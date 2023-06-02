
FIGHT_LOADER1   JMP _FIGHT_LOADER1
                JMP SPECIAL_LOAD

SAVE_SEED       =   $FE

;*** CHECK ALL SPIN UP/DOWN THROUGH FIGHT ***

_FIGHT_LOADER1  LDX #%11111111
                LDY #%11110000
                LDA #%00000000
                STA TAKEN_COUNT
SPECIAL_LOAD    STX OPTIONS1        ;Calling routine must clear
                STY OPTIONS2        ;   TAKEN_COUNT if unused
                STA FORCE_SURPRISE

                ; TODO: remove this debug code
                LDA SEED0
                STA SAVE_SEED+0
                LDA SEED1
                STA SAVE_SEED+1

                ; LDA #$33                ;***
                ; STA SEED0
                ; LDA #$64
                ; STA SEED1               ;***

                ; TODO: make sure hall range is set appropriately
                JSR CAPTURE_HALLS

                LDA OPTIONS1
                AND #Xalien1+Xalien2+Xalien3
                BEQ :1
                JSR SET_DATA_FILE
                JSR PICK_ALIENS
:1              LDA OPTIONS1
                AND #Xhmany1+Xhmany2+Xhmany3
                BEQ :2
                JSR PICK_NUMBER
:2              LDA OPTIONS2
                AND #Xpicture
                BEQ :3
                JSR DRAW_PICTURE
:3              JSR SHOW_PAGE2

                ; TODO: need to capture halls

                JSR SET_DATA_FILE
                JSR LOAD_ALIEN_DATA

                LDA #side_F1
                JSR SET_DISK_SIDE

                LDX #<FILE_TABLE_3
                LDY #>FILE_TABLE_3
                JSR SET_FILE_TABLE

                LDA #NOT_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF

                LDA #$5F
                PHA
                LDA #$FF
                PHA
                LDA #fileFightLoader2
                LDY #$60
                JMP LOAD_FILE

SET_DATA_FILE   LDY SHELL
                LDA :DATA_FILES-1,Y
                JMP SET_FILE
;
; Base file for alien data by shell
;
:DATA_FILES     DB  fileAlienData12
                DB  fileAlienData12
                DB  fileAlienData345
                DB  fileAlienData345
                DB  fileAlienData345

OPTIONS1        DS  1
OPTIONS2        DS  1
FORCE_SURPRISE  DS  1
; TWINS_FLAG    DS  1

;---------------------------------------

PICK_ALIENS     JSR LOAD_TABLE

                LDX MAP_FACE
                LDA FACE_MASKS,X
                STA FMASK

                LDA OPTIONS1
                AND #Xalien1
                BEQ FIRST_PICKED

                LDX #$00
                STX POSCNT
                INX
                STX COUNT
POSLOOP         LDY COUNT
                JSR POINTEM
                LDY #$00
                LDA (DATPNTL),Y
                AND FMASK
                BEQ NOTPOS
                LDY POSCNT
                LDA COUNT
                STA POSSIBLE,Y
                INC POSCNT
NOTPOS          LDA COUNT
                INC COUNT
                CMP DATA_BUFR+0     ;# OF ALIENS
                BNE POSLOOP
                LDY POSCNT
                LDA #$FF
                STA POSSIBLE,Y

                JSR RARESUB
RERAND          JSR RANDOM
                TAY
                CPY RAREPNT
                BCS RERAND
                LDA RARITY,Y
                STA ALIEN1
                TAY
                JSR POINTEM
                LDY #$00
                LDA (DATPNTL),Y
                STA ALTYPE1

FIRST_PICKED    LDA #$FF
                STA ALIEN2
                STA ALIEN3
                ; BIT TWINS_FLAG
                ; BMI GROUP2
                JSR RANDOM
                CMP #$60
                BCC GROUP2
                RTS
GROUP2          LDA ALIEN1
                TAY
                JSR POINTEM
                LDY #$03
                LDX SHELL
                DEX
                BNE :SKIPA
                LDY #$00
                LDA (DATPNTL),Y
                JSR PICK12
                TYA
                TAX
                LDY #$04
                CPX #$02
                BNE :SKIPA
:LOOP1          LDA (DATPNTL),Y
                INY
                CMP #$FE
                BNE :LOOP1
:SKIPA          LDX #$00
:LOOP2          LDA (DATPNTL),Y
                STA POSSIBLE,X
                INX
                INY
                CMP #$FE
                BEQ :SKIPC
                CMP #$FF
                BNE :LOOP2
:SKIPC          LDA POSSIBLE-2,X
                CMP #$99
                BEQ GOT_ALIENS
                JSR RARESUB
                LDA OPTIONS1
                AND #Xalien2
                BEQ GOT_ALIENS
RERAND3         JSR RANDOM
                TAY
                CPY RAREPNT
                BCS RERAND3
                LDA RARITY,Y
                STA ALIEN2
                TAY
                JSR POINTEM
                LDY #$00
                LDA (DATPNTL),Y
                STA ALTYPE2
                LDX SHELL
                DEX
                BEQ GOT_ALIENS
                LDA OPTIONS1
                AND #Xalien3
                BEQ GOT_ALIENS
                JSR RANDOM
                CMP #$60
                BCC GROUP3
                JMP GOT_ALIENS
GROUP3          LDA POSSIBLE+1
                CMP #$FF
                BEQ GOT_ALIENS
RERAND4         JSR RANDOM
                TAY
                CPY RAREPNT
                BCS RERAND4
                LDA RARITY,Y
                CMP ALIEN2
                BEQ RERAND4
                STA ALIEN3
                TAY
                JSR POINTEM
                LDY #$00
                LDA (DATPNTL),Y
                STA ALTYPE3
GOT_ALIENS      RTS

FACE_MASKS      DB  face1
                DB  face2
                DB  face3
                DB  face4
                DB  face5
                DB  face6

RARESUB         LDA #$00
                STA COUNT
                STA RAREPNT
RLOOP1          LDY COUNT
                LDA POSSIBLE,Y
                CMP #$FF
                BEQ RAROUT
                TAY
                JSR POINTEM
                LDY #$00
                LDA (DATPNTL),Y
                LDY #$01
                LDX SHELL
                DEX
                BNE :SKIPA
                JSR PICK12
:SKIPA          INY
                LDA (DATPNTL),Y
                STA RARECNT
                LDY COUNT
                LDA POSSIBLE,Y
                TAX
RLOOP2          LDY RAREPNT
                TXA
                STA RARITY,Y

            do 0
                INC RAREPNT
            else
                INY
                BEQ RAROUT      ; prevent RAREPNT from wrapping to zero and causing hang
                STY RAREPNT
            fin

                LDA RARECNT
                SEC
                SED
                SBC #$01
                CLD
                STA RARECNT
                BNE RLOOP2
                INC COUNT
                BNE RLOOP1
RAROUT          RTS

PICK12          ASL
                ASL
                LDX #0
XLOOP           ASL
                BCS FIRST
                INX
                BNE XLOOP
FIRST           LDY #$01
                CPX MAP_FACE
                BEQ PICKOUT
                INY
PICKOUT         RTS
;
; NOTE: caller has already set file
;
LOAD_TABLE      LDY SHELL
                LDA :DATA_OFFSETS-1,Y
                JSR SEEK_FILE
                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                LDY SHELL
                LDA :DATA_LENGTHS-1,Y
                LDY #>DATA_BUFR
                JMP READ_FILE
;
; Beginning sector offset of each of the data blocks
;
:DATA_OFFSETS   DB  $00,$1B,$00,$10,$21
;
; Number of sectors needed to get offset
;   tables and preliminary monster data
;   for each shell's monsters
;
:DATA_LENGTHS   DB  3,2,2,1,1

;---------------------------------------

PICK_NUMBER     LDX #0
:LOOP1          STX ALIEN_INDEX
                LDY ALIEN1,X
                CPY #$FF
                BEQ :EXIT
                LDA OPTIONS1
                AND HMANY_BITS,X
                BEQ :SKIPA
                JSR POINTEM

                LDY #1
                LDA (DATPNTL),Y
                PHA
                AND #%00001111
                STA TEMP+1
                INC TEMP+1
                PLA
                LSR
                LSR
                LSR
                LSR
                STA TEMP
:LOOP2          JSR RANDOM
                AND #%00001111
                CMP TEMP
                BCC :LOOP2
                CMP TEMP+1
                BCS :LOOP2

                LDX ALIEN_INDEX
                STA HMANY1,X
:SKIPA          INX
                CPX #3
                BNE :LOOP1
:EXIT           RTS

HMANY_BITS      DB  Xhmany1,Xhmany2,Xhmany3

;---------------------------------------

POINTEM         LDA #<DATA_BUFR
                CLC
                ADC DATA_BUFR+3     ;Rarity offset low
                STA DATPNTL
                LDA #>DATA_BUFR
                ADC DATA_BUFR+4     ;Rarity offset high
                STA DATPNTH
                TYA
                TAX
                LDY #$00
                BEQ :SKIPB          ;Always
:LOOP1          INY
                BNE :SKIPA
                INC DATPNTH
:SKIPA          LDA (DATPNTL),Y
                CMP #$FF
                BNE :LOOP1
                INY
                BNE :SKIPB
                INC DATPNTH
:SKIPB          DEX
                BNE :LOOP1
                TYA
                CLC
                ADC DATPNTL
                STA DATPNTL
                BCC :EXIT
                INC DATPNTH
:EXIT           RTS

;---------------------------------------

; TODO: shorten tunnel range for better alien drawing
; TODO: make tunnel range part of alien data

DRAW_PICTURE    JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictEnd

                JSR DRAW_HALL

                LDX ALIEN1
                LDA DATA_BUFR+4,X       ; picture #'s

                CMP #$FF
                BEQ :NO_PICT            ; sets carry
                PHA

                LDX SHELL
                LDA :PIC_FILES-1,X
                JSR SET_FILE
                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                LDA #1
                LDY #>PICT_BUFR
                JSR READ_FILE

                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                PLA
                ASL
                TAY
                INY                     ; skip COUNT_12/345
                LDA PICT_BUFR+0,Y       ; offset low byte (offset in sector)
                PHA
                LDA PICT_BUFR+3,Y       ; offset high byte of next picture
                SEC
                SBC PICT_BUFR+1,Y       ; offset high byte (sector offset)
                ADC #0                  ; + 1
                PHA
                LDA PICT_BUFR+1,Y       ; offset high byte (sector offset)
                JSR SEEK_FILE
                PLA
                LDY #>PICT_BUFR
                JSR READ_FILE
                PLA
                TAX
                LDY #>PICT_BUFR
                JSR UNPACK
                CLC                     ; clear carry if picture was drawn
:NO_PICT        RTS

:PIC_FILES      DB  fileAlienPics12
                DB  fileAlienPics12
                DB  fileAlienPics345
                DB  fileAlienPics345
                DB  fileAlienPics345

;---------------------------------------

LOAD_ALIEN_DATA
                LDA #<ALIEN_HEAP
                STA HEAP_PTR
                LDA #>ALIEN_HEAP
                STA HEAP_PTR_H

                LDA #<ALIEN_HEAP_END
                STA ALIEN_PTR
                LDA #>ALIEN_HEAP_END
                STA ALIEN_PTR_H

                LDX #0
:1              STX ALIEN_INDEX
                LDY ALIEN1,X
                CPY #$FF
                BEQ :2
                JSR DATA_LOADER
                LDX ALIEN_INDEX
                INX
                CPX #3
                BNE :1
:2              RTS

DATA_LOADER     LDA DATA_BUFR+1         ; data offset low
                CLC
                ADC #<DATA_BUFR
                STA SRC_PTR
                LDA DATA_BUFR+2         ; data offset high
                ADC #>DATA_BUFR
                STA SRC_PTR_H
                DEY
                TYA
                ASL
                CLC
                ADC SRC_PTR
                STA SRC_PTR
                BCC :1
                INC SRC_PTR_H
:1
                LDY #1                  ; (sector offset)
                LDA (SRC_PTR),Y
                JSR SEEK_FILE
                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                LDA #3
                LDY #>ALIEN_BUFR
                JSR READ_FILE

                LDY #0
                LDA (SRC_PTR),Y         ; (byte offset)
                STA SRC_PTR
                LDA #>ALIEN_BUFR
                STA SRC_PTR_H

                LDX ALIEN_INDEX
                LDA ALIEN_PTR
                SEC
                SBC #alienClassSize
                STA ALIEN_PTR
                STA ALIEN_PTRS_L,X
                BCS :2
                DEC ALIEN_PTR_H
:2              LDA ALIEN_PTR_H
                STA ALIEN_PTRS_H,X

                ; TODO: check for HEAP_PTR collision

                LDY #0
:3              LDA (SRC_PTR),Y
                STA (ALIEN_PTR),Y
                INY
                CPY #alienClassSize
                BNE :3

                JSR ADV_SRC_PTR

GET_GROUPINGS   LDA GBUFF_PTRS_L,X
                STA GBUFF_PTR
                LDA GBUFF_PTRS_H,X
                STA GBUFF_PTR_H

                LDY #0
:1              LDA (SRC_PTR),Y
                STA (GBUFF_PTR),Y
                INY
                CMP #$DD
                BNE :1
:2              LDA (SRC_PTR),Y
                STA (GBUFF_PTR),Y
                INY
                CMP #$FF
                BNE :2

                JSR ADV_SRC_PTR

ADD_TOPVIEWS    LDX ALIEN_INDEX
                LDA HEAP_PTR
                STA TV_PTRS_L,X
                LDA HEAP_PTR_H
                STA TV_PTRS_H,X

                LDY #0
                LDA (SRC_PTR),Y
                AND #%11110000
                CMP #animated
                BNE :11

                ; TODO: make topview cell dimensions common to all formats
                INY
                LDA (SRC_PTR),Y
                PHA
                LSR
                LSR
                LSR
                LSR
                STA TV_WIDTHS,X
                PLA
                AND #%00001111
                STA TV_HEIGHTS,X

                LDY #4
                JSR ADV_SRC_PTR
                JMP :12

                ; TODO: make topview cell dimensions common to all formats
:11             LDY #0
                LDA (SRC_PTR),Y
                JSR DIMENS_GET
                LDX ALIEN_INDEX
                STA TV_WIDTHS,X
                TYA
                STA TV_HEIGHTS,X

:12             LDY #0
                LDA (SRC_PTR),Y
                CMP #$FF
                BEQ :8
                PHA
                STA (HEAP_PTR),Y
                INY
                LDA (SRC_PTR),Y
                STA (HEAP_PTR),Y
                INY

                PLA
                PHA
                LDX #0
                STX TILE_COUNT
                LSR
                LSR
                LSR
                LSR
                STA TEMP
                PLA
                AND #$0F
                TAX
                CLC
:2              LDA TILE_COUNT
                ADC TEMP
                STA TILE_COUNT
                DEX
                BNE :2

                JSR ADV_SRC_HEAP_PTR

                LDY #0
:4              LDX #7
:5              LDA (SRC_PTR),Y
                STA (HEAP_PTR),Y
                CMP #$80
                INY
                BCS :6
                DEX
                BNE :5
:6              DEC TILE_COUNT
                BNE :4

                JSR ADV_SRC_HEAP_PTR
                ; TODO: check for HEAP_PTR collision
                ; JMP :1
                ; TODO: copy more than just one topview
                LDA #$FF

:8              STA (HEAP_PTR),Y
                INY
                ; fall through

ADV_HEAP_PTR    TYA
                CLC
                ADC HEAP_PTR
                STA HEAP_PTR
                BCC :1
                INC HEAP_PTR_H
:1              RTS

ADV_SRC_HEAP_PTR
                JSR ADV_HEAP_PTR
ADV_SRC_PTR     TYA
                CLC
                ADC SRC_PTR
                STA SRC_PTR
                BCC :1
                INC SRC_PTR_H
:1              RTS

GBUFF_PTRS_L    DB  <GROUP_BUFF1
                DB  <GROUP_BUFF2
                DB  <GROUP_BUFF3

GBUFF_PTRS_H    DB  >GROUP_BUFF1
                DB  >GROUP_BUFF2
                DB  >GROUP_BUFF3

;---------------------------------------
; On Entry:
;   A: Dimens in bytes
;
; On Exit:
;   A: Width in squares
;   Y: Height in squares
;---------------------------------------

; TODO: add data byte to all topviews so this isn't needed

DIMENS_GET      TAX
                LSR
                LSR
                LSR
                LSR
                LDY #0
:LOOP1          CMP WIDES,Y
                BCC :SKIPA
                BEQ :SKIPA
                INY
                BNE :LOOP1
:SKIPA          INY
                TYA
                PHA
                TXA
                AND #%00001111
                LDY #0
:LOOP2          CMP HIGHS,Y
                BCC :SKIPB
                BEQ :SKIPB
                INY
                BNE :LOOP2
:SKIPB          INY
                PLA
                RTS

WIDES           DB  $02,$05,$06
                DB  $09,$0B,$0F

HIGHS           DB  $02,$03,$05
                DB  $07,$08,$0F

;---------------------------------------
