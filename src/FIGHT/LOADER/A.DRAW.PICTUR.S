*===============================
*
*===============================

; TODO: make tunnel range part of alien data

DRAW_PICTURE    JSR DRAW_PICT
                PictSetPage2
                PictClearPage
                PictEnd

;                 LDA DIRECTN
;                 STA DIRHOLD
;                 LDA BUFFER+4
;                 CMP #$FF
;                 BNE GOTDIR
;                 LDA DIRECTN
;                 EOR #$0F
;                 STA DIRECTN
;                 JSR GETNSEW
;                 LDA BUFFER+4
;                 CMP #$FF
;                 BNE GOTDIR
;                 LDA DIRECTN
;                 EOR #$FF
;                 STA DIRECTN
;                 JSR GETNSEW
;                 LDA BUFFER+4
;                 CMP #$FF
;                 BNE GOTDIR
;                 LDA DIRECTN
;                 EOR #$0F
;                 STA DIRECTN
;                 JSR GETNSEW
; GOTDIR          LDA SRANGE
;                 PHA
;                 LDX #<SRANGE_TABLE
;                 LDY #>SRANGE_TABLE
;                 LDA ALIEN1
;                 JSR QUICK_SEARCH
;                 LDX #6
;                 BCC :SKIPA
;                 TAX
; :SKIPA          STX SRANGE
;                 CPX MXRANGE
;                 BCC GOTUNL
;                 LDA MXRANGE
;                 STA SRANGE
; GOTUNL          JSR NOSCAN
;                 PLA
;                 STA SRANGE

                JSR DRAW_HALL

                LDX ALIEN1
                LDA DATA_BUFR+4,X       ; picture #'s

                CMP #$FF
                BEQ :NO_PICT            ; sets carry
                PHA

                LDX SHELL
                LDA :PIC_FILES-1,X
                JSR SET_FILE
                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                LDA #1
                LDY #>PICT_BUFR
                JSR READ_FILE

                LDA #IS_SPINNING+KEEP_SPINNING
                JSR SET_NEXT_ON_OFF
                PLA
                ASL
                TAY
                INY                     ; skip COUNT_12/345
                LDA PICT_BUFR+0,Y       ; offset low byte (offset in sector)
                PHA
                LDA PICT_BUFR+3,Y       ; offset high byte of next picture
                SEC
                SBC PICT_BUFR+1,Y       ; offset high byte (sector offset)
                ADC #0                  ; + 1
                PHA
                LDA PICT_BUFR+1,Y       ; offset high byte (sector offset)
                JSR SEEK_FILE
                PLA
                LDY #>PICT_BUFR
                JSR READ_FILE
                PLA
                TAX
                LDY #>PICT_BUFR
                JSR UNPACK
                CLC                     ; clear carry if picture was drawn
:NO_PICT        RTS

:PIC_FILES      DB  fileAlienPics12
                DB  fileAlienPics12
                DB  fileAlienPics345
                DB  fileAlienPics345
                DB  fileAlienPics345

; SRANGE_TABLE    DB  3               ;# of entries
;                 DB  3               ;bytes per entry
;                 DB  1,$25,3         ;SHELL #, ALIEN #, SRANGE
;                 DB  1,$2B,5
;                 DB  1,$2F,5

*---------------------------------------------------------
* On Entry:
*       A: Alien number to match with
*     X,Y: Address of list structure
*   SHELL: Current shell
*
* On Exit:
*     Carry set: Match WAS found
*   Carry clear: Match was NOT found
*       TEMP,+1: Address of entry that matched (if found)
*             A: Third byte of entry (if found)
*             Y: 3 (if match found)
*
* Uses:
*   TEMP,+1
*---------------------------------------------------------

; QUICK_SEARCH    STX TEMP
;                 STY TEMP+1
;                 STA :MOD1+1
;                 LDY #0
;                 LDA (TEMP),Y
;                 TAX
;                 INY
;                 LDA (TEMP),Y
;                 STA :MOD2+1
;                 LDA TEMP
;                 CLC
;                 ADC #2
;                 STA TEMP
;                 BCC :LOOP1
;                 INC TEMP+1
; :LOOP1          LDY #0
;                 LDA (TEMP),Y
;                 INY
; :MOD1           CMP #$FF            ;Modified
;                 BNE :SKIPB
;                 LDA (TEMP),Y
;                 CMP SHELL
;                 BEQ :SKIPD
; :SKIPB          LDA TEMP
;                 CLC
; :MOD2           ADC #$FF            ;Modified
;                 STA TEMP
;                 BCC :SKIPC
;                 INC TEMP+1
; :SKIPC          DEX
;                 BNE :LOOP1
;                 CLC
;                 RTS
;
; :SKIPD          INY
;                 LDA (TEMP),Y
;                 SEC
;                 RTS
