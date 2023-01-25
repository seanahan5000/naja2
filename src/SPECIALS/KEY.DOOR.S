
NewScrolling    =   1

HATCH_INDEX     =   $C0
LIMIT_LINE      =   $C1
SRC_LINE        =   $C2
DST_LINE        =   $C3
START_COL       =   $C4
END_COL         =   $C5
PTRL            =   $C6
PTRH            =   $C7

            DO NewScrolling
PANEL_INDEX     =   HATCH_INDEX
ORDER_INDEX     =   $C8
            ELSE
POINTER         =   $C4
NUMUP           =   $C5
ENDSAVE         =   $C6
FROMCNT         =   $C7
TOCNT           =   $C8
            FIN

HATCH_TOP_LINE  =   80
HATCH_BOT_LINE  =   111                 ; inclusive

                DUMMY SCRATCH_PAGE
KEY_COUNT       DS  1
KEY_CHARS       DS  5
KEY_SLOTS       DS  5
KEY_ORDER       DS  5
KEY_PICKS       DS  5
LIMIT_LINES_U   DS  7
LIMIT_LINES_D   DS  7
                DEND

AT_KEY_DOOR     LDA KEY_DOOR_BITS
                BNE :2
:1              JSR RANDOM
                AND #$0F
                BEQ :1
                STA KEY_DOOR_BITS
:2              JSR BUILD_KEY_ORDER

                JSR DRAW_PICT
                PictSetPage2
                PictCall DRAW_DOOR
                PictCall DRAW_HATCHES
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                JSR COUNT_KEYS
                LDA KEY_COUNT
                CMP #5
                BEQ HAVE_KEYS

KEY_TURN_AWAY   LDA KEYBRD
                BPL KEY_TURN_AWAY
                JSR CHECK_TURN
                BNE KEY_TURN_AWAY
                CLC                 ; return door not opened
                RTS

HAVE_KEYS       JSR DRAW_PICT
                PictSetPage2
                PictClear 7;183;33;192
                PictTextAt 53;184;(DO_YOU_WANT_TO_INSERT_KEYS?_)
                PictSwap 7;183;33;191
                PictSetPage1
                PictEnd

                JSR GET_INPUT_KEY
:RECHECK        CMP #"Y"
                BEQ :YES
                CMP #"N"
                BEQ :NO
                JSR REGET_INPUT
                JMP :RECHECK

:NO             JSR DRAW_PICT
                PictSwap 7;183;33;191
                PictEnd
                JMP KEY_TURN_AWAY

:YES            JSR DRAW_PICT
                PictSwap 7;183;33;191
                PictSetPage2
                PictImageFill PEDESTALS
                PictClear 8;140;32;192
                PictTextAt 60;142;(SELECT_A_KEY_TO_PLACE:)
                PictCall DRAW_KEY_NAMES
                PictSetPage1
                PictSwap 8;191;32;140
                PictEnd

                JSR PICK_KEYS

                JSR DRAW_PICT
                PictSwap 8;140;32;191
                PictEnd

                LDX #4
                JSR WAIT_LOOP

                LDX #4
:1              LDA KEY_PICKS,X
                CMP KEY_ORDER,X
                BNE :FAIL
                DEX
                BPL :1
                BMI :CORRECT            ; always

:FAIL
                JSR DRAW_PICT
                PictSetPage2
                PictClear 12;183;28;192
                PictTextAt 92;184;(NOTHING_HAPPENED)
                PictSwap 12;183;28;191
                PictSetPage1
                PictEnd

                ; TODO: wait for key instead?
                LDX #16
                JSR WAIT_LOOP

                JSR DRAW_PICT
                PictSwap 12;183;28;191
                PictEnd

                JSR DRAW_PICT
                PictImageFill PEDESTALS
                PictEnd
                JMP KEY_TURN_AWAY

:CORRECT        JSR DRAW_PICT
                PictSetPage2
                PictCall DRAW_HATCHES
                PictSetPage1
                PictCall CLOSE_HATCHES
                PictEnd

                ; slight pause before starting animation
                LDX #2
                JSR WAIT_LOOP

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictSetPage1
                PictCall SCROLL_PANELS
                PictEnd

                JSR REMOVE_KEYS
                LDA KEY_DOOR_BITS
                ORA #$80
                STA KEY_DOOR_BITS
                SEC                     ; return door opened
                RTS

WAIT_LOOP       LDA #$FF
                JSR WAIT
                DEX
                BNE WAIT_LOOP
                RTS

COUNT_KEYS      LDA #0
                STA KEY_COUNT
                JSR FIRST_CHAR
