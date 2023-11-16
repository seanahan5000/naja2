ZBLOCK_A0       =   $A0
ZBLOCK_A8       =   $A8
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

; TEMPBUF         =   $7F00           ;Must be on page boundary

ENROLL
                ; LDA FSFLAG
                ; AND #$80
                ; STA FSFLAG
                ; LDA #$F0
                ; LDX FSFLAG
                ; BEQ AFIRST
                ; LDA #$0F
; AFIRST
                ; LDY HOLDSEC
                ; ORA OPENBUF,Y
                ; STA HOLD_MOD+1

; *** cancel back on each of these? ***

ASK_NAME        JSR CLEAR_BOX
                JSR DRAW_PICT
                PictTextAt 54;154;"WHAT IS YOUR NAME? "
                PictEnd
                JSR ASK_CHAR_NAME
                BCS GOT_NAME
                JSR CLEAR_BOX
                JMP ANYONE

GOT_NAME        JSR IS_NAJA_NAME
                BCC NOT_NAJA
                JSR DRAW_PICT
                PictTextAt 42;172;"ONLY ONE PERSON GOES BY THAT NAME"
                PictTextAt 78;180;"AND YOU ARE NOT HIM!!"
                PictEnd
                JSR SPACE_WAIT
                JMP ASK_NAME

NOT_NAJA        JSR DUPE_CHECK
                BCS ASK_RACE
                JSR DRAW_PICT
                PictTextAt 30;172;"SOMEONE IS REGISTERED UNDER THAT NAME."
                PictEnd
                JSR SPACE_WAIT
                JMP ASK_NAME

ASK_RACE        JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictTextAt 6;143;"TO WHICH RACE DO YOU BELONG?"
                ; *** where are you from? ***
                PictTextAt 204;143;"HUMAN"  ; *** EARTH
                PictTextAt 204;153;"ORN"
                PictTextAt 204;163;"STILICX"
                PictTextAt 204;173;"XXTYS"
                PictTextAt 204;183;"DENEB"
                PictEnd

                LDX #<:RACE_CURSOR
                LDY #>:RACE_CURSOR
                LDA #5
                JSR KBLINK_SUB
                ; *** RETURN VALUE AND SAVE RACE HERE ***
                BEQ GOT_RACE
                JMP ANYONE

:RACE_CURSOR    LDY :RACE_YPNTS,X
                LDX #$BE
                JMP DRAW_ARROW

:RACE_YPNTS     DB  $8F,$99,$A3
                DB  $AD,$B7

GOT_RACE        LDA CURSOR
                STA RACE

ASK_GENDER      JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictTextAt 30;153;"OF WHICH GENDER ARE YOU?"
                ; *** what is your gender ***
                PictTextAt 204;153;"MALE"
                PictTextAt 204;163;"FEMALE"
                PictTextAt 204;173;"OTHER"
                PictEnd

                LDX #<:GENDER_CURSOR
                LDY #>:GENDER_CURSOR
                LDA #3
                JSR KBLINK_SUB
                ; *** RETURN VALUE AND SAVE GENDER HERE ***
                BEQ GOT_GENDER
                JMP ANYONE

:GENDER_CURSOR  LDY :GENDER_YPNTS,X
                LDX #$BE
                JMP DRAW_ARROW

:GENDER_YPNTS   DB  $99,$A3,$AD

GOT_GENDER      LDA CURSOR
                STA GENDER

                JSR ANIMATE_ARROWS
                JSR DRAW_PICT
                PictTextAt 6;150;"AN ANALYSIS HAS BEEN MADE OF YOUR ABILITIES"
                PictTextAt 6;159;"AND I HAVE FORMULATED THE INFORMATION ON THE"
                PictTextAt 6;168;"FOLLOWING CHART.  <REFER TO YOUR TACTICAL"
                PictTextAt 6;177;"FORCE MANUAL FOR INSTRUCTIONS>"
                PictEnd

                JSR SPACE_WAIT
                JSR CLEAR_BOX
;                 JSR DEFINE_CHAR

; *** IN ROSTER ***
;                 LDY HOLDSEC
; HOLD_MOD        LDA #$FF            ;Modified
;                 STA OPENBUF,Y

TAKE_OATH       JSR DRAW_PICT
                PictTextAt 6;145;"YOUR ENROLLMENT APPLICATION HAS BEEN"
                PictTextAt 6;154;"ACCEPTED.  AT THIS TIME PLEASE STATE THE"
                PictTextAt 6;163;"TACTICAL FORCE LOYALTY OATH.  <IF YOU HAVE"
                PictTextAt 6;172;"NOT MEMORIZED IT YET, THEN REFER TO YOUR"
                PictTextAt 6;181;"TACTICAL FORCE MANUAL> "
                PictEnd

                ; *** TODO: default input to correct text ***
                ; *** could also use for character rename ***

                LDA #$12
                JSR GET_INPUT_LIMIT
:1
                ; *** escape cancel? don't allow? confirm? ***
                LDX #0
:2              LDA OATH,X
                CMP #TextLineEnd
                BEQ PASSED_OATH
                CMP TEXT_BUFFER,X
                BNE :3
                INX
                BNE :2                  ; always
:3              JSR REGET_INPUT
                JMP :1

OATH            TXT "UPHOLD AND SUPPORT"

PASSED_OATH
                ; JSR SAVE_CHAR

                JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictTextAt 6;149;"IN ORDER TO FORM AN EXPLORATION GROUP YOU'LL"
                PictTextAt 6;158;"HAVE TO SEE MR. LELVK AT THE GROUP ASSEMBLY"
                PictTextAt 6;167;"OFFICE.  TO GET THERE, GO DOWN THE HALL THAT"
                PictTextAt 6;176;"YOU JUST CAME THROUGH AND TURN LEFT."
                PictEnd
                JSR SPACE_WAIT
                ; *** JOIN ***
                JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictTextAt 6;149;"GOOD LUCK, AND REMEMBER, THE ALLIANCE OF THE"
                PictTextAt 6;158;"FIVE FREE WORLDS IS DEPENDING ON YOU TO"
                PictTextAt 6;167;"UPHOLD YOUR POSITION AND AID IN THE DOWNFALL"
                PictTextAt 6;176;"OF NAJA."
                PictEnd
                JSR SPACE_WAIT

                JSR CLEAR_BOX
                JMP ANYONE

; *** FOLD THIS INTO MAIN ROUTINE ***
KBLINK_SUB      JSR SET_KBLINK_INFO
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

*-------------------------------
