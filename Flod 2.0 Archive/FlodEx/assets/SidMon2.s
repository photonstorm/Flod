  section player,data_c

start:
  move.l  4,a6
  jsr     -132(a6)
  bsr     initmuzak
sync:
  cmp.b   #128,$dff006
  bne.s   sync
  bsr     playmuzak
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


initmuzak:
  movem.l d0-d7/a0-a6,-(a7)                 ;store registers
  bset    #1,$bfe001                        ;turn off led filter
  lea     $dff000,a6                        ;registers base address
  move.w  #0,$a8(a6)                        ;reset channel 1 volume
  move.w  #0,$b8(a6)                        ;reset channel 2 volume
  move.w  #0,$c8(a6)                        ;reset channel 3 volume
  move.w  #0,$d8(a6)                        ;reset channel 4 volume
  move.w  #$000f,$96(a6)                    ;disable all channels dma
  moveq   #0,d6                             ;clear register
  lea     header(pc),a0                     ;header in a0
  lea     midimode(pc),a2                   ;midimode in a2
  moveq   #$3a,d0                           ;header text offset in d0
  add.l   -6(a2),d0                         ;add module base pointer
  move.l  d0,(a0)                           ;store in header
  move.l  -6(a2),a1                         ;module base pointer in a1
  move.w  (a1)+,(a2)+                       ;store midimode
  move.b  (a1)+,d6                          ;song length in d6
  move.b  d6,(a2)                           ;store song length in length
  move.b  (a1)+,1(a2)                       ;store song speed in speed
  move.w  (a1)+,d0                          ;number of waveforms (samples) in d0
  lsr.w   #6,d0                             ;divide by 64
  subq.w  #1,d0                             ;decrease number of samples (start from 0)
  move.w  d0,-4(a2)                         ;store number of waveforms in sampleno
  moveq   #64,d0                            ;64 in d0
  move.l  d0,2(a2)                          ;store 64 in patlength
  clr.b   6(a2)                             ;reset currentrast2
  moveq   #10,d0                            ;loop counter
addloop:
  move.l  (a0)+,d1                          ;songlen var pointer in d1
  add.l   (a1)+,d1                          ;add following lengths to d1 address
  move.l  d1,(a0)                           ;store result in the right var
  dbf     d0,addloop                        ;loop
  move.l  a2,a0                             ;length pointer in a0
  lea     voice1(pc),a2                     ;voice1 in a2
  moveq   #3,d7                             ;loop counter
  addq.w  #1,d6                             ;increase length
  moveq   #0,d5                             ;clear d5
findloop:
  clr.w   72(a2)                            ;reset current waveform
  move.l  d5,(a2)                           ;reset position and transposes offset
  add.l   d6,d5                             ;length + 1 in d5
  bsr     findnote                          ;gosub findnote
  lea     voice2-voice1(a2),a2              ;pointer to next voice structure
  dbf     d7,findloop                       ;loop
  moveq   #0,d0                             ;clear d0
  move.l  patterns(pc),a0                   ;patterns in a0
  move.w  -(a0),d0                          ;get last pattern length from pattern pointers table
  add.l   patterns(pc),d0                   ;add patterns address
  move.l  d0,a1                             ;result address in a1
  lea     voice1(pc),a2                     ;voice1 in a2
  moveq   #63,d3                            ;loop counter
plus:
  bsr     getnote2                          ;gosub getnote2
  dbf     d3,plus                           ;loop
  clr.w   68(a2)                            ;reset empty notes counter
  move.l  a1,d0                             ;waveforms (samples) start address in d0
  addq.l  #1,d0                             ;increase address
  bclr    #0,d0                             ;be sure the start address is even
  move.l  d0,a0                             ;result address in a0
  move.l  sampletab(pc),a1                  ;sampletab in a1 (pointer to first sample header)
  move.w  sampleno(pc),d0                   ;sampleno in d0 (loop counter)
calcaddloop:
  move.l  a0,(a1)                           ;store waveform data address in sample header
  moveq   #0,d1                             ;clear d1
  move.w  4(a1),d1                          ;sample length in d1 (in words)
  add.l   d1,d1                             ;multiply by 2 (in byte)
  add.l   d1,a0                             ;add length to start address
  lea     64(a1),a1                         ;offset to next sample header
  dbf     d0,calcaddloop                    ;loop
  movem.l (a7)+,d0-d7/a0-a6                 ;restore registers
  rts                                       ;return

header:         dc.l 0
songlen:        dc.l 0
positions:      dc.l 0
ntransposes:    dc.l 0
itransposes:    dc.l 0
ins1:           dc.l 0
wavelists:      dc.l 0
arpeggiolists:  dc.l 0
vibratolists:   dc.l 0
sampletab:      dc.l 0
patternpointer: dc.l 0
patterns:       dc.l 0

playmuzak:
  movem.l d0-d7/a0-a6,-(a7)                 ;store registers
  lea     $dff000,a6                        ;amiga registers base address
  lea     length(pc),a0                     ;length in a0
  addq.b  #1,6(a0)                          ;increase currentrast2
  cmp.b   #3,6(a0)                          ;compare currentrast2
  bne.s   notthree                          ;if != 3 goto notthree
  clr.b   6(a0)                             ;reset currentrast2
