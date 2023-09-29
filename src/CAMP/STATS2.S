
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

STATUS_NAMES    TXI " HEALTHY"
                TXI "  DEAD"
                TXI "ABANDONED"
                TXI " BROKEN"
                TXI "IN-TRACC"
                TXI "COMPRESSD"
                TXI "IN-LIMBO"
                TXI "  LOST"
                TXI "CORRODING"
                TXI "POISONED"
                TXI "BLEEDING"
                TXI "RADIATED"
                TXI "   ILL"
                TXI "  BLIND"
                TXI "CONFUSED"
                TXI "SMOTHERIN"
                TXI "  FAST"
                TXI " STRONG"
                TXI "SLIPPING"
                TXI "  NUMB"
                TXI "RAN AWAY"
                TXI " ON FIRE"
                TXI "  DIZZY"
                TXI " STUNNED"
                TXI "IMMOBILE"
                TXI "CONTROLLD"
                TXI " CHOKING"
                TXI "CRITICAL"
                TXI "RUN DOWN"
