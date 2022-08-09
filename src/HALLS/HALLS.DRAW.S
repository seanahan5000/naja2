
DRAW_HALL       ENT
                LDA #0
                STA CUR_DEPTH
                STA BLOCK_INDEX

                LDA #<XY_DATA
                STA XYDATAL
                LDA #>XY_DATA
                STA XYDATAH

                LDA #WHITE1
                STA COLOR
:1              JSR DRAW_BLOCK
                LDX BLOCK_INDEX
                LDA BLOCK_BUFFER-BUFFER_WIDTH,X
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BNE :2
                JSR NEXT_XY
                INC CUR_DEPTH
                LDA CUR_DEPTH
                CMP RANGE
                BEQ :1
                BCC :1
:2              RTS


SCAN_HALL       LDA #0
                STA CUR_DEPTH
                STA BLOCK_INDEX

                LDA #<XY_DATA
                STA XYDATAL
                LDA #>XY_DATA
                STA XYDATAH

                LDA #BLACK1
                STA COLOR
                JSR DRAW_BLOCK

:1              LDA CUR_DEPTH
                CMP RANGE
                BCS :2
                LDA BLOCK_INDEX
                PHA
                INC CUR_DEPTH
                JSR NEXT_XY
                LDA #BLACK1
                STA COLOR
                JSR DRAW_BLOCK
                JSR PREV_XY
                DEC CUR_DEPTH
                PLA
                STA BLOCK_INDEX

:2              LDA #WHITE1
                STA COLOR
                JSR DRAW_BLOCK
                LDX BLOCK_INDEX
                LDA BLOCK_BUFFER-BUFFER_WIDTH,X
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BNE :3
                JSR NEXT_XY
                INC CUR_DEPTH
                LDA CUR_DEPTH
                CMP RANGE
                BEQ :1
                BCC :1
:3
                ; shift blocks down in buffer and move

                LDX #BUFFER_WIDTH
:4              LDA BLOCK_BUFFER,X
                STA BLOCK_BUFFER-BUFFER_WIDTH,X
                INX
                CPX BLOCK_COUNT
                BNE :4
                TXA
                SEC
                SBC #BUFFER_WIDTH
                STA BLOCK_COUNT
                JMP MOVE_FORWARD

DRAW_BLOCK      LDA #$00
                STA LINE_SIDE

NEXT_SIDE       LDX BLOCK_INDEX
                LDA BLOCK_BUFFER,X
                STA BLOCK_DATA

;               LDA BLOCK_DATA
                AND #SIDE_MASK
;               CMP #SIDE_OPEN
                BEQ SIDE_IS_OPEN
                JMP SIDE_IS_WALLDOOR

SIDE_IS_OPEN    LDA BLOCK_DATA
                AND #XFRONT_MASK
;               CMP #XFRONT_OPEN
                BEQ :1
                CMP #XFRONT_FACE
                BNE :2
:1              JMP XFRONT_NOT_WALL_DOOR

;---------------------------------------
; draw left/right front-facing wall/door

:2              LDA BLOCK_DATA
                AND #XFRONT_MASK
                CMP #XFRONT_DOOR
                BNE :4

                LDA #1
                PHP                     ; default to didMidWall = false

                LDA CUR_DEPTH
                BEQ :3

                LDX #<leftMidDoorA
                LDY #>leftMidDoorA
                JSR DRAW_SEGMENTS
                BNE :5

                LDX #<leftMidDoorAB
                LDY #>leftMidDoorAB
                JSR DRAW_SEGMENTS
                PHA                     ; save clippedMidDoor
                LDX #<leftDoor
                LDY #>leftDoor
                JSR DRAW_SEGMENTS
                PLA                     ; restore clippedMidDoor
                BNE :5
                LDX #<leftMidDoorBDown
                LDY #>leftMidDoorBDown
                JSR DRAW_SEGMENTS
                LDX #<leftMidDoorBWall
                LDY #>leftMidDoorBWall
                PLP
                JSR DRAW_SEGMENTS
                PHP
                JMP :5

:3              LDX #<leftMidDoorA
                LDY #>leftMidDoorA
                JSR DRAW_SEGMENTS
                LDX #<leftDoor0
                LDY #>leftDoor0
                JSR DRAW_SEGMENTS
                JMP :5

