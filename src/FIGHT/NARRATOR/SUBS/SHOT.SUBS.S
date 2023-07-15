
DRAW_SHOOTBOX   JSR DRAW_PICT
                PictSetPage2
                PictClear 0;70;40;192
                PictCall DRAW_GRID_WALLS
                PictCall COPY_SHOTGRID2
                PictSetWhite1
                PictRect 0;70;87;190
                PictEnd
                RTS

COPY_SHOTGRID1  LDA #13
                DB  $2C                 ; BIT abs
COPY_SHOTGRID2  LDA #26
                STA :MOD+1
                LDX #71
:1              JSR SET_SOURCE_LINE
                LDA SCREENL
                CLC
:MOD            ADC #$FF
                STA DESTINL
                LDA SCREENH
                STA DESTINH
                LDY #12
:2              LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :2
                INX
                CPX #190
                BNE :1
                RTS

*-------------------------------
*
*-------------------------------

EOR_SHOTGRID    LDX #71
:LOOP1          JSR EOR_SUB
:LOOP2          LDA (SCREENL),Y
                EOR (DESTINL),Y
                STA (SCREENL),Y
                DEY
                BPL :LOOP2
                INX
                CPX #190
                BNE :LOOP1
                RTS

EOR_SUB         LDA LOBYTES,X
                STA SCREENL
                CLC
                ADC #13
                STA DESTINL
                LDA HIBYTES,X
                STA SCREENH
                ADC #0
                STA DESTINH
                LDY #12
                RTS

*-------------------------------
*
*-------------------------------

EOR_SHOT        LDX #71
:1              JSR SET_SOURCE_LINE
                JSR SET_DEST_OFF
                LDY #12
:2              LDA (SCREENL),Y
                EOR (DESTINL),Y
                STA (SCREENL),Y
                DEY
                BPL :2
                LDA SHOT_TYPE           ; Every other line if
                CMP #2                  ;  brain jammer or robot restrainer
                BCC :3
                INX
:3              INX
                CPX #190
                BCC :1
                RTS

*-------------------------------
*
*-------------------------------

FADE_ALIEN      JSR DRAW_PICT
                PictSetPage2
                PictCall COPY_SHOTGRID1
                PictCopyTo 0;71;13;190
                PictCall DRAW_ALIEN
                PictEnd
                LDA #8
                STA COUNTER
:LOOP1          LDA #71
                STA TEMP                ; line number
:LOOP2          TAX
                JSR SET_SOURCE_OFF
                JSR SET_DEST_LINE
                TXA
                CLC
                ADC COUNTER
                AND #%00000111
                TAX
                LDY #12
:LOOP3          LDA (SCREENL),Y
                EOR (DESTINL),Y
                AND FADE_MASKS,X
                EOR (SCREENL),Y
                STA (SCREENL),Y
                INX
                TXA
                AND #%00000111
                TAX
                DEY
                BPL :LOOP3
                LDA TEMP                ; line number
                CLC
                ADC #5
                STA TEMP
                CMP #189
                BCC :LOOP2
                SEC
                SBC #117
                STA TEMP
                CMP #76
                BNE :LOOP2
                DEC COUNTER
                BNE :LOOP1
COPY_GRIDLEFT   LDX #71
:1              JSR EOR_SUB
:2              LDA (DESTINL),Y
                STA (SCREENL),Y
                DEY
                BPL :2
                INX
                CPX #190
                BNE :1
                JMP SET_PAGE1

FADE_MASKS      DB  %00000001
                DB  %00010000
                DB  %00000010
                DB  %00100000
                DB  %00000100
                DB  %01000000
                DB  %00001000
                DB  %10000000

*-------------------------------------------------------
* On Entry:
*   EL_DAMAGEL,H: Initial damage value
*            X,Y: Destination coordinates
*    Carry Clear: No ricochets allowed
*      Carry Set: Ricochets are allowed
*
*   SET_SHOT_START called for source coordinates
*
* On Exit:
*   EL_DAMAGEL,H: Final damage value
*      RICOCHETS: Number of times shot hit wall
*       ABSORBED: #$FF if wall absorbed energy
*        BLOCKED: #$FF if alien hit alien/char hit char
*     SQUARE_HIT: 00 if nothing hit
*                 XY if square is hit
*-------------------------------------------------------

TRACE_SHOT      LDA #$00
                STA SQUARE_HIT
                STA BLOCKED
                STA ABSORBED
                ADC #$FF                ; capture passed carry
                STA RICOCHETS

                LDA #$FF                ; monster shot
                CPY YCOORD
                BCS :1
                LDA #0                  ; character shot
:1              STA MC_FLAG

                JSR TRACE_LINE

LINE_LOOP       CPY #71
                BCC :DONE               ; hit top boundary
                CPY #190
                BCS :DONE               ; hit bottom boundary
                TXA
                BEQ :DONE               ; hit left boundary
                CPX #87
                BEQ :DONE               ; hit right boundary

                LDA HNDX
                CLC
                ADC #26
                TAY
                LDA HMASK
                AND (SCREENL),Y
                BEQ NOT_A_WALL          ; (X is still valid)

                INC RICOCHETS
                BNE :1
                INC RICOCHETS           ; no ricochets allowed
                BNE :ABSORBED           ; always
:1
                STY TEST_HNDX
                LDX EL_DAMAGEL
                LDY EL_DAMAGEH
                LDA #$75                ; percent
                JSR PERCENT_OF
                STX EL_DAMAGEL
                STY EL_DAMAGEH
                TYA
                ORA EL_DAMAGEL
                BEQ :ABSORBED

                LDX #$40                ; flip horizontal quadrant
                LDY TEST_HNDX
                LDA HMASK               ; test left
                LSR
                BCC :2
                LDA #$40
                DEY
