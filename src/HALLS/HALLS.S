
        DO 0
HALL_DRIVER     JSR INIT_RANDOM
                JSR HGR

                LDX #<MAP_DATA
                LDY #>MAP_DATA
                LDA #17
                JSR SET_MAP_DATA

                LDA #0
                STA MAP_FACE
                STA MAP_X
                STA MAP_Y
                STA MAP_DIR
                JSR COMPUTE_MAP_PTR

                JSR RESTORE_MAPPED
                JSR MARK_MAPPED

                LDA #6
                STA RANGE

                JSR GET_NSEW
                JSR DRAW_HALL           ; fall through
        FIN

HALL_KEYS       ENT
                JSR RANDOM
                LDA KEYBRD
                BPL HALL_KEYS
                BIT UNSTROB
                JSR FILTER_KEYS
                BCS HALL_KEYS
                JSR CHECK_UP
                BEQ :FORWARD
                JSR CHECK_DOWN
                BEQ :AROUND
                JSR CHECK_RIGHT
                BEQ :RIGHT
                JSR CHECK_LEFT
                BNE HALL_KEYS           ; fall through

:LEFT           JSR SAVE_MAP_POS
                JSR TURN_LEFT
                JSR GET_NSEW
                LDX #1
                JSR FILTER_HALL
                BCS HALL_KEYS
                BCC :REDRAW             ; always

:RIGHT          JSR SAVE_MAP_POS
                JSR TURN_RIGHT
                JSR GET_NSEW
                LDX #1
                JSR FILTER_HALL
                BCS HALL_KEYS
                BCC :REDRAW             ; always

:AROUND         JSR SAVE_MAP_POS
                JSR TURN_AROUND
                JSR GET_NSEW
                LDX #1
                JSR FILTER_HALL
                BCS HALL_KEYS
                BCC :REDRAW             ; always

:FORWARD        LDA BLOCK_BUFFER
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BEQ :SCAN
                CMP #FRONT_WALL
                BEQ :STOP
                JSR SAVE_MAP_POS
                JSR MOVE_FORWARD
                JSR MARK_MAPPED
                JSR GET_NSEW
                LDX #2
                JSR FILTER_HALL
                BCS HALL_KEYS

:REDRAW         JSR CLEAR_PAGE
                JSR DRAW_HALL
                JMP HALL_KEYS

:SCAN           JSR SAVE_MAP_POS
                JSR MOVE_FORWARD
                JSR MARK_MAPPED
                LDX #3
                JSR FILTER_HALL
                BCS :1
                JSR SCAN_HALL
:1              JMP HALL_KEYS

:STOP           JSR BLIP
                JMP HALL_KEYS

BLIP            LDX #$50
:1              STA CLICK
                LDA #$05
                JSR WAIT
                DEX
                BNE :1
                RTS

SET_KEY_FILTER  ENT
                STX FILTER_KEYS+1
                STY FILTER_KEYS+2
                RTS

FILTER_KEYS     JMP DEFAULT_FILTER

SET_HALL_FILTER ENT
                STX FILTER_HALL+1
                STY FILTER_HALL+2
                RTS

FILTER_HALL     JMP DEFAULT_FILTER

DEFAULT_FILTER  CLC
                RTS

GET_NSEW        ENT
                JSR PUSH_MAP_STATE

                LDA #$00
                STA BLOCK_COUNT

:NEXT           JSR MOVE_LEFT
        do farLeftRightCaps
                JSR MOVE_LEFT
                JSR LOAD_MAP_DATA
                STA DATA_FARLEFT
                JSR MOVE_RIGHT
        fin
                JSR LOAD_MAP_DATA
                STA DATA_LEFT
                JSR MOVE_RIGHT
                JSR LOAD_MAP_DATA
                STA DATA_CENTER
                JSR MOVE_RIGHT
                JSR LOAD_MAP_DATA
                STA DATA_RIGHT
        do farLeftRightCaps
                JSR MOVE_RIGHT
                JSR LOAD_MAP_DATA
                STA DATA_FARRIGHT
                JSR MOVE_LEFT
        fin
                JSR MOVE_LEFT

                ; Wl.Nl.El.Sl  Wc.Nc.Ec.Sc  Wr.Nr.Er.Sr
                ;                 ^^
                ;       Wl.Nl.Wc.Nc  Er.Nr.Ec.Nc
                ;                ^^           ^^

                ; build Wl.Nl.Wc.Nc from Wl.Nl.El.Sl and Wc.Nc.Ec.Sc

                LDA DATA_CENTER     ; Wc.Nc.Ec.Sc
                LSR
                LSR
                LSR
                LSR                 ; 00.00.Wc.Nc
                EOR DATA_LEFT       ; Wl.Nl.XX.XX
                AND #$0F            ; 00.00.XX.XX
                EOR DATA_LEFT       ; Wl.Nl.Wc.Nc
        do farLeftRightCaps
                STA DATA_LEFT

                ; special case handling to treat xside as xxfront

                AND #XSIDE_MASK
