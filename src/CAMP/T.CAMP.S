**********************************************************
*                                                        *
*              MOTHERSHIP/TRACC CAMP ROUTINE             *
*                                                        *
*                Written 02/21/1987                      *
*              Rewritten 08/06/2022                      *
*                                                        *
**********************************************************

        do MINI_CAMP
ENTER_CAMP      ENT
                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_STATS_BOX
                PictCall COPY_DOWN
                PictSwap 0;191;40;122
                PictSetPage1
                PictEnd

                LDA SHELL
                BNE :TRACC

:MOTHER         JSR DRAW_PICT
                PictSetBlue
                ; TODO: this will eventually need to be tested in
                ;	Mothership and adjusted accordingly
                ; TODO: too close to edge of byte
                PictRect 106;14;174;35
                PictTextAt 123;17;()-
                USR (MEMBERS\n)-
                USR (LEAVE)
                PictEnd
                LDA #0
                STA CCURPOS_MS
                LDX #<CAMP_MENU_MS
                LDY #>CAMP_MENU_MS
                BNE :COMMON             ; always

:TRACC          JSR DRAW_PICT
                PictSetViolet
                ; TODO: too close to edge of byte
                PictRect 106;14;174;53
                PictTextAt 123;17;()-
                USR (MEMBERS\n)-
                USR (FORMAT\n)-
                USR (CODEX\n)-
                USR (LEAVE)
                PictEnd
                LDA #0
                STA CCURPOS_TRACC
                LDX #<CAMP_MENU_TRACC
                LDY #>CAMP_MENU_TRACC
:COMMON         JSR MENU_INIT
                JSR MENU_SELECT
                JMP MENU_TARGET
        else
ENTER_CAMP      ENT
                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_STATS_BOX
                PictCall COPY_DOWN
                PictSwap 0;191;40;122
                PictSetPage1
                PictSetViolet
                PictRect $72;$21;$A6;$3F
                PictTextAt 131;36;(MORE\nFLIP\nEXIT)
                PictEnd
                LDX #<STATS_MENU
                LDY #>STATS_MENU
                JSR MENU_INIT
                JSR MENU_SELECT
                JMP MENU_TARGET
        fin

; copy stats box from normal top-of-screen location to bottom of screen
; TODO: generalize this if anything other than CAMP also does it

COPY_DOWN       LDX #0
:1              JSR SET_SOURCE_LINE
                LDA LOBYTES+122,X
                STA DESTINL
                LDA HIBYTES+122,X
                STA DESTINH
                JSR COPY_FULL_LINE
                INX
                CPX #70
                BNE :1
                RTS

        do MINI_CAMP

*-------------------------------

CAMP_MENU_MS    DB  $82
CCURPOS_MS      DB  $00
                DW  CAMP_CURS
                DW  :CAMP_JUMPS_MS

:CAMP_JUMPS_MS  DW  TO_MEMBERS
                DW  GO_LEAVE

CAMP_MENU_TRACC DB  $84
CCURPOS_TRACC   DB  $00
                DW  CAMP_CURS
                DW  :CAMP_JUMPS_T

:CAMP_JUMPS_T   DW  TO_MEMBERS
                DW  TO_REFORMAT
                DW  TO_ALIENS
                DW  GO_LEAVE

CAMP_CURS       LDY CAMP_YPNTS,X
                LDX #109
                JMP DRAW_ARROW

CAMP_YPNTS		DB	17,26,35,44

*-------------------------------

; TODO: reconcile with full leave
GO_LEAVE        JSR DRAW_PICT
				PictClear 15;14;25;54
                PictSwap 0;122;40;191
                PictEnd
                RTS

TO_MEMBERS
RECAMP
CAMP_MARKER
COPTION
				RTS

        else

*-------------------------------

STATS_MENU      DB  $83             ; min 0, max 2, clear LEGALS
                DB  $00
                DW  :STATS_CURS
                DW  :STATS_JUMPS

