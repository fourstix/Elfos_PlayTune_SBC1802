;-------------------------------------------------------------------------------
; This library supports the AY-3-8912 sound chips on the EXP1802 expansion 
; card running on the SBC1802 mini-computer. 
;-------------------------------------------------------------------------------
; This is the public library routine to play a stream from miditunes.
;
; Parameters:
;   RF = pointer to buffer with miditunes data
;   RC.0 = midi key offset
;
; Returns: 
;   DF = 1 if play stopped by pressing Input
;-------------------------------------------------------------------------------


#include    ../include/ops.inc


        extrn   psg_begin
        extrn   psg_play_stream
        extrn   psg_end
        
        proc    psg_player
        
        PUSH rd               ; save the registers used
        PUSH r8
        PUSH r7
              
        CALL psg_begin        ; Now we're ready to play ....
       	CALL psg_play_stream  ; and play it!
        CALL psg_end          ; reset the PSG after we are done
                  
        POP  r7               ; restore register
        POP  r8
        POP  rd
        RETURN    
        endp      
