  section player,data_c

start:
  move.l  4,a6
  jsr     -132(a6)
  bsr     dm_init
sync:
  cmp.b   #128,$dff006
  bne.s   sync
  bsr     dm_play
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


dm_play:
  movem.l d0-a6,-(sp)
  lea     channel1(pc),a6
  bsr.w   dm_calc_frequency
  lea     channel2(pc),a6
  bsr.w   dm_calc_frequency
  lea     channel3(pc),a6
  bsr.w   dm_calc_frequency
  lea     channel4(pc),a6
  bsr.w   dm_calc_frequency
  move.w  #$800f,$dff096
dm_sample_handler:
  move.w  #200,d0
dm_swait:
  dbf     d0,dm_swait
  lea     channel1(pc),a6
  movea.l (a6),a4
  movea.l 6(a6),a5
  tst.b   14(a5)
  beq.s   dm_no_sample1
  move.w  28(a5),4(a4)
  moveq   #0,d7
  move.w  26(a5),d7
  add.l   a5,d7
  addi.l  #30,d7
  move.l  d7,0(a4)
dm_no_sample1:
  lea     channel2(pc),a6
  movea.l (a6),a4
  movea.l 6(a6),a5
  tst.b   14(a5)
  beq.s   dm_no_sample2
  move.w  28(a5),4(a4)
  moveq   #0,d7
  move.w  26(a5),d7
  add.l   a5,d7
  addi.l  #30,d7
  move.l  d7,0(a4)
dm_no_sample2:
  lea     channel3(pc),a6
  movea.l (a6),a4
  movea.l 6(a6),a5
  tst.b   14(a5)
  beq.s   dm_no_sample3
  move.w  28(a5),4(a4)
  moveq   #0,d7
  move.w  26(a5),d7
  add.l   a5,d7
  addi.l  #30,d7
  move.l  d7,0(a4)
dm_no_sample3:
  lea     channel4(pc),a6
  movea.l (a6),a4
  movea.l 6(a6),a5
  tst.b   14(a5)
  beq.s   dm_no_sample4
  move.w  28(a5),4(a4)
  moveq   #0,d7
  move.w  26(a5),d7
  add.l   a5,d7
  addi.l  #30,d7
  move.l  d7,0(a4)
dm_no_sample4:
  movem.l (sp)+,d0-a6
  rts

dm_calc_frequency:
  movea.l (a6),a4
  movea.l 6(a6),a5
  subq.b  #1,47(a6)
  bne.w   dm_block_con
  move.b  play_speed(pc),47(a6)
  tst.l   28(a6)
  bne.s   dm_check_block
dm_track_step:
  movea.l 18(a6),a0
  move.w  22(a6),d7
  move.w  (a0,d7.w),d0
  cmpi.w  #-1,d0
  bne.s   dm_track_con
  move.w  2(a0,d7.w),d0
  andi.w  #$7ff,d0
  asl.w   #1,d0
  move.w  d0,22(a6)
  bra.s   dm_track_step
dm_track_con:
  move.b  d0,50(a6)
  asr.l   #2,d0
  andi.l  #16320,d0
  add.l   blocks(pc),d0
  move.l  d0,24(a6)
  addq.w  #2,22(a6)
dm_check_block:
  movea.l 24(a6),a0
  adda.l  28(a6),a0
  tst.b   2(a0)
  beq.s   dm_no_new_effect
  move.b  2(a0),55(a6)
  move.b  3(a0),56(a6)
dm_no_new_effect:
  moveq   #0,d0
  move.b  1(a0),d0
  beq.w   dm_test_effect
  add.b   50(a6),d0
  move.b  d0,40(a6)
  move.w  4(a6),d0
  subi.w  #$8000,d0
  move.w  d0,$dff096
  moveq   #0,d0
  move.b  d0,51(a6)
  move.w  d0,48(a6)
  move.w  d0,52(a6)
  move.b  d0,54(a6)
  move.b  2(a0),55(a6)
  move.b  3(a0),56(a6)
  lea     snd_table(pc),a1
  move.b  (a0),d0
  asl.l   #2,d0
  move.l  (a1,d0.l),d0
  move.l  d0,6(a6)
  movea.l d0,a5
  addi.l  #30,d0
  move.l  d0,12(a6)
  clr.b   16(a6)
  tst.b   14(a5)
  beq.s   dm_no_sample_clear
  clr.w   30(a5)
  move.l  d0,0(a4)
