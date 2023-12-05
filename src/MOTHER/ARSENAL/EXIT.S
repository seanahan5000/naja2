*-------------------------------
*
*-------------------------------

LEAVE_ARSENAL
ARSOUT
;                 LDA PAGE
;                 CMP #$40
;                 BEQ AROKAY
;                 JSR MOVETO2
;                 STA SCNDARY
; AROKAY
                ; LDA STCKDIF
;                 BEQ ARSKIPT
;                 LDX #67
; AOLOOP          LDA PISTSTK,X
;                 STA $9C8B,X
;                 DEX
;                 BPL AOLOOP

                ; LDX #wStock
                ; JSR CALL_WRITERS
ARSKIPT         ; LDX #mPictures
                ; JSR SLOAD_FILE

                JSR PACK_STOCK

                ;*** WRITE MS STATE AND DIRTY CHARS ***

                ;*** CHECK PAGES ***
                JSR DRAW_PICT
                PictClearPage
                PictCall DRAW_HALL
                PictShowPage
                PictEnd
                SEC
                RTS

*-------------------------------
