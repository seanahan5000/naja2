FLIP            LDA FLIPPED_FLAG
                EOR #$FF
                STA FLIPPED_FLAG
                JSR FLIPPER
                JSR OPT_CURSOR
                JMP GETOP2

UNFLIP_STATS    LDA FLIPPED_FLAG
                BPL :1
                EOR #$FF
                STA FLIPPED_FLAG
                JSR FLIPPER
:1              RTS

FLIPPER         JSR DRAW_PICT
                PictSwap $0F;$02;$28;$42
                PictEnd
                RTS
