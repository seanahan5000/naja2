
FIGHT_LOADER2   LDA #0
                STA ROUND
                STA SURPRISED_FLAG
                STA ATOTAL1
                STA ATOTAL2
                STA ATOTAL3

                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF

                LDA #fileFightShared
                LDY #$A0
                JSR LOAD_FILE

                JSR FORCE_BOGUS
                JSR MAKE_ALLMONS
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

                LDX #4
                LDA #0
:1              STA MNAME_TABLE,X
                DEX
                BPL :1

                JSR UPDATE_MNAMES
                JMP DRAW_STATS_BOX

DRAW_ALLMONS    JSR FIRST_MONSTER
:1              JSR DRAW_ALIEN
                JSR NEXT_MONSTER
                BCC :1
                RTS

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
