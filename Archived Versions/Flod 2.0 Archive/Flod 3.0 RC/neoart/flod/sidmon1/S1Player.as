package neoart.flod.sidmon1 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class S1Player extends AmigaPlayer {
    internal var
      tracksPtr   : Vector.<int>,
      tracks      : Vector.<S1Step>,
      patternsPtr : Vector.<int>,
      patterns    : Vector.<S1Row>,
      samples     : Vector.<S1Sample>,
      waveLists   : Vector.<int>,
      speedDef    : int,
      trackLen    : int,
      patternDef  : int,
      mix1Speed   : int,
      mix2Speed   : int,
      mix1Dest    : int,
      mix2Dest    : int,
      mix1Source1 : int,
      mix1Source2 : int,
      mix2Source1 : int,
      mix2Source2 : int,
      doFilter    : int,
      doReset     : int;
    private var
      voices      : Vector.<S1Data>,
      trackPos    : int,
      trackEnd    : int,
      patternPos  : int,
      patternEnd  : int,
      patternLen  : int,
      mix1Ctr     : int,
      mix2Ctr     : int,
      mix1Pos     : int,
      mix2Pos     : int,
      audPtr      : int,
      audLen      : int,
      audPer      : int,
      audVol      : int;

    private const
      PERIODS : Vector.<int> = Vector.<int>([0,
        5760,5424,5120,4832,4560,4304,4064,3840,3616,
        3424,3232,3048,2880,2712,2560,2416,2280,2152,2032,1920,1808,
        1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,0960,0904,
        0856,0808,0762,0720,0678,0640,0604,0570,0538,0508,0480,0452,
        0428,0404,0381,0360,0339,0320,0302,0285,0269,0254,0240,0226,
        0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,
         0,0,0,0,0,0,0,4028,3806,3584,
        3394,3204,3013,2855,2696,2538,2395,2268,2141,2014,1903,1792,
        1697,1602,1507,1428,1348,1269,1198,1134,1071,1007,0952,0896,
        0849,0801,0754,0714,0674,0635,0599,0567,0536,0504,0476,0448,
        0425,0401,0377,0357,0337,0310,0300,0284,0268,0252,0238,0224,
        0213,0201,0189,0179,0169,0159,0150,0142,0134,
         0,0,0,0,0,0,0,3993,3773,3552,
        3364,3175,2987,2830,2672,2515,2374,2248,2122,1997,1887,1776,
        1682,1588,1494,1415,1336,1258,1187,1124,1061,0999,0944,0888,
        0841,0794,0747,0708,0668,0629,0594,0562,0531,0500,0472,0444,
        0421,0397,0374,0354,0334,0315,0297,0281,0266,0250,0236,0222,
        0211,0199,0187,0177,0167,0158,0149,0141,0133,
         0,0,0,0,0,0,0,3957,3739,3521,
        3334,3147,2960,2804,2648,2493,2353,2228,2103,1979,1870,1761,
        1667,1574,1480,1402,1324,1247,1177,1114,1052,0990,0935,0881,
        0834,0787,0740,0701,0662,0624,0589,0557,0526,0495,0468,0441,
        0417,0394,0370,0351,0331,0312,0295,0279,0263,0248,0234,0221,
        0209,0197,0185,0176,0166,0156,0148,0140,0132,
         0,0,0,0,0,0,0,3921,3705,3489,
        3304,3119,2933,2779,2625,2470,2331,2208,2084,1961,1853,1745,
        1652,1560,1467,1390,1313,1235,1166,1104,1042,0981,0927,0873,
        0826,0780,0734,0695,0657,0618,0583,0552,0521,0491,0464,0437,
        0413,0390,0367,0348,0329,0309,0292,0276,0261,0246,0232,0219,
        0207,0195,0184,0174,0165,0155,0146,0138,0131,
         0,0,0,0,0,0,0,3886,3671,3457,
        3274,3090,2907,2754,2601,2448,2310,2188,2065,1943,1836,1729,
        1637,1545,1454,1377,1301,1224,1155,1094,1033,0972,0918,0865,
        0819,0773,0727,0689,0651,0612,0578,0547,0517,0486,0459,0433,
        0410,0387,0364,0345,0326,0306,0289,0274,0259,0243,0230,0217,
        0205,0194,0182,0173,0163,0153,0145,0137,0130,
         0,0,0,0,0,0,0,3851,3638,3426,
        3244,3062,2880,2729,2577,2426,2289,2168,2047,1926,1819,1713,
        1622,1531,1440,1365,1289,1213,1145,1084,1024,0963,0910,0857,
        0811,0766,0720,0683,0645,0607,0573,0542,0512,0482,0455,0429,
        0406,0383,0360,0342,0323,0304,0287,0271,0256,0241,0228,0215,
        0203,0192,0180,0171,0162,0152,0144,0136,0128,
        6848,6464,6096,5760,5424,5120,4832,4560,4304,4064,3840,
        3616,3424,3232,3048,2880,2712,2560,2416,2280,2152,2032,1920,
        1808,1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,0960,
        0904,0856,0808,0762,0720,0678,0640,0604,0570,0538,0508,0480,
        0452,0428,0404,0381,0360,0339,0320,0302,0285,0269,0254,0240,
        0226,0214,0202,0190,0180,0170,0160,0151,0143,0135,0127]);

    public function S1Player(amiga:Amiga = null) {
      super(amiga);
      PERIODS.fixed = true;

      tracksPtr = new Vector.<int>(4, true);
      voices    = new Vector.<S1Data>(4, true);

      voices[0] = new S1Data();
      voices[1] = new S1Data();
      voices[2] = new S1Data();
      voices[3] = new S1Data();
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      S1Loader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, dst:int, i:int, index:int, row:S1Row, sample:S1Sample, src1:int, src2:int, step:S1Step, value:int, voice:S1Data;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        chan  = amiga.channels[i];
        audPtr = -1;
        audLen = audPer = audVol = 0;

        if (timer == 0) {
          if (patternEnd) {
            if (trackEnd) voice.step = tracksPtr[i];
              else voice.step++;

            step = tracks[voice.step];
            voice.row = patternsPtr[step.pattern];
            if (doReset) voice.noteTimer = 0;
          }

          if (voice.noteTimer == 0) {
            row = patterns[voice.row];

            if (row.sample == 0) {
              if (row.note) {
                voice.noteTimer = row.timer;

                if (voice.waitCtr) {
                  sample = samples[voice.sample];
                  audPtr = sample.pointer;
                  audLen = sample.length;
                  voice.samplePtr = sample.loopPtr;
                  voice.sampleLen = sample.repeat;
                  voice.waitCtr = 1;
                  chan.enabled  = 0;
                }
              }
            } else {
              sample = samples[row.sample];
              if (voice.waitCtr) chan.enabled = voice.waitCtr = 0;

              if (sample.waveform > 15) {
                audPtr = sample.pointer;
                audLen = sample.length;
                voice.samplePtr = sample.loopPtr;
                voice.sampleLen = sample.repeat;
                voice.waitCtr = 1;
              } else {
                voice.wavePos = 0;
                voice.waveList = sample.waveform;
                index = voice.waveList << 4;
                audPtr = waveLists[index] << 5;
                audLen = 32;
                voice.waveTimer = waveLists[++index];
              }
              voice.noteTimer   = row.timer;
              voice.sample      = row.sample;
              voice.envelopeCtr = voice.pitchCtr = voice.pitchFallCtr = 0;
            }

            if (row.note) {
              voice.noteTimer = row.timer;

              if (row.note != 0xff) {
                sample = samples[voice.sample];
                step   = tracks[voice.step];

                voice.note = row.note + step.transpose;
                voice.period = audPer = PERIODS[int(1 + sample.finetune + voice.note)];
                voice.phaseSpeed = sample.phaseSpeed;

                voice.bendSpeed   = voice.volume = 0;
                voice.envelopeCtr = voice.pitchCtr = voice.pitchFallCtr = 0;

                switch (row.data1) {
                  case 0:
                    if (row.data2 == 0) break;
                    sample.attackSpeed = row.data2;
                    sample.attackMax   = row.data2;
                    voice.waveTimer    = 0;
                    break;
                  case 2:
                    speed = row.data2;
                    voice.waveTimer = 0;
                    break;
                  case 3:
                    patternLen = row.data2;
                    voice.waveTimer = 0;
                    break;
                  default:
                    voice.bendTo    = row.data1 + step.transpose;
                    voice.bendSpeed = row.data2;
                    break;
                }
              }
            }
            voice.step++;
          } else
            voice.noteTimer--;
        }

        sample = samples[voice.sample];
        audVol = voice.volume;

        switch (voice.envelopeCtr) {
          case 8:
            break;
          case 0: //attack
            audVol += sample.attackSpeed;
            if (audVol > sample.attackMax) {
              audVol = sample.attackMax;
              voice.envelopeCtr += 2;
            }
            break;
          case 2: //decay
            audVol -= sample.decaySpeed;
            if (audVol <= sample.decayMin || audVol < -256) {
              audVol = sample.decayMin;
              voice.envelopeCtr += 2;
              voice.sustainCtr = sample.sustain;
            }
            break;
          case 4: //sustain
            voice.sustainCtr--;
            if (voice.sustainCtr == 0 || voice.sustainCtr == -256) voice.envelopeCtr += 2;
            break;
          case 6: //release
            audVol -= sample.releaseSpeed;
            if (audVol <= sample.releaseMin || audVol < -256) {
              audVol = sample.releaseMin;
              voice.envelopeCtr = 8;
            }
            break;
        }

        voice.volume = audVol;
        voice.arpeggioCtr = ++voice.arpeggioCtr & 15;
        index = sample.finetune + sample.arpeggio[voice.arpeggioCtr] + voice.note;
        voice.period = audPer = PERIODS[index];

        if (voice.bendSpeed) {
          value = PERIODS[int(sample.finetune + voice.bendTo)];
          index = ~voice.bendSpeed + 1;
          if (index < -128) index &= 255;
          voice.pitchCtr += index;
          voice.period   += voice.pitchCtr;

          if ((index < 0 && voice.period <= value) || (index > 0 && voice.period >= value)) {
            voice.note   = voice.bendTo;
            voice.period = value;
            voice.bendSpeed = 0;
            voice.pitchCtr  = 0;
          }
        }

        if (sample.phaseShift) {
          if (voice.phaseSpeed) {
            voice.phaseSpeed--;
          } else {
            voice.phaseTimer = ++voice.phaseTimer & 31;
            index = (sample.phaseShift << 5) + voice.phaseTimer;
            voice.period += amiga.memory[index] >> 2;
          }
        }

        voice.pitchFallCtr -= sample.pitchFall;
        if (voice.pitchFallCtr < -256) voice.pitchFallCtr += 256;
        voice.period += voice.pitchFallCtr;

        if (voice.waitCtr == 0) {
          if (voice.waveTimer) {
            voice.waveTimer--;
          } else {
            if (voice.wavePos < 16) {
              index = (voice.waveList << 4) + voice.wavePos;
              value = waveLists[index++];

              if (value == 0xff) {
                voice.wavePos = waveLists[index] & 254;
              } else {
                audPtr = value << 5;
                voice.waveTimer = waveLists[index];
                voice.wavePos += 2;
              }
            }
          }
        }
        if (audPtr > -1) chan.pointer = audPtr;
        if (audPer != 0) chan.period  = voice.period;
        if (audLen != 0) chan.length  = audLen;

        if (sample.volume) chan.volume = sample.volume;
          else chan.volume = audVol >> 2;

        chan.enabled = 1;
      }
      trackEnd = patternEnd = 0;

      if (++timer > speed) {
        timer = 0;

        if (++patternPos == patternLen) {
          patternPos = 0;
          patternEnd = 1;
          if (++trackPos == trackLen) trackPos = trackEnd = amiga.complete = 1;
        }
      }

      if (mix1Speed) {
        if (mix1Ctr == 0) {
          mix1Ctr = mix1Speed;
          index   = mix1Pos = ++mix1Pos & 31;
          dst  = (mix1Dest    << 5) + 31;
          src1 = (mix1Source1 << 5) + 31;
          src2 =  mix1Source2 << 5;

          for (i = 31; i > -1; --i) {
            amiga.memory[dst--] = (amiga.memory[src1--] + amiga.memory[int(src2 + index)]) >> 1;
            index = --index & 31;
          }
        }
        mix1Ctr--;
      }

      if (mix2Speed) {
        if (mix2Ctr == 0) {
          mix2Ctr = mix2Speed;
          index   = mix2Pos = ++mix2Pos & 31;
          dst  = (mix2Dest    << 5) + 31;
          src1 = (mix2Source1 << 5) + 31;
          src2 =  mix2Source2 << 5;

          for (i = 31; i > -1; --i) {
            amiga.memory[dst--] = (amiga.memory[src1--] + amiga.memory[int(src2 + index)]) >> 1;
            index = --index & 31;
          }
        }
        mix2Ctr--;
      }

      if (doFilter) {
        index = mix1Pos + 32;
        amiga.memory[index] = ~amiga.memory[index] + 1;
      }

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        chan  = amiga.channels[i];

        if (voice.waitCtr == 1) {
          voice.waitCtr++;
        } else if (voice.waitCtr == 2) {
          voice.waitCtr++;
          chan.pointer = voice.samplePtr;
          chan.length  = voice.sampleLen;
        }
      }
    }

    override protected function initialize():void {
      var chan:AmigaChannel, i:int, step:S1Step, voice:S1Data;
      super.initialize();
      speed      =  speedDef;
      timer      =  speedDef;
      trackPos   =  1;
      trackEnd   =  0;
      patternPos = -1;
      patternEnd =  0;
      patternLen =  patternDef;

      mix1Ctr = mix2Ctr = 0;
      mix1Pos = mix2Pos = 0;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.step   = tracksPtr[i];
        step         = tracks[voice.step];
        voice.row    = patternsPtr[step.pattern];
        voice.sample = patterns[voice.row].sample;

        chan = amiga.channels[i];
        chan.length  = 32;
        chan.period  = voice.period;
        chan.enabled = 1;
      }
    }
  }
}