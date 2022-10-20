
NEXT_XY         LDA XYDATAL
                CLC
                ADC #XYDATA_SIZE
                STA XYDATAL
                BCC :1
                INC XYDATAH
:1              RTS

PREV_XY         LDA XYDATAL
                SEC
                SBC #XYDATA_SIZE
                STA XYDATAL
                BCS :1
                DEC XYDATAH
:1              RTS

;
; Draw encoded line segment data
;
; on entry:
;   X: pointer to line segment data low
;   Y: pointer to line segment data high
;
; on exit:
;   A: count of segments clipped
;   Z: zero status of clipped segment count
;
DRAW_SEGMENTS   ENT
                STX LINE_PTR
                STY LINE_PTRH
                LDA #0
                STA CLIP_ENABLE
                STA LINES_CLIPPED
                STA LINE_INDEX
:MOVE_OP        LDA #1
                STA LINE_MOVE       ; start in move mode
:NEXT           LDY LINE_INDEX
                LDA (LINE_PTR),Y
                BMI :OPCODE

                TAX
                INY
                LDA (LINE_PTR),Y
                INY
                STY LINE_INDEX
                TAY
                LDA (XYDATAL),Y
                STA DY
                TXA
                TAY

                LDA (XYDATAL),Y
                STA LAST_X          ; save for later zero-clipping

                LDX LINE_SIDE
                BNE :RIGHT

:LEFT           STA DXL
                LDA #0
                STA DXH
                BEQ :POINT          ; always

:RIGHT          LDA #$16
                SEC
                SBC LAST_X
                STA DXL
                LDA #$01
                SBC #0
                STA DXH

:POINT          LDX LINE_MOVE
                BEQ :HLINE
                DEX
                STX LINE_MOVE

:HPOSN          LDY DY
                STY YO
                STY YCRD
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDX DXL
                STX XOL
                LDY DXH
                STY XOH
                BNE :1
                LDA DIV7,X
                LDY MOD7,X
                BPL :2              ; always
:1              LDA DIV7HI,X
                LDY MOD7HI,X
:2              STA HNDX
                LDA BIT_TABLE,Y
                STA HMASK
                BNE :NEXT           ; always

; TODO: move to top of function for short branches
;   and remove most JMPs

:OPCODE         INY
                STY LINE_INDEX
                CMP #ORD_MOVE
                BEQ :MOVE_OP
                CMP #ORD_FLIP
                BEQ :FLIP_OP
                CMP #ORD_INC
                BEQ :INC_OP
                CMP #ORD_DEC
                BEQ :DEC_OP
                CMP #ORD_STOP
                BNE :CLIP_OP
                LDA LINES_CLIPPED   ; return value and Z status
                RTS

:FLIP_OP        LDA LINE_SIDE
                EOR #$01
                STA LINE_SIDE
                JMP :NEXT

:INC_OP         JSR NEXT_XY
                JMP :NEXT

:DEC_OP         JSR PREV_XY
                JMP :NEXT

:CLIP_OP        SEC
                SBC #ORD_CLIP-1
                STA CLIP_ENABLE
                JMP :MOVE_OP        ; CLIP restarts MOVE point

;*******************************************************************************
            do useXLines
;*******************************************************************************

:HLINE          LDX #$E8        ; INX
                LDY DY
                TYA
                SEC
                SBC YO
                STY YO
                BCS :POS_DY
:NEG_DY         LDX #$CA        ; DEX
                EOR #$FF
;               CLC
                ADC #1
:POS_DY         STA DY
                STX DY_OPCODE

                LDX DXL
                TXA
                SEC
                SBC XOL
                STX XOL
                TAX
                LDY DXH
                TYA
                SBC XOH
                STY XOH
                LDY #0          ; right draw
                BCS :POS_DX
:NEG_DX         TAY
                TXA
                EOR #$FF
;               CLC
                ADC #1
                TAX
                TYA
                EOR #$FF
                ADC #0
                LDY #5          ; left draw
