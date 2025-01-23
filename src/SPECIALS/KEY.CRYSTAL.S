
frameByteWidth  =   6
frameHeight     =   26
frameBytes      =   frameByteWidth*frameHeight
frameCount      =   21
frameLeft       =   17
frameRight      =   frameLeft+frameByteWidth
frameTop        =   98
frameBottom     =   frameTop+frameHeight

FRAME_INDEX     =   $C0

DO_KEY_PEDESTAL
                ; TODO: check for cystal

:HAS_CRYSTAL    LDA RINGS_EXPANDED
                BNE :1
                JSR DRAW_PICT
                PictSetPage2
                PictImageFill RINGS
                PictCall EXPAND_RINGS
                PictEnd
                INC RINGS_EXPANDED
:1
                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictImage CRYSTAL
                PictEnd

                LDX #0
                JSR EOR_RING

                JSR DRAW_PICT
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

:2              LDX #1
:3              STX FRAME_INDEX
                JSR EOR_RING
                LDA #$60
                JSR WAIT_KEY
                BPL :4
                JSR CHECK_LEFT
                BEQ :5
                JSR CHECK_RIGHT
                BEQ :5
                JSR CHECK_DOWN
                BEQ :5
:4              BIT UNSTROB
                LDX FRAME_INDEX
                INX
                CPX #frameCount
                BNE :3
                BEQ :2                  ; always

:NO_CRYSTAL     JSR DRAW_PICT
                PictCall DRAW_HALL
                PictImage PEDESTAL
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd
:5              SEC
                RTS

RINGS_EXPANDED  DB  0

EXPAND_RINGS    JSR :EXPAND0
                LDX #<7*frameBytes+RING_BUFFER
                LDY #>7*frameBytes+RING_BUFFER
                LDA #6
                JSR :EXPAND
                LDX #<14*frameBytes+RING_BUFFER
                LDY #>14*frameBytes+RING_BUFFER
                LDA #12
:EXPAND         STX :MOD2+1
                STY :MOD2+2
                STA :MOD1+1
                CLC
                ADC #6
                STA :MOD3+1
:EXPAND0        LDX #0
                LDY #0
:1              STY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
:MOD1           LDY #0
:2              LDA (SCREENL),Y
:MOD2           STA RING_BUFFER,X
                INX
                INY
:MOD3           CPY #6
                BNE :2
                CPX #frameBytes
                BNE :3
                TXA
                CLC
                ADC :MOD2+1
                STA :MOD2+1
                LDX #0
                BCC :3
                INC :MOD2+2
:3              LDY LINENUM
                INY
                CPY #7*frameHeight
                BNE :1
                RTS

EOR_RING        TXA
                ASL
                TAX
                LDA FRAME_PTRS+0,X
                STA :MOD+1
                LDA FRAME_PTRS+1,X
                STA :MOD+2
                LDX #0
                LDY #frameTop
:1              STY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY #frameLeft
:MOD            LDA $FFFF,X
                EOR (SCREENL),Y
                STA (SCREENL),Y
                INX
                INY
                CPY #frameRight
                BNE :MOD
                LDY LINENUM
                INY
                CPY #frameBottom
                BNE :1
                RTS

FRAME_PTRS      DW  frameBytes*0+RING_BUFFER
                DW  frameBytes*1+RING_BUFFER
                DW  frameBytes*2+RING_BUFFER
                DW  frameBytes*3+RING_BUFFER
                DW  frameBytes*4+RING_BUFFER
                DW  frameBytes*5+RING_BUFFER
                DW  frameBytes*6+RING_BUFFER
                DW  frameBytes*7+RING_BUFFER
                DW  frameBytes*8+RING_BUFFER
                DW  frameBytes*9+RING_BUFFER
                DW  frameBytes*10+RING_BUFFER
                DW  frameBytes*11+RING_BUFFER
                DW  frameBytes*12+RING_BUFFER
                DW  frameBytes*13+RING_BUFFER
                DW  frameBytes*14+RING_BUFFER
                DW  frameBytes*15+RING_BUFFER
                DW  frameBytes*16+RING_BUFFER
                DW  frameBytes*17+RING_BUFFER
                DW  frameBytes*18+RING_BUFFER
                DW  frameBytes*19+RING_BUFFER
                DW  frameBytes*20+RING_BUFFER
                DW  frameBytes*21+RING_BUFFER

