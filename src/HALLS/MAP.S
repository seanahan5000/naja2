
; TODO: add module header and this loadable

; TODO: make these common blit zpage vars
SRC_LINE        =   $D0
DST_LINE        =   $D1

; TODO: make this more like a camp module

LOC_CX          =   $C0                 ; location in screen-relative cells
LOC_CY          =   $C1

CLIP_TOP        =   $C2                 ; inclusive
CLIP_LEFT       =   $C3                 ; inclusive
CLIP_BOTTOM     =   $C4                 ; exclusive
CLIP_RIGHT      =   $C5                 ; exclusive

CUR_CX          =   $C6                 ; screen-relative cells
CUR_CY          =   $C7

FILTER_FACE     =   $C8
NEW_VFACE       =   $C9

FILL0_BITS      =   $CA
FILL1_BITS      =   $CB
FORCE_NORTH     =   $CC
SAVE_FACE       =   $CD

DST_COL         =   LOCAL_TEMP+0
OFFSET          =   LOCAL_TEMP+1
TOP_LINE        =   LOCAL_TEMP+2
BOTTOM_LINE     =   LOCAL_TEMP+3

MAPPED_MASK     =   %00000001           ; mapped and dead masks order dependent
DEAD_MASK       =   %00000010
PREV_MAPPED_MASK =  %00000100
PREV_DEAD_MASK  =   %00001000
NORTH_MASK      =   %00110000
WEST_MASK       =   %11000000

NORTH_OPEN      =   OPEN * 16
NORTH_FACE      =   FACE * 16
NORTH_DOOR      =   DOOR * 16
NORTH_WALL      =   WALL * 16

WEST_OPEN       =   OPEN * 64
WEST_FACE       =   FACE * 64
WEST_DOOR       =   DOOR * 64
WEST_WALL       =   WALL * 64

MAP_TOP_PAD     =   5
MAP_BOTTOM_PAD  =   4
MAP_WIDTH_CELLS =   20
CELL_WIDTH      =   14
CELL_HEIGHT     =   13
MAP_HEIGHT_CELLS =  15
MAX_MAP_SIZE    =   17

CENTER_CELL_X   =   MAP_WIDTH_CELLS/2
CENTER_CELL_Y   =   MAP_HEIGHT_CELLS/2

; TODO: move this -- it's used by hall code
; NOTE: map code expects this to be (MAP_SIZE + 1) * 2 = minimum 36 bytes in size
BLOCK_BUFFER    ENT
                DS  64                  ; TODO: move this somewhere else
                                        ; TODO: how much space is needed?
; TODO: use SCRATCH_PAGE buffers instead
BLOCK_BUFFER2   DS  32                  ; BLOCK_BUFFER+MAP_WIDTH_CELLS+2

SHOW_MAP        ENT

                ; start with location marker in center of screen
                LDA #CENTER_CELL_X
                STA LOC_CX
                LDA #CENTER_CELL_Y
                STA LOC_CY

                JSR DRAW_PICT
                PictSetPageX
                PictClearPage
                PictCall RESET_CLIP
                PictCall DRAW_MAP
                PictCall DRAW_LOCATION
                PictShowPage
                PictSetPageX
                PictClearPage
                PictSetPageX
                PictEnd

:BLINK_LOOP     LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI :GOT_KEY
                JSR DRAW_LOCATION
                LDA #$00
                JSR WAIT_KEY
                JSR DRAW_LOCATION
:KEY_LOOP       JSR RANDOM
                LDA KEYBRD
                BPL :BLINK_LOOP
:GOT_KEY        BIT UNSTROB
                JSR CHECK_LEFT
                BEQ :LEFT
                JSR CHECK_RIGHT
                BEQ :RIGHT
                JSR CHECK_UP
                BEQ :UP
                JSR CHECK_DOWN
                BEQ :DOWN
                JSR DRAW_PICT
                PictSetPageX
                PictClearPage
                ; TODO: combine these two calls?
                PictCall GET_NSEW
                PictCall DRAW_HALL
                PictShowPage
                PictEnd

                ; TODO: make this normalization code common
                LDA PAGE
                CMP #$20
                BEQ :3
                JSR DRAW_PICT
                PictSetPageX
                PictCopyToPage
                PictShowPage
                PictEnd
