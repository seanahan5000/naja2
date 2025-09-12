
                DUM SCRATCH_PAGE
;
; list of allocated roster locations
;
; xy00iiii
;   x: 1 if in group
;   y: 1 if dirty
;   i: roster index
;
ROSTER_INFO     DS  maxRosterSize

RDIRTY_SECTORS  DS  rosterSectors
                DEND

inGroup         =   %10000000           ; assumed to be high bit
isDirty         =   %01000000
indexMask       =   %00001111

; ROSTER_BITS is a two-byte bitmap of
;   character slots allocated in roster file,
;   found in saved game state

;---------------------------------------

LOAD_ROSTER     LDA #fileSaveGame
                JSR SET_FILE

                ; build initial ROSTER_INFO list
                LDX #0
                STX ROSTER_COUNT
:1              STX COUNT
                TXA
                JSR TEST_ROSTER_BIT
                BEQ :2
                LDX ROSTER_COUNT
                LDA COUNT
                STA ROSTER_INFO,X
                INC ROSTER_COUNT
:2              LDX COUNT
                INX
                CPX #maxRosterSize
                BNE :1

                ; check for empty roster, just in case
                LDA ROSTER_COUNT
                BEQ :7

                ; read the minimum range of allocated sectors into roster buffer
                LDA ROSTER_INFO+0
                LSR
                STA RTEMP
                CLC
                ADC #stateSectors
                JSR SEEK_FILE
                LDA #>ROSTER_BUFFER
                CLC
                ADC RTEMP
                TAY
                LDX ROSTER_COUNT
                LDA ROSTER_INFO-1,X
                LSR
                SEC
                SBC RTEMP
                CLC
                ADC #1
                JSR READ_FILE

                ; walk through current group, if any
                JSR FIRST_CHAR
                BCS :7

                ; find character in ROSTER_INFO by matching its rosterLocation
:3              LDY #rosterLocation
                LDA (CHARDL),Y
                AND #%00001111
                STA RTEMP
                LDY #0
:4              LDA ROSTER_INFO,Y
                CMP RTEMP
                BEQ :5
                INY
                CPY ROSTER_COUNT
                BNE :4

                ; update its inGroup and dirty status in ROSTER_INFO
:5              LDA #inGroup!isDirty
                ORA ROSTER_INFO,Y
                STA ROSTER_INFO,Y

                ; copy char data to roster buffer
                TYA
                TAX
                JSR SET_RCHARPTR
                LDY #$7F
:6              LDA (CHARDL),Y
                STA (CHARPTR),Y
                DEY
                BPL :6

                JSR NEXT_CHAR
                BCC :3
:7              RTS
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
WRITE_ROSTER    LDA #0
                LDY #rosterSectors-1
:1              STA RDIRTY_SECTORS,Y
                DEY
                BPL :1

                LDY #0
:2              LDA ROSTER_INFO,Y
                TAX
                AND #isDirty
                BEQ :3
; if dirty entry found, force ENTRY_SIZE non-zero
                INC ENTRY_SIZE
                TXA
                EOR #isDirty
                STA ROSTER_INFO,Y
                TXA
                AND #indexMask
                LSR
                TAX
                INC RDIRTY_SECTORS,X
:3              INY
                CPY ROSTER_COUNT
                BNE :2

; if group was empty on entering group assembly and
;   no roster entries are dirty, skip all writing
                LDA ENTRY_SIZE
                BEQ :6

                LDA #fileSaveGame
                JSR SET_FILE
                LDA #stateSectors
                LDY #>GAME_STATE
                JSR WRITE_FILE

                LDA #>ROSTER_BUFFER
                STA CHARPTR+1
                LDY #0
:4              STY RTEMP
                LDA RDIRTY_SECTORS,Y
                BEQ :5
                TYA
                CLC
                ADC #stateSectors
                JSR SEEK_FILE
                LDA #1
                LDY CHARPTR+1
                JSR WRITE_FILE
:5              INC CHARPTR+1
                LDY RTEMP
                INY
                CPY #rosterSectors
                BNE :4
:6              RTS

;---------------------------------------

rosterNameX     =   8+6

DRAW_ROSTER
                ; *** SHOW ROSTER UPDATING? ***
                ; *** CHECK FOR IT CURRENTLY BEING VALID? ***

                JSR DRAW_PICT
                ; *** set page ***
                PictClearPage

                ; *** redo all this spacing ***

                ; *** add/use PictTextAtX ***
                PictTextAt 8+6;2;"NAME"
                PictTextAt 71+6;2;"PROFESSION"
                PictTextAt 140+6;2;"RACE"
                PictTextAt 188+6;2;"LEVEL"
                PictTextAt 227+6;2;"STATUS"

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
                LDA ROSTER_INFO,X
