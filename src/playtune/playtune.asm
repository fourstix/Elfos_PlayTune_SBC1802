; -------------------------------------------------------------------
; Play a demo tune through the SPBC1802 AY-3-8912 music chips
; Copyright 2024 by Gaston Williams
; -------------------------------------------------------------------
; Based on software written by Michael H Riley
; Thanks to the author for making this code available.
; Original author copyright notice:
; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

#include ../include/ops.inc
#include ../include/bios.inc
#include ../include/kernel.inc
#include ../include/psg_sbc1802.inc


            org     2000h
            

start:      br      main

            
; Build information

ever

db    'Copyright 2025 by Gaston Williams',0

main:   lda     ra                  ; move past any spaces
        smi     ' '
        lbz     main

        dec     ra                  ; move back to non-space character
        ldn     ra                  ; get character
        lbnz    good                ; jump if non-zero
                  
usage:  CALL    o_inmsg           ; display usage message and return
          db  'Usage: playtune tunefile',10,13,0
        CALL    o_inmsg
          db  'Play a Miditones file.',13,10,0
        RETURN                      ; and return to os
        
good:   COPY    ra, rf             ; copy argument address to rf

good1:  lda     ra                 ; look for first less <= space
        smi     33
        lbdf    good1
        dec     ra                  ; backup to char
        ldi     0                   ; need proper termination
        str     ra
        phi     r7
        ldi     20                  ; open for read only, move pointer to end
        plo     r7
        LOAD    rd, pt_des          ; get file descriptor
        
        CALL    o_open              ; attempt to open file      
        lbnf    opened              ; jump if file opened
        
        CALL    o_inmsg             ; display error message
          db 'File not found.',10,13,0
        RETURN                      ; return to Elf/OS

opened: ldi     0                   ; zero out r7 and r8
        phi     r8                  ; to read file position
        plo     r8
        phi     r7
        plo     r7
        phi     rc                 
        ldi     1
        plo     rc                  ; seek from current position at EOF
        LOAD    rd, pt_des          ; set file descriptor for seek
        call    o_seek              ; get current position into r7 and r8
        lbnf    f_size

sz_err: LOAD    rd, pt_des          ; set file descriptor for close
        CALL    o_close             ; close file
        CALL    o_inmsg             ; display error message
          db 'File size error.',10,13,0
        RETURN                      ; return to Elf/OS

f_size: ghi     r8                  ; check if file too large for memory
        lbnz    sz_err              ; anything greater than 32K is too big
        glo     r8 
        lbnz    sz_err              ; anything greater than 32K is too big
        COPY    r7, ra              ; save file size for later
        
        LOAD    rd, pt_des          ; set file descriptor for seek
        ldi     0                   ; move file pointer back to beginning
        phi     r8                  ; set R8:R7 to 0 for beginning
        plo     r8
        phi     r7
        plo     r7
        phi     rc
        plo     rc                  ; seek from beginning
        call    o_seek              ; move file pointer back to beginning

        
        COPY    ra, rc              ; set size for memory allocation
        ldi     0                   ; set flags for temporary memory, no alignment
        phi     r7
        plo     r7
        
        call    o_alloc             ; allocate block of memory for music
        lbdf    sz_err              ; if not enough memory available, show error
        
        COPY    ra, rc              ; set file size to read into buffer
        LOAD    rd, pt_des          ; set file descriptor for seek
        COPY    rf, ra              ; save copy of buffer pointer for playing data             
        CALL    o_read              ; read the music data into buffer
        lbnf    play                ; Check for error

rd_err: CALL    o_inmsg             ; display error on reading
          db    10,13,'File read error',10,13,0

        LOAD    rd, pt_des          ; set file descriptor for close  
        CALL    o_close             ; attempt to close the open file
        RETURN                      ; return to OS
                
play:   
        COPY    ra, rf	  	        ; point to music buffer
     	  CALL    psg_player          ; and play it!
        
        LOAD    rd, pt_des          ; set file descriptor for close
        CALL    o_close             ; close the file
        
        COPY    ra, rf              ; de-allocate music buffer
        CALL    o_dealloc           ; not required but best practice
        
        call    o_inmsg             ; print exit message
          db 'OK.',10,13,0  

        RETURN                      ; Return to Elf/OS
          
pt_des:   db      0,0,0,0
          dw      dta
          db      0,0
flags:    db      0
          db      0,0,0,0
          dw      0,0
          db      0,0,0,0

dta:   ds      512        ; data transfer area       
        end     start
