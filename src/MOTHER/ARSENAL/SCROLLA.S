TALKER          BIT UNSTROB
                ;*** JSR DRIVE_OFF

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DOTEXT
                PictSetPage1
                PictEnd

                LDA KEYBRD
                BPL LOOP2
KEYOUT          BIT UNSTROB
                CMP #$9B                ; escape
                BNE :1
                PLA
                PLA
                JMP GOBACK

:1              ;*** JSR DRIVE_ON
                PLA
                PLA
                JMP SMAINER

LOOP2           LDA #$00
                STA COUNT
LOOP3           LDX COUNT
                DEC DELWAIT,X
                BNE SKIP3B
                LDA DELMAX,X
                STA DELWAIT,X
                TXA
                JSR SCROLL
                LDA KEYBRD
                BMI KEYOUT
                LDX COUNT
                INC XSPOTS,X
                LDA XSPOTS,X
                CMP #$28
                BNE SKIP3A
                LDA #$00
                STA XSPOTS,X
                LDA YSPOTS,X
                CLC
                ADC #$07
                STA YSPOTS,X
                CMP YENDS+1,X
                BNE SKIP3A
                LDA YENDS,X
                STA YSPOTS,X
SKIP3A          LDA OPENER,X
                CMP #$CC
                BNE GOPEN
                DEC MOUNUMB,X
                BNE MOUCOMN
                LDA #$AA
                STA OPENER,X
                BNE MOUCOMN
GOPEN           LDA MOUNUMB,X
                CMP #$03
                BEQ REVERSE
                INC MOUNUMB,X
                LDX COUNT
                JSR RANDOM
                AND #$03
                BNE MOUCOMN
REVERSE         LDA #$CC
                STA OPENER,X
MOUCOMN         LDA MOUNUMB,X
                JSR MOUTHER
SKIP3B          INC COUNT
                LDA COUNT
                CMP #$03
                BNE LOOP3
                LDA #$10
                JSR WAIT
                JMP LOOP2

MOUTHER         ASL
                ASL
                ASL
                STA POINTER
                LDX COUNT
                LDA MOUTHX,X
                TAX
                CLC
                ADC #$04
                STA ENDLINE2
:1              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY POINTER
                LDA MOUTHS,Y
                LDY #$0D
                STA (SCREENL),Y
                INC POINTER
                LDY POINTER
                LDA MOUTHS,Y
                LDY #$0E
                STA (SCREENL),Y
                INC POINTER
                INX
                CPX ENDLINE2
                BNE :1
                RTS

MOUTHX          DB  $10,$15,$1A
MOUTHS          DB  $55,$2A,$55
                DB  $2A,$51,$22
                DB  $05,$28
                DB  $55,$2A,$55
                DB  $2A,$01,$20
                DB  $05,$28
                DB  $55,$2A,$05
                DB  $28,$01,$20
                DB  $05,$28
                DB  $05,$28,$01
                DB  $20,$01,$20
                DB  $05,$28
OPENER          DB  $AA,$CC,$AA
MOUNUMB         DB  $00,$02,$00
DELWAIT         DB  $20,$40,$60
DELMAX          DB  $68,$7C,$88

SCROLL          TAY
                LDA YLINES,Y
                STA LCOUNT1
                CLC
                ADC #$07
                STA ENDLINE2
                LDA YSPOTS,Y
                PHA
                LDA #$01
                STA COLUMN
:1              LDX LCOUNT1
:2              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY COLUMN
                LDA (SCREENL),Y
                DEY
                STA (SCREENL),Y
                INX
                CPX ENDLINE2
                BNE :2
                INC COLUMN
                LDA COLUMN
                CMP #$28
                BNE :1
                PLA
                STA LCOUNT2
                CLC
                ADC #$07
                STA ENDLINE2
:3              LDX LCOUNT1
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDX LCOUNT2
                LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                EOR #$60
                STA DESTINH
                LDX COUNT
                LDY XSPOTS,X
                LDA (DESTINL),Y
                LDY #$27
                STA (SCREENL),Y
                INC LCOUNT1
                INC LCOUNT2
                LDA LCOUNT2
                CMP ENDLINE2
                BNE :3
                LDA KEYBRD
                BPL :5
                CMP #$93                ; Control-S to stop/start scrolling
                ; *** TODO: this doesn't work in dbug emulator
                ; *** control key treated as unique key press
                BNE :5
:4              BIT KEYBRD
                BPL :4
                BIT UNSTROB