:STATS_CURS     LDY :YPNTS,X
                LDX #$75
                JMP DRAW_ARROW

:YPNTS          DFB $24,$2D,$36

:STATS_JUMPS    DW  STATS_MORE
                DW  STATS_FLIP
                DW  STATS_EXIT

*-------------------------------

STATS_EXIT      JSR DRAW_PICT
                PictClear $10;$21;$18;$40
                PictSwap 0;122;40;191
                PictEnd
                RTS

STATS_FLIP      JSR DRAW_PICT
        do SMALL_GROUP
                PictVMoveTo 125
        else
                PictVMoveTo 124
        fin
                PictEnd
                JSR FLIP_STATS
                JSR MENU_SELECT
                JMP MENU_TARGET

FORCE_CAMP      JSR DRAW_PICT
				PictSetPage2
				PictClearPage
				PictEnd
                JSR DRAW_STATS_BOX

STATS_MORE      LDA SHELL
                BEQ :1
                ; JSR SET_CAMPFILES
:1
				JSR DRAW_PICT
                PictSetPage2
                PictClear 0;121;40;192
                PictCall CAMP_MENU_BOX
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                LDA #0				; TRADE
COPTION			STA CCURPOS_MS
                STA CCURPOS_TRACC
                BPL CMENU			; always

RECAMP			BIT	UNSTROB
				JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall DRAW_STATS_BOX
                PictCall CAMP_MENU_BOX
                PictShowPage
                PictEnd

CMENU         	LDA SHELL
                BNE :TRACC
:MOTHER			LDX #<CAMP_MENU_MS
                LDY #>CAMP_MENU_MS
                BNE :COMMON			; always
:TRACC			LDX #<CAMP_MENU_TRACC
                LDY #>CAMP_MENU_TRACC
:COMMON			JSR MENU_INIT

; TODO: make it possible use <escape> to directly leave camp menu

                JSR MENU_SELECT
                STX CCURPOS_MS
                STX CCURPOS_TRACC
                JSR CAMP_MARKER
:1              JMP MENU_TARGET

CAMP_MENU_BOX   LDA SHELL
				BNE :TRACC

:MOTHER			JSR DRAW_PICT
                PictSetBlue
                ; PictRect $3A;$7C;$DC;$AE
                PictRect $3A;$7C;$DC;$A5
                PictTextAt 81;128;()-
                USR (TRADE\n)-
                ; USR (POOL_CREDITS\n)-
                USR (INDIVIDUAL_STATISTICS\n)-
                USR (FLIP_STATS_TABLE\n)-
                USR (LEAVE)
                PictEnd
                RTS

:TRACC			JSR DRAW_PICT
                PictSetOrange
                PictRect $3B;$7C;$DD;$B7
                PictTextAt 81;128;()-
                USR (TRADE\n)-
                USR (REFORMAT_GROUP\n)-
                USR (INDIVIDUAL_STATISTICS\n)-
                USR (ALIEN_COMPENDIUM\n)-
                USR (FLIP_STATS_TABLE\n)-
                USR (LEAVE)
                PictEnd
                RTS

CAMP_MARKER     LDY CAMP_YPNTS,X
                LDX #$46
                JMP DRAW_MARKER

*-------------------------------

CAMP_MENU_MS    DB  $84
CCURPOS_MS      DB  $00
                DW  CAMP_CURS
                DW  :CAMP_JUMPS_MS

:CAMP_JUMPS_MS  DW  TO_TRADE
                DW  TO_ISTATS
                DW  GOFLOP
                DW  GOLEAVE

CAMP_MENU_TRACC DB  $86
CCURPOS_TRACC   DB  $00
                DW  CAMP_CURS
                DW  :CAMP_JUMPS_T

:CAMP_JUMPS_T   DW  TO_TRADE
                DW  TO_REFORMAT
                DW  TO_ISTATS
                DW  TO_ALIENS
                DW  GOFLOP
                DW  GOLEAVE

CAMP_CURS       LDY CAMP_YPNTS,X
                LDX #$43
                JMP DRAW_ARROW

