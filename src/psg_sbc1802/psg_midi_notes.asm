;-------------------------------------------------------------------------------
; This library supports the AY-3-8912 sound chips on the EXP1802 expansion 
; card running on the SBC1802 mini-computer. 
;-------------------------------------------------------------------------------
; This table is indexed by the MIDI note number, 0..127, and gives the
; corresponding 8912 tone generator setting.  In the SBC1802 the 8912 clock
; is the baud rate clock, 4.9152Mhz, divided by 4.  So these values are
; calculated assuming a 1.2288MHz clock for the 8912.
;
;   Note that this table contains only six octaves worth of notes to save
; space, although MIDI allows for much more.  The PSGKEY symbol is the offset
; applied to each note to get the correct table entry, remembering of course
; that each octave is 12 notes.
;--
; psgkey offset is (-36+12)
;-------------------------------------------------------------------------------

        proc  midinote
;		     A      A#     B     C      C#      D      D#     E      F      F#     G      G#
	dw	 4697,  4433,  4184,  3950,  3728,  3519,  3321,  3135,  2959,  2793,  2636,  2488
	dw	 2348,  2217,  2092,  1975,  1864,  1759,  1661,  1567,  1479,  1396,  1318,  1244
	dw	 1174,  1108,  1046,   987,   932,   880,   830,   784,   740,   698,   659,   622
	dw	  587,   554,   523,   494,   466,   440,   415,   392,   370,   349,   329,   311
	dw	  294,   277,   262,   247,   233,   220,   208,   196,   185,   175,   165,   156
	dw	  147,   139,   131,   123,   116,   110,   104,    98,    92,    87,    82,    78
        endp
