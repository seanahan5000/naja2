
; *** SHARED BETWEEN GROUP, ENROLL, ROBOTS ***
; *** REQUIRES NAME_BUFFER

;
; Ask for character name
; (Used for enrollment, renaming, maybe robots)
;
; On exit:
;   CC: cancel
;   CS: name entered
;   NAME_BUFFER: result, leading spaced trimmed,
;       end padded with spaces
;
ASK_CHAR_NAME   LDA #charNameLength
                JSR GET_INPUT_LIMIT
:1
                ; *** CANCEL WITH ESCAPE??? ***
                TXA
                BNE :2
                JSR REGET_INPUT
                JMP :1

:2              LDX #0
:3              LDA TEXT_BUFFER,X
                CMP #TextSpace
                BNE :4
                INX
                CPX #charNameLength
                BNE :3
                CLC
                RTS

:4              LDY #0
:5              LDA TEXT_BUFFER,X
                CMP #TextLineEnd
                BNE :6
                LDA #TextSpace
                DEX
:6              STA NAME_BUFFER,Y
                INX
                INY
                CPY #charNameLength
                BNE :5
                SEC
                RTS
;
; Check NAME_BUFFER for "NAJA" string
;
; On exit:
;   CC: no NAJA match
;   CS: matches NAJA
;
IS_NAJA_NAME    LDX #0
:1              LDA NAME_BUFFER,X
                CMP NAJA_NAME,X
                BNE :2
                INX
                CPX #4
                BNE :1
                SEC
                RTS
:2              CLC
                RTS

NAJA_NAME       TXC "NAJA"
;
; On entry:
;   A: roster character index (0-15)
;
; On exit:
;   BNE true if bit allocated
;
TEST_ROSTER_BIT JSR DIV_MOD8
                AND BIT_TABLE,Y
                RTS

SET_ROSTER_BIT  JSR DIV_MOD8
                ORA MASK_TABLE,Y
                STA ROSTER_BITS,X
                RTS

CLEAR_ROSTER_BIT JSR DIV_MOD8
                AND MASK_TABLE,Y
                STA ROSTER_BITS,X
                RTS
;
; On entry:
;   A: roster character index (0-15)
;
; On exit:
;   X: A div 8
;   Y: A mod 8
;
DIV_MOD8        AND #$0F                ; make sure no high bits
                LDX #0
                CMP #8
                AND #$07
                BCC :1
                INX
:1              TAY
                RTS

;---------------------------------------

;*** shared? ***
DUPE_CHECK
;                 JSR DRIVE_ON
;                 LDA #>TEMPBUF
;                 STA SSTOREH
;                 LDY #0
;                 STY SECOUNT
; MORCHCK         LDA OPENBUF,Y
;                 BNE POSSIBL
; NEXT1           INC SECOUNT
;                 LDY SECOUNT
;                 CPY #$0B
;                 BNE MORCHCK
;                 JSR DRIVE_OFF
                SEC                 ;Name is okay
                RTS

; POSSIBL         PHA
;                 LDY #>charTrack
;                 LDA #<charTrack
;                 ORA SECOUNT
;                 TAX
;                 LDA #1
;                 JSR FLOADER
;                 PLA
;                 TAX
;                 AND #$F0
;                 BEQ FAILNAM
;                 LDY #$09
; MORCOMP         LDA NAME,Y
;                 CMP CHARBUF,Y
;                 BNE FAILNAM
;                 DEY
;                 BPL MORCOMP
;                 JSR DRIVE_OFF
;                 CLC                 ;Duplicate name found
;                 RTS

; FAILNAM         TXA
;                 AND #$0F
;                 BEQ NEXT1
;                 LDY #$09
; MORCOM2         LDA NAME,Y
;                 CMP CHARBUF+$80,Y
;                 BNE NEXT1
;                 DEY
;                 BPL MORCOM2
;                 JSR DRIVE_OFF
;                 CLC                 ;Duplicate name found
;                 RTS

;---------------------------------------