CRYSTAL         DB  $12,$64,$04,$13
                HEX 9610506040823F8418786889289D220B2F2C077084038D13
                HEX 1319191D1C1646505124551D98060607017A0182

PEDESTAL        DB  $11,$78,$06,$3E
                HEX 8A5555EE208D822A2A0820C43F9C8304D0D0D4D4558D8255
                HEX 5511442A805500548B00509705099F0410B70410CF041654
                HEX 522A2A802A8D822A2A220815802A000A8B00029707099F06
                HEX 10B70610CF06164A52555580018D8255550401E283048282
                HEX 8A8A8A2A2AEE
                DB  $FF

RINGS           DB  $00,$00,$12,$B6
                HEX 073860A8603807824410A8104482787F7E3860A060387E7F
                HEX 7801820D3E7C70409840707C3E0D8201060D82051A7E7860
                HEX 96787E1A05820D06780E731F820D3B63061C7088701C0682
                HEX 3B0D821F730E7884701C06633B0D82970098970082849701
                HEX 888484033E60A0601E03880C4118409C4068410C84013F6F
                HEX 7F7B5E7098705E0B5F4F1F011E4F6082031E731E70903082
                HEX 731E0382404F1E607088031F7F788C183F82038850401F3F
                HEX 0188010F78013F60600701180F8A011F1F603F01780F0188
                HEX 013F1F07070188010F58011F408803161098700E038E0114
                HEX 051298700E1C8C0701171303039A5F280A860F678601038B
                HEX 964028220A820F77608A0102039828220A70788E01038203
                HEX 039428207F780701A60A282A8E1C6090201A02981C6C2040
                HEX 8E204A08940C785C7040898E500A600F8C011F7C78408640
                HEX 4090607F150186031F6F708C40898E70451501827F031E70
                HEX A45014015501038E4084404094010190011F70887018A206
                HEX 200C4084408220069C071C773F7D7F606070703876040694
                HEX 010F3F7C7082013E1F1F308470043E0F018E97026E608601
                HEX 8E787F1F0286013F60031E704086603F7E7E30608640701E
                HEX 02603E827E3F608640701E03603F01013060821C82408660
                HEX 3E7E94010738380701A80208840802A401071F3F07073F1F
                HEX 07019E01060B0428303028040B069C030F0B1482170E0E17
                HEX 82140B820390030E1830333E14161B0F01010F1B16148233
                HEX 30180E0384970B8F3E970B9588030E18829F0B888A609700
                HEX 7B820D06060D82051A82786096970161820101820D3E7C82
                HEX 409C970149970134A41044844410A81044844410A4AF0C3C
                HEX 9C970D20820101820D3E7C82408C86787F1F03887060608A
                HEX 031F7F588E701E731E0382604F1E0607840382731E709470
                HEX 5E7B7F6F3F0101070F1F7B40709A4018410C880C2118409C
                HEX 970E55880C01589CA70E3A2F0F3F3B827094970F1E82604F
                HEX 1E0E0F840382731E8A82786706018C03898E010A2A288660
                HEX 07110701860303900F790A208C100717030301038E03380F
                HEX 78940615820190114898124514018E104270960303535751
                HEX 07880D705050926003018B82405057078407557040907E7D
                HEX 038A40409A015554827E7B0F844078409A05515486786F7C
                HEX 70587898023E45508A600C6C189802824E408C60086C1C96
                HEX 010862308C786F78705C780C900E590A60408A7E7B0F8440
                HEX 786C0C8A010F2E588E82018660970E038E1C8278608A1F3E
                HEX 0182707C3F0F01943E7C70843E1E607F7D3F771C0798061C
                HEX 743E7C7E6082400C2006A005200C408497144FA006220C40
                HEX 829F153498061C773C7C7C601F3E018297151E92053E7C70
                HEX 843C1C0E1782140B0F0398970A6E82170E970B5B019C9F0A
                HEX 55970B41A0970B3C820802A80208840802A8020882971734
                HEX A09717499F161A9C9F162E8A970D0582970C0B82051A8278
                HEX 608E9F009E82A700A5849701AF84971827829F008788701C
                HEX 06823B0D82971823060D8297016B96971806820D06018297
                HEX 015098970DA28201970D8FA0970D8A824410A81044828697
                HEX 1406887060602088031F0F08869F029C88013F1F0F2F0188
                HEX 010F08010F821F3F01889F03892F01380F8A010F0F607088
                HEX 97086B8C387F82038C1E4F6082970352907082731E03840F
                HEX 0E9F033498705E7B0F89018497021C9C4018110C84827863
                HEX 02018A505707075758947F7803018E508D9670788E010750
                HEX 5757500D940F77608A0116575084505D14940F6386010751
                HEX 575088505450039203010303174750408C40504338039001
                HEX 821506409440480D03887E7D038A606C06028401192F2090
                HEX 01038E6006026263011820929706828E0282010198970669
                HEX 8A02646262690198011F787840840C62668468390F9A0878
                HEX 58706C6C6088382F2E039A186C0C608C200E19028C820186
                HEX 9715058E1E0578608A7E3F6086A708A23960821E82408660
                HEX 3C7C9F09828697088C39608640701C82603C8897096B8601
                HEX 840188787E1C909709528297085838018270823E0E96A708
                HEX 3A7979307482069C9708228440082804900E178297160398
                HEX 97161382170EAF0B9C88030E18829F0BAF84C70A84829723
                HEX 209097221382970A7382140B82039AAF0B55A0AF0A3CA402
                HEX 0884080294
                DB  $FF

