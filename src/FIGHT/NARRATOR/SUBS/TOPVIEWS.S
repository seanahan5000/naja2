*-------------------------------
*
*-------------------------------

DRAW_IF_DEAD    LDA DEAD_FLAG
                LSR
                BCC :1
                AND #%00000001
                PHA
                LDA DEAD_XY
                JSR POS_TO_XY
                LDA GRID_XPNTS,X
                TAX
                LDA CGRID_YPNTS,Y
                TAY
                JSR MOVE_TO
                PLA
                TAY
                LDX :ADR_LOW,Y
                LDA :ADR_HIGH,Y
                TAY
                JMP NEW_DRAW_SHAPE
:1              RTS

:ADR_LOW        DB  <HDEAD
                DB  <VDEAD
:ADR_HIGH       DB  >HDEAD
                DB  >VDEAD

HDEAD           DB  $42,$00

                DB  $00,$70,$78
                DB  $5C,$0E,$00
                DB  $40

                DB  $00,$40,$73
                DB  $0F,$7E,$7C
                DB  $7F

                DB  $06,$1F,$7C
                DB  $7E,$FF

                DB  $00,$00,$00
                DB  $1D,$3F,$1F
                DB  $01

                DB  $7C,$1F,$80

                DB  $03,$80

                DB  $7E,$40,$80

                DB  $67,$3F,$1C
                DB  $80

VDEAD           DB  $23,$00

                DB  $00,$00,$00
                DB  $60,$38,$30
                DB  $60

                DB  $00,$30,$33
                DB  $19,$18,$9C

                DB  $60,$40,$50
                DB  $58,$4C,$6E
                DB  $7C

                DB  $0F,$0F,$0F
                DB  $87

                DB  $78,$60,$40
                DB  $40,$60,$40
                DB  $00

                DB  $0F,$0F,$1D
                DB  $3B,$33,$19
                DB  $0C

*-------------------------------
*
*-------------------------------

DRAW_IMAGENS    LDX #0
                STX XCOUNT
                STX YCOUNT
:1              STX COUNT
                LDA MASTER_CGRID,X
                BPL :2
                AND #$7F
                CMP #$7F
                BEQ :2
                JSR SET_CHAR
                LDX XCOUNT
                LDY YCOUNT
                JSR CGRID_MOVETO
                JSR DRAW_PROF_IMAGEN
:2              LDX XCOUNT
                INX
                CPX #5
                BNE :3
                LDX #0
                INC YCOUNT
:3              STX XCOUNT
                LDX COUNT
                INX
                CPX #25
                BNE :1
                RTS

DRAW_PROF_IMAGEN
                LDX #<BLIT_IMAGEN
                LDY #>BLIT_IMAGEN
                JSR :SUB1
                JSR DRAW_PROF_TOPVIEW
                LDX #<BLIT_TILE
                LDY #>BLIT_TILE
:SUB1           STX BLIT_TILE_MOD+1
                STY BLIT_TILE_MOD+2
                RTS

BLIT_IMAGEN     LDX #0
                TXA
:1              STA TILE_BUFFER+1,X
                INX
                INX
                CPX #8
                BNE :1
                JMP BLIT_TILE

*-------------------------------

BLINK_MONS      JSR :SUBA
                BIT KEYBRD
                BMI :EXIT
:SUBA           JSR :SUBB
:SUBB           JSR DRAW_ALIEN
                LDA #$C0
                JSR WAIT_KEY
:EXIT           RTS

BLINK_CHAR      JSR :SUBA
                BIT KEYBRD
                BMI :EXIT
:SUBA           JSR :SUBB
:SUBB           JSR DRAW_CHAR
                JSR DRAW_NAME
                LDA #$C0
                JSR WAIT_KEY
:EXIT           RTS

DRAW_CHAR       LDX CHAR_NUMBER
                LDA TEMPCHAR_XY,X
                JSR POS_TO_XY
                JSR CGRID_MOVETO
                JMP DRAW_PROF_TOPVIEW

DRAW_NAME
        do NAME_FIRST
                JSR CNAME_TO_TEXT
        else
                JSR PROFNAME_TO_TEXT
        fin
                LDX CHAR_NUMBER
                LDY YPOINTS,X
                LDX #$10
                JMP DRAW_TEXTBUF_XY
