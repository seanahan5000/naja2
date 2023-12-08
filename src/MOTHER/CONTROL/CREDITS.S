;-----------------------------------------------------------
; On Entry:
;           X,Y: Pointing to credits to be taken
;   Carry Clear: Just test if group has enough credits
;     Carry Set: Test and take if the have enough
;
; On Exit:
;   Carry Clear: They COULD NOT afford it
;     Carry Set: They COULD afford it
;
;-----------------------------------------------------------

; TODO: move to camp

GROUP_SPEND     ENT
                PHP
                STX TEMP+0
                STY TEMP+1
                LDY #3
                SEC
                SED
:1              LDA GROUP_CREDITS,Y
                SBC (TEMP),Y
                STA TEMP_CREDITS,Y
                DEY
                BPL :1
                CLD
                BCC :4
                PLP
                BCC :3
                LDY #3
:2              LDA TEMP_CREDITS,Y
                STA GROUP_CREDITS,Y
                DEY
                BPL :2
                LDA #-1
                STA DIRTY_STATE
:3              SEC
                RTS
:4              PLP
                CLC
                RTS

TEMP_CREDITS    DS  4

;-----------------------------------------------------------

SPLIT_GCREDITS  ENT                     ; *** demote to internal???
                LDX #<GROUP_CREDITS
                LDY #>GROUP_CREDITS
SPLIT_CREDITS   ENT                     ; *** demote to internal???
                STX :1+1
                STY :1+2
                LDY #0
                LDX #0
:1              LDA $FFFF,Y
                PHA
                LSR
                LSR
                LSR
                LSR
                STA TEXT_BUFFER,X
                INX
                PLA
                AND #$0F
                STA TEXT_BUFFER,X
                INX
                INY
                CPY #4
                BNE :1
                LDA #TextLineEnd
                STA TEXT_BUFFER,X
                LDX #0
:2              LDA TEXT_BUFFER,X
                BNE :3
                LDA #TextSpace
                STA TEXT_BUFFER,X
                INX
                CPX #7
                BNE :2
:3              RTS
;
; Draw group credits at given location
;
; On entry:
;   X: horizontal draw position
;   Y; vertical draw position
;
DRAW_GCREDITS_AT  ENT
                JSR MOVE_TO
DRAW_GCREDITS   ENT
                JSR SPLIT_GCREDITS
                JMP DRAW_TEXTBUF_SPLIT
;
; On entry:
;   X: pointer to credits (low)
;   Y: pointer to credits (high)
;   MOVE_TO called for position
;
DRAW_CREDITS    ENT                     ;*** demote to internal???
                JSR SPLIT_CREDITS
                ; fall through
;
; Draw digits with spacing 00 000 000
;
; On entry:
;   TEXT_BUFFER: digit characters to be drawn
;   MOVE_TO called for position
;
DRAW_TEXTBUF_SPLIT
                LDX #0
:1              TXA
                PHA
                LDY :OFFSETS,X
                STY :MOD+1
                LDA TEXT_BUFFER,Y
                PHA
                LDA #TextLineEnd
                STA TEXT_BUFFER,Y
                JSR DRAW_TEXTBUF
                LDX #2
                JSR HMOVE
                LDX #0
                LDA #TextEmpty
:2              STA TEXT_BUFFER,X
                INX
:MOD            CPX #$FF
                BNE :2
                PLA
                STA TEXT_BUFFER,X
                PLA
                TAX
                INX
                CPX #3
                BNE :1
                RTS

:OFFSETS        DB  2,5,8

;-----------------------------------------------------------
