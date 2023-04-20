*-------------------------------
* On Entry:
*   X -> INSTR1
*   Y -> INSTR2
*   A -> TIMTAKE

GENERAL_POST    STX INSTR1
                STY INSTR2
                STA TIMTAKE

POST_COMMAND    LDX COMCNT
                LDA TIMLEFT
                STA CTIMTAB,X
                LDY COMPNTR
                LDA INSTR1
                STA COMMAND,Y
                INY
                INC COMPNTR
                LDA INSTR2
                STA COMMAND,Y
                INC COMPNTR
                JSR DOTIME3
                LDA TIMLEFT
                SED
                SEC
                SBC TIMTAKE
                STA TIMLEFT
                CLD
                JSR DOTIME3
COMND2          LDA COMCNT
                CMP #$0A
                BNE GOCOMR
                LDA INSTR1
                PHA
                LDA INSTR2
                PHA
                JSR MOVOVER
                PLA
                STA INSTR2
                PLA
                STA INSTR1
GOCOMR          JSR DRAW_CMD
                INC COMCNT
                RTS

DOTIME3         LDA TIMLEFT
                JSR TWO_DIGITS
                JSR DRAW_PICT
                PictMoveTo 262;76
                PictTextbuf
                PictEnd
                RTS

TWO_DIGITS      PHA
                LSR
                LSR
                LSR
                LSR
                STA TEXT_BUFFER+0
                PLA
                AND #$0F
                STA TEXT_BUFFER+1
                LDA #TextLineEnd
                STA TEXT_BUFFER+2
                RTS

DRAW_CMD        LDY COMCNT
                LDA COMYS,Y
                PHA
                CPY #$0A
                BCS :1
                TYA
                CLC
                ADC #$05
                TAY
:1              LDX COMXS,Y
                PLA
                TAY
DRAW_CMD2       JSR MOVE_TO
                JSR BUILD_CMD
                JSR DRAW_TEXTBUF
                LDX #3
                LDA #TextEmpty
:3              STA TEXT_BUFFER,X
                DEX
                BPL :3
                LDX #2
                JSR HMOVE
                JMP DRAW_TEXTBUF

; TODO: use move logic to get rid of these tables
; TODO: also used in C.USER.S
COMYS           DFB $57,$5F,$67
                DFB $6F,$77,$57
                DFB $5F,$67,$6F
                DFB $77,$57,$5F
                DFB $67,$6F,$77
COMXS           DFB $A8,$A8,$A8
                DFB $A8,$A8,$CE
                DFB $CE,$CE,$CE
                DFB $CE,$F4,$F4
                DFB $F4,$F4,$F4

BUILD_CMD       LDA INSTR1
                AND #$0F
                PHA
                LDX #<CMD_WORDS
                LDY #>CMD_WORDS
                JSR GET_IND_STRING
                LDA #TextLineEnd
                STA TEXTBUF+6
                PLA
                TAY
                LDX TYPE2,Y
                LDA TYPES+1,X
                PHA
                LDA TYPES,X
                PHA
                RTS

CMD_WORDS       USR (SWN)=
                USR (SHT)=
                USR (ENR)=
                USR (THW)=
                USR (USE)=
                USR (XXX)=
                USR (AIM)=
                USR (MOV)=
                USR (IDN)=
                USR (EXC)=
                USR (PAR)=
                USR (RUN)=
                USR (TES)=

TYPES           DW  CXY-1
                DW  CXF-1
                DW  HUL-1
                DW  NTS-1
                DW  QST-1
                DW  NOT-1

CXY             LDA INSTR1
                AND #%00001111
                CMP #cmdIDENTIFY
                BNE CXYSKIP
                LDA INSTR2
                BPL CXYSKIP
                JMP NOT
CXYSKIP         LDA INSTR2
                LSR
                LSR
                LSR
                LSR
                AND #%00000111
                STA TEXTBUF+4
                LDA INSTR2
                AND #%00001111
                CLC
                ADC #$0A
                STA TEXTBUF+5
                RTS

