
NameBoxTopY     =   11+3

MaxNameListCount =  12                  ; max window height in names
NameListMidIndex =  5
NameListTopY     =  NameBoxTopY+8       ; in lines
NameListBottomY  =  MaxNameListCount*9+NameListTopY-1
NameListLeftX    =  15

NameBoxBottomY  =   NameListBottomY+6

ImageCornerWidth  = 23
ImageCornerLeft   = 40-ImageCornerWidth
ImageCornerTop    = 1
ImageCornerHeight = 150

; TODO: use DUMMY after code
NAME_BUFFER     =   $8000
DESC_BUFFER     =   $8500
OFFSET_BUFFER   =   $8700
ALIEN_COUNT     =   $8700
OFFSET_TABLE    =   $8701
KNOWN_LIST      =   $8800
DATA_TABLE      =   $8900

KNOWN_INDEX     =   $C0
KNOWN_COUNT     =   $C1
ALIEN_SET       =   $C2

state_missing   =   0                   ; assumed to be zero
state_empty     =   1
state_drawn     =   2
state_overflow  =   3

ALIEN_STATE     =   $C3
DESC_STATE      =   $C4

; TODO: share with common?
PPIC            =   $C5
PPIC_H          =   $C6

DESC_BASE       =   $C7
WINDOW_TOP_ALIEN =  $C8                 ; alien index
WINDOW_HEIGHT   =   $C9                 ; <= MaxNameListCount
CURSOR_LINE     =   $CA                 ; index from 0 to WINDOW_HEIGHT-1
INDEX           =   $CB
ARROWS_VISIBLE  =   $CC

; used by LOAD_DESC and LOAD_ALIEN
OFFSET_L        =   $CD
OFFSET_H        =   $CE
BYTE_COUNT      =   $CF

AlienBase12TS   =   $000
AlienBase345TS  =   $0B0

AlienDesc12TS   =   $170
AlienDesc345TS  =   $180

                DUMMY SCRATCH_PAGE
ALIGNMENT       DS  72
                DEND

; TODO: Use typing to fast-scroll to alien? (just first letter? ignore quote)
; - page up and page down?
; - alphabetize names?
; - maybe pre-alphabetize?
; - loop list around?
; - show x/n count
; - vertically center description text

ALIEN_ID_MOD    DB  modAlienId

IDENTIFIED_ALIENS
                LDA #1
                STA ALIEN_SET

                LDA #$FF
                STA DESC_BASE

                LDA #state_missing
                STA DESC_STATE
                LDA #state_overflow
                STA ALIEN_STATE

                JSR LOAD_NAMES
                ;*** leave drive spinning ***

                JSR LOAD_OFFSETS
                ;*** leave drive spinning ***

                JSR BUILD_KNOWN_LIST

                LDA KNOWN_COUNT
                BNE :1
                JMP NO_KNOWN

:1              LDA #0
                STA WINDOW_TOP_ALIEN
                STA KNOWN_INDEX

                ; adjust offset and height when KNOWN_COUNT < max window height
                LDX #0
                LDY #MaxNameListCount
                CPY KNOWN_COUNT
                BCC :2
                LDY KNOWN_COUNT
:2              STX CURSOR_LINE
                STY WINDOW_HEIGHT

                LDX #$01+1
                LDA #$0F+1          ;***
                JSR SET_LINE_BOUNDS

AMAIN_LOOP      LDX ALIEN_STATE
;               CPX #state_missing
                BEQ :2
                CPX #state_drawn
                BEQ :1
                JSR COMPOSITE_EMPTY
                JMP :2

:1              JSR CLEAR_ALIEN
:2              LDA #state_missing
                STA ALIEN_STATE

                LDX DESC_STATE
                CPX #state_drawn
                BNE :4
                LDX #state_empty
                STX DESC_STATE
                JSR CLEAR_DESC