; ------------------------------------------------------------------------------

                DO 0

HIGH_FRAME      =   $C1
HIGH_DIR        =   $C2
LOW_FRAME       =   $C3
LOW_DIR         =   $C4

GENERATE        JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_HALL
                PictImage PEDESTAL
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                JSR DRAW_CRYSTAL
                LDX #0
                JSR CAPTURE_FRAME

                LDA #0
                STA HIGH_FRAME
                LDA #1
                STA HIGH_DIR
                LDA #10
                STA LOW_FRAME
                LDA #-1
                STA LOW_DIR
                LDA #0
                STA FRAME_INDEX

:1
                JSR DRAW_PICT
                PictClear 17;98;23;124
                PictEnd

                LDX HIGH_FRAME
                LDA HIGH_DIR
                BMI :12
                JSR DRAW_HIGH_RING_BOT
                JMP :13
:12             JSR DRAW_HIGH_RING_TOP
:13
                LDX LOW_FRAME
                LDA LOW_DIR
                BMI :14
                JSR DRAW_LOW_RING_BOT
                JMP :15
:14             JSR DRAW_LOW_RING_TOP
:15
                JSR DRAW_CRYSTAL

                LDX HIGH_FRAME
                LDA HIGH_DIR
                BMI :16
                JSR DRAW_HIGH_RING_TOP
                JMP :17
:16             JSR DRAW_HIGH_RING_BOT
:17
                LDX LOW_FRAME
                LDA LOW_DIR
                BMI :18
                JSR DRAW_LOW_RING_TOP
                JMP :19
:18             JSR DRAW_LOW_RING_BOT
:19
                LDA HIGH_FRAME
                CLC
                ADC HIGH_DIR
                BMI :2
                CMP #11
                BCC :3
                LDA #-1
                STA HIGH_DIR
                LDA #9
                BNE :3                  ; always
:2              LDA #1
                STA HIGH_DIR
:3              STA HIGH_FRAME

                LDA LOW_FRAME
                CLC
                ADC LOW_DIR
                BMI :22
                CMP #11
                BCC :33
                LDA #-1
                STA LOW_DIR
                LDA #9
                BNE :33                 ; always
:22             LDA #1
                STA LOW_DIR
:33             STA LOW_FRAME

                LDX FRAME_INDEX
                INX
                JSR CAPTURE_FRAME

                LDX FRAME_INDEX
                INX
                CPX #22
                BNE :44
                JSR DIFF_FRAMES
                JSR DRAW_ALL_FRAMES
                LDX #0
:44             STX FRAME_INDEX

                JMP :1

                JSR DRAW_PICT
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                SEC
                RTS

DRAW_CRYSTAL    LDX #0
                LDY #100
:1              STY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY #17
:2              LDA (SCREENL),Y
                AND CRYSTAL_MASK,X
                ORA CRYSTAL_BITS,X
                STA (SCREENL),Y
                INX
                INY
                CPY #23
                BNE :2
                LDY LINENUM
                INY
                CPY #124
                BNE :1
                RTS

                ;{"format": "hires","x":119,"y":100,"width":42,"height":24}
