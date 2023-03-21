                JMP FIGHT_LOADER
                JMP SPECIAL_LOAD

SAVE_SEED       =   $FE

FIGHT_LOADER    LDX #%11111111
                LDY #%11110000
                LDA #%00000000
                STA TAKEN_COUNT
SPECIAL_LOAD    STX OPTIONS1        ;Calling routine must clear
                STY OPTIONS2        ;   TAKEN_COUNT if unused
                STA FORCE_SURPRISE

                ; TODO: remove this debug code
                LDA SEED0
                STA SAVE_SEED+0
                LDA SEED1
                STA SAVE_SEED+1

                TXA
                AND #Xalien1+Xalien2+Xalien3
                BEQ :SKIPA
                JSR SET_DATA_FILE
                JSR PICK_ALIENS
:SKIPA          LDA OPTIONS1
                AND #Xhmany1+Xhmany2+Xhmany3
                BEQ :SKIPB
                JSR PICK_NUMBER
:SKIPB          LDA OPTIONS2
                AND #Xpicture       ;Calling routine must setup
                BEQ :SKIPC          ;   DIRHOLD if skipping picture
                JSR DRAW_PICTURE
:SKIPC          JSR SHOW_PAGE2
                ; LDA #$00
                ; STA CAMP_HERE
                ;*** clear out module id ***
                ;*** spin down drive? wait for key?
*** LOOK THROUGH SPECIALS TABLE
*** IF NONE FOUND, SKIP
                ; CLC                 ;TEMP
                ; BCC NOSPECIAL       ;TEMP
*** LOAD SPECIAL FILE
                ; JSR SPECIAL
                ; CLC                 ;TEMP
                ; BCC NOEXIT

; TODO: needed in case player knows Ruuik's guards password
; EXIT_EARLY      LDA DIRHOLD
;                 STA DIRECTN
;                 LDA #$20
;                 STA PAGE
;                 JSR CLEAR1
;                 LDA #WHITE1
;                 STA COLOR
;                 JSR GETNSEW
;                 JSR NOSCAN
;                 STA PRIMARY
;             do ORIGINAL
;             else
;                 LDA DISK_SIDE
;                 EOR #side_T1!side_F1            ;! means XOR
;                 STA DISK_SIDE
;             fin
;                 JMP RDKEY


NOEXIT          ; JSR DRIVE_ON
NOSPECIAL       ; LDX #fLoader2
                ; JSR FLOADER_FILE
                JSR SET_DATA_FILE
                JSR LOAD_DATA
                LDA #0
                STA ROUND
                STA SURPRISED_FLAG
                STA ATOTAL1
                STA ATOTAL2
                STA ATOTAL3
                JSR MAKE_ALLMONS
                JSR FIGHT_SCREEN
                ; JSR SURPRISE_SUB
                ; LDA #$62
                ; PHA
                ; LDA #$FF
                ; PHA
                ; LDX #fCommand
                ; JMP FLOAD_FILE

                JSR DRAW_PICT
                PictSetPage1
                ; PictCopyToPage
                PictShowPage
                PictEnd
                RTS

SET_DATA_FILE   LDY SHELL
                LDA :DATA_FILES-1,Y
                JMP SET_FILE
;
; Base file for alien data by shell
;
:DATA_FILES     DB  fileAlienData12
                DB  fileAlienData12
                DB  fileAlienData345
                DB  fileAlienData345
                DB  fileAlienData345

OPTIONS1        DS  1
OPTIONS2        DS  1
FORCE_SURPRISE  DS  1
TWINS_FLAG      DS  1
