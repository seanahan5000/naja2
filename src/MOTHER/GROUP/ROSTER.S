
                DUMMY SCRATCH_PAGE
;
; list of roster locations
;
; xy00iiii
;   x: 1 if in group
;   y: 1 if dirty
;   i: roster index
;
ROSTER_LIST     DS  maxRosterSize
HLEGALS         DS  4
NAME_BUFFER     DS  charNameLength+1
                DEND

;---------------------------------------

LOAD_ROSTER     LDA #fileSaveGame
                JSR SET_FILE
                LDA #stateSectors
                JSR SEEK_FILE

                ; TODO: minimize read size based on ROSTER_BITS
                LDA #rosterSectors
                LDY #>ROSTER_BUFFER
                JSR READ_FILE

                LDA #0
                STA ROSTER_COUNT
                LDX #0
:1              STX COUNT
                TXA
                JSR TEST_ROSTER_BIT
                BEQ :5
                JSR FIRST_CHAR
:2              LDY #rosterLocation
                LDA (CHARDL),Y
                AND #%00001111
                CMP COUNT
                BEQ :3
                JSR NEXT_CHAR
                BCC :2
                LDA COUNT
                BCS :4                  ; always
:3              ORA #%10000000          ; mark as in group
:4              LDX ROSTER_COUNT
                STA ROSTER_LIST,X
                INC ROSTER_COUNT
:5              LDX COUNT
                INX
                CPX #maxRosterSize
                BNE :1
                RTS
;
; On entry:
;   A: roster character index
;
; On exit:
;   BNE true if bit allocated
;
TEST_ROSTER_BIT LDX #0
                CMP #8
                AND #$07
                BCC :1
                INX
:1              TAY
                LDA ROSTER_BITS,X
                AND BIT_TABLE,Y
                RTS

;---------------------------------------
;
; Write to disk any roster entries marked as dirty.
;
; NOTE: If there are any dependencies between a single character
;   and the overall game state, force a write of the state too.
;
WRITE_ROSTER    LDY #0
                LDX #0
:1              LDA ROSTER_BITS,X
                AND #%01000000
                BEQ :2
                INY
:2              INX
                CPX ROSTER_COUNT
                BNE :1
                TYA
                BEQ :6
                LDA #>ROSTER_BUFFER
                STA CHARPTR+1
                LDX #0
:3              LDA ROSTER_BITS,X
                AND #%01000000
                BNE :4
                LDA ROSTER_BITS+1,X
                AND #%01000000
                BEQ :5
:4              TXA
                PHA
                LSR
                JSR SEEK_FILE
                LDA #1
                LDY CHARPTR+1
                ;*** JSR WRITE_FILE
                PLA
                TAX
:5              INC CHARPTR+1
                INX
                INX
                CPX ROSTER_COUNT
                BNE :3
:6              RTS

;---------------------------------------

rosterNameX     =   8

DRAW_ROSTER
                ; *** SHOW ROSTER UPDATING? ***
                ; *** CHECK FOR IT CURRENTLY BEING VALID? ***

                JSR DRAW_PICT
                ; *** set page ***
                PictClearPage

                ; *** redo all this spacing ***

                ; *** add/use PictTextAtX ***
                ; PictTextAt 8;2;"NAME      PROFESSION   RACE   LEVEL  STATUS"
                PictTextAt 8;2;"NAME"
                PictTextAt 71;2;"PROFESSION"
                PictTextAt 140;2;"RACE"
                PictTextAt 188;2;"LEVEL"
                PictTextAt 227;2;"STATUS"

                PictSetGreen
                PictMoveTo $00;$0B
                PictLineTo $117;$0B
                PictMoveTo $00;$B5
                PictLineTo $117;$B5
                PictShowPage            ;***
                PictVMoveTo 14
                PictEnd

                LDX #0
:1              STX COUNT
                JSR SET_RCHARDL
                LDX COUNT
                LDA ROSTER_LIST,X
                BPL :2
                JSR DRAW_DOTS
