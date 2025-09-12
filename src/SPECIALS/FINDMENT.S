*------------------------------*
*                              *
*        Find Equipment        *
*                              *
*   Written:  3/8/1987         *
* Rewritten: 10/27/2022        *
*                              *
*------------------------------*

; TODO: maybe build as a module of camp?

; TODO: make part of equipment constants?
Sword           =   0
Pistol          =   1
Rifle           =   2
Helmet          =   3
DCard           =   4
Shield          =   5
Cmpres          =   6
RSword          =   7
RBlast          =   8
CompCube        =   9

All             =   %00111111           ; TODO: AllFaces

; randomly choose equipment
NORMAL_FIND     JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictEnd
                JSR PICNPUT
; equipment number in A
FORCE_FIND      ASL
                TAY
                LDX PICKS,Y
                LDA PICKS+1,Y
                TAY
                JSR UNPACK
; equipment already drawn on page 2
SPECIAL_FIND    JSR DRAW_PICT
                PictShowPage
                PictSetPage1
                PictClearPage
                PictCall DRAW_STATS_BOX
                PictSetBlack1
                PictMoveTo $02;$44
                PictLineTo $38;$44
                PictSetGreen
                PictMoveTo $01;$44
                PictLineTo $01;$4C
                PictLineTo $39;$4C
                PictMoveTo $39;$44
                PictLineTo $39;$56
                PictLineTo $115;$56
                PictLineTo $115;$44
                PictEnd

                JSR ETABLE_TO_TEXT

                ; change "AN" TO "A" when necessary
                LDA TEXTBUF
                LDX #$04
GRLOOP2         CMP VOWELS,X
                BEQ ANOKAY
                DEX
                BPL GRLOOP2
                LDA #TextEmpty
                STA NOAMOD

ANOKAY          JSR DRAW_PICT
                PictTextAt $10;$44;(NOBODY)
                ; TODO: fix this awkward wording
                PictTextAt $3F;$4E;(WHOM_DO_YOU_WANT_TO_GIVE_IT_TO?)
                PictTextAt $3F;$46;(YOU_HAVE_FOUND_A)-
NOAMOD          TXT "N_"
                PictEnd

                JSR ETABLE_TO_TEXT
                LDA #TextPeriod
                STA TEXTBUF,X
                LDA #TextLineEnd
                STA TEXTBUF+1,X
                JSR DRAW_TEXTBUF

                JSR SET_PAGE2
                JSR FLIPPER
                JSR RESET_CHRLIST
                JSR CSCAN_PUTABLE
                LDA #$00
                STA CHAR_LIST+7
                BIT UNSTROB
                LDX #<:FIND_DEF
                LDY #>:FIND_DEF
                JSR MENU_INIT
                JSR MENU_SELECT
                CPX #$07
                BEQ :SKIPA
                TXA
                JSR SET_CHAR
                JSR RESET_EQLIST
                JSR ESCAN_PUTABLE
                LDA CORESPS,X
                TAY
                LDX #$00
:LOOP1          LDA ETABLE,X
                STA (CHARDL),Y
                INY
                INX
                CPX #$04
                BNE :LOOP1
                JSR CALC_ALL
                LDA ETABLE+1
                CMP #$F3            ;Must be $F3 in data tables
                BNE :SKIPA
                DEC LOST_CHARS
:SKIPA          JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall DRAW_HALL
                PictShowPage
                PictEnd
                SEC
                RTS                     ; back to halls

*-------------------------------
:FIND_DEF       DB  $08
                DB  $00
                DW  :FIND_CURS

:FIND_CURS      LDY FYPOINTS,X
                LDX #3
                JMP DRAW_ARROW

FYPOINTS        DB  $0C,$14,$1C
                DB  $24,$2C,$34
                DB  $3C,$44
*-------------------------------

VOWELS          TXC "AEIOU"

POINTL          =   LOCAL_TEMP+0
POINTH          =   LOCAL_TEMP+1
ETEMP           =   LOCAL_TEMP+2

PICNPUT         LDY SHELL
                LDA GROUPS_LOW-1,Y
                STA POINTL
                LDA GROUPS_HIGH-1,Y
                STA POINTH
:LOOP1          JSR RANDOM
                AND #$0F                ; currently hard-wired to 16 items
                ASL
                STA ETEMP
                ASL
