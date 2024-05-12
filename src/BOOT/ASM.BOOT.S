
                PUT /NAJA/VARS/CONSTANTS
                PUT /NDOS/EXT
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                ORG $0800
                PUT BOOT1
                SAV BOOT

                ORG $6000
                PUT TITLE.PAGE.S
                PUT TITLE.DATA.S
                PUT BOOT2
                SAV TITLE.PAGE
