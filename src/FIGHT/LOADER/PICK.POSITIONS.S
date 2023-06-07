
*-------------------------------------------------
* On Entry:
*   ALIEN_INDEX: Number of current alien (0 to 2)
*
* On Exit:
*   Carry Clear: No positions were picked
*           Set: At least one position was picked
*-------------------------------------------------

PICK_POSITIONS  LDX ALIEN_INDEX
                LDY ALIEN1,X
                INY
                CLC
                BEQ :2

                LDA TV_WIDTHS,X
                STA TVIEW_WIDTH
                LDA TV_HEIGHTS,X
                STA TVIEW_HEIGHT

                LDA :GBUFF_PTRS_L,X
                STA GBUFF_PTR
                LDA :GBUFF_PTRS_H,X
                STA GBUFF_PTR_H

                JSR POSITIONS

                ; reduce alien count if not all could be placed in grid

                LDX ALIEN_INDEX
                LDA MONSTER_INDEX       ; per-race monster index
                CMP HMANY1,X
                BCS :2
                CMP #1                  ; create carry result
                BCS :1
                LDA #$FF
:1              STA HMANY1,X
:2              RTS

:GBUFF_PTRS_L   DB  <GROUP_BUFF1
                DB  <GROUP_BUFF2
                DB  <GROUP_BUFF3

:GBUFF_PTRS_H   DB  >GROUP_BUFF1
                DB  >GROUP_BUFF2
                DB  >GROUP_BUFF3

*---------------------------------------------------------------
* On Entry:
*   GROUP_BUFF: Grouping format data for current alien
*
* On Exit:
*   MONSTER_INDEX: Number of monsters that were positioned
*   POSITION_LIST: Positions that were found for those monsters
*---------------------------------------------------------------

POSITIONS       LDA #0
                STA MONSTER_INDEX       ; per-race monster index
:LOOP0
:1              LDY #0
:LOOP1          LDA (GBUFF_PTR),Y
                INY
                CMP #$DD
                BNE :LOOP1
                LDX #0
:LOOP2          LDA (GBUFF_PTR),Y
                CMP #$FF
                BEQ :2              ;branch to branch to :BAD_DATA
                CMP MONSTER_INDEX
                BEQ :SKIPF
                BCS :SKIPA
:SKIPF          INX
                INY
                BNE :LOOP2          ;Always
:SKIPA          LDY #0
:LOOP3          DEX
                BMI :SKIPB
:LOOP4          LDA (GBUFF_PTR),Y
                INY
                CMP #$DD
:2              BEQ :BAD_DATA
                CMP #$CC
                BNE :LOOP4
                BEQ :LOOP3          ;Always
:SKIPB          STY FIRST_ONE
:LOOP5          INY
                LDA (GBUFF_PTR),Y
                AND #%11101110      ;#$CC or #$DD
                CMP #$CC
                BNE :LOOP5
                STY LAST_ONE        ;This is exclusive
:LOOP6          CPY FIRST_ONE
                BEQ :SKIPC          ;None found
                DEY
                LDA (GBUFF_PTR),Y
                BEQ :LOOP6
                BNE :SKIPD          ;One found
:SKIPC          LDY LAST_ONE
                LDA (GBUFF_PTR),Y
                CMP #$DD
                BEQ :BAD_DATA
                INY
                BNE :SKIPB          ;Always
:SKIPD

; TODO: skip randomize if FIRST_ONE and LAST_ONE wrap just one
:LOOP7          JSR RANDOM
                AND #%00011111
                CMP FIRST_ONE
                BCC :LOOP7
                CMP LAST_ONE
                BCS :LOOP7
                TAY
                LDA (GBUFF_PTR),Y
                BEQ :LOOP7
                STY RND_HOLD

                JSR PICK_VALID
                BCS :SKIPE

                LDY RND_HOLD
                LDA #$00
                STA (GBUFF_PTR),Y
                LDY LAST_ONE
                BPL :LOOP6          ;Always

