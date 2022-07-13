#!/bin/bash
set -x

./asm6502 ASM.COMMON -lst COMMON.LST -ent COMMON.EXT.S
./asm6502 TEST.COMMON -lst TEST.COMMON.LST

cp COMMON ../../../dbug/naja2
cp COMMON.LST ../../../dbug/naja2

cp TEST.COMMON ../../../dbug/naja2
cp TEST.COMMON.LST ../../../dbug/naja2