:4              LDX #<leftMidWall
                LDY #>leftMidWall
                JSR DRAW_SEGMENTS
                PHP
:5
        do smartXfrontCaps
                LDY #0                  ; flat
                LDA BLOCK_DATA
                AND #XSIDE_MASK
;               CMP #XSIDE_OPEN
                BEQ :7
        do farLeftRightCaps
                LDX CUR_DEPTH
                BEQ :7
                ; NOTE: Edge.FACE here is a special flag to denote
                ;  block.xxfront being open
                CMP #XSIDE_FACE
                BNE :6
                LDY #2                  ; open
                BNE :7                  ; always
        fin
:6              LDY #1                  ; corner
:7              TYA
                BNE :8
        fin ; smartXfrontCaps
                LDX #<leftTopBotFlat
                LDY #>leftTopBotFlat
                PLP
                BNE :11
                JSR DRAW_SEGMENTS
                LDX #<leftMidEndFlat
                LDY #>leftMidEndFlat
        do smartXfrontCaps
                BNE :11                  ; always
:8              DEY
                BNE :9
                LDX #<leftTopBotCorner
                LDY #>leftTopBotCorner
                PLP
                BNE :11
                JSR DRAW_SEGMENTS
                LDX #<leftMidEndCorner
                LDY #>leftMidEndCorner
        do farLeftRightCaps
                BNE :11                  ; always
:9              LDX #<leftTopBotOpen
                LDY #>leftTopBotOpen
                PLP
                BNE :11
                JSR DRAW_SEGMENTS
                LDA CUR_DEPTH
                CMP #2
                BEQ :10
                LDX #<leftMidEndOpen
                LDY #>leftMidEndOpen
                BNE :11                 ; always
:10             LDX #<leftMidEndOpen2
                LDY #>leftMidEndOpen2
        fin
        fin ; smartXfrontCaps
:11             JSR DRAW_SEGMENTS

                LDA BLOCK_DATA
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BEQ :12
                CMP #FRONT_FACE
                BEQ :12
                LDX #<frontWallEnd
                LDY #>frontWallEnd
                JSR DRAW_SEGMENTS
:12

XFRONT_NOT_WALL_DOOR
;---------------------------------------
; center closed but left/right is open, so draw sigma

                LDA BLOCK_DATA
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BNE :1

                LDX BLOCK_INDEX
                LDA BLOCK_BUFFER+BUFFER_WIDTH,X
                AND #SIDE_MASK
;               CMP #SIDE_OPEN
                BEQ :4

:1              LDA BLOCK_DATA
                AND #XFRONT_MASK
;               CMP #XFRONT_OPEN
                BEQ :2
                CMP #XFRONT_FACE
                BNE :4
:2              LDX #<leftTopBotO
                LDY #>leftTopBotO
                JSR DRAW_SEGMENTS
                LDX #<leftSigma
                LDY #>leftSigma
                LDA CUR_DEPTH
                BNE :3
                LDX #<frontCenterSigma0
                LDY #>frontCenterSigma0
:3              JSR DRAW_SEGMENTS
:4
                LDA BLOCK_DATA
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BNE :6
                LDA BLOCK_DATA
                AND #XFRONT_MASK
;               CMP #XFRONT_OPEN
                BNE :5
                LDX BLOCK_INDEX
                LDA BLOCK_BUFFER+BUFFER_WIDTH,X
                AND #SIDE_MASK
;               CMP #SIDE_OPEN
                BEQ :7

                ; draw far opening lines
:5              LDX #<sideFarCornerAngled
                LDY #>sideFarCornerAngled
                JSR DRAW_SEGMENTS
                LDX BLOCK_INDEX
                LDA BLOCK_BUFFER+BUFFER_WIDTH,X
                AND #SIDE_MASK
;               CMP #SIDE_OPEN
                BNE :7
                LDA CUR_DEPTH
                CMP RANGE
                BCS :7
                ; TODO: overlap this code with below
                LDX #<sideFarOpenToNextOpen
                LDY #>sideFarOpenToNextOpen
                JSR DRAW_SEGMENTS
                JMP SIDE_IS_DONE

:6              CMP #FRONT_FACE
                BNE :7
                LDX #<sideFarCornerAngled
                LDY #>sideFarCornerAngled
                JSR DRAW_SEGMENTS
