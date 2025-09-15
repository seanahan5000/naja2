
DEFINE_CHAR     JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictSetGreen

                PictMoveTo 1;0
                PictHLineTo 279
                PictVLineTo 191
                PictHLineTo 1
                PictVLineTo 0

                PictMoveTo 71;1
                PictVLineTo 132
                PictMoveTo 1;24
                PictHLineTo 71
                PictMoveTo 1;47
                PictHLineTo 71
                PictMoveTo 1;102
                PictHLineTo 71
                PictMoveTo 1;133
                PictHLineTo 279

                PictTextAt 7;140;"BODY COMPOSITION"
                PictTextAt 38;153;"% INORGANIC:"
                PictTextAt 50;165;"% ORGANIC:"
                PictTextAt 20;177;"ENERGY USAGE: ."
                PictTextAt 4;5;"NAME:"
                PictTextAt 4;28;"RACE:"
                PictTextAt 82;118;"IQ"
                PictTextAt 102;118;"STRENGTH"
                PictTextAt 158;113;"LOWER  UPPER"
                PictTextAt 158;123;"REFLEX-SPEED"
                PictTextAt 239;118;"CREDIT"

                PictCall DRAW_ADAPT
                PictCall DRAW_POSPROF
                PictTextAt 16;92;"C>ANCEL"
                PictEnd

                LDX #0
:1              LDA NAME_BUFFER,X
                STA TEXT_BUFFER,X
                INX
                CPX #charNameLength
                BNE :1
:2              DEX
                BMI :3
                LDA TEXT_BUFFER,X
                CMP #TextSpace
                BEQ :2
:3              LDA #TextLineEnd
                STA TEXT_BUFFER+1,X
                JSR DRAW_PICT
                PictTextbufXY 10;14
                PictEnd

                LDA RACE
                JSR RACE_TO_TEXT
                JSR DRAW_PICT
                PictTextbufXY 10;37
                PictEnd

                LDA #$FF
                STA PROF_POS

                LDX RACE
                LDA MINOFF,X        ;LOAD MINIMUM CHARACTERIST VALUES
                TAX
                LDY #$00
MORMINS         LDA MINMUM,X
                STA MINSTAT,Y       ;STORE THEM IN MINIMUM TABLE
                STA PRSNST,Y        ;AND IN PRESENT VALUE TABLE
                INX
                INY
                CPY #$09
                BNE MORMINS
TOOMUCH         JSR RANDOM
                LDX RACE
                CMP ADRANGE,X
                BEQ NOPROB
                BCS TOOMUCH
NOPROB          CLC
                SED
                ADC PRSNST+7
                STA PRSNST+7
                CLD
                LDY #$05
                SED
                LDA #$00            ;CALCULATE INORGANIC BASED ON ORGANIC
                SEC
                SBC PRSNST,Y
                CLD
                LDY #$06
                STA PRSNST,Y
                LDY #$08
                STA PRSNST,Y

                LDA #$00
                STA STATNUM
MORNUMS         JSR STATOUT         ;LOOP THROUGH AND DRAW STATS
                INC STATNUM
                LDA STATNUM
                CMP #$09
                BNE MORNUMS

                LDY #$07            ;CLEAR MINIMUM ADAPTATION POINTS
                LDA #$00
                STA MINSTAT,Y
                LDA #$00
                STA BOXNUM
                JSR DRAW_BOX
                JSR UPDATE_PROFS

                LDX #0
MORGRPH         STX WHICH
                JSR CALLA
                LDX WHICH
                INX
                CPX #5
                BNE MORGRPH

                LDA PRSNST+5
                JSR MOD5
                STA MOD
                LDA PRSNST+6
                JSR MOD5
                STA MOD+1
                LDA PRSNST+8
                JSR MOD5
                STA MOD+2

                LDX #0
MORHGRP         STX WHICH
                JSR ADJUSTR
                LDA MOD,X
                STA COUNT
                STA HOLDIT
                LDA #$00
                STA DATCNT
                LDA #$13
                STA XHOLD
                JSR HSTART2
                LDX WHICH
                INX
                CPX #3
                BNE MORHGRP

                JSR SHOW_PAGE
                LDA UNSTROB
                JMP KEYIN

