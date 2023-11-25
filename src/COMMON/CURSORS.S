; On entry:
;   X: x position
;   Y: y position

DRAW_ARROW      ENT
                JSR MOVE_TO
                LDX #<:ARROW_TAIL
                LDY #>:ARROW_TAIL
                JSR DRAW_TILE
                LDX #<:ARROW_HEAD
                LDY #>:ARROW_HEAD
                JMP DRAW_TILE

:ARROW_TAIL     DB  %00000000
                DB  %00000000
                DB  %00000000
                DB  %01111111
                DB  %00000000
                DB  %00000000
                DB  %00000000

:ARROW_HEAD     DB  %00000000
                DB  %00000011
                DB  %00000110
                DB  %00011111
                DB  %00000110
                DB  %00000011
                DB  %00000000

DRAW_MARKER     ENT
                JSR MOVE_TO
DRAW_MARKER_TILE ENT
                LDX #<:MARKER
                LDY #>:MARKER
                JMP DRAW_TILE

:MARKER         DB  %00000000
                DB  %00011111
                DB  %00011111
                DB  %00011111
                DB  %00011111
                DB  %00011111
                DB  %00000000

DRAW_MARKER_TIP ENT
                JSR MOVE_TO
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

DRAW_TRIANGLE   ENT
                JSR MOVE_TO
                LDX #<:TRIANGLE
                LDY #>:TRIANGLE
                JMP DRAW_TILE

:TRIANGLE       DB  %00000011
                DB  %00000111
                DB  %00001111
                DB  %00111111
                DB  %00001111
                DB  %00000111
                DB  %00000011
