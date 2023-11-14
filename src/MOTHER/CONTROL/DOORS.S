
DOOR_SIGN       PHA
                JSR UPDATE_HALL
                PLA
                PHA
                ASL
                TAX
                LDA :SIGNS+0,X
                STA :MOD+1
                LDA :SIGNS+1,X
                STA :MOD+2
:MOD            JSR $FFFF
                PLA
                CMP #9                  ; restricted
                BNE :2
:1              LDA KEYBRD
                BPL :1
                JSR CHECK_TURN
                BEQ :2
                BIT UNSTROB
                JMP :1
:2              SEC
                RTS

:SIGNS          DW  :ENROLLMENT
                DW  :ASSEMBLY
                DW  :INFIRMARY
                DW  :ENERGY
                DW  :ARSENAL
                DW  :ROBOTS
                DW  :ENTRANCE
                DW  :EXIT
                DW  :TESSERPORT
                DW  :RESTRICTED

:ENROLLMENT     JSR DRAW_PICT
                PictSetBlue
                PictRect $64;$37;$B2;$4C
                PictTextAt 110;58;"ENROLLMENT"
                PictTextAt 107;67;"AND TESTING"
                PictEnd
                RTS

:ASSEMBLY       JSR DRAW_PICT
                PictSetBlue
                PictRect $46;$37;$D0;$4C
                PictTextAt 77;58;"GROUP ASSEMBLY OFFICE"
                PictTextAt 92;67;"<TREPR E. LELVK>"
                PictEnd
                RTS

:INFIRMARY      JSR DRAW_PICT
                PictSetOrange
                PictRect $6B;$3B;$AB;$47
                PictTextAt 113;62;"INFIRMARY"
                PictEnd
                RTS

:ENERGY         JSR DRAW_PICT
                PictSetViolet
                PictRect $60;$32;$B6;$50
                PictTextAt 122;53;"ENERGY"
                PictTextAt 104;62;"DISTRIBUTION"
                PictTextAt 122;71;"CENTER"
                PictEnd
                RTS

:ARSENAL        JSR DRAW_PICT
                PictSetViolet
                PictRect $70;$3B;$A6;$47
                PictTextAt 119;62;"ARSENAL"
                PictEnd
                RTS

:ROBOTS         JSR DRAW_PICT
                PictSetViolet
                PictRect $4E;$37;$C8;$4C
                PictTextAt 86;58;"ROBOT ORDERING AND"
                PictTextAt 86;67;"REPLACEMENT CENTER"
                PictEnd
                RTS

:ENTRANCE       JSR DRAW_PICT
                PictTextAt 116;12;"ENTRANCE"
                PictEnd
                RTS

:EXIT           JSR DRAW_PICT
                PictTextAt 128;12;"EXIT"
                PictEnd
                RTS

:TESSERPORT     JSR DRAW_PICT
                PictSetGreen
                PictRect $67;$3B;$AF;$47
                PictTextAt 110;62;"TESSERPORT"
                PictEnd
                RTS

:RESTRICTED     JSR DRAW_PICT
                PictSetOrange
                PictRect $4F;$30;$C7;$52
                PictRect $51;$30;$C5;$52
                PictTextAt 89;53;"-RESTRICTED AREA-"
                PictTextAt 110;63;"AUTHORIZED"
                PictTextAt 98;71;"PERSONNEL ONLY"
                PictEnd
                RTS
