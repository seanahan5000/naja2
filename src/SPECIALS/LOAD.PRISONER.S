
PRISON_DOOR     JSR UPDATE_HALL
                JSR DRAW_PICT
                PictSetOrange
                PictRect 101;45;177;83
                PictRect 103;46;175;82
                PictTextAt 113;51;"DETENTION"
                PictTextAt 110;61;"CELL BLOCK"
                PictTextAt 128;71;"1138"
;               PictTextAt 125;71;"AA-23"   // cell 2187
                PictEnd
                JSR LOAD_PRISON
                SEC
                RTS

PRISON_CELL     JSR LOAD_PRISON
                JMP DO_PRISON_CELL

LOAD_PRISON     PHA
                LDA #filePrisoner
                CMP PRISON_FILE
                BEQ :2
                STX :1+1
                LDY #>PRISON_FILE
                JSR LOAD_FILE
:1              LDX #$FF                ; modified
:2              PLA
                RTS
