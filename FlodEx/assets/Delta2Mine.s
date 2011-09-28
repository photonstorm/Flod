  section player,data_c

start:
  move.l  4,a6
  jsr     -132(a6)
  bsr     dm2_init
sync:
  cmp.b   #128,$dff006
  bne.s   sync
  bsr     dm2_play_music
  btst    #6,$bfe001
  bne.s   sync
  clr.l   $dff0a6
  clr.l   $dff0b6
  clr.l   $dff0c6
  clr.l   $dff0d6
  move.w  #$000f,$dff096
  bclr    #1,$bfe001
  move.l  4,a6
  jmp     -138(a6)
  rts


dm2_play_music:
  movem.l d0-a6,-(sp)                       ;store registers
  lea     song_data(pc),a6                  ;song data in a6
  clr.b   1(a6)                             ;reset song data dma bit
  movea.l 30(a6),a3                         ;waveforms table address in a3
  move.l  42(a6),d1                         ;noise value in d1
  moveq   #15,d0                            ;loop counter
dm2_noise:
  rol.l   #7,d1                             ;random noise
  addi.l  #$6eca756d,d1                     ;calc
  eori.l  #$9e59a92b,d1                     ;calc
  move.l  d1,(a3)+                          ;store in 1st waveform
  dbf     d0,dm2_noise                      ;loop
  move.l  d1,42(a6)                         ;store last noise value in song data
  subq.b  #1,48(a6)                         ;decrease song data speed counter
  bpl.s   dm2_timer                         ;if >= 0 goto dm2_timer
  move.b  47(a6),48(a6)                     ;else reset replay speed
dm2_timer:
  lea     channel1(pc),a0                   ;channel1 in a0
  bsr.w   dm2_play_voice                    ;gosub dm2_play_voice
  lea     channel2(pc),a0                   ;channel2 in a0
  bsr.w   dm2_play_voice                    ;gosub dm2_play_voice
  lea     channel3(pc),a0                   ;channel3 in a0
  bsr.w   dm2_play_voice                    ;gosub dm2_play_voice
  lea     channel4(pc),a0                   ;channel4 in a0
  bsr.w   dm2_play_voice                    ;gosub dm2_play_voice
  move.w  (a6),$dff096                      ;set dmacon
  movem.l (sp)+,d0-a6                       ;restore registers
  rts                                       ;return

dm2_play_voice:
  movea.l (a0),a1                           ;amiga channel base address in a1
  movea.l 6(a0),a2                          ;instruments header pointer in a2
  tst.b   51(a0)                            ;test instrument type
  bpl.s   dm2_synth                         ;if >= 0 goto dm2_synth
  clr.b   51(a0)                            ;else reset instrument type
  moveq   #0,d0                             ;clear d0
  movea.l 38(a6),a3                         ;samples offset table in a3
  move.b  39(a2),d0                         ;instrument sample number in d0
  andi.b  #7,d0                             ;sample # mask
  asl.l   #2,d0                             ;multiply by 4
  adda.l  d0,a3                             ;add to samples table
  movea.l (a3),a4                           ;sample address in a4
  adda.l  34(a6),a4                         ;add sample data address
  moveq   #0,d0                             ;clear d0
  move.w  4(a2),4(a1)                       ;set amiga channel length
  move.w  2(a2),d0                          ;sample repeat in d0
  clr.w   (a4)                              ;clear first 2 bytes of the sample
  adda.l  d0,a4                             ;add repeat pointer
  move.l  a4,(a1)                           ;set amiga channel pointer
dm2_synth:
  tst.b   48(a6)                            ;test song data speed counter
  bne.w   dm2_block                         ;if != 0 goto dm2_block
  tst.w   20(a0)                            ;test voice block position
  bne.s   dm2_check_block                   ;if != 0 goto dm2_check_block
  moveq   #0,d0                             ;clear d0
  movea.l 10(a0),a3                         ;voice track address in a3
  move.w  18(a0),d1                         ;voice track position in d1
  move.b  (a3,d1.w),d0                      ;new block number in d0
  move.b  1(a3,d1.w),43(a0)                 ;store note transpose in voice
  asl.l   #6,d0                             ;multiply block # by 64
  add.l   26(a6),d0                         ;add block data address
  move.l  d0,14(a0)                         ;store block address in voice
  addq.w  #2,d1                             ;increase track position
  move.w  d1,18(a0)                         ;store new track position in voice
  cmp.w   56(a0),d1                         ;compare track position
  bmi.s   dm2_check_block                   ;if < track length goto dm2_check_block
  move.w  54(a0),18(a0)                     ;copy start track position in voice track position
