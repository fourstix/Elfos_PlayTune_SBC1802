# Elfos_PlayTune_SBC1802
An 1802 Library and programs for the SBC1802 AY-3-8912 Programmable Sound Generators (PSG).
The library and programs were assembled into 1802 binary files using the [Asm/02 1802 Assembler](https://github.com/fourstix/Asm-02), the [Link/02 1802 Linker](https://github.com/fourstix/Link-02).

Platform  
--------

These programs were written to run on a Spare Time Gizmos [SBC1802 microcomputer](https://github.com/SpareTimeGizmos/SBC1802) with the Expansion Board.  The Expansion board must have both AY-3-8912 programmable sound generator chips installed.


Playtune
---------

## playtune
**Usage:** playtune [-f | -sn | -on] [*filename*]    
Play the miditones tune file *filename* through the PSG chips on the SBC1802 Expansion board. Pressing input will stop the playing immediately. The option -f (*force*) will play the file
without checking for the presence of the PSG chips. The option -sn  where n is a positive or negative integer, while shift the pitch up (positive) or down (negative) n half-tones. The option -on  where n is a positive or negative integer, while shift the pitch up (positive) or down (negative) n octaves.

Demo Programs
--------------

## ruins_athens
**Usage:** minuet    
Plays the *Turkish March* from *The Ruins of Athens by Beethoven* through the PSG chips on the SBC1802 Expansion board.  This file demonstrates how to play a tune through an assembly file listing using the PSB_SBC1802 library.

## minuet
**Usage:** minuet    
Plays the *Minuet in G by JS Bach/Christian Petzold* through the PSG chips on the SBC1802 Expansion board. This file demonstrates how to play a tune with a pitch change to the data in the assembly file listing using the PSB_SBC1802 library.


PSG_SBC1802 Library
---------------------



Tools
-----

The tune files were created using [Miditones](https://github.com/LenShustek/miditones) by Len Shustek to convert midi files to a time ordered sequence of note commands the AY-3-8912 PSG's.  

The tunes were created using the basic set of options *-t=6 -pi -b* for 6 channels, no percussion and binary output.  In some cases the *-c0x3f* option was used to restrict the conversion to the first 6 channels only.  The assembly program listings were created using the *-asm1802* option instead of the *-b* option to output an assembly listing compatible for most 1802 assemblers.  

Tunes
------
* athens.tune - Turkish March from *The Ruins of Athens* by Ludwig van Beethoven
* fur_elise.tune - Fur Elise (Bagatelle No. 25) by Ludwig van Beethoven
* jesu.tune - Jesu, Joy of Man's Desiring (BWV 147) by J.S. Bach
* prelude.tune - Prelude from Cello Suite No. 1 (BWV 1007) by J.S. Bach
* rondo.tune - Rondo alla Turk from Piano Sonata No. 11 (K 331) by Wolfgang Mozart
* scales.tune - Traditional scales practice tune

Repository Contents
-------------------
 
* **/src/**  -- Common source files for assembling Elf/OS utilities.
* **/src/include/**  -- Include files for Elf/OS file utilities.
  * ops.inc - Opcode definitions for Asm/02.
  * bios.inc - Bios definitions from Elf/OS
  * kernel.inc - Kernel definitions from Elf/OS
  * psg_sbc1802.inc - PSG_SBC1802 library public API definitions.
  * sbc1802_psg.inc - PSG SBC1802 hardware definitions.
* **/src/demo/**  -- Source files for PSG SBC1802 demo programs.
  * build.bat - Windows batch file to assemble the demo source files with Asm/02 to create object files and then use Link/02 to link the object files into a binary file.
  * clean.bat - Windows batch file to delete binary and object files from previous builds.

License Information
-------------------
  
This code is public domain under the MIT License, but please buy me a beverage
if you use this and we meet someday (Beerware).
  
References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.
  
Any company, product, or services names may be trademarks or services marks of others.
  
All libraries used in this code are copyright their respective authors.
  
This code is based on a Elf/OS code libraries written by Mike Riley and assembled with the Asm/02 assembler also written by Mike Riley.
  
Elf/OS 
Copyright (c) 2004-2024 by Mike Riley

Mini-DOS 
Copyright (c) 2024-2025 by David Madole
  
Asm/02 1802 Assembler 
Copyright (c) 2004-2024 by Mike Riley
     
The STG SBC1802 Baseboard hardware 
Copyright (c) 2024-2025 by Spare Time Gizmos.
  
SBC1802 Expansion Card hardware 
Copyright (c) 2024-2025 by Spare Time Gizmos.
  
The 1802-Mini Microcomputer Hardware 
Copyright (c) 2020-2024 by David Madole
  
Many thanks to the original authors for making their designs and code available as open source.
   
This code, firmware, and software is released under the [MIT License](http://opensource.org/licenses/MIT).
  
The MIT License (MIT)
  
Copyright (c) 2025 by Gaston Williams
  
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
  
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
  
**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.**