notthree:
  addq.b  #1,4(a0)                          ;increase currentrast
  move.b  4(a0),d0                          ;currentrast in d0
  cmp.b   1(a0),d0                          ;compare currentrast
  blt     doeffects                         ;if < speed goto do effects
  clr.b   4(a0)                             ;reset currentrast
  clr.b   6(a0)                             ;reset currentrast2
  lea     dma(pc),a5                        ;dma in a5
  clr.w   (a5)                              ;reset dma
  lea     voice1(pc),a2                     ;voice1 in a2
  bsr     getnote                           ;gosub getnote
  lea     voice2(pc),a2                     ;voice2 in a2
  bsr     getnote                           ;gosub getnote
  lea     voice3(pc),a2                     ;voice3 in a2
  bsr     getnote                           ;gosub getnote
  lea     voice4(pc),a2                     ;voice4 in a2
  bsr     getnote                           ;gosub getnote
  move.w  (a5),$96(a6)                      ;disable channel(s) dma
  add.w   #$8000,(a5)                       ;set clr/set dma bit
  lea     voice1(pc),a2                     ;voice1 in a2
  bsr     playvoice                         ;gosub playvoice
  ;lea     voice2(pc),a2                     ;voice2 in a2
  ;bsr     playvoice                         ;gosub playvoice
  ;lea     voice3(pc),a2                     ;voice3 in a2
  ;bsr     playvoice                         ;gosub playvoice
  ;lea     voice4(pc),a2                     ;voice4 in a2
  ;bsr     playvoice                         ;gosub playvoice
  bsr     donegation                        ;gosub donegation
  move.b  6(a6),d0                          ;vhpos beam value in d0
raster:
  cmp.b   6(a6),d0                          ;compare beam position
  beq.s   raster                            ;if == loop
  move.w  (a5),$96(a6)                      ;enabled channel(s) dma
  move.b  6(a6),d0                          ;vhpos beam value in d0
raster2:
  cmp.b   6(a6),d0                          ;compare beam position
  beq.s   raster2                           ;if == loop
  lea     voice1(pc),a2                     ;voice1 in a2
  moveq   #3,d0                             ;loop counter
repeatloop:
  move.w  16(a2),d4                         ;channel register offset in d4
  move.l  26(a2),(a6,d4.w)                  ;set amiga channel pointer to current voice repeat start
  move.w  30(a2),4(a6,d4.w)                 ;set amiga channel length to current voice repeat length
  lea     voice2-voice1(a2),a2              ;point to next voice structure
  dbf     d0,repeatloop                     ;loop
  addq.b  #1,3(a0)                          ;increase currentnot
  move.b  5(a0),d0                          ;patlength in d0
  cmp.b   3(a0),d0                          ;compare currentnot
  bne.s   doeffects                         ;if != patlength goto doeffects
  clr.b   3(a0)                             ;reset currentnot
  move.b  (a0),d0                           ;length in d0
  cmp.b   2(a0),d0                          ;compare length
  bne.s   addlater                          ;if != currentpos goto addlater
  move.b  #-1,2(a0)                         ;set currentpos to -1
addlater:
  addq.b  #1,2(a0)                          ;increase currentpos
  lea     voice1(pc),a2                     ;voice1 in a2
  bsr     findnote                          ;gosub findnote
  lea     voice2(pc),a2                     ;voice2 in a2
  bsr     findnote                          ;gosub findnote
  lea     voice3(pc),a2                     ;voice3 in a2
  bsr     findnote                          ;gosub findnote
  lea     voice4(pc),a2                     ;voice4 in a2
  bsr     findnote                          ;gosub findnote
doeffects:
  lea     voice1(pc),a2                     ;voice1 in a2
  bsr     doeffect                          ;gosub doeffect
  lea     voice2(pc),a2                     ;voice2 in a2
  bsr     doeffect                          ;gosub doeffect
  lea     voice3(pc),a2                     ;voice3 in a2
  bsr     doeffect                          ;gosub doeffect
  lea     voice4(pc),a2                     ;voice4 in a2
  bsr     doeffect                          ;gosub doeffect
  tst.b   4(a0)                             ;test currentrast
  beq.s   nonega                            ;if 0 goto nonega
  bsr.s   donegation                        ;else gosub donegation
nonega:
  movem.l (a7)+,d0-d7/a0-a6                 ;restore registers
  rts                                       ;return

donegation:
  movem.l d0-d4/a0-a3,-(a7)                 ;store registers
  lea     waveadds(pc),a3                   ;waveadds in a3
  lea     voice1(pc),a1                     ;voice1 in a1
  moveq   #3,d0                             ;loop counter
negationloop:
  move.w  72(a1),d1                         ;current waveform (sample) in d1
  lsl.w   #6,d1                             ;multiply by 64
  move.l  sampletab(pc),a0                  ;sampletab in a0
  lea     (a0,d1.w),a0                      ;add waveform offset
  move.l  a0,(a3)+                          ;store address in waveadds
  tst.w   26(a0)                            ;test neg switch
  bne.s   nonegation                        ;if != 0 goto nonegation
  not.w   26(a0)                            ;logical not on neg switch
  tst.w   24(a0)                            ;test neg counter
  beq.s   checknegation                     ;if 0 goto checknegation
  subq.w  #1,24(a0)                         ;else decrease neg counter
  and.w   #31,24(a0)                        ;& 31 neg counter (value must be between 0-31)
  bra.s   nonegation                        ;goto nonegation