dm_no_sample_clear:
  move.w  24(a5),d0
  asr.w   #1,d0
  move.w  d0,4(a4)
  move.b  9(a5),32(a6)
  move.b  11(a5),d0
  move.b  d0,33(a6)
  move.b  d0,34(a6)
  asl.b   #1,d0
  move.b  d0,35(a6)
  clr.b   41(a6)
  clr.b   17(a6)
  clr.b   16(a6)
  clr.b   42(a6)
  clr.b   43(a6)
  move.w  4(a5),44(a6)
  clr.b   46(a6)
dm_test_effect:
  addq.l  #4,28(a6)
  cmpi.l  #64,28(a6)
  bne.s   dm_block_con
  clr.l   28(a6)
dm_block_con:
  tst.b   14(a5)
  bne.s   dm_portamento_handler
  tst.b   17(a6)
  beq.s   dm_sound_table_handler
  subq.b  #1,17(a6)
  bra.s dm_portamento_handler

dm_sound_table_handler:
  move.b  15(a5),17(a6)
dm_sound_read_again:
  movea.l 12(a6),a0
  moveq   #0,d6
  move.b  16(a6),d6
  cmpi.b  #48,d6
  bmi.s   dm_sound_read_c
  clr.b   16(a6)
  moveq   #0,d6
dm_sound_read_c:
  adda.l  d6,a0
  moveq   #0,d7
  move.b  (a0),d7
  bpl.s   dm_new_sounddata
  cmpi.b  #$ff,d7
  bne.s   dm_sound_new_speed
  move.b  1(a0),d7
  move.b  d7,16(a6)
  bra.s   dm_sound_read_again
dm_sound_new_speed:
  andi.b  #127,d7
  move.b  d7,15(a5)
  addq.b  #1,16(a6)
  bra.s   dm_sound_read_again
dm_new_sounddata:
  asl.l   #5,d7
  addi.l  #78,d7
  add.l   6(a6),d7
  move.l  d7,0(a4)
  addq.b  #1,16(a6)

dm_portamento_handler:
  tst.b   13(a5)
  beq.s   dm_vibrator_handler
  move.w  10(a6),d1
  bne.s   dm_porta_con
  moveq   #0,d0
  lea     freq_table(pc),a1
  move.b  40(a6),d0
  asl.w   #1,d0
  move.w  (a1,d0.w),d0
  add.w   48(a6),d0
  move.w  d0,10(a6)
  bra.s   dm_vibrator_handler
dm_porta_con:
  moveq   #0,d0
  moveq   #0,d2
  move.b  13(a5),d2
  lea     freq_table(pc),a1
  move.b  40(a6),d0
  asl.w   #1,d0
  move.w  (a1,d0.w),d0
  add.w   48(a6),d0
  cmp.w   d0,d1
  beq.s   dm_vibrator_handler
  bcs.s   dm_porta_low
  sub.w   d2,d1
  cmp.w   d0,d1
  bpl.s   dm_porta_high_con
  move.w  d0,10(a6)
  bra.s   dm_vibrator_handler
dm_porta_high_con:
  move.w  d1,10(a6)
  bra.s   dm_vibrator_handler
dm_porta_low:
  add.w   d2,d1
  cmp.w   d0,d1
  bmi.s   dm_porta_low_con
  move.w  d0,10(a6)
  bra.s   dm_vibrator_handler
dm_porta_low_con:
  move.w  d1,10(a6)

dm_vibrator_handler:
  tst.b   32(a6)
  beq.s   dm_calc_vibrator
  subq.b  #1,32(a6)
  bra.s   dm_bendrate_handler
dm_calc_vibrator:
  moveq   #0,d0
  moveq   #0,d1
  move.b  34(a6),d0
  move.b  d0,d2
  move.b  10(a5),d1
  mulu.w  d1,d0
  move.w  d0,36(a6)
  btst    #0,51(a6)
  bne.s   dm_vibrator_minus
  addq.b  #1,d2
  cmp.b   35(a6),d2
  bne.s   dm_vibrator_no_reset
  eori.b  #1,51(a6)
dm_vibrator_no_reset:
  move.b  d2,34(a6)
  bra.s   dm_bendrate_handler
dm_vibrator_minus:
  subq.b  #1,d2
  bne.s   dm_vibrator_no_reset2
  eori.b  #1,51(a6)
dm_vibrator_no_reset2:
  move.b  d2,34(a6)

dm_bendrate_handler:
  moveq   #0,d0
  movea.l 6(a6),a1
  move.b  12(a1),d0
  bpl.s   dm_rate_minus
  neg.b   d0
  add.w   d0,48(a6)
  bra.s   dm_effect_handler
dm_rate_minus:
  sub.w   d0,48(a6)