DRAW_POSPROF    JSR DRAW_PICT
                PictTextAt 4;51;"PROFESSION:"
                PictEnd
                RTS

DRAW_ADAPT      JSR DRAW_PICT
                PictTextAt 7;106;"ADAPTATION"
                PictTextAt 19;114;"POINTS"
                PictEnd
                RTS

MOD5            LDY #$00
                SED
                SEC
:1              SBC #$05
                INY
                BCS :1
                CLD
                DEY
                TYA
                RTS

BLINKY          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI KEYGOT
                JSR ERASE_BOX
                LDA #$00
                JSR WAIT_KEY
                JSR DRAW_BOX
KEYIN           BIT KEYBRD
                BPL BLINKY
KEYGOT          LDA KEYBRD
                BIT UNSTROB
                JSR CHECK_LEFT
                BNE :1
                JMP GO_LEFT
:1              JSR CHECK_RIGHT
                BNE :2
                JMP GO_RIGHT
:2              JSR CHECK_UP
                BNE :3
                JMP GO_UP
:3              JSR CHECK_DOWN
                BNE :4
                JMP GO_DOWN
:4              JSR CHECK_ENTER
                BNE :5
                JMP DID_ENTER
:5              JSR CHECK_CANCEL
                BNE KEYIN
                CLC

LEAVE_CREATE    PHP
                JSR DRAW_PICT
                PictSetPage1
                PictCall CLEAR_BOX
                PictShowPage
                PictEnd
                PLP
                RTS

GO_LEFT         LDA BOXNUM
                CMP #$02
                BNE NOREFLX
                LDA #$06
                STA BOXNUM
                JSR ERASE_BOX
                LDA #$02
                STA BOXNUM
NOREFLX         JSR ERASE_BOX
                DEC BOXNUM
                BPL NOZEROL
                LDA #$05
                STA BOXNUM
NOZEROL         LDA BOXNUM
                CMP #$03
                BNE NORFLX2
                LDA #$06
                STA BOXNUM
                JSR DRAW_BOX
                LDA #$03
                STA BOXNUM
NORFLX2         JSR DRAW_BOX
                JMP KEYIN

GO_RIGHT        LDA BOXNUM
                CMP #$03
                BNE NOREFL
                LDA #$06
                STA BOXNUM
                JSR ERASE_BOX
                LDA #$03
                STA BOXNUM
NOREFL          JSR ERASE_BOX
                INC BOXNUM
                LDA BOXNUM
                CMP #$02
                BNE NOREFL2
                LDA #$06
                STA BOXNUM
                JSR DRAW_BOX
                LDA #$02
                STA BOXNUM
                BNE NOSIXR              ; always
NOREFL2         CMP #$06
                BNE NOSIXR
                LDA #$00
                STA BOXNUM
NOSIXR          JSR DRAW_BOX
                JMP KEYIN

GO_UP           LDX BOXNUM
                CPX #$05
                BNE NOORG
                LDA PRSNST,X
                CMP MINSTAT,X
                BNE OKAYED
                JMP KEYIN

OKAYED          PHA
                TXA
                PHA
                LDX #$08
                STX STATNUM
                JSR STATOUT
                PLA
                TAX
                PLA
                SED
                SEC
                SBC #$05
                CLD
                JSR CHNGST
                LDX #$00
                JSR ADJUSTR
                LDA MOD
                SEC
                SBC #$01
                JSR HGRAPH
                LDX #$06
                LDA PRSNST,X
                SED
                CLC
                ADC #$05
                CLD
                JSR CHNGST
                LDX #$08
                STX STATNUM
                JSR STATOUT
                LDX #$01
                JSR ADJUSTR
                LDA MOD+1
                CLC
                ADC #$01
                JSR HGRAPH
                LDX #$02
                JSR ADJUSTR
                LDA MOD+2
                CLC
                ADC #$01
                JSR HGRAPH
                JSR UPDATE_PROFS
                JMP KEYIN
NOORG           TXA
                BNE NOTINT
                LDA PRSNST,X
                CMP #$25
                BNE ALRIGHT
                JMP KEYIN