checknegation:
  move.w  14(a0),24(a0)                     ;copy neg speed in neg counter
  move.w  16(a0),d4                         ;neg direction in d4
  beq.s   nonegation                        ;if 0 goto nonegation
  move.l  (a0),a2                           ;sample data start address in a2
  moveq   #0,d1                             ;clear d1
  moveq   #0,d2                             ;clear d2
  move.w  10(a0),d1                         ;neg start offset in d1
  move.w  12(a0),d2                         ;neg length in d2
  add.l   d1,d1                             ;multiply by 2
  add.l   d2,d2                             ;multiply by 2
  subq.l  #1,d2                             ;decrease length in bytes
  add.l   d1,a2                             ;add neg start offset to sample address
  add.l   20(a0),a2                         ;add neg step to sample address
  not.b   (a2)                              ;logical not on sample value
  moveq   #0,d3                             ;clear d3
  move.w  18(a0),d3                         ;neg offset in d3
  ext.l   d3                                ;extend word to longword
  add.l   d3,20(a0)                         ;add value to neg step
  tst.l   20(a0)                            ;test neg step
  bmi.s   noright                           ;if negative goto noright
  cmp.l   20(a0),d2                         ;compare neg step
  bhs.s   nonegation                        ;if neg length - 1 >= neg step goto nonegation
checkmode:
  cmp.w   #1,d4                             ;compare neg direction
  bne.s   noleft                            ;if != 1 goto noleft
  clr.l   20(a0)                            ;reset neg step
  bra.s   nonegation                        ;goto nonegation
noright:
  cmp.w   #2,d4                             ;compare neg direction
  bne.s   noleft                            ;if != 2 goto noleft
  move.l  d2,20(a0)                         ;store neg length (in bytes - 1) in neg step
  bra.s   nonegation                        ;goto nonegation
noleft:
  neg.l   d3                                ;negate offset (going left = negative)
  add.l   d3,20(a0)                         ;add neg offset to neg step
  neg.w   18(a0)                            ;negate offset
nonegation:
  lea     voice2-voice1(a1),a1              ;next voice pointer
  dbf     d0,negationloop                   ;loop
  sub.w   #16,a3                            ;back to waveadds start address
  moveq   #3,d0                             ;loop counter
joho:
  move.l  (a3)+,a0                          ;waveadds in a0
  clr.w   26(a0)                            ;reset neg switch
  dbf     d0,joho                           ;loop
  movem.l (a7)+,d0-d4/a0-a3                 ;restore registers
  rts                                       ;return

findnote:
  moveq   #0,d0                             ;clear d0
  moveq   #0,d1                             ;clear d1
  moveq   #0,d2                             ;clear d2
  move.b  2(a0),d0                          ;currentpos in d0
  move.l  positions(pc),a1                  ;positions in a1
  add.l   (a2),a1                           ;add current voice position offset
  move.b  (a1,d0.w),d2                      ;get position
  add.w   d2,d2                             ;multiply by 2
  move.l  patternpointer(pc),a1             ;patternpointer in a1
  move.w  (a1,d2.w),d2                      ;add position offset
  add.l   patterns(pc),d2                   ;add patterns address
  move.l  d2,64(a2)                         ;store in current voice note address
  move.l  ntransposes(pc),a1                ;ntranspose in a1
  add.l   (a2),a1                           ;add current voice position offset
  move.b  (a1,d0.w),71(a2)                  ;store in current voice note transpose
  move.l  itransposes(pc),a1                ;itranspose in a1
  add.l   (a2),a1                           ;add current voice position offset
  move.b  (a1,d0.w),57(a2)                  ;store in current voice instrument transpose
  clr.b   69(a2)                            ;reset current voice empty notes counter
  rts                                       ;return

getnote:
  move.l  64(a2),a1                         ;current voice note address in a1
  bsr.s   getnote2                          ;gosub getnote2
  move.l  a1,64(a2)                         ;store next note address in current voice
  move.w  46(a2),d0                         ;current note in d0
  beq.s   noteok                            ;if 0 goto noteok
  move.w  14(a2),d1                         ;else dma bit in d1
  add.w   d1,(a5)                           ;add dma bit to temp dma
  add.b   71(a2),d0                         ;add note transpose to current note
  move.w  d0,46(a2)                         ;store result in current note
noteok:
  rts                                       ;return

getnote2:
  moveq   #0,d1                             ;clear d1
  move.l  d1,46(a2)                         ;reset current voice current note
  move.l  d1,50(a2)                         ;reset current voice current fx
  tst.b   69(a2)                            ;test current voice empty notes counter
  beq.s   readnote                          ;if 0 goto readnote
  subq.b  #1,69(a2)                         ;else decrease empty notes counter
  rts                                       ;return

readnote:
  move.b  (a1)+,d1                          ;get value
  beq.s   nonotebutslide                    ;if 0 goto nonotebutslide
  bpl.s   simplenote                        ;if positive goto simplenote
negativvalue:
  not.b   d1                                ;~current value
  move.b  d1,69(a2)                         ;store result in current voice empty notes counter
  rts                                       ;return

simplenote:
  cmp.b   #112,d1                           ;compare value
  blt.s   simplenote2                       ;if < 112 goto simplenote2
  move.b  d1,51(a2)                         ;else value is fx store in current voice current fx
  move.b  (a1)+,53(a2)                      ;store fx-info in current voice
  rts                                       ;return