CRYSTAL_BITS    HEX 000018000000
                HEX 000078000000
                HEX 000068030000
                HEX 000068030000
                HEX 000068030000
                HEX 000028030000
                HEX 000028130000
                HEX 000028130000
                HEX 000028190000
                HEX 000028190000
                HEX 0000281D0000
                HEX 0010281C0000
                HEX 005028160600
                HEX 006022460600
                HEX 00400B500700
                HEX 00002F510100
                HEX 7F3F2C247A7F
                HEX 000007550100
                HEX 0000701D0000
                HEX 000000000000
                HEX 0020552A0100
                HEX 0020552A0100
                HEX 0020552A0100
                HEX 0020552A0100

                ;{"format": "hires","x":119,"y":100,"width":42,"height":24}
CRYSTAL_MASK
                ; HEX 7F7F017E7F7F
                ; HEX 7F7F01787F7F
                ; HEX 7F7F01707F7F
                ; HEX 7F7F01707F7F
                ; HEX 7F7F01707F7F
                ; HEX 7F7F01407F7F
                ; HEX 7F7F01007F7F
                ; HEX 7F7F01007F7F
                ; HEX 7F7F01007F7F
                ; HEX 7F7F01007F7F
                ; HEX 7F4701007F7F
                ; HEX 7F030000707F
                ; HEX 7F030000607F
                ; HEX 7F070000607F
                ; HEX 7F0F0000607F
                ; HEX 7F1F0000607F
                ; HEX 7F3F0000707F
                ; HEX 7F1F0000787F
                ; HEX 7F3F00007C7F
                ; HEX 7F070000787F
                ; HEX 7F070000787F
                ; HEX 7F070000787F
                ; HEX 7F070000787F
                ; HEX 7F070000787F

                ;{"format": "hires","x":119,"y":155,"width":42,"height":24}
                hex 7f7f637f7f7f
                hex 7f7f037f7f7f
                hex 7f7f03787f7f
                hex 7f7f03787f7f
                hex 7f7f03787f7f
                hex 7f7f03787f7f
                hex 7f7f03407f7f
                hex 7f7f03407f7f
                hex 7f7f03407f7f
                hex 7f7f03407f7f
                hex 7f7f03407f7f
                hex 7f6703407f7f
                hex 7f070000707f
                hex 7f0f0000707f
                hex 7f1f0000707f
                hex 7f3f00007c7f
                hex 7f1f0000787f
                hex 7f7f00007e7f
                hex 7f7f00007e7f
                hex 7f0f00007c7f
                hex 7f0f00007c7f
                hex 7f0f00007c7f
                hex 7f0f00007c7f
                hex 7f0f00007c7f

; high ring
;{"format": "hires","x":119,"y":98,"width":42,"height":13}

; low ring
;{"format": "hires","x":119,"y":111,"width":42,"height":13}

DRAW_LOW_RING_TOP
                TXA
                ASL
                TAX
                LDY RING_TOPS+0,X
                LDA RING_TOPS+1,X
                BNE DRAW_LOW_RING_CMN   ; always

DRAW_LOW_RING_BOT
                TXA
                ASL
                TAX
                LDY RING_BOTS+0,X
                LDA RING_BOTS+1,X

DRAW_LOW_RING_CMN
                STY :2+1
                STA :2+2
                LDY #111
                LDA #124
                STA ENDLINE

                LDX #0
:1              STY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY #17
:2              LDA $FFFF,X
                ORA (SCREENL),Y
                STA (SCREENL),Y
                INX
                INY
                CPY #23
                BNE :2
                LDY LINENUM
                INY
                CPY ENDLINE
                BNE :1
                RTS

DRAW_HIGH_RING_TOP
                TXA
                ASL
                TAX
                LDY RING_TOPS+0,X
                LDA RING_TOPS+1,X
                BNE DRAW_HIGH_RING_CMN   ; always

DRAW_HIGH_RING_BOT
                TXA
                ASL
                TAX
                LDY RING_BOTS+0,X
                LDA RING_BOTS+1,X

DRAW_HIGH_RING_CMN
                STY :2+1
                STA :2+2
                LDY #98
                LDA #111
                STA ENDLINE

                LDX #0
:1              STY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY #17
:2              LDA $FFFF,X
                ORA (SCREENL),Y
                STA (SCREENL),Y
                INX
                INY
                CPY #23
                BNE :2
                LDY LINENUM
                INY
                CPY ENDLINE
                BNE :1
                RTS

