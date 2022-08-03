
; opcode
;   1xxx.xxxx   ; all opcodes
;   1xxx.xxx0   ; skip
;   1000.0001   ; copy 1
;   1xxx.xx01   ; repeat single
;   1000.0011 xxxx.xxxx             ; copy
;   1xxx.x011   ; repeat double
;   1xxx.x111 0ccc.cccx llll.llll   ; move

DATAL           =   $30
DATAH           =   $31
START_COLUMN    =   $32
START_LINE      =   $33
END_COLUMN      =   $34
END_LINE        =   $35
DATA_INDEX      =   $36
CUR_COLUMN      =   $37
TEMP_LINE       =   $38
HIGH_BIT        =   $39
SRCL            =   $3A
SRCH            =   $3B
SRC_LINE        =   $3C

;
; Decompress image to current screen at XCOORD,YCOORD
;
; On entry:
;   XCOORD,YCOORD: target position
;   X: data pointer low
;   Y: data pointer high
;
UNPACK_TO       ENT
                STX DATAL
                STY DATAH
                LDA XCOORD
                STA START_COLUMN
                LDA YCOORD
                STA START_LINE
                LDY #2
                LDX #$18            ; CLC
                BNE UNPACK_CMN2     ; always
;
; Decompress image to current screen, filling transparent with black
; *** TODO: how common is this??? ***
;
; On entry:
;   X: data pointer low
;   Y: data pointer high
;
UNPACK_FILL     ENT
                LDA #$38            ; SEC
                BNE UNPACK_CMN1     ; always
;
; Decompress image to current screen with transparency
;
; On entry:
;   X: data pointer low
;   Y: data pointer high
;
UNPACK          ENT
                LDA #$18            ; CLC
UNPACK_CMN1     STX DATAL
                STY DATAH
                TAX
                LDY #0
                LDA (DATAL),Y
                STA START_COLUMN
                INY
                LDA (DATAL),Y
                STA START_LINE
                INY
UNPACK_CMN2     LDA (DATAL),Y
                CLC
                ADC START_COLUMN
                STA END_COLUMN
                INY
                LDA (DATAL),Y
;               CLC
                ADC START_LINE
                STA END_LINE
                INY
                STY DATA_INDEX

                STX :SKIP_MOD

                LDY START_COLUMN
                STY CUR_COLUMN

                LDA #$00
                STA HIGH_BIT
                BEQ :START_COLUMN   ; always

:EXIT           LDA #$18            ; CLC
                STA :SKIP_MOD
                ; TODO: should this update DATAL/H with final address? YES! ***
                RTS

:NEXT_COLUMN    LDY CUR_COLUMN
                INY
                STY CUR_COLUMN
                CPY END_COLUMN
                BEQ :EXIT

:START_COLUMN   LDX START_LINE

:COLUMN_LOOP    CPX END_LINE
                BEQ :NEXT_COLUMN

                LDY DATA_INDEX
                LDA (DATAL),Y
                BMI :OPCODE
                INY
                BNE :1
                INC DATAH
:1              STY DATA_INDEX
                ORA HIGH_BIT
                TAY
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                INX
                TYA
                LDY CUR_COLUMN
                STA (SCREENL),Y
                BPL :COLUMN_LOOP    ; always
                SAME_PAGE_AS :COLUMN_LOOP

:OPCODE         INY
                BNE :2
                INC DATAH
:2              STY DATA_INDEX
                AND #$7F
                LSR A
                BCS :NOSKIP
                BEQ :FLIP_HIGH

:SKIP_MOD       CLC
                BCS :OPAQUE

:TRANSPARENT    STX TEMP_LINE
                ADC TEMP_LINE
                TAX
                BNE :COLUMN_LOOP    ; always

:OPAQUE         STX TEMP_LINE
                CLC
                ADC TEMP_LINE
                STA :REP1_MODB+1
                LDY CUR_COLUMN
                LDA #$00
                BEQ :REP1_FILL      ; always

:FLIP_HIGH      LDA HIGH_BIT
                EOR #$80
                STA HIGH_BIT
                JMP :COLUMN_LOOP

; TODO: get rid of this once masking is done?
:COPY1          INX
                STX  :COPYN_MOD+1
                DEX
                JMP :COPYN_LOOP

:COPYN          LDA (DATAL),Y
                INY
                BNE :3
                INC DATAH
:3              STY DATA_INDEX
                STX TEMP_LINE
                CLC
                ADC TEMP_LINE
                STA :COPYN_MOD+1
:COPYN_LOOP     LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                INX
                LDY DATA_INDEX
                LDA (DATAL),Y
                INY
                BNE :4
                INC DATAH
:4              STY DATA_INDEX
                LDY CUR_COLUMN
                STA (SCREENL),Y
:COPYN_MOD      CPX #$FF
                BNE :COPYN_LOOP
                SAME_PAGE_AS :COPYN_LOOP
                JMP :COLUMN_LOOP

:NOSKIP         LSR A
                BCS :NOREP1
                BEQ :COPY1

:REP1           STX TEMP_LINE
                ADC TEMP_LINE
                STA :REP1_MODB+1
                LDY CUR_COLUMN
                LDA (SCREENL),Y
:REP1_FILL      STA :REP1_MODA+1
:REP1_LOOP      LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                INX
:REP1_MODA      LDA #$FF
                STA (SCREENL),Y
:REP1_MODB      CPX #$FF
                BNE :REP1_LOOP
                SAME_PAGE_AS :REP1_LOOP
                JMP :COLUMN_LOOP

:NOREP1         LSR A
                STA TEMP_LINE
                BCS :MOVE
                BEQ :COPYN

:REP2           LDY CUR_COLUMN
                LDA (SCREENL),Y
                STA :REP2_MODB+1
                LDA LOBYTES-2,X
                STA SCREENL
                LDA HIBYTES-2,X
                STA SCREENH
                LDA (SCREENL),Y
                STA :REP2_MODA+1
:REP2_LOOP      LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                INX
:REP2_MODA      LDA #$FF
                STA (SCREENL),Y
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                INX
:REP2_MODB      LDA #$FF
                STA (SCREENL),Y
                DEC TEMP_LINE
                BNE :REP2_LOOP
                SAME_PAGE_AS :REP2_LOOP
                JMP :COLUMN_LOOP

:MOVE           LDY DATA_INDEX
                LDA (DATAL),Y
                INY
                BNE :5
                INC DATAH
:5              LSR A
                ROL TEMP_LINE
;               CLC
                ADC START_COLUMN
                STA :MOVE_MODA+1
                LDA (DATAL),Y
                INY
                BNE :6
                INC DATAH
:6
;               CLC
                ADC START_LINE
                STA SRC_LINE
                LDA TEMP_LINE
                STX TEMP_LINE
;               CLC
                ADC TEMP_LINE
                STA :MOVE_MODB+1
                STY DATA_INDEX
:MOVE_LOOP      LDY SRC_LINE
                LDA LOBYTES,Y
                STA SRCL
                LDA HIBYTES,Y
                STA SRCH
                INY
                STY SRC_LINE
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                INX
:MOVE_MODA      LDY #$FF
                LDA (SRCL),Y
                LDY CUR_COLUMN
                STA (SCREENL),Y
:MOVE_MODB      CPX #$FF
                BNE :MOVE_LOOP
                SAME_PAGE_AS :MOVE_LOOP
                JMP :COLUMN_LOOP
