;
;     Written: 2/12/1983
;   Rewritten: 11/8/2023
;

SORCLIN         =   $0B
LINSORC         =   $0C
; LEFTCOL         =   $10
; RITECOL         =   $11
TOCNT           =   $12
FROMCNT         =   $13

; *** MOVE THESE ***
CONTROL_MODULE  =   $7000
; SET_CONTROL     =   $7001
MAP_MODULE      =   $8000

                JMP TESS_TO_MOTHER

*-------------------------------
*
*-------------------------------

TESSERACT_PORT  JSR LOST_IN_GROUP
                BCS :2

                JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictImage TESSER_PIC
                PictCall FILL_TESPIC
                PictTextAt 64;17;"TESSERACT TO TRACC STATION"
                PictTextAt 64;27;"CANCEL"
                PictShowPage
                PictEnd

                LDX #<TESS_CDEF
                LDY #>TESS_CDEF
                JSR MENU_INIT

                ; flush any forward keystrokes from walking towards tesserport
                LDA KEYBRD
                BPL :1
                JSR CHECK_UP
                BNE :1
                BIT UNSTROB
:1              JSR MENU_SELECT
                BEQ TESS_TO_TRACC
                JSR DRAW_PICT
                PictSetPage1
                PictShowPage
                PictEnd
                SEC
:2              RTS

TESS_TO_TRACC   JSR DRAW_PICT
                PictClear 9;17;32;34    ; clear text message
                PictEnd

                ; clear expedition stats
                LDA #0
                LDX #3
:1              STA TOTAL_KILLS,X
                STA TOTAL_CREDITS,X
                STA TOTAL_EXP,X
                DEX
                BPL :1

                JSR SET_TO_LIMBO        ;Mark chars as "inlimbo"
                JSR SAVE_GAME
                JSR SET_TO_LIMBO        ;Restore real statuses

                LDA #side_T1
                JSR SET_DISK_SIDE

                LDA #fileControl17
                LDY #>CONTROL_MODULE
                JSR LOAD_FILE

                LDA #1
                STA SHELL
                JSR SET_CONTROL

                ; preload map code
                LDA #fileMap
                LDY #>MAP_MODULE
                JSR LOAD_FILE

; *** PICK A DESTINATION ***
                LDA #0
                STA MAP_FACE
;               LDA #0
                STA MAP_X
                LDA #4
                STA MAP_Y
                LDA #EAST
                STA MAP_DIR
                JSR COMPUTE_MAP_PTR

                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall GET_NSEW
                PictCall DRAW_HALL
                PictSetPage2
                PictCall SPRAY
                PictSetPage1
                PictShowPage
                PictEnd
                SEC
                RTS

*-------------------------------
*
*-------------------------------

; source hall on page 1 (visible)
; dest hall on page 2
; spray onto page 1 (current draw page)

SPRAY           LDX #0
                STX LEFTCOL
                INX
                STX SORCLIN
                LDA #$27
                STA RITECOL
                LDA #$BF
                STA LINSORC
:1              BIT KEYBRD
                BMI :2

                ; LDA LINSORC
                ; CMP #$A3
                ; BCS :11

                JSR LEFTIN
                JSR RIGHTIN
; :11
                JSR UPIN
                JSR DOWNIN
                LDA LINSORC
                CMP #$C0
                BCC :1
:2              BIT UNSTROB
                RTS

LEFTIN          LDA LEFTCOL
                CMP #$28
                BEQ :3
                LDX #2
:1              JSR LR_SUB
                LDY #1
:2              LDA (SCREENL),Y
                DEY
                STA (SCREENL),Y
                INY
                INY
                CPY #$28
                BNE :2
                LDY LEFTCOL
                LDA (DESTINL),Y
                LDY #$27
                STA (SCREENL),Y
                TXA
                CLC
                ADC #4
                TAX
                CPX #$C2
                BNE :1
                INC LEFTCOL
:3              RTS

