
                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /HALLS/VARS
                PUT /HALLS/EXT

*-------------------------------
* REFORMAT ZPAGE

rYHOLD1         =   $C0
rYHOLD2         =   $C1
rYSORC          =   $C2
rYDEST          =   $C3
rARRCURS        =   $C4
rSOURCE         =   $C5
rFLPFLAG        =   $C6
rSTART          =   rFLPFLAG
rCOUNTX         =   $C7
rCOUNTY         =   $C8
rSWFLAG         =   $C9
rLINECNT        =   rSWFLAG
rSCRACH2        =   $CA
*

MCURSOR         =   $CC
CURHOLD         =   $CD
LEFHOLD         =   $CE
RITHOLD         =   $CF

*-------------------------------

                ORG $E000
                PUT T.CAMP.S
                PUT KEY.COMMONS.S
                PUT SCAN.COMMONS.S

                PUT C.ISTATS.S
                PUT C.REFORMAT.S
                PUT /TEST/TOPVIEWS

                PUT /TEST/CHARACTERS
                PUT /TEST/EQUIPMENT
                PUT /TEST/STATS

SHELL           DB  $1              ; TODO: move later
                SAV CAMP.E000
