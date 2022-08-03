
                DS  \,$EE               ; no alignment should be required

LOBYTES         ENT
                HEX 0000000000000000
                HEX 8080808080808080
                HEX 0000000000000000
                HEX 8080808080808080
                HEX 0000000000000000
                HEX 8080808080808080
                HEX 0000000000000000
                HEX 8080808080808080
                HEX 2828282828282828
                HEX A8A8A8A8A8A8A8A8
                HEX 2828282828282828
                HEX A8A8A8A8A8A8A8A8
                HEX 2828282828282828
                HEX A8A8A8A8A8A8A8A8
                HEX 2828282828282828
                HEX A8A8A8A8A8A8A8A8
                HEX 5050505050505050
                HEX D0D0D0D0D0D0D0D0
                HEX 5050505050505050
                HEX D0D0D0D0D0D0D0D0
                HEX 5050505050505050
                HEX D0D0D0D0D0D0D0D0
                HEX 5050505050505050
                HEX D0D0D0D0D0D0D0D0

SET_PAGE2       ENT
                LDA #$40
                BNE SET_PAGE        ; always
SET_PAGE1       ENT
                LDA #$20
SET_PAGE        ENT
                STA PAGE
                LDA HIBYTES
                CMP PAGE
                BEQ :2
                LDX #192
:1              LDA HIBYTES-1,X
                EOR #$60
                STA HIBYTES-1,X
                DEX
                BNE :1
:2              RTS

HGR             ENT
                LDA #$20
                JSR SET_PAGE
                JSR CLEAR_PAGE
                STA PRIMARY
                STA NOMIXED
                STA HIRES
                STA GRAPHICS
                RTS

INIT_RANDOM     ENT
                LDA #$12
                STA SEED0
                LDA #$34
                STA SEED1
                RTS

                DS  \,$EE               ; TODO: use these bytes

HIBYTES         ENT
                HEX 2024282C3034383C
                HEX 2024282C3034383C
                HEX 2125292D3135393D
                HEX 2125292D3135393D
                HEX 22262A2E32363A3E
                HEX 22262A2E32363A3E
                HEX 23272B2F33373B3F
                HEX 23272B2F33373B3F
                HEX 2024282C3034383C
                HEX 2024282C3034383C
                HEX 2125292D3135393D
                HEX 2125292D3135393D
                HEX 22262A2E32363A3E
                HEX 22262A2E32363A3E
                HEX 23272B2F33373B3F
                HEX 23272B2F33373B3F
                HEX 2024282C3034383C
                HEX 2024282C3034383C
                HEX 2125292D3135393D
                HEX 2125292D3135393D
                HEX 22262A2E32363A3E
                HEX 22262A2E32363A3E
                HEX 23272B2F33373B3F
                HEX 23272B2F33373B3F

DIV7HI          ;ENT
                HEX 242424
                HEX 25252525252525
                HEX 26262626262626
                HEX 27272727272727

HMASKS          ;ENT
                DB  %00000001
                DB  %00000010
                DB  %00000100
                DB  %00001000
                DB  %00010000
                DB  %00100000
                DB  %01000000

LEFT_MASKS      DB  %00000000
                DB  %00000001
                DB  %00000011
                DB  %00000111
                DB  %00001111
                DB  %00011111
                DB  %00111111

RIGHT_MASKS     DB  %01111110       ; NOTE: right masks are inclusive
                DB  %01111100
                DB  %01111000
                DB  %01110000
                DB  %01100000
                DB  %01000000
                DB  %00000000

                DS  \,$EE           ; TODO: use these bytes

DIV7            ;ENT
                HEX 00000000000000
                HEX 01010101010101
                HEX 02020202020202
                HEX 03030303030303
                HEX 04040404040404
                HEX 05050505050505
                HEX 06060606060606
                HEX 07070707070707
                HEX 08080808080808
                HEX 09090909090909
                HEX 0A0A0A0A0A0A0A
                HEX 0B0B0B0B0B0B0B
                HEX 0C0C0C0C0C0C0C
                HEX 0D0D0D0D0D0D0D
                HEX 0E0E0E0E0E0E0E
                HEX 0F0F0F0F0F0F0F
                HEX 10101010101010
                HEX 11111111111111
                HEX 12121212121212
                HEX 13131313131313
                HEX 14141414141414
                HEX 15151515151515
                HEX 16161616161616
                HEX 17171717171717
                HEX 18181818181818
                HEX 19191919191919
                HEX 1A1A1A1A1A1A1A
                HEX 1B1B1B1B1B1B1B
                HEX 1C1C1C1C1C1C1C
                HEX 1D1D1D1D1D1D1D
                HEX 1E1E1E1E1E1E1E
                HEX 1F1F1F1F1F1F1F
                HEX 20202020202020
                HEX 21212121212121
                HEX 22222222222222
                HEX 23232323232323
                HEX 24242424

MOD7            ;ENT
                HEX 00010203
MOD7HI          ;ENT
                HEX 040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203040506
                HEX 00010203
