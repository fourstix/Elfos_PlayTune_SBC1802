;-------------------------------------------------------------------------------
; This library supports the AY-3-8912 sound chips on the EXP1802 expansion 
; card running on the SBC1802 mini-computer. 
;-------------------------------------------------------------------------------
; Reset both PSG's and then set the I/O group back to the base group
;-------------------------------------------------------------------------------

#include    ../include/ops.inc
#include    ../include/sbc1802_psg.inc

        proc psg_end
        sex  r3                 ; set x = p for inline data

        ; OUTPSG1(PSGR10, $00)	; mute channel A1
        out  PSG1ADR 
        db   PSGR10
        out  PSGDATA
        db   $00

        ; OUTPSG2(PSGR10, $00)	; mute channel A2
        out  PSG2ADR 
        db   PSGR10
        out  PSGDATA
        db   $00

        ; OUTPSG1(PSGR11, $00)	; mute channel B1
        out  PSG1ADR 
        db   PSGR11
        out  PSGDATA
        db   $00


        ; OUTPSG2(PSGR11, $00)	; mute channel B2
        out  PSG2ADR 
        db   PSGR11
        out  PSGDATA
        db   $00

        ; OUTPSG1(PSGR12, $00)	; mute channel C1
        out  PSG1ADR 
        db   PSGR12
        out  PSGDATA
        db   $00

        ; OUTPSG2(PSGR12, $00)	; mute channel C2
        out  PSG2ADR 
        db   PSGR12
        out  PSGDATA
        db   $00 

        ; OUTPSG1(PSGR7,  $3F)	; turn off all mixer inputs on PSG 1
        out  PSG1ADR 
        db   PSGR7
        out  PSGDATA
        db   $3F
        
        ; OUTPSG2(PSGR7,  $3F)	; turn off all mixer inputs on PSG 2
        out  PSG2ADR 
        db   PSGR7
        out  PSGDATA
        db   $3F
        
        ; select the base board I/O group again
        out  GROUP
        db   BASEGRP 
        sex  r2               ; set x back to stack pointer
        RETURN                ; return to Elf/OS
        endp