:POS_DX         STA DXH
                STX DXL

                LDA COLOR
                BNE :DRAW
                TYA
                CLC
                ADC #10         ; erase
                TAY
                LDA HMASK
                EOR #$FF
                STA HMASK

; NOTE: wide X-dominant lines are not supported
;   (DXH is assumed to be zero)
:DRAW           LDA DXL
                CMP DY
                BCC :YDOM
                BEQ :YDOM

:XDOM_NARROW    TAX
                INX
                STX COUNTL
                LSR A
                STA EL
                LDX DY
                BEQ :DRAW_HORZ

:DRAW_XDOM_SHORT
                LDA CLIP_ENABLE
                BNE :DRAW_XDOM_SHORT_CLIP
                JSR DRAW_XDOM_SHORT
                JMP :TO_NEXT

:DRAW_XDOM_SHORT_CLIP
                STA CLIP_SKIP
                JSR DRAW_XDOM_SHORT_CLIP
                BCS :SKIP_CLIPPED
                LDA LAST_X
                BEQ :SKIP_CLIPPED
                JMP :TO_NEXT

:DRAW_HORZ      LDA CLIP_ENABLE
                BNE :DRAW_HORZ_CLIP
                JSR DRAW_HORZ
                JMP :TO_NEXT

:DRAW_HORZ_CLIP STA CLIP_SKIP
                JSR DRAW_HORZ_CLIP
                BCS :SKIP_CLIPPED
                LDA LAST_X
                BEQ :SKIP_CLIPPED
                JMP :TO_NEXT

:YDOM           LDA DY
                LSR A
                STA EL

                LDA DXL
                BEQ :DRAW_VERT

:DRAW_YDOM      LDA CLIP_ENABLE
                BNE :DRAW_YDOM_CLIP
                JSR DRAW_YDOM
                JMP :TO_NEXT

:DRAW_YDOM_CLIP STA CLIP_SKIP
                JSR DRAW_YDOM_CLIP
                BCS :SKIP_CLIPPED
                LDA LAST_X
                BEQ :SKIP_CLIPPED
                JMP :TO_NEXT

:DRAW_VERT      LDA CLIP_ENABLE
                BNE :DRAW_VERT_CLIP
                JSR DRAW_VERT
                JMP :TO_NEXT

:DRAW_VERT_CLIP STA CLIP_SKIP
                JSR DRAW_VERT_CLIP
                BCS :SKIP_CLIPPED
                LDA LAST_X
                BEQ :SKIP_CLIPPED
;               JMP :TO_NEXT

:TO_NEXT        LDA HMASK
                BPL :3
                EOR #$FF
                STA HMASK
:3              JMP :NEXT

:SKIP_CLIPPED   INC LINES_CLIPPED
                LDY LINE_INDEX
:LOOP1          LDA (LINE_PTR),Y
                CMP #ORD_STOP
                BEQ :STOP_OP
                INY
                CMP #ORD_CLIP
                BNE :LOOP1
                STY LINE_INDEX
                JMP :CLIP_OP

:STOP_OP        LDA LINES_CLIPPED   ; return value and Z status
                RTS

MOD_TABLE
; right draw
                DB  $05,$06,$10,$C8,$01         ; ORA, ASL, BPL, INY, $01
; left draw
                DB  $05,$46,$D0,$88,$40         ; ORA, LSR, BNE, DEY, $40

; right erase
                DB  $25,$26,$30,$C8,$FE         ; AND, ROL, BMI, INY, $FE
; left erase
                DB  $25,$66,$B0,$88,$BF         ; AND, ROR, BCS, DEY, $BF

;*******************************************************************************
            else
;*******************************************************************************

:HLINE          LDX DXL
                TXA
                SEC
                SBC XOL
                STX XOL
                TAX
                LDY DXH
                TYA
                SBC XOH
                STY XOH
                STA QDRNT
                BCS :HLIN2
                TXA
                EOR #$FF
                ADC #1
                TAX
                LDA #0
                SBC QDRNT
:HLIN2          STA DXH
                STA EH
                STX DXL
                STX EL

                LDY DY
                TYA
                CLC
                SBC YO
                STY YO
                BCC :HLIN3
                EOR #$FF
                ADC #$FE