CAMP_YPNTS		DB	128,137,146
				DB	155,164,173
				DB	182

*-------------------------------

TO_TRADE		JSR BANK_1
				JMP TRADE

GOFLOP          JSR DRAW_PICT
        do SMALL_GROUP
                PictVMoveTo 3
        else
                PictVMoveTo 2
        fin
                PictEnd
                JSR FLIP_STATS
                LDX CURSOR
                JSR CAMP_MARKER
                JSR MENU_SELECT
		        JSR CAMP_MARKER
                JMP MENU_TARGET

GOLEAVE			LDA	SHELL
				BEQ EXIT_CAMP
				; JSR LOOSE_ENDS
EXIT_CAMP		JSR	DRAW_PICT
				PictSetPage2
				PictClearPage
				PictCall DRAW_HALL
				PictShowPage
				PictSetPage1
				PictCopyToPage
				PictShowPage
				PictEnd
				RTS

TO_ISTATS		JSR DRAW_PICT
		do SMALL_GROUP
				PictTextAt 16;71;(CANCEL)
		else
				PictTextAt 16;70;(CANCEL)
		fin
				PictTextAt 63;96;(INDIVIDUAL_STATS_FOR_WHOM?)
				PictEnd
				JSR	PICK_CHAR
				CPX #7
				BEQ	:CANCEL
				TXA
				JSR	SET_CHAR
				JSR	MENU_DRAW_CURSOR
				JMP	DOSTATS

:CANCEL			JSR DRAW_PICT
		do SMALL_GROUP
                PictClear 2;71;8;78
        else
                PictClear 2;70;8;77
        fin
                PictClear 9;96;32;103
                PictEnd
                ; TODO: clean this up after switch to JSR MENU_SELECT
                LDX CCURPOS_MS
				JSR CAMP_MARKER
                JMP	CMENU

*-------------------------------

; caller has already set Y position
FLIP_STATS      LDA SELECT
                LDX SHELL
                BNE :1
                AND #$03
                STA SELECT_FLIP
                EOR #$03
                BPL :2					; always
:1				STA SELECT_FLIP
				EOR #$C3
:2				PHA
				LDA SELECT_FLIP
				JSR STATS_HEADER2
				PLA
				PHA
				JSR STATS_HEADER2
                JSR DRAW_PICT
        do SMALL_GROUP
                PictVMove 11
        else
                PictVMove 10
        fin
                PictEnd
                JSR FIRST_CHAR
:3				LDA SELECT_FLIP
				JSR STATS_LINE2
				PLA
				PHA
				JSR STATS_LINE2
                JSR DRAW_PICT
        do SMALL_GROUP
                PictVMove 9
        else
                PictVMove 8
        fin
                PictEnd
                JSR NEXT_CHAR
                BCC :3
                PLA
                STA SELECT
                RTS

        fin ; MINI_CAMP

PICK_CHAR		JSR	RESET_CHRLIST
				JSR	PRE_ARROW
				JMP	MENU_SELECT

*-------------------------------

PRE_ARROW		LDA #$00
		do SMALL_GROUP
				STA LEGALS+7		; TODO: eventually adjust
		else
				STA LEGALS+7
		fin
				LDX	#<:PRE_DEF
				LDY	#>:PRE_DEF
				JMP	MENU_INIT

:PRE_DEF		DB	$0B
				DB	$00
				DW	:PRE_CURS

:PRE_CURS		LDY	YPOINTS,X
				LDX	#$03
				JMP	DRAW_ARROW

; NOTE: was in KEY.COMMONS.S
YPOINTS			ENT
		do SMALL_GROUP
				DB  14,23,32
				DB	41,50,59
				DB	0					; TODO: eventually remove
				DB	71					; cancel
		else
				DB	$0C,$14,$1C
				DB	$24,$2C,$34
				DB	$3C
				DB	$46					; cancel
		fin

*-------------------------------

