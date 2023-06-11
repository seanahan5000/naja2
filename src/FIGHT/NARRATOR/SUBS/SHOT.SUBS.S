*-------------------------------
*
*-------------------------------

COPY_SHOTGRID   LDX #$47
:LOOP1          JSR EOR_SUB
:LOOP2          LDA (SCREENL),Y
                STA (DESTINL),Y
                DEY
                BPL :LOOP2
                INX
                CPX #$B8
                BNE :LOOP1
                RTS


*-------------------------------
*
*-------------------------------

EOR_SHOTGRID    LDX #$47
:LOOP1          JSR EOR_SUB
:LOOP2          LDA (SCREENL),Y
                EOR (DESTINL),Y
                STA (SCREENL),Y
                DEY
                BPL :LOOP2
                INX
                CPX #$B8
                BNE :LOOP1
                RTS


EOR_SUB         LDA LOBYTES,X
                STA SCREENL
                CLC
                ADC #$0E
                STA DESTINL
                LDA HIBYTES,X
                STA SCREENH
                ADC #0
                STA DESTINH
                LDY #$0C
                RTS


*-------------------------------
*
*-------------------------------

EOR_SHOT        LDX #$47
:1              LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA SCREENH
                EOR #$60
                STA DESTINH
                LDY #$0C
:2              LDA (SCREENL),Y
                EOR (DESTINL),Y
                STA (SCREENL),Y
                DEY
                BPL :2
                LDA SHOT_TYPE       ;Every other line if
                CMP #2              ;  brain jammer or robot restrainer
                BCC :3
                INX
:3              INX
                CPX #$B8
                BCC :1
CLEAN_FRONT
;                 LDA $3FB4
;                 ORA #$22
;                 STA $3FB4
;                 LDX #10
; :LOOP1          LDA $3FA9,X
;                 ORA #$55                ; violet
;                 STA $3FA9,X
;                 DEX
;                 BEQ :EXIT
;                 LDA $3FA9,X
;                 ORA #$2A                ; green
;                 STA $3FA9,X
;                 DEX
;                 BNE :LOOP1          ;Always
:EXIT           RTS


*-------------------------------
*
*-------------------------------

FADE_ALIEN      LDA #$40
                STA PAGE
                JSR COPY_SHOTGRID
                JSR COPY_GRID       ;In RUN_RESOLVER
                JSR DRAW_ALIEN
FADE_SHOTGRID   LDA #8
                STA COUNTER
:LOOP1          LDA #$47
                STA TEMP            ;line number
:LOOP2          TAX
                LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                ORA #$20
                STA SCREENH
                EOR #$60
                STA DESTINH
                TXA
                CLC
                ADC COUNTER
                AND #%00000111
                TAX
                LDY #$0C
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
                LDA TEMP            ;line number
                CLC
                ADC #5
                STA TEMP
                CMP #$B8
                BCC :LOOP2
                SEC
                SBC #$70
                STA TEMP
                CMP #$4C
                BNE :LOOP2
                DEC COUNTER
                BNE :LOOP1
COPY_GRIDLEFT   LDX #$47
:1              JSR EOR_SUB
:2              LDA (DESTINL),Y
                STA (SCREENL),Y
                DEY
                BPL :2
                INX
                CPX #$B8
                BNE :1
                LDA #$20
                STA PAGE
                RTS

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
*   HPOSN called for source coordinates
*
* On Exit:
*   EL_DAMAGEL,H: Final damage value
*      RICOCHETS: Number of times shot hit wall
*       ABSORBED: #$FF if wall aborbed energy
*        BLOCKED: #$FF if alien hit alien/char hit char
*     SQUARE_HIT: 00 if nothing hit
*                 XY if square is hit
*-------------------------------------------------------

TRACE_SHOT      LDA #$00
                STA SQUARE_HIT
                STA BLOCKED
                STA ABSORBED
                ADC #$FF            ;Use passed carry
                STA RICOCHETS

                LDA #$FF            ;Monster shot
                CPY YCRD
                BCS :SKIPA
                LDA #0              ;Character shot
:SKIPA          STA MC_FLAG

                LDA #$7F            ;WHITE1
                STA COLOR
                LDA #$FF            ;Enable collision detection
                STA COLFLG
                LDA HLINE_MOD       ;Alter line drawing code to
                STA DD3+1           ;   continue past the destination
                LDA HLINE_MOD+1     ;   point until something is hit
                STA DD4+1
                LDA #$EA
                STA HLINE_MOD
                STA HLINE_MOD+1

                TXA                 ;X and Y still assumed valid
                LDX #$00
                JSR HLIN
