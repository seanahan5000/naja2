
; TODO:
; - option to scroll UDLR in map using arrow keys?
; - option to rotate to direction faced?
; - background fill pattern?

ThickWalls      =   0
WhiteWalls      =   0

; TODO: make this more like a camp module
; TODO: use camp zpage, not hall zpage

SCREEN_Y        =   $11
CELL_Y          =   $12
MAP_ROW         =   $13

FILTER_FACE     =   $14
NEW_FACE        =   $15

MAPPED_INDEX    =   $16
MAPPED_BITS     =   $17

FILL0_BITS      =   $18
FILL1_BITS      =   $19

MAPPED_MASK       = %00000001           ; assumed to be low bit
PREV_MAPPED_MASK  = %00000010           ; assumed to be next bit up
BOTH_MAPPED_MASKS = %00000011

NORTH_MASK      =   %00110000
WEST_MASK       =   %11000000

NORTH_OPEN      =   (OPEN * 16)
NORTH_FACE      =   (FACE * 16)
NORTH_DOOR      =   (DOOR * 16)
NORTH_WALL      =   (WALL * 16)

WEST_OPEN       =   (OPEN * 64)
WEST_FACE       =   (FACE * 64)
WEST_DOOR       =   (DOOR * 64)
WEST_WALL       =   (WALL * 64)

MAP_TOP_LINE    =   6
        do ThickWalls
MAP_LEFT_BYTE   =   1
MAP_WIDTH_CELLS =   19
        else
MAP_LEFT_BYTE   =   2
MAP_WIDTH_CELLS =   18
        fin
CELL_HEIGHT     =   13
MAP_HEIGHT_CELLS =  14
MAX_MAP_SIZE    =   17

        do ThickWalls
ARROW_X         =   MAP_LEFT_BYTE+8*14+7
        else
ARROW_X         =   MAP_LEFT_BYTE+8*14
        fin
ARROW_Y         =   MAP_HEIGHT_CELLS/2*CELL_HEIGHT+MAP_TOP_LINE+4

; TODO: use SCRATCH_PAGE buffers instead
BLOCK_BUFFER2   =   BLOCK_BUFFER+MAP_WIDTH_CELLS+2

; TODO: generalize/share these
ARROW_SHAPES    DB  $00,$00,$00,$40,$60,$70,$00     ; up arrow
                DB  $00,$02,$07,$0F,$1F,$3F,$00

                DB  $60,$60,$60,$60,$60,$60,$60     ; right arrow
                DB  $00,$03,$0F,$3F,$0F,$03,$00

                DB  $00,$70,$60,$40,$00,$00,$00     ; down arrow
                DB  $00,$3F,$1F,$0F,$07,$02,$00

                DB  $00,$00,$40,$70,$40,$00,$00     ; left arrow
                DB  $18,$1E,$1F,$1F,$1F,$1E,$18

SHOW_MAP        ENT

:DRAW_LOOP      JSR DRAW_PICT
                PictSetPageX
                PictClearPage
                PictCall DRAW_MAP
                PictShowPage
                PictEnd
:KEY_LOOP       JSR RANDOM
                LDA KEYBRD
                BPL :KEY_LOOP
                BIT UNSTROB
                JSR CHECK_LEFT
                BEQ :LEFT
                JSR CHECK_RIGHT
                BEQ :RIGHT
                JSR CHECK_UP
                BEQ :UP
                JSR CHECK_DOWN
                BEQ :DOWN
                ; TODO: up/down/reverse?
                JSR DRAW_PICT
                PictSetPageX
                PictClearPage
                ; TODO: combine these two calls?
                PictCall GET_NSEW
                PictCall DRAW_HALL
                PictShowPage
                PictEnd
                ; TODO: make this normalization code common?
                LDA PAGE
                CMP #$20
                BEQ :1
                JSR DRAW_PICT
                PictSetPageX
                PictCopyToPage
                PictShowPage
                PictEnd
:1              SEC
                RTS

:UP             ; TODO: handle simple up
                JMP :KEY_LOOP

:DOWN           ; TODO: handle simple down
                JMP :KEY_LOOP

:LEFT           LDA PBUTTON0            ; open-apple
                BMI :ROT_CCW
                ; TODO: handle simple left
                JMP :KEY_LOOP