simplenote2:
  move.b  d1,47(a2)                         ;store value in current voice current note
  move.b  (a1)+,d1                          ;get fx value
  bmi.s   negativvalue                      ;if negative goto negativvalue
  cmp.b   #112,d1                           ;compare fx
  blt.s   simpleins                         ;if < 112 goto simpleins
  move.b  d1,51(a2)                         ;else store fx in current voice current fx
  move.b  (a1)+,53(a2)                      ;store fx-info in current voice
  rts                                       ;return

simpleins:
  move.b  d1,49(a2)                         ;value is an instrument, store in current voice current instrument
  move.b  (a1)+,d1                          ;get fx
  bmi.s   negativvalue                      ;if negative goto negativvalue
  move.b  d1,51(a2)                         ;else store fx in current voice current fx
  move.b  (a1)+,53(a2)                      ;store fx-info in current voice
  rts                                       ;return

nonotebutslide:
  move.b  (a1)+,51(a2)                      ;store fx in current voice current fx
  move.b  (a1)+,53(a2)                      ;store fx-info in current voice
  rts                                       ;return

playvoice:
  clr.w   58(a2)                            ;reset pitchbend value
  move.w  46(a2),d0                         ;current note in d0
  beq     nonote                            ;if 0 goto nonote
  clr.w   12(a2)                            ;reset sample volume
  clr.l   34(a2)                            ;reset wavelist delay
  clr.w   38(a2)                            ;reset arpeggio delay
  clr.l   40(a2)                            ;reset arpeggio offset
  clr.w   44(a2)                            ;reset vibrato offset
  clr.w   54(a2)                            ;reset pitchbend counter
  clr.w   62(a2)                            ;reset note-slide speed
  move.w  #4,18(a2)                         ;set adsr status to 4
  clr.w   20(a2)                            ;reset sustain counter
  moveq   #0,d1                             ;clear d1
  move.w  48(a2),d1                         ;current instrument in d1
  beq.s   noinschange                       ;if 0 goto noinschange
  subq.b  #1,d1                             ;decrease sample number
  add.b   57(a2),d1                         ;add instrument transpose
  lsl.w   #5,d1                             ;multiply by 32
  move.l  ins1(pc),a1                       ;get instrument headers offset
  add.l   d1,a1                             ;add current instrument offset
  move.l  a1,22(a2)                         ;store instrument pointer
  moveq   #0,d5                             ;clear d5
  move.b  (a1),d5                           ;instrument waveform list in d5
  lsl.w   #4,d5                             ;multiply by 16
  move.l  wavelists(pc),a1                  ;get waveform lists offset
  add.l   d5,a1                             ;add current waveform list offset
  moveq   #0,d5                             ;clear d5
  move.b  (a1),d5                           ;get waveform number
  move.b  d5,73(a2)                         ;store in current waveform
  lsl.w   #6,d5                             ;multiply by 64
  move.l  sampletab(pc),a1                  ;sampletab in a1
  add.l   d5,a1                             ;add current waveform offset
  move.l  (a1)+,4(a2)                       ;store sample start
  move.w  (a1)+,8(a2)                       ;store sample length (in words)
  move.l  4(a2),26(a2)                      ;store repeat start
  moveq   #0,d5                             ;clear d5
  move.w  (a1)+,d5                          ;get repeat offset (in words)
  add.l   d5,d5                             ;multiply by 2
  add.l   d5,26(a2)                         ;add repeat offset to repeat start
  move.w  (a1),30(a2)                       ;store repeat length
noinschange:
  move.l  22(a2),a1                         ;instrument address in a1
  moveq   #0,d5                             ;clear d5
  move.b  4(a1),d5                          ;get arpeggio list number
  lsl.w   #4,d5                             ;multiply by 16
  move.l  arpeggiolists(pc),a1              ;arpeggio lists offset in a1
  moveq   #0,d1                             ;clear d1
  move.b  (a1,d5.w),d1                      ;get arpeggio value (base + offset)
  ext.w   d1                                ;extend byte to word
  add.w   d1,d0                             ;add arpeggio value to current note
  move.w  d0,32(a2)                         ;store in original note
  lea     playperiods(pc),a3                ;periods table in a3
  add.w   d0,d0                             ;multiply note value by 2
  move.w  16(a2),d4                         ;channel register offset in d4
  move.w  (a3,d0.w),10(a2)                  ;store period in sample period
  move.l  4(a2),(a6,d4.w)                   ;set amiga channel pointer
  move.w  8(a2),4(a6,d4.w)                  ;set amiga channel length
  move.w  10(a2),6(a6,d4.w)                 ;set amiga channel period
nonote:
  rts                                       ;return

doeffect:
  move.w  16(a2),d4                         ;channel register in d4
  bsr     doadsrcurve                       ;gosub doadsrcurve
  bsr     dowaveform                        ;gosub dowaveform
  bsr     doarpeggio                        ;gosub doarpeggio
  bsr.s   dosoundtracker                    ;gosub dosoundtracker
  bsr     dovibrato                         ;gosub dovibrato
  bsr.s   dopitchbend                       ;gosub dopitchbend
  bsr     donoteslide                       ;gosub donoteslide
  move.w  58(a2),d0                         ;pitchbend value in d0
  add.w   d0,10(a2)                         ;add pitchbend value to sample period
  cmp.w   #95,10(a2)                        ;compare period
  bgt.s   notlow                            ;if > 95 goto notlow
  move.w  #95,10(a2)                        ;else store 95 in sample period
  move.w  10(a2),6(a6,d4.w)                 ;set amiga channel period
  rts

