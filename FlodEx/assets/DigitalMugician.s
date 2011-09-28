main:
  movem.l d0-d7/a0-a6,-(a7)
  moveq   #0,d0                             ;songr
  bsr     muzaxon
wait:
  btst    #6,$bfe001
  bne     wait
  bsr     muzaxoff
  movem.l (a7)+,d0-d7/a0-a6
  rts

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
  and.l   #$7,d0
  asl.w   #2,d0
  add.l   (a1,d0),a0
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
  beq     druut
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
  move.w  (a0),d1                           ;seq nr
  move.w  2(a0),d0                          ;pat nr
  lea     songspd(pc),a0
  move.w  (a0),d2                           ;songspd in 2 nibbles
  rts

statusinstr:
  lea     datach1(pc),a5
  move.w  4(a5),d0
  move.w  52(a5),d1
  move.w  100(a5),d2
  move.w  148(a5),d3
  addq    #1,d0
  addq    #1,d1
  addq    #1,d2
  addq    #1,d3
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
  sub.w   #1,d1
  and.w   #3,d1
  lea     datach1(pc),a5
  mulu    #48,d1
  lea     (a5,d1),a5
  and.w   #15,d2
  move.w  d2,46(a5)
  rts

chngsongspd:
  lea     songspd(pc),a0
  and.w   #$ff,d2
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
  lea     ssname(pc),a0                     ;mug.muzak?
  lea     muzak(pc),a1
  moveq   #23,d6
compa:
  move.b  (a0)+,d2
  cmp.b   (a1)+,d2
  bne     error
  dbf     d6,compa
  moveq   #0,d4
  move.w  d0,d4                             ;sngnr
  move.w  d4,d6
  asl.w   #4,d6
  lea     muzak+76(pc),a4
  lea     muzak(pc),a5
  lea     songdata2(pc),a6
  move.l  a4,(a6)
  add.l   d6,(a6)                           ;goedesong verwijzen
  lea     128(a4),a4
  lea     28(a5),a2
  moveq   #0,d2
  moveq   #7,d5
songslop:
  move.l  (a2)+,d3
  asl.l   #3,d3
  cmp.w   d2,d4
  bne     overt
  move.l  a4,4(a6)                          ;sngdata
overt:
  addq    #1,d2
  lea     (a4,d3),a4
  dbf     d5,songslop
  move.l  60(a5),d3
  asl.l   #4,d3
  move.l  a4,8(a6)                          ;indata
  lea     (a4,d3),a4
  move.l  64(a5),d3
  asl.l   #7,d3
  move.l  a4,16(a6)                         ;wavedat
  lea     (a4,d3),a4
  move.l  68(a5),d3
  move.l  a4,24(a6)                         ;smplstruct
  asl.l   #5,d3
  lea     (a4,d3),a4
  moveq   #0,d3
  move.w  26(a5),d3
  asl.l   #8,d3
  move.l  a4,20(a6)                         ;pdata
  lea     (a4,d3),a4
  move.l  a4,28(a6)                         ;sampdata
  move.l  72(a5),d3
  lea     (a4,d3),a4
  tst.w   24(a5)
  beq     nikko2
  move.l  a4,12(a6)                         ;arpda
  rts
nikko2:
  move.l  a4,12(a6)                         ;arp
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
  lea     songnr(pc),a0
  move.w  d0,(a0)
  bsr     initializer
  cmp.w   #-1,d7
  beq     druut
  lea     datach1(pc),a0
  moveq   #95,d7
frclr3:
  clr.w   (a0)+
  dbf     d7,frclr3
  lea     playerdat(pc),a0
  clr.l   (a0)+
  clr.w   (a0)+
  addq    #2,a0
  clr.l   (a0)+
; clr.w   (a0)+
  move.w  #124,$dff0a4
  move.w  #124,$dff0b4
  move.w  #124,$dff0c4
  move.w  #124,$dff0d4
  move.w  #0,$dff0a8
  move.w  #0,$dff0b8
  move.w  #0,$dff0c8
  move.w  #0,$dff0d8
  move.w  #$000f,$dff096
  lea     songnr(pc),a0
  move.w  (a0),d0
  moveq   #3,d7
  lea     datach1(pc),a0
  lea     (a0),a1