:RIGHT          LDA PBUTTON0            ; open-apple
                BMI :ROT_CW
                ; TODO: handle simple right
                JMP :KEY_LOOP

:ROT_CCW        LDX MAP_ROTATION
                INX
                JMP :ROTATE

:ROT_CW         LDX MAP_ROTATION
                DEX
:ROTATE         STX MAP_ROTATION
                JMP :DRAW_LOOP

MAP_ROTATION    DB  NORTH

DRAW_MAP        JSR PUSH_MAP_STATE      ; save actual map position

                LDA MAP_ROTATION
                AND #3
                STA MAP_DIR

                LDA MAP_FACE            ; capture before MOVE_FORWARD changes it
                PHA

                LDA #MAP_HEIGHT_CELLS/2
                STA BLOCK_COUNT
:1              JSR MOVE_FORWARD
                DEC BLOCK_COUNT
                BNE :1

; If MAP_FACE is 1, 2, 3, or 4 and a different face will be visible above it,
;   then start with filtering that northern face.

                LDX #$FF
                PLA
                ; BEQ :2
                ; CMP #5
                ; BEQ :2
                CMP MAP_FACE
                BEQ :2
                LDX MAP_FACE
:2              STX FILTER_FACE

                JSR PUSH_MAP_STATE      ; save center map position

                LDA #MAP_WIDTH_CELLS/2
                STA BLOCK_COUNT
:3              JSR MOVE_LEFT
                DEC BLOCK_COUNT
                BNE :3

                JSR PUSH_MAP_STATE      ; save left map position

                LDA #MAP_TOP_LINE
                STA SCREEN_Y

                LDX #MAX_MAP_SIZE+3     ; clear prev line and left/right padding
                LDA #0
:4              STA BLOCK_BUFFER,X
                STA BLOCK_BUFFER2,X
                DEX
                BPL :4

                LDA #0
                STA MAP_ROW
                JMP FIRST_ROW

NEXT_ROW
        do ThickWalls
                LDA #0
                STA CELL_Y
        else
                LDA #-1
                STA CELL_Y
                DEC SCREEN_Y            ; up one line for overlap
        fin

NEXT_LINE       LDY #MAP_LEFT_BYTE
                LDX SCREEN_Y
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH

                LDX #0
NEXT_CELL       LDA BLOCK_BUFFER+1,X
                STA BLOCK_DATA

                LDA #0
                STA FILL0_BITS
                STA FILL1_BITS
                LDA BLOCK_DATA
                AND #MAPPED_MASK
                BNE :11
        do ThickWalls
            do WhiteWalls
                LDA #$7C
                STA FILL0_BITS
                LDA #$7F
                STA FILL1_BITS
            else
                LDA #$54
                STA FILL0_BITS
                LDA #$2A
                STA FILL1_BITS
            fin
        else
                LDA #$28
                STA FILL0_BITS
                LDA #$55
                STA FILL1_BITS
        fin
:11
                LDA CELL_Y
        do ThickWalls
                CMP #3
                BCS :WEST_EDGE
        else
                BMI :NORTH_OVERLAP
                BEQ :NORTH_EDGE
                BNE :WEST_EDGE          ; always

:NORTH_OVERLAP  LDA BLOCK_DATA
                AND #NORTH_MASK
                CMP #NORTH_DOOR
                BNE :22

                LDA BLOCK_DATA
                AND #BOTH_MAPPED_MASKS
                BEQ :22
                JMP :NORTH_DOOR_N

:22             INY
                JMP :CELL_DONE2
        fin

:NORTH_EDGE     LDA BLOCK_DATA
                AND #BOTH_MAPPED_MASKS
                BEQ :NORTH_WALL

                LDA BLOCK_DATA
                AND #NORTH_MASK
;               CMP #NORTH_OPEN
                BEQ :NORTH_OPEN
                CMP #NORTH_FACE
                BEQ :NORTH_FACE
                CMP #NORTH_WALL
                BEQ :NORTH_WALL

:NORTH_DOOR
        do ThickWalls
            do WhiteWalls
                LDA #$1F
            else
                LDA #$15
            fin
                STA (SCREENL),Y
                INY
            do WhiteWalls
                LDA #$60
            else
                LDA #$20
            fin
        else
                LDA #$6A
                STA (SCREENL),Y
                INY
                LDA #$5F
        fin
                STA (SCREENL),Y
                JMP :CELL_DONE2

