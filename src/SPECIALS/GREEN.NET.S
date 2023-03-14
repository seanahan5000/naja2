
A_LINE          =   $C0
B_LINE          =   $C1
A_COUNT         =   $C2
B_COUNT         =   $C3
BEGLINE         =   $C4
ENDLINE         =   $C5

PICHERE         =   $5FFF

GREEN_NET       BIT OPEN1
                BVS :1
                CLC                     ; back to halls
                RTS
:1
                LDA RANGE
                STA SAVE_RANGE
                LDA #1
                STA RANGE

                LDA PICHERE
                CMP #$01
                BEQ NETHERE

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictShowPage
                PictEnd

                JSR CLOSE_NET

                LDA #$01
                STA PICHERE

NETHERE         JSR DRAW_PICT
                PictSetPage2
                PictShowPage
                PictEnd

                BIT UNSTROB

                LDX #$0E
                LDA #$1A
                JSR SET_LINE_BOUNDS
                JSR BOXIN

                LDX #$8F
                LDY #$AA
                JSR MOVE_TO
                LDA #$05
                JSR GET_INPUT_LIMIT

                LDX #4
                LDY #$FF
:1              LDA TEXTBUF,X
                CMP GDASH28,X
                BNE :2
                DEX
                BPL :1
                INY
:2              TYA
                PHA
                JSR SCROLLD
                PLA
                BEQ PASSER

                JSR SET_PAGE1
DOKEY           LDA KEYBRD
                BPL DOKEY
                JSR CHECK_TURN
                BEQ TURNED
                BIT UNSTROB
                JMP DOKEY

TURNED          JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictShowPage
                PictEnd
                LDA SAVE_RANGE
                STA RANGE
                SEC
                RTS                     ; back to halls

PASSER          JSR OPEN_NET
                LDA SAVE_RANGE
                STA RANGE
                SEC
                RTS                     ; back to halls

; TODO: generate/randomize and save in game data?
GDASH28         USR (GN-28)-

CLOSE_NET       JSR DRAW_PICT
                PictSetWhite1
                PictMoveTo $5A;$AF
                PictTile BOX_EDGE_L
                PictLineTo $B7;$AF
                PictTile BOX_EDGE_R
                PictMoveTo $5A;$B2
                PictLineTo $B7;$B2
                PictEnd

                LDA #$36
                STA A_LINE
                LDA #$A2
                STA B_LINE
                LDA #0
                STA A_COUNT
                LDA #27
                STA B_COUNT
:1              LDY A_LINE
                LDX A_COUNT
                JSR NET_LINE
                LDX A_LINE              ; pitch
                LDA #$30                ; length
                JSR SOUND
                LDY B_LINE
                LDX B_COUNT
                JSR NET_LINE
                LDX #$FF                ; pitch
                LDA #$10                ; length
                JSR SOUND
                LDA A_LINE
                CLC
                ADC #8
                STA A_LINE
                LDA B_LINE
                SEC
                SBC #8
                STA B_LINE
                DEC B_COUNT
                DEC B_COUNT
                LDA A_COUNT
                INC A_COUNT
                INC A_COUNT
                CMP #$1A
                BNE :1
                RTS
;
; On entry:
;   X: net line index
;   Y: net line Y coordinate
;
NET_LINE        STX COUNT
                LDA EXES,X
                STA :XMOD+1
                PHA
                TAX
                JSR MOVE_TO
                JSR SET_WHITE1
                PLA
                PHA
                TAX
                INX
                JSR HLINE_TO
                JSR SET_GREEN
                PLA
                TAX
                INX
                INX
                JSR HMOVE_TO
                LDA #$16
                SEC
:XMOD           SBC #$FF
                PHA
                TAX
                DEX
                DEX
                JSR HLINE_TO
                JSR SET_WHITE1
                PLA
                TAX
                DEX
                PHA
                JSR HMOVE_TO
                PLA
                TAX
                JSR HLINE_TO

                JSR DRAW_PICT
                PictSetWhite1
                PictHMoveTo $6F
                PictEnd

                LDX COUNT
                LDA NUMBER,X
                BEQ OUTN
                PHA
                CMP #$01
                BEQ ONLY1
                LDX #$7B
                JSR HLINE_TO
                LDA COUNT
                SEC
                SBC #$0B
                ASL
;               CLC
                ADC #$7D
                TAX
                JSR HMOVE_TO
ONLY1
                LDX #$A7
                LDA COUNT
                CMP #$14
                BCS USE169
                SEC
                SBC #$05
                ASL
;               CLC
                ADC #$7D
                TAX
USE169          JSR HLINE_TO
                PLA
                CMP #$03
                BCC OUTN
                LDX #$9B
                JSR HMOVE_TO
                LDX #$A7
                LDA COUNT
                CMP #$10
                BCS ONE69
                SEC
                SBC #$0D
                ASL
                ASL
;               CLC
                ADC #$B3
                TAX
