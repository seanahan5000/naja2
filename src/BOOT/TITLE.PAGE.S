;-------------------------------------------------------------------------------
;
; Original Naja title screen animation
;
;     Written ??/1983
;   Rewritten 10/2023
;
; NOTE: Much of the code has been left unchanged
;   in order to maintain the original sound timing.
;
;-------------------------------------------------------------------------------

GsFade          =   1
NajaFade        =   1

; LINENUM         EQU $00
BEGCOLM         EQU $C1
START2          EQU $C1
STARTS          EQU $C1
POINT           EQU $C1
; COLUMN          EQU $C2
COLUMN2         EQU $C2
LINECNT         EQU $C2
TOPLINE         EQU $C2
COLUMN4         EQU $C4
DATACOL         EQU $C4
NUMBER          EQU $C4
LINUM2          EQU $C4
PARTNUM         EQU $C4
PICNUM          EQU $C4
; SCRATCH         EQU $C5
GAP             EQU $C5
LINUM4          EQU $C5
STARTER         EQU $C6
CYCLE           EQU $C7
SPCOUNT         EQU $CA
DATAPNT         EQU $CA
ROW             EQU $CB
LENGTH          EQU $CC
HOWLONG         EQU $CC
DATAL           EQU $08
DATAH           EQU $09
PITCH           EQU $0D
PARTL           EQU $0D
PARTH           EQU $0E
BEGLINE         EQU $B2
PBEGLIN         EQU $B2
ENDLINE         EQU $B3
MBEGLIN         EQU $B3
BEGROW          EQU $B4
ENDROW          EQU $B5
AWAIT1          EQU $B6
AWAIT2          EQU $B7
SHIPARM         EQU $FFFF               ;DUMMY

; constants
            do GsFade
            else
BEGROWG         EQU $00
BEGROWS         EQU $10
ENDROWG         EQU $0F
ENDROWS         EQU $27
BEGLING         EQU $35
BEGLINS         EQU $51
ENDLING         EQU $54
ENDLINS         EQU $62
            fin
BEGROWA         EQU $22
ENDROWA         EQU $28
BEGLINA         EQU $55
ENDLINA         EQU $62
            do GsFade
            else
SOFBROW         EQU $10
SOFEROW         EQU $26
            fin
TOPLIN          EQU $93
BOTLINE         EQU $BB
BROWPR          EQU $0D
BROWES          EQU $10
BROWEN          EQU $13
BROWTS          EQU $16
EROWPR          EQU $0F
EROWES          EQU $12
EROWEN          EQU $15
EROWTS          EQU $18
APITCH1         EQU $10
APITCH2         EQU $01

STAR_BUFFER1    =   $9000
STAR_BUFFER2    =   $9100
STAR_BUFFER3    =   $9200
ARM_EVEN_BUFFER =   $9200               ; 2 pages
ARM_ODD_BUFFER  =   $9400               ; 2 pages

;-------------------------------------------------------------------------------

; Copy from current drawing page to memory buffer
;
;   left byte
;   top line
;   right byte (exclusive)
;   bottom line (exclusive)
;   memory ptr
HookCopyToMem   MAC
                DB  OpHook0
                DB  ]1,]2,]3,]4
                DW  ]5
                EOM

; Copy memory buffer to current drawing page
;
;   left byte
;   top line
;   right byte (exclusive)
;   bottom line (exclusive)
;   memory ptr
HookCopyFromMem MAC
                DB  OpHook1
                DB  ]1,]2,]3,]4
                DW  ]5
                EOM

;-------------------------------------------------------------------------------

; *** boot conditions ***
                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictShowPage
                PictEnd
;
; Draw star field
;
                LDX #<PICT_HOOKS
                LDY #>PICT_HOOKS
                JSR SET_PICT_HOOKS

                BIT KEYBRD
                BPL STAR_LOOP
                JMP MESSAGE

STAR_LOOP       JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictShowPage
                PictSetPage1
                PictClearPage
                PictCall DRAW_DOT_STARS
                PictCall DRAW_BIG_STARS
                HookCopyToMem $14;$5C;$23;$6B;STAR_BUFFER1
                HookCopyToMem $00;$3B;$08;$57;STAR_BUFFER2
                PictShowPage
                PictSetPage2
                PictImage SPACESHIP
                PictImageFill ARM_EVEN
                PictImageFill ARM_ODD
                HookCopyToMem $00;$00;$14;$10;ARM_EVEN_BUFFER
                HookCopyToMem $00;$10;$14;$20;ARM_ODD_BUFFER
                PictSetPage1
                PictEnd
;
; Slide space ship in three passes.
;
                LDA #$3B
                STA NXTSTEP+1
SLOOP           BIT KEYBRD
                BPL NOKEY10
                JMP GOMESS1
NOKEY10         JSR SLIDEIN

                ; correct some pixel errors from slide effect
                LDA #$80
                STA $223A
                STA $263A
                STA $3AB8
                STA $3EB8

                ; fix two long-time pixel errors
                STA $22B1
                STA $2BAE

                ; restore stars behind spaceship
                JSR DRAW_PICT
                HookCopyFromMem $00;$3B;$08;$57;STAR_BUFFER2
                PictEnd

                LDA NXTSTEP+1
                INC NXTSTEP+1
                CMP #$3D
                BNE SLOOP
                JMP ARM_IN
;
; Draw one pass of space ship slide.
;
SLIDEIN         LDA #$01
                STA START2
NXTSTEP         LDA #$3B                ; modified
                STA LINENUM
NEXTROW         LDA START2
                STA COLUMN2
                LDA #$27
                STA COLUMN4
                LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                EOR #$60
                STA SCREENH
NEXTCOL         LDY COLUMN4
                LDA (SCREENL),Y
                CMP #$80
                BEQ NOSTORE
                LDY COLUMN2
                STA (DESTINL),Y
NOSTORE         LDA CLICK
                DEC COLUMN4
                DEC COLUMN2
                LDA COLUMN2
                BPL NEXTCOL
                LDA LINENUM
                INC LINENUM
                INC LINENUM
                INC LINENUM
                CMP #$8C
                BCC NEXTROW
                LDA START2
                INC START2
                INC START2
                CMP #$27
                BNE NXTSTEP
                RTS
;
; Slide ship arm over then down
;
ARM_IN          LDA #$00
                JSR WAIT
                LDA #APITCH1
                STA AWAIT1
                LDA #APITCH2
                STA AWAIT2
                LDA #$1C
                STA STARTS
