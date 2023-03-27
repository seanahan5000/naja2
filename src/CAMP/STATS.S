
; TODO: decide what to do with SELECT

;
; On entry:
;   A: stats box enables
;       %10000000: show XY          TODO: get rid of
;       %01000000: show shielding
;       %00000010: show damage
;       %00000001: show status
;
DRAW_STATS_BOX  ENT
                LDA #statsShielding+statsDamage
DRAW_STATS_BOX_A ENT
                PHA
                JSR DRAW_PICT
                PictSetGreen
                PictRect $01;$00;$115;$44
                PictMoveTo $01;$0A
                PictLineTo $115;$0A
                PictVMoveTo 2
                PictEnd
                PLA
                STA SELECT
                JSR STATS_HEADER
                LDY #10
                JSR VMOVE
                JSR FIRST_CHAR
:1              JSR STATS_LINE
                LDY #8
                JSR VMOVE
                JSR NEXT_CHAR
                BCC :1
                RTS

; TODO: swap PROF and NAME
STATS_HEADER    JSR DRAW_PICT
                PictHMoveTo 14
                PictText (PROF)
                PictHMoveTo 58
                PictText (NAME)
                PictHMoveTo 219
                PictText (ENERGY)
                PictEnd
                LDA SELECT

STATS_HEADER2   STA SELECT
                BIT SELECT
                BMI :XY
                BVC :DAMSTAT
:SHIELD         JSR DRAW_PICT
                PictHMoveTo 105
                PictText (EL)
                PictHMoveTo 121
                PictText (PH)
                PictEnd
                JMP :DAMSTAT

; TODO: get rid of XY completely
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
                PictText (HEALTH)
                PictEnd
                RTS

:STATUS         JSR DRAW_PICT
                PictHMoveTo 147
                PictText (STATUS)
                PictEnd
                RTS

STATS_LINE      JSR PROFNAME_TO_TEXT
                LDX #$10
                JSR DRAW_TEXTBUF_X
                JSR ENERGY_TO_TEXT
                LDX #$C6
                JSR DRAW_TEXTBUF_X
                LDA SELECT

STATS_LINE2     STA SELECT
                BIT SELECT
                BMI :XY
                BVC :DAMSTAT

:SHIELD         LDY #Eshielding
                JSR CSTAT_TO_TEXT_R
                LDX #$69
                JSR DRAW_TEXTBUF_X
                LDY #Pshielding
                JSR CSTAT_TO_TEXT_R
                LDX #$79
                JSR DRAW_TEXTBUF_X
                JMP :DAMSTAT

:XY             JSR CPOS_TO_TEXT
                LDX #$71
                JSR DRAW_TEXTBUF_X
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
:1              JSR HEALTH_TO_TEXT
                JMP :3
:2              JSR CSTATUS_TO_TEXT_C
:3              LDX #$8A
                JMP DRAW_TEXTBUF_X

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
                LDA #TextSpace
                STA TEXT_BUFFER,X
                INX
                BNE NTT_CMN         ; always

CNAME_TO_TEXT   ENT
                LDX #0
NTT_CMN         LDY #name
:2              LDA (CHARDL),Y
                STA TEXT_BUFFER,X
                INX
                INY
                CPY #name+10
                BNE :2
                LDA #TextLineEnd
                STA TEXT_BUFFER,X
                RTS


TRIM_NAME       ENT
                JSR CNAME_TO_TEXT
:1              LDA TEXT_BUFFER-1,X
                CMP #TextSpace
                BNE :2
                DEX
                BPL :1
:2              LDA #TextLineEnd
                STA TEXT_BUFFER,X
                RTS

DRAW_TRIMMED_NAME ENT
                JSR TRIM_NAME
                JMP DRAW_TEXTBUF

WRAP_TRIMMED_NAME ENT
                JSR TRIM_NAME
                JMP WRAP_TEXTBUF

; NOTE: currently only used by C.ISTATS/DEAD.GROUP, so maybe move
CPROF_TO_TEXT   ENT
                LDY #profrace
                LDA (CHARDL),Y
                LSR
                LSR
                LSR
                LSR
                TAX
                LDY PROF_OFFS,X
                CPX #electromedic
                BNE :1
                LDY #EMEDIC-PROF_NAMES+4
:1              LDX #0
:2              LDA PROF_NAMES,Y
                BMI :3
                STA TEXT_BUFFER,X
                INY
                INX
                BNE :2
:3              AND #$7F
                STA TEXT_BUFFER,X
                INX
                LDA #TextLineEnd
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

; TODO: Consider moving profession and race strings back into $200,
;   assuming text insertion is removed.
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

CPOS_TO_TEXT    LDY #position
                LDA (CHARDL),Y
POS_TO_TEXT     PHA
                LSR
                LSR
                LSR
                LSR
                STA TEXT_BUFFER+0
                PLA
                AND #$0F
                CLC
                ADC #TextA
                STA TEXT_BUFFER+1
                LDA #TextLineEnd
                STA TEXT_BUFFER+2
                RTS

; TODO: could be greatly simplified when damage reversed to health
HEALTH_TO_TEXT_L
                LDA #TextEmpty
                BNE HTT_CMN             ; always
HEALTH_TO_TEXT  LDA #TextSpace
HTT_CMN         STA :FILL_MOD+1
                LDX #0
                SED
                SEC
                LDY #damagemax+1
                LDA (CHARDL),Y
                LDY #damagelev+1
                SBC (CHARDL),Y
                PHA
                PHA
                LDY #damagemax
                LDA (CHARDL),Y
                LDY #damagelev
                SBC (CHARDL),Y
                CLD