dm2_check_block:
  moveq   #0,d0                             ;clear d0
  movea.l 14(a0),a3                         ;voice block address in a3
  move.w  20(a0),d0                         ;voice block position in d0
  adda.l  d0,a3                             ;add position offset
  moveq   #0,d0                             ;clear d0
  move.b  (a3),d0                           ;note in d0
  beq.w   dm2_effect                        ;if no note goto dm2_effect
  move.w  4(a0),$dff096                     ;disable amiga channel
  move.b  d0,28(a0)                         ;store note in voice
  lea     freq_table(pc),a4                 ;freq_table in a4
  add.b   43(a0),d0                         ;add note transpose to note
  add.w   d0,d0                             ;multiply by 2
  move.w  (a4,d0.w),26(a0)                  ;store period in voice
  moveq   #0,d1                             ;clear d1
  move.b  1(a3),d1                          ;instrument # in d1
  add.l   d1,d1                             ;multiply by 2
  subq.w  #2,d1                             ;subtract 2
  movea.l 6(a6),a4                          ;instruments offset table in a4
  adda.l  d1,a4                             ;add offset
  moveq   #0,d2                             ;clear d2
  move.w  (a4),d2                           ;instrument header address in d2
  add.l   2(a6),d2                          ;add instruments header base address
  move.l  d2,6(a0)                          ;store instrument header address in voice
  movea.l d2,a2                             ;instrument header in a2
  move.b  38(a2),51(a0)                     ;copy instrument type in voice
  bpl.s   dm2_synth2                        ;if >= 0 goto dm2_synth2
  moveq   #0,d0                             ;clear d0
  movea.l 38(a6),a4                         ;sample offset table in a4
  move.b  39(a2),d0                         ;instrument sample # in d0
  andi.b  #7,d0                             ;sample # mask
  asl.l   #2,d0                             ;multiply by 4
  adda.l  d0,a4                             ;add result to offset table
  movea.l (a4),a4                           ;sample address in a4
  adda.l  34(a6),a4                         ;add samples data base address
  move.l  a4,(a1)                           ;set amiga channel pointer
  move.w  (a2),4(a1)                        ;set amiga channel length with instrument length
dm2_synth2:
  clr.b   22(a0)                            ;reset voice sample number
  clr.b   23(a0)                            ;reset voice waveform step
  clr.w   32(a0)                            ;reset voice volume
  clr.b   36(a0)                            ;reset voice volume sustain
  clr.w   34(a0)                            ;reset voice volume step
  clr.w   48(a0)                            ;reset voice arpeggio step
  clr.b   39(a0)                            ;reset voice vibrato direction
  clr.w   40(a0)                            ;reset voice vibrato period
  move.b  22(a2),42(a0)                     ;store first vibrato length from table in voice
  clr.b   52(a0)                            ;reset voice vibrato step
  move.b  23(a2),53(a0)                     ;store first vibrato sustain from table in voice
dm2_effect:
  move.b  2(a3),d0                          ;effect number in d0
  subq.b  #1,d0                             ;decrease by 1
  bmi.s   dm2_no_effect                     ;if < 0 goto dm2_no_effect
  move.b  3(a3),d1                          ;effect data in d1
  lea     effects_table(pc),a4              ;effects table in a4
  andi.l  #7,d0                             ;effect number mask
  asl.l   #2,d0                             ;multiply by 2
  movea.l (a4,d0.w),a3                      ;add effect offset to table
  jsr     (a3)                              ;jump to effect function
dm2_no_effect:
  addq.w  #4,20(a0)                         ;increase voice block position
  andi.w  #63,20(a0)                        ;block position mask (0-63)
dm2_block:
  tst.b   38(a2)                            ;test instrument type
  bmi.s   dm2_vibrator                      ;if < 0 goto dm2_vibrator
  tst.b   22(a0)                            ;test voice waveform counter
  beq.s   dm2_waveform                      ;if 0 goto dm2_waveform
  subq.b  #1,22(a0)                         ;decrease waveform counter
  bra.s   dm2_vibrator                      ;goto dm2_vibrator

