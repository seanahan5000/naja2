
; count of characters in roster list
ROSTER_COUNT    =   $C0
CHARPTR         =   $C1                 ;+1
RTEMP           =   $C3

ROSTER_BUFFER   =   $9000               ; must be page aligned

; page 1 visible, showing Trevr Levlk, PAGE still set to 1

GROUP_ASSEMBLY  LDA KEYBRD
                BPL :1
                JSR CHECK_CANCEL
                BNE :1
                BIT UNSTROB
                JMP ASSEMBLY_OUT1

:1              JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictSetBlue
                PictMoveTo 0;4
                PictLineTo 278;4
                PictLineTo 278;26
                PictLineTo 234;26
                PictLineTo 234;34
                PictLineTo 0;34
                PictLineTo 0;4
                PictTextAt 238;28;"<SPACE>"
                PictEnd

                LDA ROSTER_BITS+0
                ORA ROSTER_BITS+1
                BEQ :2
                JMP ASSEMBLY_IN

:2              JSR DRAW_PICT
                PictTextAt 14;7;"SINCE NO ONE IS ENROLLED RIGHT NOW, YOU'RE"
                PictTextAt 14;16;"PROBABLY LOOKING FOR THE ENROLLMENT OFFICE."
                PictTextAt 14;25;"IT'S THE FIRST HALL ON THE RIGHT."
                PictShowPage
                PictEnd
                JSR ANIMATE_BUBBLES
                JMP ASSEMBLY_OUT2

ASSEMBLY_IN     JSR LOAD_ROSTER

                JSR DRAW_PICT
                PictTextAt 14;7;"HELLO, MY NAME IS TREPR E. LELVK, HEAD OF"
                PictTextAt 14;16;"TACTICAL FORCE TRAINING.  I'M HERE TO HELP"
                PictTextAt 14;25;"YOU SELECT MEMBERS FOR YOUR GROUP."
                PictShowPage
                PictEnd
                JSR ANIMATE_BUBBLES
                BCC MAIN_LOOP1
                BCS ASSEMBLY_OUT2       ; always

ASSEMBLY_OUT1   JSR DRAW_PICT
                PictSetPage2
                PictCopyToPage
                PictShowPage
                PictEnd
ASSEMBLY_OUT2   RTS

MAIN_LOOP1      JSR DRAW_PICT
                PictSetPage1
                PictClearPage
                PictCall DRAW_STATS_BOX
                PictSetViolet
                PictRect $24;$65;$F2;$87
                PictTextAt 53;105;"SEE CANDIDATE ROSTER"
                PictTextAt 53;115;"SUSPEND COMMISSION <EXIT GAME>"
                PictTextAt 53;125;"LEAVE MY OFFICE"
                PictShowPage
                PictEnd

MAIN_LOOP2      LDX #<MAIN_CDEF
                LDY #>MAIN_CDEF
                JSR MENU_INIT

                LDX #$00
                LDA GRPNUMB
                BNE :1
                DEX                     ; skip remove if group empty
:1              STX LEGALS+1

                JSR MENU_SET_CANCEL
                JSR MENU_SELECT
                BCC LEAVE               ; cancel
                STX MAIN_CCUR
                JMP MENU_TARGET

LEAVE           JSR WRITE_ROSTER
                JMP ASSEMBLY_OUT1

MAIN_CDEF       DB  $83
MAIN_CCUR       DB  $00
                DW  MAIN_ARROW
                DW  :TARGETS

:TARGETS        DW  USE_ROSTER
                DW  RESIGN
                DW  LEAVE

MAIN_ARROW      LDY MAIN_YPNTS,X
                LDX #$27
                JMP DRAW_ARROW

MAIN_MARKER     LDY MAIN_YPNTS,X
                LDX #$2A
                JMP DRAW_MARKER

MAIN_YPNTS      DB  $69,$73,$7D

;---------------------------------------

BUBBLE          =   SCRATCH
BASE_HEIGHT     =   105
BASE_COLUMN     =   27

ANIMATE_BUBBLES LDA #$04
                STA BUBBLE
:1              JSR DRAW_BUBBLE
                LDY BUBBLE
                LDX BUBBLE
                LDA HEIGHT,Y
                DEC HEIGHT,X
                CMP POP_HEIGHT,Y
                BNE :4
:2              JSR RANDOM
                AND #$07
                CMP #$04
                BCS :2
                STA MASK_OF_5,Y