notlow:
  cmp.w   #5760,10(a2)                      ;compare period
  blt.s   pitchok                           ;if < 5760 goto pitchok
  move.w  #5760,10(a2)                      ;else store 5760 in sample period
pitchok:
  move.w  10(a2),6(a6,d4.w)                 ;set amiga channel period
  rts                                       ;return




;effects starts here

dopitchbend:
  move.l  22(a2),a4                         ;instrument address in a4
  moveq   #0,d0                             ;clear d0
  move.b  12(a4),d0                         ;get instrument pitchbend value
  beq.s   nopitch                           ;if 0 goto nopitch
  move.b  13(a4),d1                         ;get instrument pitchbend delay
  cmp.b   55(a2),d1                         ;compare to voice pitchbend counter
  bne.s   pitchdelay                        ;i != goto pitchdelay
  ext.w   d0                                ;extend byte to word
  add.w   d0,58(a2)                         ;add pitchbend value to voice pitchbend
nopitch:
  rts                                       ;return

pitchdelay:
  addq.b  #1,55(a2)                         ;increase voice pitchbend counter
  rts                                       ;return

dosoundtracker:
  move.w  50(a2),d0                         ;current fx in d0
  cmp.w   #112,d0                           ;compare fx
  blt.s   noarp                             ;if < 112 goto noarp
  and.w   #15,d0                            ;lower nibble
  tst.b   4(a0)                             ;test currentrast
  bne.s   egal                              ;if != 0 goto egal
  cmp.b   #5,d0                             ;compare fx
  blt.s   noarp                             ;if < 5 goto noarp
egal:
  add.w   d0,d0                             ;multiply fx by 2
  lea     steffect(pc),a1                   ;steffect in a1
  move.w  (a1,d0.w),d0                      ;get function offset in d0
  lea     arpeggio(pc),a1                   ;arpeggio in a1
  jmp     (a1,d0.w)                         ;jump to function
noarp:
  rts                                       ;return

steffect:
  dc.w  arpeggio-arpeggio
  dc.w  pitchup-arpeggio
  dc.w  pitchdown-arpeggio
  dc.w  volumeup-arpeggio
  dc.w  volumedown-arpeggio
  dc.w  setadsrattack-arpeggio
  dc.w  setpatternlen-arpeggio
  dc.w  novolchange-arpeggio
  dc.w  novolchange-arpeggio
  dc.w  novolchange-arpeggio
  dc.w  novolchange-arpeggio
  dc.w  novolchange-arpeggio
  dc.w  volumechange-arpeggio
  dc.w  novolchange-arpeggio
  dc.w  novolchange-arpeggio
  dc.w  speedchange-arpeggio

donoteslide:
  move.w  50(a2),d0                         ;current fx in d0
  beq.s   nodestnote                        ;if 0 goto nodestnote
  cmp.w   #112,d0                           ;compare fx
  bge.s   nodestnote                        ;if >= 112 goto nodestnote
  move.w  52(a2),d1                         ;current fx-info in d1
  beq.s   nodestnote                        ;if 0 goto nodestnote

  add.b   71(a2),d0                         ;only available in the
  andi.b  #$ff,d0                           ;internal replay routine

  add.w   d0,d0                             ;multiply fx by 2
  lea     playperiods(pc),a1                ;periods table in a1
  move.w  (a1,d0.w),60(a2)                  ;store slide to note in current voice
  move.w  60(a2),d0                         ;slide to note in d0
  sub.w   10(a2),d0                         ;subtract current voice sample period
  beq.s   noslider                          ;if 0 goto noslider
  bpl.s   itshigher                         ;if positive goto itshigher
  neg.w   d1                                ;negate current fx-info
itshigher:
  move.w  d1,62(a2)                         ;store fx-info in current voice note-slide speed
nodestnote:
  move.w  62(a2),d1                         ;note-slide speed in d1
  beq.s   noslider                          ;if 0 goto noslider
  bmi.s   downwithit                        ;if negative goto downwithit
  add.w   d1,10(a2)                         ;add fx-info to voice sample period
  move.w  10(a2),d0                         ;result in d0
  cmp.w   60(a2),d0                         ;compare to current voice slide to note
  blt.s   noslider                          ;if < goto noslider
  clr.w   62(a2)                            ;reset current voice note-slide speed
  move.w  60(a2),10(a2)                     ;copy slide to note to sample period
  rts                                       ;return

downwithit:
  add.w   d1,10(a2)                         ;add fx-info to voice sample period
  move.w  10(a2),d0                         ;result in d0
  cmp.w   60(a2),d0                         ;compare to current voice slide to note
  bgt.s   noslider                          ;if > goto noslider
  clr.w   62(a2)                            ;reset current voice note-slide speed
  move.w  60(a2),10(a2)                     ;copy slide to note to sample period
noslider:
  rts                                       ;return

arpeggio:
  lea     myatab(pc),a1                     ;myatab in a1
  move.w  52(a2),d0                         ;current fx-info
  move.b  d0,2(a1)                          ;store d0 in myatab
  and.b   #15,2(a1)                         ;lower nibble in 2(myatab)
  lsr.w   #4,d0                             ;higher nibble
  move.b  d0,(a1)                           ;store in 0(myatab)
  move.b  6(a0),d0                          ;currentrast2 in d0
  move.b  (a1,d0.w),d0                      ;get arpeggio value from d0 offset
  add.w   32(a2),d0                         ;add current voice original note
  add.w   d0,d0                             ;multiply by 2
  lea     playperiods(pc),a1                ;periods table in a1
  move.w  (a1,d0.w),d0                      ;found period in d0
  move.w  d0,10(a2)                         ;store in current voice sample period
  rts                                       ;return

