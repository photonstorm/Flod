  section player,data_c

delta_music:
  cmp.l   #"ALL ",data                      ;test for loaded module
  bne.s   error
; bset    #1,$bfe001                        ;power on/off
  lea     $dff000,a5
  bsr     dm_init                           ;init music
raster1:
  cmp.b   #100,$6(a5)
  bne.s   raster1
raster2:
  cmp.b   #101,$6(a5)
  bne.s   raster2
  move.w  #$0f0,$180(a5)
  bsr.s   dm_play                           ;play music
  move.w  #0,$180(a5)
  btst    #6,$bfe001                        ;wait for mouse
  bne.s   raster1
  move.w  #$f,$96(a5)                       ;stop all sound
  bclr    #1,$bfe001                        ;power on
error:
  rts


speed = 6                                   ;play speed

; ////  hardware  \\\\
h_sound     = 0
h_length    = 4
h_frequency = 6
h_volume    = 8

; ////  instrument  \\\\
s_attack_step     = 0
s_attack_delay    = 1
s_decay_step      = 2
s_decay_delay     = 3
s_sustain         = 4
s_release_step    = 6
s_release_delay   = 7
s_volume          = 8
s_vibrator_wait   = 9
s_vibrator_step   = 10
s_vibrator_length = 11
s_bendrate        = 12
s_portamento      = 13
s_sample          = 14
s_table_delay     = 15
s_arpeggio        = 16
s_sound_length    = 24
s_repeat          = 26
s_repeat_length   = 28
s_table           = 30
s_sounddata       = 78

; ////  channel  \\\\
c_hardware        = 0
c_dma             = 4
c_sounddata       = 6
c_frequency       = 10
c_sound_table     = 12
c_sound_table_cnt = 16
c_sound_table_del = 17
c_track           = 18
c_track_cnt       = 22
c_block           = 24
c_block_cnt       = 28
c_vibrator_wait   = 32
c_vibrator_length = 33
c_vibrator_pos    = 34
c_vibrator_cmp    = 35
c_vibrator_freq   = 36
c_old_frequency   = 38
c_frequency_data  = 40
c_actual_volume   = 41
c_attack_delay    = 42
c_decay_delay     = 43
c_sustain         = 44
c_release_delay   = 46
c_play_speed      = 47
c_bendrate_freq   = 48
c_transpose       = 50
c_status          = 51
c_arpeggio_cnt    = 52
c_arpeggio_data   = 53
c_arpeggio_on     = 54
c_effect_number   = 55
c_effect_data     = 56


dm_play:
  movem.l d0-d7/a0-a6,-(a7)                 ;store registers
  lea     channel1(pc),a6                   ;channel 1 in a6
  bsr.w   dm_calc_frequency                 ;gosub dm_calc_frequency
  lea     channel2(pc),a6                   ;channel 2 in a6
  bsr.w   dm_calc_frequency                 ;gosub dm_calc_frequency
  lea     channel3(pc),a6                   ;channel 3 in a6
  bsr.w   dm_calc_frequency                 ;gosub dm_calc_frequency
  lea     channel4(pc),a6                   ;channel 4 in a6
  bsr.w   dm_calc_frequency                 ;gosub dm_calc_frequency
  move.w  #$800f,$dff096                    ;enable amiga channels dma
dm_sample_handler:
  move.w  #200,d0                           ;loop counter
dm_swait:
  dbra    d0,dm_swait                       ;loop
  lea     channel1(pc),a6                   ;channel 1 in a6
  move.l  c_hardware(a6),a4                 ;hardware channel pointer in a4
  move.l  c_sounddata(a6),a5                ;channel sample pointer in a5
  tst.b   s_sample(a5)                      ;test sample pointer
  beq.s   dm_no_sample1                     ;if 0 goto dm_no_sample1
  move.w  s_repeat_length(a5),h_length(a4)  ;store instrument repeat length in h_length
  moveq   #0,d7                             ;clear d7
  move.w  s_repeat(a5),d7                   ;store instrument repeat in d7
  add.l   a5,d7                             ;add instrument address to repeat
  add.l   #s_table,d7                       ;sample data offset
  move.l  d7,h_sound(a4)                    ;set amiga channel pointer