:4
                ;*** DO DRIVE SPIN-UP SEPARATELY AND ABORTABLY ***

                JSR LOAD_ALIEN
                BCS AKEY_LOOP

                JSR POSITION_ALIEN

                LDX #state_drawn
                LDA ALIEN_BOTTOM
                CMP #151
                BCS :5
                LDA ALIEN_LEFT
                CMP #ImageCornerLeft
                BCS :6
:5              LDX #state_overflow
:6              STX ALIEN_STATE
                CPX #state_overflow
                BNE :NO_OVERFLOW

                JSR COMPOSITE_ALIEN
                ;*** CHECK FOR ABORT?
                JMP :7

:NO_OVERFLOW
;*** draw offscreen even when compositing not required ***
                JSR DRAW_ALIEN
                JSR SHOULD_ABORT
                BCS AKEY_LOOP
:7
                JSR DRAW_DESC
                LDX #state_drawn
                STX DESC_STATE

;*** reuse input from abort check ***
AKEY_LOOP       LDA KEYBRD
                BPL AKEY_LOOP
                BIT UNSTROB

                JSR CHECK_UP
                BNE :1

                JSR ON_UP
                BCC AKEY_LOOP
                JMP AMAIN_LOOP

:1              JSR CHECK_DOWN
                BNE :2

                JSR ON_DOWN
                BCC AKEY_LOOP
                JMP AMAIN_LOOP

:2              JSR CHECK_ENTER
                BNE :3
                JSR ON_FULLSCREEN
                JMP AKEY_LOOP

:3              JSR CHECK_CANCEL
                BNE AKEY_LOOP
                ;*** return to main camp screen
                RTS

NO_KNOWN        JSR COMPOSITE_EMPTY
; TODO: make this GET_CANCEL in UTILS.S?
                BIT UNSTROB
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB
                JSR CHECK_CANCEL
                BNE :1
                RTS

ON_FULLSCREEN   JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictEnd

                JSR DRAW_HALL

                LDX PPIC
                LDY PPIC_H
                JSR UNPACK

                JSR DRAW_PICT
                PictShowPage
                PictEnd

                BIT UNSTROB
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB

                JSR DRAW_PICT
                PictSetPage1
                PictShowPage
                PictEnd
                RTS

ON_UP
                LDA PBUTTON0            ; open-apple
                BMI :PAGE_UP

                LDX CURSOR_LINE
                DEX
                BMI :1
                CPX #NameListMidIndex
                BCS :2

                LDA WINDOW_TOP_ALIEN
                BEQ :2
                DEC WINDOW_TOP_ALIEN
                JSR SCROLL_NAMES_DOWN
                JSR UPDATE_ARROWS

                JSR DRAW_PICT
                PictClear $01+1;NameListTopY;$0F+1;NameListTopY+9
                PictEnd

                LDX #0
                JSR DRAW_ALIEN_NAME
                JMP :3

:1              CLC
                RTS

:2              TXA
                PHA
                JSR DRAW_NAME_CURSOR
                PLA
                STA CURSOR_LINE
                JSR DRAW_NAME_CURSOR

:3              DEC KNOWN_INDEX
                SEC
                RTS

:PAGE_UP        CLC
                RTS

ON_DOWN
                LDA PBUTTON0            ; open-apple
                BMI :PAGE_DOWN

                LDX CURSOR_LINE
                INX
                CPX #NameListMidIndex+1
                BCC :1

                LDA WINDOW_TOP_ALIEN
                CLC
                ADC WINDOW_HEIGHT
                CMP KNOWN_COUNT
                BCS :1
                INC WINDOW_TOP_ALIEN
                JSR SCROLL_NAMES_UP
                JSR UPDATE_ARROWS

                JSR DRAW_PICT
                PictClear $01+1;NameListBottomY-9;$0F+1;NameListBottomY
                PictEnd

                LDX WINDOW_HEIGHT
                DEX
                JSR DRAW_ALIEN_NAME
                JMP :3

:1              CPX WINDOW_HEIGHT
                BNE :2
                CLC
                RTS

