*===============================
*
*===============================

CREATE_MGRID    LDX #24
                LDA #$FF
:1              STA MASTER_MGRID,X
                STA AUX_MGRID,X
                DEX
                BPL :1
                LDA #0
                STA POINTER
:2              LDX POINTER
                LDA PECKS,X
                BEQ :4
                BMI :3
                JSR SET_MONSTER
**** CHECK FOR SPECIAL THINGS LIKE BEING INVISIBLE, ETC.
                LDY #monSTATUS
                LDA (MONS_PTR),Y
                CMP #dead
                BEQ :3
                LDY #monPOSITION
                LDA (MONS_PTR),Y
                JSR MONS_TOGRID
                LDY #monCRNTCMD
                LDA (MONS_PTR),Y
                AND #%00001111
                CMP #cmdMOVE
                BNE :3
                INY
                LDA (MONS_PTR),Y
                JSR PRE_FILLCHK1
                ORA #%01000000
                LDX #%10111111
                JSR FILL_GRID
:3              INC POINTER
                BNE :2              ;Always
:4              RTS

*===============================
*
*===============================

MONS_FROMGRID   LDX #24
:1              LDA AUX_MGRID,X
                AND #%10111111
                CMP MONSTER_INDEX
                BNE :2
                LDA #$FF
                STA AUX_MGRID,X
                LDA MASTER_MGRID,X
                AND #%10111111
                CMP MONSTER_INDEX
                BNE :2
                LDA #$FF
                STA MASTER_MGRID,X
:2              DEX
                BPL :1
                RTS

*======================================
* On Entry:
*   A: XY coordinate to place alien at
*======================================

MONS_TOGRID     JSR PRE_FILLCHK2
                ORA #%01000000
                LDX #%10111111
                JSR FILL_GRID
                LDX #24
:1              LDA MASTER_MGRID,X
                TAY
                AND #%10111111
                CMP MONSTER_INDEX
                BNE :2
                TYA
                STA AUX_MGRID,X
:2              DEX
                BPL :1
                RTS

*-------------------------------
*
*-------------------------------

PRE_FILLCHK1    LDX #<AUX_MGRID
                LDY #>AUX_MGRID
                BNE PRE_FC          ;Always
PRE_FILLCHK2    LDY #monPOSITION
                LDA (MONS_PTR),Y
PRE_FILLCHK3    LDX #<MASTER_MGRID
                LDY #>MASTER_MGRID
PRE_FC          STX POINTL
                STY POINTH
                LDX TVIEW_WIDTH
                STX XCOUNT
                LDY TVIEW_HEIGHT
                STY YCOUNT
                JSR MON_INDEXER
                LDA MONSTER_INDEX
                RTS

*===============================
*
*===============================

CHANGE_CGRID    JSR CAPTURE_CGRID
                JSR CREATE_CGRID
                JMP UPDATE_CGRID

*-------------------------------

CREATE_CGRID    LDX #24
:LOOP1          LDA #$FF
                STA MASTER_CGRID,X
                DEX
                BPL :LOOP1

                JSR FIRST_CHAR
:LOOP2          JSR BAD_STATUS
                BEQ :SKIPA
                LDX CHAR_INDEX
                LDA TEMPCHAR_XY,X
                JSR CHAR_INDEXER
                STX TEMP
                LDA CHAR_INDEX
                STA MASTER_CGRID,Y
                TAX
                LDA IMAGENS,X
                BEQ :SKIPA
                LDA TEMP
                CMP #$04
                BEQ :SKIPA
                INY
                LDA MASTER_CGRID,Y
                CMP #$FF
                BNE :SKIPA
                LDA CHAR_INDEX
                ORA #$80
                STA MASTER_CGRID,Y
:SKIPA          JSR NEXT_CHAR
                BCC :LOOP2
                LDA CHAR_NUMBER     ;Take note of this
                JMP SET_CHAR

*-------------------------------

CAPTURE_CGRID   LDX #$18
:LOOP1          LDA MASTER_CGRID,X
                STA OLD_CGRID,X
                DEX
                BPL :LOOP1
                RTS

*-------------------------------

UPDATE_CGRID    LDA #0
                STA XCOUNT
                STA YCOUNT
                STA COUNT
:LOOP1          LDX COUNT
                LDA OLD_CGRID,X
                CMP MASTER_CGRID,X
                BEQ :SKIPA
                PHA
                LDX XCOUNT
                LDY YCOUNT
                JSR CGRID_MOVETO
                PLA
                JSR :SUBA
                LDX COUNT
                LDA MASTER_CGRID,X
                JSR :SUBA
:SKIPA          INC XCOUNT
                LDA XCOUNT
                CMP #5
                BNE :SKIPB
                LDA #0
                STA XCOUNT
                INC YCOUNT
:SKIPB          INC COUNT
                LDA COUNT
                CMP #25
                BNE :LOOP1
                LDA CHAR_NUMBER     ;Take note of this
                JSR SET_CHAR
                RTS

:SUBA           TAY
                CMP #$FF
                BEQ :2
                TYA
                AND #$7F
                JSR SET_CHAR
                TYA
                BMI :1
                JMP DRAW_PROF_TOPVIEW
:1              JMP DRAW_PROF_IMAGEN
:2              RTS

*-------------------------------