NOTINT          LDA PRSNST,X
                CMP #$22
                BNE ALRIGHT
                JMP KEYIN
ALRIGHT         PHA
                LDX #$07
                LDA PRSNST,X
                BNE GOADAPT
                PLA
                JMP KEYIN
GOADAPT         SED
                SEC
                SBC #$01
                CLD
                JSR CHNGST
                LDX BOXNUM
;               CPX #$00
                BEQ UCONN
                CPX #$04
                BNE UNOT40
                STX STATNUM
                JSR STATOUT
                JMP UNOT40
UCONN           LDA PRSNST+4
                BEQ UNOT40
                LDX #$04
                STX STATNUM
                JSR STATOUT
                LDX #$00
UNOT40          PLA
                SED
                CLC
                ADC #$01
                CLD
                LDX BOXNUM
                PHA
                JSR CALL
                PLA
                LDX BOXNUM
                CPX #$04
                BNE UNOT42
                STX STATNUM
                STA PRSNST,X
                JSR STATOUT
                JMP UNOT43
UNOT42          JSR CHNGST
                CPX #$00
                BNE UNOT43
                LDY PRSNST+4
                BEQ UNOT43
                LDX #$04
                STX STATNUM
                JSR STATOUT
UNOT43          JSR UPDATE_PROFS
                JMP KEYIN

GO_DOWN         LDX BOXNUM
                CPX #$05
                BNE NOINORG
                LDX #$06
                LDA PRSNST,X
                CMP MINSTAT,X
                BNE OKAY
                JMP KEYIN
OKAY            PHA
                TXA
                PHA
                LDX #$08
                STX STATNUM
                JSR STATOUT
                PLA
                TAX
                PLA
                SED
                SEC
                SBC #$05
                CLD
                JSR CHNGST
                LDX #$01
                JSR ADJUSTR
                LDA MOD+1
                SEC
                SBC #$01
                JSR HGRAPH
                LDX #$02
                JSR ADJUSTR
                LDA MOD+2
                SEC
                SBC #$01
                JSR HGRAPH
                LDX #$05
                LDA PRSNST,X
                SED
                CLC
                ADC #$05
                CLD
                JSR CHNGST
                LDX #$08
                STX STATNUM
                JSR STATOUT
                LDX #$00
                JSR ADJUSTR
                LDA MOD
                CLC
                ADC #$01
                JSR HGRAPH
                JSR UPDATE_PROFS
                JMP KEYIN
NOINORG         LDA PRSNST,X
                CMP MINSTAT,X
                BNE GODOWN
                JMP KEYIN
GODOWN          PHA
                LDX #$07
                LDA PRSNST,X
                SED
                CLC
                ADC #$01
                CLD
                JSR CHNGST
                LDX BOXNUM
                CPX #$00
                BEQ CONNECT
                CPX #$04
                BNE NOT40
                STX STATNUM
                JSR STATOUT
                JMP NOT40
CONNECT         LDA PRSNST+4
                BEQ NOT40
                LDX #$04
                STX STATNUM
                JSR STATOUT
                LDX #$00
NOT40           PLA
                SED
                SEC
                SBC #$01
                CLD
                LDX BOXNUM
                PHA
                JSR CALL
                PLA
                LDX BOXNUM
                CPX #$04
                BNE NOT42
                STX STATNUM
                STA PRSNST,X
                JSR STATOUT
                JMP NOT43
NOT42           JSR CHNGST
                CPX #$00
                BNE NOT43
                LDY PRSNST+4
                BEQ NOT43
                LDX #$04
                STX STATNUM
                JSR STATOUT
NOT43           JSR UPDATE_PROFS
                JMP KEYIN

DID_ENTER       JSR ERASE_BOX
                LDX #6
                JSR UPDATE_BOX_N
                LDA PRSNST+7
                BEQ ADAPOUT
                LDA #$00                ; blink adaptation points
                JSR WBLINK
                JMP WBCOM
ADAPOUT         LDA PROF_POS
                BMI NO_PROF
                ASL
                ASL
                ASL
                ASL
                ORA RACE
                STA PROFRAC
                SEC
                JMP LEAVE_CREATE

NO_PROF         LDA #$01                ; blink possible profession
                JSR WBLINK