dm_no_sample1:
  lea     channel2(pc),a6
  move.l  c_hardware(a6),a4
  move.l  c_sounddata(a6),a5
  tst.b   s_sample(a5)
  beq.s   dm_no_sample2
  move.w  s_repeat_length(a5),h_length(a4)
  moveq   #0,d7
  move.w  s_repeat(a5),d7
  add.l   a5,d7
  add.l   #s_table,d7
  move.l  d7,h_sound(a4)
dm_no_sample2:
  lea     channel3(pc),a6
  move.l  c_hardware(a6),a4
  move.l  c_sounddata(a6),a5
  tst.b   s_sample(a5)
  beq.s   dm_no_sample3
  move.w  s_repeat_length(a5),h_length(a4)
  moveq   #0,d7
  move.w  s_repeat(a5),d7
  add.l   a5,d7
  add.l   #s_table,d7
  move.l  d7,h_sound(a4)
dm_no_sample3:
  lea     channel4(pc),a6
  move.l  c_hardware(a6),a4
  move.l  c_sounddata(a6),a5
  tst.b   s_sample(a5)
  beq.s   dm_no_sample4
  move.w  s_repeat_length(a5),h_length(a4)
  moveq   #0,d7
  move.w  s_repeat(a5),d7
  add.l   a5,d7
  add.l   #s_table,d7
  move.l  d7,h_sound(a4)
dm_no_sample4:
  movem.l (a7)+,d0-d7/a0-a6
  rts

dm_calc_frequency:
  move.l  c_hardware(a6),a4                 ;amiga hardware channel pointer in a4
  move.l  c_sounddata(a6),a5                ;channel sample pointer in a5
  subq.b  #1,c_play_speed(a6)               ;decrease channel play speed
  bne.w   dm_block_con                      ;if != 0 goto dm_block_con
  move.b  play_speed,c_play_speed(a6)       ;else copy play speed to channel play speed
  tst.l   c_block_cnt(a6)                   ;test channel block counter
  bne.s   dm_check_block                    ;if != 0 goto dm_check_block
dm_track_step:
  move.l  c_track(a6),a0                    ;channel track pointer in a0
  move.w  c_track_cnt(a6),d7                ;channel track counter in d7
  move.w  (a0,d7.w),d0                      ;get track value
  cmp.w   #-1,d0                            ;is end of track?
  bne.s   dm_track_con                      ;if != -1 goto dm_track_con
  move.w  2(a0,d7.w),d0                     ;restart position in d0
  and.w   #$7ff,d0                          ;max pos 2047
  asl.w   #1,d0                             ;multiply by 2
  move.w  d0,c_track_cnt(a6)                ;store in channel track counter
  bra.s   dm_track_step                     ;loop back
dm_track_con:
  move.b  d0,c_transpose(a6)                ;store byte in channel note tranpose
  asr.l   #2,d0                             ;divide by 2
  and.l   #16320,d0                         ;calc to get the block number
  add.l   blocks(pc),d0                     ;add blocks base address to d0
  move.l  d0,c_block(a6)                    ;store in channel block pointer
  addq.w  #2,c_track_cnt(a6)                ;add 2 to channel track counter
dm_check_block:
  move.l  c_block(a6),a0                    ;channel block pointer in a0
  add.l   c_block_cnt(a6),a0                ;add channel block counter
  tst.b   2(a0)                             ;test effect
  beq.s   dm_no_new_effect                  ;if 0 goto dm_no_new_effect
  move.b  2(a0),c_effect_number(a6)         ;else store effect in channel effect #
  move.b  3(a0),c_effect_data(a6)           ;store data in channel effect data