:SKIPE          LDX MONSTER_INDEX
                STA POSITION_LIST,X
                INX
                STX MONSTER_INDEX
                LDX ALIEN_INDEX
                LDA HMANY1,X
                CMP MONSTER_INDEX
                BEQ :EXIT
                JMP :LOOP0
:EXIT           RTS

:BAD_DATA       LDA #$EE
                JSR PICK_VALID
                BCS :SKIPE

                LDA ALIEN_INDEX                 ;**
                LDY ALIEN1                      ;**
                LDX ALIEN2                      ;**
                ; DEBUG   "Position error"      ;**
                LDA #$FF
                BNE :SKIPE          ;Always
;
; On entry:
;   A: position pattern with wildcards
;
; On exit:
;   Carry Clear: no position found
;     Carry Set: position was found
;             A: position found
;
PICK_VALID      JSR ALL_VALID
                CLC
                LDA VALID_COUNT
                BEQ :3
                LDX #0
                CMP #1
                BEQ :2
:1              JSR RANDOM
                AND #$1F
                CMP VALID_COUNT
                BCS :1
                TAX
:2              LDA VALID_LIST,X
                PHA
                TAY
                JSR SET_VALID
                PLA
                TAY
                JSR I25_TO_APOS
                SEC
:3              RTS
;
; Given a position value with wildcards, generate a list of all
;   available legal positions.
;
; On entry:
;              A: position with wildcards
;    TVIEW_WIDTH: width in grid cells
;   TVIEW_HEIGHT: height in grid cells
;
; On exit:
;    VALID_LIST: list of valid positions
;   VALID_COUNT: count of valid positions
;
ALL_VALID       LDX #0
                STX VALID_COUNT

                TAX
                AND #$EE
                CMP #$EE
                BEQ :XY_WILD
                TXA
                AND #$E0
                CMP #$E0
                BEQ :X_WILD
                TXA
                AND #$0E
                CMP #$0E
                BEQ :Y_WILD

:SINGLE         TXA
                JSR MONPOS_TO_I25
                STY START_INDEX
                JMP CHECK_VALID

:XY_WILD        LDY #0
:2              STY START_INDEX
                JSR CHECK_VALID
                LDY START_INDEX
                INY
                CPY #25
                BNE :2
                RTS

:X_WILD         TXA
                AND #$0F
                ORA #$10
                JSR MONPOS_TO_I25
:3              STY START_INDEX
                JSR CHECK_VALID
                LDY START_INDEX
                INY
                CPY #25
                BEQ :4
                LDA MOD5,Y
                BNE :3
:4              RTS

:Y_WILD         TXA
                AND #$F0
                ORA #$0A
                JSR MONPOS_TO_I25
:5              STY START_INDEX
                JSR CHECK_VALID
                LDA START_INDEX
                CLC
                ADC #5
                TAY
                CPY #25
                BCC :5
                RTS

CHECK_VALID     LDA TVIEW_WIDTH
                CLC
                ADC MOD5,Y
                CMP #6
                BCS :NOT_OKAY

                LDA TVIEW_HEIGHT
                STA YCOUNT
                CLC
                ADC DIV5,Y
                CMP #6
                BCS :NOT_OKAY

:1              STY SAVE_INDEX
                LDX TVIEW_WIDTH
:2              LDA GRID,Y
                BNE :NOT_OKAY
                INY
                DEX
                BNE :2

                LDA SAVE_INDEX
                CLC
                ADC #5
                TAY
                DEC YCOUNT
                BNE :1

:OKAY           LDX VALID_COUNT
                LDA START_INDEX
                STA VALID_LIST,X
                INC VALID_COUNT
:NOT_OKAY       RTS
;
; On entry:
;   Y: position index
;
SET_VALID       LDA TVIEW_HEIGHT
                STA YCOUNT
:1              TYA
                PHA
                LDX TVIEW_WIDTH
                LDA #$80
:2              STA GRID,Y
                INY
                DEX
                BNE :2
                PLA
                CLC
                ADC #5
                TAY
                DEC YCOUNT
                BNE :1
                RTS

*-------------------------------
