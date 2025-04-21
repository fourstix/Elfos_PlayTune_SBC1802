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

        smi     '-'-' '             ; was it a dash to indicate option?
        lbnz    fname               ; if not a dash, check for filename

        lda     ra                  ; get the next character after dash
        smi     'f'                 ; check for force play
        lbz     force               ; set force flag
        smi     5                   ; check for key shift 'k'
        lbz     key                 ; set key shift
        smi     4                   ; check for octave 'o'      
        lbz     oct                 ; set octave
        lbr     usage               ; anything else is an invalid option
        

fname:  dec     ra                  ; move back to non-space character
        ldn     ra                  ; get character
        smi     33                  ; check for printable character
        lbdf    good                ; jump if printable, otherwise invalid name
                                                      
usage:  CALL    o_inmsg           ; display usage message and return
          db  'Usage: playtune [-s=n | -o=n | -f] tunefile',10,13
          db  'Play a Miditones file ',13,10
          db  'where tunefile is the miditones file to play.',13,10,0
        CALL    o_inmsg
          db   ' Options:',13,10
          db   '-kn, shift key by n semi-tones',13,10
          db   '-on, shift key by n ovtaves',13,10
          db   '-f, force play',13,10,0
        RETURN                      ; and return to os
        

force:  LOAD    rf, skp_chk         ; set skp_chk flag to true
        ldi     $FF
        str     rf
        lbr     main                ; go back and look for more options

key:    ldi     0                   ; set flag in rc.1 for semi-tones
        phi     rc
        plo     rc                  ; set flag in rc.0 for number sign
        lbr     shift               ; jump to shift routine
        
oct:    ldi     $ff                 ; set flag in rc.1 for octave
        phi     rc
        ldi     0                   ; set flag in rc.0 for number sign
        plo     rc 

        
shift:  lda     ra                  ; skip over any spaces
        smi     ' '
        lbz     shift 
        
        smi     13                  ; is it a minus sign
        lbnz    conv                ; if not, convert the number
        
        ldi     $FF                 ; set flag in rc.0 to subtract value
        plo     rc
        inc     ra                  ; move to next character              

conv:   dec     ra                  ; move back to option
        COPY    ra, rf              ; read integer
        CALL    f_atoi              ; convert ASCII to integer
        lbdf    usage               ; if error, show usage message

        glo     rd                  ; get low byte of integer 
        str     r2                  ; save in M(X)
        COPY    rf, ra              ; move pointer to end of integer
        ghi     rc                  ; check flag in rc.1
        lbz     shift2
        
        ldx                         ; get the shift value for octave
        shl                         ; multiply by 2
        add                         ; add one more for 3
        shl                         ; multiply by 2 (6)
        shl                         ; multiply by 2 (1 octave = 12 semi-tones)
        str     r2                  ; save octave shift in M(X) 
        
shift2: LOAD    rf, key_shft        ; point
        glo     rc
        lbz     pos                 ; if positive add shift value to key shift
        ldn     rf                  ; get key shift value
        sm                          ; subtract shift
        str     rf                  ; save in memory
        lbr     main                ; check for next option or name

pos:    ldn     rf                  ; get key_shift byte
        add                         ; add shift 
        str     rf                  ; save in memory 
        lbr     main                ; check for next option or name
        
good:   COPY    ra, rf              ; copy argument address to rf

name1:  lda     ra                  ; skip over characters in file name
        smi     33                  
        lbdf    name1               ; keep going until end of string 

        dec     ra                  ; backup to end of name string
        ldi     0                   ; need proper termination
        str     ra
        
        phi     r7                  ; zero out flags register high byte
        ldi     20                  ; open for read only, move pointer to end
        plo     r7
        LOAD    rd, pt_des          ; set file descriptor
        
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
        COPY    rf, ra              ; save copy of memory buffer pointer             
        CALL    o_read              ; read the music data into buffer
        lbnf    detect              ; Check for error

rd_err: CALL    o_inmsg             ; display error on reading
          db    10,13,'File read error',10,13,0
        LOAD    rd, pt_des          ; set file descriptor for close
        CALL    o_close             ; attempt to close the file after error
        lbr     mfree               ; free memory and exit
                
detect: LOAD    rd, pt_des          ; set file descriptor for close
        CALL    o_close             ; close the file once loaded

        LOAD    rf, skp_chk         ; check for force flag
        ldn     rf
        lbnz    play                ; if force flag set, just play

        CALL    psg_detect          ; see if psg hardware is present
        lbnf    play                ; DF = 0, means hardware found
        
        call    o_inmsg 
          db 10,13,'PSG hardware not found.',10,13,0
        lbr     mfree               ; free memory and exit

play:   COPY    ra, rf	  	        ; point to music buffer in memory
        LOAD    rd, key_shft        ; point to key shift
        ldn     rd                  ; get the key shift value
        plo     rc                  ; store in register
        
        CALL    psg_player          ; and play it!
        lbdf    stop
          
        CALL    o_inmsg             ; print exit message
          db 'Done.',10,13,0  
        lbr     mfree               ; free memory and exit
        
stop:   CALL    o_inmsg             ; print stopped message
          db 'Stopped.',10,13,0
          
mfree:  COPY    ra, rf              ; de-allocate memory block
        CALL    o_dealloc           ; not required but best practice        
        RETURN                      ; Return to Elf/OS
        
key_shft: db      0           
skp_chk:  db      0
pt_des:   db      0,0,0,0
          dw      dta
          db      0,0
flags:    db      0
          db      0,0,0,0
          dw      0,0
          db      0,0,0,0

dta:   ds      512        ; data transfer area       
        end     start
