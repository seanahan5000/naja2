
;------------------------------------------------------------------------------

                ;     A,  B,  C,  D,  E,  F,  G,  H,  I,  J,  K,
                ;     L,  M,  N,  O,  P,  Q,  R,  S,  T,  U,  V,
                ;    aa, bb, cc, dd, ee, ff, gg, hh, ii, jj, kk,
                ;    ll, mm, nn, oo, pp, qq, rr, ss, tt, uu, vv,
                ;   fc0,fc1,fc2,fc3,fc4,fc5,

XY_DATA         DB  $38,$00,$00,$38,$19,$2d,$39,$24,$17,$46,$39    ; depth 0
                DB  $30,$17,$00,$00,$00,$00,$20,$a0,$00,$00,$00
                DB  $00,$00,$01,$17,$00,$19,$00,$32,$5f,$1c,$34
                DB  $66,$91,$a6,$91,$b7,$a7,$b7,$b5,$bd,$be,$be
                DB  $61,$7b,$a3,$0f,$67,$b3
                DB  $46,$17,$3a,$4f,$45,$5a,$60,$54,$4a,$64,$5f    ; depth 1
                DB  $5a,$49,$3a,$34,$35,$00,$00,$00,$00,$00,$00
                DB  $17,$26,$42,$48,$35,$4d,$42,$5a,$66,$4e,$5a
                DB  $74,$8c,$98,$8d,$8f,$98,$9f,$a1,$a3,$af,$b5
                DB  $6f,$7d,$9a,$59,$78,$92
                DB  $64,$4a,$5c,$67,$61,$6a,$6e,$66,$5e,$70,$6e    ; depth 2
                DB  $6a,$5d,$52,$4e,$4e,$14,$14,$10,$04,$03,$00
                DB  $48,$4d,$58,$5b,$56,$60,$5f,$68,$74,$60,$68
                DB  $7a,$8b,$92,$8b,$8c,$92,$95,$99,$9a,$9f,$a1
                DB  $75,$7f,$95,$73,$7f,$86
                DB  $70,$5e,$6a,$71,$6d,$72,$75,$6e,$68,$76,$75    ; depth 3
                DB  $72,$67,$5e,$5b,$5b,$2f,$2f,$2c,$22,$21,$15
                DB  $5b,$5e,$64,$65,$64,$69,$6b,$6f,$7a,$6a,$70
                DB  $7d,$8a,$90,$8a,$8a,$90,$91,$95,$95,$98,$99
                DB  $7b,$81,$93,$80,$83,$80
                DB  $76,$68,$72,$77,$74,$77,$7a,$74,$6f,$7a,$7b    ; depth 4
                DB  $78,$6f,$66,$64,$63,$43,$42,$40,$37,$37,$2c
                DB  $65,$67,$6b,$6c,$6c,$6f,$71,$74,$7d,$6f,$74
                DB  $7f,$89,$8e,$89,$8a,$8e,$8f,$92,$93,$94,$95
                DB  $7d,$82,$91,$88,$85,$7c
                DB  $7a,$6f,$76,$7b,$78,$7a,$7c,$76,$73,$7d,$7c    ; depth 5
                DB  $7a,$73,$6c,$6a,$6a,$4c,$4c,$4a,$43,$43,$3a
                DB  $6c,$6d,$6f,$70,$71,$73,$75,$77,$7f,$73,$77
                DB  $80,$89,$8d,$89,$89,$8d,$8d,$90,$91,$92,$92
                DB  $7f,$83,$8f,$8e,$87,$7a
                DB  $7d,$73,$7a,$7d,$7b,$7d,$7e,$7a,$77,$7f,$7e    ; depth 6
                DB  $7c,$77,$72,$70,$70,$56,$56,$54,$4f,$4f,$48
                DB  $70,$71,$73,$73,$74,$76,$78,$79,$80,$76,$79
                DB  $81,$89,$8c,$89,$89,$8c,$8c,$8f,$8f,$90,$90
                DB  $81,$ee,$8e,$91,$88,$78
                DB  $7f,$77,$7c,$7f,$7d,$7e,$80,$7c,$79,$80,$80    ; depth 7
                DB  $7e,$79,$74,$72,$72,$5c,$5c,$5a,$55,$55,$4e
                DB  $73,$74,$75,$76,$77,$78,$7a,$7b,$81,$78,$7b
                DB  $82,$88,$8b,$88,$89,$8b,$8c,$8e,$8e,$8f,$8f

            do 0