dm2_waveform:
  move.b  39(a2),22(a0)                     ;copy instrument waveform speed to voice waveform counter
  moveq   #0,d0                             ;clear d0
  moveq   #0,d2                             ;clear d2
  lea     40(a2),a3                         ;instrument waveform table in a3
  move.b  23(a0),d0                         ;voice waveform step in d0
dm2_read_again:
  move.b  d0,d1                             ;voice waveform step in d1
  move.b  (a3,d0.w),d2                      ;waveform table value in d2
  cmpi.b  #$ff,d2                           ;compare
  bne.s   dm2_wave_data                     ;if != $ff goto dm2_wave_data
  move.b  1(a3,d0.w),d0                     ;table restart position in d0
  move.b  (a3,d0.w),d2                      ;new value in d2
  cmpi.b  #$ff,d2                           ;test for $ff (to avoid infinite loop)
  bne.s   dm2_read_again                    ;if != goto dm2_read_again
  bra.s   dm2_vibrator                      ;goto dm2_vibrator
dm2_wave_data:
  asl.l   #8,d2                             ;multiply waveform # by 256
  add.l   30(a6),d2                         ;add waveforms table base address
  move.l  d2,(a1)                           ;set amiga channel pointer
  move.w  (a2),4(a1)                        ;set amiga channel length
  addq.b  #1,d1                             ;increase voice waveform step
  andi.b  #63,d1                            ;waveform step mask (0-63) (!!!wrong the table is only 48 bytes!!!)
  move.b  d1,23(a0)                         ;store result in voice

dm2_vibrator:
  moveq   #0,d0                             ;clear d0
  lea     21(a2),a3                         ;instrument vibrato table in a3
  move.b  52(a0),d0                         ;voice vibrato step in d0
  adda.l  d0,a3                             ;add step to table
  move.b  (a3),d0                           ;get value from table in d0
  tst.b   39(a0)                            ;test voice vibrato direction
  bne.s   dm2_vibrator_minus                ;if != 0 goto dm2_vibrator_minus
  add.w   d0,40(a0)                         ;add value to voice vibrato period
  bra.s   dm2_vibrator_reset                ;goto dm2_vibrator_reset
dm2_vibrator_minus:
  sub.w   d0,40(a0)                         ;subtract value from voice vibrato period
dm2_vibrator_reset:
  subq.b  #1,42(a0)                         ;decrease voice vibrato length
  bne.s   dm2_vibrator_sustain              ;if != 0 goto dm2_vibrator_sustain
  move.b  1(a3),42(a0)                      ;copy vibrato length from table in voice
  not.b   39(a0)                            ;invert voice vibrato direction
dm2_vibrator_sustain:
  tst.b   53(a0)                            ;test voice vibrato sustain
  beq.s   dm2_do_vibrator                   ;if 0 goto dm2_do_vibrator
  subq.b  #1,53(a0)                         ;else decrease voice vibrato sustain
  bra.s   dm2_volume                        ;goto dm2_volume
dm2_do_vibrator:
  addq.b  #3,52(a0)                         ;increase voice vibrato step
  cmpi.b  #15,52(a0)                        ;compare vibrato step
  bne.s   dm2_vibrato_reset_sustain         ;if != 15 goto dm2_vibrato_reset_sustain
  move.b  #12,52(a0)                        ;else store 12 in voice vibrato step
dm2_vibrato_reset_sustain:
  move.b  5(a3),53(a0)                      ;store new vibrato sustain value in voice

dm2_volume:
  tst.b   36(a0)                            ;test voice volume sustain
  beq.s   dm2_do_volume                     ;if 0 goto dm2_do_volume
  subq.b  #1,36(a0)                         ;decrease voice volume sustain
  bra.s   dm2_portamento                    ;goto dm2_portamento
dm2_do_volume:
  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  move.w  34(a0),d0                         ;voice volume step in d0
  lea     6(a2),a3                          ;instrument volume table in a3
  adda.l  d0,a3                             ;add step to table
  move.b  (a3),d0                           ;new volume speed from table in d0
  move.b  1(a3),d1                          ;new volume level from table in d1
  cmp.w   32(a0),d1                         ;compare voice volume
  bpl.s   dm2_volume_plus                   ;if new level >= voice volume goto dm2_volume_plus
  sub.w   d0,32(a0)                         ;subtract volume speed from voice volume
  cmp.w   32(a0),d1                         ;compare voice volume
  bmi.s   dm2_portamento                    ;if < new level goto dm2_portamento
  move.w  d1,32(a0)                         ;else store new level in voice volume
  addq.w  #3,34(a0)                         ;increment voice volume step
  move.b  2(a3),36(a0)                      ;store new volume sustain in voice
  bra.s   dm2_portamento                    ;goto dm2_portamento