:2              JSR DRAW_PICT
                PictCall CNAME_TO_TEXT
                PictTextbufX rosterNameX
                PictCall CPROF_TO_TEXT
                PictTextbufX 74
                PictCall CRACE_TO_TEXT
                PictTextbufX 140
                PictCall CLEV_TO_TEXT_R
                PictTextbufX 185
                PictCall CSTATUS_TO_TEXT_C
                PictTextbufX 218
                PictVMove 9
                PictEnd
                LDX COUNT
                INX
                CPX ROSTER_COUNT
                BNE :1
                RTS

;---------------------------------------

USE_ROSTER      JSR DRAW_PICT
                PictSetPage2            ;***
                PictCall DRAW_ROSTER
                PictEnd

                LDA #0
                STA ADD_MDEF+1
                STA REMOVE_MDEF+1
                STA RENAME_MDEF+1

                LDA #3                  ; *** start on ADD
                ; *** ADJUST THESE VALUES ***
ROSTER_LOOP     STA CURSOR
                JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 42;184;"ADD   REMOVE   CHANGE-NAME   LEAVE"
                PictEnd

                LDX #3
                LDA #0
:1              STA HLEGALS,X
                DEX
                BPL :1
                LDA GRPNUMB
                CMP #maxGroupSize
                BEQ :2
                JSR LEGAL_ADDS
                JSR COUNT_LEGALS
                BNE :3
:2              DEC HLEGALS+0
:3              LDA GRPNUMB
                BEQ :4
                JSR LEGAL_REMOVES
                JSR COUNT_LEGALS
                BNE HFIRST
:4              DEC HLEGALS+1
                BNE HFIRST              ; always

HBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI HKEYHIT
                JSR DRAW_HARROW
                LDA #$00
                JSR WAIT_KEY
                JSR DRAW_HARROW
HKEYLOOP        LDA KEYBRD
                BPL HBLINK
HKEYHIT         BIT UNSTROB
                JSR CHECK_ENTER
                BEQ HENTER
                JSR CHECK_RIGHT
                BEQ HRIGHT
                JSR CHECK_LEFT
                BEQ HLEFT
                JSR CHECK_CANCEL
                BEQ HCANCEL
                BNE HKEYLOOP            ; always

HLEFT           JSR DRAW_HARROW
:1              LDX CURSOR
                DEX
                BPL :2
                LDX #3
:2              STX CURSOR
                LDA HLEGALS,X
                BNE :1
                JSR DRAW_HARROW
                JMP HKEYLOOP

HRIGHT          JSR DRAW_HARROW
HFIRST          LDX CURSOR
                INX
                CPX #4
                BNE :1
                LDX #0
:1              STX CURSOR
                LDA HLEGALS,X
                BNE HFIRST
                JSR DRAW_HARROW
                JMP HKEYLOOP

HENTER          JSR DRAW_HARROW
                LDX CURSOR
                BEQ DO_ADD
                DEX
                BEQ DO_REMOVE
                DEX
                BEQ TO_RENAME
HCANCEL         JMP MAIN_LOOP1
TO_RENAME       JMP DO_RENAME

;---------------------------------------

DO_ADD          JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 102;184;"ADD WHO?"   ;*** better message?
                PictTextAt 234;184;"C>ANCEL"
                PictEnd
                JSR LEGAL_ADDS
                LDA ROSTER_COUNT
                STA ADD_MDEF+0
                LDX #<ADD_MDEF
                LDY #>ADD_MDEF
                JSR MENU_INIT
                JSR MENU_SET_CANCEL
                JSR MENU_SELECT
                STX ADD_MDEF+1
                BCC :1
                JSR ADD_RCHAR
                LDX CURSOR
                JSR DRAW_DOTS
:1              LDA #3                  ; ADD -> REMOVE
                JMP ROSTER_LOOP

ADD_MDEF        DB  maxRosterSize       ; modified
                DB  $00                 ; modified
                DW  ROSTER_CURSOR

;---------------------------------------

DO_REMOVE       JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 48;184;"REMOVE WHICH GROUP MEMBER?"
                PictTextAt 234;184;"C>ANCEL"
                PictEnd
                JSR LEGAL_REMOVES
                LDA ROSTER_COUNT
                STA REMOVE_MDEF+0
                LDX #<REMOVE_MDEF
                LDY #>REMOVE_MDEF
                JSR MENU_INIT
                JSR MENU_SET_CANCEL
                JSR MENU_SELECT
                STX REMOVE_MDEF+1
                BCC :1
                JSR REMOVE_RCHAR
                LDX CURSOR
                JSR DRAW_DOTS