:NORTH_WALL
        do ThickWalls
            do WhiteWalls
                LDA #$7F
            else
                LDA #$55
            fin
                STA (SCREENL),Y
                INY
            do WhiteWalls
                LDA #$7F
            else
                LDA #$2A
            fin
        else
                LDA #$2A
                STA (SCREENL),Y
                INY
                LDA #$55
        fin
                STA (SCREENL),Y
                BNE :CELL_DONE2         ; always

:NORTH_FACE
        do ThickWalls
                LDA CELL_Y
            ; do WhiteWalls
            ;     CMP #1
            ;     BNE :222
            ; else
                CMP #2
                BCS :222
            ; fin

            do WhiteWalls
                LDA #$67
            else
                LDA #$65
            fin
                STA (SCREENL),Y
                INY
            do WhiteWalls
                LDA #$67
            else
                LDA #$27
            fin
                STA (SCREENL),Y
                BNE :CELL_DONE2         ; always

:222
            do WhiteWalls
                LDA #$07
            else
                LDA #$05
            fin
                STA (SCREENL),Y
                INY
            do WhiteWalls
                LDA #$60
            else
                LDA #$20
            fin
                STA (SCREENL),Y
        else
                LDA #$52
                STA (SCREENL),Y
                INY
                LDA #$2A
                STA (SCREENL),Y
        fin
                BNE :CELL_DONE2         ; always

:NORTH_OPEN     LDA BLOCK_BUFFER+1-1,X
                AND #NORTH_MASK
;               CMP #NORTH_OPEN
                BNE :WEST_WALL
                LDA BLOCK_DATA
                AND #WEST_MASK
;               CMP #WEST_OPEN
                BNE :WEST_WALL

                LDA BLOCK_DATA
                AND #MAPPED_MASK
                BEQ :WEST_WALL
                BNE :CELL_DONE1         ; always

:WEST_EDGE      LDA BLOCK_DATA
                AND #MAPPED_MASK
                BNE :33
                LDA BLOCK_BUFFER+1-1,X
                AND #MAPPED_MASK
                BEQ :WEST_WALL

:33             LDA BLOCK_DATA
                AND #WEST_MASK
;               CMP #WEST_OPEN
                BEQ :WEST_OPEN
                CMP #WEST_FACE
                BEQ :WEST_FACE
                CMP #WEST_WALL
                BEQ :WEST_WALL

:WEST_DOOR      LDA CELL_Y
        do ThickWalls
                CMP #4
                BCC :WEST_WALL
                CMP #12
                BCS :WEST_WALL
                LDA #$02
        else
                CMP #3
                BCC :WEST_WALL
                CMP #11
                BCS :WEST_WALL
                LDA #$07
        fin
                BNE :WRITE_CELL         ; always

:WEST_OPEN      LDA BLOCK_DATA
                AND #MAPPED_MASK
                BNE :44

:WEST_WALL
        do ThickWalls
            do WhiteWalls
                LDA #$07
            else
                LDA #$05
            fin
        else
                LDA #$02
        fin
                BNE :WRITE_CELL         ; always

:WEST_FACE      LDA CELL_Y
        do ThickWalls
                CMP #5
                BCC :44
                CMP #11
                BCS :44
                LDA #$03
                BNE :WRITE_CELL         ; always
        else
                CMP #2
                BCC :44
                CMP #12
                BCS :44
                LDA #$04
                BNE :WRITE_CELL         ; always
        fin
:44             LDA #$00
:WRITE_CELL     ORA FILL0_BITS
                STA (SCREENL),Y
:CELL_DONE1     INY
                LDA FILL1_BITS
                STA (SCREENL),Y
:CELL_DONE2     INY

                LDA CELL_Y
                CMP #1
                BNE :NOT_LINE1

                LDA BLOCK_DATA
                AND #NORTH_MASK
                CMP #NORTH_DOOR
                BNE :NOT_LINE1

                LDA BLOCK_DATA
                AND #BOTH_MAPPED_MASKS
                BEQ :NOT_LINE1

:NORTH_DOOR1    DEY
                DEY