;               CLC
                ADC ETEMP
                TAY
                LDA (POINTL),Y      ;Face flag byte
                LDX FACE
                AND FAMASKS-1,X
                BEQ :LOOP1
                INY
                LDA (POINTL),Y
                CMP #CompCube
                BNE :SKIPA
                LDX LOST_CHARS
                BEQ :LOOP1
:SKIPA          PHA
                LDX #$00
:LOOP2          INY
                LDA (POINTL),Y
                STA ETABLE,X
                INX
                CPX #$04
                BNE :LOOP2
                PLA
                RTS

FAMASKS         DB  %00100000       ;Face 1
                DB  %00010000       ;     2
                DB  %00001000       ;     3
                DB  %00000100       ;     4
                DB  %00000010       ;     5
                DB  %00000001       ;     6

FLIPPER         LDA #$00
                STA COLUMN
                STA LINENUM
FLOOP0          LDY COLUMN
                LDX LINENUM
FLOOP1          LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                STA SCREENH
                EOR #$60
                STA DESTINH
                LDA (SCREENL),Y
                PHA
                LDA (DESTINL),Y
                STA (SCREENL),Y
                PLA
                STA (DESTINL),Y
                INX
                CPY #$08
                BCS FSKIP1
                CPX #$4E
                BEQ FSKIP2
FSKIP1          CPX #$58
                BEQ FSKIP2
                DEY
                BMI FSKIP2
                CPY #$08
                BCS FLOOP1
                CPX #$4E
                BCC FLOOP1
FSKIP2          LDA COLUMN
                CMP #$27
                BNE FSKIP4
                LDA LINENUM
                CMP #$57
                BEQ FOUT
                INC LINENUM
                BNE FLOOP0
FSKIP4          INC COLUMN
                BNE FLOOP0
FOUT            RTS

;-------------------------------------------------------------------------------
; Faces byte, Picture number, equipment data (4 bytes)
; 44 pieces of equipment per group is maximum
;
; TODO: turn these tables to shells -- just place holders now
; TODO: Add compressed person to data tables
;
; TODO: move this information to level-specific files

GROUPS_LOW      DB  <GROUP17
                DB  <GROUP15
                DB  <GROUP13
                DB  <GROUP11
                DB  <GROUP9

GROUPS_HIGH     DB  >GROUP17
                DB  >GROUP15
                DB  >GROUP13
                DB  >GROUP11
                DB  >GROUP9

GROUP17         DB  $3F,Sword,$08,$00,$00,$AD       ; BLUE BEAM DAGGER
                DB  $3F,Pistol,$0C,$00,$00,$A7      ; FLY PISTOL
                DB  $3F,Pistol,$0C,$01,$00,$A5      ; LIGHT PISTOL
                DB  $3F,Pistol,$0C,$02,$08,$A1      ; MEDIUM PISTOL
                DB  $3F,Helmet,$05,$00,$00,$DF      ; BENDER-C HELMET
                DB  $3F,Helmet,$05,$01,$80,$DF      ; BENDER-B HELMET
                DB  $3F,Shield,$06,$01,$00,$A6      ; 5% SHIELD
                DB  $3F,Shield,$06,$02,$00,$A6      ; 10% SHIELD
                DB  $3F,Cmpres,$21,$03,$00,$50      ; ATOM COMPRESSOR
                DB  $3F,RSword,$18,$00,$00,$20      ; ROBO-DAGGER
;               DB $3F,RBlast,$1C,$00,$00,$20       ; ROBO-BLASTER C
;               DB $3F,RBlast,$1C,$01,$00,$20       ; ROBO-BLASTER B
;               DB $3F,RBlast,$1C,$02,$00,$20       ; ROBO-BLASTER A
                DB  $3F,CompCube,$43,$F3,$10,$00    ; COMPRESSED PERSON
                DB  $3F,CompCube,$43,$F3,$10,$00    ; COMPRESSED PERSON
                DB  $3F,CompCube,$43,$F3,$10,$00    ; COMPRESSED PERSON
                DB  $3F,DCard,$03,$14,$00,$DF       ; DATA CARD B2
                DB  $3F,DCard,$03,$1C,$00,$DF       ; DATA CARD B3
                DB  $3F,DCard,$03,$24,$00,$DF       ; DATA CARD B4

