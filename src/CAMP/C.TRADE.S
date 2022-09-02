
*-------------------------------
* TRADE ZPAGE

tVPNTL          =   $C0
tVPNTH          =   $C1
tLPNTL          =   $C2
tLPNTH          =   $C3
tSMAN           =   $C4
tDMAN           =   $C5
tSEMENT         =   $C6
tDEMENT         =   $C7
tSEOFF          =   $C8
tDEOFF          =   $C9
tLLINE          =   $CA
tRLINE          =   $CB

; TODO: clean up this scratch ZPAGE use
COUNTER         =   $03
SCRATCH         =   $06
ENDLINE         =   $06
BEGLINE         =   $07

*-------------------------------

                DUMMY SCRATCH_PAGE
LVISIBL         DS  11
RVISIBL         DS  11
TLINTABL        DS  11
LINTABR         DS  11
BUFFERL         DS  8
BUFFERS         DS  4
TANSWER         DS  4
                DEND

TRADE           JSR DRAW_PICT
                PictTextAt 16;70;(CANCEL)
                PictTextAt 86;88;(TRADE_FROM_WHO?)
                PictEnd

                JSR PICK_CHAR
                CPX #7
                BEQ TRADE_EXIT

                STX tSMAN
                TXA
                JSR SET_CHAR
                LDA #$FF
                STA LEGALS,X
                JSR TRADE_MARKER

                JSR DRAW_PICT
                PictTextAt 152;88;(WHO?)
                PictEnd

                JSR CNAME_TO_TEXT
                LDX #$98
                LDY #$58
                JSR DRAW_TEXTBUF_XY

                JSR DRAW_PICT
                PictTextAt 134;98;(TO_WHOM?)
                PictEnd

                JSR MENU_SELECT_NEXT
                CPX #7
                BNE GOT_BOTH

                LDX tSMAN
                JSR TRADE_MARKER

                ; TODO: this should go back to top instead of exiting?

TRADE_EXIT      JSR CLEAR_MID
                LDX #0
                JSR CAMP_MARKER
                LDA #$00
                JMP COPTION

GOT_BOTH        STX tDMAN
                TXA
                JSR SET_CHAR
                JSR TRADE_MARKER
                JSR CLEAR_MID
                LDA tSMAN
                JSR SET_CHAR

                JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictClear 0;69;40;192
                PictEnd

                LDA tSMAN
                JSR SET_CHAR
                LDX #$00
                JSR VISISUB

                JSR CNAME_TO_TEXT
                LDX #$29
                LDY #$58
                JSR DRAW_TEXTBUF_XY

                LDA tDMAN
                JSR SET_CHAR
                LDX #$02
                JSR VISISUB

                JSR CNAME_TO_TEXT
                LDX #$B5
                LDY #$58
                JSR DRAW_TEXTBUF_XY

                JSR FILLINS

                LDA TLINTABL+10
                CLC
                ADC #$0A
                STA :RECT_MOD+4

                JSR DRAW_PICT
                PictSetOrange
:RECT_MOD       PictRect $01;$54;$115;$BF
                PictEnd

                LDA tSMAN
                JSR SET_CHAR
                LDA #$09
                LDX #$00
                JSR WRITCOL
                LDA tDMAN
                JSR SET_CHAR
                LDA #$95
                LDX #$02
                JSR WRITCOL

                JSR DRAW_TRADE_WHICH
                STA SCNDARY

                LDA tSMAN
                JSR SET_CHAR
                LDA #$23
                LDX #$00
                JSR EMENTER
                LDA tDMAN
                JSR SET_CHAR
                LDA #$AF
                LDX #$02
                JSR EMENTER
RETRADE         LDA #$0A
                STA CURSOR
REFIRST         LDX #$00
                JSR SETPNTS
                LDA #$1B
                STA XPNT
                LDA tSMAN
                JSR FORTDWN
                BNE NOLEAVS

                JSR DRAW_PICT
                PictSetPage1
                PictCall TRADE_MARKERS
                PictCall CLEAR_MID
                PictShowPage
                PictEnd

                JSR RECALC_ALL
                JMP TRADE_EXIT