:NORTH_DOOR_N
        do ThickWalls
            do WhiteWalls
                LDA #$27
            else
                LDA #$25
            fin
                ; ORA (SCREENL),Y
                STA (SCREENL),Y
                INY
                LDA #$15
                ; ORA (SCREENL),Y
                STA (SCREENL),Y
        else
                LDA #$60
                ORA (SCREENL),Y
                STA (SCREENL),Y
                INY
                LDA #$1F
                ORA (SCREENL),Y
                STA (SCREENL),Y
        fin
                INY

:NOT_LINE1      INX
                CPX #MAP_WIDTH_CELLS
                BEQ LINE_DONE
                JMP NEXT_CELL

LINE_DONE       INC SCREEN_Y
                INC CELL_Y
                LDA CELL_Y
                CMP #CELL_HEIGHT
                BEQ ROW_DONE
                JMP NEXT_LINE

ROW_DONE        INC MAP_ROW
                LDA MAP_ROW
                CMP #MAP_HEIGHT_CELLS
                BNE :ANOTHER_ROW

:ROWS_DONE      JSR PULL_MAP_STATE      ; remove left position
                JSR PULL_MAP_STATE      ; remove center position
                JSR PULL_MAP_STATE      ; restore actual map position
                ;
                ; TODO: if this changes, consider making cell calls private again
                ;
                LDX #ARROW_X
                LDY #ARROW_Y
                JSR MOVE_TO
                LDA MAP_DIR
                SEC
                SBC MAP_ROTATION
                AND #3
                PHA
                ASL
                JSR :DRAW_ARROW
                PLA
                SEC
                ROL
:DRAW_ARROW     LDX #<ARROW_SHAPES
                LDY #>ARROW_SHAPES
                JMP DRAW_TILE_A

:ANOTHER_ROW    JSR PULL_MAP_STATE      ; restore left map position
                JSR SWAP_MAP_STATE      ; get center map position, put left on stack

                LDA #0
                STA NEW_FACE
                LDA MAP_FACE
                PHA
                JSR MOVE_BACKWARD
                PLA
                CMP MAP_FACE
                BEQ :SAME_ROW_FACE

:NEW_ROW_FACE   JSR SWAP_MAP_STATE      ; restore left position, put center on stack
                JSR PULL_MAP_STATE      ; throw away left position and get center
                JSR PUSH_MAP_STATE      ; re-save center position

                INC NEW_FACE
                LDA FILTER_FACE
                EOR #$FF
                BMI :1
                LDA MAP_FACE
:1              STA FILTER_FACE

                LDA #MAP_WIDTH_CELLS/2
                STA BLOCK_COUNT
:2              JSR MOVE_LEFT
                DEC BLOCK_COUNT
                BNE :2
                BEQ :3                  ; always

:SAME_ROW_FACE  JSR SWAP_MAP_STATE      ; restore left position, put center on stack
                JSR MOVE_BACKWARD
:3              JSR PUSH_MAP_STATE      ; put left position back on stack

FIRST_ROW       LDA #0
                STA BLOCK_COUNT
                BEQ :2                  ; always

:1              INX
                STX BLOCK_COUNT
                LDA MAP_FACE
                PHA
                JSR MOVE_RIGHT
                PLA
                CMP MAP_FACE
                BEQ :SAME_COL_FACE

:NEW_COL_FACE   LDA FILTER_FACE
                BMI :4
                CMP MAP_FACE
                BEQ :4

                LDX BLOCK_COUNT
                LDA BLOCK_BUFFER2-1,X   ; W.N.E.S -> x.x.E.x
                AND #$0C
                LDY NEW_FACE
                BEQ :11
                EOR BLOCK_BUFFER2,X     ; W.N.E.S -> x.x.x.S
                AND #$0C
                EOR BLOCK_BUFFER2,X     ; W.N.E.S -> x.x.E.S
:11             ASL
                ASL
                ASL
                ASL                     ; E.S.0.0
                ORA #MAPPED_MASK
                BNE :5                  ; always

