**********************************************************
*                                                        *
*              MOTHERSHIP/TRACC CAMP ROUTINE             *
*                                                        *
*                Written 02/21/1987                      *
*              Rewritten 08/06/2022                      *
*                                                        *
**********************************************************

ENTER_CAMP      ENT
                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_STATS_BOX
                PictCall COPY_DOWN
                PictSwap 0;191;40;121
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

; copy stats box from normal top-of-screen location to bottom of screen
; TODO: generalize this if anything other than CAMP also does it

DESTINL         =   LOCAL_TEMP+0
DESTINH         =   LOCAL_TEMP+1

COPY_DOWN       LDX #0
:1              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDA LOBYTES+122,X
                STA DESTINL
                LDA HIBYTES+122,X
                STA DESTINH
                LDY #39
:2              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :2
                INX
                CPX #70
                BNE :1
                RTS

*-------------------------------
STATS_MENU      DB  $02             ; min 0, max 2
                DB  $80             ; start at 0, clear LEGALS
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
                PictSwap 0;122;40;192
                PictEnd
                RTS

STATS_FLIP      JSR DRAW_PICT
                PictVMoveTo 124
                PictEnd
                JSR FLIP_STATS
                JSR MENU_SELECT
                JMP MENU_TARGET

FORCE_CAMP      JSR SET_PAGE2       ; TODO: bring back SET_AND_CLEAR_PAGE2?
                JSR CLEAR_PAGE
                JSR DRAW_STATS_BOX

STATS_MORE      LDA SHELL
                BEQ :1
                ; JSR SET_CAMPFILES
:1
				JSR DRAW_PICT
                PictSetPage2
                PictClear 0;121;40;192
                PictCall CAMP_MENU_BOX
                PictShowPage2
                PictCopyToPage1
                PictSetPage1
                PictShowPage1
                PictEnd

                LDA #0				; TRADE
COPTION			ORA #$80
                STA CCURPOS_MS
                STA CCURPOS_TRACC
                BMI CMENU			; always

RECAMP			BIT	UNSTROB
				JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall DRAW_STATS_BOX
                PictCall CAMP_MENU_BOX
                PictShowPage1
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
                TXA
                ORA #$80
                STA CCURPOS_MS
                STA CCURPOS_TRACC
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
                ; PictRect $3B;$7C;$DD;$B7
                PictRect $3B;$7C;$DD;$AE
                PictTextAt 81;128;()-
                USR (TRADE\n)-
                ; USR (POOL_CREDITS\n)-
                USR (REFORMAT_GROUP\n)-
                USR (INDIVIDUAL_STATISTICS\n)-
                USR (FLIP_STATS_TABLE\n)-
                USR (LEAVE)
                PictEnd
                RTS

CAMP_MARKER     LDY CAMP_YPNTS,X
                LDX #$46
                JMP DRAW_MARKER

*-------------------------------
CAMP_MENU_MS    DB  $03		;$04
CCURPOS_MS      DB  $80
                DW  CAMP_CURS
                DW  :CAMP_JUMPS_MS

:CAMP_JUMPS_MS  DW  TRADE
                ; DW  POOLER
                DW  GOISTAT
                DW  GOFLOP
                DW  GOLEAVE

CAMP_MENU_TRACC DB  $04		;$05
CCURPOS_TRACC   DB  $80
                DW  CAMP_CURS
                DW  :CAMP_JUMPS_T

:CAMP_JUMPS_T   DW  TRADE
                ; DW  POOLER
                DW  GOFORM
                DW  GOISTAT
                DW  GOFLOP
                DW  GOLEAVE

CAMP_CURS       LDY CAMP_YPNTS,X
                LDX #$43
                JMP DRAW_ARROW

CAMP_YPNTS      DB  $80,$89,$92
                DB  $9B,$A4,$AD
*-------------------------------

GOFLOP          JSR DRAW_PICT
                PictVMoveTo 2
                PictEnd
                JSR FLIP_STATS
                LDX CURSOR
                JSR CAMP_MARKER
                JSR MENU_SELECT
COPT_COM        JSR CAMP_MARKER
                JMP MENU_TARGET

GOLEAVE			LDA	SHELL
				BEQ EXIT_CAMP
				; JSR LOOSE_ENDS
EXIT_CAMP		JSR	DRAW_PICT
				PictSetPage2
				PictClearPage
				PictCall DRAW_HALL
				PictSetPage1
				PictShowPage2
				PictCopyToPage1
				PictShowPage1
				PictEnd
				RTS

GOFORM			; JSR	LOAD_REFORM
				JMP	REFORMAT

; LOAD_REFORM		LDA	CAMP_HERE
; 				AND	#bit_RefRegCom
; 				BNE	:EXIT
; 				LDX	#cRefRegCom
; 				JSR	SLOAD_FILE
; 				LDA	CAMP_HERE
; 				ORA	#bit_RefRegCom
; 				STA	CAMP_HERE
; :EXIT			RTS

TRADE           RTS
; POOLER			RTS

GOISTAT			JSR DRAW_PICT
				PictTextAt 16;70;(CANCEL)
				PictTextAt 63;96;(INDIVIDUAL_STATS_FOR_WHOM?)
				PictEnd
				JSR	GRPSUB
				LDA	CURSOR
				CMP	#7
				BEQ	:CANCEL
				JSR	SET_CHAR
				JSR	DRAW_CURSOR
				JMP	DOSTATS