:HLIN3          STA DY
                ROR QDRNT
                SEC
                SBC DXL
                STA COUNTL
                LDA #$FF
                SBC DXH
                STA COUNTH
;               PHP

                LDA COLOR
                BEQ :ERASE

:DRAW           LDA CLIP_ENABLE
                BNE :DRAW_CLIPPED
;               PLP
                JSR DRAW_LINE
                JMP :NEXT

:DRAW_CLIPPED   STA CLIP_SKIP
;               PLP
                JSR DRAW_CLIPPED
                BCS :SKIP_CLIPPED
                LDA LAST_X
                BEQ :SKIP_CLIPPED
                JMP :NEXT

:ERASE          LDA CLIP_ENABLE
                BNE :ERASE_CLIPPED
;               PLP
                JSR ERASE_LINE
:TO_NEXT        JMP :NEXT

:ERASE_CLIPPED  STA CLIP_SKIP
;               PLP
                JSR ERASE_CLIPPED
                BCS :SKIP_CLIPPED
                LDA LAST_X
                BNE :TO_NEXT

:SKIP_CLIPPED   INC LINES_CLIPPED
                LDY LINE_INDEX
:LOOP1          LDA (LINE_PTR),Y
                CMP #ORD_STOP
                BEQ :STOP
                INY
                CMP #ORD_CLIP
                BNE :LOOP1
                STY LINE_INDEX
                JMP :CLIP_OP

:STOP           LDA LINES_CLIPPED   ; return value and Z status
                RTS

;*******************************************************************************

; line drawing core with collision detection DISABLED

DRAW_RIGHT      ASL HMASK           ; 5
                BPL :MOVEX2         ; 3/2 (=8)
                INY                 ; 2
                LDA #$01            ; 3
                STA HMASK           ; 3
                STY HNDX            ; 3 (=18)
:MOVEX2

DRAW_LEFT       LSR HMASK           ; 5
                BNE :MOVEX2         ; 3/2 (=8)
                DEY                 ; 2
                LDA #$40            ; 3
                STA HMASK           ; 3
                STY HNDX            ; 3 (=18)
:MOVEX2

DRAW_LINE       PHP
                LDX #0+6
                LDA #$E6            ; INC zp
                BIT QDRNT
                BMI :1              ; DY sign is reversed
                LDA #$C6            ; DEC zp
:1              BVC :2
                LDX #11+6
:2              STA :DY_MOD
                LDY #6
:3              LDA DRAW_RIGHT,X
                STA :DX_MOD,Y
                DEX
                DEY
                BPL :3

                LDY HNDX
                LDX COUNTL
                PLP
                BCS :MOVEX2

:MOVEX
:DX_MOD         ASL HMASK           ; 5
                BPL :MOVEX2         ; 3/2 (=8)
                INY                 ; 2
                LDA #$01            ; 3
                STA HMASK           ; 3
                STY HNDX            ; 3 (=18)

:MOVEX2         LDA EL              ; 3
                SEC                 ; 2
                ADC DY              ; 3
                STA EL              ; 3
                LDA EH              ; 3
                SBC #$00            ; 3
                STA EH              ; 3 (=20)

:HCOUNT         LDA (SCREENL),Y     ; 5
                ORA HMASK           ; 3   HMASK & 0x7F
                STA (SCREENL),Y     ; 5 (=13)

                INX                 ; 2
                BEQ :COUNTH         ; 2/3
:HLIN4          BCS :MOVEX          ; 3/2

:DY_MOD         INC YCRD            ; 5   INC/DEC YCRD
                LDY YCRD            ; 3
                LDA LOBYTES,Y       ; 4
                STA SCREENL         ; 3
                LDA HIBYTES,Y       ; 4
                STA SCREENH         ; 3
                LDY HNDX            ; 3 (=25)

                LDA EL              ; 3
                CLC                 ; 2
                ADC DXL             ; 3
                STA EL              ; 3
                LDA EH              ; 3
                ADC DXH             ; 3
                STA EH              ; 3
                JMP :HCOUNT         ; 3 (=23)
                                    ; = 91 (8+13+20+6+25+23) (136)