CXF             LDA INSTR2
                AND #$07
                STA TEXTBUF+4
                LDA #$10
                STA TEXTBUF+5
                LDA INSTR2
                AND #$70
                CMP #$60
                BNE NOWOVER
                INC TEXTBUF+5
NOWOVER         LDA INSTR2
                AND #$18
                LSR
                LSR
                LSR
                CMP #$01
                BEQ CXOUT
                CMP #$03
                BEQ CXOUT
                CMP #$02
                BNE MINUSON
                INC TEXTBUF+4
                BNE CXOUT
MINUSON         DEC TEXTBUF+4
CXOUT           RTS

HUL             LDA #$1F
                STA TEXTBUF+4
                LDA #$16
                STA TEXTBUF+5
                BIT INSTR1
                BPL NOTLOW
                LDA #$16
                STA TEXTBUF+4
NOTLOW          BIT INSTR1
                BVC HULOUT
                LDA #$1C
                STA TEXTBUF+5
HULOUT          RTS

NTS             LDA INSTR2
NTS2            LSR
                LSR
                LSR
                LSR
                STA TEXTBUF+4
                LDA INSTR2
                AND #$0F
                STA TEXTBUF+5
                RTS

QST             NOP
NOT             LDA #TextSpace
                STA TEXTBUF+4
                STA TEXTBUF+5
                RTS

TYPE2           DFB $02,$06,$08
                DFB $00,$04,$04
                DFB $00,$00,$00
                DFB $04,$06,$0A
                DFB $0A

MOVOVER         JSR DRAW_PICT
                PictSetPage2
                PictClear 23;71;40;128
                PictSetGreen
                PictRect 159;71;277;127
                PictMoveTo 165;72
                PictLineTo 165;126
                PictEnd

MOVBACK         JSR TUNITS_LABEL
                JSR DOTIME3
                LDA COMCNT
                PHA
                LDA COMPNTR
                PHA
                DEC COMCNT
                DEC COMPNTR
                DEC COMPNTR
                DEC COMPNTR
MVLOOP          LDY COMPNTR
                LDA COMMAND,Y
                STA INSTR2
                DEC COMPNTR
                DEY
                LDA COMMAND,Y
                STA INSTR1
                DEC COMPNTR
                LDY COMCNT
                LDX COMXS,Y
                LDA COMYS,Y
                TAY
MOVMOD          JSR DRAW_CMD2
                DEC COMCNT
                BPL MVLOOP

                JSR DRAW_PICT
                PictSwap $17;$48;$28;$7E
                PictSetPage1
                PictEnd
                PLA
                STA COMPNTR
                PLA
                STA COMCNT
                RTS

SHRINK_TUNITS   LDA COMCNT
                CMP #$0B
                BCC :1
                JSR DRAW_PICT
                PictSetPage2
                PictCall DRAW_TUNITS_BOX
                PictSwap $17;$48;$28;$7E
                PictSetPage1
                PictEnd
                RTS
:1              JMP DRAW_TUNITS_BOX


DOTIME2         LDX OPTSPOT
                LDY TIME_TYPES,X
                LDA TIMES,Y
                STA CURTIME
DOTIME          LDA CURTIME
                JSR TWO_DIGITS
                JSR DRAW_PICT
                PictMoveTo 265;185
                PictTextbuf
                PictEnd
                RTS

TIME_TYPES      DB  timeSWING
                DB  timeAimSHOOT
                DB  timeAimENERGY
                DB  timeTHROW
                DB  timeUSE
                DB  upupTime        ;Was ADJUST
                DB  timeAIM

                DB  timeMOVE
                DB  timeIDENTIFY
                DB  timeEXCHANGE
                DB  timePARRY
                DB  allTime         ;timeRUN
                DB  allTime         ;timeTESSERACT
                DB  noTime

                DB  noTime
                DB  noTime
                DB  noTime
                DB  noTime
                DB  noTime
                DB  noTime
                DB  noTime