:2              AND (SCREENL),Y
                BEQ :HIT_VWALL

                LDY TEST_HNDX
                LDA HMASK               ; test right
                ASL
                BPL :3
                LDA #$01
                INY
:3              AND (SCREENL),Y
                BEQ :HIT_VWALL
:HIT_HWALL      LDX #$80                ; flip vertical quadrant
:HIT_VWALL      TXA
                EOR QDRNT
                STA QDRNT
                LDA #$08
                STA COLCNT
                JSR RESUME_TRACE
                JMP LINE_LOOP

:ABSORBED       DEC ABSORBED            ; shot absorbed by the walls
:DONE           JMP SHOT_DONE

NOT_A_WALL      LDY YCOORD              ; X still hold hit X coordinate
                BIT MC_FLAG
                BPL :1
                CPY #128                ; alien shot blocked by alien
                BCS :3
                BCC :2                  ; always

:1              CPY #127                ; character shot blocked by character
                BCC :3
:2              DEC BLOCKED
:3              JSR GET_SQUARE

SHOT_DONE       JSR EOR_SHOTGRID        ; remove everything but shot itself
                JSR SET_PAGE1
                JMP EOR_SHOT

MC_FLAG         DB  0

*----------------------------------------------------
* On Entry:
*  X: X pixel position in screen coordinates
*  Y: Y line position in screen coordinates
*
* On Exit:
*   SQUARE_HIT: XY square that contains that X and Y
*----------------------------------------------------

GET_SQUARE      TXA
                PHA
                TYA
                LDX #1
                LDY #10
:1              CMP AGRID_YPNTS,X
                BCC :2
                INX
                DEY
                BNE :1
:2              STY SQUARE_HIT
                PLA
                LDY #4
:3              CMP GRID_XPNTS,Y
                BCS :4
                DEY
                BPL :3
:4              INY
                TYA
                ASL
                ASL
                ASL
                ASL
                ORA SQUARE_HIT
                STA SQUARE_HIT
                RTS

*-------------------------------

; TODO: reconcile these with rest of ZPAGE

HMASK           =   $50
QDRNT           =   $51
EL              =   $52
EH              =   $53
DY              =   $54
DXL             =   $55
DXH             =   $56
HNDX            =   $57
COLCNT          =   $58
YO              =   $59
XOL             =   $5A
XOH             =   $5B
TEST_HNDX       =   $5C

;
; On entry:
;   X: X-coordinate (low)
;   Y: Y-coordinate
;
SET_SHOT_START  STY YCOORD
                STY YO
                STX XOL
                LDA #0
                STA XOH
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDA DIV7,X
                STA HNDX
                LDY MOD7,X
                LDA BIT_TABLE,Y
                STA HMASK
                RTS
;
; On entry:
;   X: X-coordinate (low)
;   Y: Y-coordinate
;
; On exit:
;   X: pixel X-coordinate of collision
;   Y: line Y-coordinate of collision
;
TRACE_LINE      TXA
                LDX #0                  ; force X-coordinate (high)
                PHA
                SEC
                SBC XOL
                PHA
                LDA #$01
                STA COLCNT
                TXA
                SBC XOH
                STA QDRNT
                BCS HLIN2
                PLA
                EOR #$FF
                ADC #$01
                PHA
                LDA #$00
                SBC QDRNT
HLIN2           STA DXH
                STA EH
                PLA
                STA DXL
                STA EL
                PLA
                STA XOL
                STX XOH
                TYA
                CLC
                SBC YO
                BCC HLIN3
                EOR #$FF
                ADC #$FE
HLIN3           STA DY
                STY YO
                ROR QDRNT
                SEC
                SBC DXL
                TAX
                LDA #$FF
                SBC DXH
                LDY HNDX
                BCS MOVEX2

MOVEX           ASL                     ; of QDRNT
                BPL :RIGHT
:LEFT           LSR HMASK
                BCC :2
                DEY
                LDA #$40
                BNE :1                  ; always
:RIGHT          ASL HMASK
                BPL :2
                LDA #$01
                INY
:1              STY HNDX
                STA HMASK
:2              SEC
MOVEX2          LDA EL
                ADC DY
                STA EL
                LDA EH
                SBC #$00
HCOUNT          STA EH
                LDA (SCREENL),Y
                EOR #$FF
                AND HMASK
                BEQ COLLIDE
                EOR (SCREENL),Y
                STA (SCREENL),Y
                LDA #$00
                STA COLCNT
CONTINUE_TRACE  INX
                LDA QDRNT
                BCS MOVEX

MOVEY           BPL :1
                INC YCOORD
                BNE :2                  ; always
:1              DEC YCOORD
:2              TYA
                PHA
                LDY YCOORD
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                PLA
                TAY

                CLC
                LDA EL
                ADC DXL
                STA EL
                LDA EH
                ADC DXH
                JMP HCOUNT

COLLIDE         LDA COLCNT
                BEQ TRACE_END
                DEC COLCNT
                BPL CONTINUE_TRACE      ; always
;
; Save state and convert back to pixel X-coordinate
;   before reporting collision to caller.
;
TRACE_END       ROR HLIN_CARRY+1
                STX HLIN_XREG+1
                STY HLIN_YREG+1
                LDA HNDX
                ASL
                ASL
                ASL
                SEC
                SBC HNDX
                TAX
                LDA HMASK
:1              LSR
                BCS :2
                INX
                BNE :1                  ; always
:2              LDY YCOORD
                RTS

RESUME_TRACE
HLIN_CARRY      LDA #$FF                ; modified
                ASL
HLIN_XREG       LDX #$FF                ; modified
HLIN_YREG       LDY #$FF                ; modified
                JMP CONTINUE_TRACE

*-------------------------------