LINE_LOOP       ROR HLIN_CARRY+1    ;Come back here after ricochet
                STX HLIN_XREG+1
                STY HLIN_YREG+1
                LDA YCRD
                CMP #$48
                BCC :SKIPA
                CMP #$B7
                BCC NO_MISS
:SKIPA          JMP SHOT_DONE

NO_MISS         LDA HMASK
                AND #$7F
                TAX
                LDA HNDX
                BEQ :SKIPC
                CMP #$01
                BEQ :SKIPB
                CMP #$0C
                BNE NOT_A_WALL
                CPX #$02
                BEQ :SKIPA
                CPX #$01
                BNE NOT_A_WALL
:SKIPA          LDA #$81            ;Hit right wall
                BNE HIT_WALL        ;Always

:SKIPB          CPX #$01
                BEQ :SKIPD
                BNE NOT_A_WALL      ;Always
:SKIPC          CPX #$40
                BNE NOT_A_WALL
:SKIPD          LDA #$01            ;Hit left wall
                STA HNDX
                LDA #$82

HIT_WALL        STA HMASK
                INC RICOCHETS
                BNE :SKIPA
                INC RICOCHETS       ;No ricochets allowed
                DEC ABSORBED
                BNE SHOT_DONE       ;Always

:SKIPA          LDX EL_DAMAGEL
                LDY EL_DAMAGEH
                LDA #$75            ;percent
                JSR PERCENT_OF
                STX EL_DAMAGEL
                STY EL_DAMAGEH
                TXA
                BNE CAN_RICOCHET
                TYA
                BNE CAN_RICOCHET

                DEC ABSORBED        ;Shot absorbed by the walls
                JMP SHOT_DONE

CAN_RICOCHET    LDA QDRNT
                EOR #$40
                STA QDRNT
                LDA #$08
                STA FREE1+1
                BIT MC_FLAG
                JSR HLINE_UPDOWN    ;In line drawing code (BPL is up)
HLIN_CARRY      LDA #$FF            ;Modified
                ASL
HLIN_XREG       LDX #$FF            ;Modified
HLIN_YREG       LDY #$FF            ;Modified
                JSR DONT
                JMP LINE_LOOP

NOT_A_WALL      BIT MC_FLAG
                BPL :SKIPA
                LDA YCRD            ;Alien shot blocked by alien
                CMP #$80
                BCS :SKIPC
                BCC :SKIPB          ;Always

:SKIPA          LDA YCRD            ;Character shot blocked by character
                CMP #$7F
                BCC :SKIPC
:SKIPB          DEC BLOCKED
:SKIPC          JSR GET_SQUARE

SHOT_DONE       LDA #$01            ;Restore line drawing code
                STA FREE1+1         ;   to its original condition
DD3             LDA #$FF            ;Modified
                STA HLINE_MOD
DD4             LDA #$FF            ;Modified
                STA HLINE_MOD+1
                LDA #$00            ;Disable collision detection
                STA COLFLG

                JSR EOR_SHOTGRID    ;Remove shot containment box
                JSR SET_PAGE1
                JMP EOR_SHOT

MC_FLAG         DB  0

*----------------------------------------------------
* On Entry:
*    YCRD: Y position in screen coordinates
*    HNDX: X byte position in screen coordinates
*   HMASK: X bit position in screen coordinates
*
* On Exit:
*   SQUARE_HIT: XY square that contains that X and Y
*----------------------------------------------------

GET_SQUARE      LDX #5
                LDA YCRD
                CMP #$80
                BCS :SKIPA
                CLC                 ;Adjust Y coordinate if in
                ADC #$37            ;   monster part of grid
                LDX #0
:SKIPA          STX TEMP

                LDY #4
:LOOP1          CMP CGRID_YPNTS,Y   ;Look up row based on
                BCS :SKIPB          ;   Y coordinate
                DEY
                BPL :LOOP1

:SKIPB          TYA                 ;Reverse order
                CLC
                ADC TEMP
                STA TEMP
                LDA #$0A
                SEC
                SBC TEMP
                STA SQUARE_HIT

                LDA HNDX            ;Convert from byte/bit to pixel
                ASL
                ASL
                ASL
                SEC
                SBC HNDX
                STA TEMP
                LDY #0
                LDA HMASK
                AND #%01111111
:LOOP2          LSR
                BCS :SKIPC
                INY
                BNE :LOOP2
:SKIPC          TYA
                CLC
                ADC TEMP

                LDY #4