TIMEA           LDA #$5C
                STA LINENUM
                LDA STARTS
                LSR
                BCS :1
                LDX #<ARM_ODD_BUFFER
                LDY #>ARM_ODD_BUFFER
                BCC :2                  ; always
:1              LDX #<ARM_EVEN_BUFFER
                LDY #>ARM_EVEN_BUFFER
:2              STX DATAL
                STY DATAH
NOTHROW         LDA #$13
                STA DATACOL
                LDA STARTS
                STA COLUMN
                LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
MOROFRW         LDY DATACOL
                LDA (DATAL),Y
                LDY COLUMN
                CPY #$23
                BCC NOWORRY
                CPX #$62
                BCS NOWORRY
                ORA (SCREENL),Y
NOWORRY         STA (SCREENL),Y
                DEC AWAIT1
                BNE DO2
                LDA CLICK
                LDA #APITCH1
                STA AWAIT1
DO2             DEC AWAIT2
                BNE NODO
                LDA CLICK
                LDA #APITCH2
                STA AWAIT2
NODO            DEC DATACOL
                LDA COLUMN
                DEC COLUMN
                CMP #$14
                BNE MOROFRW
                LDA DATAL
                CLC
                ADC #$14
                STA DATAL
                BCC NOCARRY
                INC DATAH
NOCARRY         LDA LINENUM
                INC LINENUM
                CMP #$6B
                BNE NOTHROW
                LDA #$D0
                JSR WAIT
                LDA STARTS
                INC STARTS
                CMP #$25
                BEQ NOTIME
                JMP TIMEA
NOTIME          BIT KEYBRD
                BPL :SKIPA
                JMP GOMESS1

:SKIPA          JSR DRAW_PICT
                PictSetPage2
                HookCopyFromMem $14;$5C;$23;$6B;STAR_BUFFER1
                PictCopyTo $14;$6C;$27;$88
                PictSetPage1
                PictEnd

                LDA #$5C
                STA BEGLINE
LOOPINX         LDA #$01
                STA SPCOUNT
                LDA #$01
                STA BEGCOLM
                LDX BEGLINE
                STX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                EOR #$60
                STA SCREENH
                LDY #$13
MOVMORE         LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY #$26
                BNE MOVMORE
                LDA #$00
                STA LINECNT
                LDA #<ARM_EVEN_BUFFER
                STA NOTYET+1
                STA YET2+1
                STA YET3+1
                STA YET4+1
                STA YET5+1
                STA YET6+1
                LDA #>ARM_EVEN_BUFFER
                STA NOTYET+2
                STA YET2+2
                STA YET3+2
                STA YET4+2
                STA YET5+2
                STA YET6+2
                LDX #$02
                INC LINENUM
LOOPIN0         LDY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,Y
                STA DESTINH
                EOR #$60
                STA SCREENH
                LDA LINENUM
                CMP #$77
                BCC NODIAG
                CMP #$85
                BCC STILL
                LDX #$00
YET5            LDA SHIPARM,X
                LDY #$12
                STA (DESTINL),Y
                INX
YET6            LDA SHIPARM,X
                INY
                STA (DESTINL),Y
                LDX #$02
                JMP NODIAG
STILL           LDX BEGCOLM
                BNE YET4
                LDX #$01
YET3            LDA SHIPARM,X
                LDY #$13
                STA (DESTINL),Y
                LDX BEGCOLM
YET4            LDA SHIPARM,X
                LDY SPCOUNT
                AND MASKS,Y
                PHA
                TXA
                CLC
                ADC #$12
                TAY
                PLA
                ORA (SCREENL),Y
                STA (DESTINL),Y
                LDX #$02
NODIAG          LDY #$14
LOOPIN1         CPY #$23
                BCC NOTYET
                LDA LINECNT
                CMP #$05
                BCS NOTYET
YET2            LDA SHIPARM,X
                ORA (SCREENL),Y
                AND #$7F
                JMP SAMTING
NOTYET          LDA SHIPARM,X
                CMP #$80
                BNE SAMTING
                LDA (SCREENL),Y
SAMTING         STA (DESTINL),Y
                LDA CLICK
                LDA CLICK
                INY
                INX
                CPY #$26
                BNE LOOPIN1
                LDX #$02
                LDA NOTYET+1
                CLC
                ADC #$14
                STA NOTYET+1
                STA YET2+1
                STA YET3+1
                STA YET4+1
                STA YET5+1
                STA YET6+1
                BCC NOTCARY
                INC NOTYET+2
                INC YET2+2
                INC YET3+2
                INC YET4+2
                INC YET5+2
                INC YET6+2
NOTCARY         LDA LINENUM
                CMP #$77
                BCC NOSPEC
                LDA SPCOUNT
                INC SPCOUNT
                CMP #$07
                BNE NOSPEC
                LDA #$01
                STA SPCOUNT
                DEC BEGCOLM
NOSPEC          INC LINENUM
                LDA LINECNT
                INC LINECNT
                CMP #$0F
                BEQ NOLOOP0
                JMP LOOPIN0
NOLOOP0         LDA #$80
                JSR WAIT
                INC BEGLINE
                LDA BEGLINE
                CMP #$78
                BEQ LAUNCHR
                JMP LOOPINX

MASKS           DB  $00,$40,$60
                DB  $70,$78,$7C
                DB  $7E,$7F

LAUNCHR         BIT KEYBRD
                BPL NOKEY11
                JMP GOMESS1
NOKEY11         LDA #$00
                JSR WAIT
                JSR WAIT
                JSR WAIT

                LDA #$14
                STA STARTS
LAUNCHA         LDA #$60
                STA LINENUM
                LDA STARTS
                LSR
                BCC :1
                LDX #<LAUNCH_ODD
                LDY #>LAUNCH_ODD
                BCS :2                  ; always
:1              LDX #<LAUNCH_EVEN
                LDY #>LAUNCH_EVEN
:2              STX DATAL
                STY DATAH
GOROW           LDA #$06
                STA DATACOL
                LDA STARTS
                STA COLUMN
                LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
GOROW2          LDY DATACOL
                LDA (DATAL),Y
                LDY COLUMN
                CMP #$80
                BNE SKIPPER
                LDA SCREENH
                TAX
                EOR #$60
                STA SCREENH
                LDA (SCREENL),Y
                STX SCREENH
