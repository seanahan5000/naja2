
                EXP OFF

                PUT /COMMON/VARS
                PUT /COMMON/EXT

                PUT /CAMP/EXT

                PUT /NDOS/VARS
                PUT /NDOS/EXT

                PUT /NAJA/VARS/CONSTANTS
                PUT /FIGHT/FIGHT.MACROS
                PUT /FIGHT/FIGHT.CONSTS
                PUT /FIGHT/FIGHT.ZPAGE

                PUT /FIGHT/SHARED/EXT

                DO  0               ;TEMP***
*---------------------------------------
                ORG $0000
HEADER4         DB  1               ;# of entries
                DB  4               ;bytes per entry
*---
                HDR 0;0;END4
*---
* PUT SCODE/AIRSWIM

*---
END4
                SAV /FIGHT/FIGHT.SCODE.4
*---------------------------------------

*---------------------------------------
                ORG $0000
HEADER5         DB  1               ;# of entries
                DB  4               ;bytes per entry
*---
                HDR 0;0;END5
*---
* PUT SCODE/TIMWARP

*---
END5
                SAV /FIGHT/FIGHT.SCODE.5
*---------------------------------------
                FIN                 ;TEMP***

                DSK FIGHT.NARRATOR
                ORG $6000

                PUT EQUATES
                PUT TEXT/WORD.EQUATES
                PUT CONTROL

                PUT F.CHARATE
                PUT CHR/SWING
                PUT CHR/SHOOT/SHOOT
                PUT CHR/SHOOT/BLASTER
                PUT CHR/SHOOT/BRAIN.JAMMER
                PUT CHR/SHOOT/ROBOT.RESTRNR
                PUT CHR/ENERGY
                PUT CHR/THROW/THROW
                PUT CHR/THROW/BOOMERANG
                PUT CHR/THROW/IMMOBILIZER
                PUT CHR/THROW/GRENADE
                PUT CHR/USE/USE
                PUT CHR/USE/DRUGS
                PUT CHR/USE/HEALING
                PUT CHR/MOVE
                PUT CHR/IDENTIFY
                PUT CHR/EXCHANGE
                PUT CHR/RUN
                PUT F.CATSUBS

                PUT F.MONRATE
                PUT MON/SWING
                PUT MON/SHOOT
                PUT MON/AIM
                PUT MON/MOVE
                PUT F.FIGHTER
                PUT SUBS/SMART.MOVE

                PUT F.ROUTINE
                PUT SUBS/DAMAGE.SUBS
                PUT SUBS/INFLICTERS
                PUT SUBS/AIM.DISTANCE
                PUT SUBS/SHOT.SUBS
                PUT SUBS/ODDS.ROUTINES
                PUT SUBS/EXPLOSION
                PUT SUBS/GRID.ROUTINES
                PUT SUBS/TOPVIEWS
                PUT SUBS/NEW.ROUTINES
                PUT SUBS/TAKE.ITEM
                PUT SUBS/STATUS.SUBS
                PUT SUBS/RUN.RESOLVER
                PUT TEXT/TEXT.ROUTINES
                PUT TEXT/WORD.LIST
                PUT F.DTABLES

; TODO: these were zpage, should be saved in settings, shared with COMMAND
DELAY_TIME      DB  $25
DELAY_MODE      DB  $01