:3
                SEC
                RTS

:UP             JSR MAP_MOVE_DOWN
                JMP :KEY_LOOP

:DOWN           JSR MAP_MOVE_UP
                JMP :KEY_LOOP

:LEFT           LDA PBUTTON0            ; open-apple
                BMI :ROT_CCW
                JSR MAP_MOVE_RIGHT
                JMP :KEY_LOOP

:RIGHT          LDA PBUTTON0            ; open-apple
                BMI :ROT_CW
                JSR MAP_MOVE_LEFT
                JMP :KEY_LOOP

:ROT_CCW        LDX MAP_ROTATION
                INX
                BNE :ROTATE             ; always

:ROT_CW         LDX MAP_ROTATION
                DEX
:ROTATE         TXA
                AND #3
                STA MAP_ROTATION
                JSR DRAW_PICT
                PictSetPageX
                PictClearPage
                PictCall RESET_CLIP
                PictCall DRAW_MAP
                PictCall DRAW_LOCATION
                PictShowPage
                PictEnd
                JMP :KEY_LOOP

MAP_ROTATION    DB  NORTH

; 0 1 2 3 4 5 6 7 8 9 A B C D
;           d d d d d d d
; . X - - F - F - F - F - F -
; . | f . . D D D D D D D . .
; . | F *   *   *   *   *   *
; D | D *   *   *   *   *   *
; D | D *   *   *   *   *   *
; D | D *   *   *   *   *   *
; D | D *   *   *   *   *   *
; D | D *   *   *   *   *   *
; D | D *   *   *   *   *   *
; D | D *   *   *   *   *   *
; D | D *   *   *   *   *   *
; . | F *   *   *   *   *   *
; . | f *   *   *   *   *   *

DRAW_MAP        JSR PUSH_MAP_STATE      ; save actual map position

                LDA MAP_ROTATION
                AND #3
                STA MAP_DIR

                LDA MAP_FACE            ; capture before MOVE_FORWARD changes it
                STA SAVE_FACE

                LDA LOC_CY
                BEQ :2
                STA BLOCK_COUNT
:1              JSR MOVE_FORWARD
                DEC BLOCK_COUNT
                BNE :1
:2
                LDX #MAX_MAP_SIZE+3     ; clear prev line and left/right padding
:3              LDA #DEAD_MASK
                STA BLOCK_BUFFER,X
                LDA #0
                STA BLOCK_BUFFER2,X
                DEX
                BPL :3

                LDA #0
                STA CUR_CY

NEW_ROW_FACE    JSR PUSH_MAP_STATE      ; re-save center position

                LDX MAP_FACE
                CPX SAVE_FACE
                BNE :1
                LDX #-1
:1              STX FILTER_FACE

                LDA LOC_CX
                BEQ CONT_ROW_FACE
                STA BLOCK_COUNT
:2              JSR MOVE_LEFT
                DEC BLOCK_COUNT
                BNE :2

CONT_ROW_FACE   JSR PUSH_MAP_STATE      ; put left position back on stack

                LDA #0
                STA BLOCK_COUNT

; skip over clipped rows, up to row before first visible
                LDX CUR_CY
                INX
                CPX CLIP_TOP
                BCS :1
                JMP ROW_DONE

; skip over clipped columns, up to column before first visible
:1              LDX BLOCK_COUNT
                INX
                CPX CLIP_LEFT
                BCS :2
                STX BLOCK_COUNT
                JSR MOVE_RIGHT
                JMP :1
:2

SAME_COL_FACE   LDA FILTER_FACE
                BMI FULL_COL
                CMP MAP_FACE
                BEQ FULL_COL

; build empty dead block
                LDX BLOCK_COUNT
                LDA #DEAD_MASK
                LDY NEW_VFACE
                BEQ COL_FACE_CMN

; build dead block along bottom edge of face
                LDA BLOCK_BUFFER2,X     ; W.N.E.S -> 0.0.0.S
                AND #$03
                ASL
                ASL
                ASL
                ASL                     ; 0.S.0.0
                ORA #DEAD_MASK
                BNE COL_FACE_CMN        ; always