dm_no_new_effect:
  moveq   #0,d0                             ;clear d0
  move.b  1(a0),d0                          ;note in d0
  beq.w   dm_test_effect                    ;if note is 0 goto dm_test_effect
  add.b   c_transpose(a6),d0                ;else add track transpose to note
  move.b  d0,c_frequency_data(a6)           ;store in channel frequency data
  move.w  c_dma(a6),d0                      ;channel dma value in d0
  sub.w   #$8000,d0                         ;subtract $8000 (clear bit)
  move.w  d0,$dff096                        ;disable amiga channel
  moveq   #0,d0                             ;clear d0
  move.b  d0,c_status(a6)                   ;reset channel status
  move.w  d0,c_bendrate_freq(a6)            ;reset channel bendrate
  move.w  d0,c_arpeggio_cnt(a6)             ;reset channel arpeggio counter
  move.b  d0,c_arpeggio_on(a6)              ;reset channel arpeggio on/off
  move.b  2(a0),c_effect_number(a6)         ;store effect in channel effect #
  move.b  3(a0),c_effect_data(a6)           ;store data in channel effect data
  lea     snd_table(pc),a1                  ;snd_table in a1
  move.b  (a0),d0                           ;sample # in d0
  asl.l   #2,d0                             ;multiply by 4
  move.l  (a1,d0.l),d0                      ;instrument header pointer in d0
  move.l  d0,c_sounddata(a6)                ;store in channel sounddata
  move.l  d0,a5                             ;copy in a5
  add.l   #s_table,d0                       ;add 30 to d0 (sound table offset)
  move.l  d0,c_sound_table(a6)              ;store in channel sound table pointer
  clr.b   c_sound_table_cnt(a6)             ;reset channel sound table counter
  tst.b   s_sample(a5)                      ;test instrument for sample/synth
  beq.s   dm_no_sample_clear                ;if synth goto dm_no_sample_clear
  clr.w   s_table(a5)                       ;set first word of the sample to 0
  move.l  d0,h_sound(a4)                    ;set amiga channel pointer
dm_no_sample_clear:
  move.w  s_sound_length(a5),d0             ;sample length in d0
  asr.w   #1,d0                             ;divide by 2
  move.w  d0,h_length(a4)                   ;set amiga channel length
  move.b  s_vibrator_wait(a5),c_vibrator_wait(a6) ;copy instrument vibrator wait in channel vibrator wait
  move.b  s_vibrator_length(a5),d0          ;instrument vibrator length in d0
  move.b  d0,c_vibrator_length(a6)          ;store in channel vibrator length
  move.b  d0,c_vibrator_pos(a6)             ;store in channel vibrator pos
  asl.b   #1,d0                             ;multiply by 2
  move.b  d0,c_vibrator_cmp(a6)             ;store result in channel vibrator compare
  clr.b   c_actual_volume(a6)               ;reset channel actual volume
  clr.b   c_sound_table_del(a6)             ;reset channel sound table delay
  clr.b   c_sound_table_cnt(a6)             ;reset channel sound table counter
  clr.b   c_attack_delay(a6)                ;reset channel attack delay
  clr.b   c_decay_delay(a6)                 ;reset channel decay delay
  move.w  s_sustain(a5),c_sustain(a6)       ;copy instrument sustain in channel sustain
  clr.b   c_release_delay(a6)               ;reset channel release delay
dm_test_effect:
  addq.l  #4,c_block_cnt(a6)                ;increase block counter (1 step = 4 bytes)
  cmp.l   #64,c_block_cnt(a6)               ;compare block counter
  bne.s   dm_block_con                      ;if != 64 goto dm_block_con
  clr.l   c_block_cnt(a6)                   ;else reset channel block counter

dm_block_con:
  tst.b   s_sample(a5)                      ;test sample/synth
  bne.s   dm_portamento_handler             ;if sample goto dm_portamento_handler
  tst.b   c_sound_table_del(a6)             ;test channel sound table delay
  beq.s   dm_sound_table_handler            ;if 0 goto dm_sound_table_handler
  subq.b  #1,c_sound_table_del(a6)          ;else decrease channel sound table delay
  bra.s   dm_portamento_handler             ;goto dm_portamento_handler
dm_sound_table_handler:
  move.b  s_table_delay(a5),c_sound_table_del(a6) ;copy instrument table delay in channel sound table delay
dm_sound_read_again:
  move.l  c_sound_table(a6),a0              ;channel sound table pointer in a6
  moveq   #0,d6                             ;clear d6
  move.b  c_sound_table_cnt(a6),d6          ;channel sound table counter in d6
  cmp.b   #48,d6                            ;compare counter to 48
  bmi.s   dm_sound_read_c                   ;if < goto dm_sound_read_c
  clr.b   c_sound_table_cnt(a6)             ;else reset channel sound table counter
  moveq   #0,d6                             ;clear d6
