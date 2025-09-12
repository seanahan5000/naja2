

;---------------------------------------

SET_CONTROL     LDX #<FILE_HOOK
                LDY #>FILE_HOOK
                JSR SET_FILE_HOOK

                LDX #<FILE_TABLE
                LDY #>FILE_TABLE
                JSR SET_FILE_TABLE

                LDX #<DISPATCH
                LDY #>DISPATCH
                JSR SET_HALL_FILTER

                LDX #<:KEY_FILTER
                LDY #>:KEY_FILTER
                JSR SET_KEY_FILTER

                LDX #<MAP_DATA
                LDY #>MAP_DATA
                JMP SET_MAP_DATA

; NOTE: Must set a key filter, even if it's a nop
;   in order to overwrite previous filters.
:KEY_FILTER
                ; TODO: enable camp
                CLC
                RTS

;---------------------------------------

LOAD_AREA       TAX
                LDA :FILES,X
                PHA

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictShowPage
                PictSetPage1
                PictEnd

                ; page 2 black and visible, write page set to 1

                JSR TURN_AROUND
                JSR MOVE_FORWARD

                LDA #$FF
                STA DELCHAR_FILE        ; clear module header

                PLA
                LDY #$80
                JSR LOAD_FILE

                ; flush step forward key
                LDA KEYBRD
                BPL :1
                JSR CHECK_UP
                BNE :1
                BIT UNSTROB
:1
                JSR $8000
                ; each area exits with page 2 visible

                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall GET_NSEW
                PictCall DRAW_HALL
                PictShowPage
                PictEnd
                SEC
                RTS

:FILES          DB  fileEnroll_Load
                DB  fileAssembly_Load
                DB  fileInfirmary_Load
                DB  fileEnergy_Load
                DB  fileArsenal_Load
                DB  fileRobotRep_Load

;---------------------------------------

; TODO: consider combining GUARD and DELETE into one module

GUARD           LDA #fileGuard
                CMP GUARD_FILE
                BEQ :1
                LDY #>ENROLL_GUARD
                JSR LOAD_FILE
:1              JMP ENROLL_GUARD

;---------------------------------------

DELETE          LDA #fileDeleteChar
                CMP DELCHAR_FILE
                BEQ :1
                LDY #>DELETE_CHAR
                JSR LOAD_FILE
:1              JMP DELETE_CHAR

;---------------------------------------

TESSERPORT      PHA
                JSR UPDATE_HALL
                LDA #fileTesserport
                CMP TESSER_FILE
                BEQ :1
                LDY #>TESSERACT_PORT
                JSR LOAD_FILE
:1              PLA
                JMP TESSERACT_PORT

;---------------------------------------

INFO_SELLER     CPX #3                  ; step forward
                BNE :1
                ; JSR RANDOM
                ; AND #$1F
                ; CMP #$13
                ; BNE :1
                JSR RESET_CHRLIST       ; check for not full chars
                JSR CSCAN_PUTABLE
                BCC :1                  ; no room
                LDX #<MIN_PRICE         ; check for minimum credits
                LDY #>MIN_PRICE
                JSR TEST_SPEND
                BCS :2                  ; not enough
:1              CLC
                RTS

:2              LDA #fileInfoSeller
                CMP INFO_FILE
                BEQ :3
                LDY #>SELLER
                JSR LOAD_FILE
:3              JMP SELLER

;---------------------------------------

LOST_IN_GROUP   JSR FIRST_CHAR
:1              LDY #status
                LDA (CHARDL),Y
                SEC
                AND #%00111100
                CMP #%00000100          ; intracc, compressd, inlimbo, lost
                BEQ :2
                JSR NEXT_CHAR
                BCC :1
                CLC
:2              RTS

;---------------------------------------

; No space for this in COMMONS so put it here,
;   and duplicate in FIGHT.

DRAW_MARKER_TIP_TILE ENT
                LDX #<:MARKER_TIP
                LDY #>:MARKER_TIP
                JMP DRAW_TILE

:MARKER_TIP     DB  %00000000
                DB  %00000000
                DB  %00000011
                DB  %00001111
                DB  %00000011
                DB  %00000000
                DB  %00000000

;---------------------------------------

YES_OR_NO       ENT
                BIT UNSTROB
                JSR GET_INPUT_KEY
:1              CMP #"Y"
                BEQ :3
                CMP #"N"
                BEQ :2
                CMP #$9B                ; escape
                BEQ :2
                JSR REGET_INPUT
                JMP :1
:2              CLC
:3              RTS

;---------------------------------------