RECALC_ALL      LDA tSMAN
                JSR :SUBA
                LDA tDMAN
:SUBA           JSR SET_CHAR
                JMP CALC_ALL

CLEAR_MID       JSR DRAW_PICT
                PictClear 0;$45;40;$7C
                PictEnd
                RTS

NOLEAVS         STA tSEMENT
                TAY
                JSR TMARKIT2

                JSR DRAW_PUT_WHERE

                LDA #$0A
                STA CURSOR
                LDX #$02
                JSR SETPNTS
                LDA #$A7
                STA XPNT
                LDA tDMAN
                JSR FORTDWN
                BNE NOCANCS
                LDA #$1B
                STA XPNT
                LDA tSEMENT
                STA CURSOR
                TAY
                JSR TMARKIT2
                DEC CURSOR
                JSR DRAW_TRADE_WHICH
                JMP REFIRST

FORTDWN         JSR SET_CHAR
                JSR TOLEGAL
                JSR TBLINK
                LDA CURSOR
                CMP #$0A
                RTS

NOCANCS         STA tDEMENT
                LDA #$1B
                STA XPNT
                LDY tSEMENT
                JSR TMARKIT2
                JSR TRADER
                JSR DRAW_TRADE_WHICH
                JMP RETRADE

TBLINK          LDX #<TRADE_CDEF
                LDY #>TRADE_CDEF
                JSR MENU_INIT
                JMP MENU_SELECT
*-------------------------------
TRADE_CDEF      DB  $0B
                DB  $00
                DW  :CURSIT

:CURSIT         LDY CURSOR
                LDA (tLPNTL),Y
                TAY
                LDX XPNT
                JMP DRAW_TRIANGLE
*-------------------------------

DRAW_TRADE_WHICH LDX TLINTABL+10
                STX :LEAVE_MOD+2
                JSR DRAW_PICT
                PictClear 6;73;34;80
                PictTextAt 47;73;(TRADE_WHICH_PIECE_OF_EQUIPMENT?)
                PictClear 5;164;34;171
:LEAVE_MOD      PictTextAt 35;181;(LEAVE)
                PictEnd
                RTS

DRAW_PUT_WHERE  LDX TLINTABL+10
                STX :CANCEL_MOD+2
                JSR DRAW_PICT
                PictClear 6;73;34;80
                PictTextAt 68;73;(PUT_THE_EQUIPMENT_WHERE?)
                PictClear 5;164;34;171
:CANCEL_MOD     PictTextAt 175;181;(CANCEL)
                PictEnd
                RTS

TMARKIT2        LDA (tLPNTL),Y
                TAY
                LDX XPNT
                INX
                JMP DRAW_MARKER

TRADER          LDA tSEMENT
                JSR ECALC
                STY tSEOFF
                LDA tDEMENT
                JSR ECALC
                STY tDEOFF
                LDA tDMAN
                JSR SET_CHAR
                LDA CHARDL
                STA POINTL
                LDA CHARDH
                STA POINTH
                LDA tSMAN
                JSR SET_CHAR
                LDA tSEOFF
                STA COUNT
                LDA tDEOFF
                STA COUNTER
                LDX #$03
SWAPS           LDY COUNT
                LDA (CHARDL),Y
                PHA
                LDY COUNTER
                LDA (POINTL),Y
                LDY COUNT
                STA (CHARDL),Y
                PLA
                LDY COUNTER
                STA (POINTL),Y
                INC COUNT
                INC COUNTER
                DEX
                BPL SWAPS
                LDA #$0E    
                STA COUNTER
SCLOOPD         LDY tSEMENT
                LDA TLINTABL,Y
                STA tLLINE
                LDY tDEMENT
                LDA LINTABR,Y
                STA tRLINE

                LDA #$07
                STA COUNT
SCLOOPC         LDX tLLINE
                JSR SET_SOURCE_LINE
                LDX tRLINE
                JSR SET_DEST_LINE
                LDY #$26    
                LDA (DESTINL),Y
                PHA
                DEY
