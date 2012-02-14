  section player,data_c

main:
  move.l  4,a6
  jsr     -132(a6)
  moveq   #0,d0
  bsr     muzaxon
sync:
  cmp.b   #128,$dff006
  bne.s   sync
  bsr     player
  btst    #6,$bfe001
  bne.s   sync
  bsr     muzaxoff
  bclr    #1,$bfe001
  move.l  4,a6
  jmp     -138(a6)
  rts

;main:
;  movem.l d0-a6,-(sp)
;  moveq   #0,d0
;  bsr.w   muzaxon
;wait:
;  btst    #6,$bfe001
;  bne.w   wait
;  bsr.w   muzaxoff
;  movem.l (sp)+,d0-a6
;  rts

hendeljmptab:
  dc.l resetall-main
  dc.l returnsongnr-main
  dc.l status-main
  dc.l statusinstr-main
  dc.l currentfreqs-main
  dc.l currentvols-main
  dc.l false-main
  dc.l chngsongspd-main

hendelz:
  lea     main(pc),a0
  lea     hendeljmptab(pc),a1
  andi.l  #7,d0
  asl.w   #2,d0
  adda.l  (a1,d0.l),a0
  jsr     (a0)
  rts

resetall:
  lea     datach1(pc),a5
  clr.w   46(a5)
  clr.w   94(a5)
  clr.w   142(a5)
  clr.w   190(a5)
  lea     oldsongspd(pc),a0
  tst.w   2(a0)
  beq.w   druut
  move.w  (a0),d0
  lea     songspd(pc),a0
  move.w  d0,(a0)
  rts

returnsongnr:
  lea     songnr(pc),a0
  move.w  (a0),d0
  rts

status:
  lea     songcnt(pc),a0
  move.w  (a0),d1
  move.w  2(a0),d0
  lea     songspd(pc),a0
  move.w  (a0),d2
  rts

statusinstr:
  lea     datach1(pc),a5
  move.w  4(a5),d0
  move.w  52(a5),d1
  move.w  100(a5),d2
  move.w  148(a5),d3
  addq.w  #1,d0
  addq.w  #1,d1
  addq.w  #1,d2
  addq.w  #1,d3
  rts

currentfreqs:
  lea     datach1(pc),a5
  move.w  16(a5),d0
  move.w  64(a5),d1
  move.w  112(a5),d2
  move.w  160(a5),d3
  rts

currentvols:
  lea     datach1(pc),a5
  move.w  36(a5),d0
  move.w  84(a5),d1
  move.w  132(a5),d2
  move.w  180(a5),d3
  rts

false:
  subi.w  #1,d1
  andi.w  #3,d1
  lea     datach1(pc),a5
  mulu.w  #48,d1
  lea     (a5,d1.l),a5
  andi.w  #15,d2
  move.w  d2,46(a5)
  rts

chngsongspd:
  lea     songspd(pc),a0
  andi.w  #255,d2
  move.w  (a0),d0
  move.w  d2,(a0)
  lea     oldsongspd(pc),a0
  move.w  d0,(a0)
  move.w  #1,2(a0)
  rts

oldsongspd:     dc.w 0
songspdchngflg: dc.w 0

initializer:
  moveq   #0,d7
  lea     ssname(pc),a0
  lea     muzak(pc),a1
  moveq   #23,d6
compa:
  move.b  (a0)+,d2
  cmp.b   (a1)+,d2
  bne.w   error
  dbf     d6,compa
  moveq   #0,d4
  move.w  d0,d4
  move.w  d4,d6
  asl.w   #4,d6
  lea     muzak+76(pc),a4
  lea     muzak(pc),a5
  lea     songdata2(pc),a6
  move.l  a4,(a6)
  add.l   d6,(a6)
  lea     128(a4),a4
  lea     28(a5),a2
  moveq   #0,d2
  moveq   #7,d5
songslop:
  move.l  (a2)+,d3
  asl.l   #3,d3
  cmp.w   d2,d4
  bne.w   overt
  move.l  a4,4(a6)
overt:
  addq.w  #1,d2
  lea     (a4,d3.l),a4
  dbf     d5,songslop
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
  beq.w   nikko2
  move.l  a4,12(a6)
  rts
nikko2:
  move.l  a4,12(a6)
  move.w  #255,d7
leeg:
  clr.b   (a4)+
  dbf     d7,leeg
  rts
error:
  moveq   #-1,d7
  rts

ssname: dc.b ' MUGICIAN/SOFTEYES 1990 '

druut:
  rts

muzaxon:
  lea     songnr(pc),a0                     ;songnr in a0
  move.w  d0,(a0)                           ;store song # requested
  bsr.w   initializer                       ;gosub initializer
  cmpi.w  #-1,d7                            ;compare ??? to -1
  beq.w   druut                             ;if == goto druut
  lea     datach1(pc),a0                    ;datachx in a0
  moveq   #95,d7                            ;loop counter
