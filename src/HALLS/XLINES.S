;
; draw a purely vertical line
;
DRAW_VERT       LDA MOD_TABLE+0,Y   ; ORA/AND
                EOR #$0C            ; from ZPAGE to IMM
                STA :ORA_MOD+0
                LDA HMASK
                STA :ORA_MOD+1
                LDA DY_OPCODE
                STA :DY_MOD
                LDA YO
                STA :ENDY_MOD+1
                LDX YCRD
                LDY HNDX
                BPL :1              ; always

:DY_MOD         INX                 ; 2
:1              LDA LOBYTES,X       ; 4
                STA SCREENL         ; 3
                LDA HIBYTES2,X      ; 4
                STA SCREENH         ; 3
                LDA (SCREENL),Y     ; 5
:ORA_MOD        ORA #$FF            ; 2
                STA (SCREENL),Y     ; 5
:ENDY_MOD       CPX #$FF            ; 2
                BNE :DY_MOD         ; 3/2
                STX YCRD
                RTS
;
; draw a purely vertical line with clipping
;
DRAW_VERT_CLIP  LDA MOD_TABLE+0,Y   ; ORA/AND
                EOR #$0C            ; from ZPAGE to IMM
                STA :ORA_MOD+0
                LDA HMASK
                STA :ORA_MOD+1
                LDA DY_OPCODE
                STA :DY_MOD
                LDA YO
                STA :ENDY_MOD+1
                LDX YCRD
                LDY HNDX
                BPL :1              ; always

:DY_MOD         INX                 ; 2
:1              LDA LOBYTES,X       ; 4
                STA SCREENL         ; 3
                LDA HIBYTES2,X      ; 4
                STA SCREENH         ; 3
                LDA (SCREENL),Y     ; 5
:ORA_MOD        ORA #$FF            ; 2
                CMP (SCREENL),Y
                BEQ :CHECK_CLIP
                STA (SCREENL),Y     ; 5
                LDA #0
                STA CLIP_SKIP
:ENDY_MOD       CPX #$FF            ; 2
                BNE :DY_MOD         ; 3/2
                CLC                 ; return no collision
:DID_CLIP       STX YCRD
                RTS

:CHECK_CLIP     LDA CLIP_SKIP
                SEC                 ; return did collision
                BEQ :DID_CLIP
                DEC CLIP_SKIP
                BPL :ENDY_MOD       ; always
;
; draw vertically dominant line
;
DRAW_YDOM       CPY #$00
                BEQ :CACHED
                STY DRAW_YDOM+1

                LDA MOD_TABLE+0,Y   ; ORA/AND
                STA :ORA_MOD

                LDA MOD_TABLE+1,Y   ; ASL/LSR/ROL/ROR
                STA :DX_MOD1

                LDA MOD_TABLE+2,Y   ; BPL/BNE/BMI/BCS
                STA :DX_MOD2

                LDA MOD_TABLE+3,Y   ; INY/DEY
                STA :DX_MOD3

                LDA MOD_TABLE+4,Y   ; $01/$04/$FE/$BF
                STA :DX_MOD4+1

:CACHED         LDA DY_OPCODE
                STA :DY_MOD
                LDA YO
                STA :ENDY_MOD+1
                LDX YCRD
                LDY HNDX
                BPL :LOOP2          ; always

:LOOP1          STA EL              ; 3
:LOOP2          LDA LOBYTES,X       ; 4
                STA SCREENL         ; 3
                LDA HIBYTES2,X      ; 4
                STA SCREENH         ; 3
                LDA (SCREENL),Y     ; 5
:ORA_MOD        ORA HMASK           ; 2
                STA (SCREENL),Y     ; 5
:ENDY_MOD       CPX #$FF            ; 2
                BEQ :EXIT           ; 2/3
:DY_MOD         INX                 ; 2
                LDA EL              ; 3
                SEC                 ; 2
                SBC DXL             ; 3
                BCS :LOOP1          ; 3/2
                ADC DY              ;   3
                STA EL              ;   3