GROUP15         DB  All,Sword,$08,$00,$00,$AD       ; BLUE BEAM DAGGER
                DB  All,Pistol,$0C,$00,$00,$A7      ; FLY PISTOL
                DB  All,Pistol,$0C,$01,$00,$A5      ; LIGHT PISTOL
                DB  All,Pistol,$0C,$02,$08,$A1      ; MEDIUM PISTOL
                DB  All,Helmet,$05,$00,$00,$DF      ; BENDER-C HELMET
                DB  All,Helmet,$05,$01,$80,$DF      ; BENDER-B HELMET
                DB  All,Shield,$06,$01,$00,$A6      ; 5% SHIELD
                DB  All,Shield,$06,$02,$00,$A6      ; 10% SHIELD
                DB  All,Cmpres,$21,$03,$00,$50      ; ATOM COMPRESSOR
                DB  All,RSword,$18,$00,$00,$20      ; ROBO-DAGGER
                DB  All,RBlast,$1C,$00,$00,$20      ; ROBO-BLASTER C
                DB  All,RBlast,$1C,$01,$00,$20      ; ROBO-BLASTER B
                DB  All,RBlast,$1C,$02,$00,$20      ; ROBO-BLASTER A
                DB  All,DCard,$03,$14,$00,$DF       ; DATA CARD B2
                DB  All,DCard,$03,$1C,$00,$DF       ; DATA CARD B3
                DB  All,DCard,$03,$24,$00,$DF       ; DATA CARD B4

GROUP13         DB  All,Sword,$08,$00,$00,$AD       ; BLUE BEAM DAGGER
                DB  All,Pistol,$0C,$00,$00,$A7      ; FLY PISTOL
                DB  All,Pistol,$0C,$01,$00,$A5      ; LIGHT PISTOL
                DB  All,Pistol,$0C,$02,$08,$A1      ; MEDIUM PISTOL
                DB  All,Helmet,$05,$00,$00,$DF      ; BENDER-C HELMET
                DB  All,Helmet,$05,$01,$80,$DF      ; BENDER-B HELMET
                DB  All,Shield,$06,$01,$00,$A6      ; 5% SHIELD
                DB  All,Shield,$06,$02,$00,$A6      ; 10% SHIELD
                DB  All,Cmpres,$21,$03,$00,$50      ; ATOM COMPRESSOR
                DB  All,RSword,$18,$00,$00,$20      ; ROBO-DAGGER
                DB  All,RBlast,$1C,$00,$00,$20      ; ROBO-BLASTER C
                DB  All,RBlast,$1C,$01,$00,$20      ; ROBO-BLASTER B
                DB  All,RBlast,$1C,$02,$00,$20      ; ROBO-BLASTER A
                DB  All,DCard,$03,$14,$00,$DF       ; DATA CARD B2
                DB  All,DCard,$03,$1C,$00,$DF       ; DATA CARD B3
                DB  All,DCard,$03,$24,$00,$DF       ; DATA CARD B4

GROUP11         DB  All,Sword,$08,$00,$00,$AD       ; BLUE BEAM DAGGER
                DB  All,Pistol,$0C,$00,$00,$A7      ; FLY PISTOL
                DB  All,Pistol,$0C,$01,$00,$A5      ; LIGHT PISTOL
                DB  All,Pistol,$0C,$02,$08,$A1      ; MEDIUM PISTOL
                DB  All,Helmet,$05,$00,$00,$DF      ; BENDER-C HELMET
                DB  All,Helmet,$05,$01,$80,$DF      ; BENDER-B HELMET
                DB  All,Shield,$06,$01,$00,$A6      ; 5% SHIELD
                DB  All,Shield,$06,$02,$00,$A6      ; 10% SHIELD
                DB  All,Cmpres,$21,$03,$00,$50      ; ATOM COMPRESSOR
                DB  All,RSword,$18,$00,$00,$20      ; ROBO-DAGGER
                DB  All,RBlast,$1C,$00,$00,$20      ; ROBO-BLASTER C
                DB  All,RBlast,$1C,$01,$00,$20      ; ROBO-BLASTER B
                DB  All,RBlast,$1C,$02,$00,$20      ; ROBO-BLASTER A
                DB  All,DCard,$03,$14,$00,$DF       ; DATA CARD B2
                DB  All,DCard,$03,$1C,$00,$DF       ; DATA CARD B3
                DB  All,DCard,$03,$24,$00,$DF       ; DATA CARD B4

