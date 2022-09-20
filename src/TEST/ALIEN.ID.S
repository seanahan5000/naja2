
NameBoxTopY     =   11

MaxNameListCount =  13                  ; max window height in names
NameListMidIndex =  MaxNameListCount/2
NameListTopY     =  NameBoxTopY+8       ; in lines
NameListBottomY  =  MaxNameListCount*9+NameListTopY-1

NameBoxBottomY  =   NameListBottomY+6

ImageCornerWidth  = 22
ImageCornerLeft   = 40-ImageCornerWidth
ImageCornerTop    = 1
ImageCornerHeight = 153

STRACK          =   $B1
SSTOREH         =   $B2
DISK_SIDE       =   $B3

; TODO: switch to ENT-derived symbols
READ_VECTOR     =   $0406
ON_OFF_FLAG     =   $07F8

NAME_BUFFER     =   $A000
DESC_BUFFER     =   $A500
OFFSET_BUFFER   =   $A700
ALIEN_COUNT     =   $A700
OFFSET_TABLE    =   $A701
KNOWN_LIST      =   $A800
DATA_TABLE      =   $A900

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
; $C8
; $C9
; $CA
WINDOW_TOP_ALIEN =  $CB                 ; alien index
WINDOW_HEIGHT   =   $CC                 ; <= MaxNameListCount
CURSOR_LINE     =   $CD                 ; index from 0 to WINDOW_HEIGHT-1
INDEX           =   $CE
ARROWS_VISIBLE  =   $CF

ALIEN_BASE_12   =   $0000
ALIEN_BASE_345  =   $0100

ALIEN_DESC_12   =   $0200
ALIEN_DESC_345  =   $0210

; TODO: Use typing to fast-scroll to alien? (just first letter? ignore quote)
; - page up and page down?
; - alphabetize names?
; - maybe pre-alphabetize?
; - loop list around?

IDENTIFIED_ALIENS
                LDA #0
                STA ALIEN_SET

                ; TODO: eventually not needed
                LDA #$00
                STA DISK_SIDE

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

ON_UP           LDX CURSOR_LINE
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

ON_DOWN         LDX CURSOR_LINE
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
                PictClear 0;0;17;NameBoxBottomY+12
                PictClear 0;153;40;192
                PictEnd
                ; fall through

COMPOSITE_CMN   JSR DRAW_PICT
                PictTextAt 10;NameBoxTopY-9;(IDENTIFIED_ALIENS)
                PictSetViolet
                PictRect 4;NameBoxTopY;116;NameBoxBottomY
                PictSetGreen
                PictRect 3;154;277;191
                PictEnd

                LDA KNOWN_COUNT
                BEQ :1

                JSR DRAW_PICT
                PictTextAt 4;NameBoxBottomY+3;(FULL_SCREEN_<SPACE>)
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

LOAD_NAMES      LDA #>NAME_BUFFER
                STA SSTOREH
                LDA #%00000000          ; spin up/down
                STA ON_OFF_FLAG
                LDX #<ALIEN_DESC_12
                LDY #>ALIEN_DESC_12
                LDA ALIEN_SET
                BEQ :1
                LDX #<ALIEN_DESC_345
                LDY #>ALIEN_DESC_345
:1              LDA #5                  ; 5 sectors
; TODO: could be dropped to 4 if one name is removed from ALIEN.DESC.12
                JSR READ_VECTOR

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

LOAD_OFFSETS    LDA #>OFFSET_BUFFER
                STA SSTOREH
                LDA #%00000000          ; spin up/down
                STA ON_OFF_FLAG
                LDX #<ALIEN_BASE_12
                LDY #>ALIEN_BASE_12
                LDA ALIEN_SET
                BEQ :1
                LDX #<ALIEN_BASE_345
                LDY #>ALIEN_BASE_345
:1              LDA #1                  ; one sector
                JMP READ_VECTOR

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

OFFSET_L        =   LOCAL_TEMP+0
OFFSET_H        =   LOCAL_TEMP+1
BYTE_COUNT      =   LOCAL_TEMP+2

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
                LDA #>DESC_BUFFER+$100
                STA SSTOREH
                INC DESC_BASE
                SEC
                LDA #1                  ; one sector
                BNE :COMMON             ; always

                ; shift up and load into bottom half