;               SEC                 ;   2 (only needed for erase)
:DX_MOD1        ASL HMASK           ;   5 (carry must be set here for erase)
:DX_MOD2        BPL :LOOP2          ;   3/2
:DX_MOD3        INY                 ;     2
:DX_MOD4        LDA #$01            ;     3
                STA HMASK           ;     3
                BNE :LOOP2          ;     3  always

:EXIT           STX YCRD
                STY HNDX
                RTS
;
; draw vertically dominant line with clipping
;
DRAW_YDOM_CLIP  CPY #$00
                BEQ :CACHED
                STY DRAW_YDOM_CLIP+1

                LDA MOD_TABLE+0,Y   ; ORA/AND
                STA :ORA_MOD

                LDA MOD_TABLE+1,Y   ; ASL/LSR/ROL/ROR
                STA :DX_MOD1

                LDA MOD_TABLE+2,Y   ; BPL/BNE/BMI/BCS
                STA :DX_MOD2

                LDA MOD_TABLE+3,Y   ; INY/DEY
                STA :DX_MOD3

                LDA MOD_TABLE+4,Y   ; $01/$04/$FE/$BF
                STA :DX_MOD4+1

:CACHED         LDA DY_OPCODE
                STA :DY_MOD
                LDX YCRD
                LDY HNDX
                BPL :LOOP2          ; always

:LOOP1          STA EL              ; 3
:LOOP2          LDA LOBYTES,X       ; 4
                STA SCREENL         ; 3
                LDA HIBYTES2,X      ; 4
                STA SCREENH         ; 3
                LDA (SCREENL),Y     ; 5
:ORA_MOD        ORA HMASK           ; 2
                CMP (SCREENL),Y
                BEQ :CHECK_CLIP
                STA (SCREENL),Y     ; 5
                LDA #0
                STA CLIP_SKIP
:CLIP_REJOIN    CPX YO              ; 3
                BEQ :EXIT           ; 2/3
:DY_MOD         INX                 ; 2
                LDA EL              ; 3
                SEC                 ; 2
                SBC DXL             ; 3
                BCS :LOOP1          ; 3/2
                ADC DY              ;   3
                STA EL              ;   3
;               SEC                 ;   2 (only needed for erase)
:DX_MOD1        ASL HMASK           ;   5 (carry must be set here for erase)
:DX_MOD2        BPL :RECHECK_CLIP   ;   3/2
:DX_MOD3        INY                 ;     2
:DX_MOD4        LDA #$01            ;     3
                STA HMASK           ;     3
                ; check that diagonal lines don't pass through each other
:RECHECK_CLIP   LDA HMASK
                BMI :LOOP2          ; skip this when erasing
                ORA (SCREENL),Y
                CMP (SCREENL),Y
                BNE :LOOP2
                LDA CLIP_SKIP
                SEC                 ; return did collision
                BEQ :DID_CLIP
                DEC CLIP_SKIP
                BPL :LOOP2          ; always

:CHECK_CLIP     LDA CLIP_SKIP
                SEC                 ; return did collision
                BEQ :DID_CLIP
                DEC CLIP_SKIP
                BPL :CLIP_REJOIN    ; always

:EXIT           CLC                 ; return no collision
:DID_CLIP       STX YCRD
                STY HNDX
                RTS
;
; draw horizontally dominant line with short delta
;
DRAW_XDOM_SHORT CPY #$00
                BEQ :CACHED
                STY DRAW_XDOM_SHORT+1

                LDA MOD_TABLE+0,Y   ; ORA/AND
                STA :ORA_MOD

                LDA MOD_TABLE+1,Y   ; ASL/LSR/ROL/ROR
                STA :DX_MOD1

                LDA MOD_TABLE+2,Y   ; BPL/BNE/BMI/BCS
                STA :DX_MOD2

                LDA MOD_TABLE+3,Y   ; INY/DEY
                STA :DX_MOD3

                LDA MOD_TABLE+4,Y   ; $01/$04/$FE/$BF
                STA :DX_MOD4+1

