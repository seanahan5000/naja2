
MASK_BITS       =   TEMP                ;***

;---------------------------------------

MAKE_ALIENS     JSR FORCE_BOGUS

                LDX #24
                LDA #0
:1              STA GRID,X
                DEX
                BPL :1

                JSR APPLY_AWALLS

                LDX #0
                STX ALIEN_INDEX
                STX MONSTER_COUNT
:LOOP2          JSR PICK_POSITIONS
                LDX ALIEN_INDEX
                BCC :SKIPA
                LDA #0
                STA MONSTER_INDEX       ; per-race monster index
:LOOP3          JSR MAKE_MONSTER
                INC MONSTER_INDEX
                LDA MONSTER_INDEX
                LDX ALIEN_INDEX
                CMP HMANY1,X
                BNE :LOOP3
:SKIPA          INX
                STX ALIEN_INDEX
                CPX #3
                BNE :LOOP2
                RTS

; TODO: share these?

APPLY_AWALLS    LDY #0
                LDX #0
:1              STX COUNT
                LDA GRID_BITS+0,X
                STA MASK_BITS
                LDX #0
:2              LSR MASK_BITS
                BCC :3
                LDA #%00100000          ; blocked grid cell
                STA GRID,Y
:3              INY
                INX
                CPX #5
                BNE :2
                LDX COUNT
                INX
                CPX #5
                BNE :1
                RTS

I25_TO_APOS     LDA MOD5,Y
                ASL
                ASL
                ASL
                ASL
;               CLC
                ADC #$10
                STA :MOD+1
                LDA #$0A
                SEC
                SBC DIV5,Y
:MOD            ORA #$FF
                RTS

;---------------------------------------

MAKE_MONSTER    LDY #aUpperReflex
                LDA (ALIEN_PTR),Y
                ; JSR PLUS_MINUS_10
                STA NEW_MONSTER+monUPREF

                LDY #aLowerReflex
                LDA (ALIEN_PTR),Y
                ; JSR PLUS_MINUS_10
                STA NEW_MONSTER+monLOREF

                LDY #aBlasts
                LDA (ALIEN_PTR),Y
                STA NEW_MONSTER+monSHOTS

                LDY #aSwings
                LDA (ALIEN_PTR),Y
                STA NEW_MONSTER+monSWINGS

                LDY #aDamage
                LDA (ALIEN_PTR),Y
*** PLUS OR MINUS 10 PERCENT
                STA NEW_MONSTER+monDAMAGE
                INY
                LDA (ALIEN_PTR),Y
                STA NEW_MONSTER+monDAMAGE+1

                LDY #aElShield
                LDA (ALIEN_PTR),Y
                STA NEW_MONSTER+monELSHIELD
                INY
                LDA (ALIEN_PTR),Y
                STA NEW_MONSTER+monPHSHIELD

                LDX MONSTER_INDEX       ; per-race monster index
                LDA POSITION_LIST,X
                STA NEW_MONSTER+monPOSITION

                LDA ALIEN_INDEX
                STA NEW_MONSTER+monNUMBER

                LDA #healthy
                STA NEW_MONSTER+monSTATUS

                LDA #0
                STA NEW_MONSTER+monSTATCOUNT
                STA NEW_MONSTER+monSTATCOUNT+1

                LDA #$FF
                STA NEW_MONSTER+monLASTCMD

                LDA #$00
                STA NEW_MONSTER+monTOPVIEW
                STA NEW_MONSTER+monFLAGS

                LDA MONSTER_COUNT
                JSR SET_MONS_PTR
                LDY #bytespermons-1
:LOOP3          LDA NEW_MONSTER,Y
                STA (MONS_PTR),Y
                DEY
                BPL :LOOP3
                INC MONSTER_COUNT
                RTS

; TODO: this code seems buggy
; PLUS_MINUS_10   PHA
; :LOOP1          JSR RANDOM
;                 STA TEMP
;                 CPY TEMP
;                 BCC :LOOP1
;                 AND #$0F
;                 CMP #$0A
;                 BCS :LOOP1
;                 LDA TEMP
;                 AND #$F0
;                 CMP #$A0
;                 BCS :LOOP1
; ;               LDA RANDOM1+1
; ; TODO: should this be BMI :SKIPA?
;                 BCC :SKIPA
;                 PLA
;                 CLC
;                 SED
;                 ADC TEMP
;                 CLD
;                 BCC :EXIT
;                 LDA #$99
;                 RTS
; :SKIPA          PLA
;                 SEC
;                 SED
;                 SBC TEMP
;                 CLD
;                 BEQ :SKIPB
;                 BCS :EXIT
; :SKIPB          LDA #$01
; :EXIT           RTS

;---------------------------------------

FORCE_BOGUS     LDX #0
:1              STX ALIEN_INDEX
                LDY ALIEN1,X
                CPY #$FF
                BEQ :3

                LDA ALIEN_PTRS_L,X
                STA ALIEN_PTR+0
                LDA ALIEN_PTRS_H,X
                STA ALIEN_PTR+1

                LDY #bytesperalien-1
:2              LDA BOGUS_ALIEN-16,Y
                STA (ALIEN_PTR),Y
                DEY
                CPY #15
                BNE :2

                LDX ALIEN_INDEX
:3              INX
                CPX #3
                BNE :1
                RTS

BOGUS_ALIEN
                DB  10              ;swings
                DDB $0005           ;damage per swing
                DB  10              ;blasts
                DDB $0005           ;damage per blast
                DB  %01110000       ;swing squares
                DB  0               ;inflicting ability
                DB  0               ;status inflicted
                DB  0
                DB  0,0,0,$49,0     ;fight parameters
                DB  %00000100       ;blast source

                DB  $20             ;upper reflex
                DB  $20             ;lower reflex
                DB  0
                DDB $0005           ;damage
                DB  $30             ;electrical shielding
                DB  $30             ;physical shielding
                DB  0
                DB  0
                DB  0
                HEX 0100            ;experience
                HEX 0100            ;credit
                DB  $90             ;finding odds
                DB  %11111100       ;finding groups

                DB  $20             ;surprisability
                DB  $20             ;surprisingability
                DB  $30             ;identifyability
                DB  $30             ;jammability
                DB  $30             ;immobilizability
                DB  0
                DB  0
                DB  0
                DB  $AA,$AA,$AA     ;susceptabilities
                DB  $FF,$FF,$FF     ;swing words
                DB  $33             ;retreat odds
                DB  $33             ;advance odds

;---------------------------------------
