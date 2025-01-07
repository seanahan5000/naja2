
leftColumn      =   7
rightColumn     =   32                  ; inclusive
topLine         =   30
bottomLine      =   164                 ; inclusive
edgeTopLine     =   52
edgeBotLine     =   146                 ; inclusive
lineWidth       =   rightColumn-leftColumn+1
lineCount       =   bottomLine-topLine/2+1

LPTR            =   $C0
LPTR_H          =   $C1
FILL            =   $C2
CELL_NUMBER     =   $C3
BARS_ON         =   $C4
HAS_PRISONER    =   $C5
BAR_PHASE       =   $C6
BAR_MASK        =   $C7

; ----------------------------------------------------------

DO_PRISON_CELL  STA CELL_NUMBER
                STA :CELL_MOD-2

                LDA #$0F                ; data for DRAW_BLOCK1 call
                STA BLOCK_BUFFER+2
                STA BLOCK_BUFFER+3

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictCall DRAW_BLOCK1
                PictSetBlack1
                PictClear 8;2;11;30         ; top left
                PictClear 29;2;32;30        ; top right
                PictClear 8;165;14;189      ; bottom left
                PictClear 26;165;32;189     ; bottom right
                PictFillRect 23;102;49;109  ; left edge
                PictFillRect 229;102;255;109 ; right edge
                PictCall DRAW_HALL
                PictSetBlack1
                PictFillRect 49;102;79;102  ; center line
                PictFillRect 81;102;197;102
                PictFillRect 199;102;229;102
                PictTextAt 123;11;"CELL X"
:CELL_MOD       PictEnd

                LDA #0
                STA HAS_PRISONER
                STA BARS_ON
                STA BAR_PHASE

; TODO: which bar lines should be on?
                LDA #%00001111
                STA BAR_MASK

                LDA CELL_NUMBER
                CMP #3
                BNE :1
                LDA #gamePrisonerGone
                JSR TEST_GAME_FLAG
                BCS :1
                DEC HAS_PRISONER
                DEC BARS_ON
:1
; TODO: which other cells should have bars on?

                BIT HAS_PRISONER
                BVC :2
                JSR DRAW_PICT
                PictImage ALIEN
                PictEnd
                BNE :3                  ; always
:2              JSR DRAW_PICT
                PictImage BENCH
                PictEnd
:3              JSR SAVE_LINES

                LDX lineCount-1
                LDA #$00
:4              STA CUR_BARS,X
                STA NEXT_BARS,X
                DEX
                BPL :4

                BIT BARS_ON
                BVC :5
                JSR ANIMATE_BARS
:5              JSR DRAW_PICT
                PictShowPage
                PictSetPage1
                PictCopyToPage
                PictShowPage
                PictEnd

                BIT BARS_ON
                BVC :7
:6              BIT UNSTROB
                JSR ANIMATE_BARS
                LDA #$80
                JSR WAIT_KEY
                BPL :6
                JSR CHECK_UP
                BEQ :6
                JSR CHECK_LEFT
                BEQ :7
                JSR CHECK_RIGHT
                BEQ :7
                JSR CHECK_DOWN
                BNE :6
:7
                SEC
                RTS

ANIMATE_BARS    LDX #0
                LDY BAR_PHASE
:1              LDA #0
                CPY #4
                BCS :5
                LDA BIT_TABLE,Y
                AND BAR_MASK
                BEQ :5
                TYA
                ORA #$80
:5              STA NEXT_BARS,X
                INY
                CPY #8
                BNE :6
                LDY #0
:6              INX
                CPX #lineCount
                BNE :1

                LDX BAR_PHASE
                DEX
                BPL :7
                LDX #7
:7              STX BAR_PHASE

                ; fall through

UPDATE_BARS     LDX #0
:1              STX LINENUM
                LDA NEXT_BARS,X
                CMP CUR_BARS,X
                BEQ :4
                STA CUR_BARS,X
                TAY
                BEQ :2
                AND #$7F
                TAY
                JSR FILL_LINE
                BEQ :3                  ; always
:2              JSR RESTORE_LINE
:3              LDX LINENUM
:4              INX
                CPX #lineCount
                BNE :1
                RTS

SAVE_LINES      LDX #0
:1              LDA LINE_PTRS+0,X
                STA LPTR
                LDA LINE_PTRS+1,X
                STA LPTR_H
                TXA
                CLC
                ADC #topLine
                TAY
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY #leftColumn
:2              LDA (SCREENL),Y
                STA (LPTR),Y
                INY
                CPY #rightColumn+1
                BNE :2
                INX
                INX
                CPX #lineCount*2
                BNE :1
                RTS

RESTORE_LINE    TXA
                ASL
                TAX
                LDA LINE_PTRS+0,X
                STA LPTR
                LDA LINE_PTRS+1,X
                STA LPTR_H
                TXA
;               CLC
                ADC #topLine
                TAY
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH
                LDY #leftColumn
:1              LDA (LPTR),Y
                STA (SCREENL),Y
                INY
                CPY #rightColumn+1
                BNE :1
                RTS

FILL_LINE       LDA COLORS,Y
                STA FILL
                TXA
                ASL
                TAX
;               CLC
                ADC #topLine
                TAY
                LDA LOBYTES,Y
                STA SCREENL
                LDA HIBYTES,Y
                STA SCREENH

                CPY #edgeTopLine
                BCC :1
                LDX #edgeTopLine-topLine
                CPY #edgeBotLine+2
                BCC :1
                TYA
