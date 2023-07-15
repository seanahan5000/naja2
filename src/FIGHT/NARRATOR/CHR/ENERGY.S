CHR_ENERGY

*------------------------------*
*  Prepare for energy attack   *
*------------------------------*

                LDA #0
                LDX #24
:1              STA ENHIT,X         ;Clear hit zone buffer
                DEX
                BPL :1

                ; TODO: eventually center area on aim position

                LDX COMPNTR
                LDA COMMAND-1,X         ; upper-left from AIM
                JSR APOS_TO_I25
                STY CURSOR_UL
                ;
                ; get type of energy thrown
                ;
                LDX COMPNTR
                LDA COMMAND+0,X
                ROL
                ROL
                ROL
                AND #$03
                STA ENTYPE
                ;
                ; extract dimensions of area covered
                ;
                LDA COMMAND+1,X         ; width-1/height-1 from ENERGY
                TAY
                LSR
                LSR
                LSR
                LSR
                TAX
                STX XCOUNT
                TYA
                AND #$0F
                TAY
                STY YCOUNT
                ;
                ; compute lower-right cursor
                ;
                TXA
                CLC
                ADC CURSOR_UL
                ADC MUL5,Y
                STA CURSOR_LR
                ;
                ; compute BCD count of squares covered
                ;
                LDA #0
                SED
:2              SEC                     ; +1
                ADC XCOUNT
                DEY
                BPL :2
                CLD
                STA SQUARE_COUNT
                ;
                ; set squares in hit zone to #$FF
                ;
                LDA CURSOR_UL
:3              PHA
                TAY
                LDX XCOUNT
                LDA #$FF
:4              STA ENHIT,Y
                INY
                DEX
                BPL :4
                PLA
                CLC
                ADC #5
                DEC YCOUNT
                BPL :3
                ;
                ; draw boundaries
                ;
                JSR ZONE

*------------------------------*
*   Begin attack description   *
*------------------------------*

                LDY COMPNTR
                LDA COMMAND-2,Y
                LSR
                LSR
                LSR
                LSR                 ;CHANGE TO 2 BYTE VALUES IN TABLE
                STA TEMP
                ASL
                ADC TEMP
                TAX
                LDY ENTABLE+1,X
                STY ENERGY_H
                LDA ENTABLE+2,X
                STA ENERGY_L
                TAX
                LDA SQUARE_COUNT
                JSR MULTIPLY_12
                LDX #<PRODUCT_3
                LDY #>PRODUCT_3
                CLC
                JSR DRAINER_MAIN
                BCS :SKIPB
                LDY #energylev+1
                LDA (CHARDL),Y
                TAX
                DEY
                LDA (CHARDL),Y
                TAY
                LDA SQUARE_COUNT
                JSR DIVIDE_12
                STX ENERGY_H
                PHA
                LDY #energylev+2
                LDA (CHARDL),Y
                TAX
                PLA
                TAY
                LDA SQUARE_COUNT
                JSR DIVIDE_12
                STX ENERGY_L
                TXA                 ;Check for 0 energy throw
                ORA ENERGY_H
                BNE :SKIPB
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* "<name> RELEASES A HARMLESS"
* "BOLT OF ENERGY."
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                JSR CLEAR_TLINE1
                LDY #5              ;S>5 CharsName.Releases.A.Harmless
                JMP EXIT_ENERGY     ;    Bolt.Of.Energy.
:SKIPB

*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* "<name> | LETS LOOSE | WITH A"
*         | UNLOADS    |
*         | THROWS     |
*         | DISCHARGES |
*         | RELEASES   |
*         | EMITS      |
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                JSR CLEAR_TLINE1
                LDY #xCharsName
                JSR WORD1_INC
                LDA #5
                JSR RND_DIGIT_0
                TAY
                LDA ECORES,Y
                TAY
                JSR WORD1_INC
                JSR RANDOM
                AND #$07
                CMP #$02
                BCS :SKIPA
                LDY #xWith
                JSR WORD1_INC
:SKIPA          LDY #xA
                JSR WORD1_RET

