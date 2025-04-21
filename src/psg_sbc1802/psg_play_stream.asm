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
; Registers Used:
;   RD = data value
;   R8 = sub routine pointer
;   R7 = table pointer
;
; Returns: 
;   DF = 1 if Input pressed to stop playing
;-------------------------------------------------------------------------------

#include    ../include/ops.inc
#include    ../include/sbc1802_psg.inc


        extrn   midinote
        

;++
;   This is the main player loop of the AY-3-8912 music player.  It fetches the
; next note or function from the music stream and programs the 8912 accordingly.
; rf should point at the music stream.
;--
        proc    psg_play_stream
        
playlp:	 sex  r3      ; set x = p for inline data        
         out  GROUP   ; select the base board I/O group for Input
         db   BASEGRP 
         BRNI playon  ; check for input to cancel
         stc          ; Set DF to indicate play stopped  
         sex  r2      ; set x back to stack pointer for return
         RETURN       ; return if input pressed    

playon: out  GROUP    ; set back to the PSG Group
        db   PSGGRP 
        sex  r2       ; set x back to stack pointer

        ldn  rf		    ; look ahead at the next byte
	      ani  $80      ; check only the MSB
	      lbnz play1	  ; branch if it's a tone generator function

; It's a delay - this byte and the next byte are the interval, in milliseconds.
	      lda	 rf       ; get the first delay byte
	      phi  rd		    ; they're in big endian ordering
	      lda  rf		    ; and the second delay byte
	      plo  rd		    ; ...
;   We just delay using a loop at the DLY1MS macro, the latter which will adjust
; for the CPU clock frequency.  The bad thing is that the DLY1MS macro suffers
; from roundoff errors, and if we use it inside a loop then those errors will
; accumulate.  That makes the actual delay here a bit unpredictable.  It'd be
; nice to fix this, but for the moment we'll just live with it.
play10:	glo  rd
        str  r2	      ; see if the count is zero
	      ghi  rd
        or		        ; ...
	      lbz  playlp		; quit when it's zereo
        
        ldi  DLYCONST ; delay for 1 ms
dly1ms: smi  1        ; count down until timer gone
        bnz  dly1ms
        
	      dec  rd
        lbr  play10   ; decrement the count until it's zero

;   It's not a delay.  A byte of $9t (where 't' is the tone generator number)
; starts a tone playing, and $8t stops it.  Officially the only other defined
; value is $F0, which means end of tune, but we interpret anything else as the
; end and stop playing.

play1:	ldn  rf		    ; get the byte code again
	      ani	 $F0		  ; look at just the top nibble
	      smi	 $90		  ; check for $80 or $90
	      lbz	 play3		; branch if $90 - start a tone
	      lbnf play2		; branch if $80 - stop a tone
quit:   sex  r3       ; set x = P for inline data
        out  GROUP    ; select the base board I/O group again
        db   BASEGRP 
        clc           ; make sure DF is off
        sex  r2       ; set x = SP for return  
        RETURN			  ; otherwise we're done playing - quit!

;   Stop a tone generator.  This is a single byte code, and the lower nibble is
; the tone generator index - 0 .. 5.  In theory there could be more tone
; generators (up to 16, I guess) but the SBC1802 hardware only has six.
play2:	lda  rf
        ani  $0F 
        plo  rd	      ; put tone generator number in rd.0
	      CALL jtone		; jump indirectly to the right MUTE routine
	      dw	 mutetb		;  ... table of six mute functions
	      lbr  playlp		; and then keep playing


; Start a tone generator.  This is a two byte code - the lower nibble of the
; first byte is the tone generator number, just like for MUTE.  The second
; byte is the MIDI note number, from 0 to 127.  The MIDI note number we have to
; actually look up in the note table in order to translate it to a counter
; value for the 8910 tone generator...
play3:	lda  rf
        ani  $0F
        plo  rd	      ; put tone generator number in rd.0
	      lda  rf
        phi  rd		    ; put the note number in rd.1
	      CALL jtone		; jump indirectly to the right PLAY routine
	      dw	 playtb		;  ... table of six play functions
	      lbr  playlp		; then keep playing

; Start PSG Tone Generators

; Play the MIDI note in D on PSG#1 tone generator A ...
playa1:	CALL ldnote	  ; get the tone generator setting
        glo  rd
        lbnz conta1   ; non-zero so continue
        ghi  rd
        lbz  mutea1   ; if zero mute channel instead
        glo  rd
conta1: CALL wrpsg1 	; write the low tone byte to R0
        db	 PSGR0		;  ...
        ghi  rd
        CALL wrpsg1	  ; write the high tone byte to R1
        db	 PSGR1		;  ...
        sex  r3		    ; set x = PC for output
        ; OUTPSG1(PSGR10, PSGVOL)	; and finally unmute channel A
        out  PSG1ADR 
        db   PSGR10
        out  PSGDATA
        db   PSGVOL
        sex  r2       ; set x = SP for return
        RETURN			  ; all done

; Play the MIDI note in D on PSG#2 tone generator A ...
playa2:	CALL ldnote		; get the tone generator setting
        glo  rd
        lbnz conta2   ; non-zero so continue
        ghi  rd
        lbz  mutea2   ; if zero mute channel instead
        glo  rd
