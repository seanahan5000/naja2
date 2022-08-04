
; TODO: decide what to do with SELECT
* another comment

SBOXER          LDA #$42            ;*** temporary
;
; On entry:
;   A: stats box enables
;       %10000000: show XY
;       %01000000: show shielding
;       %00000010: show damage
;       %00000001: show status
;
DRAW_STATS_BOX  PHA
                JSR DRAW_PICT
                PictSetGreen
                PictRect $01;$00;$115;$44
                PictMoveTo $01;$0A
                PictLineTo $115;$0A
                PictVMoveTo 2
                PictEnd
                PLA
STATS_LINES     STA SELECT
                JSR STATS_HEADER
                JSR DRAW_PICT
                PictVMove 10
                PictEnd
                JSR FIRST_CHAR
:1              JSR STATS_LINE
                JSR DRAW_PICT
                PictVMove 8
                PictEnd
                JSR NEXT_CHAR
                BCC :1
                RTS

STATS_HEADER    JSR DRAW_PICT
                PictHMoveTo 14
                PictText (PROF)
                PictHMoveTo 58
                PictText (NAME)
                PictHMoveTo 219
                PictText (ENERGY)
                PictEnd
STATS_HEADER2   BIT SELECT          ; only used when flipping stats
                BMI :XY
                BVC :DAMSTAT
                JSR DRAW_PICT
                PictHMoveTo 105
                PictText (EL)
                PictHMoveTo 121
                PictText (PH)
                PictEnd
                JMP :DAMSTAT

:XY             JSR DRAW_PICT
                PictHMoveTo 113
                PictText (XY)
                PictEnd
:DAMSTAT        LDA SELECT
                LSR
                BCS :STATUS
                LSR
                BCS :DAMAGE
                RTS

:DAMAGE         JSR DRAW_PICT
                PictHMoveTo 147
                PictText (DAMAGE)
                PictEnd
                RTS

:STATUS         JSR DRAW_PICT
                PictHMoveTo 147
                PictText (STATUS)
                PictEnd
                RTS

STATS_LINE      JSR PROFNAME_TO_TEXT
                LDX #$10
                JSR DRAW_TEXTBUF

                JSR ENERGY_TO_TEXT
                LDX #$C6
                JSR DRAW_TEXTBUF

STATS_LINE2     BIT SELECT          ; only used when flipping stats
                BMI :XY
                BVC :DAMSTAT

                LDY #Eshielding
                JSR SHIELD_TO_TEXT
                LDX #$69
                JSR DRAW_TEXTBUF

                LDY #Pshielding
                JSR SHIELD_TO_TEXT
                LDX #$79
                JSR DRAW_TEXTBUF

                JMP :DAMSTAT

:XY             JSR XY_TO_TEXT
                LDX #$71
                JSR DRAW_TEXTBUF

:DAMSTAT        LDA SELECT
                LSR
                BCS :STATUS
                LSR
                BCS :DAMAGE
                RTS

:DAMAGE         JSR MAJOR_STATUS
                BCC :1
                BCS :2              ; always

:STATUS         JSR MAJOR_STATUS
                BCC :2
:1              JSR DAMAGE_TO_TEXT
                JMP :3
:2              JSR STATUS_TO_TEXT
:3              LDX #$8A
                JMP DRAW_TEXTBUF

PROFNAME_TO_TEXT LDY #profrace
                LDA (CHARDL),Y
                LSR
                LSR
                LSR
                LSR
                TAX
                LDY PROF_OFFS,X
                LDX #0
:1              LDA PROF_NAMES,Y
                STA TEXT_BUFFER,X
                INY
                INX
                CPX #3
                BNE :1
                LDA #CharSpace
                STA TEXT_BUFFER,X
                INX
                LDY #name
:2              LDA (CHARDL),Y
                STA TEXT_BUFFER,X
                INX
                INY
                CPY #name+10
                BNE :2
                LDA #CharLineEnd
                STA TEXT_BUFFER,X
                RTS

PROF_OFFS       DB  WARRIOR-PROF_NAMES
                DB  ANDROID-PROF_NAMES
                DB  CYBERN-PROF_NAMES
                DB  JUICER-PROF_NAMES
                DB  PHYSIC-PROF_NAMES
                DB  MUTANT-PROF_NAMES
                DB  EMEDIC-PROF_NAMES
                DB  GENIUS-PROF_NAMES
                DB  ROBOT-PROF_NAMES