dm_effect_handler:
  moveq   #0,d0
  moveq   #0,d1
  move.b  56(a6),d0
  move.b  55(a6),d1
  lea effect_table(pc),a1
  andi.b  #31,d1
  asl.l   #2,d1
  movea.l (a1,d1.w),a1
  jsr (a1)

dm_arpeggio_handler:
  movea.l a5,a1
  adda.l  #16,a1
  move.b  52(a6),d0
  move.b  (a1,d0.l),d1
  addq.b  #1,52(a6)
  andi.b  #7,52(a6)

dm_store_frequency:
  moveq   #0,d0
  lea     freq_table(pc),a1
  move.b  40(a6),d0
  add.b   d1,d0
  asl.w   #1,d0
  move.w  (a1,d0.w),d0
  moveq   #0,d1
  moveq   #0,d2
  move.b  33(a6),d1
  move.b  10(a5),d2
  mulu.w  d2,d1
  sub.w   d1,d0
  add.w   48(a6),d0
  tst.b   13(a5)
  beq.s   dm_store_no_port
  move.w  10(a6),d0
  bra.s   dm_store_port
dm_store_no_port:
  clr.w   10(a6)
dm_store_port:
  add.w   36(a6),d0
  move.w  d0,6(a4)

dm_volume_handler:
  moveq   #0,d1
  move.b  41(a6),d1
  move.b  51(a6),d0
  andi.b  #14,d0
  tst.b   d0
  bne.s   dm_test_decay
  tst.b   42(a6)
  beq.s   dm_attack_handler
  subq.b  #1,42(a6)
  bra.w   dm_volume_exit
dm_attack_handler:
  move.b  1(a5),42(a6)
  add.b   (a5),d1
  cmpi.b  #64,d1
  bcs.s   dm_test_decay
  ori.b   #2,d0
  ori.b   #2,51(a6)
  moveq   #64,d1
dm_test_decay:
  cmpi.b  #2,d0
  bne.s   dm_test_sustain
  tst.b   43(a6)
  beq.s   dm_decay_handler
  subq.b  #1,43(a6)
  bra.s   dm_volume_exit
dm_decay_handler:
  move.b  3(a5),43(a6)
  move.b  8(a5),d2
  sub.b   2(a5),d1
  cmp.b   d2,d1
  bhi.s   dm_test_sustain
  move.b  8(a5),d1
  ori.b   #6,d0
  ori.b   #6,51(a6)
dm_test_sustain:
  cmpi.b  #6,d0
  bne.s   dm_test_release
  tst.w   44(a6)
  beq.s   dm_sustain_handler
  subq.w  #1,44(a6)
  bra.s   dm_volume_exit
dm_sustain_handler:
  ori.b   #14,d0
  ori.b   #14,51(a6)
dm_test_release:
  cmpi.b  #14,d0
  bne.s   dm_volume_exit
  tst.b   46(a6)
  beq.s   dm_release_handler
  subq.b  #1,46(a6)
  bra.s   dm_volume_exit
dm_release_handler:
  move.b  7(a5),46(a6)
  sub.b   6(a5),d1
  bpl.s   dm_volume_exit
  andi.b  #9,51(a6)
  moveq   #0,d1
dm_volume_exit:
  move.b  d1,41(a6)
  move.w  d1,8(a4)
  rts

dm_init:
  lea     track1(pc),a1
  lea     data(pc),a2
  add.w   #104,a2
  moveq   #24,d7
dm_init_loop:
  move.l  a2,(a1)+
  dbf     d7,dm_init_loop
  moveq   #23,d6
  lea     track1(pc),a1
  add.w   #96,a1
dm_init_loop2:
  lea     data(pc),a0
  add.w   #4,a0
  move.l  d6,d7
dm_init_loop3:
  move.l  (a0)+,d0
  add.l   d0,(a1)
  dbf     d7,dm_init_loop3
  subq.l  #4,a1
  dbf     d6,dm_init_loop2
  lea     $dff0a0,a0
  lea     channel1(pc),a6
  bsr.s   dm_setup
  move.w  #$8001,4(a6)
  move.l  track1,18(a6)
  adda.l  #16,a0
  lea     channel2(pc),a6
  bsr.s   dm_setup
  move.w  #$8002,4(a6)
  move.l  track2,18(a6)
  adda.l  #16,a0
  lea     channel3(pc),a6
  bsr.s   dm_setup
  move.w  #$8004,4(a6)
  move.l  track3,18(a6)
  adda.l  #16,a0
  lea     channel4(pc),a6
  bsr.s   dm_setup
  move.w  #$8008,4(a6)
  move.l  track4,18(a6)
  rts

