                LDA ALIEN1
                CMP #$02
                BEQ GOSWIM
                CMP #$20
                BEQ GOSWIM
                CMP #$23
RUUSTOP         BEQ GORUUIK
                JSR PREFITE
                JMP FREAD
GOSWIM          JMP AIRSWIM

GORUUIK         STA DRIVOFF
                JSR CLEAR1
                LDA #$20
                STA PAGE
                LDA #ORANGE
                STA COLOR
                LDY #$01
                JSR LINER
                LDY #$00
                JSR TEXTER
                JSR MOVE212
                LDA #$40
                STA PAGE
                LDA #$04
                STA MAXTEXT
                JSR INPUT2
; TODO: should only allow correct password if Ruuik has actually provided it
                LDX #$03
CCOMP           LDA TEXTBUF,X
                CMP CRUU,X
                BNE FCRUU
                DEX
                BPL CCOMP
                JSR CLRBOX
                LDY #$01
                JSR TEXTER
                LDY #$06
                JSR WAITER
RUUIAIR         LDA DIRHOLD
                STA DIRECTN
                LDA #$20
                STA PAGE
                JSR CLEAR1
                LDA #WHITE1
                STA COLOR
                JSR TRANSER
                JSR GETNSEW
                JSR NOSCAN
                STA PRIMARY
                LDA #$77
                STA SSTOREH
                LDA #$16
                STA STRACK
                LDA #$07
                STA SSECTOR
                LDA #$12
                STA READNUM
                JMP SREAD

FCRUU           LDX #$03
FCOMP           LDA FUCK,X
                CMP TEXTBUF,X
                BNE ATTACOM
                DEX
                BPL FCOMP
                JSR CLRBOX
                LDY #$03
                JSR TEXTER
                LDY #$08
                JSR WAITER
ATTACOM         JSR CLRBOX
                LDY #$02
                JSR TEXTER
                JSR FSCREEN
                JSR PREFITE
                JMP SREADIT

CRUU            DFB $C3,$D2,$D5
                DFB $D5
FUCK            DFB $C6,$D5,$C3
                DFB $CB
OLINE           DFB $00,$3B,$3D
                DFB $00,$DB,$3D
                DFB $00,$DB,$54
                DFB $00,$3B,$54
                DFB $00,$3B,$3D
                DFB $FF

; TODO: should only do this the first couple of times alien is encountered

AIRSWIM         STA DRIVOFF
                JSR CLEAR1
                LDA #$20
                STA PAGE
                LDA #ORANGE
                STA COLOR
                LDY #$02
                JSR LINER
                JSR MODIFY
                JSR MOVE212
                LDA #$40
                STA PAGE
                LDA #$00
                STA WAITER+1
                LDA ALIEN1
                CMP #$02
                BEQ NOHINT
                LDA #$C0
                STA WAITER+1
NOHINT          LDY #$07
                JSR TEXTER
                LDY #$01
                JSR WAITER
                LDY #$08
                JSR TEXTER
                LDY #$01
                JSR WAITER
                LDY #$09
                JSR TEXTER
                LDY #$01
                JSR WAITER
                LDY #$0A
                JSR TEXTER
                LDA #$00
                STA WAITER+1
                STA MAXTEXT
                JSR INPUT2
REKEYER         LDA TEXTBUF
                CMP #$D9
                BEQ DOATTAK
                CMP #$CE
                BEQ NOATTAK
                CMP #$8D
                BNE NORETIN
                JSR CHAROUT
NORETIN         JSR RECALL
                JMP REKEYER

RECALL          LDA HOLDIT
                PHA
                JMP KEYREAD

NOATTAK         JSR CHAROUT
                JSR CLRBOX
                LDY #$0A
                JSR TEXTER
                LDA ALIEN1
                CMP #$02
                BEQ NOLIAR
                LDY #$0B
                JSR TEXTER
                LDY #$02
                JSR WAITER
                LDY #$0C
                JSR TEXTER
                LDY #$01
                JSR WAITER
                LDY #$0D
                JSR TEXTER
                LDY #$04
                JSR WAITER
                JMP RUUIAIR

NOLIAR          LDY #$0E
                JSR TEXTER
                LDA #$69
                STA CHRSPRD
                LDA #$FF
                BNE COLIAR