:1              JSR RESET_EQLIST
                JSR ESCAN_FULSLOT
                LDX #<:ESCAN_KEYS
                LDY #>:ESCAN_KEYS
                JSR ESCAN_COMMON
                JSR NEXT_CHAR
                BCC :1
                RTS
;
; NOTE: Scanner works backwards from 15 to 0,
;   so values will be high-to-low in KEY_SLOTS.
;   This is import for REMOVE_ITEM below.
;
:ESCAN_KEYS     LDA (CHARDL),Y
                CMP #$43                ; TODO: use constant
                BNE :EXIT
                INY
                LDA (CHARDL),Y
                AND #%00000111
                CMP #$02                ; orbs/keys
                BNE :EXIT
                TXA
                LDX KEY_COUNT
                STA KEY_SLOTS,X
                LDA CHAR_INDEX
                STA KEY_CHARS,X
                INX
                STX KEY_COUNT
                LDA #0                  ; force BEQ
:EXIT           RTS

REMOVE_KEYS     LDX #0
:1              STX HATCH_INDEX
                LDA KEY_CHARS,X
                JSR SET_CHAR
                LDA KEY_SLOTS,X
                TAX
                JSR REMOVE_ITEM
                LDX HATCH_INDEX
                INX
                CPX #5
                BNE :1
                RTS

PICK_KEYS       LDX #<:KEYS_MENU
                LDY #>:KEYS_MENU
                JSR MENU_INIT

                LDX #0
:1              STX HATCH_INDEX

                LDA #4
                STA CURSOR
                JSR MENU_SELECT_NEXT
                LDA #$FF
                STA MENU_DISABLES,X
                TXA
                LDY HATCH_INDEX
                STA KEY_PICKS,Y
                JSR DRAW_KEY_NAME

                LDX HATCH_INDEX
                JSR OPEN_HATCH
                LDA #$FF
                JSR WAIT

                LDX CURSOR
                LDA HATCH_INDEX
                JSR DRAW_KEY
                JSR KEY_SOUND

                LDX HATCH_INDEX
                INX
                CPX #5
                BNE :1
                RTS

:KEYS_MENU      DB  $85
                DB  $00
                DW  :KEYS_CURS

:KEYS_CURS      LDY KEY_LINES,X
                LDX #65
                JMP DRAW_TRIANGLE

DRAW_KEY_NAMES  LDX #0
:1              STX HATCH_INDEX
                JSR DRAW_KEY_NAME
                LDX HATCH_INDEX
                INX
                CPX #5
                BNE :1
                RTS

DRAW_KEY_NAME   TXA
                PHA
                LDY KEY_LINES,X
                LDX #73
                JSR MOVE_TO
                PLA
                PHA
                JSR RACE_TO_TEXT
                JSR DRAW_TEXTBUF
                JSR HMOVE_6
                LDX #<GROUP_KEY
                LDY #>GROUP_KEY
                PLA
                JSR GET_IND_STRING
                JMP DRAW_TEXTBUF

KEY_LINES       DB  151,159,167,175,183

BUILD_KEY_ORDER PHA
                AND #3
                TAY
                LDA :ORDER_13+0,Y
                STA KEY_ORDER+1
                LDA :ORDER_13+1,Y
                STA KEY_ORDER+3
                PLA
                LSR
                LSR
                AND #3
                TAY
                LDA :ORDER_246+0,Y
                STA KEY_ORDER+0
                LDA :ORDER_246+1,Y
                STA KEY_ORDER+2
                LDA :ORDER_246+2,Y
                STA KEY_ORDER+4
                RTS

:ORDER_13       DB  deneb,stilicx,deneb,stilicx,deneb
:ORDER_246      DB  human,orn,xxtys,human,orn,xxtys
;
; On entry:
;   X: key type
;   A: hatch index
;
DRAW_KEY        CLC
                ADC :TIMES_5,X
                ASL
                TAY
                LDA KEY_IMAGES+0,Y
                TAX
                LDA KEY_IMAGES+1,Y
                TAY
                JMP UNPACK_FILL

:TIMES_5        DB  0,5,10,15,20

KEY_SOUND       LDX #$30
:1              LDY #$10
:2              PHA
                PLA
                DEY
                BNE :2
                BIT CLICK
                DEX
                BNE :1
                RTS

DRAW_HATCHES    LDX #0
:1              STX HATCH_INDEX
                LDA KEY_ORDER,X
                ASL
                TAY
                LDA HATCH_IMAGES+0,Y
                STA PTRL
                LDA HATCH_IMAGES+1,Y
                STA PTRH
                LDA PANEL_COLUMNS+1,X
                LDY #0
                STA (PTRL),Y
                LDX PTRL
                LDY PTRH
                JSR UNPACK_FILL
                LDX HATCH_INDEX
                INX
                CPX #5
                BNE :1
                RTS

