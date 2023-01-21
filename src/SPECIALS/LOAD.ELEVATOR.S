
                PUT /HALLS/HALLS.EQU

ELEVATOR_FAR    JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictSetBlack1
                PictMoveTo $66;$74
                PictLineTo $AE;$74
                PictSetWhite1
                PictRect $6D;$62;$A7;$86
                PictCall DRAW_DIAGS_FAR
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd
                JSR LOAD_ELEVATOR
                JMP :2

:1              BIT UNSTROB
:2              LDA KEYBRD
                BPL :2
                JSR CHECK_MOVE
                BNE :1
                SEC
                RTS

DRAW_DIAGS_FAR  LDX #<DIAG_DATA_FAR
                LDY #>DIAG_DATA_FAR
                STX XYDATAL
                STY XYDATAH
                LDX #<DIAGS_FAR
                LDY #>DIAGS_FAR
                JMP DRAW_SEGMENTS

DIAGS_FAR       DB  ORD_B, ORD_E
                DB  ORD_A, ORD_F
                DB  ORD_B, ORD_G
                DB  ORD_MOVE
                DB  ORD_C, ORD_E
                DB  ORD_D, ORD_F
                DB  ORD_C, ORD_G
                DB  ORD_STOP

;                    A   B   C   D   E   F   G
DIAG_DATA_FAR   DB  $65,$6D,$A7,$AF,$62,$74,$86

ELEVATOR_123    JSR LOAD_ELEVATOR
                LDA #0
                JMP ELEVATOR_CMN

ELEVATOR_345    JSR LOAD_ELEVATOR
                LDA #1
                JMP ELEVATOR_CMN

LOAD_ELEVATOR   LDA #fileElevator
                CMP ELEVATOR_FILE
                BEQ :1
                LDY #>ELEVATOR_FILE
                JMP LOAD_FILE
:1              RTS