NEW_COL_FACE    LDA FILTER_FACE
                BMI FULL_COL
                CMP MAP_FACE
                BEQ FULL_COL

; build dead block along corner bottom edge of face
                LDX BLOCK_COUNT
                LDA BLOCK_BUFFER2-1,X   ; W.N.E.S -> x.x.E.x
                AND #$0C
                LDY NEW_VFACE
                BEQ :1
                EOR BLOCK_BUFFER2,X     ; W.N.E.S -> x.x.x.S
                AND #$0C
                EOR BLOCK_BUFFER2,X     ; W.N.E.S -> x.x.E.S
:1              ASL
                ASL
                ASL
                ASL                     ; E.S.0.0
                ORA #DEAD_MASK
                BNE COL_FACE_CMN        ; always

FULL_COL        JSR LOAD_MAP_DATA
                LDX BLOCK_COUNT
                STA BLOCK_BUFFER2,X

                LDY MAP_X
                EOR (MAP_PTR),Y
                AND #MAPPED_MASK!$FF
                EOR (MAP_PTR),Y         ; reinsert mapped bit
                AND #DEAD_MASK!$FF      ; clear current dead bit

COL_FACE_CMN
                ; insert previous mapped and dead masks into new data
                STA BLOCK_DATA
                LDA BLOCK_BUFFER+1,X
                ASL
                ASL
                EOR BLOCK_DATA
                AND #PREV_MAPPED_MASK+PREV_DEAD_MASK
                EOR BLOCK_DATA

                STA BLOCK_BUFFER+1,X
                INX
                CPX CLIP_RIGHT
                BEQ COLS_DONE
                STX BLOCK_COUNT

                LDA MAP_FACE
                PHA
                JSR MOVE_RIGHT
                PLA
                CMP MAP_FACE
                BEQ SAME_COL_FACE
                BNE NEW_COL_FACE        ; always

COLS_DONE       LDX CUR_CY
                CPX CLIP_TOP
                BCC ROW_DONE

                LDA CELL_Y_TABLE+0,X
                STA TOP_LINE
                LDA CELL_Y_TABLE+1,X
                STA BOTTOM_LINE
                JSR DRAW_ROW

ROW_DONE        INC CUR_CY
                LDA CUR_CY
                CMP CLIP_BOTTOM
                BEQ ROWS_DONE

                JSR PULL_MAP_STATE      ; restore left map position
                JSR SWAP_MAP_STATE      ; get center map position, put left on stack

                LDA #0
                STA NEW_VFACE
                LDA MAP_FACE
                PHA
                JSR MOVE_BACKWARD
                PLA
                CMP MAP_FACE
                BNE :NEW_ROW_FACE

:SAME_ROW_FACE  JSR SWAP_MAP_STATE      ; restore left position, put center on stack
                JSR MOVE_BACKWARD
                JMP CONT_ROW_FACE

:NEW_ROW_FACE   JSR SWAP_MAP_STATE      ; restore left position, put center on stack
                JSR PULL_MAP_STATE      ; throw away left position and get center

; only report a vertical face change if previously not filtering
; (this prevents building a horizontal edge when advancing across
;   a third face change, which is only possible with 9x9 maps)
                LDX FILTER_FACE
                BPL :1
                INC NEW_VFACE
:1              JMP NEW_ROW_FACE

ROWS_DONE       JSR PULL_MAP_STATE      ; remove left position
                JSR PULL_MAP_STATE      ; remove center position
                JSR PULL_MAP_STATE      ; restore actual map position
                RTS                     ; exit DRAW_MAP

;--------------------------------------------
;
; draw one row of map cells, possibly clipped
;
DRAW_ROW        LDA CLIP_LEFT
                TAX
                ASL
                STA DST_COL

:1              STX CUR_CX
                LDA BLOCK_BUFFER+1,X
                STA BLOCK_DATA