PROF_NAMES
WARRIOR         USR (WARRIOR)=
ANDROID         USR (ANDROID)=
CYBERN          USR (CYBERNATE)=
JUICER          USR (JUICER)=
PHYSIC          USR (PHYSICIAN)=
MUTANT          USR (MUTANT)=
EMEDIC          USR (EMD/E-MEDIC)=
GENIUS          USR (GENIUS)=
ROBOT           USR (ROBOT)=
NONE            USR (NONE)=

XY_TO_TEXT      LDY #position
                LDA (CHARDL),Y
                PHA
                LSR
                LSR
                LSR
                LSR
                STA TEXT_BUFFER+0
                PLA
                AND #$0F
                CLC
                ADC #CharA
                STA TEXT_BUFFER+1
                LDA #CharLineEnd
                STA TEXT_BUFFER+2
                RTS

SHIELD_TO_TEXT  LDX #0
                LDA #1
                JSR CHAR_DIGITS_R
                LDA #CharLineEnd
                STA TEXT_BUFFER,X
                RTS

DAMAGE_TO_TEXT  LDX #0
                LDY #damagelev
                LDA #2
                JSR CHAR_DIGITS_R
                LDA #CharSlash
                STA TEXT_BUFFER,X
                INX
                LDY #damagemax
                LDA #2
                JSR CHAR_DIGITS_L
                LDA #CharLineEnd
                STA TEXT_BUFFER,X
                RTS

ENERGY_TO_TEXT  LDX #0
                LDY #energylev
                LDA #3
                JSR CHAR_DIGITS_R
                LDA #CharSlash
                STA TEXT_BUFFER,X
                INX
                LDY #energymax
                LDA #3
                JSR CHAR_DIGITS_L
                LDA #CharLineEnd
                STA TEXT_BUFFER,X
                RTS
;
; On entry:
;   Y: character field
;   A: byte (not digit) count
;   X: TEXT_BUFFER position
;
; On exit:
;   X: updated TEXT_BUFFER position
;
BYTE_COUNT      =   LOCAL_TEMP+0
START_INDEX     =   LOCAL_TEMP+1
END_INDEX       =   LOCAL_TEMP+2

CHAR_DIGITS_L   STA BYTE_COUNT
                LDA #CharEmpty
                BNE CHAR_DIG_CMN    ; always
CHAR_DIGITS_R   STA BYTE_COUNT
                LDA #CharSpace
CHAR_DIG_CMN    STA :FILL_MOD+1
                STX START_INDEX
:1              LDA (CHARDL),Y
                INY
                PHA
                LSR
                LSR
                LSR
                LSR
                STA TEXT_BUFFER,X
                INX
                PLA
                AND #$0F
                STA TEXT_BUFFER,X
                INX
                DEC BYTE_COUNT
                BNE :1
                DEX
                STX END_INDEX
                LDX START_INDEX
:2              LDA TEXT_BUFFER,X
                BNE :3
:FILL_MOD       LDA #$FF
                STA TEXT_BUFFER,X
                INX
                CPX END_INDEX
                BNE :2
:3              LDX END_INDEX
                INX
                RTS

STATUS_TO_TEXT  LDY #status
                LDA (CHARDL),Y
                TAX
                AND #critical
                BNE :1
                TXA
                CMP #rundown
                BEQ :1
                AND #%00111100
                CMP #illA
                BEQ :1
                TXA
                AND #%00111111
:1
                LDX #0
:2              CMP STATUS_NUMS,X
                BEQ :FOUND_STATUS
                INX
                BNE :2              ; always

:FOUND_STATUS   LDY #0
:3              DEX
                BMI :FOUND_NAME
:4              INY
                LDA STATUS_NAMES-1,Y
                BPL :4
                BMI :3              ; always

:FOUND_NAME     LDX #0
:5              LDA STATUS_NAMES,Y
                BMI :6
                STA TEXT_BUFFER,X
                INX
                INY
                BNE :5              ; always
:6              AND #$7F
                STA TEXT_BUFFER,X
                INX
                LDA #CharLineEnd
                STA TEXT_BUFFER,X
                RTS

MAJOR_STATUS    JSR BAD_STATUS
                BCS :1
                LDA (CHARDL),Y
                AND #critical
                BEQ :1
                SEC
