;-------------------------------------------------------------------------------
; This library supports the AY-3-8912 sound chips on the EXP1802 expansion 
; card running on the SBC1802 mini-computer. 
;-------------------------------------------------------------------------------
; This is the public library routine to detect if PSG hardware is present.
;
; Uses:
;   RF = Elf/OS hardware data
;
; Returns: 
;   DF = 0 OK, PSG hardware is present
;   DF = 1 ERROR, PSG hardware not present
;-------------------------------------------------------------------------------


#include    ../include/ops.inc
#include    ../include/bios.inc

          proc    psg_detect

          CALL  f_getdev    ; get Elf/OS hardware byte in rf.0      
          glo   rf          ; rf.0 has bios type bits
          ani   $80         ; check bit 7 to see if $f000 bios available
          lbnz  chk_hwf     ; if present, check hardware flags for psg 
          stc               ; if not, no psg present (not an SBC1802)
          RETURN 
               
chk_hwf:  CALL  f_testhwf
          dw    $0010       ; bit 4 of hardware flags word indicates PSG present
          RETURN            ; return results from hardware flags test
        endp      
