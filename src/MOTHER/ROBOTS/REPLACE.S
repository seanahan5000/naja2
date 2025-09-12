
REPLACE         LDA #$EE
                STA PARTALL
                LDA #0
                JSR PICK_A_ROBOT
                BCS :1
                JMP OPTIONS
:1              JSR PACSUB
                LDA THE_ROBOT
                JSR SET_CHAR
                JSR REVERSE
                JSR TOTALUP
                JSR ROSTAT2
                LDX PICK
                LDA ON1,X
                ORA #$0F
                STA ON1,X
                JSR DRAW_PICT
                PictTextAt 89;94;"REPLACE WHICH PART?"
                PictEnd
                LDA #7
                JSR SET_LEGALS
                LDX #$FF
                LDY #e2_SLOT
                LDA (CHARDL),Y
                CMP #$FF
                BEQ :2
                STX LEGALS+scrnHEAD
:2              LDA LWEAPON
                CMP #$06
                BNE :3
                STX LEGALS+scrnWEAPONL
:3              LDA RWEAPON
                CMP #$06
                BNE :4
                STX LEGALS+scrnWEAPONR
:4              LDX #-1
:5              INX
                LDA LEGALS,X
                BNE :5
                STX CURSOR
                JSR CURFLIP
                JSR SHOW_SCREEN
                JSR GBOXSUB
                BCS :6
                JMP OPTIONS             ; cancel back to main menu
:6              JSR CURFLIP
                JSR NEXT_SCREEN
                JSR BTRANS
                JSR CHURSIT
                LDA CURSOR
                ASL
                ASL
                TAY
                LDX #0
RELOOPB         LDA BODTOT,Y
                STA THE_PRICE,X
                INY
                INX
                CPX #$04
                BNE RELOOPB
                JSR GTRADE2
                LDA CURSOR
                JSR DRAW_SCREEN
                JSR DELABEL
                JSR TOPLEVL
                LDX PICK
                LDA #$FF
                STA ON1,X
                JSR SHOW_SCREEN
                JSR MINISUB
                LDA CURSOR
                AND #%11111110
                CMP #scrnWEAPONL
                BNE NOWEPO
                LDA CURSOR
                STA :MOD+1
                JSR EDIT_WEAPON
                BCC :3
                LDA SAME_FLAG
                BNE :3
                JSR CREATE_PART
                LDA THE_ROBOT
                JSR SET_CHAR
                LDY #e5_ROBRGT+3
:MOD            LDA #$FF
                LSR
                BCS :1
                LDY #e3_ROBLFT+3
:1              LDX #3
:2              LDA ROBOTBUF,Y
                STA (CHARDL),Y
                DEY
                DEX
                BPL :2
                JMP PARTOUT
:3              JMP OPTIONS

NOWEPO          JSR ZOOMUP
                JSR EDIT_PART
                BCS :1
                LDX PICK                ; cancelled
                LDA #$FF
                STA ON1,X
                BNE :2                  ; always
:1              LDA SAME_FLAG
                BEQ :3                  ; selection unchanged
:2              JMP OPTIONS

:3              JSR TOSLOT
                JSR CREATE_PART
                LDA THE_ROBOT
                JSR SET_CHAR

PARTPRO         LDX SCRPICK
                CPX #scrnPROGRAM
                BNE :1
                LDY #e15_PROGRAM+1
                LDA ROBOTBUF+e15_PROGRAM+1
                STA (CHARDL),Y
                LDY #level+1
                LDA ROBOTBUF+level+1
                STA (CHARDL),Y
:1

PARTENR         LDY #energymax+2
:1              LDA ROBOTBUF,Y
                STA (CHARDL),Y
                DEY
                CPY #energymax-1
                BNE :1
                SEC
:2              LDA (CHARDL),Y
                SED
                SBC ROBOTBUF+3,Y
                CLD
                DEY
                CPY #energylev-1
                BNE :2
                BCS :4
                LDY #energylev+2
