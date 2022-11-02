
DOOR_DONE       DB  $00                 ; TODO: move someplace else?

DOOR_SIGN       JSR CLEAR_PAGE
                JSR DRAW_HALL

                LDA DOOR_DONE
                BNE :TRANSLATE

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictSetOrange
                PictRect $39;$2F;$DB;$51
                PictRect $3B;$30;$D9;$50
                PictImage DOOR_WRITING
                PictSetPage1
                PictCopyTo 8;47;32;82
                PictEnd

                JSR FIRST_CHAR
:1              LDY #profrace
                LDA (CHARDL),Y
                AND #$F0
                CMP #android*16
                BEQ :GOT_ANDROID
                JSR NEXT_CHAR
                BCC :1
                JMP :KEYLOOP

:GOT_ANDROID    JSR DRAW_PICT
                PictTextAt $40;$7E;(DO_YOU_WANT_)
                PictCall DRAW_TRIMMED_NAME
                PictText (_TO)
                PictTextAt $40;$86;(TRANSLATE_THE_WRITING?_)
                PictEnd

                JSR GET_INPUT_KEY
:ASK_YN         CMP #"Y"
                BEQ :TRANSLATE
                CMP #"N"
                BEQ :NOTRANS
                JSR REGET_INPUT
                JMP :ASK_YN

:TRANSLATE      LDA #$FF
                STA DOOR_DONE

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictSetOrange
                PictRect $39;$2F;$DB;$51
                PictRect $3B;$30;$D9;$50
                PictTextAt $43;$34;(THIS_MARKS_THE_BORDER_OF)
                PictTextAt $4C;$3D;(EMPEROR_RUUIK'S_ROYAL)
                PictTextAt $7A;$46;(DOMAIN)
                PictSetPage1
                PictCopyTo 8;47;32;82
                PictEnd
                ; fall through

:NOTRANS        JSR DRAW_PICT
                PictClear 9;126;31;141
                PictEnd

:KEYLOOP        LDA KEYBRD
                BPL :KEYLOOP
                JSR CHECK_MOVE
                BEQ :HALLS
                BIT UNSTROB
                JMP :KEYLOOP

:HALLS          SEC
                RTS                     ; back to halls

DOOR_WRITING    DB  $0A,$34,$14,$18
                HEX 92068D1E1E920F0F4C8D860303438D920606676761618660
                HEX 60678D923333707030308630307070434392787879797878
                HEX 8A79790101920C95863C3C0C0C3C3C92060618181E1E861E
                HEX 95924F4F43434F4F860F0F43430F0F86404070704040678D
                HEX 61618666660101060686010197080B707073737070864343
                HEX 30303333860C95797961617979869708021818869F0C0084
                HEX 3C3C8A970A098A4C4C438D1E1E97000B8697180206068601
                HEX 954C4C4F4F4C4C864F4F0F0F4F4F92618D67678607079710
                HEX 0992971202737386707003034040929F1012867979606019
                HEX 19920C0C843C3C860C0C30303C3C921E958A181896920F95
                HEX 92
                DB  $FF

