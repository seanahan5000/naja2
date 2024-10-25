
; This contains code for drawing and updating the monster name box.
; Used for both for initial loader drawing as well as narration updates.

; TODO: consider adding "(#)" count when multiple aliens in same row
; TODO: limit number of aliens to 16 so only 4 bits are needed here and elsewhere

; MNAME_TABLE format
;   IANM.MMMM
;    I: identified
;    A: has arrow marker
;    N: has name
;    M: monster index

INDEX           =   YCOUNT              ;***

DRAW_MNAMES     ENT
                LDX #4
                LDA #0
:1              STA MNAME_TABLE,X
                DEX
                BPL :1
                ; fall through

UPDATE_MNAMES   ENT
                JSR CLEAR_NEXT

                JSR FIRST_MONSTER
:2              LDY #monNUMBER
                LDA (MONS_PTR),Y
                TAX
                LDY TV_HEIGHTS,X
                DEY
                STY :MOD2+1
                LDY #monPOSITION
                LDA (MONS_PTR),Y
                AND #%00001111
                STA :MOD1+1
                LDA #10
                SEC
:MOD1           SBC #$FF
                CLC
:MOD2           ADC #$FF
                TAX
                LDA NEXT_MNAMES,X
                BEQ :SET

                LDY #monTOPVIEW
                LDA (MONS_PTR),Y
                BMI :CUR_IDED

                LDA MNAME_TABLE,X
                BMI :NO_SET
                BPL :LEFT               ; always

:CUR_IDED       LDA MNAME_TABLE,X
                BPL :SET
:LEFT           LDY #monPOSITION
                LDA (MONS_PTR),Y
                CMP LEFT_MNAMES,X
                BCS :NO_SET

:SET            LDY #monSTATUS
                LDA (MONS_PTR),Y
                CMP #dead
                BEQ :NO_SET
                LDY #monTOPVIEW
                LDA (MONS_PTR),Y
                AND #%10000000
                ORA MONSTER_INDEX
                ORA #%01100000          ; set arrow marker and name
                STA NEXT_MNAMES,X
                LDY #monPOSITION
                LDA (MONS_PTR),Y
                STA LEFT_MNAMES,X

:NO_SET         JSR NEXT_MONSTER
                BCC :2
                BCS MNAME_REDRAW        ; always

ERASE_MNAMES    ENT
                JSR CLEAR_NEXT
                ; fall through

MNAME_REDRAW    LDX #0
:1              STX INDEX
                LDY AGRID_YPNTS,X
                JSR VMOVE_TO
                LDA MNAME_TABLE,X
                EOR NEXT_MNAMES,X
                BEQ :4
                PHA
                AND #%01000000          ; check for arrow marker change
                BEQ :2
                LDX #92
                JSR HMOVE_TO
                JSR DRAW_SMALL_ARROW
:2              PLA
                AND #%10111111          ; check for any alien/id change
                BEQ :3
                LDX INDEX
                LDY MNAME_TABLE,X
                JSR DRAW_MNAME
                LDX INDEX
                LDY NEXT_MNAMES,X
                JSR DRAW_MNAME
:3              LDX INDEX
                LDA NEXT_MNAMES,X
                STA MNAME_TABLE,X
:4              INX
                CPX #5
                BNE :1
                RTS

CLEAR_NEXT      LDX #4
                LDA #0
:1              STA NEXT_MNAMES,X
                STA LEFT_MNAMES,X
                DEX
                BPL :1
                RTS

DRAW_MNAME      TYA
                AND #%00100000          ; check for having a name
                BEQ :5
                TYA
                PHA
                JSR SET_MONSTER
                PLA
                BPL :3

; TODO: reuse/share this code
                LDX #0
                LDY #aName
:1              LDA (ALIEN_PTR),Y       ; TODO: ACLASS_PTR
                STA TEXT_BUFFER,X
                INX
                INY
                CPY #aName+16
                BNE :1
:2              DEX
                LDA TEXT_BUFFER,X
                CMP #TextSpace
                BEQ :2
                INX
                LDA #TextLineEnd
                STA TEXT_BUFFER,X
                BNE :4                  ; always

:3              LDY #monNUMBER
                LDA (MONS_PTR),Y
                TAX
                LDA ALTYPE1,X
                AND #%11000000
                CMP #%11000000
                BNE :31
                LDA #%00000000
:31             CLC
                ROL
                ROL
                ROL
                LDX #<MONSTER_NAMES
                LDY #>MONSTER_NAMES
                JSR GET_IND_STRING
; TODO: reuse/share this code

:4              LDX #102
                JMP DRAW_TEXTBUF_X
:5              RTS

MONSTER_NAMES   TXI "UNKNOWN"
                TXI "ALIEN"
                TXI "ROBOT"

DRAW_SMALL_ARROW
                LDX #<SMALL_ARROW
                LDY #>SMALL_ARROW
                JMP DRAW_TILE

SMALL_ARROW     DB  %00000000
                DB  %00110000
                DB  %00111100
                DB  %00111111
                DB  %00111100
                DB  %00110000
                DB  %00000000

; TODO: move to scratch area
NEXT_MNAMES     DS  5
LEFT_MNAMES     DS  5
