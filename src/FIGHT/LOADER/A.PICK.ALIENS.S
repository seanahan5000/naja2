*===============================
*
*===============================

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
********************************
*               BIT $C062
*               BPL :2
*               LDX FACE
*               CPX #2
*               BNE :1
*               LDA #$08            ;BURROWING TAAN
*               BNE :2              ;Always
*:1             CPX #3
*               BNE :2
*               LDA #$10            ;FROBOT
*:2
********************************
                STA ALIEN1
                TAY
                JSR POINTEM
                LDY #$00
                LDA (DATPNTL),Y
                STA ALTYPE1

FIRST_PICKED    LDA #$FF
                STA ALIEN2
                STA ALIEN3

*** CHECK FOR TWINS
*** SET 'TWINS_FLAG' IF THERE ARE

                BIT TWINS_FLAG
                BMI GROUP2
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

LOAD_TABLE      LDY SHELL
                LDA :DATA_FILES-1,Y
                JSR SET_FILE
                LDY SHELL
                LDA :DATA_OFFSETS-1,Y
                JSR SEEK_FILE
                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                LDY SHELL
                LDA :DATA_LENGTHS-1,Y
                LDY #>DATA_BUFR
                JMP READ_FILE
;
; Base file for alien data by shell
;
:DATA_FILES     DB  fileAlienData12
                DB  fileAlienData12
                DB  fileAlienData345
                DB  fileAlienData345
                DB  fileAlienData345
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