initizer:
  move.w  d0,(a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+                             ;eff. bits
  clr.w   (a0)+
  clr.w   (a0)+
  clr.w   (a0)+                             ;zet ch. weer aan flg.
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
  move.l  songdata2(pc),a0
  move.b  3(a0),d1
  lea     songlength(pc),a2
  move.w  d1,(a2)
  lea     patlength(pc),a2
  move.w  #64,(a2)
  move.b  2(a0),d1
  lea     songdelay(pc),a2
  move.w  d1,(a2)
  move.b  d1,d0
  and.b   #15,d0
  and.b   #15,d1
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
  lea     intflg(pc),a2
  tst.w   (a2)
  bne     notag
  lea     player(pc),a0
  lea     hasan(pc),a1
  move.l  $6c,2(a1)
  move.l  a0,$6c
  move.w  #$000f,$dff096
  move.w  #1,(a2)
notag:
  rts

intflg:      dc.w 0
playpattflg: dc.w 0
ch1mute:     dc.w 0
ch2mute:     dc.w 0
ch3mute:     dc.w 0
ch4mute:     dc.w 0

muzaxoff:
  move.w  #$000f,$dff096
  lea     intflg(pc),a2
  tst.w   (a2)
  beq     notag
  clr.w   (a2)
  lea     hasan(pc),a1
  move.l  2(a1),$6c
  lea     datach1(pc),a0
  moveq   #95,d7
frclr:
  clr.w   (a0)+
  dbf     d7,frclr
  rts

player:
  movem.l d0-d7/a0-a6,-(a7)
  lea     chtab(pc),a2
  move.l  #$80808080,(a2)
  lea     checkpnt(pc),a3
  move.l  a2,(a3)
  bsr     samplereinit
  lea     playerdat(pc),a1                  ;very impo(r)tent
  lea     $dff0a0,a6
  lea     datach1(pc),a5
  move.w  #$0001,10(a1)                     ;dma
  moveq   #0,d6                             ;add up with songdata
  bsr     playit
  lea     16(a6),a6
  lea     48(a5),a5
  moveq   #2,d6                             ;add up with songdata
  move.w  d6,10(a1)                         ;dma
  bsr     playit
  lea     16(a6),a6
  lea     48(a5),a5
  moveq   #4,d6                             ;add up with songdata
  move.w  d6,10(a1)
  bsr     playit
  lea     16(a6),a6
  lea     48(a5),a5
  move.w  #$0008,10(a1)
  moveq   #6,d6                             ;add up with songdata
  bsr     playit
  lea     $dff0a0,a6                        ;$dff0a0
  lea     datach1(pc),a5                    ;datach1
  bsr     playit2
  lea     16(a6),a6
  lea     48(a5),a5
  bsr     playit2
  lea     16(a6),a6
  lea     48(a5),a5
  bsr     playit2
  lea     16(a6),a6
  lea     48(a5),a5
  bsr     playit2
  clr.l   2(a1)                             ;npatflag
  sub.w   #1,(a1)                           ;songdelay
  bne     interweg
  move.w  14(a1),(a1)                       ;sngspd
  and.w   #15,(a1)
  move.w  14(a1),d5
  and.w   #15,d5
  move.w  14(a1),d0
  and.w   #$f0,d0
  asr.w   #4,d0
  asl.w   #4,d5
  or.w    d0,d5
  move.w  d5,14(a1)
  move.w  #1,4(a1)
  add.w   #1,8(a1)
  move.w  18(a1),d5
  cmp.w   #64,8(a1)
  beq     ohoh
  cmp.w   8(a1),d5                          ;cmp.w  patcnt,d5
  bne     interweg
ohoh:
  clr.w   8(a1)
  move.w  #1,2(a1)
  add.w   #1,6(a1)
  move.w  16(a1),d5
  cmp.w   6(a1),d5
  bne     interweg
  move.l  songdata2(pc),a0
  moveq   #0,d0
  tst.b   (a0)                              ;loopflg
  beq     afnokke
  move.b  1(a0,d0),7(a1)                    ;songcnt+1
  clr.b   6(a1)
  bra     interweg
afnokke:
  bsr     muzaxoff
  bra     hijsuit
interweg:
  move.w  #$800f,$dff096
hijsuit:
  movem.l (a7)+,d0-d7/a0-a6
hasan:
  jmp     $00000000

playit:
  moveq   #0,d0
  tst.w   2(a1)
  beq     notnewpat
  move.l  songdata(pc),a0
  move.w  6(a1),d0
  asl.w   #3,d0
; lea     (a0,d0),a0
  add.w   d0,d6
  move.b  (a0,d6),3(a5)                     ;cur. patnr
  move.b  1(a0,d6),9(a5)                    ;cur. trspose
notnewpat:
  tst.w   4(a1)
  beq     insthandle
  move.l  patdata(pc),a0
  move.w  2(a5),d0
  asl.w   #8,d0
  lea     (a0,d0),a0
  move.w  8(a1),d0
  asl.w   #2,d0
  tst.b   (a0,d0)
  beq     insthandle
  lea     (a0,d0),a0                        ;GROOTTE INIT
  cmp.b   #$4a,2(a0)                        ;note wander
  beq     zelfdinstr
  move.b  (a0),7(a5)                        ;last note played
  tst.b   1(a0)
  beq     zelfdinstr
  move.b  1(a0),5(a5)                       ;cur.instnr.
  sub.b   #1,5(a5)
zelfdinstr:
  move.l  instdata(pc),a4
  move.w  4(a5),d0                          ;cur.instnr.
  asl.w   #4,d0                             ;ver. met 16 !  
  lea     (a4,d0),a4
  move.b  8(a4),19(a5)                      ;f.tune
  and.b   #63,5(a5)
  clr.b   15(a5)                            ;eff=none
  cmp.b   #64,2(a0)
  blo     pbnd
  move.b  2(a0),15(a5)
  sub.b   #62,15(a5)
  bra     noeff2
pbnd:
  move.b  #1,15(a5)
noeff2:
  move.b  3(a0),13(a5)                      ;pitch.spd
  cmp.b   #12,15(a5)
  beq     nwando
  move.b  2(a0),11(a5)                      ;endnote
  cmp.b   #1,15(a5)                         ;eind freq voor bend berekenen
  bne     vanafhierzelfde
  lea     frequencies+14(pc),a2
  moveq   #0,d0
  moveq   #0,d1
  move.b  11(a5),d1                         ;endnotenrpbend
  move.w  8(a5),d0
  ext.w   d0
  add.w   d0,d1                             ;pat.transpose
  move.w  18(a5),d0                         ;fine tuning
  add.w   46(a5),d0
  and.w   #15,d0
  asl.w   #7,d0
  lea     (a2,d0),a2                        ;finetune erby
  add.w   d1,d1
  move.w  (a2,d1),42(a5)                    ;pitch end value
  bra     vanafhierzelfde
nwando:
  move.b  (a0),11(a5)                       ;endnote
  lea     frequencies+14(pc),a2
  moveq   #0,d0
  moveq   #0,d1
  move.b  11(a5),d1                         ;endnotenrpbend
  move.w  8(a5),d0
  ext.w   d0
  add.w   d0,d1                             ;pat.transpose
  move.w  18(a5),d0                         ;fine tuning
  add.w   46(a5),d0
  and.w   #15,d0
  asl.w   #7,d0
  lea     (a2,d0),a2                        ;finetune erby
  add.w   d1,d1
  move.w  (a2,d1),42(a5)                    ;pitch end value
vanafhierzelfde:  
  cmp.b   #11,15(a5)
  bne     noarpchng
  move.b  13(a5),4(a4)
  and.b   #7,4(a4)
noarpchng:
  moveq   #0,d1
  move.l  wavedata(pc),a3
  move.b  (a4),d1                           ;cur wavef.
  cmp.b   #12,15(a5)
  beq     nosmpol
  cmp.b   #32,d1                            ;sample of waveform??
  bhs     sampletjen
nosmpol:
  asl.w   #7,d1                             ;128 bytes per wavef.
  lea     (a3,d1),a3
  move.l  a3,(a6)                           ;ch1.waveform
  moveq   #0,d1
  move.b  1(a4),d1                          ;wavelength
  move.w  d1,4(a6)                          ;ch1.length
  cmp.b   #12,15(a5)
  beq     oioe
  cmp.b   #10,15(a5)
  beq     oioe
  move.w  10(a1),$dff096                    ;ch.uit
**** THE MUGICIAN EFFECT RECOGNIZER ****
oioe:
  tst.b   11(a4)
  beq     sampletrug
  cmp.b   #2,15(a5)
  beq     sampletrug
  cmp.b   #4,15(a5)
  beq     sampletrug
  cmp.b   #12,15(a5)
  beq     sampletrug
; move.b  5(a5),40(a5)
; add.b   #1,40(a5)
  moveq   #0,d0
  move.b  12(a4),d0                         ;src
  asl.w   #7,d0
  move.l  wavedata(pc),a3
  lea     (a3,d0),a3
  moveq   #0,d0
  move.b  (a4),d0                           ;dest
  asl.w   #7,d0
  move.l  wavedata(pc),a2
  lea     (a2,d0),a2
  clr.b   6(a4)                             ;effhulpcnt
  moveq   #0,d7
; move.b  1(a4),d7
; add.b   d7,d7
; addq    #4,d7
; asr.w   #2,d7
; subq    #1,d7
  moveq   #31,d7
initz:
  move.l  (a3)+,(a2)+
  dbf     d7,initz
  move.b  14(a4),41(a5)
sampletrug:
  cmp.b   #3,15(a5)
  beq     novioli
  cmp.b   #4,15(a5)
  beq     novioli
  cmp.b   #12,15(a5)
  beq     novioli
  move.w  #1,24(a5)
  clr.w   22(a5)                            ;volumecnt
novioli:
  clr.w   44(a5)
; move.b  3(a4),25(a5)                      ;volspd.
  move.b  7(a4),29(a5)                      ;phasedelay
  clr.w   30(a5)                            ;phasecnt
  clr.w   26(a5)                            ;arpcnt
insthandle:
  cmp.b   #5,15(a5)
  beq     nplen
  cmp.b   #6,15(a5)
  beq     nsspd
  cmp.b   #7,15(a5)
  beq    laan
  cmp.b   #8,15(a5)
  beq     luit
  cmp.b   #13,15(a5)
  beq     nshuf
  rts
laan:
  bclr    #1,$bfe001
  rts
luit:
  bset    #1,$bfe001
  rts
nplen:
  moveq   #0,d0
  move.b  13(a5),d0
  tst.w   d0
  beq     ruts
  cmp.w   #64,d0
  bhi     ruts
  move.w  d0,18(a1)
  rts
nsspd:
  moveq   #0,d0
  move.b  13(a5),d0
  and.w   #15,d0
  move.b  d0,d1
  asl.b   #4,d0
  or.b    d1,d0
  tst.b   d1
  beq     ruts
  cmp.b   #15,d1
  bhi     ruts
  move.w  d0,14(a1)
  lea     songspdchngflg(pc),a2
  clr.w   (a2)
  rts
nshuf:
  clr.b   15(a5)
  moveq   #0,d0
  move.b  13(a5),d0
  move.b  d0,d1
  and.b   #15,d1
  tst.b   d1
  beq     ruts
  move.b  d0,d1
  and.b   #$f0,d1
  tst.b   d1
  beq     ruts
  move.w  d0,14(a1)
  lea     songspdchngflg(pc),a2
  clr.w   (a2)
  rts

checkpnt: dc.l 0
chtab:    dc.l 0,0

playit2:
  cmp.b   #9,15(a5)
  bne     nrl
  bchg    #1,$bfe001
nrl:
  moveq   #0,d0
  move.l  instdata(pc),a4
  move.w  4(a5),d0                          ;cur.instnr.
  asl.w   #4,d0                             ;ver. met 16 !  
  lea     (a4,d0),a4

;eerst volume updaten

*** ALLEREERST DE EFFECIEFACCIE! ***
  movem.l d0-d7/a0-a6,-(a7)

  tst.b 11(a4)
  beq hiha
  cmp.b #32,(a4)
  bhs hiha

  move.l  checkpnt(pc),a2
  lea chtab(pc),a3
  moveq #0,d0
  move.b  5(a5),d0
  addq  #1,d0
  cmp.b (a3)+,d0
  beq hiha
  cmp.b (a3)+,d0
  beq hiha
  cmp.b (a3)+,d0
  beq hiha
  cmp.b (a3)+,d0
  beq hiha
  move.b  d0,(a2)+
  lea checkpnt(pc),a2
  add.l #1,(a2)

  tst.b 41(a5)
  bne jammel
  move.b  14(a4),41(a5)

  lea effjmptab(pc),a2
  moveq #0,d0
  move.b  11(a4),d0
  asl.w #2,d0
  move.l  (a2,d0),d0
  lea main(pc),a2
  lea (a2,d0),a2

  move.l  wavedata(pc),a3
  moveq #0,d3
  move.b  (a4),d3
  asl.w #7,d3
  lea (a3,d3),a3
  jsr (a2)    ;effefeccie
  bra hiha
jammel:
  sub.b #1,41(a5)
hiha:
  movem.l (a7)+,d0-d7/a0-a6

  tst.w 24(a5)
  beq geenvolmeer ;volume changing stoppen?
  sub.w #1,24(a5) ;vol.spd.
  tst.w 24(a5)    ;volume al veranderen?
  bne geenvolmeer
  move.b  3(a4),25(a5)  ;vol.spd
  add.w #1,22(a5) ;vol.cnt
  and.w #$7f,22(a5)
  tst.w 22(a5)    
  bne okgagang


  btst  #1,15(a4) ;vol loopen??
  bne okgagang
  clr.w 24(a5)    ;stop volume
  bra geenvolmeer
okgagang:
  move.w  22(a5),d0 ;vol.cnt
  moveq #0,d1
  move.l  wavedata(pc),a3
  move.b  2(a4),d1  ;vol.wave
  asl.w #7,d1
  add.w d0,d1
  lea (a3,d1),a3
  moveq #0,d1
  move.b  (a3),d1   ;vol.
  add.b #129,d1
  neg.b d1
  asr.w #2,d1
  move.w  d1,8(a6)  ;ch1.vol
  move.w  d1,36(a5)

geenvolmeer:

;nu de freq.handler

  lea frequencies+14(pc),a2
  moveq #0,d0
  moveq #0,d1
  move.w  6(a5),d1  ;lastnotenr
  tst.b 4(a4)
  beq noarp

  move.l  arpdata(pc),a3
  move.b  4(a4),d0  ;arp.point
; subq  #1,d0
  asl.w #5,d0
  lea (a3,d0),a3
  move.w  26(a5),d0 ;arpcnt

  add.b (a3,d0),d1  ;notenr ophogen met arpwaarde!
  add.w #1,26(a5)
  and.w #31,26(a5)
noarp:
  
  move.w  8(a5),d0
  ext.w d0
  add.w d0,d1 ;pat.transpose

  move.w  18(a5),d0 ;fine tuning
  add.w 46(a5),d0
  and.w #15,d0
  asl.w #7,d0
  lea (a2,d0),a2  ;finetune erby
  add.w d1,d1
; lea (a2,d1),a2  ;note erby
  move.w  (a2,d1),16(a5)  ;cur.freq

  move.w  16(a5),d3 ;effe onth

  cmp.b #12,15(a5)
  beq nwandvruut
  cmp.b #1,15(a5)
  bne nognietd
nwandvruut:
  move.w  12(a5),d0 ;pbendspd
  ext.w d0
  neg.w d0
  add.w d0,44(a5)


  move.w  16(a5),d1
  add.w 44(a5),d1
  move.w  d1,16(a5)
  tst.w 12(a5)
  beq nognietd
  btst  #15,d0
  beq pdwn
  cmp.w 42(a5),d1
  bhi nognietd
  move.w  42(a5),d1
  sub.w d3,d1
  move.w  d1,44(a5)
  clr.w 12(a5)
  bra nognietd
pdwn: cmp.w 42(a5),d1
  blo nognietd
  move.w  42(a5),d1
  sub.w d3,d1
  move.w  d1,44(a5)
  clr.w 12(a5)
nognietd:

  tst.b 5(a4) ;pitch change
  beq nopitch
  tst.b 29(a5)  ;pitchdelay
  beq okpitzen
  sub.b #1,29(a5)
  bra nopitch
okpitzen:
  move.l  wavedata(pc),a3
  moveq #0,d1
  move.b  5(a4),d1
  asl.w #7,d1
  lea (a3,d1),a3
  move.w  30(a5),d1 ;phasecnt.
  add.w #1,30(a5)
  and.w #127,30(a5)
  tst.w 30(a5)
  bne opplopz
  move.b  9(a4),31(a5)
opplopz:
; lea (a3,d1),a3
  move.b  (a3,d1),d1
  ext.w d1
  neg.w d1
  add.w d1,16(a5) ;cur.freq
nopitch:
  move.w  16(a5),6(a6)  ;ch1. freq.
ruts:
  rts

effjmptab:
  dc.l  ruts-main,pfilter-main,pmix-main,pscrl-main
  dc.l  pscrr-main,pupsmple-main,pdwnsmple-main
  dc.l  pnega-main,pmadmix-main,padda-main,pfilt2-main
  dc.l  pmorph-main,pmorphf-main,pfilt3-main
  dc.l  pnega2-main,pcnega-main
  blk.l 16,ruts-main


pmorph:

  moveq #0,d3
  move.l  wavedata(pc),a0
  move.b  12(a4),d3
  asl.w #7,d3
  lea (a0,d3),a0

  moveq #0,d3
  move.l  wavedata(pc),a2
  move.b  13(a4),d3
  asl.w #7,d3
  lea (a2,d3),a2

  add.b #1,6(a4)
  and.b #127,6(a4)

  moveq #0,d0
  move.b  6(a4),d0
  cmp.b #64,d0
  bhs morphl
  move.l  d0,d3
  eor.b #$ff,d3
  and.w #63,d3

  moveq #0,d7
  move.b  1(a4),d7
  add.b d7,d7
  subq  #1,d7
zrala:
  move.b  (a0)+,d1
  move.b  (a2)+,d2
  ext.w d1
  ext.w d2
  mulu  d0,d1
  mulu  d3,d2
  add.w d1,d2
  asr.w #6,d2
  move.b  d2,(a3)+
  dbf d7,zrala
  rts
morphl: 
  moveq #0,d7
  move.b  1(a4),d7
  add.b d7,d7
  subq  #1,d7

  moveq #127,d3
  sub.l d0,d3
  move.l  d3,d0
  eor.b #$ff,d3
  and.w #63,d3

zralal:
  move.b  (a0)+,d1
  move.b  (a2)+,d2
  ext.w d1
  ext.w d2
  mulu  d0,d1
  mulu  d3,d2
  add.w d1,d2
  asr.w #6,d2
  move.b  d2,(a3)+
  dbf d7,zralal
  rts

pmorphf:

  moveq #0,d3
  move.l  wavedata(pc),a0
  move.b  12(a4),d3
  asl.w #7,d3
  lea (a0,d3),a0

  moveq #0,d3
  move.l  wavedata(pc),a2
  move.b  13(a4),d3
  asl.w #7,d3
  lea (a2,d3),a2

  add.b #1,6(a4)
  and.b #31,6(a4)

  moveq #0,d0
  move.b  6(a4),d0
  cmp.b #16,d0
  bhs morphl2
  move.l  d0,d3
  eor.b #$ff,d3
  and.w #15,d3

  moveq #0,d7
  move.b  1(a4),d7
  add.b d7,d7
  subq  #1,d7
zralaf:
  move.b  (a0)+,d1
  move.b  (a2)+,d2
  ext.w d1
  ext.w d2
  mulu  d0,d1
  mulu  d3,d2
  add.w d1,d2
  asr.w #4,d2
  move.b  d2,(a3)+
  dbf d7,zralaf
  rts
morphl2:  
  moveq #0,d7
  move.b  1(a4),d7
  add.b d7,d7
  subq  #1,d7

  moveq #31,d3
  sub.l d0,d3
  move.l  d3,d0
  eor.b #$ff,d3
  and.w #15,d3

zralalf:
  move.b  (a0)+,d1
  move.b  (a2)+,d2
  ext.w d1
  ext.w d2
  mulu  d0,d1
  mulu  d3,d2
  add.w d1,d2
  asr.w #4,d2
  move.b  d2,(a3)+
  dbf d7,zralalf
  rts




pdwnsmple:
  lea (a3),a2
  lea 128(a3),a3
  lea 64(a2),a2
  moveq #63,d7
eff5l:
  move.b  -(a2),-(a3)
  move.b  (a2),-(a3)
  dbf d7,eff5l
  rts

pupsmple:
  lea (a3),a2
  lea (a2),a0
  moveq #63,d7
puplop:
  move.b  (a2)+,(a3)+
  addq  #1,a2
  dbf d7,puplop

  lea (a0),a2
  moveq #63,d7
puplop2:
  move.b  (a2)+,(a3)+
  dbf d7,puplop2
  rts

pmadmix:
  add.b #1,6(a4)
  and.b #127,6(a4)
  moveq #0,d1
  move.b  6(a4),d1

  moveq #0,d3
  move.l  wavedata(pc),a0
  move.b  13(a4),d3
  asl.w #7,d3
  lea (a0,d3),a0

  moveq #0,d0
  move.b  1(a4),d0
  add.b d0,d0
  subq  #1,d0

  move.b  (a0,d1),d2

  move.b  #3,d1
ieff8:  add.b d1,(a3)+
  add.b d2,d1
  dbf d0,ieff8
  rts



pmix:
  moveq #0,d3
  move.l  wavedata(pc),a0
  move.b  12(a4),d3
  asl.w #7,d3
  lea (a0,d3),a0

  moveq #0,d3
  move.l  wavedata(pc),a2
  move.b  13(a4),d3
  asl.w #7,d3
  lea (a2,d3),a2

  moveq #0,d2
  move.b  6(a4),d2
  add.b #1,6(a4)
  and.b #127,6(a4)

  moveq #0,d7
  move.b  1(a4),d7
  add.b d7,d7
  subq  #1,d7

eff3l:  move.b  (a0)+,d0
  move.b  (a2,d2),d1
  ext.w d0
  ext.w d1
  add.w d0,d1
  asr.w #1,d1
  move.b  d1,(a3)+
  add.b #1,d2
  and.b #127,d2
  dbf d7,eff3l
  rts

padda:
  moveq #0,d3
  move.l  wavedata(pc),a0
  move.b  13(a4),d3
  asl.w #7,d3
  lea (a0,d3),a0

; moveq #0,d3
; lea wavedata(pc),a2
; move.b  13(a4),d3
; asl.w #7,d3
; lea (a2,d3),a2

; moveq #0,d2
; move.b  6(a4),d2
; add.b #1,6(a4)
; and.b #127,6(a4)

  moveq #0,d7
  move.b  1(a4),d7
  add.b d7,d7
  subq  #1,d7

effal:  move.b  (a0)+,d0
  move.b  (a3),d1
  ext.w d0
  ext.w d1
  add.w d0,d1
; asr.w #1,d1
  move.b  d1,(a3)+
  dbf d7,effal
  rts



pnega:
  moveq #0,d0
  move.b  6(a4),d0
  neg.b (a3,d0)
  add.b #1,6(a4)
  move.b  1(a4),d0
  add.b d0,d0
  cmp.b 6(a4),d0
  bhi ruts
  clr.b 6(a4)
  rts


pnega2:
  moveq #0,d0
  move.b  6(a4),d0
  neg.b (a3,d0)
  move.b  1(a4),d1
  add.b 13(a4),d0
  add.b d1,d1
  subq  #1,d1
  and.b d1,d0
  neg.b (a3,d0)

  add.b #1,6(a4)
  move.b  1(a4),d0
  add.b d0,d0
  cmp.b 6(a4),d0
  bhi ruts
  clr.b 6(a4)
  rts


pscrl:
  moveq #126,d7
  move.b  (a3),d0
eff2l:  move.b  1(a3),(a3)+
  dbf d7,eff2l
  move.b  d0,(a3)+
  rts

pscrr:
  moveq #126,d7
  lea 128(a3),a3
  move.b  -(a3),d0
eff4l:  move.b  -(a3),1(a3)
  dbf d7,eff4l
  move.b  d0,(a3)
  rts

pcnega:
  lea (a3),a2
  bsr pfilter
  lea (a2),a3
  add.b #1,6(a4)
  move.b  6(a4),d0
  cmp.b 13(a4),d0
  bne ruts
  clr.b 6(a4)
  bra pupsmple

pfilter:
  moveq #126,d7
eff1l:  move.b  (a3),d0
  ext.w d0
  move.b  1(a3),d1
  ext.w d1
  add.w d0,d1
  asr.w #1,d1
  move.b  d1,(a3)+
  dbf d7,eff1l
  rts
pfilt2:
  lea 126(a3),a2
  moveq #125,d7
  clr.w d2
efffl:  move.b  (a3)+,d0
  ext.w d0
  move.w  d0,d1
  add.w d0,d0
  add.w d1,d0
  move.b  1(a3),d1
  ext.w d1
  add.w d0,d1
  asr.w #2,d1
  move.b  d1,(a3)
  addq  #1,d2
  dbf d7,efffl
  rts
pfilt3:
  lea 126(a3),a2
  moveq #125,d7
  clr.w d2
efffl3: move.b  (a3)+,d0
  ext.w d0
  move.b  1(a3),d1
  ext.w d1
  add.w d0,d1
  asr.w #1,d1
  move.b  d1,(a3)
  addq  #1,d2
  dbf d7,efffl3
  rts

sampletjen:
  sub.w #32,d1
  asl.w #5,d1   ;32 bytes per samplestruct.
  move.l  samplestruct(pc),a3
  lea (a3,d1),a3
  move.l  a3,32(a5) ;opslaan voor over 1 beeld!
  move.w  #1,20(a5)
  move.l  sampledata(pc),a2
  lea (a2),a0
  add.l (a3),a0   ;samplestart
  move.l  a0,(a6)   ;ch1.waveform
  move.l  4(a3),d1
  sub.l (a3),d1
  asr.l #1,d1
  move.w  d1,4(a6)  ;ch1.length
  move.w  10(a1),$dff096  ;ch.uit
  bra sampletrug

samplereinit:
  move.l  sampledata(pc),a2
  lea empty(pc),a4


  lea datach1(pc),a5
  lea $dff0a0,a6
  moveq #3,d5
  
slop:
  tst.w 20(a5)
  beq next
  clr.w 20(a5)
  move.l  32(a5),a3 ;point to smplestruct
  tst.l 8(a3)
  beq noloop

  lea (a2),a1
  add.l 8(a3),a1  ;sampleloopstart
  move.l  a1,(a6)   ;ch1.waveform
  move.l  4(a3),d1
  sub.l 8(a3),d1
  asr.l #1,d1
  move.w  d1,4(a6)  ;ch1.length

next:
  lea 48(a5),a5
  lea 16(a6),a6
  dbf d5,slop
  rts
noloop:
  move.l  a4,(a6)   ;ch1.wavef
  move.w  #4,4(a6)  ;ch1.length

  lea 48(a5),a5
  lea 16(a6),a6
  dbf d5,slop
  rts

empty:
  blk.b 8,0 ;for smple te nokke

playerdat:
songdelay:  dc.w  0
newpatflg:  dc.w  0
newnoteflg: dc.w  0
songcnt:  dc.w  0 ;(0-7)
patcnt:   dc.w  0 ;(0-63)
dma:    dc.w  0

songnr:   dc.w  0
songspd:  dc.w  5
songlength: dc.w  1
patlength:  dc.w  64

datach1:  blk.b 48,0
datach2:  blk.b 48,0
datach3:  blk.b 48,0
datach4:  blk.b 48,0

**
songdata2:  dc.l  0
songdata: dc.l  0
instdata: dc.l  0
arpdata:  dc.l  0
wavedata: dc.l  0
patdata:  dc.l  0
samplestruct: dc.l  0
sampledata: dc.l  0
**
  
org $22000
frequencies:
  org frequencies+2048


***** HIER DE MUGICIAN OBJECTMODULE INLADEN *****
org $26000
muzak:
