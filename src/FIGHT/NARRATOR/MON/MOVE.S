MON_MOVE        LDY #monCRNTCMD+1
                LDA (MONS_PTR),Y
                TAX
                AND #%00001111
                CMP #11                 ; running off top of grid?
                BEQ :2
                TXA
                PHA
                JSR CHECK_AGRID_MAIN
                BCS :1              ;Dest square should never be full
                JSR MONS_FROMGRID
                JSR DRAW_ALIEN
                PLA
                PHA
                LDY #monPOSITION
                STA (MONS_PTR),Y
                JSR MONS_TOGRID
                JSR DRAW_ALIEN
                JSR UPDATE_MNAMES
:1              PLA
                JMP MCOM

:2              JSR MONS_FROMGRID       ; ran off top of grid
                JSR DRAW_ALIEN
                JSR UPDATE_MNAMES
                DEC ATALLY
                LDY #monSTATUS
                LDA #dead
                STA (MONS_PTR),Y
                JMP MCOM
