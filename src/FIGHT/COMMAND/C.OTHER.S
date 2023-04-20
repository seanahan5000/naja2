OTHER           JSR OTHER_SUB
                LDA PLANNER
                JSR SET_CHAR
                LDX PLANNER
                BIT ORIGRED
                BPL :SKIPA
                LDA #$FF
                STA LEGALS,X
                LDX GRPNUMB
:SKIPA          TXA
                PHA
                JSR CLEAR_CANCEL_IN
                JSR DRAW_PICT
                PictTextAt 114;152;(SEE_WHOSE_FIGHTING_PLAN?)
                PictEnd
                PLA
                JSR SELECT_CHAR
                PHP
                JSR CANCEL_OUT
                PLP
                BCC :CANCEL
                JSR CLEAR_WTIME
                JSR DOCOM3
                JSR DRAW_PICT
                PictTextAt 107;152;(<SPACE>)
                PictTextAt 104;162;(TO_LEAVE)
                PictEnd
:KEYLOOP         JSR SPACE_WAIT
                BCC :KEYLOOP
                BCS :OKAY               ; always

:CANCEL         JSR CHAR_CURSOR2
:OKAY           JSR DRAW_PICT
                ; NOTE: CLEAR_WTIME not used because a full width
                ;   clear is needed here
                PictSetBlack1
                PictFillRect 91;128;276;182
                PictMoveTo $A5;$80
                PictLineTo $A5;$B7
                PictLineTo $104;$B7
                PictEnd
                JSR DOTIME
                JSR OPTIONS
                JMP GETOP2

DOCOM3          LDA CURSOR
                ASL
                ASL
                ASL
                ASL
                ASL
                STA POINTR2
                LDA #$00
                STA CFLAG
                LDA COMCNT
                CMP #$0A
                BCS FULLBOX
                LDY POINTR2
                LDX #$00
DOCLOOP         LDA COMMAND,Y
                CMP #$8A
                BEQ DFOUND
                INY
                INY
                INX
                BNE DOCLOOP
DFOUND          CPX #$0B
                BCS FULLBOX
                LDA #$05
                STA CFLAG
FULLBOX
                LDA CFLAG
                AND #$01
                BNE :1

                JSR DRAW_PICT
                PictSetGreen
                PictMoveTo $A5;$80
                PictLineTo $A5;$B7
                PictLineTo $104;$B7
                PictEnd
                BNE DOC2                ; always

:1              JSR DRAW_PICT
                PictSetGreen
                PictMoveTo $CB;$80
                PictLineTo $CB;$B7
                PictLineTo $104;$B7
                PictEnd

DOC2            LDY POINTR2
                LDA COMMAND,Y
                CMP #$8A
                BEQ DOOUT
                STA INSTR1
                INY
                INC POINTR2
                LDA COMMAND,Y
                STA INSTR2
                INC POINTR2
                LDY CFLAG
                LDX COMXS,Y
                LDA COMYS,Y
                CLC
                ADC #$38
                TAY
                INC CFLAG
                JSR DRAW_CMD2
                JMP DOC2
DOOUT           RTS

OTHER_SUB       JSR SET_LEGALS
                LDX PLANNER         ;Also called by CONTROL
                BIT ORIGRED
                BPL :LOOP1
                LDX GRPNUMB
                DEX
:LOOP1          LDA #$00
                STA LEGALS,X
                TXA
                JSR SET_CHAR
                JSR BAD_STATUS
                BNE :SKIPB
:SKIPA          LDA #$FF
                STA LEGALS,X
:SKIPB          DEX
                BPL :LOOP1
                RTS