RING_TOPS       DW  RING0_TOP
                DW  RING1_TOP
                DW  RING2_TOP
                DW  RING3_TOP
                DW  RING4_TOP
                DW  RING5_TOP
                DW  RING6_TOP
                DW  RING7_TOP
                DW  RING8_TOP
                DW  RING9_TOP
                DW  RING10_TOP

RING_BOTS       DW  RING0_BOT
                DW  RING1_BOT
                DW  RING2_BOT
                DW  RING3_BOT
                DW  RING4_BOT
                DW  RING5_BOT
                DW  RING6_BOT
                DW  RING7_BOT
                DW  RING8_BOT
                DW  RING9_BOT
                DW  RING10_BOT

RING0_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":13,"WIDTH":42,"HEIGHT":13}
                HEX 070000000000
                HEX 380000000000
                HEX 600300000000
                HEX 003E00000000
                HEX 006003000000
                HEX 00001E000000
                HEX 000070030000
                HEX 0000001E0000
                HEX 000000700100
                HEX 000000001F00
                HEX 000000007001
                HEX 000000000007
                HEX 000000000038

RING0_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":13,"WIDTH":42,"HEIGHT":13}
                HEX 070000000000
                HEX 380000000000
                HEX 600300000000
                HEX 003E00000000
                HEX 006003000000
                HEX 00001E000000
                HEX 000070030000
                HEX 0000001E0000
                HEX 000000700100
                HEX 000000001F00
                HEX 000000007001
                HEX 000000000007
                HEX 000000000038

RING1_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":27,"WIDTH":42,"HEIGHT":13}
                HEX 070000000000
                HEX 7C0000000000
                HEX 400F00000000
                HEX 007801000000
                HEX 00001F000000
                HEX 000070010000
                HEX 0000001F0000
                HEX 000000700000
                HEX 000000400700
                HEX 000000003C00
                HEX 000000006003
                HEX 00000000000E
                HEX 000000000038

RING1_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":27,"WIDTH":42,"HEIGHT":13}
                HEX 070000000000
                HEX 1C0000000000
                HEX 700100000000
                HEX 000F00000000
                HEX 007800000000
                HEX 004003000000
                HEX 00003E000000
                HEX 000060030000
                HEX 0000003E0000
                HEX 000000600700
                HEX 000000007C00
                HEX 00000000400F
                HEX 000000000038

RING2_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":41,"WIDTH":42,"HEIGHT":13}
                HEX 7F0100000000
                HEX 003F00000000
                HEX 00600F000000
                HEX 000078000000
                HEX 0000400F0000
                HEX 000000780000
                HEX 000000400700
                HEX 000000001C00
                HEX 000000007001
                HEX 000000000007
                HEX 00000000001C
                HEX 000000000030
                HEX 000000000000

RING2_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":41,"WIDTH":42,"HEIGHT":13}
                HEX 000000000000
                HEX 030000000000
                HEX 0E0000000000
                HEX 380000000000
                HEX 600300000000
                HEX 001E00000000
                HEX 007001000000
                HEX 00000F000000
                HEX 000078000000
                HEX 0000400F0000
                HEX 000000780100
                HEX 000000003F00
                HEX 00000000603F

RING3_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":55,"WIDTH":42,"HEIGHT":13}
                HEX 7E1F00000000
                HEX 00700F000000
                HEX 000078010000
                HEX 0000001F0000
                HEX 000000700100
                HEX 000000000F00
                HEX 000000003800
                HEX 000000006001
                HEX 000000000007
                HEX 00000000000C
                HEX 000000000018
                HEX 000000000018
                HEX 000000000000

RING3_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":55,"WIDTH":42,"HEIGHT":13}
                HEX 000000000000
                HEX 030000000000
                HEX 030000000000
                HEX 060000000000
                HEX 1C0000000000
                HEX 700000000000
                HEX 400300000000
                HEX 001E00000000
                HEX 007001000000
                HEX 00001F000000
                HEX 000070030000
                HEX 0000007E0100
                HEX 000000007F0F

RING4_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":69,"WIDTH":42,"HEIGHT":13}
                HEX 787F0F000000
                HEX 0E0078030000
                HEX 0000001E0000
                HEX 000000700300
                HEX 000000001E00
                HEX 000000007000
                HEX 000000004003
                HEX 00000000000E
                HEX 00000000000C
                HEX 000000000018
                HEX 000000000018
                HEX 000000000000
                HEX 000000000000

