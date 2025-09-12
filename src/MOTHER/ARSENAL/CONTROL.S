; TEMP            =   LOCAL_TEMP+0        ; +1

; POINTL          =   LOCAL_TEMP+2
; POINTH          =   LOCAL_TEMP+3

; LINENUM         =   $00
; COUNTER         =   $01
FACTOR          =   $02
; SCRATCH         =   $06
BEGLINE         =   $0A
ENDLINE         =   $0B

ZBLOCK_A0       =   $A0
WANTED1         =   ZBLOCK_A0+0
ON1             =   ZBLOCK_A0+1
ON2             =   ZBLOCK_A0+2
DISPLAY         =   ZBLOCK_A0+3
CURRENT         =   ZBLOCK_A0+4
CURSPNT         =   ZBLOCK_A0+5
MAXCURS         =   ZBLOCK_A0+6
CHUNK           =   ZBLOCK_A0+7

ZBLOCK_A8       =   $A8
WHOPIC          =   ZBLOCK_A8+0
*
LEAVLIN         =   ZBLOCK_A8+2
DSPLACE         =   LEAVLIN
CTABCNT         =   ZBLOCK_A8+3
SOURCE          =   ZBLOCK_A8+4
BRNCURS         =   ZBLOCK_A8+5     ;+6,+7
CLSCURS         =   BRNCURS+1
YNOCURS         =   BRNCURS+2

ZBLOCK_80       =   $80
LINUMB          =   ZBLOCK_80+0
LINECNT         =   ZBLOCK_80+1
*
*
NUMBIN          =   ZBLOCK_80+4
TABLCNT         =   ZBLOCK_80+5
DRAWFLG         =   ZBLOCK_80+6
ELECT           =   ZBLOCK_80+7

ZBLOCK_88       =   $88
PHYSIC          =   ZBLOCK_88+0     ;+1
MASK            =   ZBLOCK_80+2
APOINTER        =   ZBLOCK_80+3
THELEGL         =   ZBLOCK_80+4
STATUS          =   ZBLOCK_80+5
*
STOCK_OFF       =   ZBLOCK_80+7

; enter with page 1 visible

ARSENAL         JSR UNPACK_STOCK

                BIT UNSTROB
                LDA #$00
                STA ON1
                STA ON2
                STA CURRENT
                STA SOURCE
                LDA #$01
                STA DISPLAY
                STA WANTED1

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_STATS_BOX
                PictEnd
                JSR DRAW_SCREEN

                LDA #$0A
                STA ON1
MAIN_LOOP       LDA WANTED1
                CMP #$05
                BCC :1
                CMP #$09
                BCS :1
                JSR MARKIT
:1              LDA WANTED1
                CMP #$02
                BNE :2
                JSR RESET_CHRLIST
                LDA #0
                STA LEGALS+7
:2              LDX DISPLAY
                DEX
                LDA WANTED1
                CMP #$02
                BNE :3
                LDA #$00
:3              STA ON1,X
                LDY WANTED1
                DEY
                LDA MAXOPTS,Y
                STA MAXCURS
                LDA WANTED1
                CMP CURRENT
                BCC ATBOTM
                LDA #$00
                STA CURSOR
                BEQ GOTMAX
ATBOTM          LDA MAXCURS
                STA CURSOR
                DEC CURSOR
GOTMAX          LDA WANTED1
                STA CURRENT
                CMP #$01
                BNE NOTMAIN
                LDA SOURCE
                STA CURSOR
NOTMAIN         LDA WANTED1
                CMP #$04
                BCS NOMAIN
                CMP #$02
                BCC NOMAIN
MAINER          LDY CURSOR
                LDA LEGALS,Y
                BEQ NOMAIN
                INC CURSOR
                BNE MAINER
NOMAIN          JSR CURSITA
ABLINK          LDA #$10
                JSR WAIT
                LDA #$F0
                JSR WAIT_KEY
                BMI AKEYGOT
                JSR CURSITA
                LDA #$00
                JSR WAIT_KEY
                JSR CURSITA
ARKEY           BIT KEYBRD
                BPL ABLINK
AKEYGOT         LDA KEYBRD
                BIT UNSTROB
                JSR CHECK_CANCEL
                BEQ GETOUT
                JSR CHECK_UP
                BEQ GOUP1
                JSR CHECK_DOWN
                BEQ GODOWN1
                JSR CHECK_ENTER
                BEQ ENTERIT
                BIT UNSTROB
                JMP ARKEY

GETOUT          JSR CURSITA
                JSR DEMARK
                LDX WANTED1
                DEX
                BEQ :1
                LDA #$01
                STA WANTED1
                JSR DRAW_SCREEN
                JMP MAIN_LOOP
:1              JMP LEAVE_ARSENAL

GOUP1           JSR CURSITA
GOUP1A          LDA CURSOR
                BNE NOTATOP
                LDA MAXCURS
                STA CURSOR
                DEC CURSOR
                JMP UPCOM
NOTATOP         DEC CURSOR
UPCOM           LDA CURRENT
                CMP #$04
                BCS NOTHER
                CMP #$02
                BCC NOTHER
                LDY CURSOR
                LDA LEGALS,Y
                BNE GOUP1A
NOTHER          JSR CURSITA
                BIT UNSTROB
                JMP ARKEY

GODOWN1         JSR CURSITA
GODWN1B         INC CURSOR
                LDA CURSOR
                CMP MAXCURS
                BNE NOTBOT
                LDA #$00
                STA CURSOR
NOTBOT          LDA CURRENT
                CMP #$04
                BCS NOTHER1
                CMP #$02
                BCC NOTHER1
                LDY CURSOR
                LDA LEGALS,Y
                BNE GODWN1B
NOTHER1         JSR CURSITA
                JMP ARKEY