:COUNTH         INC COUNTH
                BNE :HLIN4
                RTS

; line drawing core with collision detection ENABLED

DRAW_CLIPPED    PHP
                LDX #0+6
                LDA #$E6            ; INC zp
                BIT QDRNT
                BMI :1              ; DY sign is reversed
                LDA #$C6            ; DEC zp
:1              BVC :2
                LDX #11+6
:2              STA :DY_MOD
                LDY #6
:3              LDA DRAW_RIGHT,X
                STA :DX_MOD,Y
                DEX
                DEY
                BPL :3

                LDY HNDX
                LDX COUNTL
                PLP
                BCS :MOVEX2

:MOVEX
:DX_MOD         ASL HMASK           ; 5
                BPL :MOVEX2         ; 3/2
                INY                 ; 2
                LDA #$01            ; 3
                STA HMASK           ; 3
                STY HNDX            ; 3

:MOVEX2         LDA EL              ; 3
                SEC                 ; 2
                ADC DY              ; 3
                STA EL              ; 3
                LDA EH              ; 3
                SBC #$00            ; 3
                STA EH              ; 3

:HCOUNT         PHP                 ; 3
                LDA (SCREENL),Y     ; 5
                ORA HMASK           ; 3   HMASK & 0x7F
                CMP (SCREENL),Y     ; 5
                BEQ :CLIPPED        ; 2/3
                STA (SCREENL),Y     ; 5
                LDA #0              ; 3
                STA CLIP_SKIP       ; 3
                PLP                 ; 4

:NO_CLIPPED     INX                 ; 2
                BEQ :COUNTH         ; 2/3
:HLIN4          BCS :MOVEX          ; 3/2

:DY_MOD         INC YCRD            ; 5   INC/DEC YCRD
                LDY YCRD            ; 3
                LDA LOBYTES,Y       ; 4
                STA SCREENL         ; 3
                LDA HIBYTES,Y       ; 4
                STA SCREENH         ; 3
                LDY HNDX            ; 3

                LDA EL              ; 3
                CLC                 ; 2
                ADC DXL             ; 3
                STA EL              ; 3
                LDA EH              ; 3
                ADC DXH             ; 3
                STA EH              ; 3
                JMP :HCOUNT         ; 3
                                    ; = 138 (169)
:CLIPPED        PLP
                LDA CLIP_SKIP
                BEQ :DID_CLIPPED
                DEC CLIP_SKIP
                BPL :NO_CLIPPED     ; always

:DID_CLIPPED    SEC                 ; return did collision
                RTS

:COUNTH         INC COUNTH
                BNE :HLIN4
                CLC                 ; return no collision
                RTS

; line erasing core with collision detection DISABLED

ERASE_RIGHT     ROL HMASK           ; 5
                BMI :MOVEX2         ; 3/2
                INY                 ; 2
                LDA #$7E            ; 3
                STA HMASK           ; 3
                STY HNDX            ; 3
:MOVEX2

ERASE_LEFT      ROR HMASK           ; 5
                BCS :MOVEX2         ; 3/2
                DEY                 ; 2
                LDA #$BF            ; 3
                STA HMASK           ; 3
                STY HNDX            ; 3
:MOVEX2

ERASE_LINE      PHP
                LDA HMASK
                EOR #$FF
                STA HMASK

                LDX #0+6
                LDA #$E6            ; INC zp
                BIT QDRNT
                BMI :1              ; DY sign is reversed
                LDA #$C6            ; DEC zp
:1              BVC :2
                LDX #11+6
:2              STA :DY_MOD
                LDY #6
:3              LDA ERASE_RIGHT,X
                STA :DX_MOD,Y
                DEX
                DEY
                BPL :3

                LDY HNDX
                LDX COUNTL
                PLP
                BCS :MOVEX2

:MOVEX          SEC                 ; 2
:DX_MOD         ROL HMASK           ; 5
                BMI :MOVEX2         ; 3/2
                INY                 ; 2
                LDA #$7E            ; 3
                STA HMASK           ; 3
                STY HNDX            ; 3

