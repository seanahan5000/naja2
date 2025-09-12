
ZBLOCK_A0       =   $A0
ZBLOCK_A8       =   $A8
XHOLD           =   ZBLOCK_A8+7         ;*** ONLY IN DEFINE.CHAR.S ***

                DUMMY SCRATCH_PAGE
PROFRAC         DS  1
RACE            DS  1

; character creation
PRSNST          DS  9
MINSTAT         DS  9

; vertical graphic values, by stat #
;                    IQ  ST  LR  UR  CR
LEVEL           DB  $00,$00,$00,$00,$00
POINTER         DB  $00,$00,$00,$00,$00

; character testing
CONTAB          DS  51
PLUSTAB         DB  $00,$00,$00,$00
                DEND

ENROLL_TEST     LDA #$FF
                STA ENROLL_FILE

                JSR DRAW_PICT
                PictTextAt 21;145;"WELCOME, I'M THE COMPUTERIZED COUNCIL OF"
                PictTextAt 6;154;"FIVE, SET UP BY THE ORIGINAL COUNCIL TO SERVE"
                PictTextAt 6;163;"IN THEIR PLACE UNTIL A NEW COUNCIL IS FORMED."
                PictTextAt 21;172;"INFORMATION OF THE DEMISE OF THE COUNCIL"
                PictTextAt 12;181;"CAN BE FOUND IN YOUR TACTICAL FORCE MANUAL."
                PictEnd

                JSR SPACE_WAIT
                BCS :1
                JMP ENROLL_EXIT

:1              LDA #2
ENTEST_BACK     STA CURSOR
                JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictTextAt 6;143;"I AM HERE TO PROVIDE TWO SERVICES FOR CADETS"
                PictTextAt 45;152;"WHICH OF THESE ARE YOU HERE FOR?"
                PictTextAt 111;164;"TESTING"
                PictTextAt 111;173;"ENROLLMENT"
                PictTextAt 111;182;"LEAVE"
                PictEnd

                LDX #<:MAIN_KCURSOR
                LDY #>:MAIN_KCURSOR
                LDA #3
                JSR SET_KBLINK_INFO

                ; no testing if group is empty
                LDA GRPNUMB
                BNE :1
                DEC LEGALS+0
:1
                JSR IS_ROSTER_FULL
                BCC :2
                ; no enrollment if roster is full
                DEC LEGALS+1
:2
                JSR DOT
                JSR KBLINK_START
                TXA
                BMI :3
                JSR DOT
                LDX CURSOR
                BEQ GO_TEST
                DEX
                BEQ GO_ENROLL
:3              JMP ENROLL_EXIT

:MAIN_KCURSOR   LDY :MAIN_YPNTS,X
                LDX #$61
                JMP DRAW_ARROW

:MAIN_YPNTS     DB  $A4,$AD,$B6

GO_TEST         LDA #fileEntest_Test
                CMP TEST_FILE
                BEQ :1
                LDY #>TESTING
                JSR LOAD_FILE
:1              JMP TESTING

GO_ENROLL       LDA #fileEntest_Enroll
                CMP ENROLL_FILE
                BEQ :1
                LDY #>ENROLL
                JSR LOAD_FILE
:1              JMP ENROLL

ENROLL_EXIT     JSR DRAW_PICT
                PictCall CLEAR_BOX
                PictSetPage2
                PictCopyToPage
                PictShowPage
                PictEnd
                RTS

CLEAR_BOX       LDX #142
:1              JSR SET_SOURCE_LINE
                LDY #39
                LDA #$40
                STA (SCREENL),Y
                DEY
                LDA #$00
:2              STA (SCREENL),Y
                DEY
                BNE :2
                LDA #$02
                STA (SCREENL),Y
                INX
                CPX #191
                BNE :1
                RTS
;
; On entry:
;   X: cursor proc (low)
;   Y: cursor proc (high)
;   A: max cursor value
;
; On exit:
;   LEGALS cleared based on max cursor
;
SET_KBLINK_INFO STX KCURSOR_PROC+1
                STY KCURSOR_PROC+2
                TAX
                STX KCURSOR_MAX
                LDA #$00
:1              DEX
                BMI :2
                STA LEGALS,X
                BPL :1                  ; always
:2              RTS

KBLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI GOTKEY
                JSR DOT
                JSR DRAW_KCURSOR
                LDA #$00
                JSR WAIT_KEY
                JSR DOT
                JSR DRAW_KCURSOR
KEYMOVE         BIT KEYBRD
                BPL KBLINK
GOTKEY          JSR SPECKS
                LDA KEYBRD
                BIT UNSTROB
                JSR CHECK_UP
                BEQ KUP
                JSR CHECK_DOWN
                BEQ KDOWN
                JSR CHECK_CANCEL
                BEQ KCANCEL
                JSR CHECK_ENTER
                BNE KEYMOVE
                ; *** ERASE CURSOR?
                LDX #0
                RTS

