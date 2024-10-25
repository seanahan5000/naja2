
SAVE_ROBOT      JSR PACSUB

                JSR DRAW_PICT
                PictSetBlue
                PictRect $28;$6B;$F6;$BF
                PictEnd

                LDX PICK
                LDA #$1F
                STA ON1,X
                JSR VIEWER
;*** why? ***
;                 LDA PICK
;                 BEQ NOVIEW2
;                 ;*** check this ***
;                 JSR DRAW_PICT
;                 PictSetPage1
;                 PictCopyToPage
;                 PictShowPage
;                 PictEnd
; NOVIEW2
                LDX #0
                STX PICK
                DEX
                STX ON2

ASK_NAME        JSR DRAW_PICT
                ; PictCall CLEAR_BOX
                PictTextAt 50;126;"WHAT NAME WILL YOUR ROBOT"
                PictTextAt 50;135;"BE REGISTERED UNDER? "
                ; PictTextAt 50;126;"YOUR ROBOT IS BEING REGISTERED"
                ; PictTextAt 50;135;"UNDER THE NAME "
                PictEnd

                JSR ASK_CHAR_NAME
                BCS GOT_NAME
                BCS ASK_NAME            ; always

GOT_NAME        JSR IS_NAJA_NAME
                BCC NOT_NAJA
                JSR DRAW_PICT
                PictTextAt 50;126;"ONLY ONE PERSON GOES BY THAT NAME"
                PictTextAt 86;135;"AND YOU ARE NOT HIM!!"
                PictEnd
                JSR ANY_KEY
                JMP ASK_NAME

NOT_NAJA        JSR DUPE_NAME_CHECK
                BCC NOT_DUPE
                JSR DRAW_PICT
                PictTextAt 50;126;"SOMEONE IS REGISTERED UNDER THAT NAME."
                PictEnd
                JSR ANY_KEY
                JMP ASK_NAME

NOT_DUPE        JSR CREATE_ROBOT
                ; JSR SAVE_GAMESTATE_MS
                ; JSR SAVE_MEMBERS

                LDX PICK
                LDA #$0F
                ORA ON1,X
                STA ON1,X
                LDA #$60
                STA STOPPER
                JSR OPTIONS
                LDA #$EA
                STA STOPPER
                JSR PPEOR

                ; JSR DRAW_PICT
                ; PictTextAt 116;126;"IS BEING"
                ; PictTextAt 116;126;"HAS BEEN"
                ; PictTextAt 50;148;"YOU CAN PICK THE ROBOT UP AT THE"
                ; PictTextAt 50;157;"GROUP ASSEMBLY OFFICE AND CHANGE"
                ; PictTextAt 50;166;"ITS NAME TO WHAT EVER YOU WISH."
                ; PictTextAt 188;179;"<SPACE>"
                ; PictEnd
                ;
                ; JSR PPEOR
                ; JSR ANY_KEY
                JMP STOPPER

ANY_KEY         BIT UNSTROB
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB
                RTS

;-----------------------------------------------------------

; NOTE: group and roster are known to have space for a new robot

CREATE_ROBOT    JSR CREATE_PART

                LDA ASSIGN2
                JSR SET_CHAR
                LDY #rosterLocation
                LDA (CHARDL),Y
                PHA
;
; append robot to group and copy image
;
                LDA GRPNUMB
                STA THE_ROBOT
                INC GRPNUMB
                JSR SET_CHAR
                LDY #$7F
:1              LDA ROBOTBUF,Y
                STA (CHARDL),Y
                DEY
                BPL :1
;
; copy entered name
;
                LDX #0
                LDY #name
:2              LDA NAME_BUFFER,X
                STA (CHARDL),Y
                INY
                INX
                CPX #charNameLength
                BNE :2
;
; put cybernate location in robot
;
                PLA
                ORA #$80
                LDY #roboCyberLink
                STA (CHARDL),Y
;
; find slot for robot and set it
;
                JSR GET_ROSTER_LOC
                ORA #$80
                LDY #rosterLocation
                STA (CHARDL),Y
                PHA
;
; put robot location in cybernate and mark dirty
;
                LDA ASSIGN2
                JSR SET_CHAR
                PLA
                ORA #$80
                LDY #roboCyberLink
                STA (CHARDL),Y
;
; dirty both the cybernate and robot
;
                ; LDA #-1
                ; LDX ASSIGN2
                ; STA DIRTY_CHARS,X
                ; LDX THE_ROBOT
                ; STA DIRTY_CHARS,X
                RTS

;-----------------------------------------------------------

CREATE_PART     LDA #<ROBOTBUF
                STA CHARDL
                LDA #>ROBOTBUF
                STA CHARDH

                LDA #0
                LDY #$7F
:1              STA (CHARDL),Y
                DEY
                BPL :1

                LDA #$FF
                LDY #e1_HEAD
:2              STA (CHARDL),Y
                INY
                CPY #e16_UNUSED+4
                BNE :2

                LDX #0
