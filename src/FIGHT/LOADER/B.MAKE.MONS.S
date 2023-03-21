*===============================
*
*===============================

MAKE_ALLMONS    JSR FIRST_CHAR
:1              LDY #position
                LDA (CHARDL),Y
                STA CHARXY,X
                JSR NEXT_CHAR
                BCC :1

                LDX #24
                LDA #$FF
:2              STA GRID,X
                DEX
                BPL :2

                LDX #0
                STX ALIEN_NUMBER
                STX MONS_TOTAL
:LOOP2          JSR PICK_POSITNS
                LDX ALIEN_NUMBER
                BCC :SKIPA
                LDA #0
                STA MONS_NUMBER
:LOOP3          JSR MAKE_MONSTER
                INC MONS_NUMBER
                LDA MONS_NUMBER
                LDX ALIEN_NUMBER
                CMP HMANY1,X
                BNE :LOOP3
:SKIPA          INX
                STX ALIEN_NUMBER
                CPX #3
                BNE :LOOP2
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

                LDX MONS_NUMBER
                LDA POSITION_LIST,X
                STA NEW_MONSTER+monPOSITION

                LDA ALIEN_NUMBER
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

                LDA MONS_TOTAL
                JSR GET_MONSPTR
                LDY #bytespermons-1
:LOOP3          LDA NEW_MONSTER,Y
                STA (TEMP),Y
                DEY
                BPL :LOOP3
                INC MONS_TOTAL
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