:CACHED         LDA DY_OPCODE
                STA :DY_MOD
                LDX YCRD
                LDY HNDX
                SEC                 ; (only needed for erase)
                BCS :LOOP2          ; always

:LOOP1          STA EL              ; 3
:LOOP2          LDA (SCREENL),Y     ; 5
:ORA_MOD        ORA HMASK           ; 3
                STA (SCREENL),Y     ; 5
                DEC COUNTL          ; 5
                BEQ :EXIT           ; 2/3
:DX_MOD1        ASL HMASK           ; 5 (carry must be set here for erase)
:DX_MOD2        BPL :1              ; 3/2
:DX_MOD3        INY                 ;   2
:DX_MOD4        LDA #$01            ;   2
                STA HMASK           ;   3
:1              LDA EL              ; 3
                SEC                 ; 2
                SBC DY              ; 3
                BCS :LOOP1          ; 3/2 (set carry used by erase)
;               CLC
                ADC DXL             ;   3
                STA EL              ;   3
:DY_MOD         INX                 ;   2
                LDA LOBYTES,X       ;   4
                STA SCREENL         ;   3
                LDA HIBYTES2,X      ;   4
                STA SCREENH         ;   3
;               SEC                 ;   2 (only needed for erase)
                BCS :LOOP2          ;   3   always

:EXIT           STX YCRD
                STY HNDX
                RTS
;
; draw horizontally dominant line with short delta and clipping
;   (NOTE: probably only needed for drawing face changes)
;
DRAW_XDOM_SHORT_CLIP
                CPY #$00
                BEQ :CACHED
                STY DRAW_XDOM_SHORT_CLIP+1

                LDA MOD_TABLE+0,Y   ; ORA/AND
                STA :ORA_MOD

                LDA MOD_TABLE+1,Y   ; ASL/LSR/ROL/ROR
                STA :DX_MOD1

                LDA MOD_TABLE+2,Y   ; BPL/BNE/BMI/BCS
                STA :DX_MOD2

                LDA MOD_TABLE+3,Y   ; INY/DEY
                STA :DX_MOD3

                LDA MOD_TABLE+4,Y   ; $01/$04/$FE/$BF
                STA :DX_MOD4+1

:CACHED         LDA DY_OPCODE
                STA :DY_MOD
                LDX YCRD
                LDY HNDX
                BPL :LOOP2          ; always

:LOOP1          STA EL              ; 3
:LOOP2          LDA (SCREENL),Y     ; 5
:ORA_MOD        ORA HMASK           ; 3
                CMP (SCREENL),Y
                BEQ :CHECK_CLIP
                STA (SCREENL),Y     ; 5
                LDA #0
                STA CLIP_SKIP
:CLIP_REJOIN    DEC COUNTL          ; 5
                BEQ :EXIT           ; 2/3
                SEC                 ; 2 (only needed for erase)
:DX_MOD1        ASL HMASK           ; 5 (carry must be set here for erase)
:DX_MOD2        BPL :1              ; 3/2
:DX_MOD3        INY                 ;   2
:DX_MOD4        LDA #$01            ;   2
                STA HMASK           ;   3
:1              LDA EL              ; 3
                SEC                 ; 2
                SBC DY              ; 3
                BCS :LOOP1          ; 3/2
;               CLC
                ADC DXL             ;   3
                STA EL              ;   3
:DY_MOD         INX                 ;   2
                LDA LOBYTES,X       ;   4
                STA SCREENL         ;   3
                LDA HIBYTES2,X      ;   4
                STA SCREENH         ;   3
                BNE :LOOP2          ;   3   always

:CHECK_CLIP     LDA CLIP_SKIP
                SEC                 ; return did collision
                BEQ :DID_CLIP
                DEC CLIP_SKIP
                BPL :CLIP_REJOIN    ; always

:EXIT           CLC                 ; return no collision
:DID_CLIP       STX YCRD
                STY HNDX
                RTS