XY_DATA_ORIG    DB  $38,$00,$00,$38,$19,$2d,$38,$24,$16,$45,$38    ; depth 0
                DB  $30,$15,$00,$00,$00,$00,$20,$a0,$00,$00,$00
                DB  $00,$00,$01,$16,$00,$18,$00,$31,$5f,$1c,$34
                DB  $65,$91,$a6,$91,$00,$a7,$b7,$b4,$bd,$be,$be
                DB  $61,$7b,$a3,$0f,$67,$b3
                DB  $45,$16,$38,$4f,$44,$59,$60,$54,$49,$64,$5f    ; depth 1
                DB  $5a,$49,$38,$32,$33,$00,$00,$00,$00,$00,$00
                DB  $16,$25,$41,$47,$34,$4d,$42,$59,$65,$4e,$5a
                DB  $74,$8c,$97,$8c,$8f,$97,$9f,$a0,$a3,$ae,$b4
                DB  $6f,$7d,$9a,$59,$78,$92
                DB  $64,$49,$5a,$67,$61,$69,$6e,$64,$5d,$6f,$6c    ; depth 2
                DB  $68,$5d,$52,$4c,$4e,$10,$12,$0c,$01,$01,$00
                DB  $47,$4c,$58,$5a,$55,$5f,$5e,$67,$74,$60,$68
                DB  $79,$8a,$92,$8a,$8b,$92,$95,$98,$9a,$9e,$a0
                DB  $75,$7f,$95,$73,$7f,$86
                DB  $6f,$5d,$68,$71,$6d,$71,$75,$6e,$68,$76,$75    ; depth 3
                DB  $72,$67,$5e,$5b,$5b,$2f,$2f,$2c,$22,$21,$15
                DB  $5a,$5d,$63,$65,$64,$69,$6a,$6f,$79,$69,$6f
                DB  $7c,$89,$8f,$89,$8a,$8f,$91,$94,$95,$97,$98
                DB  $79,$81,$92,$80,$83,$80
                DB  $76,$68,$70,$77,$73,$76,$79,$74,$6e,$7a,$78    ; depth 4
                DB  $76,$6d,$66,$63,$64,$3e,$3f,$3c,$34,$33,$29
                DB  $65,$66,$6a,$6b,$6b,$6f,$70,$74,$7c,$6f,$74
                DB  $7e,$89,$8d,$89,$89,$8d,$8e,$92,$92,$94,$94
                DB  $7d,$82,$90,$88,$85,$7c
                DB  $7a,$6e,$74,$7a,$78,$7a,$7c,$76,$73,$7c,$7c    ; depth 5
                DB  $7a,$73,$6c,$6a,$6a,$4c,$4c,$4a,$43,$43,$3a
                DB  $6b,$6c,$6f,$6f,$70,$73,$75,$77,$7e,$73,$77
                DB  $80,$88,$8c,$88,$89,$8c,$8d,$90,$90,$91,$92
                DB  $7f,$83,$8f,$8e,$87,$7a
                DB  $7c,$73,$78,$7d,$7b,$7c,$7e,$7a,$76,$7e,$7e    ; depth 6
                DB  $7c,$75,$70,$6e,$6e,$54,$54,$52,$4c,$4b,$44
                DB  $6f,$70,$72,$73,$74,$75,$77,$79,$80,$76,$79
                DB  $81,$88,$8b,$88,$88,$8b,$8c,$8f,$8f,$90,$90
                DB  $7f,$ee,$8e,$91,$88,$78
                DB  $7e,$76,$7a,$7f,$7d,$7e,$7f,$7c,$79,$80,$80    ; depth 7
                DB  $7e,$79,$74,$73,$72,$5c,$5b,$5a,$55,$55,$4f
                DB  $73,$73,$75,$75,$76,$78,$79,$7b,$81,$78,$7b
                DB  $81,$88,$8b,$88,$88,$8b,$8b,$8e,$8e,$8e,$8f
            fin