RIGHTIN         LDX RITECOL
                INX
                BEQ :3
                LDX #0
:1              JSR LR_SUB
                LDY #$26
:2              LDA (SCREENL),Y
                INY
                STA (SCREENL),Y
                DEY
                DEY
                BPL :2
                LDY RITECOL
                LDA (DESTINL),Y
                LDY #$00
                STA (SCREENL),Y
                TXA
                CLC
                ADC #4
                TAX
                CPX #$C0
                BCC :1
                DEC RITECOL
:3              RTS

UPIN            LDA #1
                BNE :2                  ; always
:1              JSR UD_SUB
:2              STA TOCNT
                CLC
                ADC #4
                STA FROMCNT
                CMP #$C1
                BNE :1
                LDX SORCLIN
                TXA
                CLC
                ADC #4
                STA SORCLIN
                BCC END_SUB             ; always

DOWNIN          LDA #$BF
                BNE :2                  ; always
:1              JSR UD_SUB
:2              STA TOCNT
                SEC
                SBC #4
                STA FROMCNT
                BCS :1
                LDX LINSORC
                TXA
                SEC
                SBC #4
                STA LINSORC
                ; fall through

NewBlit         = 1
            do NewBlit
END_SUB         LDA SCREENL
                STA DESTINL
                LDA SCREENH
                STA DESTINH
                JSR SET_SOURCE_OFF
                JMP COPY_FULL_LINE

LR_SUB          JSR SET_SOURCE_LINE
                JMP SET_DEST_OFF

UD_SUB          LDX FROMCNT
                JSR SET_SOURCE_LINE
                LDX TOCNT
                JSR SET_DEST_LINE
                JSR COPY_FULL_LINE
                LDA FROMCNT
                RTS
            else
END_SUB         LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                ; ORA #$40
                EOR #$60
                STA DESTINH
                LDY #$27
:LOOP1          LDA (DESTINL),Y
                STA (SCREENL),Y
                DEY
                BPL :LOOP1
                RTS

LR_SUB          LDA LOBYTES,X
                STA SCREENL
                STA DESTINL
                LDA HIBYTES,X
                ; ORA #$20
                STA SCREENH
                EOR #$60
                STA DESTINH
                RTS

UD_SUB          LDX FROMCNT
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                ; ORA #$20
                STA SCREENH
                LDX TOCNT
                LDA LOBYTES,X
                STA DESTINL
                LDA HIBYTES,X
                ; ORA #$20
                STA DESTINH
                JSR LINMOVE
                LDA FROMCNT
                RTS

LINMOVE         LDY	#$27
:1              LDA	(SCREENL),Y
                STA	(DESTINL),Y
                DEY
                BPL	:1
                RTS
            fin

*============================================
* On Entry:
;   Assume the primary page is displayed,
;   Mothership control has been loaded but not set.
;
* Character statuses signify the following:
*       Lost means lost
*    InTracc means in tracc but compressed
*  Compressd means in group but compressed
*
* There should never be Dead or Broken
*   characters in the group at this point.
*============================================

TESS_TO_MOTHER  LDA #0
                STA SHELL

; Update lost character count and remove
;   orbs, etc. from lost characters
                LDA #0
                STA COUNT
:LOOP2          JSR SET_CHAR
                LDY #status
                LDA (CHARDL),Y
                CMP #intracc
                BNE :SKIPB
                INC LOST_CHARS
:SKIPB          CMP #lost
                BNE :SKIPC
*** RECOVER ORBS, ETC. FROM THIS CHARACTER
:SKIPC          INC COUNT
                LDA COUNT
                CMP GRPCONT             ; NOTE: GRPCONT not GRPNUMB
                BNE :LOOP2

                LDA #0
                STA MAP_FACE
                LDA #6
                STA RANGE
                JSR SET_CONTROL

                LDA GRPNUMB
                BNE GROUP_ALIVE