;               CMP #XSIDE_OPEN
                BEQ :1
                CMP #XSIDE_FACE
                BNE :4

                LDA DATA_LEFT
                EOR #XSIDE_FACE!XSIDE_WALL
                BNE :3              ; always

:1              LDA DATA_FARLEFT
                AND #$30            ; north
;               CMP #$00            ; north open
                BEQ :2
                CMP #$10            ; north face
                BNE :4

:2              LDA DATA_LEFT
                AND #XSIDE_MASK!$FF
                ORA #XSIDE_FACE
:3              STA DATA_LEFT
:4              LDA DATA_LEFT
        fin
                LDX BLOCK_COUNT
                STA BLOCK_BUFFER,X
                INX

                ; build Er.Nr.Ec.Nc from Wc.Nc.Ec.Sc and Wr.Nr.Er.Sr

                LDA DATA_RIGHT      ; Wr.Nr.Er.Sr
                ASL
                ASL
                ASL
                ASL                 ; Er.Sr.00.00
                EOR DATA_CENTER     ; XX.XX.Ec.Sc
                AND #$F0            ; XX.XX.00.00
                EOR DATA_CENTER     ; Er.Sr.Ec.Sc
                STA DATA_TEMP1

                LDA DATA_CENTER     ; Wc.Nc.Ec.Sc
                LSR
                LSR
                LSR
                LSR                 ; 00.00.Wc.Nc
                EOR DATA_RIGHT      ; Wr.Nr.XX.XX
                AND #$0F            ; 00.00.XX.XX
                EOR DATA_RIGHT      ; Wr.Nr.Wc.Nc
                EOR DATA_TEMP1      ; XX.XX.XX.XX
                AND #$33            ; 00.XX.00.XX
                EOR DATA_TEMP1      ; Er.Nr.Ec.Nc

        do farLeftRightCaps
                STA DATA_RIGHT

                ; special case handling to treat xside as xxfront

                AND #XSIDE_MASK
;               CMP #XSIDE_OPEN
                BEQ :5
                CMP #XSIDE_FACE
                BNE :8

                LDA DATA_RIGHT
                EOR #XSIDE_FACE!XSIDE_WALL
                BNE :7             ; always

:5              LDA DATA_FARRIGHT
                AND #$30            ; north
;               CMP #$00            ; north open
                BEQ :6
                CMP #$10            ; north face
                BNE :8

:6              LDA DATA_RIGHT
                AND #XSIDE_MASK!$FF
                ORA #XSIDE_FACE
:7              STA DATA_RIGHT
:8              LDA DATA_RIGHT
        fin
                STA BLOCK_BUFFER,X

                INX
                STX BLOCK_COUNT

                CPX #17*2               ; temporary hard limit
                BEQ :DONE

                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BNE :DONE           ; stop if not an opening

                JSR MOVE_FORWARD
                JMP :NEXT

:DONE           ; TODO: store a terminator? ***
                JMP PULL_MAP_STATE

; save/restore MAP_FACE through MAP_PTR_H state

PUSH_MAP_STATE  LDX MAP_STATE_PTR
                LDY #5
:1              LDA MAP_FACE,Y
                DEX
                STA MAP_STATE_STACK,X
                DEY
                BPL :1
                STX MAP_STATE_PTR
                RTS

PULL_MAP_STATE  LDX MAP_STATE_PTR
                LDY #0
:1              LDA MAP_STATE_STACK,X
                INX
                STA MAP_FACE,Y
                INY
                CPY #6
                BNE :1
                STX MAP_STATE_PTR
                RTS

SWAP_MAP_STATE  LDX MAP_STATE_PTR
                LDY #0
:1              LDA MAP_STATE_STACK,X
                PHA
                LDA MAP_FACE,Y
                STA MAP_STATE_STACK,X
                PLA
                STA MAP_FACE,Y
                INX
                INY
                CPY #6
                BNE :1
                RTS

MAP_STATE_PTR   DB  6*3
MAP_STATE_STACK DS  6*3
;
; Save/restore MAP_FACE through MAP_PTR_H, separate from
;   state stack.  Used for backing up when running from fight.
; TODO: consider using a random location nearby
;
SAVE_MAP_POS    LDX #0
:1              LDA MAP_FACE,X
                STA SAVED_MAP_POS,X
                INX
                CPX #6
                BNE :1
                RTS