SKIPPER         STA (SCREENL),Y
                DEC DATACOL
                LDA COLUMN
                DEC COLUMN
                CMP #$14
                BNE GOROW2
                LDA DATAL
                CLC
                ADC #$07
                STA DATAL
                BCC NOTCARR
                INC DATAH
NOTCARR         LDA LINENUM
                INC LINENUM
                CMP #$75
                BNE GOROW

                LDA #$A0
                JSR WAIT
                LDA STARTS
                INC STARTS
                CMP #$1A
                BNE LAUNCHA

                LDA #$00
                JSR WAIT
                JSR WAIT

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictSetPage1
                PictEnd

                LDA #$17
                STA BEGROW
                LDA #$1A
                STA ENDROW
                LDA #$64
                STA TOPLINE
                LDA #$75
                STA ENDLINE
                LDA #$C6                ; DEC zp: pitch up
                STA HERE2A
                STA HERE2
                JSR CLOOP
                LDA #$E6                ; INC zp: pitch down
                STA HERE2A              ; NOTE: not HERE2

                JSR DRAW_PICT
                PictShowPage2
                PictClearPage
                PictEnd

                DEC TOPLINE
                DEC ENDLINE

; write a single line of $80 that can be watched for on the bus this

SYNC_BEAM       JSR SET_PAGE2
                LDX ENDLINE
                INX
                INX
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #$27
                LDA #$80
:1              STA (SCREENL),Y
                DEY
                BPL :1

; watch for $80 on the bus to know where the scanning beam is

                LDA #$00
                SEC
:2              PHA
:3              BIT $C057
                BMI :4
                SBC #$01
                BNE :3
                PLA
                SBC #$01
                BNE :2
                BEQ :5              ; always
:4              PLA
:5

NOTLAST         LDA #$00
                STA BEGROW
                LDA #$03
                STA ENDROW

                JSR DRAW_PICT
                PictSetPage2
                PictCall CDRAW
                PictSetPage1
                PictEnd

                JSR CDRAW2
                JSR CLOOP2
                BIT KEYBRD
                BPL NOKEY1
                JMP MESSAGE

NOKEY1          LDA ENDLINE
                SEC
                SBC #$08
                STA ENDLINE
                LDA TOPLINE
                CMP #$43
                BEQ CDONE
                SEC
                SBC #$08
                STA TOPLINE
                CMP #$43
                BNE NOTLAST
                LDA #$0D
                STA CPNT+1
                JMP NOTLAST
CDONE           LDA #$27
                STA CPNT+1
                LDA #$00
                JSR WAIT
                JMP GFADE
CLOOP           LDA #$1F
                STA PITCH
                LDA #$00
                STA POINT
CLOOPA          JSR CDRAW
                LDA BEGROW
                CMP #$27
                BEQ CEXIT
                INC BEGROW
                INC ENDROW
                LDA #$30
                STA LENGTH
                JSR NOISE
                JSR CDRAW
                LDA #$30
                JSR WAIT
                JMP CLOOPA
CEXIT           RTS

CLOOP2          JSR SHOW_PAGE1

                LDA #$3F
                JSR WAIT
                LDY #$0A
GOWAIT          PHA
                PLA
                DEY
                BPL GOWAIT

                JSR DRAW_PICT
                PictSetPage2
                PictCall CDRAW
                PictEnd

                INC BEGROW
                INC ENDROW
                JSR CDRAW2
                STA SCNDARY
                LDA #$3C
                JSR WAIT

                JSR DRAW_PICT
                PictSetPage1
                PictCall CDRAW
                PictEnd

                LDA BEGROW
CPNT            CMP #$27                ; modified
                BEQ CEXIT2
                INC BEGROW
                INC ENDROW
                JSR CDRAW2
                JMP CLOOP2
CEXIT2          RTS

CDRAW2          INC BEGROW
                INC ENDROW
                JSR CDRAW
                DEC BEGROW
                DEC ENDROW
                RTS
;
; Draw the flying letter "C"
;
CDRAW           LDA TOPLINE
                STA LINENUM
                LDA #$00
                STA POINT
CMORE0          LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY BEGROW
CMORE1          LDX POINT
                LDA CDATA,X
                CPY #$28
                BCS OFFIT
                EOR (SCREENL),Y
                STA (SCREENL),Y
OFFIT           INC POINT
                CPY ENDROW
                BEQ ROWOVER
                INY
                JMP CMORE1
ROWOVER         LDA LINENUM
                INC LINENUM
                CMP ENDLINE
                BNE CMORE0
                RTS

GFADE
            do GsFade
                JSR DRAW_PICT
                PictSetPage1
                PictImage GRAPHIC
                PictSetPage2
                PictEnd
                LDX #0
                JSR FADE_GS
            else
                JSR SET_PAGE2
                LDA #BEGROWG
                STA BEGROW
                LDA #ENDROWG
                STA ENDROW
                LDA #BEGLING
                STA BEGLINE
                LDA #ENDLING
                STA ENDLINE
                LDA #<GRAPHIC
                STA LOOPNT1+1
                LDA #>GRAPHIC
                STA SPOT1+1
                LDA #$04
                STA HERE+1
                LDA #$EA                ; NOP: no pitch change
                STA HERE2
                STA HERE2+1
                JSR FADEIN
            fin

                BIT KEYBRD
                BPL NOKEY2
                JMP MESSAGE

NOKEY2          LDA #$00
                JSR WAIT
                LDA #BEGROWA
                STA BEGROW
                LDA #ENDROWA
                STA ENDROW
                LDA #BEGLINA
                STA BEGLINE
                LDA #ENDLINA
                STA ENDLINE
ESOVER1         LDA #$00
                STA DATAPNT
                LDA BEGLINE
                STA LINENUM
ESOVER2         LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY BEGROW
ESOVER3         LDX DATAPNT
                LDA ES,X
                STA (SCREENL),Y
                INY
                INC DATAPNT
                CPY ENDROW
                BNE ESOVER3
                LDA LINENUM
                INC LINENUM
                CMP ENDLINE
                BNE ESOVER2
                BIT KEYBRD
                BPL NOKEY3
                JMP MESSAGE