:MOVEX2         LDA EL              ; 3
                SEC                 ; 2
                ADC DY              ; 3
                STA EL              ; 3
                LDA EH              ; 3
                SBC #$00            ; 3
                STA EH              ; 3

:HCOUNT         LDA (SCREENL),Y     ; 5
                AND HMASK           ; 3  ~(HMASK & 0x7F)
                STA (SCREENL),Y     ; 5

                INX                 ; 2
                BEQ :COUNTH         ; 2/3
:HLIN4          BCS :MOVEX          ; 3/2

:DY_MOD         INC YCRD            ; 5   INC/DEC YCRD
                LDY YCRD            ; 3
                LDA LOBYTES,Y       ; 4
                STA SCREENL         ; 3
                LDA HIBYTES,Y       ; 4
                STA SCREENH         ; 3
                LDY HNDX            ; 3

                LDA EL              ; 3
                CLC                 ; 2
                ADC DXL             ; 3
                STA EL              ; 3
                LDA EH              ; 3
                ADC DXH             ; 3
                STA EH              ; 3
                JMP :HCOUNT         ; 3

:COUNTH         INC COUNTH
                BNE :HLIN4
                LDA HMASK
                EOR #$FF
                STA HMASK
                RTS

; line erasing core with collision detection ENABLED

ERASE_CLIPPED   PHP
                LDA HMASK
                EOR #$FF
                STA HMASK

                LDX #0+6
                LDA #$E6            ; INC zp
                BIT QDRNT
                BMI :1              ; DY sign is reversed
                LDA #$C6            ; DEC zp
:1              BVC :2
                LDX #11+6
:2              STA :DY_MOD
                LDY #6
:3              LDA ERASE_RIGHT,X
                STA :DX_MOD,Y
                DEX
                DEY
                BPL :3

                LDY HNDX
                LDX COUNTL
                PLP
                BCS :MOVEX2

:MOVEX          SEC                 ; 2
:DX_MOD         ROL HMASK           ; 5
                BMI :MOVEX2         ; 3/2
                INY                 ; 2
                LDA #$7E            ; 3
                STA HMASK           ; 3
                STY HNDX            ; 3

:MOVEX2         LDA EL              ; 3
                SEC                 ; 2
                ADC DY              ; 3
                STA EL              ; 3
                LDA EH              ; 3
                SBC #$00            ; 3
                STA EH              ; 3

:HCOUNT         PHP                 ; 3
                LDA (SCREENL),Y     ; 5
                AND HMASK           ; 3   ~(HMASK & 0x7F)
                CMP (SCREENL),Y     ; 5
                BEQ :CLIPPED        ; 2/3
                STA (SCREENL),Y     ; 5
                LDA #0              ; 3
                STA CLIP_SKIP       ; 3
                PLP                 ; 4

:NO_CLIPPED     INX                 ; 2
                BEQ :COUNTH         ; 2/3
:HLIN4          BCS :MOVEX          ; 3/2

:DY_MOD         INC YCRD            ; 5   INC/DEC YCRD
                LDY YCRD            ; 3
                LDA LOBYTES,Y       ; 4
                STA SCREENL         ; 3
                LDA HIBYTES,Y       ; 4
                STA SCREENH         ; 3
                LDY HNDX            ; 3

                LDA EL              ; 3
                CLC                 ; 2
                ADC DXL             ; 3
                STA EL              ; 3
                LDA EH              ; 3
                ADC DXH             ; 3
                STA EH              ; 3
                JMP :HCOUNT         ; 3

:CLIPPED        PLP
                LDA CLIP_SKIP
                BEQ :DID_CLIPPED
                DEC CLIP_SKIP
                BPL :NO_CLIPPED     ; always

:DID_CLIPPED    SEC
                BCS :LINEND         ; always
:COUNTH         INC COUNTH
                BNE :HLIN4
                CLC
:LINEND         LDA HMASK
                EOR #$FF
                STA HMASK
                RTS

;*******************************************************************************
            fin
;*******************************************************************************