OPEN_HATCH      JSR SET_HATCH
                TXA
                LSR
                BCS :OPEN_DOWN

:OPEN_UP        LDX #HATCH_BOT_LINE
:1              STX LIMIT_LINE
                LDX #HATCH_TOP_LINE
:2              JSR SET_DEST_LINE
                INX
                JSR SET_SOURCE_LINE
                JSR COPY_HATCH_LINE
                CPX LIMIT_LINE
                BNE :2
:3              JSR SET_DEST_LINE
                JSR SET_SOURCE_OFF
                JSR COPY_HATCH_LINE
                LDA #$50
                JSR WAIT
                DEX
                CPX #HATCH_TOP_LINE
                BEQ :3
                BCS :1
                RTS

:OPEN_DOWN      LDX #HATCH_TOP_LINE
:4              STX LIMIT_LINE
                LDX #HATCH_BOT_LINE
:5              JSR SET_DEST_LINE
                DEX
                JSR SET_SOURCE_LINE
                JSR COPY_HATCH_LINE
                CPX LIMIT_LINE
                BNE :5
:6              JSR SET_DEST_LINE
                JSR SET_SOURCE_OFF
                JSR COPY_HATCH_LINE
                LDA #$50
                JSR WAIT
                INX
                CPX #HATCH_BOT_LINE
                BEQ :6
                BCC :4
                RTS

CLOSE_HATCHES   LDX #0
:1              STX HATCH_INDEX
                JSR CLOSE_HATCH
                LDA #$FF
                JSR WAIT
                LDX HATCH_INDEX
                INX
                CPX #5
                BNE :1
                RTS

CLOSE_HATCH     JSR SET_HATCH
                TXA
                LSR
                BCS :CLOSE_UP

:CLOSE_DOWN     LDX #HATCH_TOP_LINE
:1              STX LIMIT_LINE
                LDA #HATCH_BOT_LINE
                STA SRC_LINE
:2              STX DST_LINE
                JSR SET_DEST_LINE
                LDX SRC_LINE
                JSR SET_SOURCE_OFF
                JSR COPY_HATCH_LINE
                DEC SRC_LINE
                LDX DST_LINE
                DEX
                CPX #HATCH_TOP_LINE
                BCS :2
                LDA #$50
                JSR WAIT
                LDX LIMIT_LINE
                INX
                CPX #HATCH_BOT_LINE+1
                BCC :1
                RTS

:CLOSE_UP       LDX #HATCH_BOT_LINE
:3              STX LIMIT_LINE
                LDA #HATCH_TOP_LINE
                STA SRC_LINE
:4              STX DST_LINE
                JSR SET_DEST_LINE
                LDX SRC_LINE
                JSR SET_SOURCE_OFF
                JSR COPY_HATCH_LINE
                INC SRC_LINE
                LDX DST_LINE
                INX
                CPX #HATCH_BOT_LINE
                BCC :4
                LDA #$50
                JSR WAIT
                LDX LIMIT_LINE
                DEX
                CPX #HATCH_TOP_LINE
                BCS :3
                RTS
;
; On entry:
;   X: hatch index
;
; On exit:
;   X: hatch index
;
SET_HATCH       LDA PANEL_COLUMNS+1,X
                STA START_COL
                LDA PANEL_COLUMNS+2,X
                STA END_COL
                RTS

COPY_HATCH_LINE LDY START_COL
:1              LDA (SCREENL),Y
                STA (DESTINL),Y
                JSR HATCH_SOUND
                INY
                CPY END_COL
                BNE :1
                RTS

HATCH_SOUND     PHA                     ; extra delay for sound
                PLA
                LDA CLICK
                LDA CLICK
                RTS

PANEL_COLUMNS   DB  0,5,11,17,23,29,35,40
BREAK_LINES     DB  95,135,55,135,55,135,95

********************************************************************************
            DO NewScrolling
********************************************************************************

SCROLL_PANELS   LDX #6
:1              LDA BREAK_LINES,X
                STA LIMIT_LINES_U,X
                CLC
                ADC #1
                STA LIMIT_LINES_D,X
                DEX
                BPL :1

:2              LDX #0
:3              STX ORDER_INDEX
                LDY PROC_INDEX,X
                LDA PROC_TABLE+0,Y
                STA :MOD+1
                LDA PROC_TABLE+1,Y
                STA :MOD+2
                LDY PANEL_ORDER,X
                STY PANEL_INDEX
                LDA PANEL_COLUMNS,Y
                STA START_COL
                LDA PANEL_COLUMNS+1,Y
                STA END_COL