; choose empty or solid fill based on block mapped status
                LDA #0                  ; empty black cell
                STA FILL0_BITS
                STA FILL1_BITS
                LDA BLOCK_DATA
                AND #MAPPED_MASK+DEAD_MASK
                BNE :2
                LDA #$28                ; unmapped green cell
                STA FILL0_BITS
                LDA #$55
                STA FILL1_BITS
:2

; if current or above block is mapped, draw normal north wall segment
                LDA #0
                STA FORCE_NORTH
                LDA BLOCK_DATA
                AND #PREV_MAPPED_MASK+MAPPED_MASK
                BNE :4

; if current and above block are dead, draw open segment
                LDA BLOCK_DATA
                AND #PREV_DEAD_MASK+DEAD_MASK
                CMP #PREV_DEAD_MASK+DEAD_MASK
                BNE :3
; if previous block is unmapped but not dead, use open segment with connector
                LDY #OPEN
                LDA BLOCK_BUFFER+1-1,X
                AND #MAPPED_MASK+DEAD_MASK
                CMP #DEAD_MASK
                BNE :6                  ; with connector
                BEQ :5                  ; w/o connector
:3

; check for cases where top edge should be forced to a wall
                INC FORCE_NORTH
                LDY #WALL

; force wall if both the current block and above are unmapped
                LDA BLOCK_DATA
                AND #PREV_MAPPED_MASK+MAPPED_MASK
                BEQ :6

; get face, door, or wall hsegment directly from block data
                DEC FORCE_NORTH
:4              LDA BLOCK_DATA
                AND #NORTH_MASK
                ERR NORTH_MASK-%00110000
                LSR
                LSR
                LSR
                LSR
                TAY
                BNE :6

; check for cases where open top edge needs a connector

; use connector if previous block has non-empty north segment
                LDA BLOCK_BUFFER+1-1,X
                AND #NORTH_MASK
;               CMP #NORTH_OPEN
                BNE :6

; use connector if the current block has a non-empty west segment
                LDA BLOCK_DATA
                AND #WEST_MASK
;               CMP #WEST_OPEN
                BNE :6

; use connector if the current block is unmapped
                LDA BLOCK_DATA
                AND #MAPPED_MASK
                BEQ :6

:5              LDY #4                  ; w/o connector

:6              JSR DRAW_HSEGMENT

; stop at very bottom of screen before drawing vertical segment
                LDA TOP_LINE
                CMP #191-MAP_BOTTOM_PAD
                BEQ :9

; if current block is mapped, go pick individual vsegment type
                LDA BLOCK_DATA
                AND #MAPPED_MASK
                BNE :7

; if previous block is mapped, go pick individual vsegment type
                LDX CUR_CX
                LDA BLOCK_BUFFER+1-1,X
                AND #MAPPED_MASK
                BNE :7

; if both are dead, draw open vsegment, else draw wall
                LDY #WALL
                LDA BLOCK_DATA
                AND #DEAD_MASK
                BEQ :8
                LDA BLOCK_BUFFER+1-1,X
                AND #DEAD_MASK
                BEQ :8
                LDY #OPEN
                BEQ :8                  ; always

; get vsegment type directly from block data
:7              LDA BLOCK_DATA
                ERR WEST_MASK-%11000000
                ROL
                ROL
                ROL
                AND #3
                TAY

:8              JSR DRAW_VSEGMENT

; if top edge is not a door, skip overlap draw
:9              LDA BLOCK_DATA
                AND #NORTH_MASK
                CMP #NORTH_DOOR
                BNE :10

; if north edge was forced to wall, skip overlap draw
                LDA FORCE_NORTH
                BNE :10

                JSR DRAW_HOVERLAPS
:10
                INC DST_COL
                INC DST_COL
                LDX CUR_CX
                INX
                CPX CLIP_RIGHT
                BEQ :11
                JMP :1
:11             RTS
;
; On entry:
;   Y: hsegment index
;
DRAW_HSEGMENT   TYA
                ASL
                TAX
                LDY TOP_LINE
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY DST_COL
                LDA HSEGMENTS+0,X
                STA (SCREENL),Y
                INY
                LDA HSEGMENTS+1,X
                STA (SCREENL),Y
                RTS

