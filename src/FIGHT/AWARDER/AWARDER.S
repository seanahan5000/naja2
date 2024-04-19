*-------------------------------------------------
* It is assumed that on entry to this code,
*   battle-only illnesses have already been cured
*   and characters are in their normal positions.
*
* Group gets credit and experience for all
*   aliens killed even if the group runs away
*   before all of the aliens are killed.
*
* GROUP_STATUS is setup by Fight Narrator
*   AB......
* A = Run away group
* B = All dead, broken, abandoned
*
*-------------------------------------------------

; TODO: put in common file
CONTROL_MODULE  =   $7000
SET_CONTROL     =   $7001
MAP_MODULE      =   $8000

AWARDER         JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictSetGreen
                PictRect $01;$47;$115;$BF
                PictMoveTo $01;$85
                PictLineTo $115;$85
                PictTextAt 40;80;"ALIENS"
                PictImage AWARD_IMAGES
                PictEnd

                LDA #statsShielding+statsStatus
                JSR DRAW_STATS_BOX_A

                LDA TAKEN_COUNT
                STA FOUND_COUNT
                LDX #19
:1              LDA TAKEN_ITEMS,X
                STA FOUND_ITEMS,X
                DEX
                BPL :1

            do 0
            else
                ; It looks like odds of finding equipment and what equipment
                ;   can be found was in the middle of being changed but not
                ;   finished.  This temporary code makes it at least work.
                ;   (It must be done before other files are loaded and ALIEN_HEAP
                ;   is overwritten.)
                LDY #aFindingOdds
                LDA (ALIEN_PTR),Y
                STA FINDODD_ALIEN
                LDY #aFindingGroup
                LDA (ALIEN_PTR),Y
                STA FINDGRP_ALIEN
            fin

                ; must finish before fight shared overwritten
                JSR TOTALS_OUT

                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                LDA #fileFightHalls
                LDY #$60
                JSR LOAD_FILE

                LDX SHELL
                LDA :FILES,X
                PHA
                LDA DISK_SIDES,X
                JSR SET_DISK_SIDE
                LDA #IS_SPINNING+STOP_SPINNING
                JSR SET_NEXT_ON_OFF
                PLA
                LDY #>CONTROL_MODULE
                JSR LOAD_FILE
                JSR SET_CONTROL

                ; preload map code
                LDA #fileMap
                LDY #>MAP_MODULE
                JSR LOAD_FILE

                BIT GROUP_STATUS
                BMI :3
                JSR RESET_CHRLIST       ; find a good android
                LDA #android*16
                JSR CSCAN_PROF
                LDX #<FIND_GOODROID
                LDY #>FIND_GOODROID
                JSR CSCAN_COMMON
                STX THE_ANDROID
                BCC :2
                TXA
                JSR SET_CHAR
                JSR PICK_EQUIPMENT
:2              LDA ATOTAL1
                ORA ATOTAL2
                ORA ATOTAL3
                BNE :4
:3              JSR DRAW_PICT
                PictTextAt 43;149;"THERE ARE NO REMAINS THAT CAN BE"
                PictTextAt 52;158;"SCANNED FOR USABLE EQUIPMENT."
                PictEnd
                JMP :7

:4              LDA THE_ANDROID
                BPL :5
                JSR DRAW_PICT
                PictTextAt_ 13;149
                TXC "NO ONE IN THE GROUP IS CAPABLE OF SCANNING\n"
                TXT "THE REMAINS FOR USABLE EQUIPMENT."
                PictEnd
                JMP :7

:5              LDA ROOM_FOUND
                BNE :6
                JSR DRAW_PICT
                PictTextAt_ 13;144
                TXC "ALL GROUP MEMBERS ARE NOW CARRYING AS MUCH\n"
                TXC "AS POSSIBLE AND WILL NOT BE ABLE TO KEEP\n"
                TXT "ANY MORE NEW EQUIPMENT."
                PictEnd
                BNE :7                  ; always

:6              LDA FOUND_COUNT
                BNE HAVE_ROOM
                JSR DRAW_PICT
                PictMoveTo 13;149
                PictCall DRAW_CNAME
                PictText " HAS SCANNED THROUGH THE REMAINS"
                PictTextAt 13;158;"BUT HAS NOT FOUND ANY USABLE EQUIPMENT."
                PictEnd