*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* "| | SCORCHING | | 999999 UNIT | BLAST | OF"
*  | | BURNING   | |             |       |
*  | | SEARING   | |             | BOLT  |
*  |               |             |       |
*  | | CRACKLING | |             | FLASH |
*  | | PULSATING | |
*  | | GLOWING   | |
*  |               |
*  | | BRILLIANT | |
*  | | BLINDING  | |
*  | | GLARING   | |
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                LDA ENTYPE
                ASL
                CLC
                ADC ENTYPE
                STA SCRATCH
                LDA #2
                JSR RND_DIGIT_0
                CLC
                ADC #xScorching
                ADC SCRATCH
                TAY
                LDX #0
                JSR WORD1_INC

                LDY #3
:LOOP4          LDA PRODUCT_4,Y
                PHA
                DEY
                BPL :LOOP4
                LDA #4
                JSR DIGITS_L

                INX
                LDY ENTYPE
                LDA BCORES,Y
                LDY #xUnit
                JSR WORD2_INC
                LDY #xOf
                JSR WORD1_RET

*------------------------------*
*   Check individual squares   *
*------------------------------*

EN_EMPTIES
                LDY #0
                STY ANY_HIT_FLAG
:1              STY AINDEX
                LDA ENHIT,Y
                BEQ :2
                LDA AGRID_MAIN,Y
                BMI :2
                LDA #0
                STA ENHIT,Y
                JSR TAKE_ENERGY
                LDY AINDEX
:2              INY
                CPY #25
                BNE :1

EN_ALIENS       LDY #0
:1              STY AINDEX
                LDA ENHIT,Y
                BEQ :4
                LDA AGRID_MAIN,Y
                BPL :4

                JSR SET_MONSTER
                LDA #0
                STA MCOUNTR
                LDA AINDEX
                PHA
                TAY
:2              STY BINDEX
                LDA ENHIT,Y
                BEQ :3
                LDA AGRID_MAIN,Y
                BPL :3
                AND #%00011111
                CMP MONSTER_INDEX
                BNE :3
                LDA #0
                STA ENHIT,Y
                INC MCOUNTR
                JSR TAKE_ENERGY
                LDY BINDEX
:3              INY
                CPY #25
                BNE :2
                JSR CLEAR_TEXT
                JSR ENAPART

                PLA
                TAY
:4              INY
                CPY #25
                BNE :1

                BIT ANY_HIT_FLAG    ;Last square
                BMI EEXIT2
                JSR CLEAR_TEXT
                LDX #0
                LDY #xEnergy
                JSR WORD1_INC
                LDY #0              ;S>0 But.No.One.Is.Affected
EXIT_ENERGY     JSR SENTENCE_PRET
                JSR DELAYER
EEXIT2          JSR CLRBOX
                JSR ZONE
                JMP CCOM

;*** TODO: change to command-specific zpage
AINDEX          DS  1
BINDEX          DS  1

*-------------------------------

ENAPART         LDA ANY_HIT_FLAG
                BNE :SKIPA
                LDX #0
                LDY #xEnergy
                JSR WORD1_PRDRET
:SKIPA          DEC ANY_HIT_FLAG
                LDX #$A5
                JSR CLOOP2
                LDX ENTYPE
                BEQ HEAT
                DEX
                BEQ ELECTRICAL
                JMP LIGHT

*-------------------------------

ELECTRICAL      LDA #xHit
                STA TEMP
                LDA #$75            ;Type % adjustment
                LDX #monELSHIELD
                LDY #susELECTRICAL
                BPL EH_COM          ;Always

HEAT            LDA #xBurned
                STA TEMP
                LDA #$50            ;Type % adjustment
                LDX #monPHSHIELD
                LDY #susHEAT

EH_COM          STX :MOD1+1
                STY :MOD2+1
                LDX TEMP
                STX HITMOD+1
                LDX ENERGY_L
                LDY ENERGY_H
                JSR PERCENT_OF
                STY TEMP
:MOD1           LDY #$FF            ;Modified
                LDA (MONS_PTR),Y
                LDY TEMP
                JSR LESS_PERCENT
:MOD2           LDA #$FF            ;Modified
                JSR SUSEPTABILITY
                LDA MCOUNTR
                JSR MULTIPLY_12
                LDX PRODUCT_3+2
                LDY PRODUCT_3+1
                LDA PRODUCT_3+0
                BEQ :SKIPA
                LDX #$99
                LDY #$99
