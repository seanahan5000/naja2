
FIGHT_LOADER2   LDA #0
                STA ROUND
                STA SURPRISED_FLAG
                STA ATOTAL1
                STA ATOTAL2
                STA ATOTAL3

                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF

                LDA #fileFightShared
                LDY #$A0                ;*** use constant
                JSR LOAD_FILE

                JSR BUILD_GRID
                JSR SAVE_ADJ_CPOS

                JSR MAKE_ALIENS
                JSR FIGHT_SCREEN
                ; JSR SURPRISE_SUB

                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF

                LDA #$5F
                PHA
                LDA #$FF
                PHA
                LDA #fileFightCommand
                LDY #$60
                JMP LOAD_FILE

;-------------------------------------------------
; Save all initial characters positions and then
;   move any that are on blocked squares.
;-------------------------------------------------

SAVE_ADJ_CPOS   JSR INIT_CGRID
;
; save all positions and place unblocked characters
;
                JSR FIRST_CHAR
:2              LDY #position
                LDA (CHARDL),Y
                STA SAVE_CPOS,X
                JSR POS_TO_I25
                LDA CGRID_MAIN,Y
                BNE :3
                LDA CHAR_INDEX
                ORA #%10000000
                STA CGRID_MAIN,Y
:3              JSR NEXT_CHAR
                BCC :2
;
; move all blocked characters
;
                JSR FIRST_CHAR
:4              LDY #position
                LDA (CHARDL),Y
                JSR POS_TO_I25
                LDX CGRID_MAIN,Y
                BMI :NEXT
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
                LDA CGRID_MAIN,Y
                BEQ :8
;
; try to move side characters inward
;
:5              LDX MOD5,Y
                CPX #3
                BCC :7

:6              LDA CGRID_MAIN,Y
                BEQ :8
                DEY
                BPL :6
                LDY #24
                BNE :6                 ; always

:7              LDA CGRID_MAIN,Y
                BEQ :8
                INY
                CPY #25
                BNE :7
                LDY #0
                BEQ :7                 ; always

:8              LDA CHAR_INDEX
                ORA #%10000000
                STA CGRID_MAIN,Y

                JSR I25_TO_CPOS
                LDY #position
                STA (CHARDL),Y

:NEXT           JSR NEXT_CHAR
                BCC :4
                RTS

;---------------------------------------

FIGHT_SCREEN    JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictSetGreen
                PictRect $59;$47;$115;$BF
                PictMoveTo $59;$47
                PictLineTo $115;$47
                PictMoveTo $59;$7F
                PictLineTo $115;$7F
                PictMoveTo $CB;$48
                PictLineTo $CB;$7E
                PictEnd
                JSR DRAW_GRID2
                JSR DRAW_ALLMONS
                JSR DRAW_MNAMES
                JMP DRAW_STATS_BOX

DRAW_ALLMONS    JSR FIRST_MONSTER
:1              JSR DRAW_ALIEN
                JSR NEXT_MONSTER
                BCC :1
                RTS

;---------------------------------------

MAKE_ALIENS     JSR FORCE_BOGUS
                JSR INIT_AGRID

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