dm2_volume_plus:
  add.w   d0,32(a0)                         ;add volume speed to voice volume
  cmp.w   32(a0),d1                         ;compare voice volume
  bpl.s   dm2_portamento                    ;if >= new level goto dm2_portamento
  move.w  d1,32(a0)                         ;else store new level in voice volume
  addq.w  #3,34(a0)                         ;increment voice volume step
  cmpi.w  #15,34(a0)                        ;compare volume step to 15
  bne.s   dm2_volume_no_reset               ;if != goto dm2_volume_no_reset
  move.w  #12,34(a0)                        ;else store 12 in voice volume step
dm2_volume_no_reset:
  move.b  2(a3),36(a0)                      ;store new volume sustain in voice

dm2_portamento:
  moveq   #0,d0                             ;clear d0
  move.b  37(a0),d0                         ;voice portamento speed in d0
  beq.s   dm2_arpeggio                      ;if 0 goto dm2_arpeggio
  move.w  26(a0),d1                         ;voice period in d1
  cmp.w   24(a0),d1                         ;compare to final period
  bpl.s   dm2_portamento_plus               ;if voice period >= final period goto dm2_portamento_plus
  sub.w   d0,24(a0)                         ;else subtract portamento speed from voice final period
  cmp.w   24(a0),d1                         ;compare to final period
  bmi.s   dm2_arpeggio                      ;if voice period < final period goto dm2_arpeggio
  move.w  d1,24(a0)                         ;else store voice period in voice final period
  bra.s   dm2_arpeggio                      ;goto dm2_arpeggio
dm2_portamento_plus:
  add.w   d0,24(a0)                         ;add portamento speed to final period
  cmp.w   24(a0),d1                         ;compare final period
  bpl.s   dm2_arpeggio                      ;if voice period >= final period goto dm2_arpeggio
  move.w  d1,24(a0)                         ;else store voice period in voice final period

dm2_arpeggio:
  moveq   #0,d0                             ;clear d0
  movea.l 44(a0),a3                         ;voice arpeggio table offset in a3
  move.w  48(a0),d1                         ;voice arpeggio step in d1
  move.b  (a3,d1.w),d0                      ;arpeggio value in d0
  tst.b   d1                                ;test voice arpeggio step
  beq.s   dm2_do_arpeggio                   ;if 0 goto dm2_do_arpeggio
  cmpi.b  #128,d0                           ;compare arpeggio value
  bne.s   dm2_do_arpeggio                   ;if != 128 goto dm2_do_arpeggio
  clr.w   48(a0)                            ;reset voice arpeggio step
  bra.s   dm2_arpeggio                      ;loop back
dm2_do_arpeggio:
  addq.w  #1,48(a0)                         ;increment voice arpeggio step
  andi.w  #15,48(a0)                        ;arpeggio length mask

  tst.b   37(a0)                            ;test voice portamento speed
  beq.s   dm2_arpeggio_period               ;if 0 goto dm2_arpeggio_period
  move.w  24(a0),d0                         ;else voice final period in d0
  bra.s   dm2_bendrate                      ;goto dm2_bendrate
dm2_arpeggio_period:
  lea     freq_table(pc),a3                 ;freq_table in a3
  add.b   28(a0),d0                         ;add voice note to arpeggio value
  add.b   43(a0),d0                         ;add voice note transpose
  add.w   d0,d0                             ;multiply by 2
  move.w  (a3,d0.w),d0                      ;get period from table
  move.w  d0,24(a0)                         ;store period in voice final period

dm2_bendrate:
  move.w  36(a2),d1                         ;instrument bendrate in d1
  sub.w   30(a0),d1                         ;subtract voice bendrate
  sub.w   d1,40(a0)                         ;subtract result from voice vibrato period
  add.w   40(a0),d0                         ;add voice vibrato period to final period
  move.w  d0,6(a1)                          ;set amiga channel period
  move.w  32(a0),d0                         ;voice volume in d0
  ror.w   #2,d0                             ;ror volume
  andi.w  #63,d0                            ;volume mask (0-63)
  cmp.b   29(a0),d0                         ;compare to channel volume
  bmi.s   dm2_set_volume                    ;if < goto dm2_set_volume
  move.b  29(a0),d0                         ;else voice channel volume in d0