:1              PHA
                LSR
                LSR
                LSR
                LSR
                STA TEXT_BUFFER,X
                INX
                PLA
                AND #$0F
                STA TEXT_BUFFER,X
                PLA
                INX
                CPX #4
                BNE :1
                LDX #0
:2              LDA TEXT_BUFFER,X
                BNE :3
:FILL_MOD       LDA #$FF
                STA TEXT_BUFFER,X
                INX
                CPX #3
                BNE :2
:3              LDX #4
                LDA #TextSlash
                STA TEXT_BUFFER,X
                INX
                LDY #damagemax
                BNE CMN_TO_TEXT_L2  ; always

; HEALTH_TO_TEXT_L LDX #0
;                 LDY #healthlev
;                 LDA #2
;                 JSR CHAR_DIGITS_L
;                 JMP DTT_CMN
; HEALTH_TO_TEXT  LDX #0
;                 LDY #healthlev
;                 LDA #2
;                 JSR CHAR_DIGITS_R
; DTT_CMN         LDA #TextSlash
;                 STA TEXT_BUFFER,X
;                 INX
;                 LDY #healthmax
;                 BNE CMN_TO_TEXT_L2  ; always

ENERGY_TO_TEXT_L LDX #0
                LDY #energylev
                LDA #3
                JSR CHAR_DIGITS_L
                JMP ETT_CMN
ENERGY_TO_TEXT  LDX #0
                LDY #energylev
                LDA #3
                JSR CHAR_DIGITS_R
ETT_CMN         LDA #TextSlash
                STA TEXT_BUFFER,X
                INX
                LDY #energymax
                LDA #3
                BNE CMN_TO_TEXT_L   ; always

; NOTE: currently only used by C.ISTATS/DEAD.GROUP, so maybe move
CEXP_TO_TEXT    ENT
                LDY #experience
                LDX #0
                LDA #4
                BNE CMN_TO_TEXT_L   ; always

CSTAT_TO_TEXT_L LDX #0
                LDA #1
                BNE CMN_TO_TEXT_L   ; always

CSTAT_TO_TEXT_R LDX #0
                LDA #1
                JSR CHAR_DIGITS_R
                LDA #TextLineEnd
                STA TEXT_BUFFER,X
                RTS

; NOTE: currently only used by C.ISTATS/DEAD.GROUP, so maybe move
CLEVEL_TO_TEXT  ENT
                LDY #level
                LDX #0
CMN_TO_TEXT_L2  LDA #2
CMN_TO_TEXT_L   JSR CHAR_DIGITS_L
                LDA #TextLineEnd
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
                LDA #TextEmpty
                BNE CHAR_DIG_CMN    ; always
CHAR_DIGITS_R   STA BYTE_COUNT
                LDA #TextSpace
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

CSTATUS_TO_TEXT_L
                JSR CSTATUS_TO_TEXT_C
                JMP FORCE_LEFT

STATUS_TO_TEXT_L
                JSR STATUS_TO_TEXT_C
FORCE_LEFT      LDX #0
:1              LDA TEXT_BUFFER,X
                CMP #TextSpace
                BNE :2
                LDA #TextEmpty
                STA TEXT_BUFFER,X
                INX
                BNE :1                  ; always
:2              RTS

CSTATUS_TO_TEXT_C
                LDY #status
                LDA (CHARDL),Y
STATUS_TO_TEXT_C
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
                BNE :2                  ; always

:FOUND_STATUS   TXA
                LDX #<STATUS_NAMES
                LDY #>STATUS_NAMES
                JMP GET_IND_STRING

MAJOR_STATUS    JSR BAD_STATUS
                BCS :1
                LDA (CHARDL),Y
                AND #critical
                BEQ :1
                SEC
:1              RTS

BAD_STATUS      ENT
                LDY #status         ;Exit carry set and BEQ true
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

STATUS_NAMES    USR (_HEALTHY)=
                USR (__DEAD)=
                USR (ABANDONED)=
                USR (_BROKEN)=
                USR (IN-TRACC)=
                USR (COMPRESSD)=
                USR (IN-LIMBO)=
                USR (__LOST)=
                USR (CORRODING)=
                USR (POISONED)=
                USR (BLEEDING)=
                USR (RADIATED)=
                USR (___ILL)=
                USR (__BLIND)=
                USR (CONFUSED)=
                USR (SMOTHERIN)=
                USR (__FAST)=
                USR (_STRONG)=
                USR (SLIPPING)=
                USR (__NUMB)=
                USR (RAN_AWAY)=
                USR (_ON_FIRE)=
                USR (__DIZZY)=
                USR (_STUNNED)=
                USR (IMMOBILE)=
                USR (CONTROLLD)=
                USR (_CHOKING)=
                USR (CRITICAL)=
                USR (RUN_DOWN)=

CRACE_TO_TEXT   ENT
                LDY #profrace
                LDA (CHARDL),Y
                BPL :1
                LDA #$05                ; no race for robots
:1              AND #$0F
RACE_TO_TEXT    ENT
                LDX #<RACE_NAMES
                LDY #>RACE_NAMES
                JMP GET_IND_STRING

RACE_NAMES
HUMAN           USR (HUMAN)=
ORN             USR (ORN)=
STILICX         USR (STILICX)=
XXTYS           USR (XXTYS)=
DENEB           USR (DENEB)=
NONE            USR (NONE)=
