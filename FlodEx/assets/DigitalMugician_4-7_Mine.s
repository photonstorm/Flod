;Digital Mugician 4/7 Voices Replay Routine
;Modified by Christian Corti

  section player,data_c

main:
  movea.l 4,a6
  jsr     -132(a6)
  moveq   #0,d0
  bsr.w   sevenmuzaxon
sync:
  cmpi.b  #128,$dff006
  bne.b   sync
  bsr.w   sevenplayer
  btst    #6,$bfe001
  bne.b   sync
  bsr.w   sevenmuzaxoff
  bclr    #1,$bfe001
  movea.l 4,a6
  jmp     -138(a6)
  rts


initializer:
  moveq   #0,d7
  lea     ssname4(pc),a0
  lea     muzak(pc),a1
  moveq   #23,d6
compa:
  move.b  (a0)+,d2
  cmp.b   (a1)+,d2
  bne.b   mug2
  dbra    d6,compa
  move.w  #0,channel7flg
  bra.b   skip
mug2:
  lea     ssname7(pc),a0
  lea     muzak(pc),a1
  moveq   #23,d6
compa2:
  move.b  (a0)+,d2
  cmp.b   (a1)+,d2
  bne.w   error
  dbra    d6,compa2
  move.w  #1,channel7flg

skip:
  moveq   #0,d4
  moveq   #0,d6
  move.w  d0,d4
  move.w  d4,d6
  asl.w   #4,d6
  lea     muzak(pc),a5
  lea     76(a5),a4
  lea     songdata2(pc),a6
  move.l  a4,(a6)
  add.l   d6,(a6)
  lea     128(a4),a4
  lea     28(a5),a2
  moveq   #0,d2
  move.w  d4,d1
  addq.w  #1,d1
  moveq   #7,d5
songslop:
  move.l  (a2)+,d3
  asl.l   #3,d3
  cmp.w   d2,d4
  bne.b   overt
  move.l  a4,4(a6)
overt:
  cmp.w   d2,d1
  bne.b   overt2
  move.l  a4,songdata7
overt2:
  addq.w  #1,d2
  lea     (a4,d3.l),a4
  dbra    d5,songslop
  move.l  60(a5),d3
  asl.l   #4,d3
  move.l  a4,8(a6)
  lea     (a4,d3.l),a4
  move.l  64(a5),d3
  asl.l   #7,d3
  move.l  a4,16(a6)
  lea     (a4,d3.l),a4
  move.l  68(a5),d3
  move.l  a4,24(a6)
  asl.l   #5,d3
  lea     (a4,d3.l),a4
  moveq   #0,d3
  move.w  26(a5),d3
  asl.l   #8,d3
  move.l  a4,20(a6)
  lea     (a4,d3.l),a4
  move.l  a4,28(a6)
  move.l  72(a5),d3
  lea     (a4,d3.l),a4
  tst.w   24(a5)
  beq.b   nikko2
  move.l  a4,12(a6)
  rts
nikko2:
  move.l  a4,12(a6)
  move.w  #255,d7
leegf:
  clr.b   (a4)+
  dbra    d7,leegf
  rts
error:
  moveq   #-1,d7
  rts

ssname4: dc.b ' MUGICIAN/SOFTEYES 1990 '
ssname7: dc.b ' MUGICIAN2/SOFTEYES 1990'

exit:
  rts

sevenmuzaxon:
  bset    #1,$bfe001                        ;disable led filter
  lea     songnr(pc),a0                     ;songnr in a0
  move.w  d0,(a0)                           ;store request song # in songnr
  bsr.w   initializer                       ;gosub initializer
  cmpi.w  #-1,d7                            ;test for error
  beq.b   exit                              ;if == goto exit
  jsr     preptabs                          ;gosub preptabs  
  lea     datach1(pc),a0                    ;datach1 in a0
  moveq   #83,d7                            ;loop counter
frclr3:
  clr.l   (a0)+                             ;reset datachx vars
  dbra    d7,frclr3                         ;loop

  lea     playerdat(pc),a0                  ;playerdat in a0
  clr.l   (a0)+                             ;reset songdelay, newpatflg
  clr.w   (a0)+                             ;reset newnoteflg
  addq.w  #2,a0                             ;add offset
  clr.l   (a0)+                             ;reset patcnt, dma
  move.w  #124,$dff0a6                      ;amiga channel 1 period = 124
  move.w  #124,$dff0b6                      ;amiga channel 2 period = 124
  move.w  #124,$dff0c6                      ;amiga channel 3 period = 124
  move.w  #2,$dff0a4                        ;amiga channel 1 length = 2
  move.w  #2,$dff0b4                        ;amiga channel 2 length = 2
  move.w  #2,$dff0c4                        ;amiga channel 3 length = 2
  move.l  #pielbuf1,$dff0d0                 ;amiga channel 4 pointer = pielbuf1
  move.w  #175,$dff0d4                      ;amiga channel 4 length = 175
  move.w  kwalcnt(pc),$dff0d6               ;amiga channel 4 period = kwalcnt
  move.w  #64,$dff0d8                       ;amiga channel 4 volume = 64
  lea     pielbuf1(pc),a0                   ;pielbuf1 in a0
  move.w  #174,d7                           ;loop counter
leegp:
  clr.w   (a0)+                             ;reset pielbuf1 samples
  dbra    d7,leegp                          ;loop

  move.w  #0,$dff0a8                        ;reset amiga channel 1 volume
  move.w  #0,$dff0b8                        ;reset amiga channel 2 volume
  move.w  #0,$dff0c8                        ;reset amiga channel 3 volume
  move.w  #$000f,$dff096                    ;disable amiga channels
  moveq   #6,d7                             ;loop counter
  lea     datach1(pc),a0                    ;datach1 in a0
  ;lea     datach1(pc),a1                    ;datach1 in a1
initizer:
  move.w  songnr(pc),d0                     ;songnr in d0
  cmpi.w  #3,d7                             ;compare loop counter to 3
  bhi.b   poepla                            ;if higher goto poepla
  tst.w   channel7flg                       ;test channel7flg
  beq.b   poepla                            ;if 0 goto poepla
  addq.w  #1,d0                             ;else increment songnr (why?)
