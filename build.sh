#!/bin/bash

#---------------------------------------
# Set up environment
#---------------------------------------

ROOT=`pwd`
SRC="$ROOT/src"
OBJ="$ROOT/obj"
DSK="$ROOT/dsk"
TOOLS="$ROOT/tools/bin/mac_arm64"
ASM="$TOOLS/asm6502 -root $SRC -objbase ../obj -srcbase"

if ! [[ -d "$OBJ" ]]; then
  mkdir $OBJ
fi

if ! [[ -d "$DSK" ]]; then
  mkdir $DSK
fi

#---------------------------------------
# Assemble all source files
#---------------------------------------

$ASM NDOS   NDOS.525    -lst $OBJ/NDOS.525.LST -ent $SRC/NDOS/EXT.S
$ASM COMMON ASM.COMMON  -lst $OBJ/COMMON.LST   -ent $SRC/COMMON/EXT.S
$ASM HALLS  ASM.HALLS   -lst $OBJ/HALLS.LST    -ent $SRC/HALLS/EXT.S
$ASM CAMP   ASM.CAMP    -lst $OBJ/CAMP.LST     -ent $SRC/CAMP/EXT.S
$ASM ALIENS ASM.PICS    -lst $OBJ/PICS.LST
$ASM ALIENS ALIEN.DESC.12
$ASM ALIENS ALIEN.DESC.345

$ASM TEST   GAME.STATE
$ASM TEST   TEST.CONTROL -lst $OBJ/CONTROL.LST

#---------------------------------------
# Build disk .nib images
#---------------------------------------

A2NIB="$TOOLS/a2nib -disk $DSK/naja2.nib"
$A2NIB -create -volume 1


$A2NIB $OBJ/ALIEN.PICS.12   -t 00 -s 00   # A900
$A2NIB $OBJ/ALIEN.PICS.345  -t 0B -s 00   # C000
$A2NIB $OBJ/ALIEN.DESC.12   -t 17 -s 00   # 0E00
$A2NIB $OBJ/ALIEN.DESC.345  -t 18 -s 00   # 0D00

$A2NIB $OBJ/DIAGNOSE        -t 19 -s 00   # 14 sectors
                                          #  2 sectors
$A2NIB $OBJ/ALIEN.ID        -t 1A -s 00   #  6 sectors
                                          #  2 sectors
$A2NIB $OBJ/ELEVATOR        -t 1A -s 08   #  8 sectors

#---------------------------------------
# Copy all project files
#---------------------------------------

PROJ="$ROOT/../dbug/naja2"

if ! [[ -d "$PROJ" ]]; then
  mkdir $PROJ
fi

cp project-naja2.json $PROJ/..

cp $OBJ/*           $PROJ
cp $DSK/naja2.nib   $PROJ

#---------------------------------------