:2              TXA
                PHA
                JSR DRAW_NAME_CURSOR
                PLA
                STA CURSOR_LINE
                JSR DRAW_NAME_CURSOR
:3              INC KNOWN_INDEX
                SEC
                RTS

:PAGE_DOWN      CLC
                RTS

COMPOSITE_EMPTY JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictEnd
                JMP COMPOSITE_CMN

COMPOSITE_ALIEN JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictEnd

                JSR DRAW_ALIEN
                ;*** abort?

                JSR DRAW_PICT
                PictClear 0;0;17;151
                PictClear 0;151;40;192
                PictEnd
                ; fall through

COMPOSITE_CMN   JSR DRAW_PICT
                PictTextAt 9;4;(IDENTIFIED_ALIENS)
                PictSetGreen
                PictRect 3;0;115;149
                PictRect 3;152;277;191
                PictEnd

                LDA KNOWN_COUNT
                BEQ :1

                JSR DRAW_PICT
                PictTextAt 6;140;(FULLSCREEN_<SPACE>)
                PictEnd

                JSR DRAW_ALIEN_NAMES
                ;*** abort?

                LDA #0
                STA ARROWS_VISIBLE
                JSR UPDATE_ARROWS

                JSR DRAW_NAME_CURSOR
                JMP :2

:1              JSR DRAW_PICT
                PictTextAt 34;73;(NONE_YET)
                PictTextAt 37;82;(C>ANCEL)
                PictEnd

:2              JSR DRAW_PICT
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                LDA #state_empty
                STA DESC_STATE
                RTS

SCROLL_NAMES_UP LDX #NameListTopY
:1              JSR SET_DEST_LINE
                LDA LOBYTES+9,X
                STA SCREENL
                LDA HIBYTES+9,X
                STA SCREENH
                ; TODO: SetSourceLine +9
                JSR COPY_LINE
                INX
                CPX #NameListBottomY-9
                BNE :1
                RTS

SCROLL_NAMES_DOWN
                LDX #NameListBottomY-1
:1              JSR SET_DEST_LINE
                LDA LOBYTES-9,X
                STA SCREENL
                LDA HIBYTES-9,X
                STA SCREENH
                ; TODO: SetSourceLine -9
                JSR COPY_LINE
                DEX
                CPX #NameListTopY+8
                BNE :1
                RTS

UPDATE_ARROWS   LDX #0
                LDA WINDOW_TOP_ALIEN
                BEQ :1
                INX
:1              CLC
                ADC WINDOW_HEIGHT
                CMP KNOWN_COUNT
                BCS :2
                INX
                INX
:2              TXA
                EOR ARROWS_VISIBLE
                STX ARROWS_VISIBLE
                LSR
                BCC :3
                PHA
                JSR DRAW_UP_ARROW
                PLA
:3              LSR
                BCC :4
                JSR DRAW_DOWN_ARROW
:4              RTS

DRAW_UP_ARROW   JSR DRAW_PICT
                PictMoveTo 16;NameBoxTopY+2
                PictEnd
                LDX #<UP_ARROW
                LDY #>UP_ARROW
                JMP DRAW_TILE

DRAW_DOWN_ARROW JSR DRAW_PICT
                PictMoveTo 16;NameBoxBottomY-5
                PictEnd
                LDX #<DOWN_ARROW
                LDY #>DOWN_ARROW
                JMP DRAW_TILE

UP_ARROW        DB  %00001000
                DB  %00011100
                DB  %00111110
                DB  %01111111
                DB  %00000000
                DB  %00000000
                DB  %00000000

DOWN_ARROW      DB  %01111111
                DB  %00111110
                DB  %00011100
                DB  %00001000
                DB  %00000000
                DB  %00000000
                DB  %00000000
