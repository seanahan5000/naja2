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

$ASM COMMON ASM.COMMON.S  -lst $OBJ/COMMON.LST -ent $SRC/COMMON/COMMON.EXT.S
$ASM ALIENS ASM.PICS      -lst $OBJ/ASM.PICS.LST

$ASM TEST   TEST.COMMON.S -lst $OBJ/TEST.COMMON.LST

#---------------------------------------
# Build disk .nib images
#---------------------------------------

A2NIB="$TOOLS/a2nib -disk $DSK/naja2.nib"
$A2NIB -create -volume 0

$A2NIB $OBJ/ALIEN.PICS.12   -t 00 -s 00
$A2NIB $OBJ/ALIEN.PICS.345  -t 10 -s 00

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