;
; If no one left in group, send them back
;   to the main (enrollment) transport
;
GROUP_DEAD      LDA GRPCONT
                STA GRPNUMB
                JSR SAVE_GAME
                LDA #0
                STA GRPNUMB

                LDY #3                  ; enrollment tranport
                JSR SET_TRANS_DEST

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictShowPage
                PictEnd

                JSR TRANS_NOISE
                SEC
                RTS

GROUP_ALIVE     JSR FIRST_CHAR
:1              LDY #status         ;Remove rundown status
                LDA (CHARDL),Y
                BPL :2
                AND #%01111111
                STA (CHARDL),Y
                LDY #energylev+1
                LDA #1
                STA (CHARDL),Y
                LDY #status
                LDA (CHARDL),Y
:2              ASL
                BPL :3
                LSR
                AND #%00111111      ;Remove critical status
                STA (CHARDL),Y
                LDY #damagemax+1
                SEC
                SED
                LDA (CHARDL),Y
                SBC #critical_amnt+1
                LDY #damagelev+1
                STA (CHARDL),Y
                LDY #damagemax
                LDA (CHARDL),Y
                SBC #0
                LDY #damagelev
                STA (CHARDL),Y
                CLD
:3              LDY #status         ;Remove auto-cure statuses
                LDA (CHARDL),Y
                LDX #0              ;# OF STATUSES - 1 (FILL IN LATER)
:4              CMP AUTO_CURES,X
                BNE :5
                LDA #healthy
                STA (CHARDL),Y
                BCS :6                  ; always
:5              DEX
                BPL :4
:6              JSR CALC_ALL
                JSR NEXT_CHAR
                BCC :1

                LDA GRPNUMB
                PHA
                LDA GRPCONT
                STA GRPNUMB
                JSR SAVE_GAME
                PLA
                STA GRPNUMB

                LDY #4                  ; tesback destination
                JSR SET_TRANS_DEST
                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictSetPage1
                PictCall SPRAY
                PictShowPage2
                PictCopyToPage
                PictShowPage
                PictEnd
                SEC
                RTS

AUTO_CURES      DB  bleeding        ;????
** etc.

*-------------------------------

SET_TO_LIMBO    JSR FIRST_CHAR
:1              LDY #status
                LDA (CHARDL),Y
                PHA
                LDY #flaglimbo
                LDA (CHARDL),Y
                LDY #status
                STA (CHARDL),Y
                PLA
                LDY #flaglimbo
                STA (CHARDL),Y
                JSR NEXT_CHAR
                BCC :1
                RTS

*-------------------------------

TESS_CDEF       DB  $82
                DB  $00
                DW  :TESS_CURS

:TESS_CURS      LDY :YPNTS,X
                LDX #$32
                JMP DRAW_ARROW

:YPNTS          DB  $11,$1B

*-------------------------------

; *** use something other than TEMP,TEMP+1 ***

FILL_TESPIC     LDA #9
                STA TEMP+1
:LOOP1          LDY TEMP+1
                LDA LCOUNTS,Y
                STA TEMP
                LDX LHEIGHTS,Y
:LOOP2          LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDY #7
:LOOP3          LDA #$55
                STA (SCREENL),Y
                INY
                LDA #$2A
                STA (SCREENL),Y
                INY
                CPY #33
                BNE :LOOP3
                INX
                DEC TEMP
                BNE :LOOP2
                DEC TEMP+1
                BPL :LOOP1
                RTS

LCOUNTS         DB  1,3,5,7,9,9,7,5,3,1
LHEIGHTS        DB  49,58,67,76,85,112,123,134,145,156

*-------------------------------

            do 1
