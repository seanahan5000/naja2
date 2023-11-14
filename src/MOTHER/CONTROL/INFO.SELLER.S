
; TODO: there is way too much text per panel -- split them up

INFO_SELLER     JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictImage INFO_PIC
                PictClear $04;$1B;$24;$50
                PictSetOrange
                PictRect $1F;$1C;$F9;$4E
                PictTextAt 36;32;"OOPS! EXCUSE ME! HEY, WOULD A FINE,"
                PictTextAt 36;41;"INTELLIGENT GROUP LIKE YOU WITH"
                PictTextAt 36;50;"SUCH WEALTH AND EXPERIENCE BE"
                PictTextAt 36;59;"INTERESTED IN A LITTLE BUSINESS"
                PictTextAt 36;68;"PROPOSITION? "
                PictShowPage
                PictEnd

                JSR YES_OR_NO
                BCC NOTINT
                JMP ISINT

NOTINT          JSR DRAW_PICT
                PictClear $05;$1D;$23;$4D
                PictTextAt 36;32;"YOU ARE GOING TO REGRET THAT"
                PictTextAt 36;41;"DECISION FOR THE REST OF YOUR"
                PictTextAt 36;50;"SERVICE.  GOOD LUCK, YOU'RE"
                PictTextAt 36;59;"GOING TO NEED IT!"
                PictEnd
                JMP INFO_OUT

ISINT           JSR DRAW_PICT
                PictClear $05;$1D;$23;$4D
                PictTextAt 36;30;"YOU ARE? GOOD! BUT FIRST, YOU MUST"
                PictTextAt 36;38;"PROMISE NOT TO DISCUSS OUR LITTLE"
                PictTextAt 36;46;"TRANSACTION WITH ANYONE.  YOU SEE,"
                PictTextAt 36;54;"THE TACTICAL FORCE AND I DON'T SEE"
                PictTextAt 36;62;"EYE-TO-EYES ON THE TOPIC OF FREE-"
                PictTextAt 36;70;"LANCERS.  DO I HAVE YOUR WORD? "
                PictEnd

                JSR YES_OR_NO
                BCS HASWORD

NOWORD          JSR DRAW_PICT
                PictClear $05;$1D;$23;$4D
                PictTextAt 36;50;"THEN I'M WASTING MY TIME. GOOD BYE."
                PictEnd
                JMP INFO_OUT

HASWORD         JSR DRAW_PICT
                PictClear $05;$1D;$23;$4D
                PictTextAt 36;32;"THEN LET'S GET DOWN TO BUSINESS."
                PictTextAt 36;41;"OH, BY THE WAY, SINCE I'VE CORNERED"
                PictTextAt 36;50;"THE ENTIRE MARKET OF INFORMATION"
                PictTextAt 36;59;"SELLING, I HAVE NO REASON TO HAGGLE"
                PictTextAt 36;68;"OVER PRICES."
                PictEnd

                JSR SPACE_INOUT

                JSR DRAW_PICT
                PictClear $05;$1D;$23;$4D
                PictTextAt 36;30;"I HAVE THESE DATA CARDS:"
                PictEnd
*WRITE DATA CARDS ON SCREEN
                JSR DRAW_PICT
                PictTextAt 36;70;"ANY OF THEM LOOK INTERESTING? "
                PictEnd

                JSR YES_OR_NO
                BCS DOWANT
                JMP RETUNNEL

DOWANT
*ADD MAXIMUM NUMBER TO SENTENCE
                JSR DRAW_PICT
                PictClear $05;$46;$23;$4D
                PictTextAt 36;70;"WHICH ONE <1-N>? "
                PictEnd

                LDA #1
                JSR GET_NUMBER_LIMIT
GETIN4          LDA TEXTBUF
                CMP #$8D
                BEQ RETUNNEL
                CMP #1
                BCS ISBIGNF
*CHECK AGAINST MAXIMUM NUMBER
                CMP #$9B                ;*** Escape
                BEQ RETUNNEL
                JSR REGET_INPUT
                JMP GETIN4

