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
;              C      C#     D      D#     E      F      F#     G      G#    A      A#     B
; 12-bit maximum value is 4095 so anything higher rolls over to produce wolf notes
;   dw       9394,  8866,  8369,  7899,  7456,  7037,  6642,  6269,  5918,  5585,  5272,  4976      ; octave -1
;   dw       4697,  4433,  4184,  3950,  3728,  3519,  3321,  3135,  2959,  2793,  2636,  2488      ; octave 0

;              C      C#     D      D#     E      F      F#     G      G#    A      A#     B
    dw          0,     0,     0,    0,     0,      0,     0,     0,     0,     0,     0,    0,      ; wolf notes
    dw          0,     0,  4095,  3950,  3728,  3519,  3321,  3135,  2959,  2793,  2636,  2488      ; octave 0
    dw       2348,  2217,  2092,  1975,  1864,  1759,  1661,  1567,  1479,  1396,  1318,  1244      ; octave 1
    dw       1174,  1108,  1046,   987,   932,   880,   830,   784,   740,   698,   659,   622      ; octave 2
    dw        587,   554,   523,   494,   466,   440,   415,   392,   370,   349,   329,   311      ; octave 3
    dw        294,   277,   262,   247,   233,   220,   208,   196,   185,   175,   165,   156      ; octave 4
    dw        147,   139,   131,   123,   116,   110,   104,    98,    92,    87,    82,    78      ; octave 5
    dw         73,    69,    65,    62,    58,    55,    52,    49,    46,    44,    41,    39      ; octave 6
    dw         37,    35,    33,    31,    29,    27,    26,    24,    23,    22,    21,    19      ; octave 7

    ; octave 8 and 9 have notes that are too far off-key (wolf notes) 
    dw         18,    17,    16,     0,     0,     0,     0,     0,     0,     0,     0,    0,      ; wolf notes
    dw          0,     0,     0,     0,     0,     0,     0,     0

;   Original Midi table values for reference 
;    dw         73,    69,    65,    62,    58,    55,    52,    49,    46,    44,    41,    39      ; octave 6
;    dw         37,    35,    33,    31,    29,    27,    26,    24,    23,    22,    21,    19      ; octave 7
;    dw         18,    17,    16,    15,    15,    14,    13,    12,    12,    11,    10,    10      ; octave 8
;    dw          9,     9,     8,     8,     7,     7,     6,     6

        endp
