
                ORG $7800

CONTROL_FILE    DB  fileControlMS

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

                ; LDX #<:KEY_FILTER
                ; LDY #>:KEY_FILTER
                ; JSR SET_KEY_FILTER
                ; *** ENABLE CAMP ***

                LDX #<MAP_DATA
                LDY #>MAP_DATA
                JMP SET_MAP_DATA

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
                JSR GET_NSEW

                LDA #$FF
                STA DELCHAR_FILE        ; clear module header

                ; TODO: different load address?
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
                JMP $8000

:FILES          DB  fileEnroll_Load
                DB  fileAssembly_Load
                DB  fileInfirmary_Load
                DB  fileEnergy_Load
                DB  fileArsenal_Load
                DB  fileRobotRep_Load

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