;
; On exit:
;   A: unchanged
;   X: unchanged
;   Y: unchanged
;   C: 1 when abort should happen
;
;*** check for page up/down ***
;*** capture input and use in input loop ***
SHOULD_ABORT    PHA
                LDA KEYBRD
                BPL :NO_ABORT
                JSR CHECK_CANCEL
                BEQ :ABORT
                JSR CHECK_UP
                BNE :1
                LDA KNOWN_INDEX
                BNE :ABORT
:NO_ABORT       CLC
                PLA
                RTS
:1              JSR CHECK_DOWN
                BNE :NO_ABORT
                LDA KNOWN_INDEX
                CLC
                ADC #1
                CMP KNOWN_COUNT
                BEQ :NO_ABORT
:ABORT          SEC
                PLA
                RTS

LOAD_NAMES      LDY #>NAME_BUFFER
; TODO: could be dropped to 4 if one name is removed from ALIEN.DESC.12
                LDA #5                  ; 5 sectors
                JSR SET_LOAD_ADDR
                LDX #<AlienDesc12TS
                LDY #>AlienDesc12TS
                LDA ALIEN_SET
                BEQ :1
                LDX #<AlienDesc345TS
                LDY #>AlienDesc345TS
:1              JSR LOAD_DATA           ; spin up/down

                LDX NAME_BUFFER+0
                INX                     ; skip DATA_END_xx offset
                TXA
                ASL
                SEC                     ; skip count byte
                ADC #<NAME_BUFFER
                STA NAMES_MODA+1
                LDA #>NAME_BUFFER
                ADC #0
                STA NAMES_MODB+1
                RTS
;
; On entry:
;   A: alien index
;
GET_ALIEN_NAME
NAMES_MODA      LDX #$FF
NAMES_MODB      LDY #$FF
                JMP GET_IND_STRING

LOAD_OFFSETS    LDY #>OFFSET_BUFFER
                LDA #1                  ; one sector
                JSR SET_LOAD_ADDR
                LDX #<AlienBase12TS
                LDY #>AlienBase12TS
                LDA ALIEN_SET
                BEQ :1
                LDX #<AlienBase345TS
                LDY #>AlienBase345TS
:1              JMP LOAD_DATA           ; spin up/down

BUILD_KNOWN_LIST
                LDX #KNOWN_ALIENS_12-KNOWN_ALIENS_12
                LDA #KNOWN_ALIENS_345-KNOWN_ALIENS_12
                LDY ALIEN_SET
                BEQ :1
                LDX #KNOWN_ALIENS_345-KNOWN_ALIENS_12
                LDA #KNOWN_ALIENS_END-KNOWN_ALIENS_12
:1              STA :MOD+1
                LDA #0
                STA KNOWN_COUNT
                TAY
:2              DEY
                LDA KNOWN_ALIENS_12,X
                SEC
:3              INY
                ROL
                BCC :3
                BEQ :4
                PHA
                STX INDEX
                TYA
                LDX KNOWN_COUNT
                STA KNOWN_LIST,X
                INC KNOWN_COUNT
                LDX INDEX
                PLA
                CLC
                BCC :3                  ; always
:4              INX
:MOD            CPX #$FF
                BNE :2
                RTS

CLEAR_DESC      JSR DRAW_PICT
                PictClear $01;155;$27;191
                PictEnd
                RTS

LOAD_DESC       LDX KNOWN_INDEX
                LDA KNOWN_LIST,X
                ASL
                TAY
                LDA NAME_BUFFER+1,Y
                STA OFFSET_L
                LDA NAME_BUFFER+2,Y
                STA OFFSET_H
                LDA NAME_BUFFER+3,Y
                SEC
                SBC OFFSET_L
                STA BYTE_COUNT

                LDA OFFSET_H
                SEC
                SBC DESC_BASE
                BEQ :NO_LOAD
                TAX
                BCC :SHIFT_DOWN
                DEX
                BNE :COPY2

                ; shift down and load into top half
                LDX #0