DRAW_HOVERLAPS  LDX TOP_LINE
                DEX
                CPX #MAP_TOP_PAD-1
                BEQ :1
                JSR :OVERLAP
:1              INX
                CPX #191-MAP_BOTTOM_PAD
                BEQ :2
                INX
:OVERLAP        LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY DST_COL
                LDA (SCREENL),Y
                ORA #$60
                STA (SCREENL),Y
                INY
                LDA (SCREENL),Y
                ORA #$1F
                STA (SCREENL),Y
:2              RTS

HSEGMENTS       DB  $02,$00             ; open w/connector
                DB  $12,$22             ; face (purple)
;               DB  $22,$10             ; face (green)
                DB  $6A,$5F             ; door
                DB  $2A,$55             ; wall
                DB  $00,$00             ; open w/o connector
;
; On entry:
;   Y: vsegment index
;
DRAW_VSEGMENT   LDA VOFFSETS,Y
                STA OFFSET
                LDY DST_COL
                LDX TOP_LINE
                INX
:1              STX DST_LINE
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDX OFFSET
                LDA VSEGMENTS,X
                ORA FILL0_BITS
                STA (SCREENL),Y
                INY
                LDA FILL1_BITS
                STA (SCREENL),Y
                DEY
                INC OFFSET
                LDX DST_LINE
                INX
                CPX BOTTOM_LINE
                BNE :1
                RTS

VOFFSETS        DB  CELL_HEIGHT-1*0     ; open
                DB  CELL_HEIGHT-1*1     ; face
                DB  CELL_HEIGHT-1*2     ; door
                DB  CELL_HEIGHT-1*3     ; wall

VSEGMENTS       DS  CELL_HEIGHT-1,$00   ; open

                DB  $00                 ; face
                DB  $04,$00
                DB  $00,$00
                DB  $04,$00
                DB  $00,$00
                DB  $04,$00
                DB  $00

                DB  $02,$02             ; door
                DB  $07,$07
                DB  $07,$07
                DB  $07,$07
                DB  $07,$07
                DB  $02,$02

                DS  CELL_HEIGHT-1,$02   ; wall

; TODO: if this changes, consider making cell calls private again
DRAW_LOCATION   LDA LOC_CX
                ASL
                STA XCOORD
                LDA #0
                STA XSHIFT
                LDX LOC_CY
                LDA CELL_Y_TABLE,X
;               CLC
                ADC #4
                STA YCOORD
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

; TODO: generalize/share these
ARROW_SHAPES    DB  $00,$00,$00,$40,$60,$70,$00     ; up arrow
                DB  $00,$02,$07,$0F,$1F,$3F,$00

                DB  $60,$60,$60,$60,$60,$60,$60     ; right arrow
                DB  $00,$03,$0F,$3F,$0F,$03,$00

                DB  $00,$70,$60,$40,$00,$00,$00     ; down arrow
                DB  $00,$3F,$1F,$0F,$07,$02,$00

                DB  $00,$00,$40,$70,$40,$00,$00     ; left arrow
                DB  $18,$1E,$1F,$1F,$1F,$1E,$18

CELL_Y_TABLE    DB  CELL_HEIGHT*0+MAP_TOP_PAD
                DB  CELL_HEIGHT*1+MAP_TOP_PAD
                DB  CELL_HEIGHT*2+MAP_TOP_PAD
                DB  CELL_HEIGHT*3+MAP_TOP_PAD
                DB  CELL_HEIGHT*4+MAP_TOP_PAD
                DB  CELL_HEIGHT*5+MAP_TOP_PAD
                DB  CELL_HEIGHT*6+MAP_TOP_PAD
                DB  CELL_HEIGHT*7+MAP_TOP_PAD
                DB  CELL_HEIGHT*8+MAP_TOP_PAD
                DB  CELL_HEIGHT*9+MAP_TOP_PAD
                DB  CELL_HEIGHT*10+MAP_TOP_PAD
                DB  CELL_HEIGHT*11+MAP_TOP_PAD
                DB  CELL_HEIGHT*12+MAP_TOP_PAD
                DB  CELL_HEIGHT*13+MAP_TOP_PAD
                DB  CELL_HEIGHT*14+MAP_TOP_PAD
                DB  CELL_HEIGHT*15+MAP_TOP_PAD
                ERR MAP_HEIGHT_CELLS-15