dm2_set_volume:
  move.w  d0,8(a1)                          ;set amiga channel volume
  move.b  5(a0),d0                          ;voice dma bit in d0
  or.b    d0,1(a6)                          ;or dma bit to temp dmacon
  rts                                       ;return

effects_table:
  dc.l eff1,eff2,eff3,eff4,eff5,eff6,eff7,eff8

eff1:                                       ;play speed
  andi.b  #15,d1
  move.b  d1,47(a6)
  rts
eff2:                                       ;led filter
  tst.b   d1
  bne.s   led_off
  bset    #1,$bfe001
  rts
led_off:
  bclr    #1,$bfe001
  rts
eff3:                                       ;slide freq up
  andi.w  #$ff,d1
  neg.w   d1
  move.w  d1,30(a0)
  rts
eff4:                                       ;slide freq down
  andi.w  #$ff,d1
  move.w  d1,30(a0)
  rts
eff5:                                       ;portamento
  move.b  d1,37(a0)
  rts
eff6:                                       ;channel volume
  andi.b  #63,d1
  move.b  d1,29(a0)
  rts
eff7:
  rts
eff8:                                       ;arpeggio
  andi.l  #63,d1
  asl.l   #4,d1
  lea     module(pc),a4
  adda.l  #4,a4                             ;arpeggio table offset
  adda.l  d1,a4
  move.l  a4,44(a0)
  rts

dm2_init:
  bset    #1,$bfe001                        ;led filter off
  lea     module(pc),a0                     ;module base address in a0
  adda.l  #1028,a0                          ;tracks length offset
  lea     song_data(pc),a4                  ;song data in a4
  clr.l   50(a4)                            ;reset track 1-2 counter
  clr.l   54(a4)                            ;reset track 3-4 counter
  movea.l a0,a2                             ;tracks offset in a2
  lea     track1data(pc),a1                 ;track1data in a1
  moveq   #15,d7                            ;loop counter

dm2_init_loop:
  move.b  (a0)+,(a1)+                       ;store 16 bytes in tracxlen vars
  dbf     d7,dm2_init_loop                  ;loop
  move.l  a0,10(a4)                         ;store track 1 address in song data
  moveq   #0,d0                             ;clear d0
  move.w  2(a2),d0                          ;track 1 length in d0
  adda.l  d0,a0                             ;add track 1 length
  move.l  a0,14(a4)                         ;store track 2 address in song data
  moveq   #0,d0                             ;clear d0
  move.w  6(a2),d0                          ;track 2 length in d0
  adda.l  d0,a0                             ;add track 2 length
  move.l  a0,18(a4)                         ;store track 3 address in song data
  moveq   #0,d0                             ;clear d0
  move.w  10(a2),d0                         ;track 3 length in d0
  adda.l  d0,a0                             ;add track 3 length
  move.l  a0,22(a4)                         ;store track 4 address in song data
  moveq   #0,d0                             ;clear d0
  move.w  14(a2),d0                         ;track 4 length in d0
  adda.l  d0,a0                             ;add track 4 length
  move.l  (a0)+,d0                          ;blocks length in d0
  move.l  a0,26(a4)                         ;store block data address in song data
  adda.l  d0,a0                             ;add block data lengh offset
  move.l  a0,6(a4)                          ;store instruments offset table in song data
  adda.l  #254,a0                           ;add table length
  moveq   #0,d0                             ;clear d0
  move.w  (a0)+,d0                          ;instruments header length in d0 (last value in the offset table)
  move.l  a0,2(a4)                          ;store instruments header address in song data
  adda.l  d0,a0                             ;add headers length
  move.l  (a0)+,d0                          ;waveforms table length in d0
  move.l  a0,30(a4)                         ;store waveforms table length in song data
  adda.l  d0,a0                             ;add table length
  move.l  a0,38(a4)                         ;store samples address table in song data
  addi.l  #64,38(a4)                        ;add 64 to samples address table
  adda.l  #96,a0                            ;add 96 to a0 address
  move.l  a0,34(a4)                         ;store sample data address in song data
  lea     $dff000,a5                        ;amiga custom registers base address
  move.w  #$000f,$96(a5)                    ;disable all amiga channels dma
  move.w  #1,$a4(a5)                        ;set amiga channel 1 length
  move.w  #1,$b4(a5)                        ;set amiga channel 2 length
  move.w  #1,$c4(a5)                        ;set amiga channel 3 length
  move.w  #1,$d4(a5)                        ;set amiga channel 4 length
  clr.w   $a8(a5)                           ;reset amiga channel 1 volume
  clr.w   $b8(a5)                           ;reset amiga channel 2 volume
  clr.w   $c8(a5)                           ;reset amiga channel 3 volume
  clr.w   $d8(a5)                           ;reset amiga channel 4 volume
  lea     song_data(pc),a4                  ;song data in a4
  lea     channel1(pc),a0                   ;channel1 in a0
  move.l  10(a4),10(a0)                     ;copy track 1 address in channel1
  move.l  track1data(pc),54(a0)             ;copy track 1 length in channel1
  bsr.w   dm2_setup                         ;gosub dm2_setup
  lea     channel2(pc),a0                   ;channel2 in a0
  move.l  14(a4),10(a0)                     ;copy track 2 address in channel2
  move.l  track2data(pc),54(a0)             ;copy track 2 length in channel2
  bsr.w   dm2_setup                         ;gosub dm2_setup
  lea     channel3(pc),a0                   ;channel3 in a0
  move.l  18(a4),10(a0)                     ;copy track 3 address in channel3
  move.l  track3data(pc),54(a0)             ;copy track 3 length in channel3
  bsr.w   dm2_setup                         ;gosub dm2_setup
  lea     channel4(pc),a0                   ;channel4 in a0
  move.l  22(a4),10(a0)                     ;copy track 4 address in channel4
  move.l  track4data(pc),54(a0)             ;copy track 4 length in channel4
  bsr.w   dm2_setup                         ;gosub dm2_setup
  move.b  #1,48(a4)                         ;store 1 in song data speed counter
  rts                                       ;return