:MOD            JSR $FFFF
                LDX ORDER_INDEX
                INX
                CPX #14
                BNE :3
                LDA LIMIT_LINES_U+5
                CMP #$FF
                BNE :2
                RTS

PANEL_ORDER     DB  0,0,6,6,1,1,2,2,3,3,4,4,5,5
PROC_INDEX      DB  4,6,4,6,0,2,0,2,0,2,0,2,0,2

PROC_TABLE      DW  OPEN_UP
                DW  OPEN_DOWN
                DW  FAST_UP
                DW  FAST_DOWN

OPEN_UP         LDX LIMIT_LINES_U,Y
                BEQ :2
                CPX #$FF
                BEQ :3
                STX LIMIT_LINE
                JSR SOUND_UP
                LDX #0
:1              JSR SET_DEST_LINE
                INX
                JSR SET_SOURCE_LINE
                JSR COPY_PANEL_LINE
                CPX LIMIT_LINE
                BNE :1
:2              JSR SHOW_HALL_LINE
                DEX
                LDY PANEL_INDEX
                TXA
                STA LIMIT_LINES_U,Y
:3              RTS

OPEN_DOWN       LDX LIMIT_LINES_D,Y
                CPX #191
                BEQ :2
                BCS :3
                STX LIMIT_LINE
                JSR SOUND_DOWN
                LDX #191
:1              JSR SET_DEST_LINE
                DEX
                JSR SET_SOURCE_LINE
                JSR COPY_PANEL_LINE
                CPX LIMIT_LINE
                BNE :1
:2              JSR SHOW_HALL_LINE
                INX
                LDY PANEL_INDEX
                TXA
                STA LIMIT_LINES_D,Y
:3              RTS

FAST_UP         LDX LIMIT_LINES_U,Y
                BMI :1
                JSR SHOW_HALL_LINE
                DEX
                JSR SHOW_HALL_LINE
                DEX
                LDY PANEL_INDEX
                TXA
                STA LIMIT_LINES_U,Y
                BMI :1
                JMP SHOW_BREAK_LINE
:1              RTS

FAST_DOWN       LDX LIMIT_LINES_D,Y
                CPX #192
                BEQ :1
                JSR SHOW_HALL_LINE
                INX
                JSR SHOW_HALL_LINE
                INX
                LDY PANEL_INDEX
                TXA
                STA LIMIT_LINES_D,Y
                CPX #192
                BEQ :1
                JMP SHOW_BREAK_LINE
:1              RTS

SHOW_BREAK_LINE JSR SET_SOURCE_LINE
                LDY START_COL
:1              LDA DOOR_BREAKS,Y
                STA (SCREENL),Y
                INY
                CPY END_COL
                BNE :1
                RTS

SHOW_HALL_LINE  JSR SET_DEST_LINE
                JSR SET_SOURCE_OFF
COPY_PANEL_LINE LDY START_COL
:1              LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY END_COL
                BNE :1
                RTS

SOUND_UP        STX :MOD+1
                LDA #135
                SEC
:MOD            SBC #$FF
                JMP UD_SOUND_CMN
SOUND_DOWN      TXA
                SEC
                SBC #56
UD_SOUND_CMN    TAY
                BEQ :3
:2              BIT CLICK
                LDA #$02
                JSR WAIT
                DEY
                BNE :2
:3              LDA #$20
                JSR WAIT
                RTS

********************************************************************************
            ELSE ; !NewScrolling
********************************************************************************
;
; Vintage code circa 1983
;
SCROLL_PANELS   JSR UPA
                JSR DOWNA
                JSR UPG
                JSR DOWNG
                JSR UPB
                JSR DOWNB
                JSR UPC
                JSR DOWNC
                JSR UPD
                JSR DOWND
                JSR UPE
                JSR DOWNE
                JSR UPF
                JSR DOWNF
                JMP SCROLL_PANELS

UPA             NOP
                LDY #$00
                JSR UP2
                CMP #1
                BNE :1
                LDA #$60
                STA UPA
:1              RTS

DOWNA           NOP
                LDY #1
                JSR DOWN2
                CMP #190
                BNE :1
                LDA #$60
                STA DOWNA
:1              RTS

UPG             NOP
                LDY #$0C
                JSR UP2
                CMP #1
                BNE :1
                LDA #$60
                STA UPG
:1              RTS

DOWNG           NOP
                LDY #$0D
                JSR DOWN2
                CMP #190
                BNE :1
                LDA #$60
                STA DOWNG
:1              RTS

UPB             NOP
                LDY #$02
                JSR UP1
                CMP #0
                BNE :1
                LDA #$60
                STA UPB