SCLOOPA         LDA (DESTINL),Y
                INY
                STA (DESTINL),Y
                DEY
                DEY
                CPY #$18    
                BNE SCLOOPA
                LDY #$12    
                LDA (SCREENL),Y
                LDY #$19    
                STA (DESTINL),Y
                LDY #$11    
SCLOOPB         LDA (SCREENL),Y
                INY
                STA (SCREENL),Y
                DEY
                DEY
                CPY #$04    
                BNE SCLOOPB
                INY
                PLA
                STA (SCREENL),Y
                INC tLLINE
                INC tRLINE
                DEC COUNT
                BNE SCLOOPC
                DEC COUNTER
                BNE SCLOOPD

                LDA #$05
                STA XPNT
                LDA tSMAN
                JSR SET_CHAR
                LDA tSEMENT
                STA CURSOR
                LDX #$00
                JSR SETPNTS
                JSR CRUNCH
                LDA #$19    
                STA XPNT
                LDA tDMAN
                JSR SET_CHAR
                LDA tDEMENT
                STA CURSOR
                LDX #$02
                JSR SETPNTS
CRUNCH          LDA CURSOR
                CMP #$04
                BCC GOCRUT  
                CMP #$09
                BNE NOCRUT  
GOCRUT          JMP CRUOUT
NOCRUT          LDY #profrace
                LDA (CHARDL),Y
                BPL NOCRUT2
                LDA CURSOR
                CMP #$04
                BEQ GOCRUT
NOCRUT2         LDA CURSOR
                JSR ECALC
                LDA (CHARDL),Y
                CMP #$FF    
                BNE GOCRUT
                LDY CURSOR  
                LDA (tLPNTL),Y
                STA BEGLINE 
                INC BEGLINE 
                LDY #$0A
                LDA (tLPNTL),Y
                STA ENDLINE
                DEC ENDLINE

                LDA #$07
                STA COUNT
CRLOOP3         LDX BEGLINE
CRLOOP2         JSR SET_SOURCE_LINE
                JSR SET_DEST_LINE
                INX
                INX
                LDA XPNT
                CLC
                ADC #$0E
                STA CMOD+1
                LDY XPNT
CRDLOOP1        LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
CMOD            CPY #$00
                BNE CRDLOOP1
                CPX ENDLINE
                BNE CRLOOP2
                DEC COUNT
                BPL CRLOOP3

                LDA CURSOR
                JSR ECALC
                LDA #$65
                STA ENDLINE
                BNE TSNEAKY
TSLIDES         LDA (CHARDL),Y
                DEY
                DEY
                DEY
                DEY
                STA (CHARDL),Y
                INY
TSNEAKY         INY
                INY
                INY
                INY
                CPY ENDLINE
                BNE TSLIDES
                DEY 
                DEY 
                DEY 
                DEY 
                LDX #$04
                LDA #$FF
TERASEM         STA (CHARDL),Y
                INY
                DEX
                BNE TERASEM
CRUOUT          RTS

ECALC           ASL
                ASL
                CLC
                ADC #e3_UPLFT
                TAY
                RTS

TOLEGAL         LDA #$04
                STA TOSKIP+1
                LDY #$0A
TOLOOP1         LDA (tVPNTL),Y
                STA LEGALS,Y
                DEY
                BPL TOLOOP1
                LDA tVPNTL
                CMP #<LVISIBL
                BNE DODESTI
                LDY #profrace
                LDA (CHARDL),Y
                BPL NORMCHR
                INC TOSKIP+1
                JSR ROBMOST
NORMCHR         JMP TOSKIP

DODESTI         LDY #profrace
                LDA (CHARDL),Y
                BPL NORMDST
                LDA tSMAN
                JSR SET_CHAR
                LDA tSEMENT
                JSR ECALC
                LDA (CHARDL),Y
                PHA
                LDA tDMAN
                JSR SET_CHAR
                PLA
                JSR ROB_EQUIP
                BNE NOTMOST
                JSR ROBMOST
                JMP NORMDST
