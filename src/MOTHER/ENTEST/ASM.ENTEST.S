                EXP OFF

                PUT /NAJA/VARS/CONSTANTS
                PUT /COMMON/VARS
                PUT /COMMON/EXT
                PUT /NDOS/EXT
                PUT /NDOS/VARS
                PUT /HALLS/VARS
                PUT /HALLS/EXT
                PUT /CAMP/EXT
                PUT /MOTHER/EXT

                ORG $8000
                PUT LOAD
                DS  \,$EE
                ERR *-$8C00

                ORG $8000
                PUT CONTROL
                DS  \,$EE
                ERR *-$8400

                ORG $8400
ENROLL_FILE     DB  fileEntest_Enroll
                PUT ENROLL/ENROLLMENT
                PUT ENROLL/DEFINE.CHAR
                PUT ENROLL/SAVE.CHAR
                PUT ENROLL/DATA
                DS  \,$EE
                ERR *-$9B00

                ORG $8400
TEST_FILE       DB  fileEntest_Test
                PUT TEST/TESTING
                PUT TEST/UP.DAMAGE
                PUT TEST/PASS.FAIL
                DS  \,$EE
                ERR *-$8E00

                SAV ENROLL.TEST
