
BEAM_INDEX      =   $C0
BEAM_DIR        =   $C1
BEAM_PTR        =   $C2
BEAM_PTR_H      =   $C3

; 12 bytes wide x 94 lines
;   1128 bytes (0x468)
;       * 6 frames == 0x1A70
;   22 line repeat -- over crystals
;   13 line repeat -- above table
;   29 line repeat -- table base
; 12 bytes width x 33 unique lines
;   396 bytes (0x18C)
;       * 6 frames == 0x948

; left:   100
;   4 spots (0-3)
; center: 108
;   4 spots (4-7)
; right:  116
; width:   17 (8 spots)

; left:   100
;   20? spots
; center: 140
;   20? spots
; right:  180
; width:   81 (40 spots)


; full width
; X1: 100
; X2: 180
; W: 81

; center
; X1: 140
; X2: 142
; W: 3

; ring top (inside)
; Y: 172 (-4)
; ring center
; Y: 176
; ring bottom
; Y: 181 (+5)

; full size of beams
; PictClear 14;88;26;182
; 12 bytes * 94 lines = 1128 bytes
                ; lda (screenl),y         ; 5+
                ; ora $ffff,x             ; 4+
                ; sta (screenl),y         ; 6
                ; inx                     ; 2
                ; iny                     ; 2
                                        ; 19 * 1128 bytes = 21432 cycles
                                        ;   ~ 46fps

DO_SAND         JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictImage PEDESTAL_TOP
                PictImage PEDESTAL_BASE
                PictImage SAND_BAG
                PictEnd

                JSR DRAW_PICT
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                LDA #1
                STA BEAM_DIR
                LDX #0
:1              STX BEAM_INDEX
                JSR DRAW_BEAMS
                LDA #$80
                JSR WAIT
                LDX BEAM_INDEX
                LDA BEAM_DIR
                BEQ :2
                INX
                CPX #4
                BNE :1
                LDX #2
                DEC BEAM_DIR
                BEQ :1                  ; always

:2              DEX
                BPL :1
                LDX #1
                INC BEAM_DIR
                BNE :1                  ; always

                SEC
                RTS

beamLeftCol     =   14
beamRightCol    =   26

DRAW_BEAMS      TXA
                ASL
                TAX
                LDA BEAM_PTRS+0,X
                STA BEAM_PTR
                LDA BEAM_PTRS+1,X
                STA BEAM_PTR_H
                LDX #88                 ;*** constant
:1              LDA LOBYTES,X
                STA DESTINL
                STA SCREENL
                LDA HIBYTES,X
                STA DESTINH
                EOR #$60
                STA SCREENH
                LDY #beamLeftCol
