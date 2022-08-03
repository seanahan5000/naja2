
                EXP OFF

                PUT /COMMON/VARS
                PUT /COMMON/COMMON.EXT

                ORG $6000

TEST            JSR INIT_RANDOM
                JSR HGR

                ; LDA #6
                ; STA GROUP_SIZE

                ; JSR DRAW_GRID

                ; LDA #$42
                ; JSR DRAW_STATS_BOX

                ; JSR ALIEN_DIRECTORY

HANG            JMP HANG

                PUT ALIEN.ID
                PUT CHARACTERS
                PUT STATS
                PUT TOPVIEWS
                SAV TEST.COMMON