:3              LDY ROBOT_DATA,X
                INX
                LDA ROBOT_DATA,X
                STA (CHARDL),Y
                INX
                CPX #DATA_END-ROBOT_DATA
                BNE :3

                LDY SEHEAD
                LDX HEDAMH,Y
                LDA HEDAML,Y
                JSR ADD_DAMAGE
                LDY SPHEAD
                LDX HPDAMH,Y
                LDA HPDAML,Y
                JSR ADD_DAMAGE
                LDY SEBODY
                LDX BEDAMH,Y
                LDA BEDAML,Y
                JSR ADD_DAMAGE
                LDY SPBODY
                LDX BPDAMH,Y
                LDA BPDAML,Y
                JSR ADD_DAMAGE

                LDY #e1_HEAD
                LDA LOWREF
                ASL
                AND #%00011000
                STA (CHARDL),Y
                INY
                LDA SEHEAD
                ASL
                ASL
                ASL
                ASL
                ORA SPHEAD
                STA (CHARDL),Y
                INY
                LDA SEBODY
                ASL
                ASL
                ASL
                ASL
                ORA SPBODY
                STA (CHARDL),Y
                INY
                LDA ECAPAC
                STA (CHARDL),Y

                LDA #0
                STA COUNT
:4              JSR POINTAT
                LDX COUNT
                CPX #7
                BEQ :5
                CPX #8
                BEQ :5
                LDA SLOT,X
                TAY
                LDA (VALUEL),Y
                STA SLOT,X
:5              INC COUNT
                LDA COUNT
                CMP #$0D
                BNE :4

                LDY #level+1
                LDA PLEVEL
                STA (CHARDL),Y

                LDY #energymax+1
                LDA ECAPAC
                BPL HIEN2
                AND #$7F
                PHA
                ASL
                ASL
                ASL
                ASL
                STA (CHARDL),Y
                DEY
                PLA
                LSR
                LSR
                LSR
                LSR
                STA (CHARDL),Y
                BPL NOOR5           ;Always

HIEN2           DEY
                STA (CHARDL),Y
                AND #$0F
                CMP #$02
                BEQ OR5
                CMP #$07
                BNE NOOR5
OR5             LDA #$05
                INY
                STA (CHARDL),Y
NOOR5
                SED
                LDY #baseshielding
                LDA SEHEAD
                CLC
                ADC SEBODY
                STA (CHARDL),Y
                INY
                LDA SPHEAD
                CLC
                ADC SPBODY
                STA (CHARDL),Y
                CLD

                LDY #e1_HEAD
                LDA SLOT
                ASL
                AND #%10000000
                EOR #%10000000
                ORA RRANGE
                ORA (CHARDL),Y
                STA (CHARDL),Y

                LDY #e3_ROBLFT
                LDA LWEAPON
                JSR LRSUB
                LDY #e5_ROBRGT
                LDA RWEAPON
                JSR LRSUB

                LDY #e15_PROGRAM+1
                LDA AUTO
                ASL
                AND #%10000000
                EOR #%10000000
                ORA PLEVEL
                STA (CHARDL),Y

                LDY #basestrength
                LDA UPREF
                STA (CHARDL),Y
                INY                 ;baseupreflex
                STA (CHARDL),Y
                INY                 ;baselwreflex
                LDA LOWREF
                STA (CHARDL),Y
                RTS

ROBOT_DATA      DB  status,healthy
                DB  profrace,robot*16+none
                DB  back,1
                DB  organic,1
                DB  energylev+1,$10
                DB  flaglimbo,inlimbo
                DB  miscflags,%00100000                     ;w/o implant, genderless
                DB  basepowercons,$42
                DB  e15_PROGRAM+0,$5A
                DB  e15_PROGRAM+2,$20
                DB  e15_PROGRAM+3,$20
DATA_END

ADD_DAMAGE      LDY #damagemax+1
                CLC
                SED
                ADC (CHARDL),Y
                STA (CHARDL),Y
                DEY
                TXA
                ADC (CHARDL),Y
                STA (CHARDL),Y
                CLD
                RTS

LRSUB           ASL
                TAX
                LDA ROBWEPS,X
                STA (CHARDL),Y
                INY
                LDA ROBWEPS+1,X
                STA (CHARDL),Y
                BMI :EXIT
                INY
                LDA #$00
                STA (CHARDL),Y
                INY
                LDA #$20
                STA (CHARDL),Y
:EXIT           RTS

ROBWEPS         DB  $58,$00
                DB  $58,$04
                DB  $5C,$00
                DB  $5C,$01
                DB  $5C,$02
                DB  $FF,$FF
                DB  $59,$00

HEDAMH          DB  $00,$00,$00,$01
HEDAML          DB  $05,$30,$80,$50

HPDAMH          DB  $00,$00,$01
HPDAML          DB  $10,$75,$50

BEDAMH          DB  $00,$00,$01
                DB  $03,$04,$06
                DB  $08,$10
BEDAML          DB  $30,$80,$80
                DB  $25,$75,$25
                DB  $00,$00

BPDAMH          DB  $00,$00,$01
                DB  $02,$03,$04
                DB  $05,$07,$08
                DB  $10
BPDAML          DB  $30,$70,$20
                DB  $00,$00,$25
                DB  $50,$00,$50
                DB  $00

;-----------------------------------------------------------
