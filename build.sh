#!/bin/bash

# Assumes asm6502 and a2nib are on path
# Add "export PATH=$PATH:~/dev/rpw-tools/bin" to .zprofile

#---------------------------------------
# Set up environment
#---------------------------------------

ROOT=`pwd`
SRC="$ROOT/src"
OBJ="$ROOT/obj"
DSK="$ROOT/dsk"
DATA="$ROOT/data"
ASM="asm6502 -root $SRC -objbase ../obj -srcbase"

if ! [[ -d "$OBJ" ]]; then
  mkdir $OBJ
fi

if ! [[ -d "$DSK" ]]; then
  mkdir $DSK
fi

#---------------------------------------
# Assemble all source files
#---------------------------------------

ERR=0
$ASM COMMON ASM.COMMON  -lst $OBJ/COMMON.LST   -ent $SRC/COMMON/EXT.S || ERR=1
$ASM BOOT   ASM.TITLE   -lst $OBJ/TITLE.LST                           || ERR=1
$ASM NDOS   NDOS.525    -lst $OBJ/NDOS.LST     -ent $SRC/NDOS/EXT.S   || ERR=1
$ASM HALLS  ASM.HALLS   -lst $OBJ/HALLS.LST    -ent $SRC/HALLS/EXT.S  || ERR=1
$ASM CAMP   ASM.CAMP    -lst $OBJ/CAMP.LST     -ent $SRC/CAMP/EXT.S   || ERR=1

$ASM MOTHER/CONTROL   ASM.MOTHER    -lst $OBJ/MOTHERSHIP.LST    -ent $SRC/MOTHER/EXT.S || ERR=1
$ASM MOTHER/ENTEST    ASM.ENTEST    -lst $OBJ/ENTEST.LST     || ERR=1
$ASM MOTHER/GROUP     ASM.GROUP     -lst $OBJ/GROUP.LST      || ERR=1
$ASM MOTHER/INFIRMARY ASM.INFIRMARY -lst $OBJ/INFIRMARY.LST  || ERR=1
$ASM MOTHER/ENERGY    ASM.ENERGY    -lst $OBJ/ENERGY.LST     || ERR=1
$ASM MOTHER/ARSENAL   ASM.ARSENAL   -lst $OBJ/ARSENAL.LST    || ERR=1
$ASM MOTHER/ROBOTS    ASM.ROBOTS    -lst $OBJ/ROBOTS.LST     || ERR=1

### TODO: .lst files only needed for sizing information ###
$ASM ALIENS ASM.PICS    -lst $OBJ/ALIEN.PICS.LST        || ERR=1
$ASM ALIENS ASM.DATA    -lst $OBJ/ALIEN.DATA.LST        || ERR=1
$ASM ALIENS ALIEN.DESC.12                               || ERR=1
$ASM ALIENS ALIEN.DESC.345                              || ERR=1

$ASM FIGHT/SHARED   ASM.SHARED   -lst $OBJ/SHARED.LST  -ent $SRC/FIGHT/SHARED/EXT.S || ERR=1
$ASM FIGHT/LOADER   ASM.LOADER   -lst $OBJ/LOADER.LST   || ERR=1
$ASM FIGHT/COMMAND  ASM.COMMAND  -lst $OBJ/COMMAND.LST  || ERR=1
$ASM FIGHT/NARRATOR ASM.NARRATOR -lst $OBJ/NARRATOR.LST || ERR=1
$ASM FIGHT/REFORMAT ASM.REFORMAT -lst $OBJ/REFORMAT.LST || ERR=1
$ASM FIGHT  ASM.FIGHT   -lst $OBJ/FIGHT.LST             || ERR=1

$ASM LEVELS INIT        -lst $OBJ/INIT.LST              || ERR=1
$ASM LEVELS ASM.17      -lst $OBJ/CONTROL17.LST         || ERR=1
$ASM LEVELS ASM.15      -lst $OBJ/CONTROL15.LST         || ERR=1
$ASM LEVELS ASM.13      -lst $OBJ/CONTROL13.LST         || ERR=1
$ASM LEVELS ASM.11      -lst $OBJ/CONTROL11.LST         || ERR=1
$ASM LEVELS ASM.9       -lst $OBJ/CONTROL9.LST          || ERR=1

$ASM TEST   GAME.STATE  -lst $OBJ/GAME.STATE.LST        || ERR=1

if [ "$ERR" == "1" ]; then
  echo
  echo "### Assembly errors ###"
  echo
  exit
fi

#---------------------------------------
# Build disk .nib images
#---------------------------------------

A2NIB_MS="a2nib -disk $DSK/naja0.nib"
A2NIB_T1="a2nib -disk $DSK/naja1.nib"
A2NIB_T2="a2nib -disk $DSK/naja2.nib"
A2NIB_T3="a2nib -disk $DSK/naja3.nib"

$A2NIB_MS -create -volume 0
$A2NIB_T1 -create -volume 1
$A2NIB_T2 -create -volume 2
$A2NIB_T3 -create -volume 3

