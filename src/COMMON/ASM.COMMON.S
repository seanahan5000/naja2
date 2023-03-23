
                EXP OFF

                PUT /NAJA/VARS/CONSTANTS

                ORG $0800

                PUT VARS

                PUT TABLES
                PUT UTILS
                PUT UNPACK
                PUT BLIT
                PUT SHAPES

                ; TODO: reorder code to avoid alignment issues
                DS  32
                PUT PICT

                PUT TEXT
                PUT INPUT
                PUT FONT
                PUT CURSORS

                SAV COMMON