:1              LDX #0
                LDA GRPNUMB
                BNE :2
                LDX #3                  ; if group empty, start on ADD
:2              TXA
                JMP ROSTER_LOOP

REMOVE_MDEF     DB  maxRosterSize       ; modified
                DB  $00                 ; modified
                DW  ROSTER_CURSOR

;---------------------------------------

ROSTER_CURSOR   LDY ROSTER_YPNTS,X
                LDX #$00
                JSR DRAW_TRIANGLE
                LDX CURSOR
                LDA ROSTER_LIST,X
                BPL :1
                LDX #2
                JSR HMOVE_TO
                JMP DRAW_DOT

:1              LDX #<270
                JSR HMOVE_TO_H
                LDX #<:BACK_TRI
                LDY #>:BACK_TRI
                JMP DRAW_TILE

:BACK_TRI       DB  %00110000
                DB  %00111000
                DB  %00111100
                DB  %00111111
                DB  %00111100
                DB  %00111000
                DB  %00110000
;
; On entry:
;   X: packed roster index
;
DRAW_DOTS       LDY ROSTER_YPNTS,X
                LDX #2
                JSR MOVE_TO
                JSR DRAW_DOT
                LDX #<273
                JSR HMOVE_TO_H
                ; fall through
DRAW_DOT        LDX #<:DOT_SHAPE
                LDY #>:DOT_SHAPE
                JMP DRAW_TILE

; TODO: consider using square marker instead
; *** try it out ***
:DOT_SHAPE      DB  %00000000
                DB  %00000110
                DB  %00001111
                DB  %00001111
                DB  %00000110
                DB  %00000000
                DB  %00000000

DRAW_HARROW     LDY CURSOR
                LDX :HARROW_XPNTS,Y
                LDY #$B8
                JSR MOVE_TO
                LDX #<:HARROW_SHAPE
                LDY #>:HARROW_SHAPE
                JMP DRAW_TILE

:HARROW_XPNTS   DB  34,70,124,208

:HARROW_SHAPE   DB  %00000000
                DB  %00000011
                DB  %00001110
                DB  %00111110
                DB  %00001110
                DB  %00000011
                DB  %00000000

ROSTER_YPNTS    DB  14,23,32,41
                DB  50,59,68,77
                DB  86,95,104,113
                DB  122,131,140,149

;---------------------------------------
;
; Build LEGALS list for adding or removing to/from group
;
;   Can't add robot until its cybernate is added
;   Can't remove a cybernate until its robot is removed
;
LEGAL_ADDS      LDX #0
:1              STX COUNT
                LDA ROSTER_LIST,X
                BMI :4
                JSR SET_RCHARDL
                ; TODO: what other statuses prevent add?
                ; TODO: is this check even necessary?
                LDY #status
                LDA (CHARDL),Y
                AND #%00111111
                CMP #intracc
                BEQ :4
                LDY #profrace
                LDA (CHARDL),Y
                BPL :5
                ; if robot, make sure its cybernate has been added
                LDY #roboCyberLink
                LDA (CHARDL),Y
                STA :MOD+1
                LDX #0
:2              LDA ROSTER_LIST,X
                BPL :3
:MOD            EOR #$FF
                AND #%00001111
                BEQ :5
:3              INX
                CPX ROSTER_COUNT
                BNE :2
:4              LDY #-1
                BMI :6                  ; always
:5              LDY #0
:6              TYA
                LDX COUNT
                STA LEGALS,X
                INX
                CPX ROSTER_COUNT
                BNE :1
                RTS

LEGAL_REMOVES   LDX #0
:1              STX COUNT
                LDY #-1
                LDA ROSTER_LIST,X
                BPL :5
                JSR SET_RCHARDL
                LDY #profrace
                LDA (CHARDL),Y
                AND #$F0
                CMP #cybernate*16
                BNE :4
                ; if cybernate, make sure its robot has been removed
                LDY #roboCyberLink
                LDA (CHARDL),Y
                STA :MOD+1
                LDY #-1
                LDX #0
:2              LDA ROSTER_LIST,X
                BPL :3