:CANCEL			JSR DRAW_PICT
                PictClear 2;70;8;77
                PictClear 9;96;32;103
                PictEnd
                LDX #3				; ISTATS (TRACC)
                LDA SHELL
                BNE :1
                DEX					; ISTATS (mother)
:1				JSR	CAMP_MARKER
                JMP	CMENU

GRPSUB			JSR	RESET_CHRLIST
GRPSUB2			LDA	#$00			; called from C.TRADE1.S
				STA	GCURPOS
				STA	LEGALS+7
				JSR	PRE_ARROW
				JMP	MENU_SELECT

*-------------------------------
PRE_ARROW		LDX	#<:PRE_DEF
				LDY	#>:PRE_DEF
				JMP	MENU_INIT

:PRE_DEF		DB	$0A
GCURPOS			DB	$00
				DW	:PRE_CURS

:PRE_CURS		LDY	YPOINTS,X
				LDX	#$03
				LDA	CURSOR
				CMP	#$08
				BCC	:1
				LDX	#$5A
:1				JMP	DRAW_ARROW

; NOTE: was in KEY.COMMONS.S
YPOINTS			DFB	$0C,$14,$1C
				DFB	$24,$2C,$34
				DFB	$3C
				DFB	$46,$58,$62
				DFB	$6C
*-------------------------------

; caller has already set Y position
FLIP_STATS      LDA SELECT
                LDX SHELL
                BNE :1
                AND #$03
                STA SELECT_FLIP
                EOR #$03
                BPL :2				; always
:1				STA SELECT_FLIP
				EOR #$C3
:2				PHA
				LDA SELECT_FLIP
				JSR STATS_HEADER2
				PLA
				PHA
				JSR STATS_HEADER2
                JSR DRAW_PICT
                PictVMove 10
                PictEnd
                JSR FIRST_CHAR
:3				LDA SELECT_FLIP
				JSR STATS_LINE2
				PLA
				PHA
				JSR STATS_LINE2
                JSR DRAW_PICT
                PictVMove 8
                PictEnd
                JSR NEXT_CHAR
                BCC :3
                PLA
                STA SELECT
                RTS

            DO 0
LOOSE_ENDS
*** Notify if any characters in group are critical
				LDA	#$00
				STA	COUNT
:LOOP1			JSR	POINTIT
				LDY	#status
				LDA	(CHARDL),Y
				AND	#critical
				BNE	:SKIPA
				INC	COUNT
				LDA	COUNT
				CMP	GRPNUMB
				BNE	:LOOP1
				BEQ	LOOK_FOR_DEAD	;Always
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
				JSR	BANK_2
				LDX	#<TCRITCAMP+3
				LDY	#>TCRITCAMP+3
				JSR	FLUSH_NAME
				JSR	BANK_1
				LDY	#$11
				JSR	TEXTER
				JSR	SPACE_KEY
:LOOP3			INC	COUNT
				LDA	COUNT
				CMP	GRPNUMB
				BEQ	:SKIPC
				JSR	POINTIT
				LDY	#status
				LDA	(CHARDL),Y
				AND	#critical
				BEQ	:LOOP3
				BNE	:LOOP2			;Always
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
				JSR	POINTIT
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
				JSR	POINTIT
				LDY	#e1_HEAD
				LDA	(CHARDL),Y
				AND	#%00000111
:SKIPB			CMP	SRANGE
				BCS	:SKIPC
				STA	SRANGE
:SKIPC			STA	MXRANGE
				RTS

; POOLER			JSR	CLEAR2
; 				LDA	#GREEN
; 				STA	COLOR
; 				LDA	#$40
; 				STA	PAGE
; 				LDY	#$00
; 				JSR	LINER2			; green stats box
; 				LDY	#$10
; 				JSR	TEXTER
; 				LDA	#$6E
; 				STA	XPNT
; 				JSR	RESET_CHLIST
; 				LDA	#$00
; 				STA	COUNT
; DRWCRED			TAY
; 				LDA	LEGALS,Y
; 				BNE	:SKIPA
; 				LDA	YPOINTS,Y
; 				STA	YPNT
; 				TYA
; 				JSR	POINTIT
; 				JSR	CHAR_CREDOUT
; :SKIPA			INC	COUNT
; 				LDA	COUNT
; 				CMP	GRPNUMB
; 				BNE	DRWCRED
; POSTOP			JSR	POOL_TO_TOTAL
; 				LDA	#$46
; 				STA	YPNT
; 				JSR	TOTAL_CREDOUT
; 				LDA	#$20
; 				STA	PAGE
; 				JSR	MOVE212
; 				LDY	#$0C
; 				JSR	TEXTER
; 				LDA	#$00
; 				STA	LEGALS+7
; 				STA	GCURPOS
; 				JSR	PRE_ARROW
; 				BIT	UNSTROB
; 				JSR	GETKEY
; 				LDY	#$0C
; 				JSR	TEXTER
; 				JSR	MOVE212
; 				LDA	CURSOR
; 				CMP	#$07
; 				BEQ	POOLOUT
; 				LDA	CURSOR
; 				JSR	POOL_TO_CHAR
; POOLOUT			LDY	#$01
; 				JSR	CMARKER
; 				LDA	#$00
; 				JMP	COPTION
			FIN