;------------------------------------------------------------------------------

sidePrevOpenToFarFlat
                DB  ORD_DEC
                DB  ORD_G, ORD_CC   ;  6
                DB  ORD_INC
                DB  ORD_J, ORD_DD   ; 20
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_MOVE
                DB  ORD_DEC
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_INC
                DB  ORD_J, ORD_SS   ; 22
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_STOP

sidePrevOpenToNextOpen
                DB  ORD_DEC
                DB  ORD_G, ORD_CC   ;  6
                DB  ORD_INC
                DB  ORD_INC
                DB  ORD_D, ORD_BB   ;  7
                DB  ORD_DEC
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_MOVE
                DB  ORD_DEC
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_INC
                DB  ORD_INC
                DB  ORD_D, ORD_UU   ;  4
                DB  ORD_DEC
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_STOP

sidePrevOpenToFarCorner
                DB  ORD_DEC
                DB  ORD_G, ORD_CC   ;  6
                DB  ORD_INC
                DB  ORD_G, ORD_CC   ;  6
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_MOVE
                DB  ORD_DEC
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_INC
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_STOP

sideNearFlatToFarFlat
                DB  ORD_A, ORD_AA   ;  1
                DB  ORD_J, ORD_DD   ; 20
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_MOVE
                DB  ORD_A, ORD_VV   ;  3
                DB  ORD_J, ORD_SS   ; 22
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_STOP

sideNearFlatToNextOpen
                DB  ORD_A, ORD_AA   ; 1
                DB  ORD_INC
                DB  ORD_D, ORD_BB   ; 7
                DB  ORD_B, ORD_II   ; 2
                DB  ORD_DEC
                DB  ORD_MOVE
                DB  ORD_A, ORD_VV   ; 3
                DB  ORD_INC
                DB  ORD_D, ORD_UU   ; 4
                DB  ORD_B, ORD_II   ; 2
                DB  ORD_DEC
                DB  ORD_STOP

sideNearFlatToFarCorner
                DB  ORD_A, ORD_AA   ; 1
                DB  ORD_G, ORD_CC   ; 6
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_MOVE
                DB  ORD_A, ORD_VV   ; 3
                DB  ORD_G, ORD_TT   ; 5
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_STOP

sideFarOpenToNextOpen
                DB  ORD_G, ORD_CC   ; 6
                DB  ORD_INC
                DB  ORD_D, ORD_BB   ; 7
                DB  ORD_B, ORD_II   ; 2
                DB  ORD_DEC
                DB  ORD_MOVE
                DB  ORD_G, ORD_TT   ; 5
                DB  ORD_INC
                DB  ORD_D, ORD_UU   ; 4
                DB  ORD_B, ORD_II   ; 2
                DB  ORD_DEC
                DB  ORD_STOP

sideCenterLine  DB  ORD_B, ORD_II   ;  2
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_STOP

sideCenterTopBot
                DB  ORD_D, ORD_BB   ;  7   C2 DATA
                DB  ORD_G, ORD_CC   ;  6
                DB  ORD_MOVE
                DB  ORD_D, ORD_UU   ;  4
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_STOP

sideFarCornerAngled
                DB  ORD_G, ORD_CC   ;  6   D2 DATA
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_STOP

sideDoor        DB  ORD_E, ORD_EE   ;  9   DOORDRW1 DATA
                DB  ORD_F, ORD_FF   ; 10
                DB  ORD_H, ORD_HH   ; 11
                DB  ORD_H, ORD_OO   ; 12
                DB  ORD_F, ORD_QQ   ; 13
                DB  ORD_E, ORD_RR   ; 14
                DB  ORD_C, ORD_PP   ; 15   DOORDRW2 DATA
                DB  ORD_C, ORD_GG   ;  8
                DB  ORD_E, ORD_EE   ;  9
                DB  ORD_STOP