:1              RTS

DOWNB           NOP
                LDY #$03
                JSR DOWN1
                CMP #191
                BNE :1
                LDA #$60
                STA DOWNB
:1              RTS

UPC             NOP
                LDY #$04
                JSR UP1
                CMP #0
                BNE :1
                LDA #$60
                STA UPC
:1              RTS

DOWNC           NOP
                LDY #$05
                JSR DOWN1
                CMP #191
                BNE :1
                LDA #$60
                STA DOWNC
:1              RTS

UPD             NOP
                LDY #$06
                JSR UP1
                CMP #0
                BNE :1
                LDA #$60
                STA UPD
:1              RTS

DOWND           NOP
                LDY #$07
                JSR DOWN1
                CMP #191
                BNE :1
                LDA #$60
                STA DOWND
:1              RTS

UPE             NOP
                LDY #$08
                JSR UP1
                CMP #0
                BNE :1
                LDA #$60
                STA UPE
:1              RTS

DOWNE           NOP
                LDY #$09
                JSR DOWN1
                CMP #191
                BNE :1
                LDA #$60
                STA DOWNE
:1              RTS

UPF             NOP
                LDY #$0A
                JSR UP1
                CMP #0
                BNE :1
                PLA
                PLA
:1              RTS

DOWNF           NOP
                LDY #$0B
                JSR DOWN1
                CMP #191
                BNE :1
                LDA #$60
                STA DOWNF
:1              RTS

BEGROW          DB  $00,$00
                DB  $05,$05
                DB  $0B,$0B
                DB  $11,$11
                DB  $17,$17
                DB  $1D,$1D
                DB  $23,$23
ENDROW          DB  $04,$04
                DB  $0A,$0A
                DB  $10,$10
                DB  $16,$16
                DB  $1C,$1C
                DB  $22,$22
                DB  $27,$27
ENDLINES        DB  $5F,$60
                DB  $87,$88
                DB  $37,$38
                DB  $87,$88
                DB  $37,$38
                DB  $87,$88
                DB  $5F,$60

UP1             LDA #$01
                BNE UP_CMN             ; always
UP2             LDA #$02
UP_CMN          STA NUMUP
                STY POINTER
                JSR UP_WAIT
                LDA NUMUP
                STA FROMCNT
                SEC
                SBC ENDLINES,Y
                CMP #$01
                BNE CONTINU
                LDA ENDLINES,Y
                JMP FINISH
CONTINU         LDA #$00
                STA TOCNT
LOOPA           LDX FROMCNT
                JSR SET_SOURCE_LINE
                LDX TOCNT
                JSR SET_DEST_LINE
                LDA ENDROW,Y
                STA ENDSAVE
                LDA BEGROW,Y
                TAY
LOOPB           LDA (SCREENL),Y
                STA (DESTINL),Y
                CPY ENDSAVE
                BEQ SKIP1
                INY
                JMP LOOPB
SKIP1           LDY POINTER
                LDA ENDLINES,Y
                CMP FROMCNT
                BEQ FINISH
                INC FROMCNT
                INC TOCNT
                JMP LOOPA
FINISH          PHA
                LDA ENDLINES,Y
                SEC
                SBC NUMUP
                STA ENDLINES,Y
                STA TOCNT
                INC TOCNT
                LDA NUMUP
                STA FROMCNT
LOOPC           LDX TOCNT
                JSR SET_SOURCE_OFF
                JSR SET_DEST_LINE
                LDA ENDROW,Y
                STA ENDSAVE
                LDA BEGROW,Y
                TAY
LOOPD           LDA (SCREENL),Y
                STA (DESTINL),Y
                CPY ENDSAVE
                BEQ SKIP2
                INY
                JMP LOOPD
SKIP2           LDA FROMCNT
                CMP #$01
                BEQ DONE
                DEC FROMCNT
                INC TOCNT
                LDY POINTER
                JMP LOOPC
DONE            PLA
                RTS

DOWN1           LDA #$01
                BNE DWN_CMN             ; always
DOWN2           LDA #$02
DWN_CMN         STA NUMUP
                STY POINTER
                JSR DOWN_WAIT
                LDA #191
                STA TOCNT
                SEC
                SBC NUMUP
                STA FROMCNT
                LDA #191
                SEC
                SBC ENDLINES,Y
                CMP NUMUP
                BCS LOOPE
                LDA ENDLINES,Y
                BCC FINISH2             ; always
LOOPE           LDX FROMCNT
                JSR SET_SOURCE_LINE
                LDX TOCNT
                JSR SET_DEST_LINE
                LDA ENDROW,Y
                STA ENDSAVE
                LDA BEGROW,Y
                TAY