RESTORE_MAP_POS LDX #0
:1              LDA SAVED_MAP_POS,X
                STA MAP_FACE,X
                INX
                CPX #6
                BNE :1
                RTS

;*** put this some place that survives load/store? ***
SAVED_MAP_POS   DS  6

MARK_MAPPED     ENT
                LDY MAP_X
                LDA (MAP_PTR),Y
                ORA #MAPPED_MASK
                STA (MAP_PTR),Y
                RTS

LOAD_MAP_DATA   LDY MAP_X
                LDA (MAP_PTR),Y     ; Wa.Na.xx.xx
                AND #$F0            ; Wa.Na.00.00
                STA DATA_TEMP1
                INY
                LDA (MAP_PTR),Y     ; Wb.Nb.xx.xx
                STA DATA_TEMP2
                TYA
                CLC
                ADC MAP_SIZE        ; + 1 from INY
                TAY
                LDA (MAP_PTR),Y     ; Wc.Nc.xx.xx
                EOR DATA_TEMP2      ; xx.xx.xx.xx
                AND #$30            ; 00.xx.00.00
                EOR DATA_TEMP2      ; Wb.Nc.xx.xx
                LSR
                LSR
                LSR
                LSR                 ; 00.00.Wb.Nc
                ORA DATA_TEMP1      ; Wa.Na.Wb.Nc
                LDX MAP_DIR
                BEQ :2
:1              ASL
                ADC #0
                ASL
                ADC #0
                DEX
                BNE :1
:2              RTS

MOVE_LEFT       JSR TURN_LEFT
                JSR MOVE_FORWARD
TURN_RIGHT      LDX MAP_DIR
                INX
                TXA
                AND #$03
                STA MAP_DIR
                RTS

MOVE_RIGHT      JSR TURN_RIGHT
                JSR MOVE_FORWARD
TURN_LEFT       LDX MAP_DIR
                DEX
                TXA
                AND #$03
                STA MAP_DIR
                RTS

MOVE_BACKWARD   JSR TURN_AROUND
                JSR MOVE_FORWARD
TURN_AROUND     LDX MAP_DIR
                INX
                INX
                TXA
                AND #$03
                STA MAP_DIR
                RTS

MOVE_FORWARD    LDX MAP_DIR
                DEX
                BPL :ESW

:N              LDY MAP_Y
                DEY
                BMI :CHANGE_FACE
                STY MAP_Y

                LDA MAP_PTR
                CLC                ; MAP_SIZE + 1
                SBC MAP_SIZE
                STA MAP_PTR
                BCS :N2
                DEC MAP_PTR_H
:N2             RTS

:ESW            DEX
                BPL :SW

                LDX MAP_X
                INX
                CPX MAP_SIZE
                BEQ :CHANGE_FACE
                STX MAP_X
                RTS

:SW             DEX
                BPL :W

:S              LDY MAP_Y
                INY
                CPY MAP_SIZE
                BEQ :CHANGE_FACE
                STY MAP_Y

                LDA MAP_PTR
                SEC                ; MAP_SIZE + 1
                ADC MAP_SIZE
                STA MAP_PTR
                BCC :S2
                INC MAP_PTR_H
:S2             RTS

:W              LDX MAP_X
                DEX
                BMI :CHANGE_FACE
                STX MAP_X
                RTS

:CHANGE_FACE    LDA MAP_X
                STA FACE_TABLE+1
                LDA MAP_Y
                STA FACE_TABLE+2
                LDX MAP_SIZE
                DEX
                STX FACE_TABLE+3
                TXA
                SEC
                SBC MAP_X
                STA FACE_TABLE+4
                TXA
                SEC
                SBC MAP_Y
                STA FACE_TABLE+5

                LDA MAP_FACE
                ASL
                ASL                ; four entries (directions) per source face
;               CLC
                ADC MAP_DIR
                ASL                ; two bytes per direction
                TAX
                LDA FACE_DATA+0,X
                TAY
                AND #$03           ; extract dest direction
                STA MAP_DIR
                TYA
                LSR
                LSR                ; extract dest face
                STA MAP_FACE
                LDA FACE_DATA+1,X
                TAY
                LSR
                LSR
                LSR
                LSR
                TAX                ; extract dest X coordinate
                LDA FACE_TABLE,X
                STA MAP_X
                TYA
                AND #$0F           ; extract dest Y coordinate
                TAX
                LDA FACE_TABLE,X
                STA MAP_Y
                JMP COMPUTE_MAP_PTR