KUP             JSR DRAW_KCURSOR
:1              LDX CURSOR
                BNE :2
                LDX KCURSOR_MAX
:2              DEX
                STX CURSOR
                LDA LEGALS,X
                BNE :1
                JSR DRAW_KCURSOR
                JMP KEYMOVE

KDOWN           JSR DRAW_KCURSOR
KBLINK_START    LDX CURSOR
                INX
                CPX KCURSOR_MAX
                BNE :1
                LDX #0
:1              STX CURSOR
                LDA LEGALS,X
                BNE KBLINK_START
                JSR DRAW_KCURSOR
                JMP KEYMOVE

KCANCEL
                ; *** ERASE CURSOR?
                LDX #-1
                RTS

KCURSOR_MAX     DB  $00

DRAW_KCURSOR    LDX CURSOR
KCURSOR_PROC    JMP $FFFF               ; modified

DOT             LDX #$C1
                LDY #$22
                JSR MOVE_TO
                LDX #<:DOT_SHAPE
                LDY #>:DOT_SHAPE
                JMP DRAW_TILE

:DOT_SHAPE      DB  %00001110
                DB  %00011111
                DB  %00011011
                DB  %00011111
                DB  %00001110
                DB  %00000000
                DB  %00000000

;---------------------------------------
;
; Wait for <space> while animating sweep and specks
;
; On exit:
;   CS: selection made
;   CC: cancel
;
SPACE_WAIT      JSR DRAW_PICT
                PictTextAt 101;34;"<SPACE>"
                PictEnd
                BIT UNSTROB
:1              JSR SWEEPUP
                JSR SPECKS
                LDA KEYBRD
                BPL :1
                BIT UNSTROB
                JSR CHECK_ENTER
                SEC
                BEQ :2
                JSR CHECK_CANCEL
                BNE :1
                CLC
:2              PHP
                JSR DRAW_PICT
                PictClear 14;34;21;41
                PictEnd
                PLP
                RTS

;---------------------------------------
;
; Animate computer sweep bars
;
SWEEPUP         LDA #$45
                STA LINNUMO
LOOPO           LDX #$00
LOOP            LDY LINNUMO
                CPY #$29
                BCC LINDONE
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY #$1C
AGAIN           LDA #$80
                EOR (SCREENL),Y
                STA (SCREENL),Y
                CPY #$1E
                BEQ LINDONE
                INY
                BNE AGAIN
LINDONE         LDA LINNUMO
                CMP #$47
                BEQ OUT
                INC LINNUMO
                INX
                LDA LINNUMO
                CMP #$29
                BCC LINDONE
                CPX #$03
                BEQ LINDONE
                CPX #$07
                BNE LOOP
OUT             LDA LINNUMO
                INX
                INX
                INX
                INX
                SEC
                STX DUMMY
                SBC DUMMY
                STA LINNUMO
                LDA #$80
                JSR WAIT_KEY
                LDA LINNUMO
                CMP #$21
                BNE LOOPO
                LDA #$45
                STA LINNUMO
                LDA #$00
                JMP WAIT_KEY

DUMMY           DB  $00                 ; *** USE ZPAGE
LINNUMO         DB  $00                 ; *** USE ZPAGE

;---------------------------------------
;
; Animate computer "speck" lights
;
SPECKS          LDA #$12
                STA LINENUM
                JSR RANDOM
                AND #$03
                TAX
                LDA SPECK_OFFSETS,X
                STA BYTNUMS
LOOPS1          LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDX #$0B
LOOPS2          LDY BYTNUMS
                LDA SPECK_DATA,Y
                PHA
                TXA
                TAY
                PLA
                CPX #$0C
                BNE STORE
                ORA #$E0
STORE           STA (SCREENL),Y
                INC BYTNUMS
                CPX #$0C
                BEQ NXTLINS
                INX
                BNE LOOPS2
NXTLINS         LDA LINENUM
                CMP #$19
                BEQ FROMS
                INC LINENUM
                BNE LOOPS1
FROMS           RTS

BYTNUMS         DB  $00                 ; *** USE ZPAGE

SPECK_OFFSETS   DB  $00,$10,$20,$30

SPECK_DATA      DB  $C8,$82,$B2
                DB  $88,$D4,$82
                DB  $CA,$80,$80
                DB  $87,$A8,$81
                DB  $B2,$84,$90
                DB  $8B

                DB  $88,$89
                DB  $A4,$83,$8C
                DB  $85,$E0,$80
                DB  $AC,$8D,$B4
                DB  $82,$C4,$88
                DB  $D2,$83

                DB  $AA
                DB  $8C,$8C,$82
                DB  $D4,$85,$90
                DB  $80,$CC,$86
                DB  $8A,$85,$A0
                DB  $80,$D4,$89

                DB  $D2,$8C,$AC
                DB  $85,$E4,$82
                DB  $D0,$86,$96
                DB  $85,$F4,$88
                DB  $AC,$86,$90
                DB  $85

;---------------------------------------