WBCOM           JSR DRAW_BOX
                LDA BOXNUM
                CMP #$02
                BEQ ISUPLOW
                CMP #$03
                BNE NOUPLOW
ISUPLOW         LDX #6
                JSR UPDATE_BOX_N
NOUPLOW         JMP KEYIN

;---------------------------------------

WBLINK          LDX #1
                STX COUNT
:1              PHA
                JSR :BLINK1
                PLA
                DEC COUNT
                BPL :1
                RTS

:BLINK1         PHA
                LDA #$00
                JSR WAIT_KEY
                PLA
                PHA
                JSR :BLINK2
                LDA #$00
                JSR WAIT_KEY
                PLA
:BLINK2         TAX
                BNE :2
                JMP DRAW_ADAPT
:2              JMP DRAW_POSPROF

;---------------------------------------

; code for doing flicker-free stats number updates

STATOUT         LDX STATNUM
                CPX #$04
                BNE NORMST
                LDA #$02
                STA MISC
                LDY RACE
                LDA BASECRD,Y
                STA MISC+1
                LDA PRSNST,X
                BEQ ADDEDIT
                PHA
CREDADD         LDA PRSNST
                CLC
                SED
                ADC MISC+1
                STA MISC+1
                LDA MISC
                ADC #$00
                STA MISC
                PLA
                SEC
                SBC #$01
                CLD
                PHA
                BNE CREDADD
                PLA
ADDEDIT         LDA MISC
                JSR SPLIT
                STA TEXTBUF+0
                STY TEXTBUF+1
                LDA MISC+1
                JSR SPLIT
                STA TEXTBUF+2
                STY TEXTBUF+3
                LDA #TextLineEnd
                STA TEXTBUF+4
                LDY #$00
ZEROUT          LDA TEXTBUF,Y
                BNE ZEROD
                LDA #TextSpace
                STA TEXTBUF,Y
                INY
                CPY #$03
                BNE ZEROUT
ZEROD           LDX #$04
                JMP TOUT
NORMST          CPX #$08
                BNE NORM2
                LDA #$20
                CLC
                SED
                ADC PRSNST+6
                STA MISC2+1
                LDA #$03
                ADC #$00
                STA MISC2
                CLD
                LDA #TextSpace
                STA TEXTBUF+0
                LDA MISC2
                AND #$0F
                STA TEXTBUF+1
                LDA MISC2+1
                JSR SPLIT
                STA TEXTBUF+2
                STY TEXTBUF+3
                LDA #TextLineEnd
                STA TEXTBUF+4
                LDX #104
                LDY #177
                JSR DRAW_TEXTBUF_XY
                LDA TEXTBUF+1
                ASL
                ASL
                ASL
                ASL
                ORA TEXTBUF+2
                STA MISC2
                LDA TEXTBUF+3
                ASL
                ASL
                ASL
                ASL
                STA MISC2+1
                RTS

MISC            DB  $00,$00
MISC2           DB  $00,$00

NORM2           LDA PRSNST,X
                JSR SPLIT
                BNE :1
                LDA #TextSpace
:1              STA TEXTBUF+0
                STY TEXTBUF+1
                LDA #TextLineEnd
                STA TEXTBUF+2
                JMP TOUT
;
; On entry:
;   A: value to split
;
; On exit:
;   Y: high nibble
;   A: low nibble
;   X: unchanged
;   BEQ/BNE: based on high nibble value
;
SPLIT           TAY
                LSR
                LSR
                LSR
                LSR
                PHA
                TYA
                AND #$0F
                TAY
                PLA
                RTS

CHNGST          PHA
                LDA PRSNST,X
                LSR
                LSR
                LSR
                LSR
                STA HOLDIT
                PLA
                PHA
                LSR
                LSR
                LSR
                LSR
                CMP HOLDIT
                BEQ NOFIRST
                PHA
                LDA HOLDIT
                BEQ OVERIT
                STA TEXTBUF
                LDA #TextLineEnd
                STA TEXTBUF+1
                JSR TOUT
OVERIT          PLA
                BEQ NOFIRST
                STA TEXTBUF
                LDA #TextLineEnd
                STA TEXTBUF+1
                JSR TOUT
