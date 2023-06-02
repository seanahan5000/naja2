*-------------------------------
*
*-------------------------------

WHIZ_SUB        TXA
                PHA
:LOOP1          JSR RANDOM
                AND #$03
                STA :MOD+1
                LDX ATALLY
                BNE :SKIPA
                CMP #$01
                BCC :LOOP1
:SKIPA          CLC
                ADC #xMisses
                TAY
                PLA
                TAX
                JSR WORD1_INC
:MOD            LDA #$FF
                BEQ :EXIT
                LDY #xPast
                JSR WORD1_INC
:EXIT           RTS


*-------------------------------
*
*-------------------------------

ATTAREM         LDY #xRemains
                LDA ATALLY
                BEQ REMAIN
                LDY #xAttacker
REMAIN          JSR WORD1
                LDA ATALLY
                CMP #$02
                BCC :EXIT
                LDA #$1D
                STA TEXTBUF,X
                INX
:EXIT           RTS


*-------------------------------
*
*-------------------------------

FIND_CHAR       LDA SQUARE_HIT
                AND #$0F
                STA TEMP
                LDA #$05
                SEC
                SBC TEMP
                TAY
                LDA TIMES5,Y
                STA TEMP
                LDA SQUARE_HIT
                LSR
                LSR
                LSR
                LSR
                CLC
                ADC TEMP
                TAY
                DEY
                LDA MASTER_CGRID,Y
                RTS

;-------------------------------
;
; On exit:
;     Carry set: Monster in that square, SET_MONSTER called
;   Carry clear: Monster NOT in that square
;
;-------------------------------

FIND_MONSTER    LDA SQUARE_HIT
                JSR MON_INDEXER
                LDA MASTER_MGRID,Y
                CMP #$FF
                CLC
                BEQ :1
                JSR SET_MONSTER
                SEC
:1              RTS

*-------------------------------
*
*-------------------------------

KILL_DESTROY    STX TEMP
                LDY #monNUMBER
                LDA (MONS_PTR),Y
                TAX
                LDY #xDestroyed
                LDA ALTYPE1,X
                BMI :SKIPA
                JSR RANDOM
                AND #$01
                CLC
                ADC #xKilled
                TAY
:SKIPA          LDX TEMP
                JMP WORD1

*-------------------------------
* FIRES A BLAST
* FIRES A SHOT
* BLASTS A SHOT
*-------------------------------

BLAST_A_SHOT    PHA
                JSR CLEAR_TLINE1
                PLA
                TAY
                JSR RANDOM
                PHA
                AND #$02
                CLC
                ADC #xFire
                JSR WORD2
                LDA #TextS
                STA TEXTBUF,X
                INX
                INX
                LDY #xShot
                PLA
                LSR
                BCS :SKIPA
                LSR
                BCS :SKIPA
                DEY
:SKIPA          TYA
                LDY #xA
                JMP WORD2

*-------------------------------
