
USER            JSR SETVTAB             ; in I.MOVER.S
                JSR RESET_EQLIST
                JSR ESCAN_HANDBCK
                JSR ESCAN_FULSLOT
                JSR ESCAN_RGTPROF
                LDX #<MED_EQUIP
                LDY #>MED_EQUIP
                JSR ESCAN_COMMON
                LDX #14
:1              LDA EQUIP_LIST,X
                STA USABLE,X
                DEX
                BPL :1

                JSR LEGAL1
                CMP #$FF
                BEQ :CANCEL

                STX MCURSOR
                JSR DRAW_USE_WHICH

                JSR PRESUB              ; in I.MOVER.S
                JSR COMNKEY             ; in I.MOVER.S
                PHA

                JSR CURSIT2             ; in I.MOVER.S

                PLA
                CMP #"C"
                BNE :NO_CANCEL

:CANCEL         JSR DRAW_PICT
                PictClear 24;50;39;105
                PictEnd
                RTS                     ; return back to C.ISTATS.S

:NO_CANCEL      JSR DRAW_PICT
                ; leave green lines
                PictClear 24;51;39;104
                PictEnd

                LDX MCURSOR
                LDY CORESPS,X
                INY
                LDA (CHARDL),Y
                BEQ DIAGNOSE
                TAX
                DEX
                BEQ CELLREG
                DEX
                BEQ CIRCREP
                ; JSR LOAD_REFORM
                JMP COMPRESS

CIRCREP         LDA #$01
                BNE CC_COM              ; always
CELLREG         LDA #$00
CC_COM          ; PHA
                ; JSR LOAD_REFORM
                ; PLA
                JMP REGENERATE

DIAGNOSE        JSR BIG_STATS_BOX

                JSR DRAW_PICT
                PictTextAt 184;84;(USE_DIAGNOSER)
                PictTextAt 198;93;(ON_WHOM?)
                PictEnd

                JSR RESET_CHLIST        ; excludes robot
                ; LDX LEFHOLD           ;???
                ; LDA #$FF              ;???
                ; STA CHAR_LIST,X       ;???
                JSR PRE_ARROW
                JSR MENU_SELECT
                CPX #7
                BNE :NO_CANCEL

                JMP HIDE_BIG_STATS      ; return back to C.ISTATS.S

:NO_CANCEL      STX ITARGET_CHAR
                LDA #$00
DIAG_MERGE      PHA                     ; called from KILLED_HIM
                ; LDA CAMP_HERE
                ; AND #bit_Diagnose
                ; BNE :SKIPA
                ; LDX #cDiagnose
                ; JSR SLOAD_FILE
                ; LDA CAMP_HERE
                ; ORA #bit_Diagnose
                ; STA CAMP_HERE
:SKIPA          PLA
                JSR DIAGNOSER
                PLA
                PLA
                LDA ISOURCE_CHAR
                JSR SET_CHAR
                JMP RESTATS

MED_EQUIP       LDA (CHARDL),Y
                AND #%11011111
                CMP #$41
                BNE :1
                INY
                LDA (CHARDL),Y
                AND #%11111100
:1              RTS