:3              LDA ROBOTBUF+3,Y
                STA (CHARDL),Y
                DEY
                CPY #energylev-1
                BNE :3
:4

PARTDAM         LDY #damagemax+1
:1              LDA ROBOTBUF,Y
                STA (CHARDL),Y
                DEY
                CPY #damagemax-1
                BNE :1
                LDY #damagemax+1
                SEC
                LDA (CHARDL),Y
                SED
                LDY #damagelev+1
                SBC (CHARDL),Y
                STA SCRATCH
                INY
                LDA (CHARDL),Y
                LDY #damagelev
                SBC (CHARDL),Y
                CLD
                LDX #$75                ; percentage
                BCC :2
                ORA SCRATCH
                BEQ :2
                LDX #$50                ; percentage
:2
; drop damagelev to 50% or 75% of value
; TODO: why is this being done?
                TXA
                PHA
                LDY #damagelev+1
                LDA (CHARDL),Y
                TAX
                DEY
                LDA (CHARDL),Y
                TAY
                PLA
                JSR MULTIPLY_12
                LDY #damagelev+1
                LDA PRODUCT_3+1
                STA (CHARDL),Y
                DEY
                LDA PRODUCT_3+0
                STA (CHARDL),Y

PARTOTHER       LDY #e1_HEAD+3
:1              LDA ROBOTBUF,Y
                STA (CHARDL),Y
                DEY
                CPY #e1_HEAD-1
                BNE :1

                LDY #baselwreflex
:2              LDA ROBOTBUF,Y
                STA (CHARDL),Y
                DEY
                CPY #basestrength-1
                BNE :2

                LDY #baseshielding
                LDA ROBOTBUF+baseshielding
                STA (CHARDL),Y
                INY
                LDA ROBOTBUF+baseshielding+1
                STA (CHARDL),Y

PARTOUT         JSR CALC_ALL
                JSR SPEND_RTOTNUM
                JMP OPTIONS             ; back to main menu

SPEND_RTOTNUM   LDX #<RTOTNUM
                LDY #>RTOTNUM
                SEC
                JMP GROUP_SPEND

GTRADE2         JSR CALC_TRADEIN
                LDX #$03
:1              LDA THE_PRICE,X
                STA TRADEIN,X
                DEX
                BPL :1
                RTS

ZOOMUP          LDA #$00
                STA POINTER
                LDY SCRPICK
                LDA NUMCATS,Y
                STA MAXMOD2+1
COLOOP1         LDX POINTER
                LDA POINTLV,X
                BEQ COSKIP1
                CMP #$15
                BCS COSKIP3
                STA MAXMOD1+1
                LDA #$00
                STA POINTLV,X
                TXA
                LDY SCRPICK
                CLC
                ADC BEGCATS,Y
                JSR POINTAT
COLOOP2         LDX POINTER
                INC POINTLV,X
                JSR BIGSUB
                JSR UPDSUB
                LDA SCRPICK
                CMP #scrnMOVEMENT
                BNE COSKIP2
                JSR DRAW_MOVEMENT_T
COSKIP2         LDX POINTER
                LDA POINTLV,X
MAXMOD1         CMP #$FF
                BNE COLOOP2
COSKIP1         INC POINTER
                LDA POINTER
MAXMOD2         CMP #$FF
                BNE COLOOP1
COSKIP3         LDY SCRPICK
                LDA BEGCATS,Y
                JMP POINTAT

TOPLEVL         LDY SCRPICK
                LDA NUMCATS,Y
                CLC
                ADC BEGCATS,Y
                STA SCRATCH
                LDX BEGCATS,Y
                LDY #$00
PVLOOPB         LDA SLOT,X
                STA POINTLV,Y
                STA DUPNTLV,Y
                INY
                INX
                CPX SCRATCH
                BNE PVLOOPB
                RTS