frclr3:
  clr.w   (a0)+                             ;reset data structure
  dbf     d7,frclr3                         ;loop
  lea     playerdat(pc),a0                  ;playerdat in a0
  clr.l   (a0)+                             ;reset songdelay
  clr.w   (a0)+                             ;reset newpatflg
  addq.w  #2,a0                             ;data offset
  clr.l   (a0)+                             ;reset songcnt
  move.w  #124,$dff0a4                      ;set amiga channel 1 length
  move.w  #124,$dff0b4                      ;set amiga channel 2 length
  move.w  #124,$dff0c4                      ;set amiga channel 3 length
  move.w  #124,$dff0d4                      ;set amiga channel 4 length
  move.w  #0,$dff0a8                        ;set amiga channel 1 volume
  move.w  #0,$dff0b8                        ;set amiga channel 2 volume
  move.w  #0,$dff0c8                        ;set amiga channel 3 volume
  move.w  #0,$dff0d8                        ;set amiga channel 4 volume
  move.w  #$000f,$dff096                    ;disable channels
  lea     songnr(pc),a0                     ;songnr in a0
  move.w  (a0),d0                           ;
  moveq   #3,d7                             ;loop counter
  lea     datach1(pc),a0                    ;datach1 in a0
  lea     (a0),a1                           ;