ONE69           JSR HLINE_TO
OUTN            RTS

NUMBER          DB  $00,$00,$00
                DB  $00,$00,$01
                DB  $01,$01,$01
                DB  $01,$01,$02
                DB  $02,$03,$03
                DB  $03,$03,$03
                DB  $03,$03,$02
                DB  $02,$02,$00
                DB  $00,$00,$00
                DB  $00

EXES            DB  $51,$4F,$4C
                DB  $4A,$47,$45
                DB  $42,$40,$3D
                DB  $3B,$38,$36
                DB  $33,$31
                DB  $31,$33
                DB  $36,$38,$3B
                DB  $3D,$40,$42
                DB  $45,$47,$4A
                DB  $4C,$4F,$51
;
; On entry:
;   A: length
;   X: pitch
;
PITCH           =   LOCAL_TEMP+0
LENGTH          =   LOCAL_TEMP+1

SOUND           STA LENGTH
                STX PITCH
                LDY #$00
:1              LDA GREEN_NET,Y         ; (random bytes)
                LDX #$08
:2              LSR
                BNE :3
                STA CLICK
                STA CLICK
:3              DEX
                BNE :2
                LDX PITCH
:4              DEX
                BNE :4
                INY
                DEC LENGTH
                BNE :1
                RTS

BOXIN           JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictSetWhite1
                PictMoveTo $62;$A7
                PictLineTo $62;$B0
                PictMoveTo $63;$B0
                PictLineTo $63;$A7
                PictLineTo $B4;$A7
                PictLineTo $B4;$B0
                PictMoveTo $B5;$B0
                PictLineTo $B5;$A7
                PictTextAt $65;$A9;(CODE)
                PictHMoveTo $81
                PictTile NUMSIGN0
                PictTile NUMSIGN1
                PictSetPage2
                PictEnd
;               JMP SCROLLU

SCROLLU         LDX #$B0
:1              STX BEGLINE
                LDA #$A7
                STA ENDLINE
:2              LDY ENDLINE
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                EOR #$60
                STA SCREENH
                JSR SET_DEST_LINE
                JSR COPY_LINE
                INX
                INC ENDLINE
                CPX #$B2
                BNE :2
                LDA #$60
                JSR WAIT
                LDX BEGLINE
                DEX
                CPX #$A7
                BNE :1
                RTS

SCROLLD         LDA #$A7
                STA ENDLINE
:1              LDX #$B1
:2              JSR SET_DEST_LINE
                DEX
                JSR SET_SOURCE_LINE
                JSR COPY_LINE
                CPX ENDLINE
                BNE :2
                LDA #$60
                JSR WAIT
                LDA ENDLINE
                INC ENDLINE
                CMP #$AD
                BCC :1
                BNE :4
                INC ENDLINE
                INX
                BNE :1                  ; always

:4              CMP #$AF
                BEQ :1
                JSR SET_DEST_LINE
                JSR CLEAR_LINE
                INX
                LDA #$60
                JSR WAIT
                JSR SET_DEST_LINE
                JMP CLEAR_LINE

OPEN_NET        JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall DRAW_HALL
                PictEnd

                LDA #$9E
                STA A_LINE
                LDA #$3A
                STA B_LINE
:1              LDX A_LINE
                JSR UN_NETLINE
                LDX A_LINE              ; pitch
                LDA #$30                ; length
                JSR SOUND
                LDX B_LINE
                JSR UN_NETLINE
                LDX #$FF                ; pitch
                LDA #$10                ; length
                JSR SOUND
                LDA A_LINE
                SEC
                SBC #8
                STA A_LINE
                LDA B_LINE
                CLC
                ADC #8
                STA B_LINE
                CMP #$AA
                BNE :1

                LDA SAVE_RANGE
                STA RANGE
                JSR DRAW_PICT
                PictCall DRAW_HALL
                PictShowPage
                PictEnd

                LDA #$00
                STA OPEN1
                RTS

UN_NETLINE      JSR SET_SOURCE_LINE
                JSR SET_DEST_OFF
                JMP COPY_FULL_LINE

OPEN1           DB  $FF
SAVE_RANGE      DB  $01

NUMSIGN0        DB  %01101100
                DB  %01101100
                DB  %01111111
                DB  %01101100
                DB  %01111111
                DB  %01101100
                DB  %01101100

NUMSIGN1        DB  %00000000
                DB  %00000000
                DB  %00000011
                DB  %00000000
                DB  %00000011
                DB  %00000000
                DB  %00000000

BOX_EDGE_L      DB  %01000000
                DB  %00110000
                DB  %00001100
                DB  %01111111
                DB  %00000000
                DB  %00000000
                DB  %00000000

BOX_EDGE_R      DB  %00000000           ; missing bit here drawn as line
                DB  %00000110
                DB  %00011000
                DB  %01111111
                DB  %00000000
                DB  %00000000
                DB  %00000000