INDEX           =   COLUMN

OPTIONS         JSR TIME_TABLE
                JSR CAN_CANT
                LDY #-1
                STY INDEX
                INY
                BEQ :11                 ; always
:1              LDX #<:COL_NAMES
                LDY #>:COL_NAMES
                JSR GET_IND_STRING
                LDY TEXT_BUFFER+0
                CPY #TextSpace
                BCS :2
:11             LDX :COL_X,Y
                LDY #129
                JSR MOVE_TO
                JSR HSAVE
                JMP :4
:2              JSR HRESTORE
                LDX INDEX
                LDA OPT_LEGALS,X
                BMI :3
                JSR DRAW_TEXTBUF_RET
                JMP :4
:3              JSR DRAW_MARKER_TILE
                LDY #9
                JSR VMOVE
:4              INC INDEX
                LDA INDEX
                CMP #20
                BNE :1
                RTS

:COL_X          DB  114,173,244

:COL_NAMES      USR (SWING)=
                USR (SHOOT)=
                USR (ENERGY)=
                USR (THROW)=
                USR (USE)=
                USR (_)=
                USR (1)=
                USR (MOVE)=
                USR (IDENTIFY)=
                USR (EXCHANGE)=
                USR (PARRY)=
                USR (RUN)=
                USR (TESSERACT)=        ; TODO: get rid of
                USR (2)=
                USR (END)=
                USR (BACK1)=
                USR (REDO)=
                USR (OTHER)=
                USR (FLIP)=
                USR (DELAY)=

CAN_CANT        JSR SET_HANDFLAGS
                JSR MAKE_CONVERT
                LDX #20
                LDA #0
:LOOP1          STA OPT_LEGALS,X
                DEX
                BPL :LOOP1
                STX OPT_LEGALS+5
                STX OPT_LEGALS+6
                STX OPT_LEGALS+12
                STX OPT_LEGALS+13
                STX OPT_LEGALS+20
                INX
:LOOP2          LDY TIME_TYPES,X
                CPY #noTime
                BEQ :SKIPB
                LDA COMCNT
                CMP #15
                BEQ :SKIPA
                LDA TIMLEFT
                SED
                SEC
                SBC TIMES,Y
                CLD
                BCS :SKIPB
:SKIPA          LDA #$FF
                STA OPT_LEGALS,X
:SKIPB          INX
                CPX #21
                BNE :LOOP2

*-------------------------------
* IDENTIFY
*-------------------------------
CSKIP0          LDY #profrace
                LDA (CHARDL),Y
                AND #%11110000
                CMP #android*$10
                BNE :SKIPA
                JSR RESET_EQLIST
                JSR ESCAN_HANDBCK
                LDX #back6
                LDA #$FF
:LOOP1          STA EQUIP_LIST,X
                DEX
                BPL :LOOP1
                JSR ESCAN_FULSLOT
                LDX #<FIND_IDSCAN
                LDY #>FIND_IDSCAN
                JSR ESCAN_COMMON
                STY WHERE_IDSCAN
                BCS CSKIP1
:SKIPA          LDX #$FF
                STX OPT_LEGALS+cmdIDENTIFY
*-------------------------------
* RUN
*-------------------------------
CSKIP1          LDX #$FF
                LDA TIMLEFT
                CMP TIMES+timeRUN
                BCS CSKIP3
                STX OPT_LEGALS+cmdRUN
*-------------------------------
* BACK1
*-------------------------------
CSKIP3          LDA COMCNT
                BNE CSKIP4
                STX OPT_LEGALS+cmdBACK1
*-------------------------------
* OTHER
*-------------------------------
CSKIP4          LDA PLANNER
                BEQ CSKIP4B
                LDX #$00
CSLOOP4         TXA
                JSR SET_CHAR
                JSR BAD_STATUS
                BNE CSKIP5
:SKIPA          INX
                CPX PLANNER
                BNE CSLOOP4
CSKIP4B         LDX #$FF
                STX OPT_LEGALS+cmdOTHER