;
; draw purely horizontal line
;
DRAW_HORZ       CPY #$00
                BEQ :CACHED
                STY DRAW_HORZ+1

                LDA MOD_TABLE+0,Y   ; ORA/AND
                STA :ORA_MOD

                LDA MOD_TABLE+1,Y   ; ASL/LSR/ROL/ROR
                STA :DX_MOD1

                LDA MOD_TABLE+2,Y   ; BPL/BNE/BMI/BCS
                STA :DX_MOD2

                LDA MOD_TABLE+3,Y   ; INY/DEY
                STA :DX_MOD3
                STA :DX_MOD5

                LDA MOD_TABLE+4,Y   ; $01/$04/$FE/$BF
                STA :DX_MOD4+1

:CACHED         LDX YCRD
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES2,X
                STA SCREENH
                LDY HNDX
                LDX COUNTL
:LOOP1          LDA (SCREENL),Y
:ORA_MOD        ORA HMASK
                STA (SCREENL),Y
                DEX
                BEQ :EXIT
                SEC                 ; (only needed for erase)
:DX_MOD1        ASL HMASK
:DX_MOD2        BPL :LOOP1
:DX_MOD3        INY
:DX_MOD4        LDA #$01
                STA HMASK
                DEX                 ; bias
                LDA MOD7,X
                STA COUNTL
                LDA DIV7,X
                BEQ :1
                TAX
                LDA COLOR
:LOOP2          STA (SCREENL),Y
:DX_MOD5        INY
                DEX
                BNE :LOOP2
:1              LDX COUNTL
                INX                 ; unbias
                BNE :LOOP1          ; always

:EXIT           STY HNDX
                RTS
;
; draw purely horizontal line with clipping
;
DRAW_HORZ_CLIP  CPY #$00
                BEQ :CACHED
                STY DRAW_HORZ_CLIP+1

                LDA MOD_TABLE+0,Y   ; ORA/AND
                STA :ORA_MOD

                LDA MOD_TABLE+1,Y   ; ASL/LSR/ROL/ROR
                STA :DX_MOD1

                LDA MOD_TABLE+2,Y   ; BPL/BNE/BMI/BCS
                STA :DX_MOD2

                LDA MOD_TABLE+3,Y   ; INY/DEY
                STA :DX_MOD3
                STA :DX_MOD5

                LDA MOD_TABLE+4,Y   ; $01/$04/$FE/$BF
                STA :DX_MOD4+1

                LDA COLOR
                EOR #$7F
                STA :FILL_MOD+1

:CACHED         LDX YCRD
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES2,X
                STA SCREENH
                LDY HNDX
                LDX COUNTL
:LOOP1          LDA (SCREENL),Y
:ORA_MOD        ORA HMASK
                CMP (SCREENL),Y
                BEQ :CHECK_CLIP
                STA (SCREENL),Y
                LDA #0
                STA CLIP_SKIP
:CLIP_REJOIN    DEX
                BEQ :EXIT
                SEC                 ; (only needed for erase)
:DX_MOD1        ASL HMASK
:DX_MOD2        BPL :LOOP1
:DX_MOD3        INY
:DX_MOD4        LDA #$01
                STA HMASK
                DEX                 ; bias
                LDA MOD7,X
                STA COUNTL
                LDA DIV7,X
                BEQ :SKIP_FILL
                TAX

:LOOP2          LDA (SCREENL),Y
:FILL_MOD       CMP #$00
                BNE :STOP_FILL
                LDA COLOR
                STA (SCREENL),Y
                LDA #0
                STA CLIP_SKIP
:DX_MOD5        INY
                DEX
                BNE :LOOP2
:SKIP_FILL      LDX COUNTL
                INX                 ; unbias
                BNE :LOOP1
                BEQ :EXIT           ; always

:STOP_FILL      LDA COUNTL
                CLC
:LOOP3          ADC #7
                DEX
                BNE :LOOP3
                TAX
                INX                 ; unbias
                BNE :LOOP1          ; always

:CHECK_CLIP     LDA CLIP_SKIP
                SEC                 ; return did collision
                BEQ :DID_CLIP
                DEC CLIP_SKIP
                BPL :CLIP_REJOIN    ; always

:EXIT           CLC                 ; return no collision
:DID_CLIP       STY HNDX
                RTS
