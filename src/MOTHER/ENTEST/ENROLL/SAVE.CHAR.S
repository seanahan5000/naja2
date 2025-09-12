BUILD_CHAR      JSR ALLOC_CHAR

                LDA #0              ;Clear character buffer
                LDY #$7F
:LOOP1          STA (CHARDL),Y
                DEY
                BPL :LOOP1

                LDY #name
:LOOP2          LDA NAME_BUFFER,Y
                STA (CHARDL),Y      ;NAME
                INY
                CPY #name+10
                BNE :LOOP2

                LDA #healthy
                STA (CHARDL),Y      ;STATUS
                INY

                LDA #$00
                STA (CHARDL),Y      ;LEVEL
                INY
                LDA #$01
                STA (CHARDL),Y      ;LEVEL+1
                INY

                LDA PROFRAC
                STA (CHARDL),Y      ;PROFESSION / RACE
*INY

                                    ;EXPERIENCE
                                    ;UNUSED BYTE

                LDY #credits+2
                LDA MISC
                STA (CHARDL),Y      ;CREDITS+2
                INY
                LDA MISC+1
                STA (CHARDL),Y      ;CREDITS+3
*INY

                                    ;STRENGTH
                                    ;UPPER REFLEX
                                    ;LOWER REFLEX
                                    ;INTELLIGENCE
                                    ;EL SHIELDING
                                    ;PH SHIELDING

                LDY #back
                LDA #$03
                LDX RACE
                CPX #orn
                BNE :SKIPA
                LDA #$04
:SKIPA          STA (CHARDL),Y      ;SPACE ON BACK
*INY

                                    ;POSITION

                LDA PROFRAC
                LSR
                LSR
                LSR
                LSR
                TAX
                LDA DROFF,X
                TAY
                LDA PRSNST+6
                SED
                SEC
                SBC INOMIN,X
                CLD
                JSR DIV_BY_5
                TXA
                ASL
                STA SCRATCH
                TYA
                CLC
                ADC SCRATCH
                TAY
                LDA DAMRANG,Y
                STA SCRATCH            ;Was MINIMUM
                INY
                LDA DAMRANG,Y
                STA SCRATCH+1          ;Was MAXIMUM
                INC SCRATCH+1          ;Was MAXIMUM
:LOOP3          JSR RANDOM
                CMP SCRATCH+1          ;Was MAXIMUM
                BCS :LOOP3
                CMP SCRATCH            ;Was MINIMUM
                BCC :LOOP3
                TAX
                AND #$0F
                CMP #$0A
                BCS :LOOP3
                TXA
                AND #$F0
                CMP #$A0
                BCS :LOOP3
                LDY #damagemax+1
                TXA
                STA (CHARDL),Y      ;DAMAGEMAX+1
                INY

                LDA PRSNST+5
                STA (CHARDL),Y      ;COMPOSITION
*INY

                LDY #energylev+1
                LDA #$10
                STA (CHARDL),Y      ;ENERGY LEVEL+1

                LDA PRSNST+6
                TAX
                ASL
                ASL
                ASL
                ASL
                LDY #energymax+2
                STA (CHARDL),Y      ;ENERGY MAX+2
                TXA
                LSR
                LSR
                LSR
                LSR
                DEY
                SED
                CLC
                ADC #$32
                CLD
                STA (CHARDL),Y      ;ENERGY MAX+1

                LDA PROFRAC
                AND #%11110000
                CMP #juicer*16
                BNE :SKIPB
                SED
                LDY #energymax+2
                LDA (CHARDL),Y
                CLC
                ADC (CHARDL),Y
                STA (CHARDL),Y      ;ENERGY MAX+2 (IF JUICER)
                DEY
                LDA (CHARDL),Y
                ADC (CHARDL),Y
                STA (CHARDL),Y      ;ENERGY MAX+1 (IF JUICER)
                CLD

                LDY #energylev+1
                LDA #$20
                STA (CHARDL),Y      ;ENERGY LEVEL+1 (IF JUICER)
:SKIPB

                                    ;POWER CONSUMPTION,+1
                                    ;UNUSED BYTE

                                        ; rosterLocation (already fill in)

;               LDY #roboCyberLink
;               LDA #$00
;               STA (CHARDL),Y          ;SECTOR/SEGMENT FOR ROBOT/CYBERN

                                    ;POWER LEVEL FRACTION,+1

                LDY #basepowercons
                LDA MISC2
                STA (CHARDL),Y      ;BASE POWER CONSUMPTION
                INY
                LDA MISC2+1
                STA (CHARDL),Y      ;BASE POWER CONSUMPTION+1
                INY

                LDA PROFRAC
                AND #%00001111
                TAX
                LDA ESHIELD,X
                STA (CHARDL),Y      ;BASE EL SHIELDING
                INY
                LDA PSHIELD,X
                STA (CHARDL),Y      ;BASE PH SHIELDING
                INY

                LDA #$FF
:LOOP4          STA (CHARDL),Y      ;ALL EQUIPMENT SLOTS
                INY
                CPY #e16_UNUSED+4
                BNE :LOOP4

                                    ;INFLICT COUNT
                                    ;INFLICT DELAY
                                    ;INFLICT AMOUNT
                                    ;INFLICT NUMS

                LDY #basestrength
                LDA PRSNST+1
                STA (CHARDL),Y      ;BASE STRENGTH
                INY

                LDA PRSNST+3
                STA (CHARDL),Y      ;BASE UPPER REFLEX
                INY

                LDA PRSNST+2
                STA (CHARDL),Y      ;BASE LOWER REFLEX
                INY

                LDA PRSNST
                STA (CHARDL),Y      ;BASE INTELLIGENCE

                                    ;UNUSED BYTE

                LDY #flaglimbo
                LDA #inlimbo
                STA (CHARDL),Y      ;FLAG LIMBO
                INY

                LDA #0
                STA (CHARDL),Y      ;MISC FLAGS

                JSR CALC_ALL
                JMP SAVE_CHAR

*-------------------------------
* Used to determine damagemax

DROFF           DB  $00,$10,$1A
                DB  $26,$32
INOMIN          DB  $20,$60,$30
                DB  $45,$15
DAMRANG         DB  $55,$61,$58
                DB  $64,$61,$67
                DB  $64,$67,$64
                DB  $67,$64,$70
                DB  $67,$73,$70
                DB  $76
                DB  $33,$39,$36
                DB  $42,$36,$42
                DB  $36,$42,$39
                DB  $45
                DB  $29,$33,$31
                DB  $36,$33,$38
                DB  $31,$36,$33
                DB  $38,$36,$40
                DB  $40,$46,$43
                DB  $49,$49,$52
                DB  $43,$49,$46
                DB  $52,$49,$55
                DB  $31,$35,$33
                DB  $38,$35,$40
                DB  $33,$38,$35
                DB  $40,$38,$42

DIV_BY_5        LDX #0
                CMP #$00
                BEQ :EXIT
                SEC
:LOOP1          INX
                SED
                SBC #$05
                CLD
                BNE :LOOP1
:EXIT           RTS

*-------------------------------

ESHIELD         DB  $00,$00,$03
                DB  $00,$00
PSHIELD         DB  $00,$01,$00
                DB  $00,$02
