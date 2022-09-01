EXAMINE         JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictSetGreen
                PictRect $B9;00;$115;$BF
                PictTextAt 214;95;(LEAVE)
                PictEnd

                JSR SETVTAB
                JSR ESCAN_FULSLOT

                LDX #0
:1              STX COUNT
                LDA EQUIP_LIST,X
                BNE :2

                LDY LINTABL,X
                JSR VMOVE_TO

                LDY CORESPS,X
                JSR ENERUSE

                JSR PARSTAT
                LDX #165
                JSR DRAW_TEXTBUF_X

                LDX #196
                JSR HMOVE_TO
                LDA #TextSpace
                JSR DRAW_ENERGY_PER

:2              LDX COUNT
                INX
                CPX #15
                BNE :1

                JSR DRAW_PICT
                PictSetPage2
                PictSwap $17;$00;$28;$BF
                PictEnd

                BIT UNSTROB

                LDX #<:EXAM_DEF
                LDY #>:EXAM_DEF
                JSR MENU_INIT
                JSR MENU_SELECT

                JSR DRAW_PICT
                PictSwap $17;$BF;$28;$00
                PictEnd
                RTS

*-------------------------------
:EXAM_DEF       DB  $81
                DB  $00
                DW  :EXAM_CURS

:EXAM_CURS      LDX #$C8
                LDY #$5F
                JMP DRAW_ARROW
*-------------------------------
