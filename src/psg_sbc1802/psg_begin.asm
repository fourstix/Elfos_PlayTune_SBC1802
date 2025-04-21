;-------------------------------------------------------------------------------
; This library supports the AY-3-8912 sound chips on the EXP1802 expansion 
; card running on the SBC1802 mini-computer. 
;-------------------------------------------------------------------------------
; Initialize both PSG's set the I/O group for sound generator
;-------------------------------------------------------------------------------

#include    ../include/ops.inc
#include    ../include/sbc1802_psg.inc

        proc psg_begin
        ; Select the sound generator I/O group
        sex  r3                 ; set x = p for inline data
        out  GROUP
        db   PSGGRP 

        ; Initialize both PSGs ...

        ; OUTPSG1(PSGR6,  $00)  ; disable the noise generator 1
        out  PSG1ADR 
        db   PSGR6
        out  PSGDATA
        db   $00

        ; OUTPSG2(PSGR6,  $00)  ; disable the noise generator 2
        out  PSG2ADR 
        db   PSGR6
        out  PSGDATA
        db   $00

        ; OUTPSG1(PSGR7,  $38)  ; turn on tone generators A1, B1 & C1
        out  PSG1ADR 
        db   PSGR7
        out  PSGDATA
        db   $38

        ; OUTPSG2(PSGR7,  $38)  ; turn on tone generator A2, B2 & C2
        out  PSG2ADR 
        db   PSGR7
        out  PSGDATA
        db   $38

        ; OUTPSG1(PSGR10, $00)  ; mute channel A1
        out  PSG1ADR 
        db   PSGR10
        out  PSGDATA
        db   $00

        ; OUTPSG2(PSGR10, $00)  ; mute channel A2
        out  PSG2ADR 
        db   PSGR10
        out  PSGDATA
        db   $00

        ; OUTPSG1(PSGR11, $00)  ; mute channel B1
        out  PSG1ADR 
        db   PSGR11
        out  PSGDATA
        db   $00


        ; OUTPSG2(PSGR11, $00)  ; mute channel B2
        out  PSG2ADR 
        db   PSGR11
        out  PSGDATA
        db   $00

        ; OUTPSG1(PSGR12, $00)  ; mute channel C1
        out  PSG1ADR 
        db   PSGR12
        out  PSGDATA
        db   $00

        ; OUTPSG2(PSGR12, $00)  ; mute channel C2
        out  PSG2ADR 
        db   PSGR12
        out  PSGDATA
        db   $00 

        ; OUTPSG1(PSGR15, $00)  ; disable envelope generator 1 (we don't use it)
        out  PSG1ADR 
        db   PSGR15
        out  PSGDATA
        db   $00
        ; OUTPSG2(PSGR15, $00)  ; disable envelope generator 2
        out  PSG2ADR 
        db   PSGR15
        out  PSGDATA
        db   $00
        
        out  GROUP              ; select the base board I/O group again
        db   BASEGRP 

        sex  r2                 ; set x back to stack pointer for return
        RETURN
        endp
