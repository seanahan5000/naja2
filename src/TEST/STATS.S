
; TODO: decide what to do with SELECT

;
; On entry:
;   A: stats box enables
;       %10000000: show XY
;       %01000000: show shielding
;       %00000010: show damage
;       %00000001: show status
;
DRAW_STATS_BOX  ;ENT
                LDA #$42
                BNE DSB_CMN
DRAW_STATS_BOX_XY ;ENT
                LDA #$82
DSB_CMN         PHA
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
                JSR SHIELD_TO_TEXT
                LDX #$69
                JSR DRAW_TEXTBUF_X
                LDY #Pshielding
                JSR SHIELD_TO_TEXT
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
:1              JSR DAMAGE_TO_TEXT
                JMP :3
:2              JSR STATUS_TO_TEXT
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
                LDA #CharSpace
                STA TEXT_BUFFER,X
                INX
                BNE NTT_CMN         ; always

CNAME_TO_TEXT   LDX #0
NTT_CMN         LDY #name
:2              LDA (CHARDL),Y
                STA TEXT_BUFFER,X
                INX
                INY
                CPY #name+10
                BNE :2
                LDA #CharLineEnd
                STA TEXT_BUFFER,X
                RTS

; NOTE: currently only used by C.ISTATS.S, so maybe move
CPROF_TO_TEXT   LDY #profrace
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
                BNE CMN_TO_TEXT_L2  ; always

ENERGY_TO_TEXT  LDX #0
                LDY #energylev
                LDA #3
                JSR CHAR_DIGITS_R
                LDA #CharSlash
                STA TEXT_BUFFER,X
                INX
                LDY #energymax
                LDA #3
                BNE CMN_TO_TEXT_L   ; always

; NOTE: currently only used by C.ISTATS.S, so maybe move
CEXP_TO_TEXT    LDY #experience
                LDX #0
                LDA #4
                BNE CMN_TO_TEXT_L   ; always

; NOTE: currently only used by C.ISTATS.S, so maybe move
CLEVEL_TO_TEXT  LDY #level
                LDX #0
CMN_TO_TEXT_L2  LDA #2
CMN_TO_TEXT_L   JSR CHAR_DIGITS_L
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

; NOTE: currently only used by C.ISTATS.S, so maybe move
CRACE_TO_TEXT   LDY #profrace
                LDA (CHARDL),Y
                AND #$0F
                LDX #<RACE_NAMES
                LDY #>RACE_NAMES
                JMP GET_IND_STRING

RACE_NAMES
HUMAN           USR (HUMAN)=
ORN             USR (ORN)=
STILICX         USR (STILICX)=
XXTYS           USR (XXTYS)=
DENEB           USR (DENEB)=


; On entry:
;   X: string list (low)
;   Y: string list (high)
;   A: string index
;
; On exit:
;   TEXT_BUFFER: holding indexed string
;   X: index of CharLineEnd
;
PTR             =   LOCAL_TEMP+0
PTR_H           =   LOCAL_TEMP+1

GET_IND_STRING  ENT
                STX PTR
                STY PTR_H
                TAX
                LDY #-1
                BMI :2              ; always
:1              INY
                LDA (PTR),Y
                BPL :1
:2              DEX
                BPL :1
                INY
                LDX #0
:3              LDA (PTR),Y
                BMI :4
                STA TEXT_BUFFER,X
                INX
                INY
                BNE :3              ; always
:4              AND #$7F
                STA TEXT_BUFFER,X
                INX
                LDA #CharLineEnd
                STA TEXT_BUFFER,X
                RTS