TESSER_PIC      DB  $05,$31,$02,$6C
                HEX 559054898C5091884099A67FA840998850918C548990552A
                HEX 902A898C2A91882A99842AA18228997F289D822AA1842A99
                HEX 882A918C2A89902A

                DB  $07,$5F,$1A,$10
                HEX 55997F559D2A997F2A9DC70000C70200014101917F019D82
                HEX 7F1899789582827330917030709582823F8A1F8201913F82
                HEX 827E06917E8C7E82826760916706956782827F8A7F60957F
                HEX 82827C0C917C0C3C917C82824F40914740954F82827F4191
                HEX 7F4147958282619D679582827F60917F82039582827C0C99
                HEX 3C917C82824F4CAD4F8282BF1A018282710199079582827F
                HEX 06991E958220997F209DC70400C70600C72C00C72E00

                DB  $21,$31,$02,$6C
                HEX 559055898C55918855998415A18205997F059D8215A18455
                HEX 998855918C558990552A900A898C0291BC7FBE02918C0A89
                HEX 902A
                DB  $FF
            else
TESSER_PIC      DB  $05,$31,$1E,$6C
                HEX 559054898C5091884099D040998850918C548990552A902A
                HEX 898C2A91882A99842AA182289982289D822AA1842A99882A
                HEX 918C2A89902A559055898C55918855998455A18255998255
                HEX 9D8255A18455998855918C558990552A902A898C2A91882A
                HEX 99842AA1822A99822A9D822AA1842A99882A918C2A89902A
                HEX 559055898C55918855998455A182559982559D8255A18455
                HEX 998855918C558990552A902A898C2A91882A99842AA1822A
                HEX 99822A9D822AA1842A99882A918C2A89902A559055898C55
                HEX 918855998455A1820141019182019D8255A1845599885591
                HEX 8C558990552A902A898C2A91882A99842AA1847F18997895
                HEX 842AA1842A99882A918C2A89902A559055898C5591885599
                HEX 8455A184733091703070958455A18455998855918C558990
                HEX 552A902A898C2A91882A99842AA1843F8A1F8201913F842A
                HEX A1842A99882A918C2A89902A559055898C55918855998455
                HEX A1847E06917E8C7E8455A18455998855918C558990552A90
                HEX 2A898C2A91882A99842AA18467609167069567842AA1842A
                HEX 99882A918C2A89902A559055898C55918855998455A1847F
                HEX 8A7F60957F8455A18455998855918C558990552A902A898C
                HEX 2A91882A99842AA1847C0C917C0C3C917C842AA1842A9988
                HEX 2A918C2A89902A559055898C55918855998455A1844F4091
                HEX 4740954F8455A18455998855918C558990552A902A898C2A
                HEX 91882A99842AA1847F41917F414795842AA1842A99882A91
                HEX 8C2A89902A559055898C55918855998455A184619D679584
                HEX 55A18455998855918C558990552A902A898C2A91882A9984
                HEX 2AA1847F60917F820395842AA1842A99882A918C2A89902A
                HEX 559055898C55918855998455A1847C0C993C917C8455A184
                HEX 55998855918C558990552A902A898C2A91882A99842AA184
                HEX 4F4CAD4F842AA1842A99882A918C2A89902A559055898C55
                HEX 918855998455A184BF1E2F8455A18455998855918C558990
                HEX 552A902A898C2A91882A99842AA1847101990795842AA184
                HEX 2A99882A918C2A89902A559055898C55918855998455A184
                HEX 7F06991E958455A18455998855918C558990552A902A898C
                HEX 2A91882A99842AA182209982209D822AA1842A99882A918C
                HEX 2A89902A559055898C55918855998455A182559982559D82
                HEX 55A18455998855918C558990552A902A898C2A91882A9984
                HEX 2AA1822A99822A9D822AA1842A99882A918C2A89902A5590
                HEX 55898C55918855998455A182559982559D8255A184559988
                HEX 55918C558990552A902A898C2A91882A99842AA1822A9982
                HEX 2A9D822AA1842A99882A918C2A89902A559055898C559188
                HEX 55998415A182059982059D8215A18455998855918C558990
                HEX 552A900A898C0291FC02918C0A89902A
                DB  $FF
            fin