NOKEY3          LDA #$60
                JSR WAIT
                LDA BEGROW
                DEC BEGROW
                DEC ENDROW
                CMP #$0D
                BNE ESOVER1
                LDA #$00
                JSR WAIT

            do GsFade
                JSR DRAW_PICT
                PictSetPage1
                PictImage SIMULATIONS
                PictSetPage2
                PictEnd
                LDX #1
                JSR FADE_GS
            else
                LDA #BEGROWS
                STA BEGROW
                LDA #ENDROWS
                STA ENDROW
                LDA #BEGLINS
                STA BEGLINE
                LDA #ENDLINS
                STA ENDLINE
                LDA #<SIMULATIONS
                STA LOOPNT1+1
                LDA #>SIMULATIONS
                STA SPOT1+1
                LDA #$06
                STA HERE+1
                LDA #$E6                ; INC zp: undo pitch NOP above
                STA HERE2
                LDA #<PITCH
                STA HERE2+1
                JSR FADEIN
            fin

                BIT KEYBRD
                BPL NOKEY4
                JMP MESSAGE

NOKEY4          JMP SOFTUP


            do GsFade
;
; Fade in a word ("Graphic" or "Simulation")
;
; TODO: clean these up
BEGCOL          =   BEGROW
ENDCOL          =   ENDROW
INDEX           =   STARTER
PHASE           =   POINT
DURATION        =   LENGTH
PITCH_DELAY     =   PITCH

FADE_GS         LDA :NOISE_DURS,X
                STA :NOISE_DUR+1
                LDA :NOISE_PITCHES,X
                STA :NOISE_PITCH+0
                LDA :BEGLINES,X
                STA BEGLINE
                LDA :ENDLINES,X
                STA ENDLINE
                LDA :BEGCOLS,X
                STA BEGCOL
                LDA :ENDCOLS,X
                STA ENDCOL
                LDA #1
                STA PITCH_DELAY
                LDX #6
:1              STX INDEX
                STX CYCLE
                LDX BEGLINE
:2              STX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                EOR #$60
                STA SCREENH
                LDY BEGCOL
                LDX CYCLE
:3              LDA (SCREENL),Y
                AND :MASKS,X
                ORA (DESTINL),Y
                STA (DESTINL),Y
                DEX
                BPL :4
                LDX #6
:4              INY
                CPY ENDCOL
                BNE :3
                STX CYCLE
:NOISE_DUR      LDA #$FF                ; modified
                JSR FADE_NOISE
                INC PITCH_DELAY
:NOISE_PITCH    INC PITCH_DELAY         ; modified
                LDX LINENUM
                INX
                CPX ENDLINE
                BNE :2
                LDX INDEX
                DEX
                BPL :1
                RTS

:NOISE_DURS     DB  $04,$08
:NOISE_PITCHES  DB  $A5,$E6             ; LDA zp, INC zp
:BEGCOLS        DB  $00,$10
:ENDCOLS        DB  $10,$28
:BEGLINES       DB  $35,$51
:ENDLINES       DB  $55,$63

:MASKS          DB  %10001000
                DB  %10100000
                DB  %10000010
                DB  %11000000
                DB  %10000100
                DB  %10010000
                DB  %10000001

FADE_NOISE      STA DURATION
:1              LDY PHASE
                LDA $6000,Y
                LDX #$08
:2              LSR
                BNE :3
                STA CLICK
:3              DEX
                BNE :2
                LDX PITCH_DELAY
:4              DEX
                BNE :4
                INC PHASE
                DEC DURATION
                BNE :1
                RTS
;
; Scroll up "Software, Inc."
;
DSTSTART        =   SCRATCH
DSTLINE         =   BEGLINE
SRCLINE         =   ENDLINE

SOFTUP          LDX #191
:1              STX DSTSTART
                LDY #$6A
:2              STX DSTLINE
                STY SRCLINE
                LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                LDX SRCLINE
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                EOR #$60
                STA SCREENH
                LDY #$11
:3              LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY #$25
                BNE :3
                LDY SRCLINE
                INY
                LDX DSTLINE
                INX
                CPY #$76+1              ; +1 to erase last line on scroll
                BEQ :4
                CPX #192
                BNE :2
:4              LDA #$14                ; delay to match timing of old/slow code
                JSR WAIT
                LDX DSTSTART
                DEX
                CPX #$6A
                BCS :1
                ; fall through
            else
;
; Fade in a word ("Graphic" or "Simulation")
;
FADEIN          LDA #$00
                STA STARTER
                STA CYCLE
                STA POINT
                LDA #$01
                STA PITCH
LOOPNT1         LDA #$FF                ; modified
                STA DATAL
SPOT1           LDA #$FF                ; modified
                STA DATAH
                LDA BEGLINE
                STA LINENUM
LOOPNT2         LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDA BEGROW
                STA ROW
LOOPNT3         LDY #$00
                LDA (DATAL),Y
                LDX CYCLE
                AND GSMASKS,X
                LDY ROW
                ORA (SCREENL),Y
                STA (SCREENL),Y
                INC DATAL
                BNE NOCARYD
                INC DATAH
NOCARYD         LDA CYCLE
                INC CYCLE
                CMP #$06
                BNE NOMOD
                LDA #$00
                STA CYCLE
NOMOD           LDA ROW
                INC ROW
                CMP ENDROW
                BNE LOOPNT3
HERE            LDA #$04
                STA LENGTH
                JSR NOISE
                LDA LINENUM
                INC LINENUM
                CMP ENDLINE
                BNE LOOPNT2
                INC STARTER
                LDA STARTER
                STA CYCLE
                CMP #$07
                BNE LOOPNT1
                RTS

GSMASKS         DB  $81,$90,$84
                DB  $C0,$82,$A0
                DB  $88

;
; Scroll up "Software, Inc."
;
SOFTUP          LDA #SOFBROW
                STA BEGROW
                LDA #SOFEROW
                STA ENDROW
                LDA #<SOFTWARE_INC
                STA MODPNT+1
                LDA #>SOFTWARE_INC
                STA MODPNT+2
                LDA #$00
                STA DATAPNT
                LDA #$BE
                STA BEGLINE
                LDA #$BF
                STA ENDLINE
MORE1           LDX #$BF
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY BEGROW
MORE2           LDX DATAPNT
MODPNT          LDA $FFFF,X
                STA (SCREENL),Y
                INY
                INC DATAPNT
                BNE CARRYNO
                INC MODPNT+2
CARRYNO         CPY ENDROW
                BNE MORE2
                LDA MODPNT+2
                BEQ NOYET
                LDA DATAPNT
                CMP #$34
                BEQ DATAON2
