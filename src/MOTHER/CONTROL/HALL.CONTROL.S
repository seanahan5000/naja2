
*-------------------------------
*
*-------------------------------

TESPORT         JSR LOST_IN_GROUP
                BCC :SKIPA
                LDA #0
                RTS
:SKIPA          JSR STEP_SUB
                LDX #mTesseract
                JSR SLOAD_FILE
                JMP TESS_BEGIN

*-------------------------------
*
*-------------------------------

STATTER         LDA GRPNUMB
                BEQ :SKIPA
                JSR LOST_IN_GROUP
                BCC :SKIPB
:SKIPA          JMP RDKEY
:SKIPB          LDA #$FF
                STA PICHERE
                JMP CAMP_VECTOR

*-------------------------------
*
*-------------------------------

LOST_IN_GROUP   LDA #0
                STA COUNT
:LOOP1          JSR POINTIT
                LDY #status
                LDA (CHARDL),Y
                SEC
                AND #%00111100
                CMP #%00000100      ;intracc, compressd, inlimbo, lost
                BEQ :EXIT
                INC COUNT
                LDA COUNT
                CMP GRPNUMB
                BNE :LOOP1
                CLC
:EXIT           RTS

*-------------------------------
*
*-------------------------------

LOAD_SUB        STY :MOD1+1
                JSR CLEAR2
                STA SCNDARY
                JSR CLEAR1
                STA PRIMARY
                LDA #$FF
                STA PICHERE
:MOD1           LDX #$FF            ;Modified
                JSR SLOADER_FILE
                LDA SSTOREH
                STA :MOD2+2
:MOD2           JMP $FF00           ;Modified


MOTHER_FILES    DB  $60             ; mHallsPicts
                DW  $00C0
                DB  $20

                DB  $70             ; mPictures
                DW  $00D0
                DB  $10

                DB  $90             ; mTesseract
                DW  $00F0
                DB  $06

                DB  $80             ; mInfoSeller
                DW  $00F6
                DB  $06

                DB  $9E             ; mWriter
                DW  charTrack+$0E
                DB  $02

                DB  $80             ; mGroupAssembly_Start
                DW  $0110
                DB  $09

                DB  $80             ; mGroupAssembly_Control
                DW  $0119
                DB  $13

                DB  $80             ; mEnrollTest_Start
                DW  $0130
                DB  $11

                DB  $80             ; mEnrollTest_Control
                DW  $0141
                DB  $05

                DB  $85             ; mEnrollTest_Enroll
                DW  $0146
                DB  $1A

                DB  $85             ; mEnrollTest_Test
                DW  $0160
                DB  $0C

                DB  $80             ; mInfirmary_Start
                DW  $0170
                DB  $08

                DB  $80             ; mInfirmary_Control
                DW  $0178
                DB  $0F

                DB  $80             ; mEnergyCenter_Start
                DW  $0188
                DB  $1C

                DB  $80             ; mEnergyCenter_Control
                DW  $01A4
                DB  $0B

                DB  $80             ; mArsenal_Start
                DW  $01B0
                DB  $10

                DB  $70             ; mArsenal_Control
                DW  $01C0
                DB  $24

                DB  $80             ; mRobotRepair_Start
                DW  $01F0
                DB  $0C

                DB  $60             ; mRobotRepair_Control
                DW  $01FC
                DB  $30

*-------------------------------