;               SEC
                SBC #edgeBotLine-edgeTopLine+topLine
                TAX
:1
                LDY #leftColumn
:2              LDA (SCREENL),Y
                EOR FILL
                AND LEFT_MASKS,X
                EOR FILL
                STA (SCREENL),Y
                LDA FILL
                EOR #$7F
                STA FILL
                INX
                INY
                CPY #leftColumn+2
                BNE :2
:3              STA (SCREENL),Y
                EOR #$7F
                INY
                CPY #rightColumn-1
                BNE :3
                STA FILL
:4              LDA (SCREENL),Y
                EOR FILL
                AND RIGHT_MASKS-2,X
                EOR FILL
                STA (SCREENL),Y
                LDA FILL
                EOR #$7F
                STA FILL
                INX
                INY
                CPY #rightColumn+1
                BNE :4
                RTS

COLORS          DB  $AA,$55,$D5,$2A

LEFT_MASKS      HEX 7F03                ; line #30, column 7/8
                HEX 7F03
                HEX 7F01
                HEX 7F00
                HEX 3F00
                HEX 3F00
                HEX 1F00
                HEX 0F00
                HEX 0700
                HEX 0700
                HEX 0300
                HEX 0100                ; line #52 -> #146
                HEX 0300
                HEX 0700
                HEX 0F00
                HEX 1F00
                HEX 3F00
                HEX 7F00
                HEX 7F00
                HEX 7F01
                HEX 7F03                ; line #164

RIGHT_MASKS     HEX 707F                ; line #30, column 31/32
                HEX 607F
                HEX 607F
                HEX 407F
                HEX 007F
                HEX 007E
                HEX 007E
                HEX 007C
                HEX 0078
                HEX 0070
                HEX 0070
                HEX 0060                ; line #52 -> #146
                HEX 0070
                HEX 0078
                HEX 007C
                HEX 007E
                HEX 007F
                HEX 407F
                HEX 407F
                HEX 607F
                HEX 707F                ; line #164

ALIEN           DB  $0B,$23,$15,$82
                HEX B2800A0A0B2B2E2C3830706089408DFEB4B04060705C5715
                HEX 89058D155795178B5756895450504444FE98AC003E2B2A0A
                HEX 0086830B208040E0B0BCAFAA8A82808984008902020A2A8D
                HEX 3860FE8E812018AC50555505864050541705050101A00555
                HEX 89577E60EC40915091549155AC0A2A0A86020A0A60AC0097
                HEX 04332F7E70CE406060705838382C2C2AB50A8D6A0AF00197
                HEX 07355F7860B4970865383C2C2E2F2B2B2A91292597031F01
                HEX 919694208928953089970022C0009705322B2B2E2C2C3897
                HEX 0C149D6F00606070007C5C5E5F575755A515050101944089
                HEX 609530303730885054545591450313675D559915159F022D
                HEX 91508940AA011555A915132B9582812B89822AB92F3C3878
                HEX 897C895E89578D55AD82404060382AAD6A892A895A5B005B
                HEX 5A2A897A4697052F0A02AC282A2A4A89528997067E998308
                HEX 95407525754095D5CD54524A9F087A029100957E00071595
                HEX 55A151404459970E754D404D558D575F5E7C787097002394
                HEX 2095288D292AC5830AA00A2A7F557F2A0AA0AA99A7107202
                HEX 0095A68E009502910A9902910A6A0A970D3C9929251555DD
                HEX 7593559582830355545582559D5E9712236040A5608D3095
                HEX 608D40895F40BE1F4060705D559515912AB99F10414A2A2A
                HEX 2E932A9582812A89822AA92B29271757A155C9B4383C2E2E
                HEX 2F970A63971417008992018D45753D292AA10A0A09059101
                HEX 917D8281018982011151914545059504029D00B1028D7A02
                HEX B6018D7D9E408D0060787E5F575591970C670000AA067A97
                HEX 173C48C2C66030382C2C2E892B2B0B4B633B2D2E2F970B65
                HEX 0A0A2222288D2091408D8E3F88404060707F3F2A8D0AC2B0
                HEX 40920097152E5140891856159197184A8401990591159117
                HEX 1757B19F1F2FC4924040987A2A2A209297187A22020A952A
                HEX 2A6868282020008840409C00917E0099D286001454505141
                HEX 408D904040617F55555C60408C40705C9F1A3B8A0001030F
                HEX 7D75555454504040410101FE848A97197942763E2A8D0A0B
                HEX 9597100E2A2B2F2E3C892E2B2A97042696382F2B97141897
                HEX 15202A1A1A3A3A6868F4941715018C9F146D70707C5F9F16
                HEX 27050101A001019001050514890000F4A49712619D0089FE
                HEX C6

BENCH           DB  $18,$90,$09,$15
                HEX 862A28220A2A8D28209086558D504515558D545050408686
                HEX 2A9997000495292684818055A154519F020855862AB12802
                HEX 2A8930703055B954514582077C422AC1860F7805559D1589
                HEX 55552525882117100A8904040202018988
                DB  $FF

]OFFSET = 0
LINE_PTRS
                LUP lineCount           ; *** RPW 65 is marking as ZPAGE here
                DW  LINE_BUFFER+]OFFSET-leftColumn
]OFFSET = ]OFFSET+lineWidth
                --^

                DS  \,$EE
                DS  256
                ERR *-$A800

                DUMMY *
LINE_BUFFER     DS  lineWidth*lineCount
CUR_BARS        DS  lineCount
NEXT_BARS       DS  lineCount
                DEND