dm_sound_read_c:
  add.l   d6,a0                             ;add counter offset to sound table pointer
  moveq   #0,d7                             ;clear d7
  move.b  (a0),d7                           ;read waveform #
  bpl.s   dm_new_sounddata                  ;if positive goto dm_new_sounddata
  cmp.b   #$ff,d7                           ;compare waveform #
  bne.s   dm_sound_new_speed                ;if != $ff goto dm_sound_new_speed
  move.b  1(a0),d7                          ;end of table, read restart pointer
  move.b  d7,c_sound_table_cnt(a6)          ;store restart pointer in channel sound table counter
  bra.s   dm_sound_read_again               ;loop back to dm_sound_read_again
dm_sound_new_speed:
  and.b   #127,d7                           ;get real speed value
  move.b  d7,s_table_delay(a5)              ;store in channel sound table delay
  addq.b  #1,c_sound_table_cnt(a6)          ;increase channel sound table counter
  bra.s   dm_sound_read_again               ;loop back to dm_sound_read_again
dm_new_sounddata:
  asl.l   #5,d7                             ;multiply waveform # by 32
  add.l   #s_sounddata,d7                   ;add 78 (sound data offset)
  add.l   c_sounddata(a6),d7                ;add instrument address
  move.l  d7,h_sound(a4)                    ;set amiga channel pointer
  addq.b  #1,c_sound_table_cnt(a6)          ;increase channel sound table counter

dm_portamento_handler:
  tst.b   s_portamento(a5)                  ;test instrument portamento
  beq.s   dm_vibrator_handler               ;if 0 goto dm_vibrator_handler
  move.w  c_frequency(a6),d1                ;channel period in d1
  bne.s   dm_porta_con                      ;if != 0 goto dm_porta_con
  moveq   #0,d0                             ;clear d0
  lea     freq_table(pc),a1                 ;freq table in a1
  move.b  c_frequency_data(a6),d0           ;channel frequency data in d0
  asl.w   #1,d0                             ;multiply by 2
  move.w  (a1,d0.w),d0                      ;new frequency in d0
  add.w   c_bendrate_freq(a6),d0            ;add channel bendrate
  move.w  d0,c_frequency(a6)                ;store in channel period
  bra.s   dm_vibrator_handler               ;goto dm_vibrator_handler
dm_porta_con:
  moveq   #0,d0                             ;clear d0
  moveq   #0,d2                             ;clear d2
  move.b  s_portamento(a5),d2               ;instrument portamento in d2
  lea     freq_table(pc),a1                 ;freq table in a1
  move.b  c_frequency_data(a6),d0           ;channel frequency data in d0
  asl.w   #1,d0                             ;multiply by 2
  move.w  (a1,d0.w),d0                      ;new frequency in d0
  add.w   c_bendrate_freq(a6),d0            ;add channel bendrate
  cmp.w   d0,d1                             ;compare channel period with result
  beq.s   dm_vibrator_handler               ;if == goto dm_vibrator_handler

  blo.s   dm_porta_low                      ;if period < result goto dm_porta_low
  sub.w   d2,d1                             ;subtract instrument portamento to channel period
  cmp.w   d0,d1                             ;compare previous result with new one
  bpl.s   dm_porta_high_con                 ;if positive goto dm_porta_high_con
  move.w  d0,c_frequency(a6)                ;else store previous result in channel period
  bra.s   dm_vibrator_handler               ;goto dm_vibrator_handler
dm_porta_high_con:
  move.w  d1,c_frequency(a6)                ;store new result in channel period
  bra.s   dm_vibrator_handler               ;goto dm_vibrator_handler
dm_porta_low:
  add.w   d2,d1
  cmp.w   d0,d1
  bmi.s   dm_porta_low_con
  move.w  d0,c_frequency(a6)
  bra.s   dm_vibrator_handler
dm_porta_low_con:
  move.w  d1,c_frequency(a6)

dm_vibrator_handler:
  tst.b   c_vibrator_wait(a6)
  beq.s   dm_calc_vibrator
  subq.b  #1,c_vibrator_wait(a6)
  bra.s   dm_bendrate_handler
dm_calc_vibrator:
  moveq   #0,d0
  moveq   #0,d1
  move.b  c_vibrator_pos(a6),d0
  move.b  d0,d2
  move.b  s_vibrator_step(a5),d1
  mulu    d1,d0
  move.w  d0,c_vibrator_freq(a6)
  btst    #0,c_status(a6)
  bne.s   dm_vibrator_minus
