
_STATUS_TO_TEXT_C
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