ISBIGNF
*MOVE DATA TO POSS. AND LOWER CREDITS, STORE ON DISK
* SAVE ORB STATUS DATA IF NECESSARY

RETUNNEL        JSR DRAW_PICT
                PictClear $05;$1D;$23;$4D
                PictTextAt 36;50;"REMEMBER... NOT A WORD TO ANYONE."
                PictEnd

INFO_OUT        JSR SPACE_IN
                JSR SPACE_WAIT

                JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall DRAW_HALL
                PictShowPage
                PictEnd
                SEC
                RTS

*-------------------------------

YES_OR_NO       BIT UNSTROB
                JSR GET_INPUT_KEY
:1              CMP #"Y"
                BEQ :2
                CMP #"N"
                CLC
                BEQ :2
                JSR REGET_INPUT
                JMP :1
:2              RTS

*-------------------------------

SPACE_WAIT      BIT UNSTROB
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB
                JSR CHECK_ENTER
                BNE :1
                RTS

SPACE_IN        JSR DRAW_PICT
                PictClear 29;71;36;79
                PictSetOrange
                PictMoveTo $C9;$4E
                PictLineTo $C9;$46
                PictLineTo $F9;$46
                PictTextAt 206;72;"<SPACE>"
                PictEnd
                RTS

SPACE_INOUT     JSR SPACE_IN
                JSR SPACE_WAIT

                JSR DRAW_PICT
                PictSetBlack1
                PictFillRect 201;70;248;78
                PictSetOrange
                PictMoveTo $C9;$4E
                PictLineTo $F9;$4E
                PictLineTo $F9;$46
                PictEnd
                RTS

*-------------------------------

INFO_PIC        DB  $0B,$5C,$12,$61
                HEX FEB44060208AFEAA40404C5E732182788AFE830280808A40
                HEX 406066333158586C6C36361B1B0D0D06060203898AE24091
                HEX 5091549155158D050507060603030101A688424251515014
                HEX 8D50894040A220289D2A910A0A2A8D0A8D02898840607078
                HEX 54505040AE826070787A7A3A7870608A020A2A2A2828209C
                HEX 018D058915155595548997080E8240602028286A7B2F2E6E
                HEX 3F0E429C404081C0A11F7F89716E5B6E717F1F8205151414
                HEX 0450514515970A3150404096289D22220A2AA149537F5D5F
                HEX 5D890F2128822A2B2E2C38301018484C0466620379398280
                HEX 2A2A76932A2A848001032B89232186202028282A97083982
                HEX 970A0F91288D209928298D2E2E6B3F2F2E2E3979697D6C6F
                HEX 3B3F2E7A7A6A2A8A5595847F03827F01827F848055556E93
                HEX 55558C970A268D8001899001970A2A9D05012005558D5789
                HEX 777D7D575F777755557D5777775D5D7F757F8C2A95840F0E
                HEX 820F0E820F0E82802A2A5D932A2AB0970E0D970C2D802297
                HEX 0E1B2001282A2A2E2B8D6E3A7A6B7F6E2E6F7F6B6B2A7F6A
                HEX 3A3A2E7F408A555597101A847F07827F07827F0782805555
                HEX 3B935555AA80505455959706438901A105050D0D1D1D2525
                HEX 272B2989272F277D7D75897F40882A2A1555526A40401F1C
                HEX 823F38827F6082802A2A77932A2AA8802A99029E97063454
                HEX 545599151505393A2F2A7F2A2A6A3A7040821525292A0A84
                HEX 0101030206040C09191080151516931515A8800115559154
                HEX 408C9709232AA10A0A2289208C0101074F5F455151155465
                HEX 716140ACAE029F0831970E2084019D05911591A70A2E5289
                HEX 42408903060B0202AEB8010165971A30970C1650408E9F06
                HEX 331414048902910A951A1E36366C6C58583030606040409A
                HEX CA02971832971825970939B20101030306060D0D1B1B1656
                HEX 742C0C7C8AC497162F45455189148180D203070C1830218A
                HEX C80291F0
                DB  $FF

*-------------------------------