dm_vibrator_plus:
  addq.b  #1,d2
  cmp.b   c_vibrator_cmp(a6),d2
  bne.s   dm_vibrator_no_reset
  eor.b   #1,c_status(a6)
dm_vibrator_no_reset:
  move.b  d2,c_vibrator_pos(a6)
  bra.s   dm_bendrate_handler
dm_vibrator_minus:
  subq.b  #1,d2
  bne.s   dm_vibrator_no_reset2
  eor.b   #1,c_status(a6)
dm_vibrator_no_reset2:
  move.b  d2,c_vibrator_pos(a6)

dm_bendrate_handler:
  moveq   #0,d0
  move.l  c_sounddata(a6),a1
  move.b  s_bendrate(a1),d0
  bpl.s   dm_rate_minus
  neg.b   d0
  add.w   d0,c_bendrate_freq(a6)
  bra.s   dm_effect_handler
dm_rate_minus:
  sub.w   d0,c_bendrate_freq(a6)

dm_effect_handler:
  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  move.b  c_effect_data(a6),d0              ;channel effect data in d0
  move.b  c_effect_number(a6),d1            ;channel effect # in d1
  lea     effect_table(pc),a1               ;effect table in a1
  and.b   #$1f,d1                           ;max effect # = 31
  asl.l   #2,d1                             ;multiply by 4
  move.l  (a1,d1.w),a1                      ;get function pointer
  jsr     (a1)                              ;gosub function

dm_arpeggio_handler:
  move.l  a5,a1
  add.l   #s_arpeggio,a1
  move.b  c_arpeggio_cnt(a6),d0
  move.b  (a1,d0.w),d1
  addq.b  #1,c_arpeggio_cnt(a6)
  and.b   #7,c_arpeggio_cnt(a6)
dm_store_frequency:
  moveq   #0,d0
  lea     freq_table(pc),a1
  move.b  c_frequency_data(a6),d0
  add.b   d1,d0
  asl.w   #1,d0
  move.w  (a1,d0.w),d0
  moveq   #0,d1
  moveq   #0,d2

  move.b  c_vibrator_length(a6),d1
  move.b  s_vibrator_step(a5),d2
  mulu    d2,d1
  sub.w   d1,d0
  add.w   c_bendrate_freq(a6),d0
  tst.b   s_portamento(a5)
  beq.s   dm_store_no_port
  move.w  c_frequency(a6),d0
  bra.s   dm_store_port
dm_store_no_port:
  clr.w   c_frequency(a6)
dm_store_port:
  add.w   c_vibrator_freq(a6),d0
  move.w  d0,h_frequency(a4)

dm_volume_handler:
  moveq   #0,d1                             ;clear d1
  move.b  c_actual_volume(a6),d1            ;channel actual volume in d1
  move.b  c_status(a6),d0                   ;channel adsr step in d0
  and.b   #14,d0                            ;& 14
  tst.b   d0                                ;test status
  bne.s   dm_test_decay                     ;if != 0 goto dm_test_decay
  tst.b   c_attack_delay(a6)                ;test channel attack delay
  beq.s   dm_attack_handler                 ;if 0 goto dm_attack_handler
  subq.b  #1,c_attack_delay(a6)             ;else decrease channel attack delay
  bra.w   dm_volume_exit                    ;goto dm_volume_exit
dm_attack_handler:
  move.b  s_attack_delay(a5),c_attack_delay(a6)   ;copy instrument attack delay in channel attack delay
  add.b   s_attack_step(a5),d1              ;add instrument attack step to actual volume
  cmp.b   #64,d1                            ;compare result
  blo.s   dm_attack_con                     ;if < 64 goto dm_attack_con
  or.b    #2,d0                             ;
  or.b    #2,c_status(a6)
  move.b  #64,d1
dm_attack_con:


dm_test_decay:
  cmp.b   #2,d0
  bne.s   dm_test_sustain
  tst.b   c_decay_delay(a6)
  beq.s   dm_decay_handler
  subq.b  #1,c_decay_delay(a6)
  bra.s   dm_volume_exit