myatab: dc.l 0

pitchup:
  move.w  52(a2),d0                         ;current voice fx-info in d0
  neg.w   d0                                ;negate d0
  move.w  d0,58(a2)                         ;result in current voice pitchbend value
  rts                                       ;return

pitchdown:
  move.w  52(a2),d0                         ;current voice fx-info in d0
  move.w  d0,58(a2)                         ;fx-info in current voice pitchbend value
  rts                                       ;return

volumeup:
  tst.w   18(a2)                            ;test current voice adsr status
  bne.s   novolchange                       ;if != 0 goto novolchange
  tst.b   4(a0)                             ;test currentrast
  bne.s   noinsset                          ;if != 0 goto noinsset
  tst.w   48(a2)                            ;test current voice current instrument
  beq.s   noinsset                          ;if 0 goto noinsset
  move.l  22(a2),a4                         ;instrument address in a4
  move.b  17(a4),13(a2)                     ;store attack volume in current voice
noinsset:
  move.w  52(a2),d1                         ;current fx-info in d1
  add.w   d1,d1                             ;multiply by 2
  add.w   d1,d1                             ;multiply by 2
  move.w  12(a2),d0                         ;current voice sample volume in d0
  add.w   d1,d0                             ;add result in d0
  cmp.w   #256,d0                           ;compare value
  blt.s   not256                            ;if < 256 goto not256
  moveq   #0,d0                             ;clear d0
  not.b   d0                                ;not 0 = -1 in d0
not256:
  move.w  d0,12(a2)                         ;store result in current voice sample volume
  rts                                       ;return

volumedown:
  tst.w   18(a2)                            ;test current voice adsr status
  bne.s   novolchange                       ;if != 0 goto novolchange
  tst.b   4(a0)                             ;test currentrast
  bne.s   noinsset2                         ;if != 0 goto noinsset2
  tst.w   48(a2)                            ;test current voice current instrument
  beq.s   noinsset2                         ;if 0 goto noinsset2
  move.l  22(a2),a4                         ;instrument address in a4
  move.b  17(a4),13(a2)                     ;store attack volume in current voice
noinsset2:
  move.w  52(a2),d1                         ;current fx-info in d1
  add.w   d1,d1                             ;multiply by 2
  add.w   d1,d1                             ;multiply by 2
  move.w  12(a2),d0                         ;current voice sample volume in d0
  sub.w   d1,d0                             ;decrease volume
  bpl.s   not00                             ;if position goto not00
  clr.w   d0                                ;clear d0
not00:
  move.w  d0,12(a2)                         ;store result in current voice sample volume
novolchange:
  rts                                       ;return

setadsrattack:
  move.l  22(a2),a4                         ;current voice instrument address in a4
  move.w  52(a2),d0                         ;current voice fx-info in d0
  move.b  d0,16(a4)                         ;store fx-info in instrument attack volume
  move.b  d0,17(a4)                         ;store fx-info in instrument attack speed
  rts                                       ;return

setpatternlen:
  move.b  53(a2),5(a0)                      ;store fx-info in patlength
  rts                                       ;return

;setmidivelocity:                           ;this effect is present only
;  move.l  22(a2),a4                        ;in the tracker replay routine
;  move.b  53(a2),15(a4)                    ;not in the external routine
;  rts

volumechange:
  move.w  52(a2),d0                         ;current voice fx-info in d0
  move.w  d0,8(a6,d4.w)                     ;set amiga channel volume
  add.w   d0,d0                             ;multiply by 2
  add.w   d0,d0                             ;multiply by 2
  cmp.w   #255,d0                           ;compare result
  blt.s   not255                            ;if < 255 goto not255
  move.w  #255,d0                           ;else 255 in d0
not255:
  move.w  d0,12(a2)                         ;store d0 in current voice volume
  rts

speedchange:
  move.b  53(a2),d0                         ;current voice fx-info in d0
  and.b   #15,d0                            ;lower nibble
  beq.s   novolchange                       ;if 0 goto novolchange
  move.b  d0,1(a0)                          ;store result in speed
  rts                                       ;return

dovibrato:
  move.l  22(a2),a4                         ;current voice instrument address in a4
  tst.b   9(a4)                             ;test instrument vibratolist length
  beq.s   long03                            ;if 0 goto long03
  move.b  11(a4),d6                         ;instrument vibratolist delay in d6
  cmp.b   43(a2),d6                         ;compare current voice vibrato delay counter
  beq.s   novdelay                          ;if delay counter == vibratolist delay goto novdelay
  addq.b  #1,43(a2)                         ;else increase delay counter
long03:
  rts                                       ;return

novdelay:
  move.b  10(a4),d7                         ;instrument vibratolist speed in d7
  sub.b   d7,d6                             ;subtract vibratolist speed to vibratolist delay
  move.b  d6,43(a2)                         ;store result in current voice vibrato delay counter
  move.b  9(a4),d6                          ;instrument vibratolist length in d6
  cmp.b   45(a2),d6                         ;compare current voice vibrato offset
  bne.s   notvsame                          ;if vibrato offset != length goto notvsame
  move.b  #-1,45(a2)                        ;else store -1 in current voice vibrato offset
