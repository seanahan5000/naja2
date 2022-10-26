
DISP_DATA       =   LOCAL_TEMP+0
DISP_INDEX      =   LOCAL_TEMP+1
DISP_YX         =   LOCAL_TEMP+2

DISPATCH        LDY MAP_X
                LDA (MAP_PTR),Y
                ; TODO: use constants
                AND #$0E                ; clear mapped bit too
                BEQ DISP_MORE
                STA DISP_DATA
                LDA #-1
                STA DISP_INDEX

        do BIG_MAP
                ; only use this when map width > 16
                LDX MAP_FACE
                LDA MAP_Y
                CMP DEAD_Y,X
                BCC :1
;               SEC
                SBC #1
:1              ASL
                ASL
                ASL
                ASL
                STA DISP_YX
                LDA MAP_X
                CMP DEAD_X,X
                BCC :2
;               SEC
                SBC #1
:2              ORA DISP_YX
                STA DISP_YX
        else
                LDA MAP_Y
                ASL
                ASL
                ASL
                ASL
                ORA MAP_X
                STA DISP_YX
        fin

DISP_NEXT       LDX DISP_INDEX
:1              INX
                LSR DISP_DATA
                BCS :2
                BNE :1
                BEQ DISP_MORE           ; always
:2              STX DISP_INDEX
                DEX
                BEQ DISP_SPECIAL
                DEX
                BEQ DISP_ENCOUNTER
                ; TODO: handle extra data bit here

DISP_MORE       ; random encounters need to clear SAVE_SPAWN
                LDA #$FF
                STA SAVE_SPAWN
                ; TODO: random encounter checks?
                ; TODO: encounter more common if map not visited?
                CLC
                RTS

DISP_SPECIAL    LDX MAP_FACE
                LDY SPECIAL_START,X
:1              LDA DISP_YX
:2              CMP SPECIAL_YX,Y
                BEQ :3
                BCC DISP_NEXT
                INY
                BNE :2                  ; always
:3              LDX MAP_DIR
                LDA BIT_TABLE,X         ; TODO: +4 high bits?
                AND SPECIAL_DIR,Y
                BNE :4
                INY
                BNE :1                  ; always
:4              LDA SPECIAL_ID,Y
                ASL
                TAX
                LDA SPECIAL_LIST+0,X
                STA :MOD+1
                LDA SPECIAL_LIST+1,X
                STA :MOD+2
                LDA SPECIAL_DIR,Y
:MOD            JMP $FFFF

DISP_ENCOUNTER  LDX MAP_FACE
                LDY ENCOUNTER_START,X
:1              LDA DISP_YX
:2              CMP ENCOUNTER_YX,Y
                BEQ :3
                BCC DISP_NEXT
                INY
                BNE :2                  ; always
:3              LDX MAP_DIR
                LDA BIT_TABLE,X         ; TODO: +4 high bits?
                AND ENCOUNTER_DIR,Y
                BNE :4
                INY
                BNE :1                  ; always
:4              LDA ENCOUNTER_ID,Y
                STA SAVE_SPAWN
                JSR SET_SPAWNED
                BCS DISP_NEXT
                ; TODO: use index somehow for encounter
                ; TODO: need table of encounter descriptors?
                RTS
;
; On entry:
;   A: encounter index
;
; On exit:
;   C=1: was already set
;   C=0: was clear
;
SET_SPAWNED     JSR GET_SPAWN_INDEX
                LDA ENCOUNTER_SPAWNS,Y
                ORA BIT_TABLE,X
                CMP ENCOUNTER_SPAWNS,Y
                BEQ :1
                STA ENCOUNTER_SPAWNS,Y
                CLC
:1              RTS
;
; Called if player ran away from spawn encounter
;
UNDO_SPAWNED    LDA SAVE_SPAWN
                BMI :1
                JSR GET_SPAWN_INDEX
                LDA BIT_TABLE,X
                ; TODO: create/use MASK_TABLE instead?
                EOR #$FF
                AND ENCOUNTER_SPAWNS,Y
                STA ENCOUNTER_SPAWNS,Y
:1              RTS
;
; On exit:
;   X: spawn bit
;   Y: spawn byte
;
GET_SPAWN_INDEX TAY
                AND #$07
                TAX
                LDA SHELL
                SEC
                SBC #1                  ; 1-based shell
                ASL                     ; 32 bits per shell
                ASL
                STA :MOD+1
                TYA
                LSR
                LSR
                LSR
                CLC
:MOD            ADC #$FF
                TAY
                RTS

; TODO: move someplace that survives fight load/return
SAVE_SPAWN      DB  $FF