:7              JMP SIDE_IS_DONE

SIDE_IS_WALLDOOR
                CMP #SIDE_FACE
                BEQ SIDE_IS_FACE
                PHA

                LDY #0              ; prevOpen = false
                LDA CUR_DEPTH
                BEQ :2
                LDX BLOCK_INDEX
                LDA BLOCK_BUFFER-BUFFER_WIDTH,X
                AND #SIDE_MASK
;               CMP #SIDE_OPEN
                BEQ :1
                CMP #SIDE_FACE
                BNE :2
:1              INY                 ; prevOpen = true
:2
                LDA BLOCK_DATA
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BNE :6

                LDX BLOCK_INDEX
                LDA BLOCK_BUFFER+BUFFER_WIDTH,X
                AND #SIDE_MASK
;               CMP #SIDE_OPEN
                BEQ :4
                CMP #SIDE_FACE
                BEQ :4

                TYA                 ; if (prevOpen)
                BEQ :3
                LDX #<sidePrevOpenToFarFlat
                LDY #>sidePrevOpenToFarFlat
                BNE :8              ; always
:3              LDX #<sideNearFlatToFarFlat
                LDY #>sideNearFlatToFarFlat
                BNE :8              ; always

:4              TYA                 ; if (prevOpen)
                BEQ :5
                LDX #<sidePrevOpenToNextOpen
                LDY #>sidePrevOpenToNextOpen
                BNE :8              ; always
:5              LDX #<sideNearFlatToNextOpen
                LDY #>sideNearFlatToNextOpen
                BNE :8              ; always

:6              TYA                 ; if (prevOpen)
                BEQ :7
                LDX #<sidePrevOpenToFarCorner
                LDY #>sidePrevOpenToFarCorner
                BNE :8              ; always
:7              LDX #<sideNearFlatToFarCorner
                LDY #>sideNearFlatToFarCorner

:8              JSR DRAW_SEGMENTS

                LDX #<sideCenterLine
                LDY #>sideCenterLine
                JSR DRAW_SEGMENTS
                PLA
                CMP #SIDE_DOOR
                BNE SIDE_IS_DONE
                LDX #<sideDoor
                LDY #>sideDoor
                LDA CUR_DEPTH
                BNE :9
                LDX #<sideDoor0
                LDY #>sideDoor0
:9              JSR DRAW_SEGMENTS
                JMP SIDE_IS_DONE

SIDE_IS_FACE    LDX #<sideFaceChange
                LDY #>sideFaceChange
                JSR DRAW_SEGMENTS
                LDX #<sideFarCornerAngled
                LDY #>sideFarCornerAngled
                JSR DRAW_SEGMENTS
                LDX #<sideCenterTopBot
                LDY #>sideCenterTopBot
                JSR DRAW_SEGMENTS

SIDE_IS_DONE
; after side 0 (left), draw front center wall/door/face
                LDA LINE_SIDE
                BNE FRONT_DONE

                LDA BLOCK_DATA
                AND #FRONT_MASK
;               CMP #FRONT_OPEN
                BEQ FRONT_DONE
                CMP #FRONT_FACE
                BEQ :FRONT_FACE

                PHA
                LDX #<frontCenterWall
                LDY #>frontCenterWall
                JSR DRAW_SEGMENTS
                PLA
                CMP #FRONT_DOOR
                BNE FRONT_DONE
                LDX #<frontCenterDoor
                LDY #>frontCenterDoor
                JSR DRAW_SEGMENTS
                JMP FRONT_DONE

:FRONT_FACE     LDA CUR_DEPTH
                CMP RANGE
                BCS FRONT_DONE

                ; TODO: simplify?
                LDX #<frontFaceChange
                LDY #>frontFaceChange
                JSR DRAW_SEGMENTS
                INC LINE_SIDE
                LDX #<frontFaceChange
                LDY #>frontFaceChange
                JSR DRAW_SEGMENTS
                DEC LINE_SIDE
                LDX #<frontFaceChangeSpans
                LDY #>frontFaceChangeSpans
                JSR DRAW_SEGMENTS

FRONT_DONE      INC BLOCK_INDEX
                LDA LINE_SIDE
                EOR #$01
                STA LINE_SIDE
                BEQ :1
                JMP NEXT_SIDE
:1              RTS

;------------------------------------------------------------------------------