sideDoor0       DB  ORD_E, ORD_EE   ;  9
                DB  ORD_F, ORD_FF   ; 10
                DB  ORD_H, ORD_HH   ; 11
                DB  ORD_H, ORD_OO   ; 12
                DB  ORD_F, ORD_QQ   ; 13
                DB  ORD_C, ORD_RR   ; (15.x, 14.y)
                DB  ORD_STOP

frontCenterWall DB  ORD_G, ORD_CC   ;  6
                DB  ORD_FLIP
                DB  ORD_G, ORD_CC   ;  6
                DB  ORD_FLIP
                DB  ORD_MOVE
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_FLIP
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_FLIP
                DB  ORD_MOVE
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_FLIP
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_FLIP
                DB  ORD_STOP

frontCenterDoor DB  ORD_K, ORD_JJ   ; 16   SKIPALL1
                DB  ORD_L, ORD_KK   ; 17
                DB  ORD_L, ORD_MM   ; 18
                DB  ORD_K, ORD_NN   ; 19
                DB  ORD_FLIP
                DB  ORD_K, ORD_NN   ; 19   SKIPALL2
                DB  ORD_L, ORD_MM   ; 18
                DB  ORD_L, ORD_KK   ; 17
                DB  ORD_K, ORD_JJ   ; 16
                DB  ORD_FLIP
                DB  ORD_K, ORD_JJ   ; 16
                DB  ORD_STOP

frontCenterSigma0
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_O, ORD_R    ; NOTE: ORD_R hard-coded to 32 at depth 0
                DB  ORD_MOVE
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_O, ORD_S    ; NOTE: ORD_R hard-coded to 160 at depth 0
                DB  ORD_STOP

leftSigma       DB  ORD_CLIP
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_O, ORD_CC
                DB  ORD_CLIP
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_O, ORD_TT
                DB  ORD_STOP

frontWallEnd    DB  ORD_CLIP
                DB  ORD_M, ORD_LL
                DB  ORD_M, ORD_CC
                DB  ORD_CLIP
                DB  ORD_M, ORD_LL
                DB  ORD_M, ORD_TT
                DB  ORD_STOP

; building blocks of clipped left/right segment

leftTopBotO     DB  ORD_CLIP
                DB  ORD_G, ORD_CC   ;  6
                DB  ORD_O, ORD_CC
                DB  ORD_CLIP
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_O, ORD_TT
                DB  ORD_STOP

leftTopBotFlat  DB  ORD_CLIP
                DB  ORD_G, ORD_CC   ;  6
                DB  ORD_U, ORD_CC
                DB  ORD_U, ORD_TT
                DB  ORD_CLIP
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_U, ORD_TT
                DB  ORD_U, ORD_CC
                DB  ORD_STOP

leftTopBotCorner
                DB  ORD_CLIP
                DB  ORD_G, ORD_CC   ;  6
                DB  ORD_R, ORD_CC
                DB  ORD_U, ORD_LL
;               DB  ORD_R, ORD_TT
                DB  ORD_CLIP
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_R, ORD_TT
                DB  ORD_U, ORD_LL
;               DB  ORD_R, ORD_CC
                DB  ORD_STOP

        do farLeftRightCaps
leftTopBotOpen  DB  ORD_CLIP
                DB  ORD_G, ORD_CC   ;  6
                DB  ORD_V, ORD_CC
                DB  ORD_U, ORD_LL
;               DB  ORD_V, ORD_TT
                DB  ORD_CLIP
                DB  ORD_G, ORD_TT   ;  5
                DB  ORD_V, ORD_TT
                DB  ORD_U, ORD_LL
;               DB  ORD_V, ORD_CC
                DB  ORD_STOP
        fin

; left/right front-facing door segments

leftMidDoorA    DB  ORD_CLIP
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_N, ORD_LL
                DB  ORD_STOP

leftMidDoorAB   DB  ORD_CLIP
                DB  ORD_N, ORD_LL
                DB  ORD_S, ORD_LL
                DB  ORD_STOP

leftMidDoorBWall
                DB  ORD_CLIP
                DB  ORD_S, ORD_LL
                DB  ORD_U, ORD_LL
                DB  ORD_STOP

