                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /NDOS/EXT
                PUT /NDOS/VARS
                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /CAMP/EXT

BIG_MAP         =   0
SHELLNUM        =   0

; TODO: pick better range and/or clean these up
WHICHT			=	$C0
FLAG12			=	$C1
TDELAY          =   $C2                 ; only used by guard scanner
BDELAY          =   $C3                 ; only used by guard scanner

                PUT CONTROL
                PUT /LEVELS/DISPATCH
                PUT LEVEL
                PUT FILES0
                PUT WRITER

                PUT TRANSPORT
                PUT DOORS
                PUT GUARD

                ; ERR *-$B000
                SAV MOTHERSHIP

                ORG $A000
DELCHAR_FILE    DB  fileDeleteChar
                PUT DELETE
                DS  \,$EE
                ERR *-$A900
                SAV DELETE.CHAR

                ORG $A000
TESSER_FILE     DB  fileTesserport
                PUT TESSERPORT
                DS  \,$EE
                ERR *-$A400
                SAV TESSERPORT

                ORG $A000
INFO_FILE       DB  fileInfoSeller
                PUT INFO.SELLER
                DS  \,$EE
                ERR *-$A700
                SAV INFO.SELLER
