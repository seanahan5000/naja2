
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
        do SMALL_GROUP
                PictRect $01;$01;$115;$44
                PictMoveTo $01;$0B
                PictLineTo $115;$0B
                PictVMoveTo 3
        else
                PictRect $01;$00;$115;$44
                PictMoveTo $01;$0A
                PictLineTo $115;$0A
                PictVMoveTo 2
        fin
                PictEnd
                PLA
DRAW_STATS      ENT
                STA SELECT
                JSR STATS_HEADER
        do SMALL_GROUP
                LDY #11
        else
                LDY #10
        fin
                JSR VMOVE
                JSR FIRST_CHAR
                BCS :2
:1              JSR STATS_LINE
        do SMALL_GROUP
                LDY #9
        else
                LDY #8
        fin
                JSR VMOVE
                JSR NEXT_CHAR
                BCC :1
:2              RTS

STATS_HEADER    JSR DRAW_PICT
        do NAME_FIRST
                PictHMoveTo 16
                PictText "NAME"
                PictHMoveTo 75
                PictText "PROF"
        else
                PictHMoveTo 14
                PictText "PROF"
                PictHMoveTo 58
                PictText "NAME"
        fin
                PictHMoveTo 219
                PictText "ENERGY"
                PictEnd
                LDA SELECT

STATS_HEADER2   STA SELECT
                BIT SELECT
                BMI :XY
                BVC :DAMSTAT
:SHIELD         JSR DRAW_PICT
                PictHMoveTo 105
                PictText "EL"
                PictHMoveTo 121
                PictText "PH"
                PictEnd
                JMP :DAMSTAT

; TODO: get rid of XY completely
:XY             JSR DRAW_PICT
                PictHMoveTo 113
                PictText "XY"
                PictEnd
:DAMSTAT        LDA SELECT
                LSR
                BCS :STATUS
                LSR
                BCS :DAMAGE
                RTS

:DAMAGE         JSR DRAW_PICT
                PictHMoveTo 147
                PictText "HEALTH"
                PictEnd
                RTS

:STATUS         JSR DRAW_PICT
                PictHMoveTo 147
                PictText "STATUS"
                PictEnd
                RTS

        do NAME_FIRST
STATS_LINE      JSR CNAME_TO_TEXT
                LDX #16
                JSR DRAW_TEXTBUF_X
                JSR CPROF_TO_TEXT
                LDA #TextLineEnd
                STA TEXT_BUFFER+3
                LDX #78
        else
STATS_LINE      JSR PROFNAME_TO_TEXT
                LDX #$10
        fin
                JSR DRAW_TEXTBUF_X
                JSR ENERGY_TO_TEXT
                LDX #$C6
                JSR DRAW_TEXTBUF_X
                LDA SELECT

STATS_LINE2     ENT
                STA SELECT
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
                BCS STATUS_WORD
                LSR
                BCS :DAMAGE
                RTS

:DAMAGE         JSR MAJOR_STATUS
                BCC STATUS_WORD_1
                BCS STATUS_WORD_2   ; always

STATUS_WORD     ENT
                JSR MAJOR_STATUS
                BCC STATUS_WORD_2
STATUS_WORD_1   JSR HEALTH_TO_TEXT
                JMP STATUS_WORD_3
STATUS_WORD_2   JSR CSTATUS_TO_TEXT_C
STATUS_WORD_3   LDX #$8A
                JMP DRAW_TEXTBUF_X

DAMAGE_STATUS   ENT                     ; was DAMAGR2
                JSR MAJOR_STATUS
                BCC :1
                JMP CSTATUS_TO_TEXT_C
:1              JMP HEALTH_TO_TEXT

        do NAME_FIRST
        else
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
        fin
;
; copy character name to text buffer,
;   trimmed of trailing spaces
;
; On exit:
;   X: offset of TextLineEnd
;
CNAME_TO_TEXT   ENT
                LDX #0
NTT_CMN         LDY #name
:1              LDA (CHARDL),Y
                STA TEXT_BUFFER,X
                INX
                INY
                CPY #name+10
                BNE :1
:2              LDA TEXT_BUFFER-1,X
                CMP #TextSpace
                BNE :3
                DEX
                BPL :2
:3              LDA #TextLineEnd
                STA TEXT_BUFFER,X
                RTS

DRAW_CNAME      ENT
                JSR CNAME_TO_TEXT
                JMP DRAW_TEXTBUF