:1              LDA DESC_BUFFER+$100,X
                STA DESC_BUFFER,X
                INX
                BNE :1
                LDY #>DESC_BUFFER+$100
                LDA #1                  ; one sector
                JSR SET_LOAD_ADDR
                INC DESC_BASE
                SEC
                BNE :COMMON             ; always

                ; shift up and load into bottom half
:SHIFT_DOWN     INX
                BNE :COPY2
                LDX #0
:2              LDA DESC_BUFFER,X
                STA DESC_BUFFER+$100,X
                INX
                BNE :2
                LDY #>DESC_BUFFER
                LDA #1                  ; one sector
                JSR SET_LOAD_ADDR
                DEC DESC_BASE
                CLC
                BNE :COMMON             ; always

                ; fill desc buffer with two sectors
:COPY2          LDY #>DESC_BUFFER
                LDA #2                  ; two sectors
                JSR SET_LOAD_ADDR
                LDA OFFSET_H
                STA DESC_BASE
                CLC

:COMMON         LDX #<AlienDesc12TS
                LDY #>AlienDesc12TS
                LDA ALIEN_SET
                BEQ :3
                LDX #<AlienDesc345TS
                LDY #>AlienDesc345TS
:3              TXA
                ; carry clear/set above
                ADC DESC_BASE
                TAX
                BCC :4
                INY
:4              JSR LOAD_DATA           ; spin up/down for now

:NO_LOAD        LDA OFFSET_H
                SEC
                SBC DESC_BASE
                CLC
                ADC #>DESC_BUFFER
                STA OFFSET_H

                LDY #0
:5              LDA (OFFSET_L),Y
                STA TEXT_BUFFER,Y
                INY
                CPY BYTE_COUNT
                BNE :5

                LDA #TextLineEnd
                STA TEXT_BUFFER,Y
                RTS

DRAW_DESC       JSR DRAW_PICT
                PictSetPage2
                PictClear $01;153;$27;191
                PictSetTextBox 7;155;277;191

                ; PictTextIn (THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)
                ; PictTextIn (_THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)
                ; PictTextIn (_THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)

                PictEnd
                JSR LOAD_DESC
                JSR WRAP_TEXTBUF

                JSR DRAW_PICT
                PictSetPage1
                PictCopyTo 1;155;39;190
                PictEnd
                RTS

CLEAR_ALIEN     LDA ALIEN_LEFT
                CMP ALIEN_RIGHT
                BNE :1
                RTS
:1              JSR DRAW_PICT
                DB  OpClear
ALIEN_LEFT      DB  $00
ALIEN_TOP       DB  $00
ALIEN_RIGHT     DB  $00
ALIEN_BOTTOM    DB  $00
                PictEnd
                RTS

START_OFFSET_H  =   BYTE_COUNT
END_OFFSET_L    =   OFFSET_L
END_OFFSET_H    =   OFFSET_H

LOAD_ALIEN      LDX KNOWN_INDEX
                LDA KNOWN_LIST,X
                ASL
                TAX
                LDA OFFSET_TABLE+0,X
                STA POSITION_ALIEN+1    ; START_OFFSET_L
                LDA OFFSET_TABLE+1,X
                STA START_OFFSET_H

                LDA OFFSET_TABLE+2,X
                STA END_OFFSET_L
                LDA OFFSET_TABLE+3,X
                STA END_OFFSET_H

                LDX END_OFFSET_H
                LDA END_OFFSET_L
                BEQ :2
                INX
:2              TXA
                SEC
                SBC START_OFFSET_H
                LDY #>DATA_TABLE
                JSR SET_LOAD_ADDR

                LDA #<AlienBase12TS
                LDY #>AlienBase12TS
                LDX ALIEN_SET
                BEQ :3
                LDA #<AlienBase345TS
                LDY #>AlienBase345TS
:3              CLC
                ADC START_OFFSET_H
                TAX
                BCC :4
                INY
