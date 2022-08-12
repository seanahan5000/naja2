
DRAW_GRID       ;ENT
                JSR DRAW_PICT
                PictSetGreen
                PictRect $07;$47;$55;$B7
                PictMoveTo $07;$7F
                PictLineTo $55;$7F
                PictSetTextHeight $0B
                PictTextAt $00;$4B;(J\nI\nH\nG\nF\nE\nD\nC\nB\nA)
                PictSetTextHeight $00
                PictTextAt $0E;$B9;(1)
                PictTextAt $1D;$B9;(2)
                PictTextAt $2C;$B9;(3)
                PictTextAt $3B;$B9;(4)
                PictTextAt $4A;$B9;(5)
                PictEnd

                ; draw grid dots (no HPLOT anymore)
                ; hard-wired to current fight/reformat screen position

                LDX #$53
:1              LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #$03
                LDA #$08
:2              STA (SCREENL),Y
                ASL
                INY
                INY
                CPY #$0B
                BNE :2
:3              TXA
                CLC
                ADC #$0B
                TAX
                CPX #$7F
                BEQ :3
                CPX #$B6
                BNE :1

                JSR FIRST_CHAR
:4              JSR DRAW_CHAR_TOPVIEW
                JSR NEXT_CHAR
                BCC :4
                RTS

; FROM11          ;ENT                 ; legacy name
; CPOS_TO_XY      ;ENT
;                 LDY #position
;                 LDA (CHARDL),Y
; FROM11B         ;ENT                 ; legacy name
POS_TO_XY       ;ENT
                STA :MOD+1
                LSR
                LSR
                LSR
                LSR
                TAX
                DEX
                LDA #$05
                SEC
:MOD            SBC #$FF
                AND #$0F
                TAY
                RTS

; On entry:
;   A: position in 11 format
;
; On exit:
;   A: grid index 0 to 24
;
POS_TO_I25      JSR POS_TO_XY
                TXA
                CLC
                ADC MUL5,Y
                RTS

MUL5            DB  0,5,10,15,20

DIV5            DB  0,0,0,0,0
                DB  1,1,1,1,1
                DB  2,2,2,2,2
                DB  3,3,3,3,3
                DB  4,4,4,4,4

MOD5            DB  0,1,2,3,4
                DB  0,1,2,3,4
                DB  0,1,2,3,4
                DB  0,1,2,3,4
                DB  0,1,2,3,4

DRAW_CHAR_TOPVIEW
                LDY #profrace
                LDA (CHARDL),Y
                LSR
                LSR
                LSR
                LSR
                PHA
                LDY #position
                LDA (CHARDL),Y
                JSR POS_TO_XY
                PLA

; On entry:
;   A: prof (already shifted down)
;   X: grid X
;   Y: grid Y

TVIEWIT                             ; legacy name
DRAW_TOPVIEW    PHA
                LDA GRID_XPNTS,X
                STA XCOORD
                LDA GRID_YPNTS,Y
                STA YCOORD
                PLA
                TAX
                LDA TCHAR_OFFSETS,X
                CLC
                ADC #<TCHAR_DATA
                STA DATPNTL
                LDA #0
                ADC #>TCHAR_DATA
                STA DATPNTH
                LDX #2
                LDY #2
                JMP DRAW_SHAPE

                ; pixel positions in top view grid

GRID_XPNTS      DB  #10, #25, #40, #55, #70
GRID_YPNTS      DB  #128,#139,#150,#161,#172

                ; byte offsets into TCHARS data

TCHAR_OFFSETS   DB  TCHAR_WAR-TCHAR_DATA  ; warrior
                DB  TCHAR_AND-TCHAR_DATA  ; android
                DB  TCHAR_CYB-TCHAR_DATA  ; cybernate
                DB  TCHAR_JUI-TCHAR_DATA  ; juicer
                DB  TCHAR_PHY-TCHAR_DATA  ; physician
                DB  TCHAR_MUT-TCHAR_DATA  ; mutant
                DB  TCHAR_EMD-TCHAR_DATA  ; electromedic
                DB  TCHAR_GEN-TCHAR_DATA  ; genius
                DB  TCHAR_ROB-TCHAR_DATA  ; robot

                ; profession top view data, without size/offset header
TCHAR_DATA
TCHAR_WAR       DB  $32,$73,$7B,$1B,$6F,$6F,$6E     ; warrior
                DB  $26,$67,$6F,$6C,$7B,$7B,$3B
                DB  $18,$70,$80
                DB  $0C,$07,$80

TCHAR_AND       DB  $30,$70,$18,$6C,$6F,$6F,$6F     ; android
                DB  $06,$07,$0C,$1B,$FB
                DB  $0C,$78,$80
                DB  $18,$0F,$80

TCHAR_CYB       DB  $30,$77,$73,$7B,$3F,$1F,$1E     ; cybernate
                DB  $06,$77,$67,$6F,$7E,$7C,$3C
                DB  $38,$60,$80
                DB  $0E,$03,$80

TCHAR_JUI       DB  $30,$70,$78,$1C,$6F,$2F,$6F     ; juicer
                DB  $06,$67,$6F,$6C,$7B,$7A,$3B
                DB  $18,$70,$80
                DB  $0C,$07,$80

TCHAR_PHY       DB  $30,$70,$38,$5C,$6F,$77,$4F     ; physician
                DB  $06,$07,$0E,$1D,$7B,$77,$79
                DB  $3C,$70,$80
                DB  $1E,$07,$80

TCHAR_MUT       DB  $32,$73,$7B,$1B,$6F,$2F,$6E     ; mutant
                DB  $26,$67,$6F,$6C,$7B,$7A,$3B
                DB  $18,$70,$80
                DB  $0C,$07,$80

TCHAR_EMD       DB  $30,$77,$3B,$5B,$6F,$77,$4E     ; electromedic
                DB  $06,$77,$6E,$6D,$7B,$77,$39
                DB  $3C,$70,$80
                DB  $1E,$07,$80

TCHAR_GEN       DB  $30,$73,$7B,$7B,$3F,$1F,$1E     ; genius
                DB  $06,$67,$6F,$6F,$7E,$7C,$3C
                DB  $38,$70,$80
                DB  $0E,$07,$80

TCHAR_ROB       DB  $38,$78,$08,$6F,$69,$69,$6F     ; robot
                DB  $0E,$0F,$08,$7B,$4B,$4B,$7B
                DB  $08,$78,$80
                DB  $08,$0F,$80
;
; On entry:
;   X: grid 25 x position
;   Y: grid 25 y position
;
DRAW_GRID_CURSOR_XY
                LDA #<GRID_CURSOR
                STA DATPNTL
                LDA #>GRID_CURSOR
                STA DATPNTH
                BNE DGC_CMN         ; always

;
; On entry:
;   A: grid 11 position
;
DRAW_GRID_CURSOR ;ENT
                LDX #<GRID_CURSOR
                STX DATPNTL
                LDY #>GRID_CURSOR
                STY DATPNTH

                JSR POS_TO_XY

DGC_CMN         LDA GRID_YPNTS,Y
                CLC
                ADC #8
                STA YCOORD
                LDY GRID_XPNTS,X
                DEY
                STY XCOORD

                LDX #3
                LDY #1
                JMP DRAW_SHAPE

GRID_CURSOR     DB  %00000011
                DB  %00000111
                DB  %01111110
                DB  %10000000

                DB  %00000000
                DB  %01000000
                DB  %01111111
                DB  %10000000

                DB  %00000011
                DB  %00000011
                DB  %00000001
                DB  %10000000