:SAME_COL_FACE
:2              LDA FILTER_FACE
                BMI :4
                CMP MAP_FACE
                BEQ :4

                LDX BLOCK_COUNT
                LDA #MAPPED_MASK        ; mapped but otherwise all open
                LDY NEW_FACE
                BEQ :5

                LDA BLOCK_BUFFER2,X     ; W.N.E.S -> 0.0.0.S
                AND #$03
                ASL
                ASL
                ASL
                ASL                     ; 0.S.0.0
                ORA #MAPPED_MASK
                BNE :5                  ; always

:4              JSR LOAD_MAP_DATA
                LDX BLOCK_COUNT
                STA BLOCK_BUFFER2,X
                STA BLOCK_DATA

                LDA BLOCK_BUFFER+1,X
                ASL
                EOR BLOCK_DATA
                AND #PREV_MAPPED_MASK
                EOR BLOCK_DATA          ; insert now-prev mapped bit
                LDY MAP_X
                EOR (MAP_PTR),Y
                AND #MAPPED_MASK!$FF
                EOR (MAP_PTR),Y         ; reinsert mapped bit

:5              STA BLOCK_BUFFER+1,X
                CPX #MAP_WIDTH_CELLS-1
                BNE :1
                JMP NEXT_ROW
;
; Extract all mapped bits from map data into a
;   contiguous buffer of just those bits.
;
SAVE_MAPPED     ENT
                JSR PUSH_MAP_STATE
                LDA #0
                STA MAPPED_INDEX
                STA MAP_FACE
                STA MAP_X
                STA MAP_Y
                JSR COMPUTE_MAP_PTR
                LDX #8
                LDA #0
                STA MAPPED_BITS
:NEXT_ROW       LDY #0
:NEXT_COLUMN    LDA (MAP_PTR),Y
                LSR
                ROL MAPPED_BITS
                DEX
                BNE :SAME_BYTE
                LDX MAPPED_INDEX
                STA MAP_VISITED,X
                INX
                STX MAPPED_INDEX
                LDX #8
                LDA #0
                STA MAPPED_BITS
:SAME_BYTE      INY
                CPY MAP_SIZE
                BNE :NEXT_COLUMN
                JSR ADVANCE_ROW
                BCC :NEXT_ROW
:MAP_DONE       TXA
                BEQ :EXIT
:FLUSH          ASL MAPPED_BITS
                DEX
                BNE :FLUSH
                LDX MAPPED_INDEX
                LDA MAPPED_BITS
                STA MAP_VISITED,X
                INX
                STX MAPPED_INDEX
:EXIT           JMP PULL_MAP_STATE
;
; Insert saved mapped bits from contiguous buffer into map data.
;
RESTORE_MAPPED  ENT
                JSR PUSH_MAP_STATE
                LDA #0
                STA MAPPED_INDEX
                STA MAP_FACE
                STA MAP_X
                STA MAP_Y
                JSR COMPUTE_MAP_PTR
                LDX #8
                LDA MAP_VISITED
                STA MAPPED_BITS
:NEXT_ROW       LDY #0
:NEXT_COLUMN    LDA (MAP_PTR),Y
                LSR
                ROL MAPPED_BITS
                ROL
                STA (MAP_PTR),Y
                DEX
                BNE :SAME_BYTE
                INC MAPPED_INDEX
                LDX MAPPED_INDEX
                LDA MAP_VISITED,X
                STA MAPPED_BITS
                LDX #8
:SAME_BYTE      INY
                CPY MAP_SIZE
                BNE :NEXT_COLUMN
                JSR ADVANCE_ROW
                BCC :NEXT_ROW
                JMP PULL_MAP_STATE
;
; Advance MAP_PTR to next row or start of next face.
;
ADVANCE_ROW     INC MAP_Y
                LDA MAP_Y
                CMP MAP_SIZE
                BEQ :NEXT_FACE
                LDA MAP_PTR
                SEC                     ; MAP_SIZE + 1
                ADC MAP_SIZE
                STA MAP_PTR
                BCS :1
                RTS
:1              INC MAP_PTR_H
                CLC
                RTS
:NEXT_FACE      INC MAP_FACE
                LDA MAP_FACE
                CMP #6
                BEQ :MAP_DONE
                LDA #0
                STA MAP_Y
                TXA
                PHA
                JSR COMPUTE_MAP_PTR
                PLA
                TAX
                CLC
                RTS
:MAP_DONE       SEC
                RTS
