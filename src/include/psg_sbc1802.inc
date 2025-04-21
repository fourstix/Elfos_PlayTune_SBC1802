;-------------------------------------------------------------------------------
; This library supports the AY-3-8912 sound chips on the EXP1802 expansion 
; card running on the SBC1802 mini-computer. 
; Copyright 2025 by Gaston Williams
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


;-------------------------------------------------------------------------------
; Public library routine to play a stream from miditunes.
;
; Parameters:
;   RF = pointer to buffer with miditunes data
;
; Returns: 
;   DF = 1 Play stopped by user pressing Input
;   DF = 0 Entire song played
;-------------------------------------------------------------------------------

            extrn   psg_player
;-------------------------------------------------------------------------------
; Public library routine to detect psg hardware
;
; Parameters:
;   (None)
;
; Returns: 
;   DF = 1 Error, PSG not found
;   DF = 0 OK, PSG found
;-------------------------------------------------------------------------------            
            extrn   psg_detect
