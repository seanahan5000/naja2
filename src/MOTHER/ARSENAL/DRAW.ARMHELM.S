DRAW_ARMHELM    JSR DRAW_PICT
                PictClearPage
                PictCall DRAW_NPE
                PictSetBlue
                PictRect $46;$00;$D4;$1B
                PictSetGreen
                PictRect $A1;$29;$F7;$4f
                PictRect $13;$21;$103;$9D
                PictTextAt 90;2;"ENERGY USE:"
                PictTextAt 120;11;"PRICE:"
                PictTextAt 78;19;"YOUR CREDITS:"
                PictTextAt 175;52;"PROTECTION"
                PictTextAt 187;60;"RATING"
                PictTextAt 166;70;"EL-  % PH-  %"
                PictTextAt 48;135;"BRAND"
                PictTextAt 126;135;"CLASS"
                PictTextAt 27;146;"<ELECTRICAL>  <PHYSICAL>"
                PictImage APICT0
                PictEnd

                LDA WANTED1
                CMP #$0D
                BNE DOHELM

                JSR DRAW_PICT
                PictTextAt 204;135;"SMART"
                PictTextAt 84;11;"ARMOR"
                PictTextAt 178;44;">>ARMOR<<"
                PictTextAt 184;70;"10     10"
                PictImage APICT1
                PictEnd

                LDA #$00
                STA BRNCURS
                STA BRNCURS+1
                STA BRNCURS+2
                STA MINTABL
                STA ELECT
                STA CLSCURS
                STA MINTABL+1
                STA PHYSIC
                LDA #$03
                STA YNOCURS
                STA MINTABL+2
                BNE AHCOMN              ; always

DOHELM          JSR DRAW_PICT
                PictTextAt 192;135;"WITH-SLOT"
                PictTextAt 78;11;"HELMET"
                PictTextAt 175;44;">>HELMET<<"
                PictTextAt 190;70;"4      1"
                PictTextAt 182;2;"NONE"
                PictEnd

                LDX #$03
:1              TXA
                STA BRNCURS-1,X
                STA MINTABL-1,X
                STA ELECT-1,X
                DEX
                BNE :1

AHCOMN          LDA #$02
                STA CURSPNT
:1              JSR DRAW_BIG_ARROW
                DEC CURSPNT
                BPL :1
                INC CURSPNT
                JSR DRAW_WHITE_BOX

                LDX #$9C
                LDY #$13
                JSR DRAW_GCREDITS_AT
                JSR AHPRICE
                LDX #$9C
                LDY #$0B
                JSR DRAW_PRICE_AT
                JSR CREATE_ITEM
                JSR DRAW_ENUSE
                JMP ISHERE

APICT0          DB  $05,$39,$08,$46     ; BENDMIR
                HEX 802889089928898C805489440489448954898C81D454AB80
                HEX 548C54894404894489548955891411111411111455898C80
                HEX 2A8928992A898C8305AA2AAA22A2932281AA2A802A8C2A89
                HEX 28992A892A8920222A282A22202A898C805589149955898C
                HEX 830CD555D511810181119111D55580558C97020099558955
                HEX 8950449555898C9702138022222822892A898C8306AA2AAA
                HEX 02A22280029F022D8C97023922222822892A899704000891
                HEX 9704098C80558940444440448955898C8308D555D504C444
                HEX C4048B81D55580558C9F0600970603558955890111514151
                HEX 110155898C802A89820828288208822A898C830CAA2AAA08
                HEX 880A8A088808AA2A802A8C2A89000891002A892A89022222
                HEX 029F06408C8055890111514151110155898C830CD555D550
                HEX D155D455D150D55580558C55894111114111895589058D04
                HEX 0405048905898C8102B18C028102AB028C02B1

                DB  $13,$4C,$02,$34     ; CBA
                HEX 545414A554548A8304D45494148B9F001381D4548A8303D4
                HEX D4948D970026912A2A28288C28282A2A8A83048A0AA8288B
                HEX 9F0213818A0A8A802A2A288D97022691

                DB  $1B,$5F,$07,$21     ; NOYES
                HEX C2787838AD8A38957878849702171F1F70AD8A70957F7F70
                HEX 8D7F7FB7020078788A9F06009F06137878970419A17F7F8A
                HEX 9708008407078497080AA6A7061984970A17A697081384A7
                HEX 0419
                DB  $FF

APICT1          DB  $05,$26,$08,$0D     ; CLEARWD
                HEX 28B1558901115189110155892A892295022A895589054545
                HEX 0545450455892A8908080A8908082A895589101111101189
                HEX 55892A892822222822892A8905B1

                DB  $13,$26,$02,$21     ; ED
                HEX 2A2A0A8D9F00002A2A8A802A2A0AA52A2A80151514148401
                HEX 0184141415158A80050514A50505
                DB  $FF
