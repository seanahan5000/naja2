*===============================
*
*===============================

MAKE_ALLMONS    JSR BUILD_GRID
                JSR SAVE_ADJUST_CPOS

                LDX #24
                LDA #$FF
:2              STA GRID,X
                DEX
                BPL :2

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
;
; Save all initial characters positions and then
;   move any that are on blocked squares.
;
SAVE_ADJUST_CPOS
                LDX #24
                LDA #0
:1              STA GRID,X
                DEX
                BPL :1
;
; mark blocked grid cells with #$FF
;
                LDA #$FF
                LDX #<GRID
                LDY #>GRID
                JSR APPLY_CWALLS
;
; save all positions and place unblocked characters
;
                JSR FIRST_CHAR
:2              LDY #position
                LDA (CHARDL),Y
                STA SAVE_CPOS,X
                JSR POS_TO_I25
                LDA GRID,Y
                BNE :3
                LDA CHAR_INDEX
                ORA #$40
                STA GRID,Y
:3              JSR NEXT_CHAR
                BCC :2
;
; move all blocked characters
;
                JSR FIRST_CHAR
:4              LDY #position
                LDA (CHARDL),Y
                JSR POS_TO_I25
                LDX GRID,Y
                INX
                BNE :NEXT
;
; try to move back row characters up one
;
                LDX DIV5,Y
                CPX #4
                BNE :5
                TYA
                SEC
                SBC #5
                TAY
                LDA GRID,Y
                BEQ :8
;
; try to move side characters inward
;
:5              LDX MOD5,Y
                CPX #3
                BCC :7

:6              LDA GRID,Y
                BEQ :8
                DEY
                BPL :6
                LDY #24
                BNE :6                 ; always

:7              LDA GRID,Y
                BEQ :8
                INY
                CPY #25
                BNE :7
                LDY #0
                BEQ :7                 ; always

:8              LDA CHAR_INDEX
                ORA #$40
                STA GRID,Y

                JSR I25_TO_POS
                LDY #position
                STA (CHARDL),Y

:NEXT           JSR NEXT_CHAR
                BCC :4
                RTS

;*** MOVE/SHARE THESE ***

I25_TO_POS      LDA MOD5,Y
                ASL
                ASL
                ASL
                ASL
;               CLC
                ADC #$10
                STA :MOD+1
                LDA #$05
                SEC
                SBC DIV5,Y
:MOD            ORA #$FF
                RTS

MASK_BITS       =   TEMP                ;***

APPLY_CWALLS    STA :MOD+1
                STX POINTL
                STY POINTH
                LDY #0
                LDX #0
:1              STX COUNT
                LDA GRID_BITS+5,X
                STA MASK_BITS
                LDX #0
:2              LSR MASK_BITS
                BCC :3
:MOD            LDA #$FF
                STA (POINTL),Y
:3              INY
                INX
                CPX #5
                BNE :2
                LDX COUNT
                INX
                CPX #5
                BNE :1
                RTS

*-------------------------------
*
*-------------------------------

MAKE_MONSTER
                LDY #aUpperReflex
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

*-------------------------------
*
*-------------------------------

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