notvsame:
  addq.b  #1,45(a2)                         ;increase current voice vibrato offset
  clr.w   d7                                ;clear d7
  move.w  44(a2),d6                         ;vibrato offset in d6
  move.b  8(a4),d7                          ;instrument vibratolist number in d7
  lsl.w   #4,d7                             ;multiply by 16
  add.w   d6,d7                             ;add vibrato offset
  move.l  vibratolists(pc),a4               ;vibratolists base address in a4
  move.b  (a4,d7.w),d6                      ;new vibratolist number in d6
  ext.w   d6                                ;extend byte to word
  add.w   d6,10(a2)                         ;add result to current voice period
  rts                                       ;return

doarpeggio:
  move.l  22(a2),a4                         ;current voice instrument address in a4
  tst.b   5(a4)                             ;test instrument arpeggiolist length
  beq.s   long02                            ;if 0 goto long02
  move.b  7(a4),d6                          ;instrument arpeggiolist delay in d6
  cmp.b   39(a2),d6                         ;compare current voice arpeggio delay counter
  beq.s   noadelay                          ;if delay counter == arpeggiolist delay goto noadelay
  addq.b  #1,39(a2)                         ;else increase delay counter
long02:
  rts                                       ;return

noadelay:
  move.b  6(a4),d7                          ;instrument arpeggiolist speed in d7
  sub.b   d7,d6                             ;subtract arpeggiolist speed to arpeggiolist delay
  move.b  d6,39(a2)                         ;store result in current voice arpeggio delay counter
  clr.w   d6                                ;clear d6
  move.b  5(a4),d6                          ;instrument arpeggiolist length in d6
  cmp.b   41(a2),d6                         ;compare current voice arpeggio offset
  bne.s   notasame                          ;if arpeggio offset != length goto notasame
  move.b  #-1,41(a2)                        ;else store -1 in current voice arpeggio offset
notasame:
  addq.b  #1,41(a2)                         ;increase current voice arpeggio offset
  move.w  40(a2),d6                         ;arpeggio offset in d6
  clr.w   d7                                ;clear d7
  move.b  4(a4),d7                          ;instrument arpeggiolist number in d7
  lsl.w   #4,d7                             ;multiply by 16
  add.w   d6,d7                             ;add arpeggio offset
  move.l  arpeggiolists(pc),a4              ;arpeggiolists base address in a4
  move.b  (a4,d7.w),d6                      ;new arpeggiolist number in d6
  ext.w   d6                                ;extend byte to word
  add.w   32(a2),d6                         ;add current voice original note
  lea     playperiods(pc),a4                ;periods table in a4
  add.w   d6,d6                             ;multiply by 2
  move.w  (a4,d6.w),10(a2)                  ;store new period in current voice period
  rts                                       ;return

dowaveform:
  move.l  22(a2),a4                         ;current voice instrument address in a4
  tst.b   1(a4)                             ;test instrument wavelist length
  beq.s   long0                             ;if 0 goto long0
  move.b  3(a4),d6                          ;instrument wavelist delay in d6
  cmp.b   35(a2),d6                         ;compare current voice wavelist delay counter
  beq.s   nowdelay                          ;if delay counter == wavelist delay goto nowdelay
  addq.b  #1,35(a2)                         ;else increase delay counter
long0:
  rts                                       ;return

nowdelay:
  move.b  2(a4),d7                          ;instrument wavelist speed in d7
  sub.b   d7,d6                             ;subtract wavelist speed to wavelist delay
  move.b  d6,35(a2)                         ;store result in current voice wavelist delay counter
  move.b  1(a4),d6                          ;instrument wavelist length in d6
  cmp.b   37(a2),d6                         ;compare current voice wavelist offset
  bne.s   notsame                           ;if wavelist offset != length goto notsame
  move.b  #-1,37(a2)                        ;else store -1 in current voice wavelist offset
notsame:
  addq.b  #1,37(a2)                         ;increase current voice wavelist offset
  move.w  36(a2),d6                         ;wavelist offset in d6
  clr.w   d7                                ;clear d7
  move.b  (a4),d7                           ;instrument wavelist number in d7
  lsl.w   #4,d7                             ;multiply by 16
  add.w   d6,d7                             ;add wavelist offset
  moveq   #0,d6                             ;clear d6
  move.l  wavelists(pc),a4                  ;wavelists base address in a4
  move.b  (a4,d7.w),d6                      ;new wavelist number in d6
  bpl.s   allwaveok                         ;if positive goto allwaveok
  subq.b  #1,37(a2)                         ;else decrease current voice wavelist offset
  rts                                       ;return

allwaveok:
  move.b  d6,73(a2)                         ;store new number in current voice current waveform
  lsl.w   #6,d6                             ;multiply by 64
  move.l  sampletab(pc),a4                  ;sampletab base address in a4
  add.l   d6,a4                             ;add sample offset
  move.l  (a4)+,26(a2)                      ;store sample pointer in current voice repeat start
  move.w  (a4),30(a2)                       ;store sample length in current voice repeat length
  move.l  26(a2),(a6,d4.w)                  ;set amiga channel pointer
  move.w  30(a2),4(a6,d4.w)                 ;set amiga channel length
  rts                                       ;return