RING4_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":69,"WIDTH":42,"HEIGHT":13}
                HEX 000000000000
                HEX 000000000000
                HEX 030000000000
                HEX 030000000000
                HEX 060000000000
                HEX 0E0000000000
                HEX 380000000000
                HEX 600100000000
                HEX 000F00000000
                HEX 007801000000
                HEX 00000F000000
                HEX 00007803000F
                HEX 0000007E7F01

RING5_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":83,"WIDTH":42,"HEIGHT":13}
                HEX 00607F7F0100
                HEX 003F00003F00
                HEX 700100006003
                HEX 1C000000000E
                HEX 060000000018
                HEX 030000000030
                HEX 000000000030
                HEX 000000000000
                HEX 000000000000
                HEX 000000000000
                HEX 000000000000
                HEX 000000000000
                HEX 000000000000

RING5_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":83,"WIDTH":42,"HEIGHT":13}
                HEX 000000000000
                HEX 000000000000
                HEX 000000000000
                HEX 000000000000
                HEX 000000000000
                HEX 000000000000
                HEX 030000000030
                HEX 030000000030
                HEX 060000000018
                HEX 1C000000000E
                HEX 700100006003
                HEX 003F00003F00
                HEX 00607F7F0100

RING6_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":97,"WIDTH":42,"HEIGHT":13}
                HEX 0000007E7F01
                HEX 00007803000F
                HEX 00000F000018
                HEX 007801000000
                HEX 000F00000000
                HEX 600100000000
                HEX 380000000000
                HEX 0E0000000000
                HEX 060000000000
                HEX 030000000000
                HEX 000000000000
                HEX 000000000000
                HEX 000000000000

RING6_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":97,"WIDTH":42,"HEIGHT":13}
                HEX 000000000000
                HEX 000000000000
                HEX 000000000000
                HEX 000000000018
                HEX 00000000000C
                HEX 00000000000E
                HEX 000000004003
                HEX 000000007000
                HEX 000000001E00
                HEX 000000700300
                HEX 0300001E0000
                HEX 0E0078030000
                HEX 787F0F000000

RING7_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":111,"WIDTH":42,"HEIGHT":13}
                HEX 000000007F0F
                HEX 0000007E0118
                HEX 000070030000
                HEX 00001F000000
                HEX 007001000000
                HEX 001E00000000
                HEX 400300000000
                HEX 700000000000
                HEX 1C0000000000
                HEX 060000000000
                HEX 030000000000
                HEX 000000000000
                HEX 000000000000

RING7_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":111,"WIDTH":42,"HEIGHT":13}
                HEX 000000000000
                HEX 000000000000
                HEX 000000000018
                HEX 00000000000C
                HEX 000000000007
                HEX 000000006001
                HEX 000000003800
                HEX 000000000F00
                HEX 000000700100
                HEX 0000001F0000
                HEX 000078010000
                HEX 03700F000000
                HEX 7E1F00000000

RING8_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":125,"WIDTH":42,"HEIGHT":13}
                HEX 00000000603F
                HEX 000000003F00
                HEX 000000780100
                HEX 0000400F0000
                HEX 000078000000
                HEX 00000F000000
                HEX 007001000000
                HEX 001E00000000
                HEX 600300000000
                HEX 380000000000
                HEX 0E0000000000
                HEX 030000000000
                HEX 000000000000

RING8_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":125,"WIDTH":42,"HEIGHT":13}
                HEX 000000000000
                HEX 000000000030
                HEX 00000000001C
                HEX 000000000007
                HEX 000000007001
                HEX 000000001C00
                HEX 000000400700
                HEX 000000780000
                HEX 0000400F0000
                HEX 000078000000
                HEX 00600F000000
                HEX 003F00000000
                HEX 7F0100000000

RING9_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":139,"WIDTH":42,"HEIGHT":13}
                HEX 000000000038
                HEX 00000000400F
                HEX 000000007C00
                HEX 000000600700
                HEX 0000003E0000
                HEX 000060030000
                HEX 00003E000000
                HEX 004003000000
                HEX 007800000000
                HEX 000F00000000
                HEX 700100000000
                HEX 1C0000000000
                HEX 070000000000