;               AND #inGroup
                BPL :2
                JSR ROSTER_MARK
:2              JSR DRAW_PICT
                PictCall CNAME_TO_TEXT
                PictTextbufX rosterNameX
                PictCall CPROF_TO_TEXT
                PictTextbufX 74+6
                PictCall CRACE_TO_TEXT
                PictTextbufX 140+6
                PictCall CLEV_TO_TEXT_R
                PictTextbufX 185+6
                PictCall CSTATUS_TO_TEXT_C
                PictTextbufX 218+6
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
                STA ADDREM_MDEF+1
                STA RENAME_MDEF+1

;               LDA #0                  ; start on ADD-REMOVE
ROSTER_LOOP     STA CURSOR
                JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 48;184;"ADD-REMOVE   CHANGE-NAME   LEAVE"
                PictEnd
                JSR DRAW_HARROW
                JMP HKEYLOOP

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
                LDX #2
:2              STX CURSOR
                JSR DRAW_HARROW
                JMP HKEYLOOP

HRIGHT          JSR DRAW_HARROW
                LDX CURSOR
                INX
                CPX #3
                BNE :1
                LDX #0
:1              STX CURSOR
                JSR DRAW_HARROW
                JMP HKEYLOOP

HENTER          JSR DRAW_HARROW
                LDX CURSOR
                BEQ ADD_REMOVE
                DEX
                BEQ TO_RENAME
HCANCEL         JMP MAIN_LOOP1
TO_RENAME       JMP DO_RENAME

;---------------------------------------

ADD_REMOVE      JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 24;184;"ADD-REMOVE WHICH GROUP MEMBER?"
                PictTextAt 234;184;"C>ANCEL"
                PictEnd
                JSR BUILD_LEGALS
                LDA ROSTER_COUNT
                STA ADDREM_MDEF+0
                LDX #<ADDREM_MDEF
                LDY #>ADDREM_MDEF
                JSR MENU_INIT
                JSR MENU_SET_CANCEL
                JSR MENU_SELECT
                BCC :4
                INX
                CPX ROSTER_COUNT
                BNE :1
                LDX #0
:1              STX ADDREM_MDEF+1
                LDX CURSOR
                LDA ROSTER_INFO,X
;               AND #inGroup
                BPL :2
                JSR REMOVE_RCHAR
                JMP :3
:2              JSR ADD_RCHAR
:3              LDX CURSOR
                JSR ROSTER_MARK
:4              LDA #0                  ; stay on ADD-REMOVE
                JMP ROSTER_LOOP

ADDREM_MDEF     DB  maxRosterSize       ; modified
                DB  $00                 ; modified
                DW  ROSTER_CURSOR

;---------------------------------------

ROSTER_CURSOR   LDY ROSTER_YPNTS,X
                JSR VMOVE_TO
                LDA ROSTER_INFO,X
;               AND #inGroup
                BMI :1
                LDX #3
                JSR HMOVE_TO
                JSR DRAW_MARKER_TILE
:1              LDX #8
                JSR HMOVE_TO
                JMP DRAW_MARKER_TIP_TILE

ROSTER_MARK     LDY ROSTER_YPNTS,X
                LDX #3
                JSR MOVE_TO
                JMP DRAW_MARKER_TILE

ROSTER_YPNTS    DB  14,23,32,41
                DB  50,59,68,77
                DB  86,95,104,113
                DB  122,131,140,149

DRAW_HARROW     LDY CURSOR
                LDX :HARROW_XPNTS,Y
                LDY #$B8
                JSR MOVE_TO
                LDX #<:HARROW_SHAPE
                LDY #>:HARROW_SHAPE
                JMP DRAW_TILE

:HARROW_XPNTS   DB  40,118,202

:HARROW_SHAPE   DB  %00000000
                DB  %00000011
                DB  %00001110
                DB  %00111110
                DB  %00001110
                DB  %00000011
                DB  %00000000

;---------------------------------------
;
; Build LEGALS list for adding or removing to/from group
;
;   Can't add robot until its cybernate is added
;   Can't remove a cybernate until its robot is removed
;
BUILD_LEGALS    LDX #0
:1              STX COUNT
                LDA ROSTER_INFO,X
;               AND #inGroup
                BPL :ADDS
;
; prevent remove if this is cybernate and its robot is in the group
;
:REMOVES        JSR SET_RCHARDL
                LDY #profrace
                LDA (CHARDL),Y
                AND #$F0
                CMP #cybernate*16
                BNE :INCLUDE
                LDY #roboCyberLink
                LDA (CHARDL),Y
                BEQ :INCLUDE
                JSR IN_GROUP
                BCC :INCLUDE
                LDY #-1
                BCS :EXCLUDE            ; always