:1              RTS

BAD_STATUS      LDY #status         ;Exit carry set and BEQ true
                LDA (CHARDL),Y      ;   if it's a major stat
                AND #%00111111      ;   A - holds status
                BEQ :1              ;   X - is unchanged
                CMP #lost+1
                BCS :1
                CPY #status         ;Set carry and make BEQ true
                RTS
:1              CLC
                LDY #status         ;Make BEQ false
                RTS

STATUS_NUMS     DB  healthy,dead
                DB  abandoned,broken
                DB  intracc,compressd
                DB  inlimbo,lost
                DB  corroding,poisoned
                DB  bleeding,radiated
                DB  illA,blind
                DB  confused,smotherin
                DB  fast,strong
                DB  slipping,numb
                DB  ranaway,onfire
                DB  dizzy,stunned
                DB  immobile,controlld
                DB  choking,critical
                DB  rundown

STATUS_NAMES    USR (HEALTHY)=
                USR (DEAD)=
                USR (ABANDONED)=
                USR (BROKEN)=
                USR (IN-TRACC)=
                USR (COMPRESSD)=
                USR (IN-LIMBO)=
                USR (LOST)=
                USR (CORRODING)=
                USR (POISONED)=
                USR (BLEEDING)=
                USR (RADIATED)=
                USR (ILL)=
                USR (BLIND)=
                USR (CONFUSED)=
                USR (SMOTHERIN)=
                USR (FAST)=
                USR (STRONG)=
                USR (SLIPPING)=
                USR (NUMB)=
                USR (RAN_AWAY)=
                USR (ON_FIRE)=
                USR (DIZZY)=
                USR (STUNNED)=
                USR (IMMOBILE)=
                USR (CONTROLLD)=
                USR (CHOKING)=
                USR (CRITICAL)=
                USR (RUN_DOWN)=

RACE_OFFS       DB  HUMAN-RACE_NAMES
                DB  ORN-RACE_NAMES
                DB  STILICX-RACE_NAMES
                DB  XXTYS-RACE_NAMES
                DB  DENEB-RACE_NAMES

RACE_NAMES
HUMAN           USR (HUMAN)=
ORN             USR (ORN)=
STILICX         USR (STILICX)=
XXTYS           USR (XXTYS)=
DENEB           USR (DENEB)=


        DO 0

SFLIP           JSR DRAW_CURSOR
                LDA #$7C
                STA MODHEAD+1
                JSR EXCHNGE
                JSR EXFLIP
                JSR EXCHNGE
                LDA #$02
                STA MODHEAD+1
                JSR GETKEY2
                JMP DESTINATION

BYPOINT         DFB $86,$8E,$96
                DFB $9E,$A6,$AE
                DFB $B6

EXCHNGE         LDY #$06
EX2             LDA YPOINTS,Y
                LDX BYPOINT,Y
                STA BYPOINT,Y
                TXA
                STA YPOINTS,Y
                DEY
                BPL EX2
                RTS

EXFLIP          LDA #$00
                STA COUNT
MODHEAD         LDA #$02
                STA YPNT

                LDA SHELL           ; 0 == MOTHERSHIP
                BNE :SKIPA

                JSR DORS
                LDA SELECT
                PHA
                EOR #$03
                STA SELECT
                JSR DORS
                JMP :SKIPB

:SKIPA          JSR HEADER2
                LDA SELECT
                PHA
                EOR #$C3
                STA SELECT
                JSR HEADER2

:SKIPB          PLA
                STA SELECT

MORFLOP         LDA COUNT
                JSR POINTIT
                LDY COUNT
                LDA YPOINTS,Y
                STA YPNT

                LDA SHELL           ; 0 == MOTHERSHIP
                BNE :SKIPA

                JSR PICDS
                LDA SELECT
                PHA
                EOR #$03
                STA SELECT
                JSR PICDS
                JMP :SKIPB

:SKIPA          JSR STATL2
                LDA SELECT
                PHA
                EOR #$C3
                STA SELECT
                JSR STATL2

:SKIPB          PLA
                STA SELECT
                INC COUNT
                LDA COUNT
                CMP GRPNUMB
                BNE MORFLOP
                LDA SELECT
                EOR #$C3
                STA SELECT
                RTS
            FIN