NOTMOST         JSR ROBSOME
NORMDST         LDA tSMAN
                JSR SET_CHAR
                LDY #profrace
                LDA (CHARDL),Y
                PHP
                LDA tDMAN
                JSR SET_CHAR
                PLP
                BPL TOSKIP
                LDA tSEMENT
                BEQ ISOR
                CMP #$02
                BNE TOSKIP
ISOR            LDX #$09    
ISOLOOP         LDA LEGALS,X    
                BNE ISOKAY
                TXA
                JSR ECALC
                LDA (CHARDL),Y
                JSR ROB_EQUIP
                BEQ ISOKAY
                JSR NOA
ISOKAY          DEX
                BPL ISOLOOP
TOSKIP          LDA #$04            ;Modified
                STA COUNT
TOLOOP2         JSR ECALC
                LDA (CHARDL),Y
                CMP #$FF
                BEQ TOLOOP3
                INC COUNT
                LDA COUNT
                CMP #$0A
                BNE TOLOOP2
TOOUT           RTS
TOLOOP3         LDA COUNT
                CMP #$09
                BEQ TOOUT
                INC COUNT
                LDY COUNT
                LDA #$FF
                STA LEGALS,Y
                BNE TOLOOP3         ;Always

ROB_EQUIP       CMP #$FF
                BEQ OKAY
                CMP #$58
                BEQ OKAY
                CMP #$59
                BEQ OKAY
                CMP #$5C
OKAY            RTS 

ROBMOST         LDX #0
                LDY #e3_ROBLFT
                JSR :SUBA
                LDX #2
                LDY #e5_ROBRGT
:SUBA           LDA (CHARDL),Y
                CMP #$FF
                BEQ NOB
                CMP #$59    
                BNE NOB
                INY
                INY
                INY
                INY
                LDA (CHARDL),Y
                CMP #$FF
                BNE NOA
                RTS

ROBSOME         LDX #0
                LDY #e3_ROBLFT
                JSR SOMER
                LDX #2
                LDY #e5_ROBRGT
SOMER           JSR NOA
                LDA (CHARDL),Y
                CMP #$59
                BEQ SOMOUT
NOB             INX
NOA             LDA #$FF
                STA LEGALS,X    
SOMOUT          RTS

VISISUB         JSR SETPNTS
                LDA #$FF
                LDY #$0A
VISLOOP         STA (tVPNTL),Y
                DEY
                BPL VISLOOP
                LDY #profrace
                LDA (CHARDL),Y
                BPL TROBSKIP
                LDY #$03
                LDA #$00
TRHLOOP         STA (tVPNTL),Y
                DEY
                BPL TRHLOOP
VISKIP          LDY #$04
                STA (tVPNTL),Y
                BNE NOBACKS         ;Always
TROBSKIP        LDA #$00
                TAY 
                STA (tVPNTL),Y
                INY
                STA (tVPNTL),Y
                LDY #profrace
                LDA (CHARDL),Y
                AND #%00001111
                CMP #deneb
                BNE NOTDENE
                LDA #$00
                LDY #$02
                STA (tVPNTL),Y
                INY
                STA (tVPNTL),Y
NOTDENE         LDY #back
                LDA (CHARDL),Y
                BEQ NOBACKS
                CLC
                ADC #$04
                STA SCRATCH
                LDY #$04
                LDA #$00
VBLOOP          STA (tVPNTL),Y
                INY
                CPY SCRATCH
                BNE VBLOOP
NOBACKS         LDY #$0A    
                STA (tVPNTL),Y
                RTS

FILLINS         LDA #$62    
                STA TLINTABL
                STA LINTABR
                LDA #$6A
                STA TLINTABL+1
                STA LINTABR+1
                LDA #$72
                STA COUNT
                LDA LVISIBL+2
                BEQ ONEDEN
                LDA RVISIBL+2
                BNE NODENS
ONEDEN          LDA #$72
                STA TLINTABL+2
                STA LINTABR+2
                LDA #$7A
                STA TLINTABL+3
                STA LINTABR+3
                LDA #$82
                STA COUNT
NODENS          LDY #$04
LNTLOOP         LDA LVISIBL,Y
                BEQ CANLIN
                LDA RVISIBL,Y
                BNE LEACANC