;
; prevent add if group is already full
;
:ADDS           LDY #-1
                LDA GRPNUMB
                CMP #maxGroupSize
                BEQ :EXCLUDE
;
; prevent add if this is a robot and its cybernate is not in group
;
                JSR SET_RCHARDL
                LDY #profrace
                LDA (CHARDL),Y
                BPL :INCLUDE
                LDY #roboCyberLink
                LDA (CHARDL),Y
                JSR IN_GROUP
                LDY #-1
                BCC :EXCLUDE
:INCLUDE        LDY #0
:EXCLUDE        LDX COUNT
                TYA
                STA LEGALS,X
                INX
                CPX ROSTER_COUNT
                BNE :1
                RTS
;
; find roster location value in list and in group
;
IN_GROUP        STA :MOD+1
                LDX #0
:1              LDA ROSTER_INFO,X
:MOD            EOR #$FF
                AND #indexMask
                BEQ :2
                INX
                CPX ROSTER_COUNT
                BNE :1
                BEQ :3                  ; always
:2              SEC
                LDA ROSTER_INFO,X
;               AND #inGroup
                BMI :4
:3              CLC
:4              RTS

;---------------------------------------
;
; On entry:
;   X: packed roster character index
;
ADD_RCHAR       LDA ROSTER_INFO,X
                ORA #inGroup
                STA ROSTER_INFO,X
                JSR SET_RCHARPTR
                LDA GRPNUMB
                JSR SET_CHAR
                LDY #$7F
:1              LDA (CHARPTR),Y
                STA (CHARDL),Y
                DEY
                BPL :1
                INC GRPNUMB
                ; TODO: should this be done here or elsewhere?
                ; JSR CALC_ALL
                RTS
;
; On entry:
;   X: packed roster character index
;
REMOVE_RCHAR    LDA ROSTER_INFO,X
                AND #inGroup!$FF
                STA ROSTER_INFO,X
                STA RTEMP
                JSR FIRST_CHAR
:1              LDY #rosterLocation
                LDA (CHARDL),Y
                EOR RTEMP
                AND #%00001111
                BEQ :2
                JSR NEXT_CHAR
                BCC :1
:2              LDA CHARDL
                STA CHARPTR+0
                LDA CHARDH
                STA CHARPTR+1
                JSR NEXT_CHAR
                BCS :4
                LDY #$7F
:3              LDA (CHARDL),Y
                STA (CHARPTR),Y
                DEY
                BPL :3
                BMI :2                  ; always
:4              DEC GRPNUMB
                RTS
;
; On entry:
;   X: packed roster list index
;
; On exit:
;   X: pointing to character in roster buffer (LOW)
;   Y: pointing to character in roster buffer (HIGH)
;
SET_RCHAR       LDA ROSTER_INFO,X
                AND #indexMask
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
;   X: packed roster list index
;
SET_RCHARDL     JSR SET_RCHAR
                STX CHARDL
                STY CHARDH
                RTS
;
; On entry:
;   X: packed roster list index
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
                PictCall DRAW_CNAME
                PictText "' TO WHAT? "
                PictEnd

                JSR ASK_CHAR_NAME
                BCS NO_DUPES
                LDX CURSOR
                JSR ROSTER_CURSOR
                LDA #1                  ; stay on RENAME
                JMP ROSTER_LOOP

NO_DUPES        JSR DUPE_NAME_CHECK
                BCC NO_NAJA

                JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 8;184;"'"
                PictCall DRAW_CNAME
                PictText "' IS USED - TRY ANOTHER"
                PictEnd
                JMP BAD_NAME

NO_NAJA         JSR IS_NAJA_NAME
                BCC GOOD_NAME
                JSR DRAW_PICT
                PictClear 0;184;40;191
                PictTextAt 3;184;"NO ONE IS ALLOWED TO USE THAT NAME!!!"
                PictEnd
BAD_NAME        JSR DRAW_PICT
                PictTextAt 237;184;"<SPACE>"
                PictEnd
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB
                JSR CHECK_ENTER
                BNE :1
                JMP RENAME_LOOP

GOOD_NAME       LDX CURSOR
                LDA ROSTER_INFO,X
                ORA #isDirty
                STA ROSTER_INFO,X
;               AND #inGroup
                BPL :3
                STA RTEMP
                JSR FIRST_CHAR
:1              LDY #rosterLocation
                LDA (CHARDL),Y
                EOR RTEMP
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
