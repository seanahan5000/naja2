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

$ASM NDOS   NDOS.525    -lst $OBJ/NDOS.525.LST
$ASM COMMON ASM.COMMON  -lst $OBJ/COMMON.LST   -ent $SRC/COMMON/EXT.S
$ASM HALLS  ASM.HALLS   -lst $OBJ/HALLS.LST    -ent $SRC/HALLS/EXT.S
$ASM CAMP   ASM.CAMP    -lst $OBJ/CAMP.LST     -ent $SRC/CAMP/EXT.S
$ASM ALIENS ASM.PICS    -lst $OBJ/PICS.LST
$ASM ALIENS ALIEN.DESC.12
$ASM ALIENS ALIEN.DESC.345

$ASM TEST   GAME.STATE.S
$ASM TEST   TEST.CONTROL.S -lst $OBJ/CONTROL.LST

#---------------------------------------
# Build disk .nib images
#---------------------------------------

A2NIB="$TOOLS/a2nib -disk $DSK/naja2.nib"
$A2NIB -create -volume 0

$A2NIB $OBJ/ALIEN.PICS.12   -t 00 -s 00
$A2NIB $OBJ/ALIEN.PICS.345  -t 10 -s 00
$A2NIB $OBJ/ALIEN.DESC.12   -t 20 -s 00
$A2NIB $OBJ/ALIEN.DESC.345  -t 21 -s 00

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