ENTERIT         JSR CURSITA
                JSR DEMARK
                LDA CURRENT
                CMP #$01
                BNE NOTA22
                LDX CURSOR
                STX SOURCE
NOTA22          CMP #$04
                BCS USUAL
                LDY CURSOR
                CMP #$02
                BNE USUAL
                STY WHOPIC
USUAL           LDY CURRENT
                DEY
                LDA DESTOFF,Y
                CLC
                ADC CURSOR
                TAX
                LDA DESTDAT,X
                BEQ LEAVE_ARSENAL
                CMP #$FE
                BNE :1
                LDA #$05
                LDX SOURCE
                BEQ :1
                LDA #$04
:1              STA WANTED1
                JSR DRAW_SCREEN
                LDA WANTED1
                CMP #$0F
                BCS :2
                CMP #$0A
                BCC :4
                CMP #$0D
                BCS :3
:2              JMP BUY_EQUIPMENT
:3              JMP BUY_ARMHELM
:4              JMP MAIN_LOOP

LEAVE_ARSENAL   LDA PAGE
                CMP #$40
                BEQ :1
                JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictShowPage
                PictSetPage1
                PictEnd
:1              JMP PACK_STOCK

DEMARK          LDA WANTED1
                CMP #$05
                BCC :1
                CMP #$09
                BCC MARKIT
:1              RTS

MARKIT          LDX WHOPIC
                LDY AYPOINTS,X
                LDX #6
                JMP DRAW_MARKER

DESTOFF         DB  0,DEST2-DESTDAT,DEST3-DESTDAT
                DB  DEST4-DESTDAT,DEST5-DESTDAT,DEST6-DESTDAT
                DB  DEST7-DESTDAT,DEST8-DESTDAT

DESTDAT         DB  $02,$02,$02
                DB  $02,$00
DEST2           DB  $FE,$FE,$FE
                DB  $FE,$FE,$FE
                DB  $FE,$01
DEST3
DEST4           DB  $09,$09,$09
                DB  $09,$09,$09
                DB  $09,$01
DEST5           DB  $06,$07,$08
                DB  $01
DEST6           DB  $0A,$0B,$0C
                DB  $05
DEST7           DB  $0D,$0F,$0E
                DB  $10,$11,$05
DEST8           DB  $12,$13,$14
                DB  $05

;-----------------------------------------------------------

; $0: out of stock but visible
; $1-$D: count in stock
; $E: unlimited in stock
; $F: not visible
;
; If first two common items are not in stock
;   fill stock with defaults.
;
UNPACK_STOCK    LDA EQUIP_STOCK+0
                BNE :1
                LDX #0
:0              LDA DEFAULT_STOCK,X
                STA EQUIP_STOCK,X
                INX
                CPX #36
                BNE :0
:1              LDX #0
                LDY #0
:2              LDA EQUIP_STOCK,X
                PHA
                LSR
                LSR
                LSR
                LSR
                JSR :WRITE
                PLA
                AND #$0F
                JSR :WRITE
                INX
                CPX #36
                BNE :2
                RTS

:WRITE          CMP #$0F
                BNE :3
                LDA #-1
                BNE :4                  ; always
:3              CMP #$0E
                BNE :4
                LDA #$7F
:4              STA USTOCK_BUFFER,Y
                INY
                RTS

PACK_STOCK      LDY #0
                LDX #0
:1              JSR :READ
                LSR
                LSR
                LSR
                LSR
                STA TEMP
                JSR :READ
                ORA TEMP
                STA EQUIP_STOCK,X
                INX
                CPX #36
                BNE :1
                RTS

:READ           LDA USTOCK_BUFFER,Y
                BPL :2
                LDA #$0F
                BNE :4                  ; always
:2              CMP #$7F
                BNE :3
                LDA #$0E
                BNE :4                  ; always
:3              CMP #$0E
                BCC :4
                LDA #$0D
:4              INY
                RTS

DEFAULT_STOCK
            DO 1 ; debug defaults
                DB  $EE,$14,$1F         ; PISTOL_STOCK
                DB  $E8,$1E             ; RIFLE_STOCK
                DB  $0E                 ; CANNON_STOCK
                DB  $EE,$81,$EE,$EF     ; BEAM_STOCK
                DB  $EE,$21,$EE         ; MWEAPON_STOCK
                DB  $83,$EE,$EF         ; ATTACH_STOCK
                DB  $5E,$E6             ; MARMOR_STOCK
                DB  $EE,$71,$E1,$E1     ; MEDIC_STOCK
                DB  $8E,$EE,$EE
                DB  $E1,$EE,$EE         ; SCANNER_STOCK
                DB  $EE,$EF             ; MISC_STOCK
                DB  $E8,$61,$EE,$EE     ; SHIELD_STOCK
                DB  $EE,$EE
            ELSE ; real defaults
                DB  $EE,$0F,$FF             ; PISTOL_STOCK
                DB  $E8,$0F                 ; RIFLE_STOCK
                DB  $FF                     ; CANNON_STOCK
                DB  $EE,$80,$FF,$FF         ; BEAM_STOCK
                DB  $FF,$FF,$29             ; MWEAPON_STOCK   ;9 means ??
                DB  $83,$FF,$FF             ; ATTACH_STOCK
                DB  $62,$FF                 ; MARMOR_STOCK
                DB  $EE,$7F,$0F,$F0         ; MEDICAL_STOCK   ;9 means ??
                DB  $89,$99,$9F
                DB  $E0,$FF,$FF             ; SCANNER_STOCK
                DB  $EF,$FF                 ; MISC_STOCK
                DB  $E8,$61,$FF,$FF,$FF,$FF ; SHIELD_STOCK
            FIN

;-----------------------------------------------------------