:MOD            EOR #$FF
                AND #%00001111
                BEQ :5
:3              INX
                CPX ROSTER_COUNT
                BNE :2
:4              LDY #0
:5              TYA
                LDX COUNT
                STA LEGALS,X
                INX
                CPX ROSTER_COUNT
                BNE :1
                RTS
;
; On exit:
;   A: number of available spots in LEGALS
;   BEQ/BNE: set based on result
;
COUNT_LEGALS    LDX ROSTER_COUNT
                LDY #0
:1              DEX
                BMI :2
                LDA LEGALS,X
                BNE :1
                INY
                BNE :1                  ; always
:2              TYA
                RTS

;---------------------------------------
;
; On entry:
;   X: packed roster character index
;
ADD_RCHAR       LDA ROSTER_LIST,X
                ORA #%10000000
                STA ROSTER_LIST,X
                JSR SET_RCHARPTR
                LDA GRPNUMB
                JSR SET_CHAR
                LDY #$7F
:1              LDA (CHARPTR),Y
                STA (CHARDL),Y
                DEY
                BPL :1
                INC GRPNUMB
                ; TODO: should this be done elsewhere?
                JSR CALC_ALL
                RTS
;
; On entry:
;   X: packed roster character index
;
REMOVE_RCHAR    LDA ROSTER_LIST,X
                EOR #%10000000
                ORA #%01000000
                STA ROSTER_LIST,X
                STA :MOD+1
                JSR SET_RCHARPTR
                JSR FIRST_CHAR
:1              LDY #rosterLocation
                LDA (CHARDL),Y
:MOD            EOR #$FF
                AND #%00001111
                BEQ REMOVE_CMN
                JSR NEXT_CHAR
                BCC :1
                BCS REMOVE_CMN          ; always
;
; On entry:
;   X: character index in group
;
REMOVE_GCHAR    TXA
                JSR SET_CHAR
                LDY #rosterLocation
                LDA (CHARDL),Y
                STA :MOD+1
                LDX #0
:1              LDA ROSTER_LIST,X
:MOD            EOR #$FF
                AND #%00001111
                BEQ :2
                INX
                CPX ROSTER_COUNT
                BNE :1
:2              LDA ROSTER_LIST,X
                EOR #%10000000
                ORA #%01000000
                STA ROSTER_LIST,X
                JSR SET_RCHARPTR
REMOVE_CMN      LDY #$7F
:1              LDA (CHARDL),Y
                STA (CHARPTR),Y
                DEY
                BPL :1
DELETE_GCHAR    LDA CHARDL
                STA CHARPTR+0
                LDA CHARDH
                STA CHARPTR+1
                JSR NEXT_CHAR
                BCS :2
                LDY #$7F
:1              LDA (CHARDL),Y
                STA (CHARPTR),Y
                DEY
                BPL :1
                BMI DELETE_GCHAR        ; always
:2              DEC GRPNUMB
                RTS
;
; On entry:
;   X: roster list index
;
; On exit:
;   X: pointing to character in roster buffer (LOW)
;   Y: pointing to character in roster buffer (HIGH)
;
SET_RCHAR       LDA ROSTER_LIST,X
                AND #$0F
                LSR
                PHA
                LDA #$00
                ROR
                TAX
                PLA
                CLC
                ADC #>ROSTER_BUFFER
                TAY
                RTS
;
; On entry:
;   X: roster list index
;
SET_RCHARDL     JSR SET_RCHAR
                STX CHARDL
                STY CHARDH
                RTS
;
; On entry:
;   X: roster list index
;
SET_RCHARPTR    JSR SET_RCHAR
                STX CHARPTR+0
                STY CHARPTR+1
                RTS

;---------------------------------------

DO_RENAME       JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 72;184;"CHANGE WHOSE NAME?"
                PictTextAt 234;184;"C>ANCEL"
                PictEnd

                LDA ROSTER_COUNT
                ORA #$80
                STA RENAME_MDEF+0
                LDX #<RENAME_MDEF
                LDY #>RENAME_MDEF
                JSR MENU_INIT
                JSR MENU_SET_CANCEL
                JSR MENU_SELECT
                BCS TO_RENAME_LOOP
                LDA #1                  ; stay on RENAME
                JMP ROSTER_LOOP