dm_decay_handler:
  move.b  s_decay_delay(a5),c_decay_delay(a6)
  move.b  s_volume(a5),d2
  sub.b   s_decay_step(a5),d1
  cmp.b   d2,d1
  bhi.s   dm_decay_con
  move.b  s_volume(a5),d1
  or.b    #6,d0
  or.b    #6,c_status(a6)
dm_decay_con:

dm_test_sustain:
  cmp.b   #6,d0
  bne.s   dm_test_release
  tst.w   c_sustain(a6)
  beq.s   dm_sustain_handler
  subq.w  #1,c_sustain(a6)
  bra.s   dm_volume_exit
dm_sustain_handler:
  or.b    #14,d0
  or.b    #14,c_status(a6)
dm_test_release:
  cmp.b   #14,d0
  bne.s   dm_volume_exit
  tst.b   c_release_delay(a6)
  beq.s   dm_release_handler
  subq.b  #1,c_release_delay(a6)
  bra.s   dm_volume_exit
dm_release_handler:
  move.b  s_release_delay(a5),c_release_delay(a6)
  sub.b   s_release_step(a5),d1
  bpl.s   dm_release_con
  and.b   #9,c_status(a6)
  moveq   #0,d1
dm_release_con:

dm_volume_exit:
  move.b  d1,c_actual_volume(a6)            ;store new value in channel actual volume
  move.w  d1,h_volume(a4)                   ;set amiga channel volume
  rts                                       ;return

; ----  init music  ----

all_check = 0
trk1      = 4

dm_init:
  lea     track1(pc),a1                     ;track1 in a1
  moveq   #24,d7                            ;loop counter
dm_init_loop:
  move.l  #data+26*4,(a1)+                  ;store tracks data address in all vars
  dbra    d7,dm_init_loop                   ;loop
  moveq   #23,d6                            ;loop counter
  lea     track1+24*4(pc),a1                ;load vars in sequence (starting from last soundinfo)
dm_init_loop2:
  lea     data+4(pc),a0                     ;pointer to section lengths
  move.l  d6,d7                             ;2nd loop counter
dm_init_loop3:
  move.l  (a0)+,d0                          ;read each section length in d0
  add.l   d0,(a1)                           ;add section length to address stored in the vars
  dbra    d7,dm_init_loop3                  ;2nd loop
  subq.l  #4,a1                             ;point to previous var
  dbra    d6,dm_init_loop2                  ;loop
  lea     $dff0a0,a0                        ;amiga channel 1 base address
  lea     channel1(pc),a6                   ;channel 1 in a6
  bsr.s   dm_setup                          ;gosub setup
  add.l   #16,a0                            ;offset to next amiga channel
  lea     channel2(pc),a6                   ;channel 2 in a6
  bsr.s   dm_setup                          ;gosub setup
  add.l   #16,a0                            ;offset to next amiga channel
  lea     channel3(pc),a6                   ;channel 3 in a6
  bsr.s   dm_setup                          ;gosub setup
  add.l   #16,a0                            ;offset to last amiga channel
  lea     channel4(pc),a6                   ;channel 4 in a6
  bsr.s   dm_setup                          ;gosub setup
  move.w  #$8001,channel1+c_dma             ;store channel 1 dma value
  move.w  #$8002,channel2+c_dma             ;store channel 2 dma value
  move.w  #$8004,channel3+c_dma             ;store channel 3 dma value
  move.w  #$8008,channel4+c_dma             ;store channel 4 dma value
  move.l  track1(pc),channel1+c_track       ;store track 1 pointer in channel 1
  move.l  track2(pc),channel2+c_track       ;store track 2 pointer in channel 2
  move.l  track3(pc),channel3+c_track       ;store track 3 pointer in channel 3
  move.l  track4(pc),channel4+c_track       ;store track 4 pointer in channel 4
  rts                                       ;return