# mothership
$A2NIB_MS $OBJ/DELETE.CHAR     -t 0E -s 00   # 10 sectors
$A2NIB_MS $OBJ/TESSERPORT      -t 0E -s 0C   #  4 sectors
$A2NIB_MS $OBJ/INFO.SELLER     -t 0F -s 00   #  7 sectors
$A2NIB_MS $OBJ/ENROLL.TEST     -t 13 -s 00   # 64 sectors
$A2NIB_MS $OBJ/GROUP.ASSEMBLY  -t 11 -s 00   # 32 sectors
$A2NIB_MS $OBJ/INFIRMARY       -t 17 -s 00   # 24 sectors
$A2NIB_MS $OBJ/ENERGY.CENTER   -t 18 -s 08   # 24? sectors
$A2NIB_MS $OBJ/ARSENAL         -t 1B -s 00   # 24? sectors
$A2NIB_MS $OBJ/ROBOT.REPAIR    -t 1F -s 00   # 64 sectors

# shell 17,15
$A2NIB_T1 $OBJ/ALIEN.PICS.12   -t 00 -s 00   # A900
$A2NIB_T1 $OBJ/ALIEN.DESC.12   -t 0C -s 00   # 0E00
$A2NIB_T1 $OBJ/ALIEN.DATA.12   -t 0D -s 00   # 2E00

# shell 13,11,9
$A2NIB_T2 $OBJ/ALIEN.PICS.345  -t 00 -s 00   # C000
$A2NIB_T2 $OBJ/ALIEN.DESC.345  -t 0C -s 00   # 0D00
$A2NIB_T2 $OBJ/ALIEN.DATA.345  -t 0D -s 00   # 2D00

# shell all
$A2NIB_T1 $OBJ/DIAGNOSE        -t 14 -s 00   # 14 sectors
$A2NIB_T2 $OBJ/DIAGNOSE        -t 14 -s 00   # 14 sectors
                                             #  2 sectors
$A2NIB_T1 $OBJ/ALIEN.ID        -t 15 -s 00   #  6 sectors
$A2NIB_T2 $OBJ/ALIEN.ID        -t 15 -s 00   #  6 sectors
                                             #  2 sectors
$A2NIB_T1 $OBJ/ELEVATOR        -t 15 -s 08   #  8 sectors
$A2NIB_T2 $OBJ/ELEVATOR        -t 15 -s 08   #  8 sectors

# shell 17,15
$A2NIB_T1 $OBJ/CONTROL17       -t 10 -s 00   # 16 sectors (trim)
$A2NIB_T1 $OBJ/CONTROL15       -t 11 -s 00   # 12 sectors (trim)
$A2NIB_T1 $OBJ/FIGHT.LOADER1   -t 13 -s 00   #  5 sectors

# shell 17
$A2NIB_T1 $OBJ/VIEWPORT        -t 16 -s 00   #  9 sectors
                                             #  7 sectors
$A2NIB_T1 $OBJ/RUUIK           -t 17 -s 00   # 13 sectors
                                             #  3 sectors

# shell 13,11,9
$A2NIB_T2 $OBJ/CONTROL13       -t 10 -s 00   # 12 sectors (trim)
                                             #  4 sectors
$A2NIB_T2 $OBJ/CONTROL11       -t 11 -s 00   # 12 sectors (trim)
                                             #  4 sectors
$A2NIB_T2 $OBJ/CONTROL9        -t 12 -s 00   # 12 sectors (trim)
                                             #  4 sectors
$A2NIB_T2 $OBJ/FIGHT.LOADER1   -t 13 -s 00   #  5 sectors

# shell 9
$A2NIB_T2 $OBJ/KEY.DOOR        -t 16 -s 00   # 13 sectors
                                             #  3 sectors

$A2NIB_T3 $OBJ/FIGHT.LOADER2   -t 0E -s 00   #  3 sectors
$A2NIB_T3 $OBJ/FIGHT.SHARED    -t 0F -s 00   # 16 sectors
$A2NIB_T3 $OBJ/FIGHT.COMMAND   -t 10 -s 00   # 48+ sectors
$A2NIB_T3 $OBJ/FIGHT.NARRATOR  -t 14 -s 00   # 64 sectors
$A2NIB_T3 $OBJ/HALLS           -t 1B -s 00   # 16 sectors
$A2NIB_T3 $OBJ/AWARDER         -t 1D -s 00   # 13 sectors
$A2NIB_T3 $OBJ/DEAD.GROUP      -t 1E -s 00   # 13 sectors
$A2NIB_T3 $OBJ/REFORMAT        -t 20 -s 00   #  7 sectors
                                             #  9 sectors

#---------------------------------------
# Copy all project files
#---------------------------------------

PROJECTS="$ROOT/../dbug/projects"

if ! [[ -d "$PROJECTS" ]]; then
  mkdir $PROJECTS
fi

PROJ="$PROJECTS/naja2"

if ! [[ -d "$PROJ" ]]; then
  mkdir $PROJ
fi

if ! [[ -d "$PROJ/data" ]]; then
  mkdir "$PROJ/data"
fi

cp project-naja2.json $PROJ
cp $OBJ/*           $PROJ
cp $DSK/naja*.nib   $PROJ
cp $DATA/*.json     $PROJ/data

#---------------------------------------
