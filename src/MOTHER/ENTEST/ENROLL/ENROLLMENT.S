WHICH           =   ZBLOCK_A0+0
; DATPNTL         =   ZBLOCK_A0+1
; DATPNTH         =   ZBLOCK_A0+2
PICPNT          =   ZBLOCK_A0+3
MINPNT          =   ZBLOCK_A0+4
YLEVEL          =   ZBLOCK_A0+5
BCHECKD         =   ZBLOCK_A0+6
COUNTR4         =   ZBLOCK_A0+7
DATCNT          =   ZBLOCK_A8+0
STATNUM         =   ZBLOCK_A8+1
BOXNUM          =   ZBLOCK_A8+2
PROFSNT         =   ZBLOCK_A8+3     ;+4

HOLDIT          =   ZBLOCK_A8+5         ; used by DEFINE.CHAR

ENROLL

ASK_NAME        JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictTextAt 54;154;"WHAT IS YOUR NAME? "
                PictEnd
                JSR ASK_CHAR_NAME
                BCS GOT_NAME
                JMP LEAVE_ENROLL

GOT_NAME        JSR IS_NAJA_NAME
                BCC NOT_NAJA
                JSR DRAW_PICT
                PictTextAt 42;172;"ONLY ONE PERSON GOES BY THAT NAME"
                PictTextAt 78;180;"AND YOU ARE NOT HIM!!"
                PictEnd
                JSR SPACE_WAIT
                JMP ASK_NAME

NOT_NAJA        JSR DUPE_NAME_CHECK
                BCC ASK_RACE
                JSR DRAW_PICT
                PictTextAt 30;172;"SOMEONE IS REGISTERED UNDER THAT NAME."
                PictEnd
                JSR SPACE_WAIT
                JMP ASK_NAME

ASK_RACE        JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictTextAt 6;143;"TO WHICH RACE DO YOU BELONG?"
                PictTextRows 204;143;10
                TXC "HUMAN\n"
                TXC "ORN\n"
                TXC "STILICX\n"
                TXC "XXTYS\n"
                TXT "DENEB"
                PictEnd

                LDX #<:RACE_CURSOR
                LDY #>:RACE_CURSOR
                LDA #5
                JSR KBLINK_SUB
                BEQ GOT_RACE
                JMP LEAVE_ENROLL

:RACE_CURSOR    LDY :RACE_YPNTS,X
                LDX #$BE
                JMP DRAW_ARROW

:RACE_YPNTS     DB  $8F,$99,$A3
                DB  $AD,$B7

GOT_RACE        LDA CURSOR
                STA RACE

                JSR ANIMATE_ARROWS
                JSR DRAW_PICT
                PictTextRows 6;150;9
                TXC "AN ANALYSIS HAS BEEN MADE OF YOUR ABILITIES\n"
                TXC "AND I HAVE FORMULATED THE INFORMATION ON THE\n"
                TXC "FOLLOWING CHART.  <REFER TO YOUR TACTICAL\n"
                TXT "FORCE MANUAL FOR INSTRUCTIONS>"
                PictEnd

                JSR SPACE_WAIT
                PHP
                JSR CLEAR_BOX
                PLP
                BCC :1

                JSR DEFINE_CHAR
                BCS TAKE_OATH
:1              JMP LEAVE_ENROLL

TAKE_OATH       JSR DRAW_PICT
                PictTextRows 6;145;9
                TXC "YOUR ENROLLMENT APPLICATION HAS BEEN\n"
                TXC "ACCEPTED.  AT THIS TIME PLEASE STATE THE\n"
                TXT "TACTICAL FORCE LOYALTY OATH."
                PictTextAt 84;177;"UPHOLD AND SUPPORT"
                PictCall GET_INPUT_KEY
                PictEnd

PASSED_OATH     JSR BUILD_CHAR
                JSR SAVE_GAME

                JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictTextRows 6;149;9
                TXC "IN ORDER TO FORM AN EXPLORATION GROUP YOU'LL\n"
                TXC "HAVE TO SEE MR. LELVK AT THE GROUP ASSEMBLY\n"
                TXC "OFFICE.  TO GET THERE, GO DOWN THE HALL THAT\n"
                TXT "YOU JUST CAME THROUGH AND TURN LEFT."
                PictCall SPACE_WAIT
                PictEnd

                JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictTextRows 6;149;9
                TXC "GOOD LUCK, AND REMEMBER, THE ALLIANCE OF THE\n"
                TXC "FIVE FREE WORLDS IS DEPENDING ON YOU TO\n"
                TXC "UPHOLD YOUR POSITION AND AID IN THE DOWNFALL\n"
                TXT "OF NAJA."
                PictCall SPACE_WAIT
                PictEnd

LEAVE_ENROLL    JSR CLEAR_BOX
                LDA #0
                JMP ENTEST_BACK

KBLINK_SUB      JSR SET_KBLINK_INFO
                LDX KCURSOR_MAX
                DEX
                STX CURSOR
                JSR DRAW_PICT
                PictTextAt 101;34;"C>ANCEL"
                PictEnd
                JSR DOT
                JSR KBLINK_START
                TXA
                PHA
                JSR DOT
                JSR DRAW_PICT
                PictClear 14;34;21;41   ; erase cancel
                PictEnd
                JSR CLEAR_BOX
                PLA
                RTS

;---------------------------------------

ANIMATE_ARROWS  LDA #$07
                PHA
ARLOOP1         JSR SPECKS
                LDA #$05
                STA COUNT
ARRLOOP         JSR RANDOM
                BMI NOTUORD
                LDX COUNT
                JSR PICARRO
                JSR RANDOM
                BMI UPONLY
DWNONLY         LDX COUNT
                LDA SITIONS,X
                CLC
                ADC #$02
                CMP #$26
                BCS UPONLY
                STA SITIONS,X
                BNE AORS
UPONLY          LDX COUNT
                LDA SITIONS,X
                SEC
                SBC #$02
                CMP #$16
                BCC DWNONLY
                STA SITIONS,X
AORS            LDX COUNT
                JSR PICARRO
NOTUORD         DEC COUNT
                BPL ARRLOOP
                PLA
                SEC
                SBC #$01
                BEQ ARROUT
                BIT KEYBRD
                BMI ARROUT
                PHA
                LDA #$D0
                JSR WAIT_KEY
                JMP ARLOOP1
ARROUT          RTS

PICARRO         LDY SITIONS,X
                JSR VMOVE_TO
                LDA EXES,X
                TAX
                BMI :1
                JSR HMOVE_TO_H
                JMP :2
:1              JSR HMOVE_TO
:2              LDX #<:ARRO_TILE
                LDY #>:ARRO_TILE
                JMP DRAW_TILE

:ARRO_TILE      DB  %00001100
                DB  %00001110
                DB  %00001100
                DB  %00000000
                DB  %00000000
                DB  %00000000
                DB  %00000000

EXES            DB  238,244,250
                DB  <256,<262,<268

SITIONS         DB  $20,$1E,$18
                DB  $1A,$21,$19

;---------------------------------------
