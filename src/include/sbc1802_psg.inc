;   The EXP1802 expansion board implements a number of additional options, most
; notably an RCA style I/O group selection register.  If the expansion board is
; installed then ALL I/O instructions must be preceded by the correct group
; selection!  If the expansion board is not present then I/O group selection is
; a harmless NOP.  All base board options are in group 1.

;   Note that groups 8 and up are reserved for future options and those group
; selection bits are available on the expansion bus connector.

#define GROUP	  	1	  ; port 1 is always the I/O group selection
#define BASEGRP	 	$1	; I/O group for all base board devices
#define SL1GRP	  $4	;  "    "    "  CDP1854 SLU1
#define TMRGRP	  $6	;  "    "    "  CDP1878 counter/timer
#define PPIGRP	  $5	;  "    "    "  CDP1851 parallel interface
#define PSGGRP	  $7	; I/O group for AY-3-8912 sound generator

#define BRNI      bn1 ; branch on no imput (/EF1 on SBC1802)

; *** AY-3-8912 PSG I/O group definitions ***
;   Note that the SBC1802 has two PSG chips, and there's a PSG1ADR and also a
; PSG2ADR defined here.  There is, however, ONLY ONE PSGDATA address!  That's
; not a mistake - see the comments on the PSG page for more details.

#define PSG1ADR	  2	; PSG #1 register address (write only)
#define PSG2ADR	  6	; PSG #2 register address (write only)
#define PSGDATA	  3	; PSG data port (read/write) (BOTH PSGs!)


; *** AY-3-8912 Programmable Sound Generator Definitions ***
;   Note that the AY-3-8910, 8912 and 8913 are all identical as far as the
; software is concerned.  They differ only in package, pin out and hardware
; interface.
;
;   The 8912 has an A8 address input which must be 1 to select the chip.  In
; the SBC1802, which has two 8912 PSG chips, A8 is wired up to NOT N2 for
; PSG#1, and N2 for PSG#2.  The funky thing about the AY-3-891x chips is that
; this A8 input is LATCHED WHEN THE REGISTER ADDRESS IS LOADED!  A8 is totally
; ignored when reading or writing the PSG data port.  This means that the
; following sequence doesn't work as you might expect -
;
;	SEX r3 
;	out  PSGR17
;	out PSG2ADR 
;   db PSGR16
;	out PSG1DATA
;   db $55
;	out PSG2DATA
;   db $AA
;
;   In this case both writes to the PSG data port will write to PSG#2 because
; it was the last address loaded.  PSG#1 will be unaffected by this sequence!
; The correct way would be to do this instead -
;
;	SEX r3 
;	out PSG1ADR  
;   db PSGR17
;	out PSGDATA
;   db $55
;	out PSG2ADR  
;   db PSGR16
;	out PSGDATA  
;   db $AA
;
;   The bottom line is that you should always load the PSG address register
; before reading or writing the data port.   This also why there are two 1802
; PSG I/O addresses defined, but only one PSG data port.  Awkward, but we can
; program around it...
;
;   Another useful factoid is that the 8910 actually decodes all eight bits of
; the register select address.  Yes, there are only 16 registers so only the
; lower four bits select the register, but the upper four bits MUST be zero or
; the chip will ignore us.  Most of the time, that is - it turns out that GI
; would actually manufacture custom version of the 8910 that expected other,
; non-zero, nibbles on the upper four register select bits.  The idea was to
; allow multiple PSG chips on the same bus to be separately addressed by these
; extra bits in the register address.  Normally any 8910 chip a hobbyist bought
; would want to see zeros on these bits, but these days IC pulls and surplus
; parts have found their way onto the market and you will sometimes find chips
; that want non-zero select codes.  There's no real way to find out, except by
; trial and error...
;--
#define PSGSEL		$00		; PSG select code*16 (e.g. $10, $20, etc)

;   Define mnemonics for the PSG registers just to make it easier to use the
; GI documentation.  BTW, note that GI numbered the registers in OCTAL!

#define PSGR0	    PSGSEL+$0	; tone generator low byte, channel A
#define PSGR1     PSGSEL+$1	;  "    "    "   high  " ,    "    "
#define PSGR2		  PSGSEL+$2	;  "    "    "   low byte, channel B
#define PSGR3		  PSGSEL+$3	;  "    "    "   high  " ,    "    "
#define PSGR4		  PSGSEL+$4	;  "    "    "   low byte, channel C
#define PSGR5		  PSGSEL+$5	;  "    "    "   high  " ,    "    "
#define PSGR6		  PSGSEL+$6	; noise generator control
#define PSGR7		  PSGSEL+$7	; mixer and I/O control
#define PSGR10	  PSGSEL+$8	; amplitude control, channel A
#define PSGR11		PSGSEL+$9	;  "     "     "        "    B
#define PSGR12		PSGSEL+$A	;  "     "     "        "    C
#define PSGR13		PSGSEL+$B	; envelope period, low byte
#define PSGR14		PSGSEL+$C	;  "    "     "    high  "
#define PSGR15		PSGSEL+$D	; envelope shape and cycle control
#define PSGR16		PSGSEL+$E	; I/O port A data
#define PSGR17		PSGSEL+$F	;  "   "   B   "

#define PSGVOL	  7        	; default volume (0..15)

; offset constant for midi notes
#define PSGKEY    (-36+12)

#define DLYCONST	(5000/32)