WRAP_CNAME      ENT
                JSR CNAME_TO_TEXT
                JMP WRAP_TEXTBUF

CPROF_TO_TEXT   ENT
                LDY #profrace
                LDA (CHARDL),Y
PROF_TO_TEXT    ENT
                LSR
                LSR
                LSR
                LSR
                TAX
                LDY PROF_OFFS,X
                ; TODO: how should caller request full name?
                ; CPX #electromedic
                ; BNE :1
                ; LDY #EMEDIC-PROF_NAMES+4
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

PROF_NAMES
WARRIOR         TXI "WARRIOR"
ANDROID         TXI "ANDROID"
CYBERN          TXI "CYBERNATE"
JUICER          TXI "JUICER"
PHYSIC          TXI "PHYSICIAN"
MUTANT          TXI "MUTANT"
EMEDIC          TXI "EMD/E-MEDIC"
GENIUS          TXI "GENIUS"
ROBOT           TXI "ROBOT"

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
HEALTH_TO_TEXT  ENT
                LDA #TextSpace
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

ENERGY_TO_TEXT_L ENT
                LDX #0
                LDY #energylev
                LDA #3
                JSR CHAR_DIGITS_L
                JMP ETT_CMN
ENERGY_TO_TEXT  ENT
                LDX #0
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
                LDA #4
                LDX #0
                BEQ CMN_TO_TEXT_L   ; always

CSTAT_TO_TEXT_L LDA #1
                LDX #0
                BEQ CMN_TO_TEXT_L   ; always

CSTAT_TO_TEXT_R LDA #1
                LDX #0
CMN_TO_TEXT_R   JSR CHAR_DIGITS_R
                LDA #TextLineEnd
                STA TEXT_BUFFER,X
                RTS

CLEV_TO_TEXT_R  ENT
                LDY #level
                LDA #2
                LDX #0
                BEQ CMN_TO_TEXT_R       ; always

CLEV_TO_TEXT_L  ENT
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

CHAR_DIGITS_L   STA BYTE_COUNT
                LDA #TextEmpty
                BNE CHAR_DIG_CMN        ; always
CHAR_DIGITS_R   STA BYTE_COUNT
                LDA #TextSpace
CHAR_DIG_CMN    STA :MOD1+1
                STX :MOD2+1
                TYA
                CLC
                ADC BYTE_COUNT
                TAY
                LDX BYTE_COUNT
:1              DEY
                LDA (CHARDL),Y
                PHA
                DEX
                BNE :1
:MOD1           LDY #$FF
:MOD2           LDX #$FF
                JSR DIGITS_CMN          ; must JSR, not JMP
                RTS
;
; On entry:
;   A: byte (not digit) count
;   X: TEXT_BUFFER position
;   On stack: bytes to be decoded
;
; On exit:
;   X: updated TEXT_BUFFER position
;
; NOTE: This does NOT append TextLineEnd
;
DIGITS_L        ENT
                LDY #TextEmpty
                HEX 2C
DIGITS_R        ENT
                LDY #TextSpace
                STA BYTE_COUNT
DIGITS_CMN      PLA
                CLC
                ADC #1
                STA :MOD+1
                PLA
                ADC #0
                STA :MOD+2
:1              PLA
                DEC BYTE_COUNT
                BEQ :2
                JSR TWO_DIGITS
                BNE :1                  ; always
:2              PHA
                LSR
                LSR
                LSR
                LSR
                JSR ONE_DIGIT
                PLA
                AND #%00001111
                STA TEXT_BUFFER,X
                INX
:MOD            JMP $FFFF

TWO_DIGITS      PHA
                LSR
                LSR
                LSR
                LSR
                JSR ONE_DIGIT
                PLA
                AND #%00001111
ONE_DIGIT       BEQ :1
                LDY #0
                BEQ :2                  ; always
:1              TYA
:2              STA TEXT_BUFFER,X
                INX
                RTS

CSTATUS_TO_TEXT_L ENT
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

CSTATUS_TO_TEXT_C ENT
                LDY #status
                LDA (CHARDL),Y
                JMP STATUS_TO_TEXT_C

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
HUMAN           TXI "HUMAN"
ORN             TXI "ORN"
STILICX         TXI "STILICX"
XXTYS           TXI "XXTYS"
DENEB           TXI "DENEB"
NONE            TXI "NONE"