*-------------------------------
* ENERGY
*-------------------------------
CSKIP5          LDA PLANNER
                JSR SET_CHAR
                JSR PICKECT
                CMP #$FF
                BEQ CANT5
                LDA COMCNT
                CMP #14
                BCS CANT5
                LDY #profrace
                LDA (CHARDL),Y
                AND #%11110000
                CMP #juicer*$10
                BEQ CSKIP6
                CMP #$70
                BEQ CSKIP6
CANT5           LDX #$FF
                STX OPT_LEGALS+cmdENERGY
*-------------------------------
* SHOOT
*-------------------------------
CSKIP6          LDA #$01
                JSR EQUIP_TYPER
                LDA #$01
                JSR LEGAL_HANDS
                JSR ANDUP
                BNE :SKIPA
                LDA COMCNT
                CMP #14
                BCC CSKIP7
:SKIPA          LDX #$FF
                STX OPT_LEGALS+cmdSHOOT
*-------------------------------
* SWING
*-------------------------------
CSKIP7          LDX PLANNER
                LDA XYSPOTS,X
                AND #$0F
                CMP #$05
                BNE NOFRON7
                LDA #$00
                JSR EQUIP_TYPER
                LDA #$00
                JSR LEGAL_HANDS
                JSR ANDUP
                BEQ CSKIP9
NOFRON7         LDX #$FF
                STX OPT_LEGALS+cmdSWING
*-------------------------------
* THROW
*-------------------------------
CSKIP9          LDA #$02
                JSR EQUIP_TYPER
                LDA #$02
                JSR LEGAL_HANDS
                JSR ANDUP
                BEQ CSKIP10
                LDX #$FF
                STX OPT_LEGALS+cmdTHROW
*-------------------------------
* USE
*-------------------------------
CSKIP10         LDA #$03
                JSR EQUIP_TYPER
                LDA #$03
                JSR LEGAL_HANDS
                JSR ANDUP
                BEQ CSKIP11
                LDX #$FF
                STX OPT_LEGALS+cmdUSE
*-------------------------------
* EXCHANGE
*-------------------------------
CSKIP11         LDX #$FF
                LDY #profrace
                LDA (CHARDL),Y
                BPL CSKIP12
                STX OPT_LEGALS+cmdEXCHANGE
*-------------------------------
* REDO
*-------------------------------
CSKIP12         LDA COMCNT
                BNE CANSOUT
                STX OPT_LEGALS+cmdREDO

CANSOUT         RTS
*-------------------------------


FIND_IDSCAN     LDA (CHARDL),Y
                CMP #$42            ;SCANNERS
                BNE :EXIT
                INY
                LDA (CHARDL),Y
;               CMP  #$00            ;I.D. SCANNER
:EXIT           RTS


TIME_TABLE      LDA PLANNER
                JSR SET_CHAR
                LDY #upreflex
                JSR MUCH_TIME
                STA TIMES+upTime
                LDY #lwreflex
                JSR MUCH_TIME
                STA TIMES+loloTime
                PHA
                SED
                CLC
                ADC TIMES+loloTime
                STA TIMES+loloTime
                LDA TIMES+upTime
                CLC
                ADC TIMES+upTime
                STA TIMES+upupTime
                PLA                 ;loloTime
                CLC
                ADC TIMES+upTime
                STA TIMES+uploTime
                CLD
                LDA TIMLEFT
                STA TIMES+allTime
                LDA #$AA
                STA TIMES+noTime
                LDA #$01
                STA TIMES+oneTime
                RTS

MUCH_TIME       LDA (CHARDL),Y
                LDY #$00
:LOOP1          CMP MAXCUTS,Y
                BCC :SKIPA
                BEQ :SKIPA
                INY
                BNE :LOOP1
:SKIPA          LDA TMUNITS,Y
                RTS

MAXCUTS         DB  $16,$33,$50,$66,$82,$99
TMUNITS         DB  $36,$18,$12,$09,$07,$06