TO_REFORMAT		LDA #fileReformat
                CMP REFORMAT_FILE
                BEQ :1
                LDY #>REFORMAT_FILE
                JSR LOAD_FILE
:1				JMP REFORMAT

TO_ALIENS       LDA #fileAlienId
                CMP ALIEN_ID_FILE
                BEQ :1
                LDY #>ALIEN_ID_FILE
                JSR LOAD_FILE
:1              JMP IDENTIFIED_ALIENS

*-------------------------------

            DO 0
LOOSE_ENDS
*** Notify if any characters in group are critical
				JSR FIRST_CHAR
:LOOP1			LDY	#status
				LDA	(CHARDL),Y
				AND	#critical
				BNE	:SKIPA
				JSR NEXT_CHAR
				BCC :LOOP1
				BCS	LOOK_FOR_DEAD		; always

:SKIPA			LDX	#<CRIT_BOX
				LDY	#>CRIT_BOX
				JSR	INIT_BOX
				LDA	#$40
				STA	PAGE
				JSR	CLEAR_OUTSIDE
				JSR	DRAW_BOX
				JSR	SWAP_BOX
				LDA	#$20
				STA	PAGE
:LOOP2			JSR	CLEAR_INSIDE
				LDX	#<TCRITCAMP+3
				LDY	#>TCRITCAMP+3
				JSR	FLUSH_NAME

				LDY	#$11
				JSR	TEXTER
; TCRITCAMP		PLOTAT	64;89;(XXXXXXXXXX_NEEDS_MEDICAL)
; 				PLOTAT	64;97;(ATTENTION...QUICK!)+

				JSR	SPACE_KEY

:LOOP3			JSR NEXT_CHAR
				BCS :SKIPC
				LDY	#status
				LDA	(CHARDL),Y
				AND	#critical
				BEQ	:LOOP3
				BNE	:LOOP2				; always

:SKIPC			JSR	SWAP_BOX
*** Ask them to verify that they want to leave character/s
***   that are dead
LOOK_FOR_DEAD	JSR	DEAD_LOOKER
				INX
				BNE	:1
				JMP	FILL_FRONT
:1				LDX	#<DEAD_BOX
				LDY	#>DEAD_BOX
				JSR	INIT_BOX
				LDA	#$40
				STA	PAGE
				JSR	CLEAR_OUTSIDE
				JSR	DRAW_BOX

				LDY	#$12
				JSR	TEXTER
; TDEADCAMP		PLOTAT	40;81;(DEAD_CADETS_AND_BROKEN_ROBOTS_THAT)
; 				PLOTAT	40;89;(ARE_LEFT_BEHIND,_UNCOMPRESSED_WILL)
; 				PLOTAT	40;97;(BE_UNRECOVERABLE.__ARE_YOU_SURE)
; 				PLOTAT	40;105;(YOU_WANT_TO_LEAVE?_)+

				JSR	SWAP_BOX
				LDA	#$20
				STA	PAGE
				JSR	ASK_YESNO
				BCS	TAKE_DEAD
				JSR	SWAP_BOX
				LDY	CURSOR
				JSR	CMARKER
				LDA	#$04
				JMP	COPTION

*** Take dead characters out of the group if verified
TAKE_DEAD		JSR	SWAP_BOX
:LOOP1			LDA	GRPNUMB
				BEQ	ALL_DEAD
				JSR	DEAD_LOOKER
				LDX	#0
:LOOP2			LDA	CHAR_LIST,X
				BEQ	:SKIPA
				INX
				BNE	:LOOP2			;Always
:SKIPA			DEC	GRPNUMB
				STX	COUNT
				CPX	GRPNUMB
				BEQ	:LOOP1
				TXA
				PHA
				JSR	SET_CHAR
				JSR	RETURN_DCARDS
				LDY	#status
				LDA	#intracc
				STA	(CHARDL),Y
				PLA
				JSR	HIDE_MEMBER
				JMP	:LOOP1