NOFIRST         LDA PRSNST,X
                AND #$0F
                STA TEXTBUF+1
                LDA #TextSpace
                STA TEXTBUF
                LDA #TextLineEnd
                STA TEXTBUF+2
                JSR TOUT                ; erase old value
                PLA
                STA PRSNST,X
                AND #$0F
                STA TEXTBUF+1
                LDA #TextSpace
                STA TEXTBUF
                LDA #TextLineEnd
                STA TEXTBUF+2
                JSR TOUT                ; draw new value
                RTS
;
; On entry:
;   X: index of stat to drawn
;   TEXT_BUFFER: text to be drawn
;
TOUT            TXA
                PHA
                LDY :STAT_Y,X
                LDA :STAT_X,X
                TAX
                JSR DRAW_TEXTBUF_XY
                PLA
                TAX
                RTS

;                    IQ  ST  LR  UR  CR  OR  IN  AP  EN
:STAT_X         DB   82,119,167,209,242,116,116, 31,110
:STAT_Y         DB  103,103,103,103,103,165,154,123,177

;---------------------------------------

GRAPHA          LDA #98                 ; graph bottoms
                STA YLEVEL
                LDA #$00
                STA PICPNT
                LDA PRSNST,X
                STA COUNT
                BNE NEXTLIN
                JMP TOPOUT
GRAPH           STA HOLDIT
                LDA PRSNST,X
                SED
                SEC
                SBC HOLDIT
                CLD
                BPL GODWN
                LDA HOLDIT
                SED
                SEC
                SBC PRSNST,X
                STA COUNT
                CLD
NEXTLIN         LDA #$00
                STA COUNTR4
                LDA PICPNT
PNT1            CMP #$4B
                BNE LIN2
PNTA            LDA #$00
                STA PICPNT
LIN2            LDX YLEVEL
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
PNT2            LDY #$09
LINEUP          LDX PICPNT
PNT3            LDA $FFFF,X         ;Modified
                ORA (SCREENL),Y
                STA (SCREENL),Y
                INY
                INC PICPNT
PNT4            CPY #$0E
                BNE LINEUP
                CPY #$21
                BNE NOFIXIT
                LDX #$80
                DEY
                LDA (SCREENL),Y
                CMP #$D5
                BNE FIXIT
                LDX #$81
FIXIT           TXA
                INY
                STA (SCREENL),Y
NOFIXIT         INC COUNTR4
                DEC YLEVEL
                LDA PICPNT
PNT5            CMP #$4B
                BNE NORESET
PNTB            LDA #$00
                STA PICPNT
NORESET         LDA YLEVEL
                CMP #1                  ; y-limit top of graph
                BEQ TOPOUT
                LDA COUNTR4
                CMP #$04
                BNE LIN2
                SED
                LDA COUNT
                SEC
                SBC #$01
                STA COUNT
                CLD
                BNE NEXTLIN
TOPOUT          RTS
GODWN           LDA PICPNT
                BNE GOON
PNTC            LDA #$4B
                STA PICPNT
GOON            DEC PICPNT
                LDA #$00
                STA COUNTR4
                INC YLEVEL
GODOWN2         LDX YLEVEL
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
PNT6            LDY #$09
                LDA PNT7+1
                CMP #$15
                BNE UPLINE
                LDA #$E0
                STA PNT8+1
                LDA #$1B
                STA PNT7+1
UPLINE          LDA #$00
PNT7            CPY #$09
                BNE CSTORE
                LDA (SCREENL),Y
PNT8            AND #$07
CSTORE          STA (SCREENL),Y
                INY
                DEC PICPNT
PNT9            CPY #$0E
                BNE UPLINE
                CPY #$21
                BNE NOFIX2
                LDA #$00
                STA (SCREENL),Y
NOFIX2          INC COUNTR4
                INC YLEVEL
                LDA PICPNT
PNTD            CMP #$FF
                BNE NOCLEER
PNT10           LDA #$4A
                STA PICPNT
NOCLEER         LDA YLEVEL
                CMP #$40
                BEQ GOTOP
                LDA COUNTR4
                CMP #$04
                BNE GODOWN2