dm_setup:
  move.l  a0,c_hardware(a6)                 ;store channel hardware pointer
  move.w  #16,h_length(a0)                  ;store 16 in h_length
  clr.w   h_volume(a0)                      ;reset h_volume
  move.l  #safe_zero,c_sounddata(a6)        ;store empty sample in channel sample pointer
  clr.w   c_frequency(a6)                   ;reset channel period
  move.l  snd_table(pc),d0                  ;snd_table in d0
  add.l   #16,d0                            ;increase pointer
  move.l  d0,c_sound_table(a6)              ;store in channel sound table pointer
  clr.w   c_sound_table_cnt(a6)             ;reset channel sound table counter
  clr.w   c_track_cnt(a6)                   ;reset channel track counter
  move.l  blocks(pc),c_block(a6)            ;store in channel block pointer
  clr.l   c_block_cnt(a6)                   ;reset channel block counter
  clr.l   c_vibrator_wait(a6)               ;reset channel vibrator wait
  clr.l   c_vibrator_freq(a6)               ;reset channel vibrator period
  clr.l   c_frequency_data(a6)              ;reset channel frequency data
  move.l  #1,c_sustain(a6)                  ;store 1 in channel sustain
  clr.l   c_bendrate_freq(a6)               ;reset channel bendrate period
  clr.l   c_arpeggio_cnt(a6)                ;reset channel arpeggio counter
  clr.w   c_effect_data(a6)                 ;reset channel effect data
  rts                                       ;return

; ----  effect routines  ----

eff0:
  rts                                       ;return
eff1:                                       ;play speed
  and.b   #15,d0                            ;max value 15
  beq.s   eff1_exit                         ;if 0 goto eff1_exit
  move.b  d0,play_speed                     ;store in play_speed
eff1_exit:
  rts                                       ;return
eff2:                                       ;slide freq up
  sub.w   d0,c_bendrate_freq(a6)            ;subtract effect data to channel bendrate period
  rts
eff3:                                       ;slide freq down
  add.w   d0,c_bendrate_freq(a6)            ;add effect data to channel bendrate period
  rts
eff4:                                       ;led on/off
  tst.b   d0                                ;test effect data
  beq     led_off                           ;if 0 goto led_off
  bset    #1,$bfe001                        ;filter on
  rts                                       ;return
led_off:
  bclr    #1,$bfe001                        ;filter off
  rts                                       ;return
eff5:                                       ;set vibrator wait
  move.b  d0,s_vibrator_wait(a5)            ;store effect data in instrument vibrator wait
  rts                                       ;return
eff6:                                       ;set vibrator step
  move.b  d0,s_vibrator_step(a5)            ;store effect data in instrument vibrator step
  rts                                       ;return
eff7:                                       ;set vibrator length
  move.b  d0,s_vibrator_length(a5)          ;store effect data in instrument vibrator length
  rts                                       ;return
eff8:                                       ;set bendrate
  move.b  d0,s_bendrate(a5)                 ;store effect data in instrument bendrate
  rts                                       ;return
eff9:                                       ;set portamento
  move.b  d0,s_portamento(a5)               ;store effect data in instrument portamento
  rts                                       ;return
effa:                                       ;set volume
  cmp.b   #65,d0                            ;compare effect data
  bmi.s   effa_con                          ;if < 65 goto effa_con
  move.b  #64,d0                            ;set value to 64
effa_con:
  move.b  d0,s_volume(a5)                   ;store value in instrument volume
  rts                                       ;return
effb:                                       ;set arp 1
  move.b  d0,s_arpeggio(a5)                 ;store effect data in arpeggio table byte 0
  rts                                       ;return
effc:                                       ;set arp 2
  move.b  d0,s_arpeggio+1(a5)               ;store effect data in arpeggio table byte 1
  rts                                       ;return
effd:                                       ;set arp 3
  move.b  d0,s_arpeggio+2(a5)               ;store effect data in arpeggio table byte 2
  rts                                       ;return
effe:                                       ;set arp 4
  move.b  d0,s_arpeggio+3(a5)               ;store effect data in arpeggio table byte 3
  rts                                       ;return
efff:                                       ;set arp 5
  move.b  d0,s_arpeggio+4(a5)               ;store effect data in arpeggio table byte 4
  rts                                       ;return
eff10:                                      ;set arp 6
  move.b  d0,s_arpeggio+5(a5)               ;store effect data in arpeggio table byte 5
  rts                                       ;return
eff11:                                      ;set arp 7
  move.b  d0,s_arpeggio+6(a5)               ;store effect data in arpeggio table byte 6
  rts                                       ;return
eff12:                                      ;set arp 8
  move.b  d0,s_arpeggio+7(a5)               ;store effect data in arpeggio table byte 7
  rts                                       ;return