:SKIPA          STX TOTAL_DAMAGEL
                STY TOTAL_DAMAGEH
                TXA
                BNE HAS_EFFECT
                TYA
                BEQ NO_EFFECT

HAS_EFFECT
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* "<monsname> IS | HIT    | FOR"
*                | BURNED |
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                LDA #5
                JSR CLEAR_TLINE
                LDY #xMonsName
                LDA #xIs
                JSR WORD2_INC
HITMOD          LDY #$FF            ;Modified
                LDA #xFor
                JSR WORD2_RET

*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* "<damage> DAMAGE|.               |
*                 | AND DESTROYED. |
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                JSR MDAMAGE_SUB
                PHP
                LDX #0
                LDY #x9999
                LDA #xDamage
                JSR WORD2
                PLP
                PHP
                BCC :SKIPA
                INX
                LDY #xAnd
                LDA #xIs
                JSR WORD2_INC
                JSR KILL_DESTROY
:SKIPA          JSR PERIOD_RETURN
                JSR BLINK_MONS
                PLP
                BCC :EXIT
                JSR DRAW_ALIEN
                JSR MONS_FROMGRID
                JSR UPDATE_MNAMES
:EXIT           JMP DELAYER


NO_EFFECT
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* "<monsname> IS HIT BUT"
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                LDA #5
                JSR CLEAR_TLINE
                LDY #39             ;s>39 <monsname>.Is.Hit.But
                JSR SENTENCE_RET

*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* "NOT AFFECTED."
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                LDY #xNot
                LDA #xAffected
                JSR WORD2_PRDRET
                JMP DELAYER

*-------------------------------

LIGHT           LDA ENERGY_H
                STA BASE+0
                LDA ENERGY_L
                STA BASE+1
                LDY #0
                STY BASE+2
                STY BASE+3
                LDX #$25            ;Type % adjustment
                JSR MULTIPLY_BASE

                LDY #aSusepts
                LDA (ALIEN_PTR),Y
                ASL
                ROL
                ROL
                ASL
                AND #%00000110
                TAX
                LDY LIGHT_SUS,X
                LDA LIGHT_SUS+1,X
                TAX
                JSR MULTIPLY_BASE

                LDY #monUPREF
                JSR MUCHTIM
                TYA
                ASL
                TAX
                LDY PER_TABLE,X
                LDA PER_TABLE+1,X
                TAX
                JSR MULTIPLY_BASE

                LDY MCOUNTR
                LDX #0
                JSR MULTIPLY_BASE
                LDY BASE+0
                LDX BASE+1
                STY TEMP+1
                STX TEMP
                LDA #blind
                JSR STATUS_MONS
                BCS :SKIPA          ;Branch if it had effect

*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* "<monsname> IS"
* "NOT AFFECTED."
*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                LDA #5
                JSR CLEAR_TLINE
                LDY #25             ;S>25 <monsname>.Is.RET.Not.Affected
                JSR SENTENCE_PRET
:SKIPA          JMP DELAYER

LIGHT_SUS       HEX 0000            ;never
                HEX 0010            ;little
                HEX 0025            ;some
                HEX 0100            ;very

PER_TABLE       HEX 0360            ;36/10?
                HEX 0090            ;18/20?
                HEX 0040            ;12/30?
                HEX 0022            ; 9/40?
                HEX 0014            ; 7/50?
                HEX 0010            ; 6/60?

*-------------------------------
*
*-------------------------------

ZONE            LDA CURSOR_UL
                LDX #$00                ; upper-left
                JSR :ZONE_SUB
                LDA CURSOR_LR
                LDX #$FF                ; lower-right
:ZONE_SUB       STA CURSOR
                STX EZONE_FLAG
                JMP EZONE_CURSOR

*-------------------------------

; TODO: move to per-command ZPAGE
CURSOR_UL       DB  0
CURSOR_LR       DB  0
SQUARE_COUNT    DB  0
ANY_HIT_FLAG    DB  0

ECORES          DB  xLetsLoose,xUnloads,xThrows
                DB  xDischarges,xReleases,xEmits
BCORES          DB  xBlast,xBolt,xFlash

*-------------------------------