RESET_CLIP      LDA #0
                STA CLIP_TOP
                STA CLIP_LEFT
                LDA #MAP_HEIGHT_CELLS
                STA CLIP_BOTTOM
                LDA #MAP_WIDTH_CELLS
                STA CLIP_RIGHT
                RTS

MAP_MOVE_LEFT   LDA LOC_CX
                BEQ :3
                DEC LOC_CX

                JSR SET_PAGEX

                ; copy scroll the map left
                LDX #MAP_TOP_PAD-1
:1              JSR SET_DEST_LINE
                LDY DESTINL
                INY
                INY
                STY SCREENL
                LDA DESTINH
                EOR #$60
                STA SCREENH
                LDY #37
:2              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :2
                SAME_PAGE_AS :2
                INX
                CPX #192-MAP_BOTTOM_PAD
                BNE :1

                JSR RESET_CLIP
                LDA #MAP_WIDTH_CELLS-1
                STA CLIP_LEFT
                JSR DRAW_MAP

                JSR SHOW_PAGE
:3              RTS

MAP_MOVE_RIGHT  LDX LOC_CX
                INX
                CPX #MAP_WIDTH_CELLS
                BEQ :4
                STX LOC_CX

                JSR SET_PAGEX

                ; copy scroll the map right
                LDX #MAP_TOP_PAD-1
:1              JSR SET_SOURCE_OFF
                LDY SCREENL
                INY
                INY
                STY DESTINL
                LDA SCREENH
                EOR #$60
                STA DESTINH
                LDY #37
:2              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :2
                SAME_PAGE_AS :2
                INX
                CPX #192-MAP_BOTTOM_PAD
                BNE :1

                JSR RESET_CLIP
                LDA #1+1                ; +1 to clean up connectors
                STA CLIP_RIGHT
                JSR DRAW_MAP

                ; redraw location marker if in the first column
                LDA LOC_CX
                CMP #2
                BCS :3
                JSR DRAW_LOCATION
:3
                JSR SHOW_PAGE
:4              RTS

MAP_MOVE_UP     LDA LOC_CY
                BEQ :4
                DEC LOC_CY

                JSR SET_PAGEX

                ; copy scroll the map up
                LDA #MAP_TOP_PAD+CELL_HEIGHT
                STA SRC_LINE
                LDX #MAP_TOP_PAD
:3              STX DST_LINE
                JSR SET_DEST_LINE
                LDX SRC_LINE
                JSR SET_SOURCE_OFF
                JSR COPY_FULL_LINE
                INC SRC_LINE
                LDX DST_LINE
                INX
                CPX #192-CELL_HEIGHT-MAP_BOTTOM_PAD
                BNE :3

                JSR RESET_CLIP
                LDA #MAP_HEIGHT_CELLS-2
                STA CLIP_TOP
                JSR DRAW_MAP

                JSR SHOW_PAGE
:4              RTS

MAP_MOVE_DOWN   LDX LOC_CY
                INX
                CPX #MAP_HEIGHT_CELLS-1
                BEQ :2
                STX LOC_CY

                JSR SET_PAGEX

                ; draw the new map row first
                JSR RESET_CLIP
                LDA #1+1                ; +1 to clean up door overlap
                STA CLIP_BOTTOM
                JSR DRAW_MAP

                ; copy scroll the map down
                LDA #191-CELL_HEIGHT-MAP_BOTTOM_PAD
                STA SRC_LINE
                LDX #191-MAP_BOTTOM_PAD
:1              STX DST_LINE
                JSR SET_DEST_LINE
                LDX SRC_LINE
                JSR SET_SOURCE_OFF
                JSR COPY_FULL_LINE
                DEC SRC_LINE
                LDX DST_LINE
                DEX
                CPX #MAP_TOP_PAD+CELL_HEIGHT-1
                BNE :1

                JSR SHOW_PAGE
:2              RTS
