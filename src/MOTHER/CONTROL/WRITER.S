
; one sector buffer for reading/writing/combining character data
; NOTE: must be page aligned
CHAR_BUFFER     =   $AF00

;-----------------------------------------------------------
;
; Save just the Mothership-specific part of the game state
;   (includes roster bits and arsenal inventory)
;
SAVE_GAMESTATE_MS ENT
                LDA #stateSectors-1
                BPL SAVE_CMN            ; always

;-----------------------------------------------------------
;
; Save all sectors of the game state
;   (includes Mothership and TRACC/general state)
;
SAVE_GAMESTATE  ENT
                LDA #0
SAVE_CMN        PHA
                LDA #fileSaveGame
                JSR SET_FILE
                PLA
:1              PHA
                JSR SEEK_FILE
                PLA
                PHA
                CLC
                ADC #>GAME_STATE
                TAY
                LDA #1
                JSR WRITE_FILE
                PLA
                CLC
                ADC #1
                CMP #stateSectors
                BNE :1
                RTS

;-----------------------------------------------------------
;
; Write all members of the group to disk
;
SAVE_GROUP      ENT
                LDX #maxGroupSize
                LDA #0
:1              CPX GRPNUMB
                BNE :2
                LDA #-1
:2              DEX
                BMI SAVE_MEMBERS
                STA DIRTY_CHARS,X
                BPL :1                  ; always

;-----------------------------------------------------------
;
; Save selected members of the group to disk, based on LEGALS
;
SAVE_MEMBERS    ENT
                LDA #fileSaveGame
                JSR SET_FILE
                JSR FIRST_CHAR
:1              LDA DIRTY_CHARS,X
                BEQ :6

                LDY #rosterLocation
                LDA (CHARDL),Y
                AND #$0F
                PHA
                JSR TEST_ROSTER_LOC
                BEQ :4

                LDX CHAR_INDEX
:2              INX
                CPX GRPNUMB
                BEQ :3
                LDA DIRTY_CHARS,X
                BEQ :2
                TXA
                JSR SET_CHAR
                PLA
                PHA
                LDY #rosterLocation
                EOR (CHARDL),Y
                AND #$0E
                LSR
                BNE :2

; another group member is in the same sector as the character
                LDA #0
                STA DIRTY_CHARS,X
                JSR CHAR_TO_CBUFF
                JMP :5

; a non-group member is in the same sector as the character
:3              PLA
                PHA
                LSR
                JSR READ_SECT
                JMP :5

; character is alone in the sector so clear it
:4              JSR CLEAR_CBUFF
:5              PLA
                LDA CHAR_INDEX
                JSR SET_CHAR
                JSR CHAR_TO_CBUFF
                JSR WRITE_CSECT
:6              JSR NEXT_CHAR
                BCC :1
                RTS

;-----------------------------------------------------------

CLEAR_CBUFF     LDA #0
                TAX
:1              STA CHAR_BUFFER,X
                INX
                BNE :1
                RTS

CHAR_TO_CBUFF   LDY #rosterLocation
                LDA (CHARDL),Y
                LSR
                LDA #$00
                ROR
                TAX
                LDY #0
:1              LDA (CHARDL),Y
                STA CHAR_BUFFER,X
                INX
                INY
                CPY #128
                BNE :1
                RTS

SEEK_CSECT      LDY #rosterLocation
                LDA (CHARDL),Y
                AND #$0E
                LSR
SEEK_SECT       CLC
                ADC #stateSectors
                JMP SEEK_FILE

WRITE_CSECT     JSR SEEK_CSECT
                JMP WRITE_CMN

WRITE_SECT      JSR SEEK_SECT
WRITE_CMN       LDY #>CHAR_BUFFER
                LDA #1
                JMP WRITE_FILE

READ_SECT       JSR SEEK_SECT
                LDA #1
                LDY #>CHAR_BUFFER
                JMP READ_FILE

;-----------------------------------------------------------
;
; On exit:
;   CC: no slots available
;   CS: new slot found
;   CHARDL,H: pointer to new character memory, cleared to zero
;   rosterLocation set to location
;
ALLOC_CHAR      ENT
                LDA #fileSaveGame
                JSR SET_FILE
                LDA #0