:7              JSR DRAW_PICT
                PictTextAt 118;180;"<SPACE>"
                PictShowPage
                PictEnd

                JSR SPACE_AND_CLEAR
                JMP ALL_DONE

:FILES          DB  0
                DB  fileControl17
                DB  fileControl15
                DB  fileControl13
                DB  fileControl11
                DB  fileControl9

HAVE_ROOM       JSR DRAW_PICT
                PictTextAt 166;138;"NEW EQUIPMENT:"
                PictMoveTo $AC;$93
                PictEnd

                LDA #8
                JSR SET_TEXT_HEIGHT

                LDA #0
                STA :MOD1+1
                STA YCOUNT
:1              LDX #0
:MOD1           LDY #$FF
:2              LDA FOUND_ITEMS,Y
                STA ETABLE,X
                INY
                INX
                CPX #4
                BNE :2
                STY :MOD1+1
                JSR ETABLE_TO_TEXT
                JSR DRAW_TEXTBUF_RET
                INC YCOUNT
                LDA YCOUNT
                CMP FOUND_COUNT
                BNE :1

                LDA #0
                JSR SET_TEXT_HEIGHT

EKDONE          JSR DRAW_PICT
                PictMoveTo 10;138
                PictCall DRAW_CNAME
                PictText " HAS SCANNED"
                PictSetTextHeight 8
                PictTextAt_ 10;146
                TXC "THROUGH THE REMAINS\n"
                TXC "AND HAS DISCOVERED\n"
                TXC "EQUIPMENT THAT MIGHT\n"
                TXT "BE_USABLE."
                PictTextAt 46;180;"<SPACE>"
                PictShowPage
                PictCall GET_SPACE_ENTER
                PictClear $01;$86;$15;$BF
                PictSetBlack1
                PictMoveTo $03;$44
                PictLineTo $37;$44
                PictMoveTo $03;$47
                PictLineTo $37;$47
                PictSetGreen
                PictMoveTo $01;$45
                PictLineTo $01;$46
                PictMoveTo $37;$44
                PictLineTo $37;$4C
                PictLineTo $03;$4C
                PictTextAt 16;68;"NOBODY"
                PictTextAt 16;150;"SELECT GROUP MEMBER"
                PictTextAt 28;159;"TO RECEIVE THIS"
                PictTextAt 19;168;"PIECE OF EQUIPMENT"
                PictTextAt 46;180;"<SPACE>"
                PictEnd

                LDA #0
                STA EPOINT
                STA CURSOR
:LOOP1          JSR FIND_ROOM
                JSR ECURSIT
                LDA CURSOR
                STA TO_CDEF+1
                LDX #<TO_CDEF
                LDY #>TO_CDEF
                JSR MENU_INIT
                JSR MENU_SELECT
                CPX #7
                BEQ :SKIPA
                TXA
                JSR SET_CHAR
                JSR RESET_EQLIST
                JSR ESCAN_PUTABLE
                LDA EPOINT
                ASL
                ASL
                TAX
                LDA #4
                STA TEMP
:LOOP3          LDA FOUND_ITEMS,X
                STA (CHARDL),Y
                INX
                INY
                DEC TEMP
                BNE :LOOP3
:SKIPA          JSR ECURS2
                INC EPOINT
                LDA EPOINT
                CMP FOUND_COUNT
                BNE :LOOP1

                JSR DRAW_PICT
                PictClear $01;$86;$27;$BF
                PictEnd

                JSR FIND_ROOM
                LDA ROOM_FOUND
                BEQ :4
                JMP NO_FULL

:4              JSR DRAW_PICT
                PictTextAt_ 13;144
                TXC "ALL GROUP MEMBERS ARE NOW CARRYING AS MUCH\n"
                TXC "AS POSSIBLE AND WILL NOT BE ABLE TO KEEP\n"
                TXT "ANY MORE NEW EQUIPMENT."
                PictTextAt 118;180;"<SPACE>"
                PictCall GET_SPACE_ENTER
                PictEnd

NO_FULL         JSR DRAW_PICT
                PictClear 0;68;8;77
                PictSetGreen
                PictMoveTo 1;68
                PictLineTo 55;68
                PictMoveTo 1;76
                PictLineTo 1;71
                PictLineTo 55;71
                PictClear $01;$86;$27;$BF
                PictEnd