leftDoor        DB  ORD_CLIP
                DB  ORD_N, ORD_LL
                DB  ORD_N, ORD_KK
                DB  ORD_P, ORD_JJ
                DB  ORD_Q, ORD_JJ
                DB  ORD_S, ORD_KK
                DB  ORD_S, ORD_LL
                DB  ORD_CLIP
                DB  ORD_N, ORD_LL
                DB  ORD_N, ORD_MM
                DB  ORD_P, ORD_NN
                DB  ORD_Q, ORD_NN
                DB  ORD_S, ORD_MM
                DB  ORD_S, ORD_LL
                DB  ORD_STOP

leftMidDoorBDown
                DB  ORD_CLIP
                DB  ORD_S, ORD_LL
                DB  ORD_S, ORD_MM
                DB  ORD_STOP

leftDoor0       DB  ORD_N, ORD_KK
                DB  ORD_N, ORD_MM
                DB  ORD_STOP

; left/right front-facing wall-only segments

; extra clipping to get over vertical wall divider
leftMidWall     DB  ORD_CLIP+1
                DB  ORD_I, ORD_LL   ; 21
                DB  ORD_U, ORD_LL
                DB  ORD_STOP

leftMidEndFlat  DB  ORD_CLIP
                DB  ORD_U, ORD_LL
                DB  ORD_U, ORD_CC
                DB  ORD_CLIP
                DB  ORD_U, ORD_LL
                DB  ORD_U, ORD_TT
                DB  ORD_STOP

leftMidEndCorner
                DB  ORD_CLIP
                DB  ORD_U, ORD_LL
                DB  ORD_R, ORD_CC
                DB  ORD_CLIP
                DB  ORD_U, ORD_LL
                DB  ORD_R, ORD_TT
                DB  ORD_STOP

        do farLeftRightCaps
leftMidEndOpen  DB  ORD_CLIP
                DB  ORD_U, ORD_LL
                DB  ORD_V, ORD_CC
                DB  ORD_CLIP
                DB  ORD_U, ORD_LL
                DB  ORD_V, ORD_TT
                DB  ORD_STOP

leftMidEndOpen2 DB  ORD_CLIP
                DB  ORD_U, ORD_LL
                DB  ORD_V, ORD_LL
                DB  ORD_STOP
        fin

; face-change specifics

frontFaceChange DB  ORD_G, ORD_CC
                DB  ORD_FC0, ORD_FC1
                DB  ORD_G, ORD_TT

                DB  ORD_MOVE
                DB  ORD_I, ORD_LL
                DB  ORD_FC0, ORD_FC1
                DB  ORD_FC0, ORD_TT

                DB  ORD_MOVE
                DB  ORD_FC0, ORD_FC2
                DB  ORD_G, ORD_TT

                DB  ORD_STOP

frontFaceChangeSpans
                DB  ORD_G, ORD_CC
                DB  ORD_FLIP
                DB  ORD_G, ORD_CC

                DB  ORD_MOVE
                DB  ORD_FC0, ORD_FC1
                DB  ORD_FLIP
                DB  ORD_FC0, ORD_FC1

                DB  ORD_FLIP
                DB  ORD_MOVE
                DB  ORD_FC0, ORD_FC2
                DB  ORD_FLIP
                DB  ORD_FC0, ORD_FC2

                DB  ORD_MOVE
                DB  ORD_G, ORD_TT
                DB  ORD_FLIP
                DB  ORD_G, ORD_TT
                DB  ORD_FLIP

                DB  ORD_STOP

sideFaceChange  DB  ORD_CLIP
                DB  ORD_G, ORD_CC
                DB  ORD_T, ORD_FC3

                DB  ORD_CLIP
                DB  ORD_I, ORD_LL
                DB  ORD_T, ORD_FC4

                DB  ORD_CLIP
                DB  ORD_G, ORD_TT
                DB  ORD_T, ORD_FC5

                DB  ORD_CLIP
                DB  ORD_G, ORD_TT
                DB  ORD_T, ORD_TT

                DB  ORD_STOP

;------------------------------------------------------------------------------
