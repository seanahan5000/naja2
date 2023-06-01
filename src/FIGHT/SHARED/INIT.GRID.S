
;
; capture 3 rows of hall block data facing aliens and characters
;   (XSIDE bits are forced set for later use by LIMIT_HALLS)
;
CAPTURE_HALLS   JSR GET_NSEW
                LDX #5
:1              LDA BLOCK_BUFFER,X
                ORA #XSIDE_MASK
                STA AGRID_HALLS,X
                DEX
                BPL :1

                JSR MOVE_FORWARD
                JSR TURN_AROUND
                JSR GET_NSEW
                LDX #5
:2              LDA BLOCK_BUFFER,X
                ORA #XSIDE_MASK
                STA CGRID_HALLS,X
                DEX
                BPL :2
                JSR MOVE_FORWARD
                JMP TURN_AROUND