:LOOP3          CMP GRID_XPNTS,Y    ;Look up column based
                BCS :SKIPD          ;   on X coordinate
                DEY
                BPL :LOOP3
:SKIPD          INY
                TYA
                ASL
                ASL
                ASL
                ASL
                ORA SQUARE_HIT
                STA SQUARE_HIT
                RTS

*-------------------------------

COUNTH          =   $1D

HCOLOR1         =   $50             ;NCOM line plotter
HMASK           =   $51             ;
DY              =   $52             ;
QDRNT           =   $53             ;
EL              =   $54             ;
EH              =   $55             ;
DXL             =   $56             ;
DXH             =   $57             ;
HNDX            =   $58             ;
COLCNT          =   $59             ;
YO              =   $5A             ;
XOL             =   $5B             ;
XOH             =   $5C             ;
YCRD            =   $5D             ;
COLFLG          =   $5E             ;NCOM line plotter

HPOSN           STA YCRD            ;YCOORD IN ACC.
                STA YO
                STX XOL             ;XCOORDL IN X-INDEX
                STY XOH             ;XCOORDH IN Y-INDEX
                TAX
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                ; ORA PAGE
                STA SCREENH
                LDA XOL
                SEC
                CPY #$00
                BEQ HPOSN2
                LDY #$23
                CLC
                ADC #$04
                SEC
HPOSN1          INY
HPOSN2          SBC #$07
                BCS HPOSN1          ; TODO: use div/mod 7 table here
                STY HNDX
                TAX
                LDA MSKTBL-249,X
                STA HMASK
                TYA
                LSR
                LDA COLOR
                STA HCOLOR1
                BCC NOGOSHF
                JMP CSHIFT2
NOGOSHF         RTS

MSKTBL          DB  $81,$82,$84
                DB  $88,$90,$A0
                DB  $C0

HLINA           PHA                 ;COLLISION FLAG SETTINGS
                LDA #$00            ;  00-IGNORE COLLISIONS
                STA COLFLG          ;  FF-EXIT ON COLLISIONS
                PLA
HLIN            PHA                 ;YCOORD IN Y-INDEX
                SEC                 ;XCOORDL IN ACC.
                SBC XOL             ;XCOORDH IN X-INDEX
                PHA
FREE1           LDA #$01
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
                STA COUNTH
                LDY HNDX
                BCS MOVEX2
MOVEX           ASL
                JSR LFTRT
                SEC
MOVEX2          LDA EL
                ADC DY
                STA EL
                LDA EH
                SBC #$00
HCOUNT          STA EH
                LDA (SCREENL),Y
                EOR HCOLOR1
                AND HMASK
                BNE NOCOL
                BIT COLFLG
                BPL DONT
                LDA COLCNT
                BEQ HITEND
                DEC COLCNT
                JMP DONT
HITEND          LDA #$01            ;COLLISION OCCURED
                RTS
NOCOL           EOR (SCREENL),Y
                STA (SCREENL),Y
                LDA #$00
                STA COLCNT
DONT            INX
                BNE HLIN4
                INC COUNTH
HLINE_MOD       BEQ LINEND          ;Modified
HLIN4           LDA QDRNT
                BCS MOVEX
                JSR HLINE_UPDOWN
                CLC
                LDA EL
                ADC DXL
                STA EL
                LDA EH
                ADC DXH
                JMP HCOUNT
LINEND          LDA #$00            ;COMPLETE LINE DRAWN
                RTS

LFTRT           BPL RIGHT1
                LDA HMASK
                LSR
                BCS LEFT1
                EOR #$C0
LR1             STA HMASK
                RTS
LEFT1           DEY
                BPL LEFT2
                LDY #$27            ; wrap to byte column #0 to #39
LEFT2           LDA #$C0
NEWNDX          STA HMASK
                STY HNDX
                LDA HCOLOR1
CSHIFT2         ASL
                CMP #$C0
                BPL RTS1
                LDA HCOLOR1
                EOR #$7F
                STA HCOLOR1
RTS1            RTS
RIGHT1          LDA HMASK
                ASL
                EOR #$80
                BMI LR1
                LDA #$81
                INY
                CPY #$28            ; wrap from byte column #40 to #0
                BCC NEWNDX
                LDY #$00
                BCS NEWNDX          ; always

HLINE_UPDOWN    BPL UP4             ;called from fight shot sub
                INC YCRD
                BNE UPDWN4          ; always
UP4             DEC YCRD
UPDWN4          TYA
                PHA
                LDY YCRD
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                ; ORA PAGE
                STA SCREENH
                PLA
                TAY
                RTS

*-------------------------------