:3              JSR RANDOM
                AND #$07
                CMP #$07
                BEQ :3
                CLC
                ADC #BASE_HEIGHT
                STA POP_HEIGHT,Y
                LDA #BASE_HEIGHT+7
                STA HEIGHT,Y
:4              JSR DRAW_BUBBLE
                DEC BUBBLE
                BPL :1
                LDA #$A0
                JSR WAIT
                LDA KEYBRD
                BPL ANIMATE_BUBBLES
                BIT UNSTROB
                CMP #$9B                ; escape
                BEQ :5
                JSR CHECK_ENTER
                BNE ANIMATE_BUBBLES
                CLC
:5              RTS

DRAW_BUBBLE     LDY BUBBLE
                LDX HEIGHT,Y
                LDA LOBYTES,X
                STA SCREENL
                LDA HIBYTES,X
                STA SCREENH
                LDA MASK_OF_5,Y
                ASL
                TAX
                LDA MASKS,X
                LDY #BASE_COLUMN
                EOR (SCREENL),Y
                STA (SCREENL),Y
                INY
                LDA MASKS+1,X
                EOR (SCREENL),Y
                STA (SCREENL),Y
                RTS

MASKS           DB  %00010000,%00000000
                DB  %01000000,%00000000
                DB  %00000000,%00000010
                DB  %00000000,%00001000

HEIGHT          DB  $6E,$6E,$70,$6C,$6B
POP_HEIGHT      DB  $6C,$6A,$6B,$69,$69
MASK_OF_5       DB  $02,$00,$02,$01,$00

;---------------------------------------

RESIGN          LDX #1
                JSR MAIN_MARKER

                JSR DRAW_PICT
                PictTextAt 29;185;"ARE YOU SURE YOU WANT TO QUIT <Y/N> "
                PictEnd
                JSR YES_OR_NO
                BCS :YES

:NO             JSR DRAW_PICT
                PictClear 4;185;34;192
                PictEnd
                LDX #1
                JSR MAIN_MARKER
                JMP MAIN_LOOP2

:YES
                ; *** save game and roster ***
                JSR WRITE_ROSTER

                LDA #0
                STA GRPNUMB

                JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictImage NAJA_LOGO
                PictTextAt 70;185;"PRESS ANY KEY TO RESTART"
                PictShowPage
                PictEnd

                BIT UNSTROB
:1              LDA KEYBRD
                BPL :1
                BIT UNSTROB

                ; *** transport w/noise back into mothership ***

                JMP ASSEMBLY_OUT2       ;***

; TODO: make this a common utility?
; NOTE: also used by info seller, viewport, and others

YES_OR_NO       BIT UNSTROB
                JSR GET_INPUT_KEY
:1              CMP #"Y"
                BEQ :3
                CMP #"N"
                BEQ :2
                CMP #$9B                ; escape
                BEQ :2
                JSR REGET_INPUT
                JMP :1
:2              CLC
:3              RTS

NAJA_LOGO       DB  $09,$3E,$16,$44
                HEX E870306040981838785818FDB978827F840103067C928601
                HEX 03060C1830604086060E1E36664606F507827F8A7F9294A7
                HEX 040382A7060AB27F8A7F92A2A7061382A70811A47F8A7F92
                HEX B0A7081A82A70A18967F8A7F92BEA70A2182A70C1F887F8A
                HEX 7F9208D7020078827818B5191B1E1C1888970237827F8A7F
                HEX 9288A70C28849F050E07827F8A7E06CD07827F8A7F9296A7
                HEX 100497120B1933664C18303F827E9F120D9C7F8A7F92A4B7
                HEX 120B1897131860419F15138E7F8A7F92AE7818316346BF13
                HEX 0EA715241F306040847F92AE7F8601037E84A71412414346
                HEX 4C5973A717271933664792D7030078827F8A1F18A119A1A7
                HEX 0E2384A718208486A71A3A86A7100E827F8A7E06D5669906
                HEX 9507070694A71C0382AF1313AC7F8A7F92A2A71E0A82A720
                HEX 11A47F8A7F92B0A7201A82A72218967F8A7F92BEA7222182
                HEX A7241F887F8A7F92CCA72428829727263F8A7F92DAA72626
                HEX 8A7F92E89F282D3F92
                DB  $FF

;---------------------------------------