LOOPF           LDA (SCREENL),Y
                STA (DESTINL),Y
                CPY ENDSAVE
                BEQ SKIP3
                INY
                JMP LOOPF
SKIP3           LDY POINTER
                LDA ENDLINES,Y
                CMP FROMCNT
                BEQ FINISH2
                DEC FROMCNT
                DEC TOCNT
                JMP LOOPE
FINISH2         PHA
                LDA ENDLINES,Y
                CLC
                ADC NUMUP
                STA ENDLINES,Y
                STA TOCNT
                DEC TOCNT
                LDA NUMUP
                STA FROMCNT
LOOPG           LDX TOCNT
                JSR SET_SOURCE_OFF
                JSR SET_DEST_LINE
                LDA ENDROW,Y
                STA ENDSAVE
                LDA BEGROW,Y
                TAY
LOOPH           LDA (SCREENL),Y
                STA (DESTINL),Y
                CPY ENDSAVE
                BEQ SKIP4
                INY
                JMP LOOPH
SKIP4           LDA FROMCNT
                CMP #$01
                BEQ DONE2
                DEC FROMCNT
                DEC TOCNT
                LDY POINTER
                JMP LOOPG
DONE2           PLA
                RTS

UP_WAIT         LDA #135
                SEC
                SBC ENDLINES,Y
                PHA
                JMP UD_WAIT_CMN
DOWN_WAIT       LDA ENDLINES,Y
                SEC
                SBC #56
                PHA
UD_WAIT_CMN     LDA NUMUP
                CMP #$01
                BEQ :WAITER
                PLA
                LSR A
                PHA
                LDA NUMUP
                CMP #$02
                BEQ :WAITER
                PLA
                LSR A
                PHA
:WAITER         PLA
                TAX
:LOOPER         CPX #$00
                BEQ :OUT
                BIT CLICK
                LDA #$02
                JSR WAIT
                DEX
                JMP :LOOPER
:OUT            RTS

********************************************************************************
            FIN ; !NewScrolling
********************************************************************************

DRAW_DOOR       LDX #0
:1              JSR SET_SOURCE_LINE
                LDY #39
:2              LDA DOOR_STRIPES,Y
                STA (SCREENL),Y
                DEY
                BPL :2
                INX
                CPX #192
                BNE :1
                LDX #$00
:3              STX :MOD4+1
                LDA PANEL_COLUMNS,X
                STA :MOD1+1
                LDA PANEL_COLUMNS+1,X
                STA :MOD2+1
                LDA BREAK_LINES,X
                TAX
                CLC
                ADC #$02
                STA :MOD3+1
:4              JSR SET_SOURCE_LINE
:MOD1           LDY #$FF
:5              LDA DOOR_BREAKS,Y
                STA (SCREENL),Y
                INY
:MOD2           CPY #$FF
                BNE :5
                INX
:MOD3           CPX #$FF
                BNE :4
:MOD4           LDX #$FF
                INX
                CPX #7
                BNE :3
                RTS

DOOR_STRIPES    HEX ABD5AAD5BA
                HEX ABD5AAD5AAF5
                HEX 562A552A553A
                HEX ABD5AAD5AAF5
                HEX 562A552A553A
                HEX ABD5AAD5AAF5
                HEX D6AAD5AAB5

DOOR_BREAKS     HEX 7F7F7F7FBF
                HEX FFFFFFFFFFFF
                HEX 7E7F7F7F7F3F
                HEX FFFFFFFFFFFF
                HEX 7E7F7F7F7F3F
                HEX FFFFFFFFFFFF
                HEX FE7F7F7FBF

PEDESTALS       DB  $05,$4F,$1E,$22
                HEX 807B7B5B1BED5B7B7B7F00071C7000C57040008D603C0700
                HEX 7F7F0089017F06B9607F897806064F417000007F97040000
                HEX 7F00B97F91007F3E6B970618D70700037F890F0000790107
                HEX 00007F7776FD7780768936ED76897F82030E3860BD82607C
                HEX 70826089380E03827F7F887F9E787F897E82830560D3F07C
                HEX 60827F7F887F9E7F918283059FAFBA7F1F827F7F883FA01F
                HEX 3F3F03843E8201847F3BFD89807B3B7B5B5B1BDD5B7B7B3B
                HEX 7B7F000001017F03BD787F7C4303037F01970802D709007E
                HEX 7F8D0078745C7F78007FD71D001F7F8D00074B0E3F07007F
                HEX 7F004060603F30BD073F0F30893F604040007F778976E977
                HEX 8D807636FD767F887F9E407E7F7F7084819F8260847F7F88
                HEX 7F9E7F91828305FEFDD77F7E827F7F887F9E077F891F8283
                HEX 0501F2830F01827F7F40970E1CBD82010F038203890E1870
                HEX 407F3BFD89807B1B8D5B1BBD5B89A730027BD71F00707F89
                HEX 7C004027607840007FEF07003F5F757F3F007F973405407F
                HEX 30B9013F7F7F0730307C400300007F7F97031CC503009103
                HEX 1E70407F972200F17777
                DB  $FF