poepla:
  move.w  d0,(a0)                           ;store songnr in datachx
  adda.w  #48,a0                            ;pointer to next datach
  ;move.w  d0,(a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;clr.w   (a0)+
  ;lea     48(a1),a1                         ;pointer to next datach in a1
  ;lea     (a1),a0                           ;pointer to next datach in a0
  dbra    d7,initizer                       ;loop

  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  ;move.w  songnr(pc),d0                    ;!!!
  ;asl.w   #4,d0                            ;!!!
  movea.l songdata2(pc),a0                  ;songdata2 in a0
  move.b  3(a0),d1                          ;song length in d1
  move.w  d1,songlength                     ;store in songlength
  move.b  2(a0),d1                          ;song speed in d1
  move.w  d1,songdelay                      ;store in songdelay (timer)
  move.b  d1,d0                             ;copy speed in d0
  andi.b  #15,d0                            ;speed1 mask (0-15)
  andi.b  #15,d1                            ;speed2 mask (0-15)
  asl.b   #4,d0                             ;multiply speed1 by 16
  or.b    d0,d1                             ;speed1 | speed2
  move.w  d1,songspd                        ;result in songspd
  move.w  #1,newpatflg                      ;newpatflg = 1
  move.w  #1,newnoteflg                     ;newnoteflg = 1
  move.w  #64,patlength                     ;patlength = 64
  clr.w   patcnt                            ;reset patcnt
  clr.w   songcnt                           ;reset songcnt
  move.w  #$000f,$dff096                    ;disable amiga channels
  rts                                       ;return

ch1mute: dc.w 0
ch2mute: dc.w 0
ch3mute: dc.w 0
ch4mute: dc.w 0
ch5mute: dc.w 0
ch6mute: dc.w 0
ch7mute: dc.w 0

channel7flg: dc.w 0
dummychan:   ds.b 16
relaybuf:    ds.l 3

sevenmuzaxoff:
  move.w  #$000f,$dff096                    ;disable amiga channels
  move.w  #0,$dff0a8                        ;reset amiga channel 1 volume
  move.w  #0,$dff0b8                        ;reset amiga channel 2 volume
  move.w  #0,$dff0c8                        ;reset amiga channel 3 volume
  move.w  #0,$dff0d8                        ;reset amiga channel 4 volume
  lea     datach1(pc),a0                    ;datach1 in a0
  moveq   #83,d7                            ;loop counter
frclr:
  clr.l   (a0)+                             ;reset datachx vars
  dbra    d7,frclr                          ;loop
  rts                                       ;return

sevenplayer:
  tst.w   channel7flg                       ;test channel7flg
  bne.w   playerk7                          ;if != 0 goto playerk7
  movem.l d0-d7/a0-a6,-(sp)                 ;store registers
  move.l  #$80808080,chtab                  ;store in chtab
  move.l  #chtab,checkpnt                   ;checkpnt pointer to chtab
  bsr.w   samplereinit                      ;gosub samplereinit
  lea     playerdat(pc),a1                  ;playerdat in a1
  lea     $dff0a0,a6                        ;amiga channel 1 address in a6
  lea     datach1(pc),a5                    ;datach1 in a5
  move.w  #1,10(a1)                         ;dma = 1
  moveq   #0,d6                             ;track step offset
  tst.w   ch1mute                           ;test ch1mute
  bne.b   skip1m                            ;if != 0 goto skip1m
  movea.l songdata(pc),a0                   ;songdata in a0
  bsr.w   playit                            ;gosub playit
skip1m:
  lea     16(a6),a6                         ;pointer to next amiga channel
  lea     48(a5),a5                         ;pointer to next datach
  moveq   #2,d6                             ;track step offset
  move.w  d6,10(a1)                         ;dma = 2
  tst.w   ch2mute                           ;test ch2mute
  bne.b   skip2m                            ;if != 0 goto skip2m
  movea.l songdata(pc),a0                   ;songdata in a0
  bsr.w   playit                            ;gosub playit
skip2m:
  lea     16(a6),a6                         ;pointer to next amiga channel
  lea     48(a5),a5                         ;pointer to next datach
  moveq   #4,d6                             ;track step offset
  move.w  d6,10(a1)                         ;dma = 4
  tst.w   ch3mute                           ;test ch3mute
  bne.b   skip3m                            ;if != 0 goto skip3m
  movea.l songdata(pc),a0                   ;songdata in a0
  bsr.w   playit                            ;gosub playit
skip3m:
  lea     16(a6),a6                         ;pointer to next amiga channel
  lea     48(a5),a5                         ;pointer to next datach
  moveq   #6,d6                             ;track step offset
  move.w  #8,10(a1)                         ;dma = 8
  tst.w   ch4mute                           ;test ch4mute
  bne.b   playpatt                          ;if != 0 goto playpatt
  movea.l songdata(pc),a0                   ;songdata in a0
  bsr.w   playit                            ;gosub playit
playpatt:
  lea     $dff0a0,a6                        ;amiga channel 1 address in a6
  lea     datach1(pc),a5                    ;datach1 in a5
  bsr.w   playit2                           ;gosub playit2
  lea     16(a6),a6                         ;pointer to next amiga channel
  lea     48(a5),a5                         ;pointer to next datach
  bsr.w   playit2                           ;gosub playit2
  lea     16(a6),a6                         ;pointer to next amiga channel
  lea     48(a5),a5                         ;pointer to next datach
  bsr.w   playit2                           ;gosub playit2
  lea     16(a6),a6                         ;pointer to next amiga channel
  lea     48(a5),a5                         ;pointer to next datach
  bsr.w   playit2                           ;gosub playit2

intafmaken:
  clr.l   2(a1)                             ;reset newpatflg, newnoteflg
  subq.w  #1,(a1)                           ;decrement songdelay
  bne.b   interweg                          ;if != 0 goto interweg
  move.w  14(a1),(a1)                       ;copy songspd in songdelay (reset timer)
  andi.w  #15,(a1)                          ;songdelay mask (0-15)
  move.w  14(a1),d5                         ;songspd in d5
  andi.w  #15,d5                            ;speed1 mask (0-15)
  move.w  14(a1),d0                         ;songspd in d0
  andi.w  #240,d0                           ;speed2 mask (0-240)
  asr.w   #4,d0                             ;divide speed2 by 16
  asl.w   #4,d5                             ;multiply speed1 by 16
  or.w    d0,d5                             ;speed2 | speed1
  move.w  d5,14(a1)                         ;result in songspd
  move.w  #1,4(a1)                          ;newnoteflg = 1
  addq.w  #1,8(a1)                          ;increment patcnt
  move.w  18(a1),d5                         ;patlength in d5
  cmpi.w  #64,8(a1)                         ;compare patlength to 64
  beq.b   ohoh                              ;if == goto ohoh
  cmp.w   8(a1),d5                          ;compare patlength to patcnt
  bne.b   interweg                          ;if != goto interweg
ohoh:
  clr.w   8(a1)                             ;reset patcnt
  move.w  #1,2(a1)                          ;newpatflg = 1
  addq.w  #1,6(a1)                          ;increment songcnt
  move.w  16(a1),d5                         ;songlength in d5
  cmp.w   6(a1),d5                          ;compare songlength to songcnt
  bne.b   interweg                          ;if != goto interweg
  movea.l songdata2(pc),a0                  ;songdata2 in a0
  move.b  1(a0),7(a1)                       ;songcnt = song step restart
  clr.b   6(a1)                             ;clear songcnt high byte
interweg:
  move.w  #$800f,$dff096                    ;enable amiga channels
  movem.l (sp)+,d0-d7/a0-a6                 ;restore registers
  rts                                       ;return

playerk7:
  movem.l d0-d7/a0-a6,-(sp)                 ;store registers
  move.l  #$80808080,chtab                  ;store in chtab
  move.l  #chtab,checkpnt                   ;checkpnt pointer to chtab
  bsr.w   samplereinit                      ;gosub samplereinit
  lea     playerdat(pc),a1                  ;playerdat in a1
  lea     $dff0a0,a6                        ;amiga channel 1 address in a6
  lea     datach1(pc),a5                    ;datach1 in a5
  move.w  #1,10(a1)                         ;dma = 1
  moveq   #0,d6                             ;track step offset
  tst.w   ch1mute                           ;test ch1mute
  bne.b   skip1m7                           ;if != 0 goto skip1m7
  movea.l songdata(pc),a0                   ;songdata in a0
  bsr.w   playit                            ;gosub playit
skip1m7:
  ;move.w  #$8008,$dff096                   ;!!!
  lea     16(a6),a6                         ;pointer to next amiga channel
  lea     48(a5),a5                         ;pointer to next datach
  moveq   #2,d6                             ;track step offset
  move.w  d6,10(a1)                         ;dma = 2
  tst.w   ch2mute                           ;test ch2mute
  bne.b   skip2m7                           ;if != 0 goto skip2m7
  movea.l songdata(pc),a0                   ;songdata in a0
  bsr.w   playit                            ;gosub playit
skip2m7:
  lea     16(a6),a6                         ;pointer to next amiga channel
  lea     48(a5),a5                         ;pointer to next datach
  moveq   #4,d6                             ;track step offset
  move.w  d6,10(a1)                         ;dma = 4
  tst.w   ch3mute                           ;test ch3mute
  bne.b   skip3m7                           ;if != 0 goto skip3m7
  movea.l songdata(pc),a0                   ;songdata in a0
  bsr.w   playit                            ;gosub playit
skip3m7:
  lea     dummychan(pc),a6                  ;dummychan in a6
  lea     48(a5),a5                         ;pointer to next datach
  move.w  #0,10(a1)                         ;dma = 0
  moveq   #0,d6                             ;track step offset
  clr.l   relaybuf                          ;reset relaybuf pointer
  clr.l   relaybuf+4                        ;reset relaybuf length
  clr.l   relaybuf+8                        ;reset relaybuf loop
  tst.w   ch4mute                           ;test ch4mute
  bne.b   skip4m7                           ;if != 0 goto skip4m7
  movea.l songdata7(pc),a0                  ;songdata7 in a0
  bsr.w   playit                            ;gosub playit
  tst.l   relaybuf                          ;test relaybuf pointer
  beq.b   skip4m7                           ;if 0 goto skip4m7
  move.l  relaybuf,mix1src                  ;copy relaybuf pointer in mix1src
  move.l  relaybuf+4,mix1end                ;copy relaybuf length in mix1end
  move.l  relaybuf+8,mix1loop               ;copy relaybuf loop in mix1loop
  move.w  #0,mix1mute                       ;mix1mute = 0
skip4m7:
  lea     48(a5),a5                         ;pointer to next datach
  move.w  #0,10(a1)                         ;dma = 0
  moveq   #2,d6                             ;track step offset
  clr.l   relaybuf                          ;reset relaybuf pointer
  clr.l   relaybuf+4                        ;reset relaybuf length
  clr.l   relaybuf+8                        ;reset relaybuf loop
  tst.w   ch5mute                           ;test ch5mute
  bne.b   skip5m7                           ;if != 0 goto skip5m7
  movea.l songdata7(pc),a0                  ;songdata7 in a0
  bsr.w   playit                            ;gosub playit
  tst.l   relaybuf                          ;test relaybuf pointer
  beq.b   skip5m7                           ;if 0 goto skip5m7
  move.l  relaybuf,mix2src                  ;copy relaybuf pointer in mix2src
  move.l  relaybuf+4,mix2end                ;copy relaybuf length in mix2end
  move.l  relaybuf+8,mix2loop               ;copy relaybuf loop in mix2loop
  move.w  #0,mix2mute                       ;mix2mute = 0
skip5m7:
  lea     48(a5),a5                         ;pointer to next datach
  move.w  #0,10(a1)                         ;dma = 0
  moveq   #4,d6                             ;track step offset
  clr.l   relaybuf                          ;reset relaybuf pointer
  clr.l   relaybuf+4                        ;reset relaybuf length
  clr.l   relaybuf+8                        ;reset relaybuf loop
  tst.w   ch6mute                           ;test ch6mute
  bne.b   skip6m7                           ;if != 0 goto skip6m7
  movea.l songdata7(pc),a0                  ;songdata7 in a0
  bsr.w   playit                            ;gosub playit
  tst.l   relaybuf                          ;test relaybuf pointer
  beq.b   skip6m7                           ;if 0 goto skip6m7
  move.l  relaybuf,mix3src                  ;copy relaybuf pointer in mix3src
  move.l  relaybuf+4,mix3end                ;copy relaybuf length in mix3end
  move.l  relaybuf+8,mix3loop               ;copy relaybuf loop in mix3loop
  move.w  #0,mix3mute                       ;mix3mute = 0
skip6m7:
  lea     48(a5),a5                         ;pointer to next datach
  move.w  #0,10(a1)                         ;dma = 0
  moveq   #6,d6                             ;track step offset
  clr.l   relaybuf                          ;reset relaybuf pointer
  clr.l   relaybuf+4                        ;reset relaybuf length
  clr.l   relaybuf+8                        ;reset relaybuf loop
  tst.w   ch7mute                           ;test ch7mute
  bne.b   playpatt7                         ;goto playpatt7
  movea.l songdata7(pc),a0                  ;songdata7 in a0
  bsr.w   playit                            ;gosub playit
  tst.l   relaybuf                          ;test relaybuf pointer
  beq.b   playpatt7                         ;if 0 goto playpatt7
  move.l  relaybuf,mix4src                  ;copy relaybuf pointer in mix4src
  move.l  relaybuf+4,mix4end                ;copy relaybuf length in mix4end
  move.l  relaybuf+8,mix4loop               ;copy relaybuf loop in mix4loop
  move.w  #0,mix4mute                       ;mix4mute = 0
playpatt7:
  lea     $dff0a0,a6                        ;amiga channel 1 address in a6
  lea     datach1(pc),a5                    ;datach1 in a5
  bsr.w   playit2                           ;gosub playit2
  lea     16(a6),a6                         ;pointer to next amiga channel
  lea     48(a5),a5                         ;pointer to next datach
  bsr.w   playit2                           ;gosub playit2
  lea     16(a6),a6                         ;pointer to next amiga channel
  lea     48(a5),a5                         ;pointer to next datach
  bsr.w   playit2                           ;gosub playit2
  lea     dummychan(pc),a6                  ;dummychan in a6
  lea     48(a5),a5                         ;pointer to next datach
  bsr.w   playit2                           ;gosub playit2
  lea     48(a5),a5                         ;pointer to next datach
  bsr.w   playit2                           ;gosub playit2
  lea     48(a5),a5                         ;pointer to next datach
  bsr.w   playit2                           ;gosub playit2
  lea     48(a5),a5                         ;pointer to next datach
  bsr.w   playit2                           ;gosub playit2
  movem.l d0-d7/a0-a6,-(sp)                 ;store registers
  bsr.w   channel4mixer                     ;gosub channel4mixer
  movem.l (sp)+,d0-d7/a0-a6                 ;restore registers
  bra.w   intafmaken                        ;goto intafmaken

playit:
  moveq   #0,d0                             ;clear d0
  tst.w   2(a1)                             ;test newpatflg
  beq.b   notnewpat                         ;if 0 goto notnewpat
  ;move.w  (a5),d0                          ;!!!
  ;ror.w   #6,d0                            ;!!!
  move.w  6(a1),d0                          ;songcnt in d0
  asl.w   #3,d0                             ;multiply by 8
  add.w   d0,d6                             ;add step offset
  move.b  (a0,d6.l),3(a5)                   ;step pattern # in datachx
  move.b  1(a0,d6.l),9(a5)                  ;step transpose in datachx
notnewpat:
  tst.w   4(a1)                             ;test newnoteflg
  beq.w   insthandle                        ;if 0 goto insthandle
  move.l  patdata(pc),a0                    ;patdata in a0
  move.w  2(a5),d0                          ;pattern # in d0
  asl.w   #8,d0                             ;multiply by 256
  adda.w  d0,a0                             ;add pattern offset
  move.w  8(a1),d0                          ;patcnt in d0
  asl.w   #2,d0                             ;multiply by 4
  tst.b   (a0,d0.l)                         ;test command note
  beq.w   insthandle                        ;if 0 goto insthandle
  adda.w  d0,a0                             ;add command offset
  cmpi.b  #74,2(a0)                         ;compare command val1 to 74
  beq.b   zelfdinstr                        ;if == goto zelfdinstr
  move.b  (a0),7(a5)                        ;command note in datachx
  tst.b   1(a0)                             ;test command instrument #
  beq.b   zelfdinstr                        ;if 0 goto zelfdinstr
  move.b  1(a0),5(a5)                       ;command instrument # in datachx
  subq.b  #1,5(a5)                          ;decrement datachx instrument #
zelfdinstr:
  move.l  instdata(pc),a4                   ;instdata in a4
  move.w  4(a5),d0                          ;instrument # in d0
  asl.w   #4,d0                             ;multiply by 16 (instrument header = 16 bytes)
  adda.w  d0,a4                             ;add instrument offset
  move.b  8(a4),19(a5)                      ;instrument finetune in datachx
  andi.b  #63,5(a5)                         ;instrument # mask (0-63)
  clr.b   15(a5)                            ;reset datachx val1
  cmpi.b  #64,2(a0)                         ;compare command val1 to 64
  blo.b   pbnd                              ;if < goto pbnd (pitchbend)
  move.b  2(a0),15(a5)                      ;else command val1 in datachx
  subi.b  #62,15(a5)                        ;subtract 62 to datachx val1
  bra.b   noeff2                            ;goto noeff2
pbnd:
  move.b  #1,15(a5)                         ;datachx val1 = 1 (pitchbend)
noeff2:
  move.b  3(a0),13(a5)                      ;command val2 in datachx
  cmpi.b  #12,15(a5)                        ;compare datachx val1 to 12 (note wander)
  beq.b   nwando                            ;if == goto nwando
  move.b  2(a0),11(a5)                      ;command val1 in datachx pitchbend note
  cmpi.b  #1,15(a5)                         ;compare datachx val1 to 1
  bne.b   vanafhierzelfde                   ;if != goto vanafhierzelfde
  lea     frequencies+14(pc),a2
  moveq   #0,d0
  moveq   #0,d1
  move.b  11(a5),d1
  move.w  8(a5),d0
  ext.w   d0
  add.w   d0,d1
  move.w  18(a5),d0
  asl.w   #7,d0
  adda.w  d0,a2
  add.w   d1,d1
  move.w  (a2,d1.l),42(a5)
  bra.b   vanafhierzelfde
nwando:
  move.b  (a0),11(a5)
  lea     frequencies+14(pc),a2
  moveq   #0,d0
  moveq   #0,d1
  move.b  11(a5),d1
  move.w  8(a5),d0
  ext.w   d0
  add.w   d0,d1
  move.w  18(a5),d0
  asl.w   #7,d0
  adda.w  d0,a2
  add.w   d1,d1
  move.w  (a2,d1.l),42(a5)
vanafhierzelfde:
  move.l  instdata(pc),a4
  move.w  4(a5),d0
  asl.w   #4,d0
  adda.w  d0,a4
  move.b  8(a4),19(a5)
  cmpi.b  #11,15(a5)
  bne.b   noarpchng
  move.b  13(a5),4(a4)
  andi.b  #7,4(a4)
noarpchng:
  moveq   #0,d1
  move.l  wavedata(pc),a3
  move.b  (a4),d1
  cmpi.b  #12,15(a5)
  beq.w   sampletrug
  cmpi.b  #32,d1
  bhs.w   sampletjen
  asl.w   #7,d1
  adda.w  d1,a3
  move.l  a3,(a6)
  moveq   #0,d1
  move.b  1(a4),d1
  move.w  d1,4(a6)
  ;cmpi.b  #12,15(a5)
  ;beq.b   oioe
  cmpi.b  #10,15(a5)
  beq.b   oioe
  move.w  10(a1),$dff096
oioe:
  tst.w   channel7flg
  bne.w   sampletrug
  tst.b   11(a4)
  beq.w   sampletrug
  cmpi.b  #2,15(a5)
  beq.w   sampletrug
  cmpi.b  #4,15(a5)
  beq.w   sampletrug
  ;cmpi.b  #12,15(a5)
  ;beq.w   sampletrug
  moveq   #0,d0
  move.b  12(a4),d0
  asl.w   #7,d0
  move.l  wavedata(pc),a3
  adda.w  d0,a3
  moveq   #0,d0
  move.b  (a4),d0
  asl.w   #7,d0
  move.l  wavedata(pc),a2
  adda.w  d0,a2
  clr.b   6(a4)
  moveq   #31,d7
initz:
  move.l  (a3)+,(a2)+
  dbra    d7,initz
  move.b  14(a4),41(a5)
sampletrug:
  cmpi.b  #3,15(a5)
  beq.b   novioli
  cmpi.b  #4,15(a5)
  beq.b   novioli
  cmpi.b  #12,15(a5)
  beq.b   novioli
  move.w  #1,24(a5)
  clr.w   22(a5)
novioli:
  clr.w   44(a5)
  move.b  7(a4),29(a5)
  clr.w   30(a5)
  clr.w   26(a5)
insthandle:
  cmpi.b  #5,15(a5)
  beq.w   nplen
  cmpi.b  #6,15(a5)
  beq.w   nsspd
  cmpi.b  #7,15(a5)
  beq.b   laan
  cmpi.b  #8,15(a5)
  beq.b   luit
  cmpi.b  #13,15(a5)
  beq.w   nshuf
  rts

laan:
  bclr  #1,$bfe001
  rts
luit:
  bset  #1,$bfe001
  rts
nplen:
  moveq   #0,d0
  move.b  13(a5),d0
  tst.w   d0
  beq.w   ruts
  cmpi.w  #64,d0
  bhi.w   ruts
  move.w  d0,18(a1)
  rts
nsspd:
  moveq   #0,d0
  move.b  13(a5),d0
  andi.w  #15,d0
  move.b  d0,d1
  asl.b   #4,d0
  or.b    d1,d0
  tst.b   d1
  beq.w   ruts
  cmpi.b  #15,d1
  bhi.w   ruts
  move.w  d0,14(a1)
  rts
nshuf:
  clr.b   15(a5)
  moveq   #0,d0
  move.b  13(a5),d0
  move.b  d0,d1
  andi.b  #15,d1
  tst.b   d1
  beq.w   ruts
  move.b  d0,d1
  andi.b  #240,d1
  tst.b   d1
  beq.w   ruts
  move.w  d0,14(a1)
  rts

checkpnt: dc.l 0
chtab:    ds.l 2

playit2:
  cmpi.b  #9,15(a5)
  bne.b   nrl
  bchg    #1,$bfe001
nrl:
  moveq   #0,d0
  move.l  instdata(pc),a4
  move.w  4(a5),d0
  asl.w   #4,d0
  adda.w  d0,a4
  tst.w   channel7flg
  bne.w   nowavefect
  movem.l d0-d7/a0-a6,-(sp)
  tst.b   11(a4)
  beq.b   hiha
  cmpi.b  #32,(a4)
  bhs.b   hiha
  move.l  checkpnt(pc),a2
  lea     chtab(pc),a3
  moveq   #0,d0
  move.b  5(a5),d0
  addq.w  #1,d0
  cmp.b   (a3)+,d0
  beq.b   hiha
  cmp.b   (a3)+,d0
  beq.b   hiha
  cmp.b   (a3)+,d0
  beq.b   hiha
  cmp.b   (a3)+,d0
  beq.b   hiha
  move.b  d0,(a2)+
  add.l   #1,checkpnt
  tst.b   41(a5)
  bne.b   jammel
  move.b  14(a4),41(a5)
  lea     effjmptab(pc),a2
  moveq   #0,d0
  move.b  11(a4),d0
  asl.w   #2,d0
  move.l  (a2,d0.l),a2
  move.l  wavedata(pc),a3
  moveq   #0,d3
  move.b  (a4),d3
  asl.w   #7,d3
  adda.w  d3,a3
  jsr     (a2)
  bra.b   hiha
jammel:
  subq.b  #1,41(a5)
hiha:
  movem.l (sp)+,d0-d7/a0-a6
nowavefect:
  tst.w   24(a5)
  beq.b   geenvolmeer
  subq.w  #1,24(a5)
  tst.w   24(a5)
  bne.b   geenvolmeer
  move.b  3(a4),25(a5)
  addq.w  #1,22(a5)
  andi.w  #127,22(a5)
  tst.w   22(a5)
  bne.b   okgagang
  btst    #1,15(a4)
  bne.b   okgagang
  clr.w   24(a5)
  bra.b   geenvolmeer
okgagang:
  move.w  22(a5),d0
  moveq   #0,d1
  move.l  wavedata(pc),a3
  move.b  2(a4),d1
  asl.w   #7,d1
  add.w   d0,d1
  adda.w  d1,a3
  moveq   #0,d1
  move.b  (a3),d1
  addi.b  #129,d1
  neg.b   d1
  asr.w   #2,d1
  move.w  d1,8(a6)
  move.w  d1,36(a5)
geenvolmeer:
  lea     frequencies+14(pc),a2
  moveq   #0,d0
  moveq   #0,d1
  move.w  6(a5),d1
  tst.b   4(a4)
  beq.b   noarp
  move.l  arpdata(pc),a3
  move.b  4(a4),d0
  asl.w   #5,d0
  adda.w  d0,a3
  move.w  26(a5),d0
  add.b   (a3,d0.l),d1
  addq.w  #1,26(a5)
  andi.w  #31,26(a5)
noarp:
  move.w  8(a5),d0
  ext.w   d0
  add.w   d0,d1
  move.w  18(a5),d0
  asl.w   #7,d0
  adda.w  d0,a2
  add.w   d1,d1
  move.w  (a2,d1.l),16(a5)
  move.w  16(a5),d3
  cmpi.b  #12,15(a5)
  beq.b   nwandvruut
  cmpi.b  #1,15(a5)
  bne.b   nognietd
nwandvruut:
  move.w  12(a5),d0
  ext.w   d0
  neg.w   d0
  add.w   d0,44(a5)
  move.w  16(a5),d1
  add.w   44(a5),d1
  move.w  d1,16(a5)
  tst.w   12(a5)
  beq.b   nognietd
  btst    #15,d0
  beq.b   pdwn
  cmp.w   42(a5),d1
  bhi.b   nognietd
  move.w  42(a5),d1
  sub.w   d3,d1
  move.w  d1,44(a5)
  clr.w   12(a5)
  bra.b   nognietd
pdwn:
  cmp.w   42(a5),d1
  blo.b   nognietd
  move.w  42(a5),d1
  sub.w   d3,d1
  move.w  d1,44(a5)
  clr.w   12(a5)
nognietd:
  tst.b   5(a4)
  beq.b   nopitch
  tst.b   29(a5)
  beq.b   okpitzen
  subq.b  #1,29(a5)
  bra.b   nopitch
okpitzen:
  move.l  wavedata(pc),a3
  moveq   #0,d1
  move.b  5(a4),d1
  asl.w   #7,d1
  adda.w  d1,a3
  move.w  30(a5),d1
  addq.w  #1,30(a5)
  andi.w  #127,30(a5)
  tst.w   30(a5)
  bne.b   opplopz
  move.b  9(a4),31(a5)
opplopz:
  move.b  (a3,d1.l),d1
  ext.w   d1
  neg.w   d1
  add.w   d1,16(a5)
nopitch:
  move.w  16(a5),6(a6)
ruts:
  rts

effjmptab:
  dc.l ruts
  dc.l pfilter
  dc.l pmix
  dc.l pscrl
  dc.l pscrr
  dc.l pupsmple
  dc.l pdwnsmple
  dc.l pnega
  dc.l pmadmix
  dc.l padda
  dc.l pfilt2
  dc.l pmorph
  dc.l pmorphf
  dc.l pfilt3
  dc.l pnega2
  dc.l pcnega
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts
  dc.l ruts

pmorph:
  moveq   #0,d3                             ;clear d3
  move.l  wavedata(pc),a0                   ;wavedata in a0
  move.b  12(a4),d3                         ;sample source1 in d3
  asl.w   #7,d3                             ;multiply by 128
  adda.w  d3,a0                             ;waveform offset
  moveq   #0,d3                             ;clear d3
  move.l  wavedata(pc),a2                   ;wavedata in a2
  move.b  13(a4),d3                         ;sample source2 in d3
  asl.w   #7,d3                             ;multiply by 128
  adda.w  d3,a2                             ;waveform offset
  addq.b  #1,6(a4)                          ;increment sample effect step
  andi.b  #127,6(a4)                        ;effect step mask
  moveq   #0,d0                             ;clear d0
  move.b  6(a4),d0                          ;sample effect step in d0
  cmpi.b  #64,d0                            ;compare effect step to 64
  bhs.b   morphl                            ;if > goto morphl
  move.l  d0,d3                             ;else copy effect step in d3
  eori.b  #255,d3                           ;effect step xor 255
  andi.w  #63,d3                            ;effect step mask
  moveq   #0,d7                             ;clear d7
  move.b  1(a4),d7                          ;sample wave length in d7
  add.b   d7,d7                             ;multiply by 2 (length in bytes)
  subq.w  #1,d7                             ;loop counter
zrala:
  move.b  (a0)+,d1                          ;source1 sample in d1 and increment
  move.b  (a2)+,d2                          ;source2 sample in d2 and increment
  ext.w   d1                                ;extend to word
  ext.w   d2                                ;extend to word
  mulu.w  d0,d1                             ;multiply step1 * sample1
  mulu.w  d3,d2                             ;multiply step2 * sample2
  add.w   d1,d2                             ;add result1 to result2
  asr.w   #6,d2                             ;divide by 64
  move.b  d2,(a3)+                          ;result in sample wave and increment
  dbra    d7,zrala                          ;loop
  rts                                       ;return
morphl:
  moveq   #0,d7                             ;clear d7
  move.b  1(a4),d7                          ;sample wave length in d7
  add.b   d7,d7                             ;multiply by 2 (length in bytes)
  subq.w  #1,d7                             ;loop counter
  moveq   #127,d3                           ;127 in d3
  sub.l   d0,d3                             ;subtract effect step
  move.l  d3,d0                             ;copy result in d0
  eori.b  #255,d3                           ;effect step xor 255
  andi.w  #63,d3                            ;effect step mask
zralal:
  move.b  (a0)+,d1                          ;source1 sample in d1 and increment
  move.b  (a2)+,d2                          ;source2 sample in d2 and increment
  ext.w   d1                                ;extend to word
  ext.w   d2                                ;extend to word
  mulu.w  d0,d1                             ;multiply step1 * sample1
  mulu.w  d3,d2                             ;multiply step2 * sample2
  add.w   d1,d2                             ;add result1 to result2
  asr.w   #6,d2                             ;divide by 64
  move.b  d2,(a3)+                          ;result in sample wave and increment
  dbra    d7,zralal                         ;loop
  rts                                       ;return

pmorphf:
  moveq   #0,d3                             ;clear d3
  move.l  wavedata(pc),a0                   ;wavedata in a0
  move.b  12(a4),d3                         ;sample source1 in d3
  asl.w   #7,d3                             ;multiply by 128
  adda.w  d3,a0                             ;waveform offset
  moveq   #0,d3                             ;clear d3
  move.l  wavedata(pc),a2                   ;wavedata in a2
  move.b  13(a4),d3                         ;sample source2 in d3
  asl.w   #7,d3                             ;multiply by 128
  adda.w  d3,a2                             ;waveform offset
  addq.b  #1,6(a4)                          ;increment sample effect step
  andi.b  #31,6(a4)                         ;effect step mask
  moveq   #0,d0                             ;clear d0
  move.b  6(a4),d0                          ;sample effect step in d0
  cmpi.b  #16,d0                            ;compare effect step to 16
  bhs.b   morphl2                           ;if >= goto morphl2
  move.l  d0,d3                             ;else copy effect step in d3
  eori.b  #255,d3                           ;effect step xor 255
  andi.w  #15,d3                            ;effect step mask
  moveq   #0,d7                             ;clear d7
  move.b  1(a4),d7                          ;sample wave length in d7
  add.b   d7,d7                             ;multiply by 2 (length in bytes)
  subq.w  #1,d7                             ;loop counter
zralaf:
  move.b  (a0)+,d1
  move.b  (a2)+,d2
  ext.w   d1
  ext.w   d2
  mulu.w  d0,d1
  mulu.w  d3,d2
  add.w   d1,d2
  asr.w   #4,d2
  move.b  d2,(a3)+
  dbra    d7,zralaf
  rts
morphl2:
  moveq   #0,d7                             ;clear d7
  move.b  1(a4),d7                          ;sample wave length in d7
  add.b   d7,d7                             ;multiply by 2
  subq.w  #1,d7                             ;loop counter
  moveq   #31,d3                            ;31 in d3
  sub.l   d0,d3                             ;subtract effect step
  move.l  d3,d0                             ;copy result in d0
  eori.b  #255,d3                           ;effect step xor 255
  andi.w  #15,d3                            ;effect step mask
zralalf:
  move.b  (a0)+,d1
  move.b  (a2)+,d2
  ext.w   d1
  ext.w   d2
  mulu.w  d0,d1
  mulu.w  d3,d2
  add.w   d1,d2
  asr.w   #4,d2
  move.b  d2,(a3)+
  dbra    d7,zralalf
  rts

pdwnsmple:
  lea     (a3),a2
  lea     128(a3),a3
  lea     64(a2),a2
  moveq   #63,d7
eff5l:
  move.b  -(a2),-(a3)
  move.b  (a2),-(a3)
  dbra    d7,eff5l
  rts

pupsmple:
  lea     (a3),a2
  lea     (a2),a0
  moveq   #63,d7
puplop:
  move.b  (a2)+,(a3)+
  addq.w  #1,a2
  dbra    d7,puplop
  lea     (a0),a2
  moveq   #63,d7
puplop2:
  move.b  (a2)+,(a3)+
  dbra    d7,puplop2
  rts

pmadmix:
  addq.b  #1,6(a4)
  andi.b  #127,6(a4)
  moveq   #0,d1
  move.b  6(a4),d1
  moveq   #0,d3
  move.l  wavedata(pc),a0
  move.b  13(a4),d3
  asl.w   #7,d3
  adda.w  d3,a0
  moveq   #0,d0
  move.b  1(a4),d0
  add.b   d0,d0
  subq.w  #1,d0
  move.b  (a0,d1.l),d2
  move.b  #3,d1
ieff8:
  add.b   d1,(a3)+
  add.b   d2,d1
  dbra    d0,ieff8
  rts

pmix:
  moveq   #0,d3
  move.l  wavedata(pc),a0
  move.b  12(a4),d3
  asl.w   #7,d3
  adda.w  d3,a0
  moveq   #0,d3
  move.l  wavedata(pc),a2
  move.b  13(a4),d3
  asl.w   #7,d3
  adda.w  d3,a2
  moveq   #0,d2
  move.b  6(a4),d2
  addq.b  #1,6(a4)
  andi.b  #127,6(a4)
  moveq   #0,d7
  move.b  1(a4),d7
  add.b   d7,d7
  subq.w  #1,d7
eff3l:
  move.b  (a0)+,d0
  move.b  (a2,d2.l),d1
  ext.w   d0
  ext.w   d1
  add.w   d0,d1
  asr.w   #1,d1
  move.b  d1,(a3)+
  addq.b  #1,d2
  andi.b  #127,d2
  dbra    d7,eff3l
  rts

padda:
  moveq   #0,d3
  move.l  wavedata(pc),a0
  move.b  13(a4),d3
  asl.w   #7,d3
  adda.w  d3,a0
  moveq   #0,d7
  move.b  1(a4),d7
  add.b   d7,d7
  subq.w  #1,d7
effal:
  move.b  (a0)+,d0
  move.b  (a3),d1
  ext.w   d0
  ext.w   d1
  add.w   d0,d1
  move.b  d1,(a3)+
  dbra    d7,effal
  rts

pnega:
  moveq   #0,d0
  move.b  6(a4),d0
  neg.b   (a3,d0.l)
  addq.b  #1,6(a4)
  move.b  1(a4),d0
  add.b   d0,d0
  cmp.b   6(a4),d0
  bhi.w   ruts
  clr.b   6(a4)
  rts

pnega2:
  moveq   #0,d0
  move.b  6(a4),d0
  neg.b   (a3,d0.l)
  move.b  1(a4),d1
  add.b   13(a4),d0
  add.b   d1,d1
  subq.w  #1,d1
  and.b   d1,d0
  neg.b   (a3,d0.l)
  addq.b  #1,6(a4)
  move.b  1(a4),d0
  add.b   d0,d0
  cmp.b   6(a4),d0
  bhi.w   ruts
  clr.b   6(a4)
  rts

pscrl:
  moveq   #126,d7
  move.b  (a3),d0
eff2l:
  move.b  1(a3),(a3)+
  dbra    d7,eff2l
  move.b  d0,(a3)+
  rts

pscrr:
  moveq   #126,d7
  lea     128(a3),a3
  move.b  -(a3),d0
eff4l:
  move.b  -(a3),1(a3)
  dbra    d7,eff4l
  move.b  d0,(a3)
  rts

pcnega:
  lea     (a3),a2
  bsr.b   pfilter
  lea     (a2),a3
  addq.b  #1,6(a4)
  move.b  6(a4),d0
  cmp.b   13(a4),d0
  bne.w   ruts
  clr.b   6(a4)
  bra.w   pupsmple

pfilter:
  moveq   #126,d7
eff1l:
  move.b  (a3),d0
  ext.w   d0
  move.b  1(a3),d1
  ext.w   d1
  add.w   d0,d1
  asr.w   #1,d1
  move.b  d1,(a3)+
  dbra    d7,eff1l
  rts

pfilt2:
  ;lea     126(a3),a2
  moveq   #125,d7
  ;clr.w   d2
efffl:
  move.b  (a3)+,d0
  ext.w   d0
  move.w  d0,d1
  add.w   d0,d0
  add.w   d1,d0
  move.b  1(a3),d1
  ext.w   d1
  add.w   d0,d1
  asr.w   #2,d1
  move.b  d1,(a3)
  ;addq.w  #1,d2
  dbra    d7,efffl
  rts

pfilt3:
  ;lea     126(a3),a2
  moveq   #125,d7
  ;clr.w   d2
efffl3:
  move.b  (a3)+,d0
  ext.w   d0
  move.b  1(a3),d1
  ext.w   d1
  add.w   d0,d1
  asr.w   #1,d1
  move.b  d1,(a3)
  ;addq.w  #1,d2
  dbra    d7,efffl3
  rts

sampletjen:
  subi.w  #32,d1                            ;subtract 32 to sample wave #
  asl.w   #5,d1                             ;multiply by 32 (sample header = 32 bytes)
  move.l  samplestruct(pc),a3               ;samplestruct in a3
  adda.w  d1,a3                             ;add header offset
  move.l  a3,32(a5)                         ;sample header address in datachx
  move.w  #1,20(a5)                         ;set sample/synth flag in datachx
  move.l  sampledata(pc),a2                 ;sampledata in a2
  lea     (a2),a0                           ;sampledata in a0
  add.l   (a3),a0                           ;add sample start offset
  move.l  a0,relaybuf                       ;sample start in relaybuf
  move.l  a0,(a6)                           ;set channel pointer = sample start
  move.l  4(a3),d1                          ;sample end in d1
  add.l   a2,d1                             ;add sampledata base address
  move.l  d1,relaybuf+4                     ;sample end in relaybuf
  clr.l   relaybuf+8                        ;reset relaybuf loop length
  move.l  4(a3),d1                          ;sample end in d1
  tst.l   8(a3)                             ;test sample loop pointer
  beq.b   novulrel                          ;if 0 goto novulrel
  sub.l   8(a3),d1                          ;subtract loop pointer from end pointer
  move.l  d1,relaybuf+8                     ;sample loop length in relaybuf
novulrel:
  move.l  4(a3),d1                          ;sample end in d1
  sub.l   (a3),d1                           ;subtract sample start
  asr.l   #1,d1                             ;divide by 2 (length in words)
  move.w  d1,4(a6)                          ;set channel length = (end pointer - start pointer)
  move.w  10(a1),$dff096                    ;set dmacon (disable)
  bra.w   sampletrug                        ;goto sampletrug

samplereinit:
  move.l  sampledata(pc),a2                 ;sampledata in a2
  lea     empty(pc),a4                      ;empty sample in a4
  lea     datach1(pc),a5                    ;datach1 in a5
  lea     $dff0a0,a6                        ;amiga channel 1 address in a6
  moveq   #3,d5                             ;loop counter = 4 channels
  tst.w   channel7flg                       ;test channel7flg
  beq.b   slop                              ;if 0 (4 channels) goto slop
  moveq   #2,d5                             ;loop counter = 3 channels
slop:
  tst.w   20(a5)                            ;test datachx sample/synth flag
  beq.b   next                              ;if 0 (synth) goto next
  clr.w   20(a5)                            ;reset datachx sample/synth flag
  move.l  32(a5),a3                         ;sample header in a3
  tst.l   8(a3)                             ;test sample loop pointer
  beq.b   noloop                            ;if 0 goto noloop
  lea     (a2),a1                           ;sampledata in a1
  add.l   8(a3),a1                          ;add sample loop offset
  move.l  a1,(a6)                           ;set channel pointer = sample loop
  move.l  4(a3),d1                          ;sample end pointer
  sub.l   8(a3),d1                          ;subtract loop pointer from end pointer
  asr.l   #1,d1                             ;divide by 2 (length in words)
  move.w  d1,4(a6)                          ;set channel length = (end pointer - loop pointer)
next:
  lea     48(a5),a5                         ;offset to next datachx
  lea     16(a6),a6                         ;offset to next amiga channel
  dbra    d5,slop                           ;loop
  rts                                       ;return
noloop:
  move.l  a4,(a6)                           ;set channel pointer = sample start
  move.w  #4,4(a6)                          ;set channel length  = 4 (8 bytes)
  lea     48(a5),a5                         ;offset to next datachx
  lea     16(a6),a6                         ;offset to next amiga channel
  dbra    d5,slop                           ;loop
  rts                                       ;return

pieldest1: dc.l pielbuf1
pieldest2: dc.l pielbuf2

channel4mixer:
  move.l  mix1src,a0                        ;mix1src in a0
  move.l  mix2src,a1                        ;mix2src in a1
  move.l  mix3src,a2                        ;mix3src in a2
  move.l  mix4src,a3                        ;mix4src in a3
  move.l  pieldest1(pc),d0                  ;pieldest1 in d0
  move.l  pieldest2(pc),pieldest1           ;pieldest2 in pieldest1
  move.l  d0,pieldest2                      ;pieldest1 in pieldest2 (buffer swap)
  move.l  pieldest1(pc),a4                  ;pieldest1 in a4
  move.l  a4,$dff0d0                        ;amiga channel pointer = buffer1

  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  move.w  kwalcnt(pc),d0                    ;kwalcnt in d0
  move.w  datach4+16(pc),d1                 ;datach4 final period in d1
  cmpi.w  #124,d1                           ;compare period to 124
  bhi.b   vruut                             ;if > goto vruut
  move.w  #1,mix1mute                       ;else mix1mute = 1
  move.l  #0,src1spdcomma                   ;     src1spdcomma = 0
  bra.b   vruuts                            ;goto vruuts
vruut:
  bsr.w   calcfreq                          ;gosub calcfreq
  moveq   #0,d2                             ;clear d2
  move.w  uitk(pc),d2                       ;uitk in d2
  asl.l   #8,d2                             ;multiply by 256
  move.l  d2,src1spdcomma                   ;store result in src1spdcomma
vruuts:

  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  move.w  kwalcnt(pc),d0                    ;kwalcnt in d0
  move.w  datach5+16(pc),d1                 ;datach5 final period in d1
  cmpi.w  #124,d1                           ;compare period to 124
  bhi.b   vruut2                            ;if > goto vruut2
  move.w  #1,mix2mute                       ;else mix2mute = 1
  move.l  #0,src2spdcomma                   ;     src2spdcomma = 0
  bra.b   vruut2s                           ;goto vruut2s
vruut2:
  bsr.w   calcfreq                          ;gosub calcfreq
  moveq   #0,d2                             ;clear d2
  move.w  uitk(pc),d2                       ;uitk in d2
  asl.l   #8,d2                             ;multiply by 256
  move.l  d2,src2spdcomma                   ;store result in src2spdcomma
vruut2s:

  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  move.w  kwalcnt(pc),d0                    ;kwalcnt in d0
  move.w  datach6+16(pc),d1                 ;datach6 final period in d1
  cmpi.w  #124,d1                           ;compare period to 124
  bhi.b   vruut3                            ;if > goto vruut3
  move.w  #1,mix3mute                       ;else mix3mute = 1
  move.l  #0,src3spdcomma                   ;     src3spdcomma = 0
  bra.b   vruut3s                           ;goto vruut3s
vruut3:
  bsr.w   calcfreq                          ;gosub calcfreq
  moveq   #0,d2                             ;clear d2
  move.w  uitk(pc),d2                       ;uitk in d2
  asl.l   #8,d2                             ;multiply by 256
  move.l  d2,src3spdcomma                   ;store result in src3spdcomma
vruut3s:

  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  move.w  kwalcnt(pc),d0                    ;kwalcnt in d0
  move.w  datach7+16(pc),d1                 ;datach7 final period in d1
  cmpi.w  #124,d1                           ;compare period to 124
  bhi.b   vruut4                            ;if > goto vruut4
  move.w  #1,mix4mute                       ;else mix4mute = 1
  move.l  #0,src4spdcomma                   ;     src4spdcomma = 0
  bra.b   vruut4s                           ;goto vruut4s
vruut4:
  bsr.w   calcfreq                          ;gosub calcfreq
  moveq   #0,d2                             ;clear d2
  move.w  uitk(pc),d2                       ;uitk in d2
  asl.l   #8,d2                             ;multiply by 256
  move.l  d2,src4spdcomma                   ;store result in src4spdcomma
vruut4s:
  bra.w   tugsby                            ;goto tugsby

mix1mute: dc.w 1
mix2mute: dc.w 1
mix3mute: dc.w 1
mix4mute: dc.w 1
mix1src:  dc.l 0
mix2src:  dc.l 0
mix3src:  dc.l 0
mix4src:  dc.l 0
mix1end:  dc.l 0
mix2end:  dc.l 0
mix3end:  dc.l 0
mix4end:  dc.l 0
mix1loop: dc.l 0
mix2loop: dc.l 0
mix3loop: dc.l 0
mix4loop: dc.l 0

calcfreq:
  tst.w   d0                                ;test kwalcnt
  beq.w   ruts                              ;if 0 goto ruts
  tst.w   d1                                ;test period
  beq.w   ruts                              ;if 0 goto ruts
  asl.l   #8,d1                             ;period * 256
  divu.w  d0,d1                             ;result1 / kwalcnt
  move.l  #256,d0                           ;256 in d0
  divu.w  d1,d0                             ;256 / result1
  move.b  d0,uitk                           ;result2 in uitk[0]
  swap    d0                                ;256 mod result1 in d0
  asl.l   #8,d0                             ;multiply by 256
  andi.l  #$ffffff,d0                       ;& result3
  divu.w  d1,d0                             ;result3 / result1
  move.b  d0,uitk+1                         ;result4 in uitk[1]
  rts                                       ;return

preptabs:
  lea     averagetab(pc),a0
  move.w  #$80,d0
  move.w  #383,d7
vul80:
  move.b  d0,(a0)+
  dbra    d7,vul80
  move.w  #255,d7
vul81:
  move.b  d0,(a0)+
  addq.b  #1,d0
  dbra    d7,vul81
  subq.b  #1,d0
  move.w  #383,d7
vul7f:
  move.b  d0,(a0)+
  dbra    d7,vul7f

  lea     volumetab(pc),a0
  moveq   #0,d0
  moveq   #63,d7
makevol1:
  move.w  #255,d6
  move.w  #-128,d5
  move.w  #128,d3
makevol2:
  move.l  d5,d4
  muls.w  d0,d4
  divs.w  #63,d4
  addi.b  #$80,d4
  move.b  d4,(a0,d3.w)
  cmpi.w  #63,d7
  beq.b   flufk
  tst.w   d7
  beq.b   flufk
  cmpi.w  #128,d3
  blo.b   flufk
  subq.b  #1,(a0,d3.w)
flufk:
  addq.w  #1,d3
  andi.w  #255,d3
  addq.w  #1,d5
  dbra    d6,makevol2
  adda.w  #256,a0
  ;lea     256(a0),a0
  addq.w  #1,d0
  dbra    d7,makevol1
  rts

store:        dc.l 0
uitk:         dc.w 0
src1spdcomma: dc.l 0
src2spdcomma: dc.l 0
src3spdcomma: dc.l 0
src4spdcomma: dc.l 0
kwalcnt:      dc.w 203 ;was 128

tugsby:
  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  moveq   #0,d2                             ;clear d2
  moveq   #0,d3                             ;clear d3
  moveq   #0,d4                             ;clear d4
  moveq   #0,d5                             ;clear d5
  move.l  src2spdcomma(pc),vul2+2           ;write src2spdcomma in vul2+2 (self modifying code)
  move.l  src3spdcomma(pc),vul3+2           ;write src3spdcomma in vul3+2 (self modifying code)
  move.l  src4spdcomma(pc),vul4+2           ;write src4spdcomma in vul4+2 (self modifying code)

  move.w  datach4+36(pc),d0                 ;datach4 volume in d0
  tst.w   mix1mute                          ;test mix1mute
  beq.b   joeh1                             ;if 0 goto joeh1
  moveq   #0,d0                             ;else reset volume
joeh1:
  asl.w   #8,d0                             ;volume * 256
  lea     volumetab(pc),a5                  ;volumetab in a5
  adda.w  d0,a5                             ;add offset
  suba.l  #volp1+2,a5                       ;subtract volp1 function address + 2
  move.w  a5,volp1+2                        ;write volumetab pointer in volp1+2 (self modifying code)

  move.w  datach5+36(pc),d0                 ;datach5 volume in d0
  tst.w   mix2mute                          ;test mix2mute
  beq.b   joeh2                             ;if 0 goto joeh2
  moveq   #0,d0                             ;else reset volume
joeh2:
  asl.w   #8,d0                             ;volume * 256
  lea     volumetab(pc),a5                  ;volumetab in a5
  adda.w  d0,a5                             ;add offset
  suba.l  #volp2+2,a5                       ;subtract volp2 function address + 2
  move.w  a5,volp2+2                        ;write volumetab pointer in volp2+2 (self modifying code)

  move.w  datach6+36(pc),d0                 ;datach6 volume in d0
  tst.w   mix3mute                          ;test mix3mute
  beq.b   joeh3                             ;if 0 goto joeh3
  moveq   #0,d0                             ;else reset volume
joeh3:
  asl.w   #8,d0                             ;volume * 256
  lea     volumetab(pc),a5                  ;volumetab in a5
  adda.w  d0,a5                             ;add offset
  suba.l  #volp3+2,a5                       ;subtract volp3 function address + 2
  move.w  a5,volp3+2                        ;write volumetab pointer in volp3+2 (self modifying code)

  move.w  datach7+36(pc),d0                 ;datach7 volume in d0
  tst.w   mix4mute                          ;test mix4mute
  beq.b   joeh4                             ;if 0 goto joeh4
  moveq   #0,d0                             ;else reset volume
joeh4:
  asl.w   #8,d0                             ;volume * 256
  lea     volumetab(pc),a5                  ;volumetab in a5
  adda.w  d0,a5                             ;add offset
  suba.l  #volp4+2,a5                       ;subtract volp4 function address + 2
  move.w  a5,volp4+2                        ;write volumetab pointer in volp4+2 (self modifying code)

  move.l  a7,store                          ;store a7
  move.l  src1spdcomma(pc),a7               ;voice 4 speed in a7
  lea     averagetab(pc),a5                 ;averagetab in a5
  move.w  #349,d7                           ;loop counter
  moveq   #0,d6                             ;clear d6
mixen2:
  move.b  (a0,d2.w),d6                      ;voice 4 sampledata[counter] in d6
volp1:
  lea     volumetab+16128(pc),a6            ;volumetab in a6 (already offsetted)
  moveq   #0,d0                             ;clear d0
  move.b  (a6,d6.w),d0                      ;volumetab[sample value] in d0

  move.b  (a1,d3.w),d6                      ;voice 5 sampledata[counter] in d6
volp2:
  lea     volumetab+16128(pc),a6            ;volumetab in a6 (already offsetted)
  moveq   #0,d1                             ;clear d1
  move.b  (a6,d6.w),d1                      ;volumetab[sample value] in d1
  add.w   d0,d1                             ;add to previous value

  move.b  (a2,d4.w),d6                      ;voice 6 sampledata[counter] in d6
volp3:
  lea     volumetab+16128(pc),a6            ;volumetab in a6 (already offsetted)
  move.b  (a6,d6.w),d0                      ;volumetab[sample value] in d0
  add.w   d0,d1                             ;add to previous value

  move.b  (a3,d5.w),d6                      ;voice 7 sampledata[counter] in d6
volp4:
  lea     volumetab+16128(pc),a6            ;volumetab in a6 (already offsetted)
  move.b  (a6,d6.w),d0                      ;volumetab[sample value] in d0
  add.w   d0,d1                             ;add to previous value (result)

  move.b  (a5,d1.w),(a4)+                   ;store averagetab[result] in buffer and increment
  swap    d2                                ;swap voice 4 counter
vul1:
  add.l   a7,d2                             ;add src1spdcomma to counter
  swap    d2                                ;swap back
  swap    d3                                ;swap voice 5 counter
vul2:
  add.l   #0,d3                             ;add src2spdcomma to counter
  swap    d3                                ;swap back
  swap    d4                                ;swap voice 6 counter
vul3:
  add.l   #0,d4                             ;add src3spdcomma to counter
  swap    d4                                ;swap back
  swap    d5                                ;swap voice 7 counter
vul4:
  add.l   #0,d5                             ;add src4spdcomma to counter
  swap    d5                                ;swap back
  dbra    d7,mixen2                         ;loop

  move.l  store(pc),a7                      ;restore a7
  add.w   d2,a0                             ;add counter to pointer
  add.w   d3,a1                             ;add counter to pointer
  add.w   d4,a2                             ;add counter to pointer
  add.w   d5,a3                             ;add counter to pointer
  move.l  a0,mix1src                        ;store pointer in mix1src
  move.l  a1,mix2src                        ;store pointer in mix2src
  move.l  a2,mix3src                        ;store pointer in mix3src
  move.l  a3,mix4src                        ;store pointer in mix4src

  cmpa.l  mix1end(pc),a0                    ;compare mix1src to mix1end
  blo.b   nonokt1                           ;if < goto nonokt1
  tst.l   mix1loop                          ;test mix1loop
  beq.b   mutter                            ;if 0 goto mutter
  move.l  mix1loop(pc),d0                   ;else mix1loop in d0
  sub.l   d0,mix1src                        ;subtract mix1loop from mix1src
  bra.b   nonokt1                           ;goto nonokt1
mutter:
  move.w  #1,mix1mute                       ;mix1mute = 1
nonokt1:

  cmpa.l  mix2end(pc),a1                    ;compare mix2src to mix2end
  blo.b   nonokt2                           ;if < goto nonokt2
  tst.l   mix2loop                          ;test mix2loop
  beq.b   mutter2                           ;if 0 goto mutter2
  move.l  mix2loop(pc),d0                   ;else mix2loop in d0
  sub.l   d0,mix2src                        ;subtract mix2loop from mix2src
  bra.b   nonokt2                           ;goto nonokt2
mutter2:
  move.w  #1,mix2mute                       ;mix2mute = 1
nonokt2:

  cmpa.l  mix3end(pc),a2                    ;compare mix3src to mix3end
  blo.b   nonokt3                           ;if < goto nonokt3
  tst.l   mix3loop                          ;test mix3loop
  beq.b   mutter3                           ;if 0 goto mutter3
  move.l  mix3loop(pc),d0                   ;else mix3loop in d0
  sub.l   d0,mix3src                        ;subtract mix3loop from mix3src
  bra.b   nonokt3                           ;goto nonokt3
mutter3:
  move.w  #1,mix3mute                       ;mix3mute = 1
nonokt3:

  cmpa.l  mix4end(pc),a3                    ;compare mix4src to mix4end
  blo.b   nonokt4                           ;if < goto nonokt4
  tst.l   mix4loop                          ;test mix4loop
  beq.b   mutter4                           ;if 0 goto mutter4
  move.l  mix4loop(pc),d0                   ;else mix4loop in d0
  sub.l   d0,mix4src                        ;subtract mix4loop from mix4src
  bra.b   nonokt4                           ;goto nonokt4
mutter4:
  move.w  #1,mix4mute                       ;mix4mute = 1
nonokt4:

  lea     $dff000,a6                        ;amiga base address
  move.w  #175,$d4(a6)                      ;channel length = 175 (350 bytes)
  move.w  kwalcnt(pc),$d6(a6)               ;channel period = kwalcnt
  move.w  #64,$d8(a6)                       ;channel volume = 64
  ;move.w  #$8008,$96(a6)                   ;enable channels 1-2-3
  rts                                       ;return

playerdat:
songdelay:  dc.w 0
newpatflg:  dc.w 0
newnoteflg: dc.w 0
songcnt:    dc.w 0
patcnt:     dc.w 0
dma:        dc.w 0
songnr:     dc.w 0
songspd:    dc.w 5
songlength: dc.w 1
patlength:  dc.w 64

datach1: ds.b 48
datach2: ds.b 48
datach3: ds.b 48
datach4: ds.b 48
datach5: ds.b 48
datach6: ds.b 48
datach7: ds.b 48

songdata7:    dc.l 0
songdata2:    dc.l 0
songdata:     dc.l 0
instdata:     dc.l 0
arpdata:      dc.l 0
wavedata:     dc.l 0
patdata:      dc.l 0
samplestruct: dc.l 0
sampledata:   dc.l 0

pielbuf1:   ds.b 350    ;was 512
pielbuf2:   ds.b 350    ;was 512
averagetab: ds.b 1024   ;was 1026
volumetab:  ds.b 16384
empty:      ds.b 8

frequencies:
  dc.w 4825,4554,4299,4057,3830,3615,3412,3220,3040,2869,2708,2556,2412,2277
  dc.w 2149,2029,1915,1807,1706,1610,1520,1434,1354,1278,1206,1139,1075,1014
  dc.w 0957,0904,0853,0805,0760,0717,0677,0639,0603,0569,0537,0507,0479,0452
  dc.w 0426,0403,0380,0359,0338,0319,0302,0285,0269,0254,0239,0226,0213,0201
  dc.w 0190,0179,0169,0160,0151,0142,0134,0127
  dc.w 4842,4571,4314,4072,3843,3628,3424,3232,3051,2879,2718,2565,2421,2285
  dc.w 2157,2036,1922,1814,1712,1616,1525,1440,1359,1283,1211,1143,1079,1018
  dc.w 0961,0907,0856,0808,0763,0720,0679,0641,0605,0571,0539,0509,0480,0453
  dc.w 0428,0404,0381,0360,0340,0321,0303,0286,0270,0254,0240,0227,0214,0202
  dc.w 0191,0180,0170,0160,0151,0143,0135,0127
  dc.w 4860,4587,4330,4087,3857,3641,3437,3244,3062,2890,2728,2574,2430,2294
  dc.w 2165,2043,1929,1820,1718,1622,1531,1445,1364,1287,1215,1147,1082,1022
  dc.w 0964,0910,0859,0811,0765,0722,0682,0644,0607,0573,0541,0511,0482,0455
  dc.w 0430,0405,0383,0361,0341,0322,0304,0287,0271,0255,0241,0228,0215,0203
  dc.w 0191,0181,0170,0161,0152,0143,0135,0128
  dc.w 4878,4604,4345,4102,3871,3654,3449,3255,3073,2900,2737,2584,2439,2302
  dc.w 2173,2051,1936,1827,1724,1628,1536,1450,1369,1292,1219,1151,1086,1025
  dc.w 0968,0914,0862,0814,0768,0725,0684,0646,0610,0575,0543,0513,0484,0457
  dc.w 0431,0407,0384,0363,0342,0323,0305,0288,0272,0256,0242,0228,0216,0203
  dc.w 0192,0181,0171,0161,0152,0144,0136,0128
  dc.w 4895,4620,4361,4116,3885,3667,3461,3267,3084,2911,2747,2593,2448,2310
  dc.w 2181,2058,1943,1834,1731,1634,1542,1455,1374,1297,1224,1155,1090,1029
  dc.w 0971,0917,0865,0817,0771,0728,0687,0648,0612,0578,0545,0515,0486,0458
  dc.w 0433,0408,0385,0364,0343,0324,0306,0289,0273,0257,0243,0229,0216,0204
  dc.w 0193,0182,0172,0162,0153,0144,0136,0129
  dc.w 4913,4637,4377,4131,3899,3681,3474,3279,3095,2921,2757,2603,2456,2319
  dc.w 2188,2066,1950,1840,1737,1639,1547,1461,1379,1301,1228,1159,1094,1033
  dc.w 0975,0920,0868,0820,0774,0730,0689,0651,0614,0580,0547,0516,0487,0460
  dc.w 0434,0410,0387,0365,0345,0325,0307,0290,0274,0258,0244,0230,0217,0205
  dc.w 0193,0183,0172,0163,0154,0145,0137,0129
  dc.w 4931,4654,4393,4146,3913,3694,3486,3291,3106,2932,2767,2612,2465,2327
  dc.w 2196,2073,1957,1847,1743,1645,1553,1466,1384,1306,1233,1163,1098,1037
  dc.w 0978,0923,0872,0823,0777,0733,0692,0653,0616,0582,0549,0518,0489,0462
  dc.w 0436,0411,0388,0366,0346,0326,0308,0291,0275,0259,0245,0231,0218,0206
  dc.w 0194,0183,0173,0163,0154,0145,0137,0130
  dc.w 4948,4671,4409,4161,3928,3707,3499,3303,3117,2942,2777,2621,2474,2335
  dc.w 2204,2081,1964,1854,1750,1651,1559,1471,1389,1311,1237,1168,1102,1040
  dc.w 0982,0927,0875,0826,0779,0736,0694,0655,0619,0584,0551,0520,0491,0463
  dc.w 0437,0413,0390,0368,0347,0328,0309,0292,0276,0260,0245,0232,0219,0206
  dc.w 0195,0184,0174,0164,0155,0146,0138,0130
  dc.w 4966,4688,4425,4176,3942,3721,3512,3315,3129,2953,2787,2631,2483,2344
  dc.w 2212,2088,1971,1860,1756,1657,1564,1477,1394,1315,1242,1172,1106,1044
  dc.w 0985,0930,0878,0829,0782,0738,0697,0658,0621,0586,0553,0522,0493,0465
  dc.w 0439,0414,0391,0369,0348,0329,0310,0293,0277,0261,0246,0233,0219,0207
  dc.w 0196,0185,0174,0164,0155,0146,0138,0131
  dc.w 4984,4705,4441,4191,3956,3734,3524,3327,3140,2964,2797,2640,2492,2352
  dc.w 2220,2096,1978,1867,1762,1663,1570,1482,1399,1320,1246,1176,1110,1048
  dc.w 0989,0934,0881,0832,0785,0741,0699,0660,0623,0588,0555,0524,0495,0467
  dc.w 0441,0416,0392,0370,0350,0330,0312,0294,0278,0262,0247,0233,0220,0208
  dc.w 0196,0185,0175,0165,0156,0147,0139,0131
  dc.w 5002,4722,4457,4206,3970,3748,3537,3339,3151,2974,2807,2650,2501,2361
  dc.w 2228,2103,1985,1874,1769,1669,1576,1487,1404,1325,1251,1180,1114,1052
  dc.w 0993,0937,0884,0835,0788,0744,0702,0662,0625,0590,0557,0526,0496,0468
  dc.w 0442,0417,0394,0372,0351,0331,0313,0295,0279,0263,0248,0234,0221,0209
  dc.w 0197,0186,0175,0166,0156,0148,0139,0131
  dc.w 5020,4739,4473,4222,3985,3761,3550,3351,3163,2985,2818,2659,2510,2369
  dc.w 2236,2111,1992,1881,1775,1675,1581,1493,1409,1330,1255,1185,1118,1055
  dc.w 0996,0940,0887,0838,0791,0746,0704,0665,0628,0592,0559,0528,0498,0470
  dc.w 0444,0419,0395,0373,0352,0332,0314,0296,0280,0264,0249,0235,0222,0209
  dc.w 0198,0187,0176,0166,0157,0148,0140,0132
  dc.w 5039,4756,4489,4237,3999,3775,3563,3363,3174,2996,2828,2669,2519,2378
  dc.w 2244,2118,2000,1887,1781,1681,1587,1498,1414,1335,1260,1189,1122,1059
  dc.w 1000,0944,0891,0841,0794,0749,0707,0667,0630,0594,0561,0530,0500,0472
  dc.w 0445,0420,0397,0374,0353,0334,0315,0297,0281,0265,0250,0236,0223,0210
  dc.w 0198,0187,0177,0167,0157,0149,0140,0132
  dc.w 5057,4773,4505,4252,4014,3788,3576,3375,3186,3007,2838,2679,2528,2387
  dc.w 2253,2126,2007,1894,1788,1688,1593,1503,1419,1339,1264,1193,1126,1063
  dc.w 1003,0947,0894,0844,0796,0752,0710,0670,0632,0597,0563,0532,0502,0474
  dc.w 0447,0422,0398,0376,0355,0335,0316,0298,0282,0266,0251,0237,0223,0211
  dc.w 0199,0188,0177,0167,0158,0149,0141,0133
  dc.w 5075,4790,4521,4268,4028,3802,3589,3387,3197,3018,2848,2688,2538,2395
  dc.w 2261,2134,2014,1901,1794,1694,1599,1509,1424,1344,1269,1198,1130,1067
  dc.w 1007,0951,0897,0847,0799,0754,0712,0672,0634,0599,0565,0533,0504,0475
  dc.w 0449,0423,0400,0377,0356,0336,0317,0299,0283,0267,0252,0238,0224,0212
  dc.w 0200,0189,0178,0168,0159,0150,0141,0133
  dc.w 5093,4808,4538,4283,4043,3816,3602,3399,3209,3029,2859,2698,2547,2404
  dc.w 2269,2142,2021,1908,1801,1700,1604,1514,1429,1349,1273,1202,1134,1071
  dc.w 1011,0954,0900,0850,0802,0757,0715,0675,0637,0601,0567,0535,0505,0477
  dc.w 0450,0425,0401,0379,0357,0337,0318,0300,0284,0268,0253,0238,0225,0212
  dc.w 0201,0189,0179,0169,0159,0150,0142,0134

muzak: incbin "module.dmu"