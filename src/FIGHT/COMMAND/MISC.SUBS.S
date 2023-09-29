
SELECT_CHAR     STA WHICH_CDEF
                LDX #<WHICH_CDEF
                LDY #>WHICH_CDEF
                JSR MENU_INIT
                JSR SET_INTERCEPT
                JSR CHAR_CURSOR2
                JMP MENU_SELECT2

*-------------------------------

WHICH_CDEF      DB  $FF                 ; modified
                DB  $00
                DW  :WHICH_CURS

:WHICH_CURS     BCS :SKIPA
                JMP CHAR_CURSOR1
:SKIPA          JMP CHAR_CURSOR2

*-------------------------------

SBOTTOMR        LDA #$00
                BEQ BOTTOM_COM      ;Always
BOTTOMR         LDA #$FF
BOTTOM_COM      STA BOTTOUT+1
                JSR DRAW_PICT
                PictSetGreen
                PictMoveTo $5F;$A3
                PictLineTo $10F;$A3
                PictSetTextHeight 8
                PictTextAt_ 102;166
                TXC "HAND/S:\n"
                TXC "WEAPON:\n"
                TXT "ENERGY:"
                PictMoveTo 150;166
                PictEnd
                LDA CURHOLD
                JSR DRAW_HAND
                LDX USEDLOC
                LDA HANDTAB,X
                BNE PUTE2
                JSR DRAW_PICT
                PictTextAt 150;174;"<BARE_HAND>______<1>"
                PictEnd
                JMP BOTTOUT

PUTE2           LDX USEDLOC
                JSR ONE_EQLINE
                LDX #$96
                LDY #$AE
                JSR DRAW_TEXTBUF_XY
                JSR PARSTAT
                LDX #$FC
                LDY #$AE
                JSR DRAW_TEXTBUF_XY

BOTTOUT         LDA #$FF            ;Modified
                BMI :SKIPA
                STA ENERGY_USAGE
                STA ENERGY_USAGE+1
                STA ENERGY_USAGE+2
                STA PERWHAT
                BPL :SKIPB          ;Always
:SKIPA          JSR ENERGY2
:SKIPB          LDX #$96
                LDY #$B6
                JSR MOVE_TO
                LDA #TextEmpty
                JMP DRAW_ENERGY_PER

*-------------------------------

SET_LEGALS      LDX #15
                LDA #$FF
:LOOP1          STA LEGALS,X
                DEX
                BPL :LOOP1
                RTS

*-------------------------------

ANDUP           LDX #$05
                LDA #$FF
:1              AND LEGALS,X
                DEX
                BPL :1
                TAX
                RTS

*-------------------------------

; main box, excluding notch, if last 3 pixel columns must be cleared
;   PictFillRect 91;128;276;182

CLEAR_WCANCEL   JSR DRAW_PICT
                PictClear 13;128;39;183
                PictClear 13;183;33;191
                PictEnd
                RTS

CLEAR_WTIME     JSR DRAW_PICT
                PictClear 13;128;39;183
                PictClear 13;183;37;191
                PictEnd
                RTS

CLEAR_CANCEL_IN JSR CLEAR_WTIME
                JSR DOTIME
                ; fall through
CANCEL_IN       JSR DRAW_PICT
                PictSetBlack1
                PictMoveTo $E8;$BF
                PictLineTo $105;$BF
                PictLineTo $105;$B8
                PictTextAt 235;185;"C>ANCEL"
                PictSetGreen
                PictMoveTo $E7;$BE
                PictLineTo $E7;$B7
                PictLineTo $104;$B7
                PictEnd
                RTS

CANCEL_OUT      JSR DRAW_PICT
                PictSetBlack1
                PictMoveTo $E7;$BE
                PictLineTo $E7;$B7
                PictLineTo $104;$B7
                PictTextAt 235;185;"C>ANCEL"
                PictSetGreen
                PictMoveTo $E8;$BF
                PictLineTo $105;$BF
                PictLineTo $105;$B8
                PictEnd
                RTS

*-------------------------------

SPACE_WAIT      BIT UNSTROB
:LOOP1          LDA KEYBRD
                BPL :LOOP1
                BIT UNSTROB
                JSR CHECK_ENTER
                BEQ :EXIT
                ; TODO: CHECK_CANCEL?
                CMP #"C"
                BNE :LOOP1
                CLC
:EXIT           RTS