HATCH_IMAGES    DW  HATCH_HUMAN     ; blue hatch
                DW  HATCH_ORN       ; blue hatch
                DW  HATCH_STILICX   ; green hatch
                DW  HATCH_XXTYS     ; blue hatch
                DW  HATCH_DENEB     ; green hatch

HATCH_HUMAN     DB  $05,$4F,$06,$22
                HEX 807B3BFD7B7F55A11515456565718D656545151555A17F7F
                HEX 2A9902707C0703010060707060000103077C70022A997F7F
                HEX 559950430F3C70604041434341406070380F435055997F7F
                HEX 2AA9282929238D2929282AA97F77FD89
                DB  $FF

HATCH_ORN       DB  $05,$4F,$06,$22
                HEX 807B3BFD7B7F55B101798D0155B17F7F2AA1007C7C00007F
                HEX 8D0097040A2AA17F7F55A1404F4F409F040E97060A55A17F
                HEX 7F2AB120278D202AB17F77FD89
                DB  $FF

HATCH_STILICX   DB  $0B,$4F,$06,$22
                HEX 76FD897F2AA1827E7C7872620A6272787C7E822AA57F7F55
                HEX A1822F777B7D7E827E7D7B772F8255A57F7F2AA1827F7E7D
                HEX 7B3782377B7D7E7F822AA57F7F55A1505753515454555454
                HEX 5153575055A57F3BFD89
                DB  $FF

HATCH_XXTYS     DB  $05,$4F,$06,$22
                HEX 807B3BFD7B7F558D05717C7E897C7C7B78787770706F6065
                HEX 8D1555997F7F2A8D28230F1F890F0F7707077B03037D0129
                HEX 8D2A9D7F7F559515658D606F70707778787B7C9703077105
                HEX 55917F7F2A99298D013D03033B0707370F97050723282A91
                HEX 7F77FD89
                DB  $FF

HATCH_DENEB     DB  $0B,$4F,$06,$22
                HEX 76FD897F2AA10A0A2A827C400A89407C822AA97F7F55A140
                HEX 4F1E3C7973070F4753515455A97F7F2AA1823C1E0F677338
                HEX 3C3872620A2AA97F7F55A1545455404F405489404F4055A9
                HEX 7F3BFD89
                DB  $FF

KEY_IMAGES      DW  KEY_HUMAN_0
                DW  KEY_HUMAN_1
                DW  KEY_HUMAN_2
                DW  KEY_HUMAN_3
                DW  KEY_HUMAN_4
                DW  KEY_ORN_0
                DW  KEY_ORN_1
                DW  KEY_ORN_2
                DW  KEY_ORN_3
                DW  KEY_ORN_4
                DW  KEY_STILICX_0
                DW  KEY_STILICX_1
                DW  KEY_STILICX_2
                DW  KEY_STILICX_3
                DW  KEY_STILICX_4
                DW  KEY_XXTYS_0
                DW  KEY_XXTYS_1
                DW  KEY_XXTYS_2
                DW  KEY_XXTYS_3
                DW  KEY_XXTYS_4
                DW  KEY_DENEB_0
                DW  KEY_DENEB_1
                DW  KEY_DENEB_2
                DW  KEY_DENEB_3
                DW  KEY_DENEB_4
;
; HUMAN (white sand in blue bag) panels 0,2,[4]
;
KEY_HUMAN_0     DB  $07,$5F,$03,$09
                HEX 8006892646106D5A6D4050555056138B440A2A914A607F
                DB  $06,$6D,$02,$03
                HEX 803C4700720008
                DB  $FF

KEY_HUMAN_1     DB  $0C,$5F,$04,$09
                HEX 60918000205C3084200850645B761B5054558B4455047102
                HEX 0A911280383F
                DB  $0C,$6D,$02,$03
                HEX 804E13827C816002
                DB  $FF

KEY_HUMAN_2     DB  $12,$5F,$04,$09
                HEX 80039568576C000028023419361D2654558D5155017C3032
                HEX 91043E800F
                DB  $12,$6D,$01,$03
                HEX 80100440
                DB  $FF