initizer:
  move.w  d0,(a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  lea     48(a1),a1
  lea     (a1),a0
  dbf     d7,initizer
  moveq   #0,d0
  moveq   #0,d1
  movea.l songdata2(pc),a0
  move.b  3(a0),d1
  lea     songlength(pc),a2
  move.w  d1,(a2)
  lea     patlength(pc),a2
  move.w  #64,(a2)
  move.b  2(a0),d1
  lea     playerdat(pc),a2
  move.w  d1,(a2)
  move.b  d1,d0
  andi.b  #15,d0
  andi.b  #15,d1
  asl.b   #4,d0
  or.b    d0,d1
  lea     songspd(pc),a2
  move.w  d1,(a2)
  lea     songcnt(pc),a2
  clr.w   (a2)
  lea     newpatflg(pc),a2
  move.w  #1,(a2)
  lea     newnoteflg(pc),a2
  move.w  #1,(a2)
  ;lea     intflg(pc),a2
  ;tst.w   (a2)
  ;bne.w   notag
  ;lea     player(pc),a0
  ;lea     hasan(pc),a1
  ;move.l  $6c,2(a1)
  ;move.l  a0,$6c
  move.w  #$000f,$dff096
  ;move.w  #1,(a2)
notag:
  rts

;intflg:      dc.w 0
playpattflg: dc.w 0
ch1mute:     dc.w 0
ch2mute:     dc.w 0
ch3mute:     dc.w 0
ch4mute:     dc.w 0

muzaxoff:
  move.w  #$000f,$dff096
  ;lea     intflg(pc),a2
  ;tst.w   (a2)
  ;beq.w   notag
  ;clr.w   (a2)
  ;lea     hasan(pc),a1
  ;move.l  2(a1),$6c
  lea     datach1(pc),a0
  moveq   #95,d7
frclr:
  clr.w   (a0)+
  dbf     d7,frclr
  rts

player:
  movem.l d0-a6,-(sp)                       ;store registers
  lea     chtab(pc),a2                      ;chtab in a2
  move.l  #$80808080,(a2)                   ;store in chtab
  lea     checkpnt(pc),a3                   ;checkpnt in a3
  move.l  a2,(a3)                           ;store chtab in checkpnt
  bsr.w   samplereinit                      ;gosub samplereinit
  lea     playerdat(pc),a1                  ;playerdat in a1
  lea     $dff0a0,a6                        ;amiga channel address in a6
  lea     datach1(pc),a5                    ;datach1 in a5
  move.w  #1,10(a1)                         ;dma = 1
  moveq   #0,d6                             ;clear d6
  bsr.w   playit                            ;gosub playit
  lea     16(a6),a6                         ;point to next amiga channel
  lea     48(a5),a5                         ;point to next datachx
  moveq   #2,d6                             ;track step offset
  move.w  d6,10(a1)                         ;dma = 2
  bsr.w   playit                            ;gosub playit
  lea     16(a6),a6                         ;point to next amiga channel
  lea     48(a5),a5                         ;point to next datachx
  moveq   #4,d6                             ;track step offset
  move.w  d6,10(a1)                         ;dma = 4
  bsr.w   playit                            ;gosub playit
  lea     16(a6),a6                         ;point to next amiga channel
  lea     48(a5),a5                         ;point to next datachx
  move.w  #8,10(a1)                         ;dma = 8
  moveq   #6,d6                             ;track step offset
  bsr.w   playit                            ;gosub playit
  lea     $dff0a0,a6                        ;amiga channel address in a6
  lea     datach1(pc),a5                    ;datach1 in a5
  bsr.w   playit2                           ;gosub playit2
  lea     16(a6),a6                         ;point to next amiga channel
  lea     48(a5),a5                         ;point to next datachx
  bsr.w   playit2                           ;gosub playit2
  lea     16(a6),a6                         ;point to next amiga channel
  lea     48(a5),a5                         ;point to next datachx
  bsr.w   playit2                           ;gosub playit2
  lea     16(a6),a6                         ;point to next amiga channel
  lea     48(a5),a5                         ;point to next datachx
  bsr.w   playit2                           ;gosub playit2
  clr.l   2(a1)                             ;reset newpatflg
  subi.w  #1,(a1)                           ;decrease songdelay
  bne.w   interweg                          ;if != 0 goto interweg
  move.w  14(a1),(a1)                       ;copy songspd in songdelay (reset timer)
  andi.w  #15,(a1)                          ;speed mask (0-15)
  move.w  14(a1),d5                         ;songspd in d5
  andi.w  #15,d5                            ;speed mask (0-15)
  move.w  14(a1),d0                         ;songspd in d0
  andi.w  #240,d0                           ;speed mask (0-240)
  asr.w   #4,d0                             ;divide by 16
  asl.w   #4,d5                             ;multiply by 16
  or.w    d0,d5                             ;| both results
  move.w  d5,14(a1)                         ;store in songspd
  move.w  #1,4(a1)                          ;newnoteflg = 1
  addi.w  #1,8(a1)                          ;increase patcnt
  move.w  18(a1),d5                         ;patlength in d5
  cmpi.w  #64,8(a1)                         ;compare patlength to 64
  beq.w   ohoh                              ;if == goto ohoh
  cmp.w   8(a1),d5                          ;compare patlength to patcnt
  bne.w   interweg                          ;if != goto interweg
ohoh:
  clr.w   8(a1)                             ;reset patcnt
  move.w  #1,2(a1)                          ;newpatflg = 1
  addi.w  #1,6(a1)                          ;increase songcnt
  move.w  16(a1),d5                         ;songlength in d5
  cmp.w   6(a1),d5                          ;compare songlength to songcnt
  bne.w   interweg                          ;if != goto interweg
  movea.l songdata2(pc),a0                  ;songdata2 in a0
  moveq   #0,d0                             ;clear d0
  tst.b   (a0)                              ;test songdata2
  beq.w   afnokke                           ;if 0 goto afnokke
  move.b  1(a0,d0.l),7(a1)                  ;
  clr.b   6(a1)                             ;
  bra.w   interweg                          ;goto interweg
afnokke:
  bsr.w   muzaxoff                          ;gosub muzaxoff
  bra.w   hijsuit                           ;goto hijsuit
interweg:
  move.w  #$800f,$dff096                    ;enable amiga channels
hijsuit:
  movem.l (sp)+,d0-a6                       ;restore registers
hasan:
  rts                                       ;return (was jmp)

playit:
  moveq   #0,d0                             ;clear d0
  tst.w   2(a1)                             ;test newpatflag
  beq.w   notnewpat                         ;if 0 goto notnewpat
  movea.l songdata(pc),a0                   ;songdata in a0
  move.w  6(a1),d0                          ;songcnt in d0
  asl.w   #3,d0                             ;multiply by 8
  add.w   d0,d6                             ;track step offset
  move.b  (a0,d6.l),3(a5)                   ;step pattern # in datachx
  move.b  1(a0,d6.l),9(a5)                  ;step note transpose in datachx
notnewpat:
  tst.w   4(a1)                             ;test newnoteflag
  beq.w   insthandle                        ;if 0 goto insthandle
  movea.l patdata(pc),a0                    ;patdata in a0
  move.w  2(a5),d0                          ;pattern # in d0
  asl.w   #8,d0                             ;multiply by 256
  lea     (a0,d0.l),a0                      ;pattern command in a0
  move.w  8(a1),d0                          ;patcnt in d0
  asl.w   #2,d0                             ;multiply by 4
  tst.b   (a0,d0.l)                         ;test command note (with offset)
  beq.w   insthandle                        ;if 0 goto insthandle
  lea     (a0,d0.l),a0                      ;current pattern command in a0
  cmpi.b  #74,2(a0)                         ;compare command val1 to 74
  beq.w   zelfdinstr                        ;if == goto zelfdinstr (n.wander)
  move.b  (a0),7(a5)                        ;note in datachx
  tst.b   1(a0)                             ;test command instrument
  beq.w   zelfdinstr                        ;if 0 goto zelfdinstr
  move.b  1(a0),5(a5)                       ;instrument # in datachx
  subi.b  #1,5(a5)                          ;decrease instrument #
zelfdinstr:
  movea.l instdata(pc),a4                   ;instdata in a4
  move.w  4(a5),d0                          ;instrument # in d0
  asl.w   #4,d0                             ;multiply by 16
  lea     (a4,d0.l),a4                      ;instrument header in a4
  move.b  8(a4),19(a5)                      ;finetune in datachx
  andi.b  #63,5(a5)                         ;instrument # mask (0-63)
  clr.b   15(a5)                            ;reset datachx val1
  cmpi.b  #64,2(a0)                         ;compare command val1 to 64
  bcs.w   pbnd                              ;if < goto pbnd (pitchbend)
  move.b  2(a0),15(a5)                      ;command val1 in datachx
  subi.b  #62,15(a5)                        ;subtract 62 to val1
  bra.w   noeff2                            ;goto noeff2
pbnd:
  move.b  #1,15(a5)                         ;datachx val1 = 1
noeff2:
  move.b  3(a0),13(a5)                      ;command val2 in datachx
  cmpi.b  #12,15(a5)                        ;compare datachx val1 to 12 (note wander)
  beq.w   nwando                            ;if == goto nwando
  move.b  2(a0),11(a5)                      ;command val1 in datachx
  cmpi.b  #1,15(a5)                         ;compare datachx val1 to 1 (test for pitchbend)
  bne.w   vanafhierzelfde                   ;if != goto vanafhierzelfde
  lea     frequencies+14(pc),a2             ;frequencies in a2
  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  move.b  11(a5),d1                         ;pitchbend note in d1
  move.w  8(a5),d0                          ;note transpose in d0
  ext.w   d0                                ;extend to word
  add.w   d0,d1                             ;add transpose to pitchbend note
  move.w  18(a5),d0                         ;finetune in d0
  add.w   46(a5),d0                         ;add ???
  andi.w  #15,d0                            ;result mask (0-15)
  asl.w   #7,d0                             ;multiply by 128
  lea     (a2,d0.l),a2                      ;frequencies finetune offset
  add.w   d1,d1                             ;multiply by 2
  move.w  (a2,d1.l),42(a5)                  ;period in datachx
  bra.w   vanafhierzelfde                   ;goto vanafhierzelfde
nwando:
  move.b  (a0),11(a5)                       ;note in datachx pitchbend note
  lea     frequencies+14(pc),a2             ;frequencies in a2
  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  move.b  11(a5),d1                         ;pitchbend note in d1
  move.w  8(a5),d0                          ;note transpose in d0
  ext.w   d0                                ;extend to word
  add.w   d0,d1                             ;add transpose to pitchbend note
  move.w  18(a5),d0                         ;finetune in d0
  add.w   46(a5),d0                         ;add ???
  andi.w  #15,d0                            ;result mask (0-15)
  asl.w   #7,d0                             ;multiply by 128
  lea     (a2,d0.l),a2                      ;frequencies finetune offset
  add.w   d1,d1                             ;multiply by 2
  move.w  (a2,d1.l),42(a5)                  ;period in datachx
vanafhierzelfde:
  cmpi.b  #11,15(a5)                        ;compare datachx val1 to 11
  bne.w   noarpchng                         ;if != goto noarpchng (arpeggio change)
  move.b  13(a5),4(a4)                      ;arpeggio table # in instrument header
  andi.b  #7,4(a4)                          ;arpeggio table # mask (0-7)
noarpchng:
  moveq   #0,d1                             ;clear d1
  movea.l wavedata(pc),a3                   ;wavedata in a3
  move.b  (a4),d1                           ;instrument wave # in d1
  cmpi.b  #12,15(a5)                        ;compare datachx val1 to 12
  beq.w   nosmpol                           ;if == goto nosmpol (note wander)
  cmpi.b  #32,d1                            ;compare wave # to 32
  bcc.w   sampletjen                        ;if >= goto sampletjen (sample, not synth)
nosmpol:
  asl.w   #7,d1                             ;multiply wave # by 128
  lea     (a3,d1.l),a3                      ;wavedata offset
  move.l  a3,(a6)                           ;set amiga channel pointer
  moveq   #0,d1                             ;clear d1
  move.b  1(a4),d1                          ;instrument wave length in d1
  move.w  d1,4(a6)                          ;set amiga channel length
  cmpi.b  #12,15(a5)                        ;compare datachx val1 to 12
  beq.w   oioe                              ;if == goto oioe (note wander)
  cmpi.b  #10,15(a5)                        ;compare datachx val1 to 10
  beq.w   oioe                              ;if == goto oioe (no dma)
  move.w  10(a1),$dff096                    ;disable amiga channel (dma bit)
oioe:
  tst.b   11(a4)                            ;test instrument effect #
  beq.w   sampletrug                        ;if 0 goto sampletrug
  cmpi.b  #2,15(a5)                         ;compare effect # to 2
  beq.w   sampletrug                        ;if == goto sampletrug
  cmpi.b  #4,15(a5)                         ;compare effect # to 4
  beq.w   sampletrug                        ;if == goto sampletrug
  cmpi.b  #12,15(a5)                        ;compare datachx val1 to 12
  beq.w   sampletrug                        ;if == goto sampletrug (note wander)
  moveq   #0,d0                             ;clear d0
  move.b  12(a4),d0                         ;instrument source wave 1 in d0
  asl.w   #7,d0                             ;multiply by 128
  movea.l wavedata(pc),a3                   ;wavedata in a3
  lea     (a3,d0.l),a3                      ;wavedata offset
  moveq   #0,d0                             ;clear d0
  move.b  (a4),d0                           ;instrument wave # in d0
  asl.w   #7,d0                             ;multiply by 128
  movea.l wavedata(pc),a2                   ;wavedata in a2
  lea     (a2,d0.l),a2                      ;wavedata offset
  clr.b   6(a4)                             ;reset instrument ???
  moveq   #0,d7                             ;clear d7
  moveq   #31,d7                            ;loop counter
initz:
  move.l  (a3)+,(a2)+                       ;copy 32 bytes of source wave 1 in instrument wave
  dbf     d7,initz                          ;loop
  move.b  14(a4),41(a5)                     ;instrument effect speed in datachx
sampletrug:
  cmpi.b  #3,15(a5)                         ;compare datachx val1 to 3
  beq.w   novioli                           ;if == goto novioli (no volume i)
  cmpi.b  #4,15(a5)                         ;compare datachx val1 to 4
  beq.w   novioli                           ;if == goto novioli (no effect+volume i)
  cmpi.b  #12,15(a5)                        ;compare datachx val1 to 12
  beq.w   novioli                           ;if == goto novioli (note wander)
  move.w  #1,24(a5)                         ;datachx ??? = 1
  clr.w   22(a5)                            ;reset datachx ???
novioli:
  clr.w   44(a5)                            ;reset datachx ???
  move.b  7(a4),29(a5)                      ;instrument pitch delay in datachx
  clr.w   30(a5)                            ;reset datachx ???
  clr.w   26(a5)                            ;reset datachx ???
insthandle:
  cmpi.b  #5,15(a5)                         ;compare datachx val1 to 5
  beq.w   nplen                             ;if == goto nplen (pattern length)
  cmpi.b  #6,15(a5)                         ;compare datachx val1 to 6
  beq.w   nsspd                             ;if == goto nsspd (song speed)
  cmpi.b  #7,15(a5)                         ;compare datachx val1 to 7
  beq.w   laan                              ;if == goto laan (led on)
  cmpi.b  #8,15(a5)                         ;compare datachx val1 to 8
  beq.w   luit                              ;if == goto luit (led off)
  cmpi.b  #13,15(a5)                        ;compare datachx val1 to 13
  beq.w   nshuf                             ;if == goto nshuf (shuffle)
  rts                                       ;return
laan:
  bclr  #1,$bfe001                          ;led filter on
  rts                                       ;return
luit:
  bset  #1,$bfe001                          ;led filter off
  rts                                       ;return
nplen:
  moveq   #0,d0                             ;clear d0
  move.b  13(a5),d0                         ;datachx val2 in d0
  tst.w   d0                                ;test val2
  beq.w   ruts                              ;if 0 goto ruts
  cmpi.w  #64,d0                            ;compare val2 to 64
  bhi.w   ruts                              ;if > goto ruts
  move.w  d0,18(a1)                         ;val2 in patlength
  rts
nsspd:
  moveq   #0,d0                             ;clear d0
  move.b  13(a5),d0                         ;datachx val2 in d0
  andi.w  #15,d0                            ;speed mask (0-15)
  move.b  d0,d1                             ;result in d1
  asl.b   #4,d0                             ;multiply by 16
  or.b    d1,d0                             ;| val2 and result
  tst.b   d1                                ;test result
  beq.w   ruts                              ;if 0 goto ruts
  cmpi.b  #15,d1                            ;compare result to 15
  bhi.w   ruts                              ;if > goto ruts
  move.w  d0,14(a1)                         ;val2 in songspd
  lea     songspdchngflg(pc),a2             ;songspdchngflg in a2
  clr.w   (a2)                              ;reset songspdchngflg
  rts                                       ;return
nshuf:
  clr.b   15(a5)                            ;reset datachx val1
  moveq   #0,d0                             ;clear d0
  move.b  13(a5),d0                         ;datachx val2 in d0
  move.b  d0,d1                             ;val2 in d1
  andi.b  #15,d1                            ;val2 mask (0-15)
  tst.b   d1                                ;test result
  beq.w   ruts                              ;if 0 goto ruts
  move.b  d0,d1                             ;val2 in d1
  andi.b  #240,d1                           ;val2 mask (0-240)
  tst.b   d1                                ;test result
  beq.w   ruts                              ;if 0 goto ruts
  move.w  d0,14(a1)                         ;val2 in songspd
  lea     songspdchngflg(pc),a2             ;songspdchngflg in a2
  clr.w   (a2)                              ;reset songspdchngflg
  rts                                       ;return

checkpnt: dc.l 0
chtab:    dc.l 0,0

playit2:
  cmpi.b  #9,15(a5)                         ;compare datachx val1 to 9
  bne.w   nrl                               ;if != goto (nrl) (led rapid)
  bchg    #1,$bfe001                        ;toggle led status
nrl:
  moveq   #0,d0                             ;clear d0
  movea.l instdata(pc),a4                   ;instdata in a4
  move.w  4(a5),d0                          ;datachx instrument # in d0
  asl.w   #4,d0                             ;multiply by 16
  lea     (a4,d0.l),a4                      ;instrument header in a4
  movem.l d0-a6,-(sp)                       ;store registers
  tst.b   11(a4)                            ;test instrument effect #
  beq.w   hiha                              ;if 0 goto hiha
  cmpi.b  #32,(a4)                          ;compare instrument wave # to 32
  bcc.w   hiha                              ;if >= goto hiha (sample, not synth)
  movea.l checkpnt(pc),a2                   ;checkpnt in a2
  lea     chtab(pc),a3                      ;chtab in a3
  moveq   #0,d0                             ;clear d0
  move.b  5(a5),d0                          ;instrument # in d0
  addq.w  #1,d0                             ;increase instrument #
  cmp.b   (a3)+,d0                          ;compare result to chtab[x+0]
  beq.w   hiha                              ;if == goto hiha
  cmp.b   (a3)+,d0                          ;compare result to chtab[x+1]
  beq.w   hiha                              ;if == goto hiha
  cmp.b   (a3)+,d0                          ;compare result to chtab[x+2]
  beq.w   hiha                              ;if == goto hiha
  cmp.b   (a3)+,d0                          ;compare result to chtab[x+3]
  beq.w   hiha                              ;if == goto hiha
  move.b  d0,(a2)+                          ;instruments # (increased) in checkpnt
  lea     checkpnt(pc),a2                   ;checkpnt in a2
  addi.l  #1,(a2)                           ;increase checkpnt
  tst.b   41(a5)                            ;test datachx instrument effect speed
  bne.w   jammel                            ;if != 0 goto jammel
  move.b  14(a4),41(a5)                     ;instrument effect speed in datachx
  lea     effjmptab(pc),a2                  ;effjmptab in a2
  moveq   #0,d0                             ;clear d0
  move.b  11(a4),d0                         ;instrument effect # in d0
  asl.w #2,d0                               ;multiply by 4
  move.l  (a2,d0.l),d0                      ;function address in d0
  lea     main(pc),a2                       ;main function address in a2
  lea     (a2,d0.l),a2                      ;effect function address in a2
  movea.l wavedata(pc),a3                   ;wavedata in a3
  moveq   #0,d3                             ;clear d3
  move.b  (a4),d3                           ;instrument wave # in d3
  asl.w   #7,d3                             ;multiply by 128
  lea     (a3,d3.l),a3                      ;wavedata offset
  jsr     (a2)                              ;gosub effect function
  bra.w   hiha                              ;goto hiha
jammel:
  subi.b  #1,41(a5)                         ;decrease datachx effect speed
hiha:
  movem.l (sp)+,d0-a6                       ;restore registers
  tst.w   24(a5)                            ;test datachx volume speed
  beq.w   geenvolmeer                       ;if 0 goto geenvolmeer
  subi.w  #1,24(a5)                         ;else decrease volume speed
  tst.w   24(a5)                            ;test datachx volume speed
  bne.w   geenvolmeer                       ;if != 0 goto geenvolmeer
  move.b  3(a4),25(a5)                      ;instrument volume speed in datachx (reset counter)
  addi.w  #1,22(a5)                         ;increase datachx ???
  andi.w  #127,22(a5)                       ;value mask (0-127)
  tst.w   22(a5)                            ;test datachx ???
  bne.w   okgagang                          ;if != 0 goto okgagang
  btst    #1,15(a4)                         ;test 
  bne.w   okgagang
  clr.w   24(a5)
  bra.w   geenvolmeer
okgagang:
  move.w  22(a5),d0
  moveq   #0,d1
  movea.l wavedata(pc),a3
  move.b  2(a4),d1
  asl.w   #7,d1
  add.w   d0,d1
  lea     (a3,d1.l),a3
  moveq   #0,d1
  move.b  (a3),d1
  addi.b  #129,d1
  neg.b   d1
  asr.w   #2,d1
  move.w  d1,8(a6)
  move.w  d1,36(a5)
geenvolmeer:
  lea     frequencies+14(pc),a2             ;frequencies in a2
  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  move.w  6(a5),d1                          ;datachx note in d1
  tst.b   4(a4)                             ;test instrument arpeggio #
  beq.w   noarp                             ;if 0 goto noarp
  movea.l arpdata(pc),a3                    ;arpdata in a3
  move.b  4(a4),d0                          ;instrument arpeggio # in d0
  asl.w   #5,d0                             ;multiply by 32
  lea     (a3,d0.l),a3                      ;arpeggio data in a3
  move.w  26(a5),d0                         ;datachx arpeggio step in d0
  add.b   (a3,d0.l),d1                      ;add arpeggio value to note
  addi.w  #1,26(a5)                         ;increase arpeggio step
  andi.w  #31,26(a5)                        ;arpeggio step mask (0-31)
noarp:
  move.w  8(a5),d0                          ;datachx note transpose in d0
  ext.w   d0                                ;extend to word
  add.w   d0,d1                             ;add transpose to note
  move.w  18(a5),d0                         ;datachx finetune in d0
  add.w   46(a5),d0                         ;add datachx ???
  andi.w  #15,d0                            ;result mask (0-15)
  asl.w   #7,d0                             ;multiply by 128
  lea     (a2,d0.l),a2                      ;frequencies finetune offset
  add.w   d1,d1                             ;multiply by 2
  move.w  (a2,d1.l),16(a5)                  ;period in datachx
  move.w  16(a5),d3                         ;copy in d3
  cmpi.b  #12,15(a5)                        ;compare datachx val1 to 12
  beq.w   nwandvruut                        ;if == goto nwandvruut (note wander)
  cmpi.b  #1,15(a5)                         ;compare datachx val1 to 1
  bne.w   nognietd                          ;if != goto nognietd (pitch bend)
nwandvruut:
  move.w  12(a5),d0                         ;datachx val2 in d0
  ext.w   d0                                ;extend to word
  neg.w   d0                                ;negate value
  add.w   d0,44(a5)                         ;add to datachx ???
  move.w  16(a5),d1                         ;datachx period in d1
  add.w   44(a5),d1                         ;add datachx ???
  move.w  d1,16(a5)                         ;result in datachx period
  tst.w   12(a5)                            ;test datachx val2
  beq.w   nognietd                          ;if 0 goto nognietd
  btst    #15,d0                            ;
  beq.w   pdwn
  cmp.w   42(a5),d1
  bhi.w   nognietd
  move.w  42(a5),d1
  sub.w   d3,d1
  move.w  d1,44(a5)
  clr.w   12(a5)
  bra.w   nognietd
pdwn:
  cmp.w   42(a5),d1
  bcs.w   nognietd
  move.w  42(a5),d1
  sub.w   d3,d1
  move.w  d1,44(a5)
  clr.w   12(a5)
nognietd:
  tst.b   5(a4)
  beq.w   nopitch
  tst.b   29(a5)
  beq.w   okpitzen
  subi.b  #1,29(a5)
  bra.w   nopitch
okpitzen:
  movea.l wavedata(pc),a3
  moveq   #0,d1
  move.b  5(a4),d1
  asl.w   #7,d1
  lea     (a3,d1.l),a3
  move.w  30(a5),d1
  addi.w  #1,30(a5)
  andi.w  #127,30(a5)
  tst.w   30(a5)
  bne.w   opplopz
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
  dc.l ruts-main
  dc.l pfilter-main
  dc.l pmix-main
  dc.l pscrl-main
  dc.l pscrr-main
  dc.l pupsmple-main
  dc.l pdwnsmple-main
  dc.l pnega-main
  dc.l pmadmix-main
  dc.l padda-main
  dc.l pfilt2-main
  dc.l pmorph-main
  dc.l pmorphf-main
  dc.l pfilt3-main
  dc.l pnega2-main
  dc.l pcnega-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main
  dc.l ruts-main

pmorph:
  moveq   #0,d3
  movea.l wavedata(pc),a0
  move.b  12(a4),d3
  asl.w   #7,d3
  lea     (a0,d3.l),a0
  moveq   #0,d3
  movea.l wavedata(pc),a2
  move.b  13(a4),d3
  asl.w   #7,d3
  lea     (a2,d3.l),a2
  addi.b  #1,6(a4)
  andi.b  #127,6(a4)
  moveq   #0,d0
  move.b  6(a4),d0
  cmpi.b  #64,d0
  bcc.w   morphl
  move.l  d0,d3
  eori.b  #255,d3
  andi.w  #63,d3
  moveq   #0,d7
  move.b  1(a4),d7
  add.b   d7,d7
  subq.w  #1,d7
zrala:
  move.b  (a0)+,d1
  move.b  (a2)+,d2
  ext.w   d1
  ext.w   d2
  mulu.w  d0,d1
  mulu.w  d3,d2
  add.w   d1,d2
  asr.w   #6,d2
  move.b  d2,(a3)+
  dbf     d7,zrala
  rts
morphl:
  moveq   #0,d7
  move.b  1(a4),d7
  add.b   d7,d7
  subq.w  #1,d7
  moveq   #127,d3
  sub.l   d0,d3
  move.l  d3,d0
  eori.b  #255,d3
  andi.w  #63,d3
zralal:
  move.b  (a0)+,d1
  move.b  (a2)+,d2
  ext.w   d1
  ext.w   d2
  mulu.w  d0,d1
  mulu.w  d3,d2
  add.w   d1,d2
  asr.w   #6,d2
  move.b  d2,(a3)+
  dbf     d7,zralal
  rts
pmorphf:
  moveq   #0,d3
  movea.l wavedata(pc),a0
  move.b  12(a4),d3
  asl.w   #7,d3
  lea     (a0,d3.l),a0
  moveq   #0,d3
  movea.l wavedata(pc),a2
  move.b  13(a4),d3
  asl.w   #7,d3
  lea     (a2,d3.l),a2
  addi.b  #1,6(a4)
  andi.b  #31,6(a4)
  moveq   #0,d0
  move.b  6(a4),d0
  cmpi.b  #16,d0
  bcc.w   morphl2
  move.l  d0,d3
  eori.b  #255,d3
  andi.w  #15,d3
  moveq   #0,d7
  move.b  1(a4),d7
  add.b   d7,d7
  subq.w  #1,d7
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
  dbf     d7,zralaf
  rts
morphl2:
  moveq   #0,d7
  move.b  1(a4),d7
  add.b   d7,d7
  subq.w  #1,d7
  moveq   #31,d3
  sub.l   d0,d3
  move.l  d3,d0
  eori.b  #255,d3
  andi.w  #15,d3
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
  dbf     d7,zralalf
  rts
pdwnsmple:
  lea     (a3),a2
  lea     128(a3),a3
  lea     64(a2),a2
  moveq   #63,d7
eff5l:
  move.b  -(a2),-(a3)
  move.b  (a2),-(a3)
  dbf     d7,eff5l
  rts
pupsmple:
  lea     (a3),a2
  lea     (a2),a0
  moveq   #63,d7
puplop:
  move.b  (a2)+,(a3)+
  addq.w  #1,a2
  dbf     d7,puplop
  lea     (a0),a2
  moveq   #63,d7
puplop2:
  move.b  (a2)+,(a3)+
  dbf     d7,puplop2
  rts
pmadmix:
  addi.b  #1,6(a4)
  andi.b  #127,6(a4)
  moveq   #0,d1
  move.b  6(a4),d1
  moveq   #0,d3
  movea.l wavedata(pc),a0
  move.b  13(a4),d3
  asl.w   #7,d3
  lea     (a0,d3.l),a0
  moveq   #0,d0
  move.b  1(a4),d0
  add.b   d0,d0
  subq.w  #1,d0
  move.b  (a0,d1.l),d2
  move.b  #3,d1
ieff8:
  add.b   d1,(a3)+
  add.b   d2,d1
  dbf     d0,ieff8
  rts
pmix:
  moveq   #0,d3
  movea.l wavedata(pc),a0
  move.b  12(a4),d3
  asl.w   #7,d3
  lea     (a0,d3.l),a0
  moveq   #0,d3
  movea.l wavedata(pc),a2
  move.b  13(a4),d3
  asl.w   #7,d3
  lea     (a2,d3.l),a2
  moveq   #0,d2
  move.b  6(a4),d2
  addi.b  #1,6(a4)
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
  addi.b  #1,d2
  andi.b  #127,d2
  dbf     d7,eff3l
  rts
padda:
  moveq   #0,d3
  movea.l wavedata(pc),a0
  move.b  13(a4),d3
  asl.w   #7,d3
  lea     (a0,d3.l),a0
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
  dbf     d7,effal
  rts
pnega:
  moveq   #0,d0
  move.b  6(a4),d0
  neg.b   (a3,d0.l)
  addi.b  #1,6(a4)
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
  addi.b  #1,6(a4)
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
  dbf     d7,eff2l
  move.b  d0,(a3)+
  rts
pscrr:
  moveq   #126,d7
  lea     128(a3),a3
  move.b  -(a3),d0
eff4l:
  move.b  -(a3),1(a3)
  dbf     d7,eff4l
  move.b  d0,(a3)
  rts
pcnega:
  lea     (a3),a2
  bsr.w   pfilter
  lea     (a2),a3
  addi.b  #1,6(a4)
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
  dbf     d7,eff1l
  rts
pfilt2:
  lea   126(a3),a2
  moveq   #125,d7
  clr.w   d2
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
  addq.w  #1,d2
  dbf     d7,efffl
  rts
pfilt3:
  lea     126(a3),a2
  moveq   #125,d7
  clr.w   d2
efffl3:
  move.b  (a3)+,d0
  ext.w   d0
  move.b  1(a3),d1
  ext.w   d1
  add.w   d0,d1
  asr.w   #1,d1
  move.b  d1,(a3)
  addq.w  #1,d2
  dbf     d7,efffl3
  rts

sampletjen:
  subi.w  #32,d1
  asl.w   #5,d1
  movea.l samplestruct(pc),a3
  lea     (a3,d1.l),a3
  move.l  a3,32(a5)
  move.w  #1,20(a5)
  movea.l sampledata(pc),a2
  lea     (a2),a0
  adda.l  (a3),a0
  move.l  a0,(a6)
  move.l  4(a3),d1
  sub.l   (a3),d1
  asr.l   #1,d1
  move.w  d1,4(a6)
  move.w  10(a1),$dff096
  bra.w   sampletrug
samplereinit:
  movea.l sampledata(pc),a2                 ;sampledata in a2
  lea     empty(pc),a4                      ;empty in a4
  lea     datach1(pc),a5                    ;datach1 in a5
  lea     $dff0a0,a6                        ;amiga channel register address in a6
  moveq   #3,d5                             ;loop counter
slop:
  tst.w   20(a5)                            ;test datachx ???
  beq.w   next                              ;if 0 goto next
  clr.w   20(a5)                            ;reset datachx ???
  movea.l 32(a5),a3                         ;datachx sample header in a3
  tst.l   8(a3)                             ;test sample loop start
  beq.w   noloop                            ;if 0 goto noloop
  lea     (a2),a1                           ;sampledata address in a1
  adda.l  8(a3),a1                          ;add loop start
  move.l  a1,(a6)                           ;set amiga channel pointer
  move.l  4(a3),d1                          ;sample end in d1
  sub.l   8(a3),d1                          ;subtract sample loop start
  asr.l   #1,d1                             ;divide by 2
  move.w  d1,4(a6)                          ;set amiga channel length
next:
  lea     48(a5),a5                         ;point to next datachx
  lea     16(a6),a6                         ;point to next amiga channel
  dbf     d5,slop                           ;loop
  rts                                       ;return
noloop:
  move.l  a4,(a6)                           ;set amiga channel pointer (sample start)
  move.w  #4,4(a6)                          ;set amiga channel length = 4
  lea     48(a5),a5                         ;point to next datachx
  lea     16(a6),a6                         ;point to next amiga channel
  dbf     d5,slop                           ;loop
  rts                                       ;return

empty: ds.b 8

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

songdata2:    dc.l 0
songdata:     dc.l 0
instdata:     dc.l 0
arpdata:      dc.l 0
wavedata:     dc.l 0
patdata:      dc.l 0
samplestruct: dc.l 0
sampledata:   dc.l 0

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

muzak: incbin "Galway.dmu"