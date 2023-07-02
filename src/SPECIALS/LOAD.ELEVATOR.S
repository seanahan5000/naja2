
                PUT /HALLS/HALLS.EQU

ELEVATOR_FAR    JSR ELEVATOR_STEP
                JSR DRAW_PICT
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
                JMP :3
:2              BIT UNSTROB
:3              LDA KEYBRD
                BPL :3
                JSR CHECK_MOVE
                BNE :2
                SEC
                RTS

ELEVATOR_123    LDA #0
                BEQ ELEVATOR_ALL        ; always
ELEVATOR_345    LDA #1
ELEVATOR_ALL    PHA
                JSR SAVE_MAPPED
                JSR ELEVATOR_STEP
                JSR DRAW_PICT
                PictSetBlack1
                PictMoveTo $45;$66
                PictLineTo $D2;$66
                PictSetWhite1
                PictRect $4F;$41;$C7;$89
                PictMoveTo $50;$41
                PictLineTo $50;$89
                PictMoveTo $C8;$41
                PictLineTo $C8;$89
                PictCall DRAW_DIAGS_NEAR
                PictEnd
                LDA #fileElevator
                CMP ELEVATOR_FILE
                SEC
                BEQ :1
                PHA
                JSR SHOW_PAGE
                PLA
                LDY #>ELEVATOR_FILE
                JSR LOAD_FILE
                CLC
:1              PLA
                JMP ELEVATOR_CMN

ELEVATOR_STEP   LDX STEP_TYPE
                CPX #3
                BNE :1
                JSR GET_NSEW
:1              JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictEnd
                RTS

DRAW_DIAGS_FAR  LDX #<DIAG_DATA_FAR
                LDY #>DIAG_DATA_FAR
                STX XYDATAL
                STY XYDATAH
                LDX #<DIAGS_FAR
                LDY #>DIAGS_FAR
                JMP DRAW_SEGMENTS

DRAW_DIAGS_NEAR LDX #<DIAG_DATA_NEAR
                LDY #>DIAG_DATA_NEAR
                STX XYDATAL
                STY XYDATAH
                LDX #<DIAGS_NEAR
                LDY #>DIAGS_NEAR
                JMP DRAW_SEGMENTS

DIAGS_FAR       DB  ORD_B, ORD_E
                DB  ORD_A, ORD_F
                DB  ORD_B, ORD_G
                DB  ORD_MOVE
                DB  ORD_C, ORD_E
                DB  ORD_D, ORD_F
                DB  ORD_C, ORD_G
                DB  ORD_STOP

DIAGS_NEAR      DB  ORD_B, ORD_E
                DB  ORD_A, ORD_F
                DB  ORD_B, ORD_G
                DB  ORD_MOVE
                DB  ORD_C, ORD_E
                DB  ORD_D, ORD_F
                DB  ORD_C, ORD_G
                DB  ORD_STOP

;                    A   B   C   D   E   F   G
DIAG_DATA_FAR   DB  $65,$6D,$A7,$AF,$62,$74,$86
DIAG_DATA_NEAR  DB  $44,$4F,$C8,$D3,$41,$66,$89