CANLIN          LDA COUNT
                STA TLINTABL,Y
                STA LINTABR,Y
                CLC
                ADC #$08
                STA COUNT
                INY
                CPY #$0A
                BNE LNTLOOP
LEACANC         LDA COUNT
                CLC
                ADC #$02    
                STA TLINTABL+10
                STA LINTABR+10
                RTS

WRITCOL         STA XPNT
                JSR SETPNTS
                LDY #$03
WRTLOOP         LDA WRDATA,Y
                STA TEXTBUF,Y
                DEY
                BPL WRTLOOP
                LDY #profrace
                LDA (CHARDL),Y
                BPL ROSKIP2
                LDA #$00
                STA COUNT
                STA COLMOD+1
COLOOP1         LDA #$0A
COLMOD          STA TEXTBUF
                LDA #$01
                STA COLMOD+1
COLOOP2         LDY COUNT
                LDA (tLPNTL),Y
                TAY
                LDX XPNT
                JSR DRAW_TEXTBUF_XY
                INC COUNT
                LDA COUNT
                CMP #$04
                BEQ DENNO
                LDA TEXTBUF+1
                CMP #$0A
                BNE COLOOP1
                LDA #$1C
                STA TEXTBUF+1
                BNE COLOOP2         ;Always

ROSKIP2         LDY #$02
                LDA (tVPNTL),Y
                BEQ DENYES
                LDA #$0A
                STA TEXTBUF
DENYES          LDA #$00
                JSR WRITSUB
                LDA TEXTBUF
                CMP #$0A
                BEQ DENNO
                LDA #$16
                STA TEXTBUF
                STA TEXTBUF+1
                LDA #$02
                JSR WRITSUB
DENNO           LDA #$0C
                STA TEXTBUF
                LDA #$01
                STA TEXTBUF+1
                LDA #$04
                STA COUNT
VSLOOPA         LDY COUNT
                LDA (tVPNTL),Y
                BNE VISDOUT
                LDA (tLPNTL),Y
                TAY
                LDX XPNT
                JSR DRAW_TEXTBUF_XY
ROSKIP1         INC COUNT
                INC TEXTBUF+1   
                LDA TEXTBUF+1   
                CMP #$07
                BNE VSLOOPA
VISDOUT         RTS

WRDATA          USR (UL:)

WRITSUB         TAY
                PHA
                LDA (tLPNTL),Y
                TAY
                LDX XPNT
                JSR DRAW_TEXTBUF_XY
                LDA #$1C
                STA TEXTBUF+1   
                PLA
                TAY
                INY
                LDA (tLPNTL),Y
                TAY
                LDX XPNT
                JMP DRAW_TEXTBUF_XY

VISIS           DW  LVISIBL
                DW  RVISIBL
LINTS           DW  TLINTABL
                DW  LINTABR

EMENTER         STA XPNT
                JSR SETPNTS 
                LDA #$00
                STA COUNT
EPMLOOP         TAY
                LDA (tVPNTL),Y
                BNE NOVISI
                TYA
                JSR ECALC
                LDX #$00
TOETAB          LDA (CHARDL),Y
                STA ETABLE,X
                INY
                INX
                CPX #$04
                BNE TOETAB
                LDY COUNT
                LDA (tLPNTL),Y
                STA YPNT
                JSR EQUIP1
                LDX XPNT
                LDY YPNT
                JSR DRAW_TEXTBUF_XY
NOVISI          INC COUNT
                LDA COUNT
                CMP #$0A
                BNE EPMLOOP
                RTS

SETPNTS         LDA VISIS,X
                STA tVPNTL
                LDA VISIS+1,X
                STA tVPNTH
                LDA LINTS,X
                STA tLPNTL
                LDA LINTS+1,X
                STA tLPNTH
                RTS

TRADE_MARKERS   LDX tSMAN
                JSR TRADE_MARKER
                LDX tDMAN
TRADE_MARKER    LDY YPOINTS,X
                LDX #$06
                JMP DRAW_MARKER
