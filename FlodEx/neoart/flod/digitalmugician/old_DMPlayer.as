package neoart.flod.digitalmugician {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class DMPlayer extends AmigaPlayer {
    public var songNumber:int;

    private var mod:DMModule;
    private var song1:DMSong;
    private var song2:DMSong;
    private var voices:Vector.<DMVoice>;

    private var stepCnt:int;
    private var patternCnt:int;
    private var patternLen:int;
    private var patternEnd:int;
    private var commandEnd:int;
    private var numChannels:int;

    private var averages:Vector.<int>;
    private var volumes:Vector.<int>;
    private var mixPeriod:int;

    private var buffer:int;
    //private var bufferPtr:int;
    //private var bufferLen:int;
    //private var bufferLoop:int;

    private var dummy:AmigaChannel;

    private const PERIODS:Vector.<int> = Vector.<int>([
      /*4825,4554,4299,4057,3830,3615,3412,*/3220,3040,2869,2708,2556,2412,2277,
      2149,2029,1915,1807,1706,1610,1520,1434,1354,1278,1206,1139,1075,1014,
      0957,0904,0853,0805,0760,0717,0677,0639,0603,0569,0537,0507,0479,0452,
      0426,0403,0380,0359,0338,0319,0302,0285,0269,0254,0239,0226,0213,0201,
      0190,0179,0169,0160,0151,0142,0134,0127,
      4842,4571,4314,4072,3843,3628,3424,3232,3051,2879,2718,2565,2421,2285,
      2157,2036,1922,1814,1712,1616,1525,1440,1359,1283,1211,1143,1079,1018,
      0961,0907,0856,0808,0763,0720,0679,0641,0605,0571,0539,0509,0480,0453,
      0428,0404,0381,0360,0340,0321,0303,0286,0270,0254,0240,0227,0214,0202,
      0191,0180,0170,0160,0151,0143,0135,0127,
      4860,4587,4330,4087,3857,3641,3437,3244,3062,2890,2728,2574,2430,2294,
      2165,2043,1929,1820,1718,1622,1531,1445,1364,1287,1215,1147,1082,1022,
      0964,0910,0859,0811,0765,0722,0682,0644,0607,0573,0541,0511,0482,0455,
      0430,0405,0383,0361,0341,0322,0304,0287,0271,0255,0241,0228,0215,0203,
      0191,0181,0170,0161,0152,0143,0135,0128,
      4878,4604,4345,4102,3871,3654,3449,3255,3073,2900,2737,2584,2439,2302,
      2173,2051,1936,1827,1724,1628,1536,1450,1369,1292,1219,1151,1086,1025,
      0968,0914,0862,0814,0768,0725,0684,0646,0610,0575,0543,0513,0484,0457,
      0431,0407,0384,0363,0342,0323,0305,0288,0272,0256,0242,0228,0216,0203,
      0192,0181,0171,0161,0152,0144,0136,0128,
      4895,4620,4361,4116,3885,3667,3461,3267,3084,2911,2747,2593,2448,2310,
      2181,2058,1943,1834,1731,1634,1542,1455,1374,1297,1224,1155,1090,1029,
      0971,0917,0865,0817,0771,0728,0687,0648,0612,0578,0545,0515,0486,0458,
      0433,0408,0385,0364,0343,0324,0306,0289,0273,0257,0243,0229,0216,0204,
      0193,0182,0172,0162,0153,0144,0136,0129,
      4913,4637,4377,4131,3899,3681,3474,3279,3095,2921,2757,2603,2456,2319,
      2188,2066,1950,1840,1737,1639,1547,1461,1379,1301,1228,1159,1094,1033,
      0975,0920,0868,0820,0774,0730,0689,0651,0614,0580,0547,0516,0487,0460,
      0434,0410,0387,0365,0345,0325,0307,0290,0274,0258,0244,0230,0217,0205,
      0193,0183,0172,0163,0154,0145,0137,0129,
      4931,4654,4393,4146,3913,3694,3486,3291,3106,2932,2767,2612,2465,2327,
      2196,2073,1957,1847,1743,1645,1553,1466,1384,1306,1233,1163,1098,1037,
      0978,0923,0872,0823,0777,0733,0692,0653,0616,0582,0549,0518,0489,0462,
      0436,0411,0388,0366,0346,0326,0308,0291,0275,0259,0245,0231,0218,0206,
      0194,0183,0173,0163,0154,0145,0137,0130,
      4948,4671,4409,4161,3928,3707,3499,3303,3117,2942,2777,2621,2474,2335,
      2204,2081,1964,1854,1750,1651,1559,1471,1389,1311,1237,1168,1102,1040,
      0982,0927,0875,0826,0779,0736,0694,0655,0619,0584,0551,0520,0491,0463,
      0437,0413,0390,0368,0347,0328,0309,0292,0276,0260,0245,0232,0219,0206,
      0195,0184,0174,0164,0155,0146,0138,0130,
      4966,4688,4425,4176,3942,3721,3512,3315,3129,2953,2787,2631,2483,2344,
      2212,2088,1971,1860,1756,1657,1564,1477,1394,1315,1242,1172,1106,1044,
      0985,0930,0878,0829,0782,0738,0697,0658,0621,0586,0553,0522,0493,0465,
      0439,0414,0391,0369,0348,0329,0310,0293,0277,0261,0246,0233,0219,0207,
      0196,0185,0174,0164,0155,0146,0138,0131,
      4984,4705,4441,4191,3956,3734,3524,3327,3140,2964,2797,2640,2492,2352,
      2220,2096,1978,1867,1762,1663,1570,1482,1399,1320,1246,1176,1110,1048,
      0989,0934,0881,0832,0785,0741,0699,0660,0623,0588,0555,0524,0495,0467,
      0441,0416,0392,0370,0350,0330,0312,0294,0278,0262,0247,0233,0220,0208,
      0196,0185,0175,0165,0156,0147,0139,0131,
      5002,4722,4457,4206,3970,3748,3537,3339,3151,2974,2807,2650,2501,2361,
      2228,2103,1985,1874,1769,1669,1576,1487,1404,1325,1251,1180,1114,1052,
      0993,0937,0884,0835,0788,0744,0702,0662,0625,0590,0557,0526,0496,0468,
      0442,0417,0394,0372,0351,0331,0313,0295,0279,0263,0248,0234,0221,0209,
      0197,0186,0175,0166,0156,0148,0139,0131,
      5020,4739,4473,4222,3985,3761,3550,3351,3163,2985,2818,2659,2510,2369,
      2236,2111,1992,1881,1775,1675,1581,1493,1409,1330,1255,1185,1118,1055,
      0996,0940,0887,0838,0791,0746,0704,0665,0628,0592,0559,0528,0498,0470,
      0444,0419,0395,0373,0352,0332,0314,0296,0280,0264,0249,0235,0222,0209,
      0198,0187,0176,0166,0157,0148,0140,0132,
      5039,4756,4489,4237,3999,3775,3563,3363,3174,2996,2828,2669,2519,2378,
      2244,2118,2000,1887,1781,1681,1587,1498,1414,1335,1260,1189,1122,1059,
      1000,0944,0891,0841,0794,0749,0707,0667,0630,0594,0561,0530,0500,0472,
      0445,0420,0397,0374,0353,0334,0315,0297,0281,0265,0250,0236,0223,0210,
      0198,0187,0177,0167,0157,0149,0140,0132,
      5057,4773,4505,4252,4014,3788,3576,3375,3186,3007,2838,2679,2528,2387,
      2253,2126,2007,1894,1788,1688,1593,1503,1419,1339,1264,1193,1126,1063,
      1003,0947,0894,0844,0796,0752,0710,0670,0632,0597,0563,0532,0502,0474,
      0447,0422,0398,0376,0355,0335,0316,0298,0282,0266,0251,0237,0223,0211,
      0199,0188,0177,0167,0158,0149,0141,0133,
      5075,4790,4521,4268,4028,3802,3589,3387,3197,3018,2848,2688,2538,2395,
      2261,2134,2014,1901,1794,1694,1599,1509,1424,1344,1269,1198,1130,1067,
      1007,0951,0897,0847,0799,0754,0712,0672,0634,0599,0565,0533,0504,0475,
      0449,0423,0400,0377,0356,0336,0317,0299,0283,0267,0252,0238,0224,0212,
      0200,0189,0178,0168,0159,0150,0141,0133,
      5093,4808,4538,4283,4043,3816,3602,3399,3209,3029,2859,2698,2547,2404,
      2269,2142,2021,1908,1801,1700,1604,1514,1429,1349,1273,1202,1134,1071,
      1011,0954,0900,0850,0802,0757,0715,0675,0637,0601,0567,0535,0505,0477,
      0450,0425,0401,0379,0357,0337,0318,0300,0284,0268,0253,0238,0225,0212,
      0201,0189,0179,0169,0159,0150,0142,0134]);

    public function DMPlayer() {
      setup();
    }

    override public function load(stream:ByteArray):int {
      mod = new DMModule();
      supported = mod.initialize(stream, amiga);
      return supported;
    }

    override protected function initialize():void {
      var chan:AmigaChannel, i:int, len:int, voice:DMVoice;
      amiga.initialize();

      song1  = mod.songs[songNumber];
      speed  = song1.speed & 15;
      speed |= speed << 4;
      timer  = song1.speed;

      stepCnt     = 0;
      patternCnt  = 0;
      patternLen  = 64;
      patternEnd  = 1;
      commandEnd  = 1;
      complete    = 0;
      numChannels = 3;

      for (i = 0; i < 7; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.sample = mod.samples[0];

        if (i < 4) {
          chan = amiga.channels[i];
          chan.enabled = 0;
          chan.pointer = mod.loopPtr;
          chan.length  = 2;
          chan.period  = 124;
          chan.volume  = 0;
        }
      }

      if (supported == 2) {
        song2 = mod.songs[int(songNumber + 1)];
        dummy = new AmigaChannel(7);
        numChannels = 7;

        chan = amiga.channels[3];
        chan.mute    = 0;
        chan.pointer = mod.buffer1;
        chan.length  = 350;
        chan.period  = mixPeriod;
        chan.volume  = 64;

        len = mod.buffer1 + 350;
        for (i = mod.buffer1; i < len; ++i) amiga.samples[i] = 0;
      }
    }

    override protected function process():void {
      var chan:AmigaChannel, com:DMCommand, dst:int, i:int, idx:int, j:int, len:int, src1:int, src2:int, sample:DMSample, song:DMSong, step:DMStep, value:int, tables:Vector.<int>, voice:DMVoice;
      tables = amiga.samples;

      for (i = 2; i < numChannels; ++i) {
        if (numChannels > 4 && i > 2) {
          song = song2;
          chan = dummy;
        } else {
          song = song1;
          chan = amiga.channels[i];
        }
        voice  = voices[i];
        sample = voice.sample;

        if (sample.wave > 31) {
          if (numChannels == 4 || (numChannels > 4 && i < 2)) {
            chan.pointer = sample.loopPtr;
            chan.length  = sample.repeatLen;
          }
        }

        if (numChannels > 4 && i > 2) {
          if (patternEnd) voice.step = song.tracks[int(stepCnt + (i - 3))];
        } else {
          if (patternEnd) voice.step = song.tracks[int(stepCnt + i)];
        }
        step = voice.step;

        if (commandEnd) {
          com = mod.patterns[int(step.pattern + patternCnt)];

          if (com.note) {
            if (com.val1 != 74) {
              voice.note = com.note;

              if (com.sample) {
                voice.sample = mod.samples[com.sample];
                sample = voice.sample;
              }
            }

            voice.val1 = com.val1 < 64 ? 1 : com.val1 - 62;
            voice.val2 = com.val2;
            idx = step.transpose + sample.finetune;

            if (voice.val1 != 12) {
              voice.pitch = com.val1;

              if (voice.val1 == 1) {
                idx += voice.pitch;
                if (idx >= 0) voice.period = PERIODS[idx];
                  else voice.period = 0;
              }
            } else {
              voice.pitch = com.note;
              idx += voice.pitch;
              if (idx >= 0) voice.period = PERIODS[idx];
                else voice.period = 0;
            }

            if (voice.val1 == 11) sample.arpeggio = voice.val2 & 7;

            if (voice.val1 != 12) {
              if (sample.wave > 31) {
                chan.pointer = sample.pointer;
                chan.length  = sample.length;
                chan.enabled = 0;
                voice.mixPtr  = sample.pointer;
                voice.mixEnd = sample.pointer + sample.length;
                voice.mixMute = 0;
                //if (i == 5) voice.mixMute = 0; else voice.mixMute = 1;
              } else {
                dst = sample.wave << 7;
                chan.pointer = dst;
                chan.length  = sample.waveLen;
                if (voice.val1 != 10) chan.enabled = 0;

                if (sample.effect != 0 && voice.val1 != 2 && voice.val1 != 4 && numChannels == 4) {
                  len  = dst + 128;
                  src1 = sample.source1 << 7;
                  for (j = dst; j < len; ++j) tables[j] = tables[src1++];
                  sample.effectStep = 0;
                  voice.effectCnt = sample.effectSpeed;
                }
              }
            }

            if (voice.val1 != 3 && voice.val1 != 4 && voice.val1 != 12) {
              voice.volumeCnt  = 1;
              voice.volumeStep = 0;
            }

            voice.arpeggioStep = 0;
            voice.pitchCnt     = sample.pitchDelay;
            voice.pitchStep    = 0;
            voice.portamento   = 0;
          }
        }

        switch (voice.val1) {
          case 0:
            break;
          case 5:  //pattern length
            value = voice.val2;
            if (value > 0 && value < 65) patternLen = value;
            break;
          case 6:  //song speed
            value = voice.val2 & 15;
            value |= value << 4;
            if (value == 0 || value > 15) break;
            speed = value;
            break;
          case 7:  //led filter on
            //amiga.filter.active = 1;
            break;
          case 8:  //led filter off
            //amiga.filter.active = 0;
            break;
          case 13: //shuffle
            voice.val1 = 0;
            value = voice.val2 & 15;
            if (value == 0) break;
            value = voice.val2 & 240;
            id (value == 0) break;
            speed = voice.val2;
            break;
        }
      }

      for (i = 2; i < numChannels; ++i) {
        if (numChannels > 4 && i > 2) chan = dummy;
          else chan = amiga.channels[i];

        voice  = voices[i];
        sample = voice.sample;

        //if (voice.val1 == 0) amiga.filter.active ^= 1;

      if (numChannels == 4) {
        if (sample.wave < 32 && sample.effect) {
          if (!sample.effectDone) {
            sample.effectDone = 1;

            if (voice.effectCnt) {
              voice.effectCnt--;
            } else {
              voice.effectCnt = sample.effectSpeed;
              dst = sample.wave << 7;
//trace(sample.effect, i, sample.wave, sample.source2);
              switch (sample.effect) {
                case 1:  //filter
                  for (j = 0; j < 127; ++j) {
                    value  = tables[dst];
                    value += tables[int(dst + 1)];
                    tables[dst++] = value >> 1;
                  }
                  break;
                case 2:  //mixing
                  src1 = sample.source1 << 7;
                  src2 = sample.source2 << 7;
                  idx  = sample.effectStep;
                  len  = sample.waveLen;
                  sample.effectStep = ++sample.effectStep & 127;

                  for (j = 0; j < len; ++j) {
                    value  = tables[src1++];
                    value += tables[int(src2 + idx)];
                    tables[dst++] = value >> 1;
                    idx = ++idx & 127;
                  }
                  break;
                case 3:  //scr left
                  value = tables[dst];
                  for (j = 0; j < 127; ++j) tables[dst] = tables[++dst];
                  tables[dst] = value;
                  break;
                case 4:  //scr right
                  dst += 127;
                  value = tables[dst];
                  for (j = 0; j < 127; ++j) tables[dst] = tables[--dst];
                  tables[dst] = value;
                  break;
                case 5:  //upsample
                  idx = value = dst;
                  for (j = 0; j < 64; ++j) {
                    tables[idx++] = tables[dst++];
                    idx++;
                  }
                  idx = dst = value;
                  for (j = 0; j < 64; ++j) tables[idx++] = tables[dst++];
                  break;
                case 6:  //downsample
                  src1 = dst + 64;
                  dst += 128;
                  for (j = 0; j < 64; ++j) {
                    tables[--dst] = tables[--src1];
                    tables[--dst] = tables[src1];
                  }
                  break;
                case 7:  //negate
                  dst += sample.effectStep;
                  tables[dst] = ~tables[dst] + 1;
                  if (++sample.effectStep >= sample.waveLen) sample.effectStep = 0;
                  break;
                case 8:  //madmix 1
                  sample.effectStep = ++sample.effectStep & 127;
                  src2 = (sample.source2 << 7) + sample.effectStep;
                  len  = sample.waveLen;
                  idx  = tables[src2];
                  value = 3;
//var pop:String = "";
                  for (j = 0; j < len; ++j) {
                    tables[dst] += value;
                    if (tables[dst] < -128) tables[dst] += 256;
                      else if (tables[dst] > 127) tables[dst] -= 256;
//var p:int = tables[dst];
//if (p < 0) p += 256;
//if (p < 16) pop += "0";
//pop += p.toString(16);
                    dst++;
                    value += idx;
                    if (value < -128) value += 256;
                      else if (value > 127) value -= 256;
                  }
//trace(pop);
                  break;
                case 9:  //addition
                  src2 = sample.source2 << 7;
                  len  = sample.waveLen;
                  for (j = 0; j < len; ++j) {
                    value  = tables[src2++];
                    value += tables[dst];
                    if (value > 127) value -= 256;
                    tables[dst++] = value;
                  }
                  break;
                case 10: //filter 2
                  for (j = 0; j < 126; ++j) {
                    value  = tables[dst++] * 3;
                    value += tables[int(dst + 1)];
                    tables[dst] = value >> 2;
                  }
                  break;
                case 11: //morphing
                  break;
                case 12: //morph f
                  break;
                case 13: //filter 3
                  for (j = 0; j < 126; ++j) {
                    value  = tables[dst++];
                    value += tables[int(dst + 1)];
                    tables[dst] = value >> 1;
                  }
                  break;
                case 14: //polygate
                  idx = sample.effectStep + sample.source2;
                  tables[dst] = ~tables[dst] + 1;
                  len = sample.waveLen - 1;
                  idx &= len;
                  tables[idx] = ~tables[idx] + 1;
                  if (++sample.effectStep >= sample.waveLen) sample.effectStep = 0;
                  break;
                case 15: //colgate
                  idx = dst;
                  for (j = 0; j < 127; ++j) {
                    value  = tables[dst];
                    value += tables[int(dst + 1)];
                    tables[dst++] = value >> 1;
                  }
                  dst = idx;
                  sample.effectStep++;
                  if (sample.effectStep == sample.source2) {
                    sample.effectStep = 0;
                    idx = value = dst;
                    for (j = 0; j < 64; ++j) {
                      tables[idx++] = tables[dst++];
                      idx++;
                    }
                    idx = dst = value;
                    for (j = 0; j < 64; ++j) tables[idx++] = tables[dst++];
                  }
                  break;
              }
            }
          }
        }
      }

        if (voice.volumeCnt) {
          voice.volumeCnt--;

          if (voice.volumeCnt == 0) {
            voice.volumeCnt = sample.volumeSpeed;
            voice.volumeStep = ++voice.volumeStep & 127;

            if (voice.volumeStep || sample.volumeLoop) {
              idx = voice.volumeStep + (sample.volume << 7);
              value = ~(tables[idx] + 129) + 1;

              voice.volume = (value & 255) >> 2;
              chan.volume  = voice.volume;
            } else {
              voice.volumeCnt = 0;
            }
          }
        }

		value = voice.note;

        if (sample.arpeggio) {
          idx = voice.arpeggioStep + (sample.arpeggio << 5);
          value += mod.arpeggios[idx];
          voice.arpeggioStep = ++voice.arpeggioStep & 31;
        }// else {
        //  value = voice.note;
        //}

        idx = value + voice.step.transpose + sample.finetune;
        voice.finalPeriod = PERIODS[idx];
        dst = voice.finalPeriod;

        if (voice.val1 == 1 || voice.val1 == 12) {
          value = ~voice.val2 + 1;
          voice.portamento += value;
          voice.finalPeriod += voice.portamento;

          if (voice.val2) {
            if (value < 0) {
              if (voice.finalPeriod <= voice.period) {
                voice.portamento = voice.period - dst;
                voice.val2 = 0;
              }
            } else {
              if (voice.finalPeriod >= voice.period) {
                voice.portamento = voice.period - dst;
                voice.val2 = 0;
              }
            }
          }
        }

        if (sample.pitch) {
          if (voice.pitchCnt) {
            voice.pitchCnt--;
          } else {
            idx = voice.pitchStep;
            voice.pitchStep = ++voice.pitchStep & 127;
            if (voice.pitchStep == 0) voice.pitchStep = sample.pitchLoop;

            idx += sample.pitch << 7;
            value = tables[idx];
            voice.finalPeriod += (~value + 1);
          }
        }

        chan.period = voice.finalPeriod;
        trace(chan.period.toString(16));
      }

      if (numChannels > 4) mixer4();

      if (--timer == 0) {
        timer = speed & 15;
        commandEnd = 1;
        patternCnt++;

        if (patternCnt == 64 || patternCnt == patternLen) {
          patternCnt = 0;
          patternEnd = 1;

          if ((stepCnt += 4) == song.length) {
            stepCnt = 0;
            //???
          }
        }
      } else {
        patternEnd = commandEnd = 0;
      }

      for (i = 2; i < numChannels; ++i) {
        if (numChannels > 4 && i > 3) chan = dummy;
          else chan = amiga.channels[i];

        sample = voices[i].sample;
        chan.enabled = 1;
        sample.effectDone = 0;
      }
    }

    private function mixer4():void {
      var chan:AmigaChannel, i:int, j:int, r:int, sample:DMSample, tables:Vector.<int>, v1:int, v2:int, voice:DMVoice;

      buffer = mod.buffer1;
      mod.buffer1 = mod.buffer2;
      mod.buffer2 = buffer;

      chan = amiga.channels[3];
      chan.pointer = buffer;

      for (i = 3; i < 4; ++i) {
        voice = voices[i];
        voice.mixStep = 0;

        if (voice.finalPeriod < 125) {
          voice.mixMute   = 1;
          voice.mixSpeed  = 0;
          //voice.mixVolume = 0;
        } else {
          r = ((voice.finalPeriod << 8) / mixPeriod) & 65535;
          v1 = ((256 / r) & 255) << 8;
          v2 = ((256 % r) << 8) & 16777215;
          voice.mixSpeed = (v1 | ((v2 / r) & 255)) << 8;
/*
          r = ((voice.finalPeriod << 8) / mixPeriod) & 65535;
          v1 = 256 / r;
          v2 = 256 % r;
          v2 = (v2 << 8) & 16777215;
          r = ((v1 & 255) << 8) | ((v2 / r) & 255);
          voice.mixSpeed  = r << 8;
          //voice.mixVolume = voice.mixMute == 0 ? voice.volume << 8 : 0;
*/
        }

        if (voice.mixMute) voice.mixVolume = 0;
          else voice.mixVolume = voice.volume << 8;
      }

      tables = amiga.samples;

      for (i = 0; i < 350; ++i) {
        r = 0;

        for (j = 3; j < 7; ++j) {
          voice = voices[j];
          v1 = (tables[int(voice.mixPtr + (voice.mixStep >> 16))] & 255) + voice.mixVolume;
          r += volumes[v1];
          voice.mixStep += voice.mixSpeed;
        }
/*
        for (j = 3; j < 7; ++j) {
          voice = voices[j];
          if ((voice.mixPtr + (voice.mixStep >> 16)) >= voice.mixLen) {
            v1 = 0;
          } else {
            v1 = tables[int(voice.mixPtr + (voice.mixStep >> 16))] & 255;
            //if (v1 < 0) v1 += 256;
            v1 += voice.mixVolume;
          }
          //r += volumes[int(v1 + voice.mixVolume)];
          r += volumes[v1];
          //voice.mixStep = ((voice.mixStep & 65535) << 16) | (voice.mixStep >> 16);
          voice.mixStep += voice.mixSpeed;
          //voice.mixStep = ((voice.mixStep & 65535) << 16) | (voice.mixStep >> 16);
        }
*/
        tables[buffer++] = averages[r];
      }

      for (i = 3; i < 7; ++i) {
        voice  = voices[i];
        sample = voice.sample;
        //voice.mixPtr += voice.mixStep & 65535;
        voice.mixPtr += voice.mixStep >> 16;

        if (voice.mixPtr >= voice.mixEnd) {
          if (sample.loopStart) {
            voice.mixPtr -= sample.loopStart;
            //voice.mixEnd = sample.loopPtr + sample.repeatLen;
          } else {
            voice.mixMute = 1;
          }
        }
      }
/*
      var pop:String = "";
      for (i = 0; i < 350; ++i) {
      var p:int = tables[int(mod.buffer2 + i)];
      if (p < 0) p += 256;
      if (p < 16) pop += "0";
      pop += p.toString(16);
      }
      pop+="\n\n";
      trace("B1:",pop);
      pop = "";
/*
      for (i = 0; i < 350; ++i) {
      p = tables[int(mod.buffer1 + i)];
      if (p < 0) p += 256;
      if (p < 16) pop += "0";
      pop += p.toString(16);
      }
      pop+="\n\n";
      trace("B2:",pop);
*/
      chan.length = 350;
      chan.period = mixPeriod;
      chan.volume = 64;
    }

    private function setup():void {
      var i:int, idx:int, j:int, pos:int, step:int, v1:int, v2:int, vol:int = 128;
      PERIODS.fixed = true;

      voices = new Vector.<DMVoice>(7, true);
      voices[0] = new DMVoice();
      voices[1] = new DMVoice();
      voices[2] = new DMVoice();
      voices[3] = new DMVoice();
      voices[4] = new DMVoice();
      voices[5] = new DMVoice();
      voices[6] = new DMVoice();

      averages = new Vector.<int>( 1024, true);
      volumes  = new Vector.<int>(16384, true);
      mixPeriod = 203;

      for (i = 0; i < 1024; ++i) {
        if (vol > 127) vol -= 256;
        averages[i] = vol;
        if (i > 383 && i < 639) vol = ++vol & 255;
      }

      for (i = 0; i < 64; ++i) {
        v1 = -128;
        v2 =  128;

        for (j = 0; j < 256; ++j) {
          vol = ((v1 * step) / 63) + 128;
          idx = pos + v2;
          volumes[idx] = vol & 255;

          if (i != 0 && i != 63 && v2 >= 128) --volumes[idx];
          v1++;
          v2 = ++v2 & 255;
        }

        pos += 256;
        step++;
      }
    }
  }
}