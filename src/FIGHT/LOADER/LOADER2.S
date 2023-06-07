
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
                JSR SAVE_ADJUST_CPOS

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

SAVE_ADJUST_CPOS
                JSR INIT_CGRID
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

                JSR I25_TO_CPOS
                LDY #position
                STA (CHARDL),Y

:NEXT           JSR NEXT_CHAR
                BCC :4
                RTS

; TODO: share these?

INIT_CGRID      LDY #0
                LDX #0
:1              STX COUNT
                LDA GRID_BITS+5,X
                STA MASK_BITS
                LDX #0
:2              LSR MASK_BITS
                ROR
                ROR
                ROR
                AND #%00100000          ; inaccessible cell
:3              STA GRID,Y
                INY
                INX
                CPX #5
                BNE :2
                LDX COUNT
                INX
                CPX #5
                BNE :1
                RTS

I25_TO_CPOS     LDA MOD5,Y
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