SET_MAP_DATA    ENT
                STX MAP_PTR_MOD_L+1
                STY MAP_PTR_MOD_H+1
                STX TEMP_PTR
                STY TEMP_PTR_H
                LDY #0
                LDA (TEMP_PTR),Y
                STA MAP_SIZE
                INY
                LDA (TEMP_PTR),Y
                ASL
;               CLC
                ADC #2                  ; skip map size and count
                STA MAP_OFF_MOD+1
                RTS

COMPUTE_MAP_PTR ENT
MAP_PTR_MOD_L   LDA #$FF
                STA TEMP_PTR
MAP_PTR_MOD_H   LDA #$FF
                STA TEMP_PTR_H

                ; look up map face using pointer table

                LDA MAP_FACE
                ASL
;               CLC
                ADC #2                  ; skip map size and count
                TAY
                LDA (TEMP_PTR),Y
                STA MAP_PTR
                INY
                LDA (TEMP_PTR),Y
                STA MAP_PTR_H

                ; multiply Y by map byte width using lookup table
                ;    and set map pointer to correct line in face map

                LDA MAP_Y
                ASL
;               CLC
MAP_OFF_MOD     ADC #$FF                ; skip map size, count, and pointers
                TAY
                LDA (TEMP_PTR),Y
;               CLC
                ADC MAP_PTR
                STA MAP_PTR
                INY
                LDA (TEMP_PTR),Y
                ADC MAP_PTR_H
                STA MAP_PTR_H
                RTS

; TODO: consider building table in ZPAGE
FACE_TABLE      DB  0               ; 0: 0
                DB  0               ; 1: MAP_X
                DB  0               ; 2: MAP_Y
                DB  0               ; 3: MAP_SIZE - 1 - 0
                DB  0               ; 4: MAP_SIZE - 1 - MAP_X
                DB  0               ; 5: MAP_SIZE - 1 - MAP_Y

;        +---+
;        | 0 |
;    +---+---+---+---+---+
;    | 4 | 1 | 2 | 3 | 4 |
;    +---+---+---+---+---+
;        | 5 |
;        +---+

north           =   0
east            =   1
south           =   2
west            =   3

FACE_DATA       DB  3 * 4 + south, $40    ; north -> 3 south   size-x   0
                DB  2 * 4 + south, $50    ; east  -> 2 south   size-y   0
                DB  1 * 4 + south, $10    ; south -> 1 south   x        0
                DB  4 * 4 + south, $20    ; west  -> 4 south   y        0

                DB  0 * 4 + north, $13    ; north -> 0 north   x        size
                DB  2 * 4 + east,  $02    ; east  -> 2 east    0        y
                DB  5 * 4 + south, $10    ; south -> 5 south   x        0
                DB  4 * 4 + west,  $32    ; west  -> 4 west    size     y

                DB  0 * 4 + west,  $34    ; north -> 0 west    size     size-x
                DB  3 * 4 + east,  $02    ; east  -> 3 east    0        y
                DB  5 * 4 + west,  $31    ; south -> 5 west    size     x
                DB  1 * 4 + west,  $32    ; west  -> 1 west    size     y

                DB  0 * 4 + south, $40    ; north -> 0 south   size-x   0
                DB  4 * 4 + east,  $02    ; east  -> 4 east    0        y
                DB  5 * 4 + north, $43    ; south -> 5 north   size-x   size
                DB  2 * 4 + west,  $32    ; west  -> 2 west    size     y

                DB  0 * 4 + east,  $01    ; north -> 0 east    0        x
                DB  1 * 4 + east,  $02    ; east  -> 1 east    0        y
                DB  5 * 4 + east,  $04    ; south -> 5 east    0        size-x
                DB  3 * 4 + west,  $32    ; west  -> 3 west    size     y

                DB  1 * 4 + north, $13    ; north -> 1 north   x        size
                DB  2 * 4 + north, $23    ; east  -> 2 north   y        size
                DB  3 * 4 + north, $43    ; south -> 3 north   size-x   size
                DB  4 * 4 + north, $53    ; west  -> 4 north   size-y   size

                ; NOTE: only used for special level 9, face 6
                DB  6 * 4 + north, $13    ; north -> 6 north   x        size
                DB  6 * 4 + east,  $02    ; east  -> 6 east    0        y
                DB  6 * 4 + south, $10    ; south -> 6 south   x        0
                DB  6 * 4 + west,  $32    ; west  -> 6 west    size     y