ALL_DONE        LDA #0
                STA :MOD1+1
                JSR FIRST_CHAR
:1              JSR BAD_STATUS
                BEQ :2
                LDY #status
                LDA (CHARDL),Y
                AND #critical
                BEQ :4
                JSR DRAW_PICT
                PictMoveTo 13;153
                PictCall DRAW_CNAME
                PictText " NEEDS MEDICAL ATTENTION...QUICK!"
                PictEnd
                BNE :3                  ; always
:2              JSR DRAW_PICT
                PictMoveTo 13;153
                PictCall DRAW_CNAME
                PictText " NEEDS TO BE COMPRESSED."
                PictEnd
                DEC :MOD1+1
:3              JSR DRAW_PICT
                PictTextAt 118;180;"<SPACE>"
                PictEnd
                JSR SPACE_AND_CLEAR
:4              JSR NEXT_CHAR
                BCS :5
                JMP :1
:5

:MOD1           LDA #$FF
;                 BMI SEND_TO_CAMP

                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
;                 LDA DIRHOLD
;                 STA DIRECTN
                PictCall GET_NSEW
                PictCall DRAW_HALL
                PictShowPage
                PictEnd
                JMP HALL_KEYS

; SEND_TO_CAMP    JSR MOVETO1
;                 STA PRIMARY
;                 JMP DEAD_VECTOR

*-------------------------------

TO_CDEF         DB  $08
                DB  0                   ; modified
                DW  :TO_CURS

:TO_CURS        LDX CURSOR
                LDY YPOINTS,X
                CPX #7
                BNE :SKIPA
                DEY
                DEY
:SKIPA          LDX #3
                JMP DRAW_ARROW

*-------------------------------

FIND_GOODROID   LDY #status
                LDA (CHARDL),Y
                AND #%00111111
                LDX #1
                CMP #dead
                BEQ :SKIPA
                CMP #blind
                BEQ :SKIPA
                CMP #confused
                BEQ :SKIPA
*** MAYBE CHECK FOR OTHER STATUSES HERE
                DEX
:SKIPA          TXA
                RTS

*-------------------------------

FIND_ROOM       JSR RESET_CHRLIST
                LDA #0
                STA CHAR_LIST+7
                STA ROOM_FOUND
                LDX #<MY_PUTABLE
                LDY #>MY_PUTABLE
                JMP CSCAN_COMMON

MY_PUTABLE      JSR RESET_EQLIST
                JSR ESCAN_PUTABLE
                LDY #1
                BCC :SKIPB
                CLC
                ADC ROOM_FOUND
                CMP #maxfind
                BCC :SKIPA
                LDA #maxfind
:SKIPA          STA ROOM_FOUND
                DEY
:SKIPB          TYA
                RTS

*-------------------------------

SPACE_AND_CLEAR JSR GET_SPACE_ENTER
                JSR DRAW_PICT
                PictClear $01;$86;$27;$BF
                PictEnd
                RTS

*-------------------------------

ECURSIT         LDX EPOINT
                LDY EYPNTS,X
                LDX #$A1
                JSR DRAW_MARKER
ECURS2          LDX EPOINT
                LDY EYPNTS,X
                LDX #166
                LDX #<:MARKER_TIP
                LDY #>:MARKER_TIP
                JMP DRAW_TILE

:MARKER_TIP     DB  %00000000
                DB  %00000000
                DB  %00000011
                DB  %00001111
                DB  %00000011
                DB  %00000000
                DB  %00000000

EYPNTS          DB  $93,$9B,$A3
                DB  $AB,$B3

*-------------------------------

AWARD_IMAGES
:SKULL          DB  $10,$4A,$05,$12
                HEX 88303078408C40783030407078787C1C651D181C7C784036
                HEX 377140827F910C770C0C1673737F1E12697F1E820307070F
                HEX 0E696E060E0F07821B7B63848803030790070303

:CREDITS        DB  $17,$4E,$04,$0B
                HEX 86022A822A02867E7F0707578B07077F7E1F1F842A822A84
                HEX 1F1F86040582050486

:EXPERIENCE     DB  $1E,$4E,$05,$0B
                HEX 86022A822A02867E7F07897F7F07077F7E7377674727072B
                HEX 406777736060713B5F0E5F3B716060010182202A822A2082
                HEX 0101

                DB  $FF

*-------------------------------