GROUP9          DB  All,Sword,$08,$00,$00,$AD       ; BLUE BEAM DAGGER
                DB  All,Pistol,$0C,$00,$00,$A7      ; FLY PISTOL
                DB  All,Pistol,$0C,$01,$00,$A5      ; LIGHT PISTOL
                DB  All,Pistol,$0C,$02,$08,$A1      ; MEDIUM PISTOL
                DB  All,Helmet,$05,$00,$00,$DF      ; BENDER-C HELMET
                DB  All,Helmet,$05,$01,$80,$DF      ; BENDER-B HELMET
                DB  All,Shield,$06,$01,$00,$A6      ; 5% SHIELD
                DB  All,Shield,$06,$02,$00,$A6      ; 10% SHIELD
                DB  All,Cmpres,$21,$03,$00,$50      ; ATOM COMPRESSOR
                DB  All,RSword,$18,$00,$00,$20      ; ROBO-DAGGER
                DB  All,RBlast,$1C,$00,$00,$20      ; ROBO-BLASTER C
                DB  All,RBlast,$1C,$01,$00,$20      ; ROBO-BLASTER B
                DB  All,RBlast,$1C,$02,$00,$20      ; ROBO-BLASTER A
                DB  All,DCard,$03,$14,$00,$DF       ; DATA CARD B2
                DB  All,DCard,$03,$1C,$00,$DF       ; DATA CARD B3
                DB  All,DCard,$03,$24,$00,$DF       ; DATA CARD B4

;-------------------------------------------------------------------------------

PICKS           DW  SWORD               ; 0
                DW  PISTOL              ; 1
                DW  RIFLE               ; 2
                DW  HELMET              ; 3
                DW  CARD                ; 4
                DW  SHIELD              ; 5
                DW  COMPRES             ; 6
                DW  RSWORD              ; 7
                DW  RBLASTR             ; 8
                DW  COMPCUBE            ; 9

SWORD           DB  $14,$B1,$05,$06
                HEX 8000608D00006D29556D000036552A3600091B4A551B0002
                HEX 018D02
                DB  $FF

PISTOL          DB  $12,$AE,$03,$10
                HEX 101028101050897050308B408492063A521E7E608296030D
                HEX 090F0E
                DB  $FF

RIFLE           DB  $0C,$B4,$10,$0C
                HEX 9040868278893C3C5E7F3F86825E896F6F7F7F888277897B
                HEX 7F7F8A823D3D7D7F7F038A82970404038640784081A05355
                HEX 55152424282A7F827F81D52A89155555150505030181A055
                HEX 5541555F5F8A8181027A02827E8860828250575050151420
                HEX 287E037E820A2A2A141589970E08845589018C8204544454
                HEX 048C8480022A028E860190
                DB  $FF

HELMET          DB  $13,$A3,$05,$1B
                HEX 8480004089505000501212522A2A0A727838897070606040
                HEX 00202A890A0A2A22204A49494A5555827F917E7E97021255
                HEX 01502429290A0A2A95022A0A292B077F9900000A25155050
                HEX 558D755D2D2D5D74555554505040550100008A000002890A
                HEX 0A0B8D0A8902890091
                DB  $FF

CARD            DB  $0F,$B7,$04,$07
                HEX 8660307828765B7E7F5B1F156D5F7837465E0A820103060D
                HEX 1F15
                DB  $FF

RSWORD          DB  $10,$B2,$07,$08
                HEX 8020408D200000006C29556C00890036353A360089555500
                HEX 1555550000027C4702008B0000306F3806063C3800950101
                DB  $FF

RBLASTR         DB  $0E,$B1,$06,$0F
                HEX 202D2D208000A900553B4000A9002A152A2000A52A2A002A
                HEX 3A3A303060400091012968692901000018371C03035E5C00
                HEX 020D0D0200A5
                DB  $FF

SHIELD          DB  $12,$B2,$07,$0D
                HEX 800040505404548D50400000202A890A0103910000558D00
                HEX 00286848084868282A8D000015171311131715558D000040
                HEX 558D1500009702019702002A0A00000000010504058D0100
                HEX 89
                DB  $FF

COMPRES         DB  $0D,$AB,$07,$15
                HEX 846030404C5652548254958250408428282A2A0A0A424250
                HEX 505482545050404082020A2801010202822A910A822A2A6E
                HEX 2A3A2A010182864050144451825455545105555557558682
                HEX 082222080A0284282802082A200A2A2A8686010515508405
                HEX 86404550555586920808028D8C
                DB  $FF

COMPCUBE        DB  $16,$AD,$04,$0F
                HEX 824040505054504820208A2A28220A2A0A4A225229512544
                HEX 10400105155582552AA38A02050A152A150A050201
                DB  $FF

;-------------------------------------------------------------------------------