doadsrcurve:
  bsr.s   doadsrcalc                        ;goto doadsrcalc
  move.w  12(a2),d0                         ;current voice volume in d0
  lsr.w   #2,d0                             ;divide by 4
  move.w  d0,8(a6,d4.w)                     ;set amiga channel volume
  rts

doadsrcalc:
  move.l  22(a2),a4                         ;current voice instrument address in a4
  lea     16(a4),a4                         ;offset to instrument attack volume
  tst.w   18(a2)                            ;test current voice adsr status
  beq.s   noadsr                            ;if 0 goto noadsr
  clr.w   d6                                ;clear d6
  clr.w   d7                                ;clear d7
  cmp.w   #4,18(a2)                         ;compare adsr status
  beq.s   attack                            ;if 4 goto attack
  cmp.w   #3,18(a2)                         ;compare adsr status
  beq.s   decay                             ;id 3 goto decay
  cmp.w   #2,18(a2)                         ;compare adsr status
  beq.s   sustain                           ;if 2 goto sustain
  cmp.w   #1,18(a2)                         ;compare adsr status
  beq.s   release                           ;if 1 goto release
noadsr:
  rts                                       ;return

attack:
  move.b  (a4),d6                           ;instrument attack volume in d6
  move.b  1(a4),d7                          ;instrument attack speed in d7
  add.w   d7,12(a2)                         ;add attack speed to current voice volume
  cmp.w   12(a2),d6                         ;compare current voice volume
  bgt.s   returnadsr                        ;if attack volume > current voice volume goto returnadsr
  move.w  d6,12(a2)                         ;else store attack volume in current voice volume
  subq.w  #1,18(a2)                         ;decrease adsr status
  rts

decay:
  move.b  2(a4),d6                          ;instrument decay volume in d6
  move.b  3(a4),d7                          ;instrument decay speed in d7
  beq.s   nodecay                           ;if speed == 0 goto nodecay
  sub.w   d7,12(a2)                         ;subtract decay speed to current voice volume
  cmp.w   12(a2),d6                         ;compare current voice volume
  blt.s   returnadsr                        ;if decay volume < current voice volume goto returnadsr
  move.w  d6,12(a2)                         ;else store decay volume in current voice volume
nodecay:
  subq.w  #1,18(a2)                         ;decrease adsr status
  rts

sustain:
  move.b  4(a4),d6                          ;instrument sustain time in d6
  cmp.w   20(a2),d6                         ;compare current voice sustain counter
  bne.s   contsustain                       ;if != sustain time goto contsustain
  subq.w  #1,18(a2)                         ;else decrease adsr status
  rts                                       ;return

release:
  move.b  5(a4),d6                          ;instrument release volume in d6
  move.b  6(a4),d7                          ;instrument release speed in d7
  beq.s   norelease                         ;if speed == 0 goto norelease
  sub.w   d7,12(a2)                         ;subtract release speed to current voice volume
  cmp.w   12(a2),d6                         ;compare current voice volume
  blt.s   returnadsr                        ;if release volume < current voice volume goto returnadsr
  move.w  d6,12(a2)                         ;else store release volume in current voice volume
norelease:
  subq.w  #1,18(a2)                         ;decrease adsr status
returnadsr:
  rts                                       ;return

contsustain:
  addq.w  #1,20(a2)                         ;increase current voice sustain counter
  rts                                       ;return


dma: dc.w 0

voice1:
  dc.w 0,0,0,0,0,0,0,1,$a0,0,0,0,0
  dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0
  dc.w 0,0,0,0,0,0,0,0,0,0,0,0
voice2:
  dc.w 0,0,0,0,0,0,0,2,$b0,0,0,0,0
  dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0
  dc.w 0,0,0,0,0,0,0,0,0,0,0,0
voice3:
  dc.w 0,0,0,0,0,0,0,4,$c0,0,0,0,0
  dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0
  dc.w 0,0,0,0,0,0,0,0,0,0,0,0
voice4:
  dc.w 0,0,0,0,0,0,0,8,$d0,0,0,0,0
  dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0
  dc.w 0,0,0,0,0,0,0,0,0,0,0,0

playperiods:
  dc.w $0
  dc.w $1680,$1530,$1400,$12e0,$11d0,$10d0,$fe0,$f00,$e20,$d60,$ca0,$be8
  dc.w $0b40,$0a98,$0a00,$0970,$08e8,$0868,$7f0,$780,$710,$6b0,$650,$5f4
  dc.w $05a0,$054c,$0500,$04b8,$0474,$0434,$3f8,$3c0,$388,$358,$328,$2fa
  dc.w $02d0,$02a6,$0280,$025c,$023a,$021a,$1fc,$1e0,$1c5,$1ac,$194,$17d
  dc.w $0168,$0153,$0140,$012e,$011d,$010d,$0fe,$0f0,$0e2,$0d6,$0ca,$0be
  dc.w $00b4,$00aa,$00a0,$0097,$008f,$0087,$07f,$078,$071,$06b,$065,$05f

waveadds: ds.l 4

song:         dc.l module
sampleno:     dc.w 0
midimode:     dc.w 0
length:       dc.b 0
speed:        dc.b 0
currentpos:   dc.b 0
currentnot:   dc.b 0
currentrast:  dc.b 0
patlength:    dc.b 0
currentrast2: dc.b 0

module: incbin "module.sid2"