TO_RENAME_LOOP  STX RENAME_MDEF+1
                LDX CURSOR
                JSR ROSTER_CURSOR       ; leave cursor up
RENAME_LOOP     LDX CURSOR
                JSR SET_RCHARDL

                JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 8;184;"CHANGE FROM '"
                PictCall DRAW_TRIMMED_NAME
                PictText "' TO WHAT? "
                PictEnd

                LDA #10
                JSR GET_INPUT_LIMIT
:1
                ; *** CANCEL WITH ESCAPE??? ***
                TXA
                BNE :2
                LDX CURSOR
                JSR ROSTER_CURSOR
                LDA #1                  ; stay on RENAME
                JMP ROSTER_LOOP

:2              LDA TEXT_BUFFER
                CMP #TextSpace
                BNE PAD_NAME
                JSR REGET_INPUT
                JMP :1

PAD_NAME        LDX #0
:1              LDA TEXT_BUFFER,X
                CMP #TextLineEnd
                BEQ :2
                STA NAME_BUFFER,X
                INX
                CPX #charNameLength
                BNE :1
                BEQ NO_DUPES            ; always
:2              LDA #TextSpace
:3              STA NAME_BUFFER,X
                INX
                CPX #charNameLength
                BNE :3

NO_DUPES        LDX #0
:1              STX COUNT
                CPX CURSOR
                BEQ :3
                JSR SET_RCHARDL
                LDY #name
                LDX #0
:2              LDA (CHARDL),Y
                CMP NAME_BUFFER,X
                BNE :3
                INY
                INX
                CPX #charNameLength
                BNE :2
                BEQ :4                  ; always
:3              LDX COUNT
                INX
                CPX ROSTER_COUNT
                BNE :1
                BEQ NO_NAJA             ; always

:4              JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 8;184;"'"
                PictCall DRAW_TRIMMED_NAME
                PictText "' IS USED - TRY ANOTHER"
                PictEnd
                JMP BAD_NAME

NO_NAJA         LDX #0
:1              LDA NAME_BUFFER,X
                CMP NAJA_NAME,X
                BNE GOOD_NAME
                INX
                CPX #4
                BNE :1
                JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 3;184;"NO ONE IS ALLOWED TO USE THAT NAME!!!"
                PictEnd
BAD_NAME        JSR DRAW_PICT
                PictTextAt 237;184;"<SPACE>"
                PictEnd
:4              LDA KEYBRD
                BPL :4
                BIT UNSTROB
                JSR CHECK_ENTER
                BNE :4
                JMP RENAME_LOOP

NAJA_NAME       TXC "NAJA"

GOOD_NAME       LDX CURSOR
                LDA ROSTER_LIST,X
                ORA #%01000000
                STA ROSTER_LIST,X
                BPL :3
                STA :MOD+1
                JSR FIRST_CHAR
:1              LDY #rosterLocation
                LDA (CHARDL),Y
:MOD            EOR #$FF
                AND #%00001111
                BEQ :2
                JSR NEXT_CHAR
                BCC :1
:2              JSR COPY_NAME
                LDX CURSOR
:3              JSR SET_RCHARDL
                LDX CURSOR
                LDY ROSTER_YPNTS,X
                JSR VMOVE_TO
                JSR DRAW_PICT
                PictCall CNAME_TO_TEXT
                PictTextbufX rosterNameX
                PictCall COPY_NAME
                PictCall CNAME_TO_TEXT
                PictTextbufX rosterNameX
                PictEnd
                LDX CURSOR
                JSR ROSTER_CURSOR
                LDX RENAME_MDEF+1
                INX
                CPX ROSTER_COUNT
                BNE :4
                LDX #0
:4              STX RENAME_MDEF+1
                LDA #1                  ; stay on RENAME
                JMP ROSTER_LOOP

COPY_NAME       LDY #name
                LDX #0
:1              LDA NAME_BUFFER,X
                STA (CHARDL),Y
                INY
                INX
                CPX #charNameLength
                BNE :1
                RTS

RENAME_MDEF     DB  maxRosterSize       ; modified
                DB  $00                 ; modified
                DW  ROSTER_CURSOR

;---------------------------------------
