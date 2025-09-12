                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /NDOS/EXT
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /CAMP/EXT
                PUT /MOTHER/VARS

BIG_MAP         =   0
SHELLNUM        =   0

; TODO: move into COMMON/VARS.S?
CONTROL_MODULE  =   $7000
MAP_MODULE      =   $8000

                ORG $7000
CONTROL_FILE    DB  fileControlMS
                PUT CONTROL
                PUT /LEVELS/DISPATCH
                PUT LEVEL
                PUT FILES0
                PUT CREDITS
                PUT WRITER
                PUT TRANSPORT
                PUT DOORS
                DS  \,$EE
                DS  256
                DS  256
                ERR *-$7F00
                SAV MOTHERSHIP.7000

                ORG MOTHER_MODULE
GUARD_FILE      DB  fileGuard
                PUT GUARD
                DS  \,$EE
                ERR *-$A500
                SAV GUARD

                ORG MOTHER_MODULE
DELCHAR_FILE    DB  fileDeleteChar
                PUT DELETE
                DS  \,$EE
                ERR *-$A900
                SAV DELETE.CHAR

                ORG MOTHER_MODULE
TESSER_FILE     DB  fileTesserport
                PUT TESSERPORT
                DS  \,$EE
                ERR *-$A400
                SAV TESSERPORT

                ORG MOTHER_MODULE
INFO_FILE       DB  fileInfoSeller
                PUT INFO.SELLER
                DS  \,$EE
                ERR *-$A700
                SAV INFO.SELLER
