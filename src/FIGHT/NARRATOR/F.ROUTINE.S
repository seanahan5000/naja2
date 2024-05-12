BITMASKS        DB  %10000000       ;| Used in MON_SWING
HIT_MASKS       DB  %01000000       ;|  | Used in PICK_MCOMMAND
                DB  %00100000       ;|  |
                DB  %00010000       ;|  |
                DB  %00001000       ;|  |
                DB  %00000100       ;|  |
                DB  %00000010       ;|
                DB  %00000001       ;|

GET_CMD_XY      LDX COMPNTR
                LDA COMMAND+1,X
                STA SQUARE_HIT
                RTS

;*** TODO: convert to PictFillRect
CLRBOX          LDX #$80
CLOOP2          LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDA #$00
                LDY #$0D
CLRLOOP         STA (SCREENL),Y
                INY
                CPY #$27
                BNE CLRLOOP
                LDA (SCREENL),Y
                AND #$70
                STA (SCREENL),Y
                INX
                CPX #$BF
                BNE CLOOP2
                RTS

COMCALC         TAX
                ASL
                ASL
                ASL
                ASL
                ASL
                CLC
                ADC COMNUMS,X
                STA COMPNTR
                TAX
                LDA COMMAND,X
                AND #$0F
                RTS
;
; Draw oval representing a character in the hit grid.
; The more difficult to hit, the smaller the oval.
;
; On entry:
;   X: character index
;   A: oval shape index
;
DRAW_OVAL       PHA
                LDA TEMPCHAR_XY,X
                JSR POS_TO_XY
                LDA GRID_XPNTS,X
                TAX
                LDA CGRID_YPNTS,Y
                TAY
                JSR MOVE_TO
                PLA
                TAY
                LDX OVAL_SHAPES_L,Y
                LDA OVAL_SHAPES_H,Y
                TAY
                JMP NEW_DRAW_SHAPE

OVAL_SHAPES_L   DB  <OVAL_0
                DB  <OVAL_1
                DB  <OVAL_2
                DB  <OVAL_3
                DB  <OVAL_4
                DB  <OVAL_4

OVAL_SHAPES_H   DB  >OVAL_0
                DB  >OVAL_1
                DB  >OVAL_2
                DB  >OVAL_3
                DB  >OVAL_4
                DB  >OVAL_4

OVAL_0          DB  $21,$01

                DB  %01111000
                DB  %00001100
                DB  %00000110
                DB  %00000110
                DB  %00000110
                DB  %00001100
                DB  %01111000

                DB  %00001111
                DB  %00011000
                DB  %00110000
                DB  %00110000
                DB  %00110000
                DB  %00011000
                DB  %00001111

OVAL_1          DB  $21,$01

                DB  %01110000
                DB  %00011000
                DB  %00001100
                DB  %00001100
                DB  %00001100
                DB  %00011000
                DB  %01110000

                DB  %00000111
                DB  %00001100
                DB  %00011000
                DB  %00011000
                DB  %00011000
                DB  %00001100
                DB  %00000111

OVAL_2          DB  $21,$32

                DB  %01111110
                DB  %01000011
                DB  %01000011
                DB  %01000011
                DB  %01111110
                DB  %10000000

                DB  %00000000
                DB  %00000001
                DB  %00000001
                DB  %00000001
                DB  %10000000

OVAL_3          DB  $11,$43

                DB  %00011110
                DB  %00110011
                DB  %00011110
                DB  %10000000

OVAL_4          DB  $11,$53

                DB  %00000110
                DB  %00001111
                DB  %00000110
                DB  %10000000

DELAYER         LDA DELAY_MODE
                BEQ SPCWAIT
                BIT KEYBRD
                BMI KEYAHIT
                LDA DELAY_TIME
                BNE :1
                LDA #defaultDelayTime
:1              STA SCREENH
                LDA #$00
                STA SCREENL
DELOOP          LDA SCREENH
                ORA SCREENL
                BEQ TIMESUP
                LDA SCREENL
                SEC
                SED
                SBC #$01
                STA SCREENL
                LDA SCREENH
                SBC #$00
                CLD
                STA SCREENH
                LDA #$08
                JSR WAIT_KEY
                BPL DELOOP
KEYAHIT         LDA KEYBRD
                BIT UNSTROB
                CMP #" "
                BNE DELOOP

SPACING         LDA #$00
                STA DELAY_MODE
                JSR CLEAR_MODE_MSG
                JSR DRAW_MODE_MSG
                JMP DELAYER

SPCWAIT         LDA KEYBRD
                BPL SPCWAIT
                BIT UNSTROB
                CMP #$9B            ;TEMP***
                BEQ ABORT           ;TEMP***
                CMP #" "
                BEQ TIMESUP
                CMP #$8D
                BNE SPCWAIT

                LDA #$01
                STA DELAY_MODE
                JSR CLEAR_MODE_MSG
                JMP DRAW_MODE_MSG

TIMESUP         RTS

ABORT           BIT $C061           ;TEMP***
                BPL :2              ;TEMP***
                JSR FIRST_CHAR      ;TEMP***
:1              LDY #status         ;TEMP***
                LDA #dead           ;TEMP***
                STA (CHARDL),Y      ;TEMP***
                JSR NEXT_CHAR       ;TEMP***
                BCC :1              ;TEMP***
:2              JMP BATTLE_OVER     ;TEMP***

GETIME          LDX POINTER
                LDA PECKS,X
                AND #$7F
                JSR COMCALC
                JSR TIMTABL
                LDX COMPNTR
                LDA COMMAND,X
                AND #$0F
                LSR
                PHP
                TAY
                LDA TIMTYPE,Y
                PLP
                BCC HIGH1
                AND #$0F
                BPL DOCOMN          ;Always
HIGH1           LSR
                LSR
                LSR
                LSR
DOCOMN          TAY
                LDA TIMES,Y
                RTS

TIMTYPE         DB  $11,$13,$21
                DB  $10,$22,$50
                DB  $10

TIMTABL         LDY #upreflex
                LDA (CHARDL),Y
                JSR MUCHT
                STA TIMES+1
                LDY #lwreflex
                LDA (CHARDL),Y
                JSR MUCHT
                STA TIMES
                STA TIMES+3
                SED
                CLC
                ADC TIMES
                STA TIMES
                LDA TIMES+1
                CLC
                ADC TIMES+1
                STA TIMES+2
                LDA TIMES+1
                CLC
                ADC TIMES+3
                BCC NOVER
                LDA #$99
NOVER           STA TIMES+3
                CLD
                LDA #$01
                STA TIMES+4
                LDX COMPNTR
                INX
                LDA COMMAND,X
                STA TIMES+5
                RTS

TLWCALC         LDY #monLOREF
                JSR MUCHTIM
                STA SCRATCH
                CLC
                SED
                ADC SCRATCH
                CLD
                RTS

TUPCALC         LDY #monUPREF
MUCHTIM         LDA (MONS_PTR),Y
MUCHT           LDY #0
:1              CMP MAXCUTS,Y
                BCC :2
                BEQ :2
                INY
                BNE :1              ;Always
:2              LDA TMUNITS,Y
                RTS

MAXCUTS         DB  $16,$33,$50
                DB  $66,$82,$FF
TMUNITS         DB  $36,$18,$12
                DB  $09,$07,$06