conta2: CALL wrpsg2 	; write the low tone byte to R0
        db	 PSGR0		;  ...
        ghi  rd
        CALL wrpsg2  	; write the high tone byte to R1
        db	 PSGR1		;  ...
        sex  r3		    ; set x = PC for output
        ; OUTPSG2(PSGR10, PSGVOL)	; and finally unmute channel A
        out  PSG2ADR 
        db   PSGR10
        out  PSGDATA
        db   PSGVOL
        sex  r2       ; set x = SP for return
        RETURN			  ; all done

; Play the MIDI note in D on PSG#1 tone generator B ...
playb1:	CALL ldnote		; get the tone generator setting
        glo  rd
        lbnz contb1   ; non-zero so continue
        ghi  rd
        lbz  muteb1   ; if zero mute channel instead
        glo  rd
contb1: CALL wrpsg1 	; write the low tone byte to R2
        db	 PSGR2		;  ...
        ghi  rd
        CALL wrpsg1 	; write the high tone byte to R3
        db	 PSGR3		;  ...
        sex  r3		    ; set x = PC for output
        ; OUTPSG1(PSGR11, PSGVOL)	; and finally unmute channel B
        out  PSG1ADR 
        db   PSGR11
        out  PSGDATA
        db   PSGVOL
        sex  r2       ; set x = SP for return
        RETURN			  ; all done

; Play the MIDI note in D on PSG#2 tone generator B ...
playb2:	CALL ldnote		; get the tone generator setting
        glo  rd
        lbnz contb2   ; non-zero so continue
        ghi  rd
        lbz  muteb2   ; if zero mute channel instead
        glo  rd
contb2: CALL wrpsg2 	; write the low tone byte to R2
        db	 PSGR2		;  ...
        ghi  rd
        CALL wrpsg2 	; write the high tone byte to R3
        db	 PSGR3		;  ...
        sex  r3		    ; set x = PC for output
; OUTPSG2(PSGR11, PSGVOL)	; and finally unmute channel B
        out  PSG2ADR 
        db   PSGR11
        out  PSGDATA
        db   PSGVOL
        sex  r2       ; set x = SP for return
        RETURN			  ; all done

; Play the MIDI note in D on PSG#1 tone generator C ...
playc1:	CALL ldnote		; get the tone generator setting
        glo  rd
        lbnz contc1   ; non-zero so continue
        ghi  rd
        lbz  mutec1   ; if zero mute channel instead
        glo  rd
contc1: CALL wrpsg1	  ; write the low tone byte to R4
        db	 PSGR4		;  ...
        ghi  rd
        CALL wrpsg1 	; write the high tone byte to R5
        db	 PSGR5		;  ...
        sex  r3		    ; set x = PC for output
; OUTPSG1(PSGR12, PSGVOL)	; and finally unmute channel C
        out  PSG1ADR 
        db   PSGR12
        out  PSGDATA
        db   PSGVOL
        sex  r2       ; set x = SP for return
        RETURN			  ; all done

; Play the MIDI note in D on PSG#2 tone generator C ...
playc2:	CALL ldnote 	; get the tone generator setting
        glo  rd
        lbnz contc2   ; non-zero so continue
        ghi  rd
        lbz  mutec2   ; if zero mute channel instead
        glo  rd
contc2: CALL wrpsg2 	; write the low tone byte to R4
        db	 PSGR4		;  ...
        ghi  rd
        CALL wrpsg2   ; write the high tone byte to R5
        db	 PSGR5		;  ...
        sex  r3		    ; set x = PC for output
; OUTPSG2(PSGR12, PSGVOL)	; and finally unmute channel C
        out  PSG2ADR 
        db   PSGR12
        out  PSGDATA
        db   PSGVOL 
        sex  r2       ; set x = SP for return
        RETURN			; all done

;	Mute PSG Tone Generators

; Mute channel A1 ...
mutea1:	sex  r3		    ; set x = PC for output
; OUTPSG1(PSGR10, $00)	; set the volume for PSG#1 channel A to zero
        out  PSG1ADR 
        db   PSGR10
        out  PSGDATA
        db   $00
        sex  r2       ; set x = SP for return
        RETURN			  ; ...

; Mute channel A2 ...
mutea2:	sex  r3		    ; set x = PC for output
; OUTPSG2(PSGR10, $00)	; ...
        out  PSG2ADR 
        db   PSGR10
        out  PSGDATA
        db   $00
        sex  r2       ; set x = SP for return
        RETURN			  ; set PSG#2 channel A to zero

; Mute channel B1 ...
muteb1:	sex  r3		    ; set x = PC for output
; OUTPSG1(PSGR11, $00)	; ...
        out  PSG1ADR 
        db   PSGR11
        out  PSGDATA
        db   $00
        sex  r2       ; set x = SP for return
        RETURN			  ; ...

; Mute channel B2 ...
muteb2:	sex  r3		    ; set x = PC for output
; OUTPSG2(PSGR11, $00)	; ...
        out  PSG2ADR 
        db   PSGR11
        out  PSGDATA
        db   $00
        sex  r2       ; set x = SP for return
        RETURN			; ...