GOTOP           INC PICPNT
                DEC YLEVEL
                JMP TOPOUT

CALLA           TXA
                PHA
                JSR ADJUST
                JSR GRAPHA
SAMETH          PLA
                TAX
                LDA YLEVEL
                STA LEVEL,X
                LDA PICPNT
                STA POINTER,X
                RTS

CALL            PHA
                LDA LEVEL,X
                STA YLEVEL
                LDA POINTER,X
                STA PICPNT
                JSR ADJUST
                PLA
                TAY
                TXA
                PHA
                TYA
                JSR GRAPH
                JMP SAMETH

ADJUST          LDA COL_BEGIN,X
                STA PNT2+1
                STA PNT6+1
                STA PNT7+1
                LDA COL_END,X
                STA PNT4+1
                STA PNT9+1
                LDA LIMIT,X
                STA PNT1+1
                STA PNT5+1
                STA PNTC+1
                SEC
                SBC #$01
                STA PNT10+1
                LDA ANDNUM,X
                STA PNT8+1
                LDA LWLIMIT,X
                STA PNTA+1
                STA PNTB+1
                LDA ECHECK,X
                STA PNTD+1
                TXA
                ASL
                TAX
                LDA DATPNT,X
                STA PNT3+1
                INX
                LDA DATPNT,X
                STA PNT3+2
                DEX
                TXA
                LSR
                TAX
                RTS

HGRAPH          STA HOLDIT
                LDA MOD,X
                SEC
                SBC HOLDIT
                BPL HDOWN
                LDA HOLDIT
                SEC
                SBC MOD,X
                STA COUNT
                LDA MOD,X
                STA DATCNT
                CLC
                ADC #$13
                STA XHOLD
HSTART2         LDA #$FF            ;PNT.5  Modified
                STA LINENUM
POINT1          LDA #$FF            ;Modified
                STA DATPNTL
POINT2          LDA #$FF            ;Modified
                STA DATPNTH
MOROFIT         LDY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY DATCNT
                LDA (DATPNTL),Y
                LDY XHOLD
                STA (SCREENL),Y
                LDA LINENUM
                INC LINENUM
POINT3          CMP #$FF            ;Modified
                BEQ NOMOROF
                LDA DATPNTL
                CLC
                ADC #$13
                STA DATPNTL
                BCC MOROFIT
                INC DATPNTH
                JMP MOROFIT
NOMOROF         INC XHOLD
                INC DATCNT
                DEC COUNT
                BEQ ALLDONE
                JMP HSTART2
ALLDONE         LDA HOLDIT
                STA MOD,X
                RTS

HDOWN           LDA MOD,X
                CLC
                ADC #$13
                STA XHOLD
                DEC XHOLD
POINT4          LDA #$FF            ;Modified
                STA LINENUM
MORDOWN         LDY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDA #$00
                LDY XHOLD
                STA (SCREENL),Y
                LDA LINENUM
                INC LINENUM
POINT5          CMP #$FF            ;Modified
                BNE MORDOWN
                LDA HOLDIT
                STA MOD,X
                RTS

ADJUSTR         LDA BEGLINS,X
                STA HSTART2+1
                STA POINT4+1
                LDA ENDLINS,X
                STA POINT3+1
                STA POINT5+1
                TXA
                ASL
                TAX
                LDA DATAS,X
                STA POINT1+1
                INX
                LDA DATAS,X
                STA POINT2+1
                DEX
                TXA
                LSR
                TAX
                RTS

UPDATE_PROFS    LDA #$FF
                STA NEXT_PROF
                LDY #0
:1              STY PROF_INDEX
                LDX MIN_OFFSETS,Y
                LDY #0
:2              LDA PRSNST,Y
                CMP PROFMIN,X
                BCC :3
                INX
                INY
                CPY #$07
                BNE :2
                LDA PROF_INDEX
                STA NEXT_PROF
                BPL :6                  ; always
:3              LDY PROF_INDEX
                INY
                CPY #5
                BNE :1