:5              RTS

YLINES          DB  $9E,$AA,$B6
YSPOTS          DB  $00,$3F,$7E
XSPOTS          DB  $00,$00,$00
YENDS           DB  $00,$3F,$7E
                DB  $AF

DOTEXT          LDA #$00
                STA LINECNT2
                LDA #<TSET1
                STA ADPNTL
                LDA #>TSET1
                STA ADPNTH
:1              LDY #$00
                LDX #$00
:2              LDA (ADPNTL),Y
                CMP #$FF
                BEQ :6
                STA TEXTBUF,X
                INY
                INX
                CPX #$2F
                BNE :2
                TYA
                CLC
                ADC ADPNTL
                STA ADPNTL
                LDA ADPNTH
                ADC #$00
                STA ADPNTH
                LDA #TextLineEnd
                STA TEXTBUF,X
:3              DEX
                LDA TEXTBUF,X
                CMP #TextSpace
                BNE :3
                LDA #TextLineEnd
                STA TEXTBUF,X
                TXA
                PHA
:4              DEX
                LDA TEXTBUF,X
                CMP #$0A
                BNE :4
                LDA #TextLineEnd
                STA TEXTBUF,X
                TXA
                PHA
                LDX #0
                LDY LINECNT2
                JSR DRAW_TEXTBUF_XY
                PLA
                JSR TEXSUB
                PLA
                JSR TEXSUB
                LDA KEYBRD
                BMI :6
:5              LDA LINECNT2
                CLC
                ADC #$07
                STA LINECNT2
                BNE :1
:6              RTS

TEXSUB          TAX
                LDA #TextSpace
                STA TEXTBUF,X
                LDY XSHIFT
                BNE :1
                LDY #7
                DEC XCOORD
:1              DEY
                STY XSHIFT
                TXA
                CLC
                ADC #<TEXTBUF
                TAX
                LDY #>TEXTBUF
                JMP DRAW_TEXT

TSET1           TXC "ALLOW ME TO INTRODUCE OURSELVES.  WE'RE PREET-G"
                TXC "LAVIS-WURNN, MEDIATORS OF SALES AND PROUD OWNER"
                TXC "S OF \"THE ARSENAL\", A DIVISION OF G.S.I. ENTERP"
                TXC "RISES.  FOR THOSE OF YOU UNFAMILIAR WITH THE AB"
                TXC "ILITIES OF OUR RACE, YOU MAY BE INTERESTED TO K"
                TXC "NOW THAT WE HAVE THREE SEPARATE BRAIN/VOICE CON"
                TXC "NECTIONS WHICH MAKE US CAPABLE OF SIMULTANEOUS "
                TXC "SPEECH.  WE'RE FLUENT IN 173 LANGUAGES, AND OUR"
                TXC " VOICES COVER A RANGE OF 21 OCTAVES.           "

TSET2           TXC "FOR EQUIPMENT DESCRIPTIONS, PLEASE REFER TO YOU"
                TXC "R FIVE PLANETS TACTICAL FORCE MANUAL.  \"THE ARS"
                TXC "ENAL\" WILL NOT BE HELD RESPONSIBLE FOR ANY DAMA"
                TXC "GE, INJURY, OR DEATH CAUSED BY MALFUNCTIONING O"
                TXC "R IMPROPERLY USED EQUIPMENT.  WE ALSO RESERVE T"
                TXC "HE RIGHT TO WITHOLD ALL INFORMATION REGARDING P"
                TXC "AST OWNERSHIP OF EQUIPMENT.  \"THE ARSENAL\" DOES"
                TXC " NOT OFFER WARRANTIES.  THE INTERSTELLAR MARKET"
                TXC " RATING COMMISSION REGULATES OUR PRICES.       "

TSET3           TXC "    DO NOT ADVANCE BEYOND THIS COUNTER...EQUIPM"
                TXC "ENT WILL BE DISTRIBUTED BY OUR ASSISTANTS.  ALW"
                TXC "AYS BE ON THE LOOKOUT FOR PICKPOCKETERS.  TAKE "
                TXC "NOTE OF TODAYS SPECIAL ON SONIC BOOMERANGS.  TH"
                TXC "E PRICE IS EXCELLENT BUT LASTS FOR A LIMITED TI"
                TXC "ME ONLY.  ABSOLUTELY NO TRADING IN THE FOYERWAY"
                TXC "...TAKE CARE OF OTHER BUSINESS OUTSIDE.         "

                DB  $FF
