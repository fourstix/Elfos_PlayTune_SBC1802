[Your_Path]\Asm02\asm02 -L psg_begin.asm
[Your_Path]\Asm02\asm02 -L psg_detect.asm
[Your_Path]\Asm02\asm02 -L psg_play_stream.asm
[Your_Path]\Asm02\asm02 -L psg_midi_notes.asm
[Your_Path]\Asm02\asm02 -L psg_end.asm
[Your_Path]\Asm02\asm02 -L psg_player.asm

type psg_player.prg psg_begin.prg psg_detect.prg psg_play_stream.prg psg_midi_notes.prg psg_end.prg > psg_sbc1802.lib