NOYET           DEC BEGLINE
                JSR SCROLL
                JMP MORE1
DATAON          DEC ENDLINE
DATAON2         DEC BEGLINE
                JSR SCROLL
                LDA BEGLINE
                CMP #$69
                BNE DATAON
            fin
;
; Delay and prep for bringing in "Presents..."
;
                BIT KEYBRD
                BPL NOKEY5
                JMP MESSAGE

NOKEY5          LDA #$EA
                STA PRLETTR
                STA ESLETTR
                STA ENLETTR
                STA TSLETTR
                LDA #$04
                STA GAPPER
                STA GAPPER+1
                STA GAPPER+2
                STA GAPPER+3
                LDA #$01
                STA ESDELAY
                LDA #$02
                STA ENDELAY
                LDA #$03
                STA TSDELAY
                LDA #$00
                LDX #$04
:LOOP1          JSR WAIT
                DEX
                BNE :LOOP1
                JMP PRESNTS

            do GsFade
            else
;
; Scroll loop used to bring in "Software, Inc."
;
SCROLL          LDX BEGLINE
:1              LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                INX
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY BEGROW
:2              LDA (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY ENDROW
                BNE :2
                CPX ENDLINE
                BNE :1
                RTS
            fin
;
; Squish in "Presents..."
;
PRESNTS         JSR PRLETTR
                JSR ESLETTR
                JSR ENLETTR
                JSR TSLETTR
                LDA #$B0
                JSR WAIT
                JMP PRESNTS
;
; Squish in "Pr"
;
PRLETTR         NOP
                LDA #BROWPR
                STA BEGROW
                LDA #EROWPR
                STA ENDROW
                LDA #$00
                STA DATAPNT
                LDA GAPPER
                STA GAP
                JSR SQUISHR
                LDA GAPPER
                CMP #$04
                BEQ FIRST1P
                DEC GAPPER
                INC GAP
                LDA #$00
                STA DATAPNT
                JSR SQUISHR
                LDA GAPPER
                BNE EXITPR
                LDA #$60                ; RTS
                STA PRLETTR
                JMP EXITPR
FIRST1P         DEC GAPPER
EXITPR          RTS
;
; Squish in "es"
;
ESLETTR         NOP
                LDA ESDELAY
                BEQ ESGO
                DEC ESDELAY
                JMP EXITES
ESGO            LDA #BROWES
                STA BEGROW
                LDA #EROWES
                STA ENDROW
                LDA #$1B
                STA DATAPNT
                LDA GAPPER+1
                STA GAP
                JSR SQUISHR
                LDA GAPPER+1
                CMP #$04
                BEQ FIRST1S
                DEC GAPPER+1
                INC GAP
                LDA #$1B
                STA DATAPNT
                JSR SQUISHR
                LDA GAPPER+1
                BNE EXITES
                LDA #$60                ; RTS
                STA ESLETTR
                JMP EXITES
FIRST1S         DEC GAPPER+1
EXITES          RTS
;
; Squish in "en"
;
ENLETTR         NOP
                LDA ENDELAY
                BEQ ENGO
                DEC ENDELAY
                JMP EXITEN
ENGO            LDA #BROWEN
                STA BEGROW
                LDA #EROWEN
                STA ENDROW
                LDA #$36
                STA DATAPNT
                LDA GAPPER+2
                STA GAP
                JSR SQUISHR
                LDA GAPPER+2
                CMP #$04
                BEQ FIRST1E
                DEC GAPPER+2
                INC GAP
                LDA #$36
                STA DATAPNT
                JSR SQUISHR
                LDA GAPPER+2
                BNE EXITEN
                LDA #$60                ; RTS
                STA ENLETTR
                JMP EXITEN
FIRST1E         DEC GAPPER+2
EXITEN          RTS
;
; Squish in "ts"
;
TSLETTR         NOP
                LDA TSDELAY
                BEQ TSGO
                DEC TSDELAY
                JMP EXITTS
TSGO            LDA #BROWTS
                STA BEGROW
                LDA #EROWTS
                STA ENDROW
                LDA #$51
                STA DATAPNT
                LDA GAPPER+3
                STA GAP
                JSR SQUISHR
                LDA GAPPER+3
                CMP #$04
                BEQ FIRST1T
                DEC GAPPER+3
                INC GAP
                LDA #$51
                STA DATAPNT
                JSR SQUISHR
                LDA GAPPER+3
                BNE EXITTS
                PLA
                PLA
                JMP DOTS
FIRST1T         DEC GAPPER+3
EXITTS          RTS

GAPPER          DB  $04,$04,$04,$04
ESDELAY         DB  $01
ENDELAY         DB  $02
TSDELAY         DB  $03
;
; Common routine to squish letters of "Presents"
;
SQUISHR         LDA #$05
                SEC
                SBC GAP
                ASL A
                ASL A
                PHA
                CLC
                ADC #TOPLIN
                STA LINENUM
                PLA
                STA ENDLINE
                LDA #BOTLINE
                SEC
                SBC ENDLINE
                STA ENDLINE
SQUISH          LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY BEGROW
:LOOP1          LDX DATAPNT
                LDA PRESENT,X
                EOR (SCREENL),Y
                STA (SCREENL),Y
                INC $CA
                CPY ENDROW
                BEQ :ROWOVER
                INY
                JMP :LOOP1
:ROWOVER        LDA LINENUM
                CMP ENDLINE
                BEQ SQUISHD
                CLC
                ADC GAP
                STA LINENUM
                JMP SQUISH
SQUISHD         RTS
;
; Draw the "..." on Presents
;
DOTS            LDA #$AB
                PHA
DOTS2           TAX
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDX #$00
                LDY #$19
MORDOTS         LDA DOTSTAB,X
                STA (SCREENL),Y
                INX
                INY
                CPX #$03
                BNE MORDOTS
                PLA
                CMP #$AB
                BNE DOTOUT
                LDA #$AC
                PHA
                JMP DOTS2
DOTOUT          JMP GOPLAN

DOTSTAB         DB  $0E,$47,$03

;
; White noise generator used during "C" launching
;
NOISE           LDY POINT
                LDA $6000,Y
                LDX #$08
:SHIFT          LSR A
                BNE :NEXTBIT
                STA CLICK
:NEXTBIT        DEX
                BNE :SHIFT
                LDX PITCH
:DELAY          DEX
                BNE :DELAY
                INC POINT
                DEC LENGTH
                BNE NOISE
HERE2A          INC PITCH
HERE2           INC PITCH
                RTS

GOPLAN          LDY #$06
                LDA #$00
MOPAUSE         BIT KEYBRD
                BPL NOKEY6
                JMP MESSAGE

NOKEY6          JSR WAIT
                DEY
                BPL MOPAUSE

                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall DRAW_DOT_STARS
                HookCopyToMem $0F;$33;$14;$5B;STAR_BUFFER1
                HookCopyToMem $17;$47;$1F;$75;STAR_BUFFER3
                PictEnd

                LDA #$33
                STA PLANET+1
                LDA #$47
                STA MOON+1

                JSR DRAW_PICT
                PictImage PLANET
                PictImage MOON
                PictShowPage
                PictSetPage2
                PictCopyToPage
                PictEnd

                LDA #$98
                STA PLANET+1
                LDA #$92
                STA MOON+1

                JSR DRAW_PICT
                HookCopyFromMem $0F;$33;$14;$5B;STAR_BUFFER1
                HookCopyFromMem $17;$47;$1F;$75;STAR_BUFFER3
                PictImageFill PLANET
                PictImageFill MOON
                PictSetPage1
                PictEnd

                LDA #$33
                STA PBEGLIN
                LDA #$47
                STA MBEGLIN
MORUPIT         LDA #$00
                STA NUMBER
LOOPER5         LDA #$A0
                JSR WAIT
                DEC MBEGLIN
                JSR DRAW_MOON
                INC NUMBER
                LDA NUMBER
                CMP #$03
                BNE LOOPER5
                LDA #$A0
                JSR WAIT
                DEC MBEGLIN
                DEC PBEGLIN
                JSR DRAW_MOON
                JSR DRAW_PLANET
                BIT KEYBRD
                BPL NOKEY9
                JMP GOMESS1
NOKEY9          LDA PBEGLIN
                CMP #$24
                BNE MORUPIT
                JMP LANDSCAPE_IN
;
; Scroll in ringed planet
;
DRAW_PLANET     LDA PBEGLIN
                STA LINENUM
                LDX #$98
:1              LDA LOBYTES,X
                STA DATAL
                LDA HIBYTES,X
                EOR #$60
                STA DATAH
                LDY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,Y
                STA DESTINH
                EOR #$60
                STA SCREENH
                INY
                STY LINENUM
                LDY #$0F
:2              LDA (DATAL),Y
                CMP #$80
                BNE :3
                LDA (SCREENL),Y
:3              STA (DESTINL),Y
                INY
                CPY #$14
                BNE :2
                INX
                CPX #192
                BNE :1
                RTS
;
; Scroll in "moon"
;
DRAW_MOON       LDA MBEGLIN
                STA LINENUM
                LDX #$92
:1              LDA LOBYTES,X
                STA DATAL
                LDA HIBYTES,X
                EOR #$60
                STA DATAH
                LDY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,Y
                STA DESTINH
                EOR #$60
                STA SCREENH
                INY
                STY LINENUM
                LDY #$17
:2              LDA (DATAL),Y
                CMP #$80
                BNE :3
                LDA (SCREENL),Y
:3              STA (DESTINL),Y
                INY
                CPY #$1F
                BNE :2
                INX
                CPX #192
                BNE :1
                RTS
;
; Scroll in landscape
;
LANDSCAPE_IN    JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictImage LANDSCAPE
                PictSetPage1
                PictEnd

                LDX #$BF
:1              STX BEGLINE
                LDA #$00
                STA LINECNT
                LDA #$4D
                STA LINUM4
:2              STX LINUM2
                LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                STA DESTINH
                LDX LINUM4
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                EOR #$60
                STA SCREENH

                LDY #$27
                LDX LINECNT
                CPX #$22
                BCS :5
:3              LDA (SCREENL),Y
                CMP #$80
                BEQ :4
                STA (DESTINL),Y
:4              DEY
                BPL :3
                BMI :6                  ; always
:5              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :5
:6              INC LINUM4
                INC LINECNT
                LDX LINUM2
                INX
                CPX #192
                BNE :2

                BIT KEYBRD
                BPL :7
                JMP GOMESS1
:7              LDX BEGLINE
                DEX
                CPX #$4C
                BNE :1
;
; Delay and then fade in "NAJA"
;
                LDA #$00
                JSR WAIT
                JSR WAIT
                JSR WAIT
FADE_NAJA
            do NajaFade
                JSR DRAW_PICT
                PictSetPage2
                PictCopyTo 0;85;24;114
                PictEnd
                LDX #0
:1              STX PARTNUM
                LDY :LETTERS_H,X
                STY PARTH
                LDA :LETTERS_L,X
                STA PARTL
                TAX
                JSR UNPACK
                LDY #0
                LDA (PARTL),Y
                STA :BEGCOL+1
                CLC
                INY
                INY
                ADC (PARTL),Y
                STA :ENDCOL+1
                DEY
                LDA (PARTL),Y
                STA :BEGLINE+1
                INY
                INY
                CLC
                ADC (PARTL),Y
                STA :ENDLINE+1
                LDX #6
:2              STX STARTER
                STX CYCLE
:BEGLINE        LDX #$FF                ; modified
:3              STX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA SCREENH
                EOR #$60
                STA DESTINH
:BEGCOL         LDY #$FF                ; modified
                LDX CYCLE
:4              LDA (SCREENL),Y
                BEQ :44
                EOR (DESTINL),Y
                AND :MASKS,X
                EOR (DESTINL),Y
                STA (DESTINL),Y
:44             LDA CLICK
                DEX
                BPL :5
                LDX #6
:5              INY

; delay so timing/sound is similar to old code

                PHA
                PLA
                PHA
                PLA
                PHA
                PLA
                PHA
                PLA
                PHA
                PLA

:ENDCOL         CPY #$FF                ; modified
                BNE :4
                STX CYCLE
                LDX LINENUM
                INX
:ENDLINE        CPX #$FF                ; modified
                BNE :3
                LDX STARTER
                DEX
                BPL :2
                LDA #$D0
                JSR WAIT
                LDX PARTNUM
                INX
                CPX #5
                BEQ :6
                JMP :1
:6              JSR SET_PAGE1
                JMP BUBBLER

:LETTERS_L      DB  <NAJA_N
                DB  <NAJA_A1
                DB  <NAJA_J
                DB  <NAJA_A2
                DB  <NAJA_UNDER

:LETTERS_H      DB  >NAJA_N
                DB  >NAJA_A1
                DB  >NAJA_J
                DB  >NAJA_A2
                DB  >NAJA_UNDER

:MASKS          DB  %10001000
                DB  %10000010
                DB  %10100000
                DB  %10000001
                DB  %10010000
                DB  %10000100
                DB  %11000000

            else ; !NajaFade

                LDA #$00
                STA PARTNUM
MORPART         LDY PARTNUM
                LDA LINEBEG,Y
                STA BEGLINE
                LDA LINEEND,Y
                STA ENDLINE
                LDA ROWBEG,Y
                STA BEGROW
                LDA ROWEND,Y
                STA ENDROW
                TYA
                ASL A
                TAY
                LDA STARTIN,Y
                STA DATAL
                INY
                LDA STARTIN,Y
                STA DATAH
                LDA #$D0
                JSR WAIT
                JSR FADENAJ
                LDA PARTNUM
                INC PARTNUM
                CMP #$04
                BNE MORPART

                JMP BUBBLER

LINEBEG         DB  $55,$56,$6C
                DB  $55,$89
LINEEND         DB  $8B,$8D,$9B
                DB  $93,$93
ROWBEG          DB  $02,$08,$09
                DB  $0E,$01
ROWEND          DB  $0B,$0F,$11
                DB  $17,$0D
STARTIN         DW  NAJA_N
                DW  NAJA_A1
                DW  NAJA_J
                DW  NAJA_A2
                DW  NAJA_UNDER

;
; Subroutine used to fade each letter of "NAJA"
;
FADENAJ         LDA #$00
                STA STARTER
FADPNT0         LDA BEGLINE
                STA LINENUM
                LDA DATAL
                STA PARTL
                LDA DATAH
                STA PARTH
                LDA STARTER
                STA CYCLE
FADPNT1         LDA #$00
                STA POINT
                LDA BEGROW
                STA ROW
                LDY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
FADPNT2         LDY POINT
                LDA (PARTL),Y
                BEQ DONTDO
                LDX CYCLE
                AND ISOMASK,X
                STA SCRATCH
                LDY ROW
                LDA (SCREENL),Y
                AND SLTMASK,X
                ORA SCRATCH
                STA (SCREENL),Y
DONTDO          LDA CLICK
                INC POINT
                LDA CYCLE
                INC CYCLE
                CMP #$06
                BNE NOENDCY
                LDA #$00
                STA CYCLE
NOENDCY         LDA ROW
                INC ROW
                CMP ENDROW
                BNE FADPNT2
                LDA PARTL
                CLC
                ADC POINT
                STA PARTL
                LDA PARTH
                ADC #$00
                STA PARTH
                LDA LINENUM
                INC LINENUM
                CMP ENDLINE
                BNE FADPNT1
                LDA STARTER
                INC STARTER
                CMP #$06
                BNE FADPNT0
                RTS

ISOMASK         DB  $C0,$84,$90
                DB  $81,$A0,$82
                DB  $88
SLTMASK         DB  $BF,$FB,$EF
                DB  $FE,$DF,$FD
                DB  $F7
            fin ; !NajaFade
;
; Delay and then animate green bubbles.
;
BUBBLER         LDA #$00
                JSR WAIT
                JSR WAIT
                JSR WAIT

                JSR DRAW_PICT
                PictSetPage2
                PictImageFill BUBBLES
                PictSetPage1
                PictEnd

                LDA #$00
                STA PICNUM
                STA HOWLONG
AGAIN           LDA PICNUM
                ASL A
                TAX
                LDA BDELAY,X
                DEC BDELAY,X
                CMP #$00
                BEQ ISTIME
                JMP NOTTIME
ISTIME          INX
                LDA BDELAY,X
                DEC BDELAY,X
                CMP #$00
                BEQ ISTIME2
                JMP NOTTIME
ISTIME2         TXA
                TAY
                DEY
                LDX PICNUM
                LDA CYCOUNT,X
                ASL A
                TAX
                LDA DELNUM,X
                STA BDELAY,Y
                INY
                INX
                LDA DELNUM,X
                STA BDELAY,Y

                LDY PICNUM
                LDA CYCOUNT,Y
                STA CYCLE
                JSR DRAW_BUBBLE

                LDA #$03
                CMP CYCOUNT
                BNE NOTINC
                LDA #$01
                CMP CYCOUNT+1
                BNE NOTINC
                LDA #$02
                CMP CYCOUNT+2
                BNE NOTINC
                LDA #$04
                CMP CYCOUNT+3
                BNE NOTINC
                INC HOWLONG
                LDA HOWLONG
                CMP #$06
                BNE NOTINC
                JMP STAR_LOOP

NOTINC          LDX PICNUM
                LDA CYCOUNT,X
                INC CYCOUNT,X
                CMP #$08
                BNE NOTTIME
                LDA #$00
                STA CYCOUNT,X
NOTTIME         LDA PICNUM
                INC PICNUM
                CMP #$03
                BEQ NEVGAIN
                JMP AGAIN
NEVGAIN         LDA #$00
                STA PICNUM
                BIT KEYBRD
                BPL GONGAIN

GOMESS1         JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictShowPage
                PictSetPage1
                PictClearPage
                PictEnd
                JMP MESSAGE

GONGAIN         JMP AGAIN

;
; Animate one bubble.
;
BUBBLE_INDEX    =   PICNUM
FRAME_INDEX     =   CYCLE
SRC_LINE        =   LINENUM
DST_LINE        =   POINT

DRAW_BUBBLE     LDX BUBBLE_INDEX
                LDA :BUBBLE_COLS,X
                STA :BEGCOL+1
                LDA :BUBBLE_ROWS,X
                STA DST_LINE

                LDY FRAME_INDEX
                LDA :FRAME_LINES+1,Y
                STA :ENDLINE+1
                LDX :FRAME_LINES,Y
:1              STX SRC_LINE
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                EOR #$60
                STA SCREENH

                LDY DST_LINE
                LDA LOBYTES,Y
                CLC
:BEGCOL         ADC #$FF                ; modified
                STA DESTINL
                LDA HIBYTES,Y
                STA DESTINH
                INY
                STY DST_LINE

                LDY #0
:2              LDA (SCREENL),Y
                CMP #$80
                BEQ :3
                STA (DESTINL),Y
:3              INY
                CPY #5
                BNE :2

                INX
:ENDLINE        CPX #$FF                ; modified
                BNE :1

                LDA FRAME_INDEX
                CMP #$05
                BNE :5
                JSR RANDOM              ; okay to use new RANDOM here
                AND #$03
                ADC #$02
                STA :WAIT_MOD+1
                LDY #$20
:4              LDA CLICK
:WAIT_MOD       LDA #$FF                ; modified
                JSR WAIT
                DEY
                BNE :4
:5              RTS

:FRAME_LINES    DB  0
                DB  15
                DB  30
                DB  45
                DB  60
                DB  75
                DB  90
                DB  105
                DB  120
                DB  135

:BUBBLE_COLS    DB  $12,$1A,$18,$1E
:BUBBLE_ROWS    DB  $B0,$B0,$A0,$98

BDELAY          DB  $B9,$04,$C0,$0D
                DB  $C5,$09,$C4,$05
CYCOUNT         DB  $03,$01,$02,$04

DELNUM          DB  $00,$18,$00
                DB  $0A,$00,$0A
                DB  $00,$0A,$00
                DB  $03,$00,$02
                DB  $00,$02,$00
                DB  $02,$00,$02
;
; Put up message text and signatures.
;   Assume displaying page 2 and page 1 has already been cleared
;   or, already displaying page 1
;
MESSAGE         JSR DRAW_PICT
                PictShowPage1
                PictSetPage2
                PictClearPage
                PictTextAt 12;15;"PRESS ANY KEY TO BEGIN THE SIMULATION AND"
                PictTextAt 54;24;"WE HOPE YOU ENJOY YOURSELF."
                PictTextAt 12;165;"COPYRIGHT <C> 1988  ALL RIGHTS RESERVED BY"
                PictTextAt 36;173;"GRAPHIC SIMULATIONS SOFTWARE, INC."
                PictTextAt_ 78;184
                TXC "SERIAL NUMBER "
SERIAL_MOD      TXT "000001"
                PictImage SIGNATURES
                PictShowPage
                PictSetPage1
                PictClearPage
                PictEnd

                BIT UNSTROB
:1              JSR RANDOM
                BIT KEYBRD
                BPL :1
                BIT UNSTROB
                JSR SHOW_PAGE
                JMP FINISH_BOOT

DRAW_DOT_STARS  LDX #0
MORSTAR         STX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #39
MORELIN         JSR RANDOM
                CMP #$07
                BCS TOOBIG
                TAX
                LDA STARS,X
                TAX
                JSR RANDOM
                BPL GREVIO
                TXA
                ORA #$80
                BNE STOREIT             ; always
GREVIO          TYA
                PHA
                AND #$01
                TAY
                LDA MASK,Y
                STA SCRATCH
                TXA
                AND SCRATCH
                BEQ OKAY
                PLA
                TAY
                JMP TOOBIG
OKAY            PLA
                TAY
                TXA
STOREIT         STA (SCREENL),Y
TOOBIG          DEY
                BPL MORELIN
                LDX LINENUM
                INX
                CPX #192
                BNE MORSTAR
                RTS

STARS           DB  $01,$02,$04
                DB  $08,$10,$20
                DB  $40
MASK            DB  $55,$2A

DRAW_BIG_STARS  LDA #$00
                STA POINT
:1              LDY POINT
                LDA SPOTS,Y
                STA LINENUM
                LDA #$00
                STA LINECNT
                INY
                LDA SPOTS,Y
                TAY
:2              LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDX LINECNT
                LDA SMALL1,X
                STA (SCREENL),Y
                INC LINENUM
                LDA LINECNT
                INC LINECNT
                CMP #$02
                BNE :2
                INC POINT
                LDA POINT
                INC POINT
                CMP #$0B
                BNE :1
                LDA #$12
                STA LINENUM
                LDA #$00
                STA POINT
:3              LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #$1A
:4              LDX POINT
                LDA BIG1,X
                STA (SCREENL),Y
                INC POINT
                INY
                CPY #$1C
                BNE :4
                LDA LINENUM
                INC LINENUM
                CMP #$1E
                BNE :3
                RTS

SMALL1          DB  $08,$1C,$08
SPOTS           DB  $B1,$17,$1A
                DB  $07,$2F,$1D
                DB  $BA,$19,$97
                DB  $06,$5B,$0C
BIG1            DB  $00,$01,$00
                DB  $01,$00,$01
                DB  $40,$03,$40
                DB  $03,$60,$07
                DB  $7A,$5F,$60
                DB  $07,$40,$03
                DB  $40,$03,$00
                DB  $01,$00,$01
                DB  $00,$01

;-------------------------------------------------------------------------------

PICT_HOOKS      DW  OP_COPY_TO_MEM
                DW  OP_COPY_FROM_MEM

LEFT            =   LEFT_DIV7
RIGHT           =   LEFT_MOD7

OP_COPY_TO_MEM  LDA #$38                ; SEC
                BNE COPY_MEM_CMN
OP_COPY_FROM_MEM
                LDA #$18                ; CLC
COPY_MEM_CMN    STA :SWITCHMOD
                LDA (OP_PTR),Y
                STA LEFT
                INY
                LDA (OP_PTR),Y
                STA TOP
                INY
                LDA (OP_PTR),Y
                STA RIGHT
                INY
                LDA (OP_PTR),Y
                STA BOTTOM
                INY
                LDA (OP_PTR),Y
                STA :SRCMOD+1
                STA :DSTMOD+1
                INY
                LDA (OP_PTR),Y
                STA :SRCMOD+2
                STA :DSTMOD+2
                INY
                STY OP_INDEX

                LDX #0
                LDY TOP
:1              STY TOP
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH

                LDY LEFT
:SWITCHMOD      CLC                     ; modified
                BCS :3

:SRCMOD         LDA $FFFF,X
                STA (SCREENL),Y
                INX
                BNE :2
                INC :SRCMOD+2
:2              INY
                CPY RIGHT
                BNE :SRCMOD
                BEQ :5                  ; always

:3              LDA (SCREENL),Y
:DSTMOD         STA $FFFF,X
                INX
                BNE :4
                INC :DSTMOD+2
:4              INY
                CPY RIGHT
                BNE :3

:5              LDY TOP
                INY
                CPY BOTTOM
                BNE :1
                SAME_PAGE_AS :1
                RTS

;-------------------------------------------------------------------------------