eff13:                                      ;set arp 1 / 5
  move.b  d0,s_arpeggio(a5)                 ;store effect data in arpeggio table byte 0
  move.b  d0,s_arpeggio+4(a5)               ;store effect data in arpeggio table byte 4
  rts                                       ;return
eff14:                                      ;set arp 2 / 6
  move.b  d0,s_arpeggio+1(a5)               ;store effect data in arpeggio table byte 1
  move.b  d0,s_arpeggio+5(a5)               ;store effect data in arpeggio table byte 5
  rts                                       ;return
eff15:                                      ;set arp 3 / 7
  move.b  d0,s_arpeggio+2(a5)               ;store effect data in arpeggio table byte 2
  move.b  d0,s_arpeggio+6(a5)               ;store effect data in arpeggio table byte 6
  rts                                       ;return
eff16:                                      ;set arp 4 / 8
  move.b  d0,s_arpeggio+3(a5)               ;store effect data in arpeggio table byte 3
  move.b  d0,s_arpeggio+7(a5)               ;store effect data in arpeggio table byte 7
  rts                                       ;return
eff17:                                      ;set attack step
  cmp.b   #65,d0                            ;compare effect data
  bmi.s   eff17_con                         ;if < 65 goto eff17_con
  move.b  #64,d0                            ;set value to 64
eff17_con:
  move.b  d0,s_attack_step(a5)              ;store value in instrument attack step
  rts                                       ;return
eff18:                                      ;set attack delay
  move.b  d0,s_attack_delay(a5)             ;store effect data in instrument attack delay
  rts                                       ;return
eff19:                                      ;set decay step
  cmp.b   #65,d0                            ;compare effect data
  bmi.s   eff19_con                         ;if < 65 goto eff19_con
  move.b  #64,d0                            ;set value to 64
eff19_con:
  move.b  d0,s_decay_step(a5)               ;store value in instrument decay step
  rts                                       ;return
eff1a:                                      ;set decay delay
  move.b  d0,s_decay_delay(a5)              ;store effect data in instrument decay delay
  rts                                       ;return
eff1b:                                      ;set sustain byte 1
  move.b  d0,s_sustain(a5)                  ;store effect data in instrument sustain higher byte
  rts                                       ;return
eff1c:                                      ;set sustain byte 2
  move.b  d0,s_sustain+1(a5)                ;store effect data in instrument sustain lower byte
  rts                                       ;return
eff1d:                                      ;set release step
  cmp.b   #65,d0                            ;compare effect data
  bmi.s   eff1d_con                         ;if < 65 goto eff1d_con
  move.b  #64,d0                            ;set value to 64
eff1d_con:
  move.b  d0,s_release_step(a5)             ;store value in instrument release step
  rts                                       ;return
eff1e:                                      ;set release delay
  move.b  d0,s_release_delay(a5)            ;store effect data in instrument release delay
  rts                                       ;return

effect_table:
  dc.l eff0 ,eff1 ,eff2 ,eff3 ,eff4 ,eff5 ,eff6 ,eff7
  dc.l eff8 ,eff9 ,effa ,effb ,effc ,effd ,effe ,efff
  dc.l eff10,eff11,eff12,eff13,eff14,eff15,eff16,eff17
  dc.l eff18,eff19,eff1a,eff1b,eff1c,eff1d,eff1e,eff0

play_speed: dc.b speed
  even
safe_zero:  ds.b 16

freq_table:
  dc.w 0000,6848,6464,6096,5760,5424,5120,4832,4560,4304,4064,3840
  dc.w 3616,3424,3232,3048,2880,2712,2560,2416,2280,2152,2032,1920
  dc.w 1808,1712,1616,1524,1440,1356,1280,1208,1140,1076,0960,0904
  dc.w 0856,0808,0762,0720,0678,0640,0604,0570,0538,0508,0480,0452
  dc.w 0428,0404,0381,0360,0339,0320,0302,0285,0269,0254,0240,0226
  dc.w 0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113
  dc.w 0113,0113,0113,0113,0113,0113,0113,0113,0113,0113,0113,0113

channel1: ds.b 57
  even
channel2: ds.b 57
  even
channel3: ds.b 57
  even
channel4: ds.b 57
  even

track1: dc.l 0
track2: dc.l 0
track3: dc.l 0
track4: dc.l 0
blocks: dc.l 0

snd_table: ds.l 20

data: incbin "module.dm"