:6              LDA PROF_POS
                CMP NEXT_PROF
                BEQ :99
                JSR DRAW_PROF
                LDA NEXT_PROF
                JSR DRAW_PROF

                LDA NEXT_PROF
                BPL :77
                LDX PROF_POS
                BMI :99
                STA PROF_POS
                JSR DRAW_PICT
                PictClear 2;92;9;99
                PictTextAt 16;92;"C>ANCEL"
                PictEnd
                RTS

:77             LDX PROF_POS
                BPL :88
                STA PROF_POS
                JSR DRAW_PICT
                PictClear 2;92;9;99
                PictTextAt 16;92;"<SPACE>"
                PictEnd
                RTS

:88             STA PROF_POS
:99             RTS

DRAW_PROF       CMP #$FF
                BEQ :1
                JSR PROF_TO_TEXT
                LDX #10
                LDY #61
                JMP DRAW_TEXTBUF_XY
:1              RTS

MIN_OFFSETS     DB  0,7,14,21,28

; base/minimum stats by race
;                    HU  OR  ST  XX  DE
MINOFF          DB  $00,$08,$10,$18,$20 ; offset into MINMUM table (race * 8)

;                    IQ  ST  LR  UR  CR  OR  ??  ??
MINMUM          DB  $07,$11,$10,$11,$00,$25,$20,$28     ; 0-human
                DB  $13,$17,$05,$06,$00,$35,$25,$32     ; 1-orn
                DB  $11,$13,$09,$07,$00,$30,$35,$29     ; 2-stilicx
                DB  $16,$06,$10,$10,$00,$20,$40,$31     ; 3-xxtys
                DB  $03,$05,$14,$14,$00,$40,$15,$30     ; 4-deneb

; randomizing limit by race
ADRANGE         DB  $05,$02,$09,$02,$05

; vertical bar graph info by stat #
;                    IQ  ST  LR  UR  CR
COL_BEGIN       DB  $0A,$0F,$16,$1C,$22
COL_END         DB  $0F,$14,$1B,$21,$27
LIMIT           DB  $4B,$D7,$50,$41,$41
ANDNUM          DB  $07,$00,$00,$00,$00
LWLIMIT         DB  $00,$23,$00,$05,$00
ECHECK          DB  $FF,$22,$FF,$04,$FF

; base credits by race
;                    HU  OR  ST  XX  DE
BASECRD         DB  $50,$75,$25,$00,$50

DATPNT          DW  BRAIN
                DW  ARM
                DW  LEGS
                DW  ARROWS
                DW  CREDS

MOD             DB  $00,$00,$00

DATAS           DW  DNA
                DW  TRONICS
                DW  LBOLT

; horizontal bar graph info
;                    OR  IN  EN
BEGLINS         DB  165,154,177
ENDLINS         DB  172,161,183         ; inclusive

; minimum required stats, by profession
;                    IQ  ST  LR  UR  CR  OR  IN
PROFMIN         DB  $06,$21,$19,$20,$00,$45,$20     ; 0-warrior
                DB  $25,$10,$16,$15,$00,$20,$60     ; 1-android
                DB  $22,$14,$11,$11,$08,$45,$30     ; 2-cybernate
                DB  $14,$18,$17,$17,$00,$30,$45     ; 3-juicer
                DB  $23,$10,$14,$19,$00,$60,$15     ; 4-physician

;---------------------------------------

DRAW_BOX        LDA #OpColorViolet
                BNE BOX_CMN             ; always
ERASE_BOX       LDA #OpColorBlack1
BOX_CMN         JSR SET_COLOR
                LDX BOXNUM
UPDATE_BOX_N    STX TEMP
                JSR DRAW_PICT
                PictSwitch TEMP

:0              PictCase :1
                PictRect 80;116;96;126

:1              PictCase :2
                PictRect 98;116;152;126

:2              PictCase :3
                PictMoveTo 154;120
                PictVLineTo 111
                PictHLineTo 190
                PictVLineTo 120

:3              PictCase :4
                PictMoveTo 196;120
                PictVLineTo 111
                PictHLineTo 232
                PictVLineTo 120

:4              PictCase :5
                PictRect 236;116;276;126

:5              PictCase :6
                PictRect 4;138;104;148

:6              PictCase :END
                PictRect 154;121;232;131

:END            PictSwitchEnd
                PictEnd
                RTS

;---------------------------------------