:SHIFT_DOWN     INX
                BNE :COPY2
                LDX #0
:2              LDA DESC_BUFFER,X
                STA DESC_BUFFER+$100,X
                INX
                BNE :2
                LDA #>DESC_BUFFER
                STA SSTOREH
                DEC DESC_BASE
                CLC
                LDA #1                  ; one sector
                BNE :COMMON             ; always

                ; fill desc buffer with two sectors
:COPY2          LDA #>DESC_BUFFER
                STA SSTOREH
                LDA OFFSET_H
                STA DESC_BASE
                CLC
                LDA #2                  ; two sectors

:COMMON         PHA
                LDX #<ALIEN_DESC_12
                LDY #>ALIEN_DESC_12
                LDA ALIEN_SET
                BEQ :3
                LDX #<ALIEN_DESC_345
                LDY #>ALIEN_DESC_345
:3              TXA
                ; carry clear/set above
                ADC DESC_BASE
                TAX
                BCC :4
                INY
:4              PLA
                JSR READ_VECTOR

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
                PictClear $01;155;$27;191
                PictSetTextBox 7;156;277;191
                PictEnd
                JSR LOAD_DESC
                JSR WRAP_TEXTBUF

                ; PictTextIn (THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)
                ; PictTextIn (_THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)
                ; PictTextIn (_THIS_IS_A_TEST_OF_THE_EMERGENCY_BROADCAST_SYSTEM._THIS_IS_ONLY_A_TEST.)

                JSR DRAW_PICT
                PictSetPage1
                PictCopyTo 1;156;39;190
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

START_OFFSET_H  =   LOCAL_TEMP+0
END_OFFSET_L    =   LOCAL_TEMP+1
END_OFFSET_H    =   LOCAL_TEMP+2

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

                LDA #>DATA_TABLE
                STA SSTOREH
                LDA #%00000000          ; spin up/down
                STA ON_OFF_FLAG

                LDX END_OFFSET_H
                LDA END_OFFSET_L
                BEQ :2
                INX
:2              TXA
                SEC
                SBC START_OFFSET_H
                PHA                     ; SECTOR COUNT

                LDY #>ALIEN_BASE_12     ; T/S base high
                LDA #<ALIEN_BASE_12     ; T/S base low
                LDX ALIEN_SET
                BEQ :3
                LDY #>ALIEN_BASE_345    ; T/S base high
                LDA #<ALIEN_BASE_345    ; T/S base low
:3              CLC
                ADC START_OFFSET_H
                TAX
                BCC :4
                INY
:4              PLA
                JSR READ_VECTOR
                ;*** ONCE PER SECTOR ***
                JMP SHOULD_ABORT

POSITION_ALIEN  LDA #$FF                ; START_OFFSET_L
                STA PPIC
                LDA #>DATA_TABLE
                STA PPIC_H

                LDY #0
                LDA (PPIC),Y
                AND #$01
                STA XCOORD
                INY
                INY
                LDA #ImageCornerWidth
                SEC
                SBC (PPIC),Y
                BCC :1
                ADC #0
                LSR A
                CLC
:1              ADC #ImageCornerLeft
                BPL :2
                LDA #0               ; special case full width (THROWER)
:2              AND #$FE
                ORA XCOORD
                TAX
                CLC
                ADC (PPIC),Y
                STA ALIEN_RIGHT
                CMP #41
                BCC :22
                DEX
                DEX
                DEC ALIEN_RIGHT
                DEC ALIEN_RIGHT
:22             STX XCOORD
                STX ALIEN_LEFT
                LDA #0
                STA XSHIFT
                INY

                LDA #ImageCornerHeight
                SEC
                SBC (PPIC),Y
                BCC :3
                LSR A
                CLC
:3              ADC #ImageCornerTop
                BPL :4
                LDA #ImageCornerTop     ; special case full height (THROWER)
:4              STA YCOORD
                STA ALIEN_TOP
                CLC
                ADC (PPIC),Y
                STA ALIEN_BOTTOM
                RTS

DRAW_ALIEN      LDX PPIC
                LDY PPIC_H
                JMP UNPACK_TO

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
                JSR GET_ALIEN_NAME

                PLA
                TAX
                LDY ALIEN_NAME_LINES,X
                LDX #9+7
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
                DB  12*9+NameListTopY
                ERR 13-MaxNameListCount