DOATTAK         JSR CHAROUT
                JSR CLRBOX
                LDY #$0A
                JSR TEXTER
                LDA ALIEN1
                CMP #$02
                BEQ DOLIAR
                LDY #$0F
                JSR TEXTER
LIARNOC         LDA #$FF
                STA CHRSPRD
COLIAR          STA MONSPRD
                JSR FSCREEN
                JSR PREFITE
                JMP SREADIT
DOLIAR          LDY #$10
                JSR TEXTER
                JMP LIARNOC

MODIFY          LDA #$26
                STA CLRBOX+1
                LDA #$45
                STA CLRMOD+1
                LDA #$23
                STA MOVE212+1
                LDA #$48
                STA MOVEMOD+1
                RTS

OLINE2          DFB $00,$3B,$25
                DFB $00,$DB,$25
                DFB $00,$DB,$45
                DFB $00,$3B,$45
                DFB $00,$3B,$25
                DFB $FF

CLRBOX          LDX #$3E
CLOOP1          LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                ORA #$40
                STA SCREENH
                LDY #$09
                LDA #$00
CLOOP2          STA (SCREENL),Y
                INY
                CPY #$1F
                BNE CLOOP2
                INX
CLRMOD          CPX #$54
                BNE CLOOP1
                RTS

TRANSER         LDA #$04
                STA COUNT
TRLOOPA         LDA COUNT
                ORA #$A0
                STA TMOD1A+2
                STA TMOD1B+2
                LDA COUNT
                CLC
                ADC #$9B
                STA TMOD2A+2
                STA TMOD2B+2
                LDX #$00
TMOD1A          LDA $A000,X
                TAY
TMOD2A          LDA $9B00,X
TMOD1B          STA $A000,X
                TYA
TMOD2B          STA $9B00,X
                INX
                BNE TMOD1A
                DEC COUNT
                BPL TRLOOPA
                RTS

MOVE212         LDA #$3B
                STA LINENUM
MLOOP1          LDX LINENUM
                LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                ORA #$20
                STA SCREENH
                EOR #$60
                STA DESTINH
                LDY #$08
MLOOP2          LDA (SCREENL),Y
                TAX
                LDA (DESTINL),Y
                STA (SCREENL),Y
                TXA
                STA (DESTINL),Y
                INY
                CPY #$20
                BNE MLOOP2
                INC LINENUM
                LDA LINENUM
MOVEMOD         CMP #$57
                BNE MLOOP1
                RTS

WAITER          LDA #$00
                JSR WAIT2
                BNE WAITEND
                DEY
                BPL WAITER
WAITEND         BIT UNSTROB
                RTS

TEXT0           DB  $09,$05,$41
                (STATE_THE_ROYAL_PASSWORD)
                DB  $0A,$04,$4A
                (OR_BE_DESTROYED:_)+
TEXT1           DB  $0D,$01,$45
                (LONG_LIVE_RUUIK!)+
TEXT2           DB  $10,$04,$45
                (ATTACK!!)+
TEXT3           DB  $09,$05,$41
                (WE_WOULD_NEVER_REPRODUCE)
                DB  $09,$05,$4A
                (WITH_YOUR_INFERIOR_RACE!)+
TEXT7           DB  $09,$05,$29
                (PLEASE_DON,$28,T_ATTACK_ME.)+
TEXT8           DB  $09,$05,$32
                (I'M_HARMLESS.)+
TEXT9           DB  $15,$05,$32
                (_I_WOULD)
                DB  $09,$05,$3B
                (NEVER_HURT_ANYONE.)+
TEXTA           DB  $0D,$03,$B4
                (ATTACK_<Y/N>?_)+
TEXTB           DB  $09,$05,$2D
                (OH_THANK_YOU_SO_MUCH!!!)+
TEXTC           DB  $09,$05,$37
                (THANK_YOU.)+
TEXTD           DB  $14,$00,$37
                (THANK_YOU.)+
TEXTE           DB  $0B,$06,$32
                (SO_I_LIED_A_LITTLE.)+
TEXTF           DB  $0F,$02,$32
                (YOU_MEANIE.)+
TEXT10          DB  $09,$05,$32
                (I_DON'T_LIKE_YOU_AT_ALL.)+