:1              PHA
                JSR TEST_ROSTER_LOC
                BNE :2
                PLA
                CLC
                ADC #1
                CMP #maxRosterSize
                BNE :1
                CLC
                RTS

:2              LDX #0
                TXA
:3              STA CHAR_BUFFER,X
                INX
                BNE :3
                PLA
                PHA
                EOR #$01
                JSR TEST_ROSTER_LOC
                BEQ :4
                PLA
                PHA
                LSR
                JSR READ_SECT
:4              PLA
                LSR
                LDA #0
                ROL
                STA CHARDL
                LDA #>CHAR_BUFFER
                STA CHARDH
                TXA
                ORA #$80
                LDY #rosterLocation
                STA (CHARDL),Y
                SEC
                RTS

;-----------------------------------------------------------
;
; On entry:
;   CHAR_BUFFER holding 1 or 2 characters to be written
;
SAVE_CHAR       ENT
                LDA #fileSaveGame
                JSR SET_FILE
                LDX #rosterLocation
                LDA CHAR_BUFFER,X
                BNE :1
                LDA CHAR_BUFFER+128,X
:1              AND #$0F
                PHA
                LSR
                JSR WRITE_SECT
                PLA
                JSR SET_ROSTER_LOC
                JMP SAVE_GAMESTATE_MS

;-----------------------------------------------------------
;
; On entry:
;   NAME_BUFFER: space-padded name to look for
;
; On exit:
;   CC: no duplicate
;   CS: duplicate name found
;
DUPE_NAME_CHECK ENT
                LDA #fileSaveGame
                JSR SET_FILE
                LDA #-1
                STA LAST_SECT
                LDA #>CHAR_BUFFER
                STA CHARDH
                LDA #0
                STA CHARDL
;               LDA #0
:1              PHA
                JSR TEST_ROSTER_LOC
                BEQ :4
                PLA
                PHA
                LSR
                CMP LAST_SECT
                BEQ :2
                STA LAST_SECT
                JSR READ_SECT
:2              LDX #0
                LDY #name
:3              LDA NAME_BUFFER,X
                CMP (CHARDL),Y
                BNE :4
                INY
                INX
                CPX #charNameLength
                BNE :3
                PLA
;               SEC
                RTS

:4              LDA CHARDL
                EOR #$80
                STA CHARDL
                PLA
                CLC
                ADC #1
                CMP #maxRosterSize
                BNE :1
                CLC
                RTS

LAST_SECT       DB  $00

;-----------------------------------------------------------
;
; On exit:
;   CC: roster still has space
;   CS: rost is full
;
IS_ROSTER_FULL  ENT
                LDA ROSTER_BITS+0
                AND ROSTER_BITS+1
                CMP #$FF
                RTS
;
; On entry:
;   A: roster character index (0-15)
;
; On exit:
;   BNE true if bit allocated
;
TEST_ROSTER_LOC JSR DIV_MOD8
                LDA ROSTER_BITS,X
                AND BIT_TABLE,Y
                RTS

SET_ROSTER_LOC  JSR DIV_MOD8
                ORA MASK_TABLE,Y
                STA ROSTER_BITS,X
                RTS

CLEAR_ROSTER_LOC
                JSR DIV_MOD8
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

;-----------------------------------------------------------
;
; Ask for character name
;
; On exit:
;   CC: cancel
;   CS: name entered
;   NAME_BUFFER: result, leading spaced trimmed,
;       end padded with spaces
;
ASK_CHAR_NAME   ENT
                LDA #charNameLength
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

;-----------------------------------------------------------
;
; Check NAME_BUFFER for "NAJA" string
; TODO: could be smarter and search entire string
;
; On exit:
;   CC: no NAJA match
;   CS: matches NAJA
;
IS_NAJA_NAME    ENT
                LDX #0
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

;-----------------------------------------------------------

NAME_BUFFER     ENT
                DS  charNameLength

;-----------------------------------------------------------

DIRTY_STATE     ENT
                DB  $00
DIRTY_CHARS     ENT
                DS  maxGroupSize,$00