*** If all members are dead, force into dead group routine
ALL_DEAD		LDA	GRPNUMB
				BNE	FILL_FRONT
				LDA	DISK_SIDE
				EOR	#%00000110
				STA	DISK_SIDE
				JSR	SET_FGHTFILES
				LDX	#fDeadGroup
				JSR	SLOAD_FILE
				JMP	$8000

*** Check for someone in front row, if not, force into reformat
FILL_FRONT		JSR	RESET_CHRLIST
				LDA	#$05			;Front Row
				JSR	CSCAN_Y
				INX
				BNE	:SKIPA
				JMP	GOFORM

*** Calculate max sight range based on robots max 2
:SKIPA			JSR	CALC_SRANGE
				JMP	EXIT_CAMP

DEAD_LOOKER		JSR	RESET_CHRLIST
				LDX	#<FIND_DEAD
				LDY	#>FIND_DEAD
				JMP	CSCAN_COMMON

FIND_DEAD		LDY	#status
				LDA	(CHARDL),Y
				AND	#%00111111
				CMP	#dead
				BEQ	:EXIT
				CMP	#broken
:EXIT			RTS

FIND_CRITCALS	LDY	#status
				LDA	(CHARDL),Y
				AND	#critical
				EOR	#critical
				RTS

CRIT_BOX		DDB	52
				DB	86
				DDB	226
				DB	106
				DFB	BLUE
				DFB	wspace

DEAD_BOX		DDB	32
				DB	78
				DDB	248
				DB	114
				DFB	BLUE
				DFB	wyesno


RETURN_DCARDS	JSR	RESET_EQLIST
				LDX	#<DCARD_ORBS
				LDY	#>DCARD_ORBS
				JSR	ESCAN_COMMON
				BCC	:EXIT
				LDX	#16
:LOOP1			DEX
				BMI	:EXIT
				LDA	EQUIP_LIST,X
				BEQ	:LOOP1
				STX	TEMP
				LDY	CORESPS,X
				INY
				LDA	(CHARDL),Y
				TAY
				AND	#%00000111
				PHA
				TYA
				LSR
				LSR
				LSR
				TAX
				PLA
				CMP	#$02			;ORB
				BEQ	:SKIPA
				TXA
				LSR
				LSR
				LSR
				TAY
				TXA
				AND	#%00000111
				TAX
				LDA	BITMASKS,X
				EOR	#$FF
				AND	DCARDS_FOUND,Y
				STA	DCARDS_FOUND,Y
				JMP	:SKIPB
:SKIPA			LDA	BITMASKS,X
				EOR	#$FF
				AND	ORBS_FOUND
				STA	ORBS_FOUND
:SKIPB			LDA	TEMP
				PHA
				TAX
				JSR	REMOVE_ITEM
				PLA
				TAX
				BPL	:LOOP1			;Always
:EXIT			RTS

BITMASKS		DB	%10000000
				DB	%01000000
				DB	%00100000
				DB	%00010000
				DB	%00001000
				DB	%00000100
				DB	%00000010
				DB	%00000001

DCARD_ORBS		LDA	(CHARDL),Y
				CMP	#$43
				BNE	:EXIT
				INY
				LDA	(CHARDL),Y
				AND	#%00000111
				CMP	#$02			;ORBS
				BEQ	:EXIT
				CMP	#$04			;DATA CARDS
:EXIT			RTS


CALC_SRANGE		JSR	RESET_CHRLIST
				LDA	#robot*16
				JSR	CSCAN_PROF
				LDA #2
				BCC	:SKIPB
				LDX	#$00
:LOOP1			LDA	CHAR_LIST,X
				BEQ	:SKIPA
				INX
				BNE	:LOOP1			;Always
:SKIPA			TXA
				JSR	SET_CHAR
				LDY	#e1_HEAD
				LDA	(CHARDL),Y
				AND	#%00000111
:SKIPB			CMP	SRANGE
				BCS	:SKIPC
				STA	SRANGE
:SKIPC			STA	MXRANGE
				RTS
			FIN