; Mute channel C1 ...
mutec1:	sex  r3		    ; set x = PC for output
; OUTPSG1(PSGR12, $00)	; ...
        out  PSG1ADR 
        db   PSGR12
        out  PSGDATA
        db   $00
        sex  r2       ; set x = SP for return
        RETURN			; ...

; Mute channel C2 ...
mutec2:	sex  r3		    ; set x = PC for output
; OUTPSG2(PSGR12, $00)	; ...
        out  PSG2ADR 
        db   PSGR12
        out  PSGDATA
        db   $00
        sex  r2       ; set x = SP for return
        RETURN			; ...


;++  	Tone Generator to PSG Channel Mapping
;   The SBC1802 contains two AY-3-8912 sound generator chips, each one of which
; contains three independent tone generators designated A, B and C.  The audio
; output jack on the SBC1802 is stereo with, effectively, three channels - left,
; right and middle (i.e. both).  The hardware maps tone generator C in both PSG
; chips to the middle, generator A in both PSGs to the right channel, and tone
; generator C to the left.
;
;   The MIDITONES data stream can reference up to six tone generators, which
; we map onto chips, channels and stereo as follows -
;
;	tone generators 0 & 1	-> center (both left and right)
;	tone generators 2 & 4	-> right
;	tone generators 3 & 5	-> left
;
;  These two tables, PLAYTB and MUTETB, map the MIDITONES index onto the
; actual PSG chip and channel as above.   It's important that they stay in
; sync (e.g. muting tone generator #3 should stop the note that was played on
; tone generator #3!).
;--

; Table of play routines ...
playtb: dw	playc1		; play tone generator #1
	      dw	playc2		; ... #2
	      dw	playa1		; ... #3
	      dw	playb1		; ... #4
	      dw	playa2		; ... #5
	      dw	playb2		; ... #6

; Table of MUTE routines ...
mutetb:	dw	mutec1		; mute tone generator #1
	      dw	mutec2		; ... #2
	      dw	mutea1		; ... #3
	      dw	muteb1		; ... #4
	      dw	mutea2		; ... #5
	      dw	muteb2		; ... #6


;++
;   This routine will jump indirectly based on the tone generator index.  The
; index must be 0..5 (values of 6 and up are ignored) and in the case of play,
; the MIDI note number should be passed in rd.1.
;
;CALL:
;	rd.1/ MIDI note number
;	rd.0/ tone generator number
;	CALL(JTONE)
;	 dw	 TGTAB
;	<RETURN>
;
;TGTAB:	dw	TONE1		; PLAY/MUTE routine for tone generator #1
;	...
;	dw	TONE6		;  "    "     "      "    "   "     "  #6
;--
jtone:	glo  rd
        smi  6		    ; is the tone generator .GE. 6 ?
	      lsnf          ; return now if .GE. 6  
        RETURN
        nop	
	      glo  rd
        shl
        str  r2       ; multiply the tone generator index by 2
	      inc  r6
        ldn  r6		    ; get the low byte of the table address
	      add
        plo  r7
        dec  r6	      ; index into the dispatch table
        lda  r6
        adci 0		    ;  ... and carry the high byte
	      phi  r7
        inc  r6		    ;  ...
        LOAD r8, jtone1   ;	RLDI(T2,JTONE1)\ SEP T2	
        sep  r8     
; Here to copy MEM(r7) to r3 and continue ...
jtone1: lda  r7
        phi  r3
        lda  r7
        plo  r3
	      ghi  rd		    ; put the note number in D
	      sep	 r3		    ; branch to the PLAY/MUTE routine and return


; Write the byte in D to the PSG#1 register indicated inline ...
wrpsg1:	sex  r6
        out  PSG1ADR	; send register number to the PSG, increment r6
	      lskp			    ; join the common code
; Write the byte in D to the PSG#2 register indicated inline ...
wrpsg2:	sex  r6
        out  PSG2ADR	; send register number to the PSG, increment A
        
	      sex  r2 
        str  r2		    ; save D on the TOS
	      out  PSGDATA
        dec  r2	      ; and write the data byte
	      RETURN			  ; and we're done



; Load the note table entry for the note in D into rd ...
ldnote:	str  r2                 ; save note value in M(X)
        glo  rc                 ; get midi key offset
        add       		          ; transpose the note if desired
	      shl     			          ; multiply the index by two
        lbnf ld_ok              ; if DF = 0, index + offset within table
        ldi  0                  ; if out of range, set to zero
        plo  rd                 ; return with zero to mute channel
        phi  rd
        RETURN
ld_ok:  adi	 midinote.0	        ; index into the MIDI note table
	      plo  r7		              ; and save that in the pointer
	      ldi  midinote.1	        ; then set the high part 
	      adci 0             		  ; include any carry
	      phi  r7		              ; set the rest of the pointer
	      lda  r7                 ; get the note high byte
        phi  rd		   
	      ldn  r7
        plo  rd		              ; and the low byte
        RETURN			
        endp