RING9_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":139,"WIDTH":42,"HEIGHT":13}
                HEX 000000000038
                HEX 00000000000E
                HEX 000000006003
                HEX 000000003C00
                HEX 000000400700
                HEX 000000700000
                HEX 0000001F0000
                HEX 000070010000
                HEX 00001F000000
                HEX 007801000000
                HEX 400F00000000
                HEX 7C0000000000
                HEX 070000000000

RING10_TOP
                ;{"FORMAT": "HIRES","X":231,"Y":153,"WIDTH":42,"HEIGHT":13}
                HEX 000000000038
                HEX 000000000007
                HEX 000000007001
                HEX 000000001F00
                HEX 000000700100
                HEX 0000001E0000
                HEX 000070030000
                HEX 00001E000000
                HEX 006003000000
                HEX 003E00000000
                HEX 600300000000
                HEX 380000000000
                HEX 070000000000

RING10_BOT
                ;{"FORMAT": "HIRES","X":175,"Y":153,"WIDTH":42,"HEIGHT":13}
                HEX 000000000038
                HEX 000000000007
                HEX 000000007001
                HEX 000000001F00
                HEX 000000700100
                HEX 0000001E0000
                HEX 000070030000
                HEX 00001E000000
                HEX 006003000000
                HEX 003E00000000
                HEX 600300000000
                HEX 380000000000
                HEX 070000000000

DRAW_FRAME      TXA
                ASL
                TAX
                LDA FRAME_PTRS+0,X
                STA :MOD+1
                LDA FRAME_PTRS+1,X
                STA :MOD+2
                LDX #0
                LDY #frameTop
:1              STY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY #frameLeft
:MOD            LDA $FFFF,X
                STA (SCREENL),Y
                INX
                INY
                CPY #frameRight
                BNE :MOD
                LDY LINENUM
                INY
                CPY #frameBottom
                BNE :1
                RTS

CAPTURE_FRAME   TXA
                ASL
                TAX
                LDA FRAME_PTRS+0,X
                STA :MOD+1
                LDA FRAME_PTRS+1,X
                STA :MOD+2
                LDX #0
                LDY #frameTop
:1              STY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY #frameLeft
:2              LDA (SCREENL),Y
:MOD            STA $FFFF,X
                INX
                INY
                CPY #frameRight
                BNE :2
                LDY LINENUM
                INY
                CPY #frameBottom
                BNE :1
                RTS

DIFF_FRAMES     LDA #0
                STA DESTINL
                LDA #frameBytes
                STA SCREENL
                LDA #>FRAME_BUFFER
                STA DESTINH
                STA SCREENH
                LDX #1
:1              LDY #0
:2              LDA (DESTINL),Y
                EOR (SCREENL),Y
                STA (DESTINL),Y
                INY
                CPY #frameBytes
                BNE :2
                LDA SCREENL
                STA DESTINL
                CLC
                ADC #frameBytes
                STA SCREENL
                LDA SCREENH
                STA DESTINH
                ADC #0
                STA SCREENH
                INX
                CPX #frameCount+1
                BNE :1
                RTS

ENDCOL          =   $CF

DRAW_ALL_FRAMES LDX #0
:0              STX FRAME_INDEX
                LDA :COLUMNS,X
                STA COLUMN
                CLC
                ADC #frameByteWidth
                STA ENDCOL
                LDY :ROWS,X
                TYA
                CLC
                ADC #frameHeight
                STA ENDLINE
                TXA
                ASL
                TAX
                LDA FRAME_PTRS+0,X
                STA :MOD+1
                LDA FRAME_PTRS+1,X
                STA :MOD+2
                LDX #0
:1              STY LINENUM
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY COLUMN
:MOD            LDA $FFFF,X
                STA (SCREENL),Y
                INX
                INY
                CPY ENDCOL
                BNE :MOD
                LDY LINENUM
                INY
                CPY ENDLINE
                BNE :1
                LDX FRAME_INDEX
                INX
                CPX #frameCount         ;*** 21
                BNE :0
                RTS

:COLUMNS        DB  0,0,0,0,0,0,0
                DB  6,6,6,6,6,6,6
                DB  12,12,12,12,12,12,12

:ROWS           DB  0,26,52,78,104,130,156
                DB  0,26,52,78,104,130,156
                DB  0,26,52,78,104,130,156

                FIN

; ------------------------------------------------------------------------------

                DS  \,$EE

                DUMMY *
                ; assumed to be page aligned
RING_BUFFER     DS  frameBytes*frameCount
                DEND