KEY_HUMAN_3     DB  $18,$5F,$04,$09
                HEX 805054915307817F020A2A0A6A488B23000001040209365B
                HEX 3681039100010E03
                DB  $1A,$6D,$02,$03
                HEX 81CF01801018728040
                DB  $FF

KEY_HUMAN_4     DB  $1E,$5F,$03,$09
                HEX 8054558D1554017F00022A025A325A724830893130022D56
                HEX 6D
                DB  $20,$6D,$01,$03
                HEX 80134004
                DB  $FF
;
; ORN (orange rock) panels [0],2,4
;
KEY_ORN_0       DB  $07,$5F,$03,$09
                HEX 8006064646525013530F002A2228282A2A0A700505111115
                HEX 14617E7F
                DB  $FF

KEY_ORN_1       DB  $0D,$5F,$03,$09
                HEX 82804050101454445403202A282A2A0A2A027C0101040405
                HEX 0580183F3F
                DB  $FF

KEY_ORN_2       DB  $12,$5F,$04,$09
                HEX 800395181F7C005014444555515500282A0A0A2A220A707F
                HEX 3030318D063F0F
                DB  $FF

KEY_ORN_3       DB  $18,$5F,$03,$09
                HEX 80202008082828067F7F01554515155455500F000002020A
                HEX 0A484A70
                DB  $FF

KEY_ORN_4       DB  $1E,$5F,$03,$09
                HEX 80282822222A0A211F7F001551454555155403308D320232
                HEX 727C
                DB  $FF
;
; STILICX (purple crystal) panels [1],3
;
KEY_STILICX_0   DB  $06,$54,$04,$14
                HEX 94408E70401F06A104020A2C387260770F7F630F3D893589
                HEX 151555456564011545505E017F8A0202038D62687A1A241A
                HEX 7F7C
                DB  $FF

KEY_STILICX_1   DB  $0C,$54,$04,$14
                HEX 60A14010404082206082607C70676020A5220B2E3C301D43
                HEX 3F78030F890D4D4D6565757159194045115477823F96181A
                HEX 1E0609063F3F
                DB  $FF

KEY_STILICX_2   DB  $12,$54,$04,$14
                HEX 81FF03A104115363430303387F81FC19786889289D220B2F
                HEX 2C07700F7E82038D131319191D1C1646505124557D6081BF
                HEX 30A9363637313201803F0F
                DB  $FF

KEY_STILICX_3   DB  $18,$54,$04,$14
                HEX 7F8A409546165E5824587F3F47703C892C8929292B232626
                HEX 8228220A7B827941A1014151341D4F036E707F01A1820286
                HEX 010182010F03
                DB  $FF

KEY_STILICX_4   DB  $1D,$54,$05,$14
                HEX 805B1BA95B899701097F0091801010303070705145171649
                HEX 567F0F313C2F892B892A89282909206A68421E607E80309D
                HEX 10804010140D2733823B7C807F00A58200990300
                DB  $FF
;
; XXTYS (blue chip) panels 0,[2],4
;
KEY_XXTYS_0     DB  $07,$65,$03,$03
                HEX 803F3F7F0054547F7E7E
                DB  $FF

KEY_XXTYS_1     DB  $0D,$65,$02,$03
                HEX 800F0F1F605555
                DB  $FF

KEY_XXTYS_2     DB  $13,$65,$02,$03
                HEX 80032327787575
                DB  $FF

KEY_XXTYS_3     DB  $19,$65,$02,$03
                HEX 80012A2A7C7C7E
                DB  $FF

KEY_XXTYS_4     DB  $1E,$65,$02,$03
                HEX 803F5F5F000A4A
                DB  $FF
;
; DENEB (green leaf) panels 1,[3]
;
KEY_DENEB_0     DB  $06,$61,$04,$07
                HEX 800082830380202082408307868640501540BF830780282A
                HEX 02282AC083075445101505F8FF
                DB  $FF

KEY_DENEB_1     DB  $0C,$61,$04,$07
                HEX 6089022A827082405415415403202A02282A427C15040101
                HEX 1C3F3F
                DB  $FF

KEY_DENEB_2     DB  $12,$60,$04,$08
                HEX 81838982022A82807C830880804054154154030080202A02
                HEX 282A027C821504313180063F0F
                DB  $FF

KEY_DENEB_3     DB  $18,$61,$04,$07
                HEX 2A0820200E7F7F0155500555500F840A2A200A7003891015
                HEX 8203
                DB  $FF

KEY_DENEB_4     DB  $1E,$61,$04,$07
                HEX 2A220828271F7F81801554411554038307B0B0020A28027C
                HEX 8180890405828000
                DB  $FF