dm_setup:
  move.l  a0,0(a6)
  move.w  #16,4(a0)
  clr.w   8(a0)
  move.l  #safe_zero,6(a6)
  clr.w   10(a6)
  move.l  snd_table(pc),d0
  addi.l  #16,d0
  move.l  d0,12(a6)
  clr.w   16(a6)
  clr.w   22(a6)
  move.l  blocks(pc),24(a6)
  clr.l   28(a6)
  clr.l   32(a6)
  clr.l   36(a6)
  clr.l   40(a6)
  move.l  #1,44(a6)
  clr.l   48(a6)
  clr.l   52(a6)
  clr.w   56(a6)
  rts


eff00:
  rts
eff01:
  andi.b  #15,d0
  beq.s   eff01_exit
  move.b  d0,play_speed
eff01_exit:
  rts
eff02:
  sub.w   d0,48(a6)
  rts
eff03:
  add.w   d0,48(a6)
  rts
eff04:
  tst.b   d0
  beq.w   led_off
  bset    #1,$bfe001
  rts
led_off:
  bclr    #1,$bfe001
  rts
eff05:
  move.b  d0,9(a5)
  rts
eff06:
  move.b  d0,10(a5)
  rts
eff07:
  move.b  d0,11(a5)
  rts
eff08:
  move.b  d0,12(a5)
  rts
eff09:
  move.b  d0,13(a5)
  rts
eff10:
  cmpi.b  #65,d0
  bmi.s   eff10_con
  moveq   #64,d0
eff10_con:
  move.b  d0,8(a5)
  rts
eff11:
  move.b  d0,16(a5)
  rts
eff12:
  move.b  d0,17(a5)
  rts
eff13:
  move.b  d0,18(a5)
  rts
eff14:
  move.b  d0,19(a5)
  rts
eff15:
  move.b  d0,20(a5)
  rts
eff16:
  move.b  d0,21(a5)
  rts
eff17:
  move.b  d0,22(a5)
  rts
eff18:
  move.b  d0,23(a5)
  rts
eff19:
  move.b  d0,16(a5)
  move.b  d0,20(a5)
  rts
eff20:
  move.b  d0,17(a5)
  move.b  d0,21(a5)
  rts
eff21:
  move.b  d0,18(a5)
  move.b  d0,22(a5)
  rts
eff22:
  move.b  d0,19(a5)
  move.b  d0,23(a5)
  rts
eff23:
  cmpi.b  #65,d0
  bmi.s   eff23_con
  moveq   #64,d0
eff23_con:
  move.b  d0,0(a5)
  rts
eff24:
  move.b  d0,1(a5)
  rts
eff25:
  cmpi.b  #65,d0
  bmi.s   eff25_con
  moveq   #64,d0
eff25_con:
  move.b  d0,2(a5)
  rts
eff26:
  move.b  d0,3(a5)
  rts
eff27:
  move.b  d0,4(a5)
  rts
eff28:
  move.b  d0,5(a5)
  rts
eff29:
  cmpi.b  #65,d0
  bmi.s   eff29_con
  move.b  #64,d0
eff29_con:
  move.b  d0,6(a5)
  rts
eff30:
  move.b  d0,7(a5)
  rts

effect_table:
  dc.l eff00,eff01,eff02,eff03,eff04,eff05,eff06,eff07
  dc.l eff08,eff09,eff10,eff11,eff12,eff13,eff14,eff15
  dc.l eff16,eff17,eff18,eff19,eff20,eff21,eff21,eff23
  dc.l eff24,eff25,eff26,eff27,eff28,eff29,eff30,eff00

play_speed:
  dc.b  6
  even
safe_zero
  ds.b 16

freq_table:
  dc.w 0000,6848,6464,6096,5760,5424,5120,4832,4560,4304,4064,3840
  dc.w 3616,3424,3232,3048,2880,2712,2560,2416,2280,2152,2032,1920
  dc.w 1808,1712,1616,1524,1440,1356,1280,1208,1140,1076,0960,0904
  dc.w 0856,0808,0762,0720,0678,0640,0604,0570,0538,0508,0480,0452
  dc.w 0428,0404,0381,0360,0339,0320,0302,0285,0269,0254,0240,0226
  dc.w 0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113
  dc.w 0113,0113,0113,0113,0113,0113,0113,0113,0113,0113,0113,0113

channel1: ds.b 58
channel2: ds.b 58
channel3: ds.b 58
channel4: ds.b 58

track1: dc.l 0
track2: dc.l 0
track3: dc.l 0
track4: dc.l 0
blocks: dc.l 0

snd_table: ds.l 20

data: incbin "module.dm"