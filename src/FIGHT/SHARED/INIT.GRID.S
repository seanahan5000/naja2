
;
; capture 3 rows of hall block data facing aliens and characters
;   (XSIDE bits are forced set for later use by LIMIT_HALLS)
;
CAPTURE_HALLS
                LDX #3
:1              LDA BLOCK_BUFFER,X
                ORA #XSIDE_MASK
                STA AGRID_HALLS,X
                DEX
                BPL :1

                JSR MOVE_FORWARD
                JSR MOVE_FORWARD
                JSR GET_NSEW

                LDX #1
:2              LDA BLOCK_BUFFER,X
                ORA #XSIDE_MASK
                STA AGRID_HALLS+4,X
                DEX
                BPL :2

                JSR TURN_AROUND
                JSR MOVE_FORWARD
                JSR GET_NSEW

                LDX #3
:3              LDA BLOCK_BUFFER,X
                ORA #XSIDE_MASK
                STA CGRID_HALLS,X
                DEX
                BPL :3

                JSR MOVE_FORWARD
                JSR MOVE_FORWARD
                JSR GET_NSEW

                LDX #1
:4              LDA BLOCK_BUFFER,X
                ORA #XSIDE_MASK
                STA CGRID_HALLS+4,X
                DEX
                BPL :4

                JSR TURN_AROUND
                JSR MOVE_FORWARD
                JMP GET_NSEW
