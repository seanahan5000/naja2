
; TODO: combined SET_CLEAR_PAGE1/2

CLEAR_PAGE      ENT
                LDA PAGE
                BNE CLR_COM         ; always

CLEAR_PAGE1     ENT
                LDA #$20
                BNE CLR_COM         ; always

CLEAR_PAGE2     ENT
                LDA #$40
CLR_COM         CMP CLR_LOOP+2
                BEQ :SKIP1
                LDX #3*31
:LOOP1          LDA CLR_LOOP+2,X
                EOR #$60
                STA CLR_LOOP+2,X
                DEX
                DEX
                DEX
                BPL :LOOP1
:SKIP1          LDA #$00
                TAX
CLR_LOOP        STA $2000,X
                STA $2100,X
                STA $2200,X
                STA $2300,X
                STA $2400,X
                STA $2500,X
                STA $2600,X
                STA $2700,X
                STA $2800,X
                STA $2900,X
                STA $2A00,X
                STA $2B00,X
                STA $2C00,X
                STA $2D00,X
                STA $2E00,X
                STA $2F00,X
                STA $3000,X
                STA $3100,X
                STA $3200,X
                STA $3300,X
                STA $3400,X
                STA $3500,X
                STA $3600,X
                STA $3700,X
                STA $3800,X
                STA $3900,X
                STA $3A00,X
                STA $3B00,X
                STA $3C00,X
                STA $3D00,X
                STA $3E00,X
                STA $3F00,X
                INX
                BNE CLR_LOOP
                SAME_PAGE_AS CLR_LOOP
                RTS

; TODO: how necessary is it for this to be fast?
;   (worth all the code?)
MOVE_FROM_PAGE  ;ENT
                LDA PAGE
                EOR #$60
                BNE MOV_COM     ; always

MOVE_TO_PAGE    ;ENT
                LDA PAGE
                BNE MOV_COM     ; always

MOVE_TO_PAGE1   ;ENT
                LDA #$20
                BNE MOV_COM     ; always

MOVE_TO_PAGE2   ;ENT
                LDA #$40
MOV_COM         CMP :LOOP2+5
                BNE :SKIP1
                LDX #3*63
                ; TODO: faster to write an immediate instead of reading?
:LOOP1          LDA :LOOP2+2,X
                EOR #$60
                STA :LOOP2+2,X
                DEX
                DEX
                DEX
                BPL :LOOP1
:SKIP1          LDX #$00
:LOOP2          LDA $2000,X
                STA $4000,X
                LDA $2100,X
                STA $4100,X
                LDA $2200,X
                STA $4200,X
                LDA $2300,X
                STA $4300,X
                LDA $2400,X
                STA $4400,X
                LDA $2500,X
                STA $4500,X
                LDA $2600,X
                STA $4600,X
                LDA $2700,X
                STA $4700,X
                LDA $2800,X
                STA $4800,X
                LDA $2900,X
                STA $4900,X
                LDA $2A00,X
                STA $4A00,X
                LDA $2B00,X
                STA $4B00,X
                LDA $2C00,X
                STA $4C00,X
                LDA $2D00,X
                STA $4D00,X
                LDA $2E00,X
                STA $4E00,X
                LDA $2F00,X
                STA $4F00,X
                LDA $3000,X
                STA $5000,X
                LDA $3100,X
                STA $5100,X
                LDA $3200,X
                STA $5200,X
                LDA $3300,X
                STA $5300,X
                LDA $3400,X
                STA $5400,X
                LDA $3500,X
                STA $5500,X
                LDA $3600,X
                STA $5600,X
                LDA $3700,X
                STA $5700,X
                LDA $3800,X
                STA $5800,X
                LDA $3900,X
                STA $5900,X
                LDA $3A00,X
                STA $5A00,X
                LDA $3B00,X
                STA $5B00,X
                LDA $3C00,X
                STA $5C00,X
                LDA $3D00,X
                STA $5D00,X
                LDA $3E00,X
                STA $5E00,X
                LDA $3F00,X
                STA $5F00,X
                INX
                BEQ :EXIT
                JMP :LOOP2
:EXIT           RTS
;
; On Entry:
;   A: wait value
;
; On Exit:
;   X,Y: unchanged
;
WAIT            ;ENT
                SEC
:WAITA          PHA
:WAITB          SBC #$01
                BNE :WAITB
                PLA
                SBC #$01
                BNE :WAITA
                SAME_PAGE_AS :WAITA
                RTS

WAIT_KEY        ;ENT
                SEC
:WAITA          PHA
:WAITB          BIT KEYBRD
                BMI :KEYHIT
                SBC #$01
                BNE :WAITB
                PLA
                SBC #$01
                BNE :WAITA
                SAME_PAGE_AS :WAITA
                RTS
:KEYHIT         PLA
                LDA KEYBRD
                RTS
;
; Generate a random 8-bit number
;
; On Exit:
;   A: random 8-bit number (0-255)
;   Y: modified
;
; (from https://wiki.nesdev.com/w/index.php/Random_number_generator)
;   Assumes seed0 and seed1 zpage values have been initialized.
;   35 bytes, 69 cycles
;
; NOTE: seed0 and seed1 need to be initialized using either INIT_RANDOM
;   or by setting values directly.
;
RANDOM          ENT
                LDA SEED1
                TAY
                LSR
                LSR
                LSR
                STA SEED1
                LSR
                EOR SEED1
                LSR
                EOR SEED1
                EOR SEED0
                STA SEED1
                TYA
                STA SEED0
                ASL
                EOR SEED0
                ASL
                EOR SEED0
                ASL
                ASL
                ASL
                EOR SEED0
                STA SEED0
                RTS
;
; On entry:
;   A: key code with high bit set
;
; On exit:
;   A: unchanged
;   X: unchanged
;   Y: unchanged
;   Z: 1 on successful key compare
;
; TODO: handle lower case?
;
CHECK_UP        ENT
                CMP #"A"
                BEQ :1
                CMP #"I"
                BEQ :1
                CMP #$8B            ; up arrow
:1              RTS

CHECK_DOWN      ENT
                CMP #"Z"
                BEQ :1
                CMP #"M"
                BEQ :1
                CMP #$8A            ; down arrow
:1              RTS

CHECK_LEFT      ENT
                CMP #"J"
                BEQ :1
                CMP #$88            ; left arrow
:1              RTS

CHECK_RIGHT     ENT
                CMP #"K"
                BEQ :1
                CMP #$95            ; right arrow
:1              RTS

CHECK_ENTER     ENT
                CMP #" "
                BEQ :1
                CMP #$8D            ; <return>
:1              RTS

CHECK_CANCEL    ENT
                CMP #"C"
                BEQ :1
                CMP #$9B            ; <escape>
:1              RTS