:2              LDA (BEAM_PTR),Y
                ORA (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY #beamRightCol
                BNE :2
                INX
                CPX #177                ;*** constant
                BNE :1

                TXA
                TAY
                LDX #0
:3              STY LINENUM
                LDA LOBYTES,Y
                STA DESTINL
                STA SCREENL
                LDA HIBYTES,Y
                STA DESTINH
                EOR #$60
                STA SCREENH
                LDY #beamLeftCol
:4              LDA (BEAM_PTR),Y
                AND BEAM_FRONT_MASKS,X
                ORA (SCREENL),Y
                STA (DESTINL),Y
                INX
                INY
                CPY #beamRightCol
                BNE :4
                LDY LINENUM
                INY
                CPY #182                ;*** constant
                BNE :3
                RTS

BEAM_PTRS       DW  BEAM_DATA+0-beamLeftCol
                DW  BEAM_DATA+12-beamLeftCol
                DW  BEAM_DATA+24-beamLeftCol
                DW  BEAM_DATA+36-beamLeftCol

BEAM_DATA       HEX D4A2D0A0C18AD4A0858A94A8
                HEX D48A94A8D08295A8C18285AA
                HEX D482858AD4A085AAD0A0C1AA
                HEX D4A0C18295A8C18A94A890AA

BEAM_BACK_MASKS
                HEX FFFFFFFFFF8FC0FFFFFFFFFF    ; 168

                HEX FFFFFFFF9F8080F8FFFFFFFF    ; 169
                HEX FFFFFF808080808080FEFFFF    ; 170
                HEX FFBF8080808080808080FCFF    ; 171
                HEX FF838080808080808080C0FF    ; 172
                HEX 9F80808080808080808080F8    ; 173
                ; HEX 8780808080808080808080E0    ; *** NOT NEEDED

BEAM_FRONT_MASKS
                ; HEX FCFFFFFFFFFFFFFFFFFFFFBF    ; *** NOT NEEDED
                ; HEX F8FFFFFFFFFFFFFFFFFFFF9F    ; *** NOT NEEDED

                HEX E0FFFFFFFFFFFFFFFFFFFF87    ; 177
                HEX 00FCFFFFFFFFFFFFFFFFBF00    ; 178
                HEX 00C0FFFFFFFFFFFFFFFF8000    ; 179
                HEX 000080FFFFFFFFFFFF810000    ; 180
                HEX 00000000E0FFFF8700000000    ; 181

PEDESTAL_TOP    DB  $0B,$14,$12,$62
                HEX F8802095C0F24054558D11448B10BCF0282A910822084250
                HEX 52104093B0EE50558D154411202A890A22683E2E3E6822AE
                HEX EE2A91220842558945117C5F150535373431303020A23F82
                HEX 805410100440108210821040824082408240B04040824010
                HEX 1340100404401401A70637802A8D08627F2A0077B5375767
                HEX 674707956604802A862A0202822808088220898402820208
                HEX 820882088220898420208220080882280202822802842802
                HEX 84280284802A91220897023A45117F55003E951E2C329572
                HEX 7391717070604000807F8255865586558655865501018250
                HEX 050101401586550184558655865586540184540186805591
                HEX 9F0B3C7A2F0A404757991777897B797801A184807F822A86
                HEX 2A862A862A862A862A862A862A862A862A862A02862A8180
                HEX 842A88802A910822558D970C420F2F9D373A38A130208A80
                HEX 7F8255865586558655865586558655865586558655865540
                HEX 8655818084558880559111442A8D08BF0B44375747950791
                HEX 0400807F822A862A862A862A862A860A20840228862A862A
                HEX 862A862A862A8180842A88802A912208558D115F75500078
                HEX 7A91620E2E892F916F897678897060401F82805586554040
                HEX 821510108205040482014101401001110110010489010104
                HEX 04010410100114404001144084154084154084AF0F368022
                HEX 971241717589355589545799505E5D5951418D401E82802A
                HEX 08082002088208820882080282028202B002028202084802
                HEX 082020022882800A2A8D289F153B477F5400383A3A3B3B47
                HEX 6F894F0FB96702EA810182559144114297173E3F7A282627
                HEX 773707890301A4EEA718360555895144177D757D174401AC
                HEX EE0015558D54114410420A4A08029300AEF2022A9108228B
                HEX 0800BAF601058D0405C0
                DB  $FF

PEDESTAL_BASE   DB  $0D,$83,$0E,$38
                HEX D280405050545450504410504088D0287A5E7676161E7A2A
                HEX 28022A2886865070C240753F6B7E1F0084011F7555005555
                HEX 84842A2A2B7EC06A7F557F3F8C3F6A2A002A2A820054558D
                HEX 7F0040B8547F2A7F7F907F55401555402A952F78020820B4
                HEX 7A5F757F0F900F7A97063355997F0011448B108B408B00B3
                HEX 4F970C1B0F4A0F970D20006040867F9704322A997F002208
                HEX A30A080AA94A0A8D4A8D0A911A0F867F970A3455997F0044
                HEX 1104010001A27F885F7A2F7F6090705F970C34022A917F00
                HEX 0A00B62A7F557F7F907F2A02282A02820555897D07BE577E
                HEX 2B7F788C7C579710348284022A3E03C0022F7D577F708640
                HEX 7E2B970E340082CE01155F7A6F6C68785F55154154150184
                HEX D2020A0A2A2A0A0A22080A0288
                DB  $FF

SAND_BAG        DB  $11,$7F,$07,$0A
                HEX 8A801415558982505454555554002A2A2A99005555820155
                HEX 0564452464502A84000250575F6D575D88022B2A2E6A2A8A
                HEX 055575557D
                DB  $FF