:4              JSR LOAD_DATA           ; spin up/down

                ; stuff #$FF at end of compressed data
                LDA END_OFFSET_H
                SEC
                SBC START_OFFSET_H
                CLC
                ADC #>DATA_TABLE
                STA :MOD+2
                LDX END_OFFSET_L
                LDA #$FF
:MOD            STA DATA_TABLE,X

                ;*** ONCE PER SECTOR ***
                JMP SHOULD_ABORT

POSITION_ALIEN  LDA #$FF                ; START_OFFSET_L
                STA PPIC
                LDA #>DATA_TABLE
                STA PPIC_H

                LDY #2
                LDX KNOWN_INDEX
                LDA ALIGNMENT,X
                BEQ :0
                BPL :00

                ; align left in window
                LDX #ImageCornerLeft
                BNE :2                  ; always

                ; align right in window
:00             LDA #40
                SEC
                SBC (PPIC),Y
                TAX
                BNE :2                  ; always

                ; center in window
:0              LDY #0
                LDA (PPIC),Y
                AND #$01
                STA XCOORD
                INY
                INY
                LDA #ImageCornerWidth
                SEC
                SBC (PPIC),Y
                BCC :1
                LSR
                CLC
                ADC #ImageCornerLeft
                TAX
                EOR XCOORD
                AND #1
                BEQ :2
                INX
                BNE :2                  ; always

:1          ;   CLC
                ADC #ImageCornerLeft
                TAX
                EOR XCOORD
                AND #1
                BEQ :2
                DEX
:2              TXA
                CLC
                ADC (PPIC),Y
                STA ALIEN_RIGHT
                STX XCOORD
                STX ALIEN_LEFT
                LDA #0
                STA XSHIFT
                INY

                LDA #ImageCornerHeight
                SEC
                SBC (PPIC),Y
                BCC :3
                LSR
                CLC
:3              ADC #ImageCornerTop
                BPL :4
                ;**** fix so thrower is at top but not all others ***
                LDA #ImageCornerTop-1   ; special case full height (THROWER)
:4              STA YCOORD
                STA ALIEN_TOP
                CLC
                ADC (PPIC),Y
                STA ALIEN_BOTTOM
                RTS

DRAW_ALIEN      LDX PPIC
                LDY PPIC_H
                JSR UNPACK_TO
                ;*** CHECK FOR CHAINING ***
                RTS

DRAW_NAME_CURSOR
                LDX CURSOR_LINE
                LDY ALIEN_NAME_LINES,X
                LDX #1+7
                JMP DRAW_TRIANGLE

DRAW_ALIEN_NAMES
                LDX #0
:1              STX INDEX
                JSR DRAW_ALIEN_NAME
                LDX INDEX
                INX
                CPX WINDOW_HEIGHT
                BNE :1
                RTS
;
; On entry:
;   X: cursor index
;
DRAW_ALIEN_NAME TXA
                PHA
                CLC
                ADC WINDOW_TOP_ALIEN
                PHA
                JSR GET_ALIEN_NAME
                PLA
                TAX
                LDY #-1
                LDA TEXT_BUFFER+0
                CMP #TextLT
                BEQ :1
                INY
                INY
                CMP #TextGT
                BEQ :1
                DEY
                BEQ :2                  ; always
:1              LDA #TextEmpty
                STA TEXT_BUFFER+0
:2              TYA
                STA ALIGNMENT,X
                PLA
                TAX
                LDY ALIEN_NAME_LINES,X
                LDX #NameListLeftX
                JMP DRAW_TEXTBUF_XY

ALIEN_NAME_LINES
                DB  0*9+NameListTopY
                DB  1*9+NameListTopY
                DB  2*9+NameListTopY
                DB  3*9+NameListTopY
                DB  4*9+NameListTopY
                DB  5*9+NameListTopY
                DB  6*9+NameListTopY
                DB  7*9+NameListTopY
                DB  8*9+NameListTopY
                DB  9*9+NameListTopY
                DB  10*9+NameListTopY
                DB  11*9+NameListTopY
                ERR 12-MaxNameListCount