dm2_setup:
  clr.w   20(a0)                            ;reset voice block position
  clr.w   18(a0)                            ;reset voice track position
  move.l  2(a4),6(a0)                       ;copy instruments header address in voice
  clr.b   51(a0)                            ;reset voice instrument type
  clr.w   48(a0)                            ;reset voice arpeggio step
  lea     module(pc),a3                     ;module base address in a3
  adda.l  #4,a3                             ;arpeggio table offset in a3
  move.l  a3,44(a0)                         ;store arpeggio table offset in voice
  clr.w   32(a0)                            ;reset voice volume
  clr.w   34(a0)                            ;reset voice volume step
  clr.b   36(a0)                            ;reset voice volume sustain
  clr.b   37(a0)                            ;reset voice portamento speed
  clr.w   30(a0)                            ;reset voice bendrate
  move.b  #63,29(a0)                        ;store 63 in voice channel volume
  rts                                       ;return

track1data: dc.l 0
track2data: dc.l 0
track3data: dc.l 0
track4data: dc.l 0

channel1:
  dc.l $dff0a0
  dc.w 1
  dc.l 0
  dc.l 0
  dc.l 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.l 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0

channel2:
  dc.l $dff0b0
  dc.w 2
  dc.l 0
  dc.l 0
  dc.l 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.l 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0

channel3:
  dc.l $dff0c0
  dc.w 4
  dc.l 0
  dc.l 0
  dc.l 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.l 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0

channel4:
  dc.l $dff0d0
  dc.w 8
  dc.l 0
  dc.l 0
  dc.l 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.l 0
  dc.w 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0

freq_table:
  dc.w 0000,6848,6464,6096,5760,5424,5120,4832,4560,4304,4064,3840,3616,3424,3232
  dc.w 3048,2880,2712,2560,2416,2280,2152,2032,1920,1808,1712,1616,1524,1440,1356
  dc.w 1280,1208,1140,1076,1016,0960,0904,0856,0808,0762,0720,0678,0640,0604,0570
  dc.w 0538,0508,0480,0452,0428,0404,0381,0360,0339,0320,0302,0285,0269,0254,0240
  dc.w 0226,0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113,0113,0113
  dc.w 0113,0113,0113,0113,0113,0113,0113,0113,0113,0113

song_data:
  dc.w $8000
  dc.l 0
  dc.l 0
  dc.l 0
  dc.l 0
  dc.l 0
  dc.l 0
  dc.l 0
  dc.l 0
  dc.l 0
  dc.l 0
  dc.l 0
  dc.b 0
  dc.b 5
  dc.b 0
  dc.b 0
  dc.w 0
  dc.w 0
  dc.w 0
  dc.w 0

module: incbin "module.dm2"