package neoart.flod.digitalmugician {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class DMPlayer extends AmigaPlayer {
    public static const
      DIGITALMUG_V1 : int = 1,
      DIGITALMUG_V2 : int = 2;

    internal var
      songs       : Vector.<DMSong>,
      patterns    : Vector.<AmigaRow>,
      samples     : Vector.<DMSample>,
      arpeggios   : Vector.<int>,
      buffer1     : int,
      buffer2     : int;
    private var
      voices      : Vector.<DMData>,
      song1       : DMSong,
      song2       : DMSong,
      trackPos    : int,
      patternPos  : int,
      patternLen  : int,
      patternEnd  : int,
      stepEnd     : int,
      numChannels : int,
      averages    : Vector.<int>,
      volumes     : Vector.<int>,
      mixChannel  : AmigaChannel,
      mixPeriod   : int;

    private const
      PERIODS : Vector.<int> = Vector.<int>([
        3220,3040,2869,2708,2556,2412,2277,
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

    public function DMPlayer(amiga:Amiga = null) {
      super(amiga);
      PERIODS.fixed = true;

      songs     = new Vector.<DMSong>(8, true);
      arpeggios = new Vector.<int>(256, true);
      voices    = new Vector.<DMData>(7, true);

      voices[0] = new DMData();
      voices[1] = new DMData();
      voices[2] = new DMData();
      voices[3] = new DMData();
      voices[4] = new DMData();
      voices[5] = new DMData();
      voices[6] = new DMData();
      setup();
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      DMLoader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, dst:int, i:int, idx:int, j:int, len:int, memory:Vector.<int>, r:int, row:AmigaRow, src1:int, src2:int, sample:DMSample, value:int, voice:DMData;
      memory = amiga.memory;

      for (i = 0; i < numChannels; ++i) {
        voice  = voices[i];
        sample = voice.sample;

        if (i < 3 || numChannels == 4) {
          chan = amiga.channels[i];
          if (stepEnd) voice.step = song1.tracks[int(trackPos + i)];

          if (sample.wave > 31) {
            chan.pointer = sample.loopPtr;
            chan.length  = sample.repeat;
          }
        } else {
          chan = mixChannel;
          if (stepEnd) voice.step = song2.tracks[int(trackPos + (i - 3))];
        }

        if (patternEnd) {
          row = patterns[int(voice.step.pattern + patternPos)];

          if (row.note) {
            if (row.data1 != 74) {
              voice.note = row.note;
              if (row.sample) sample = voice.sample = samples[row.sample];
            }
            voice.val1 = row.data1 < 64 ? 1 : row.data1 - 62;
            voice.val2 = row.data2;
            idx = voice.step.transpose + sample.finetune;

            if (voice.val1 != 12) {
              voice.pitch = row.data1;

              if (voice.val1 == 1) {
                idx += voice.pitch;
                if (idx < 0) voice.period = 0;
                  else voice.period = PERIODS[idx];
              }
            } else {
              voice.pitch = row.note;
              idx += voice.pitch;
              if (idx < 0) voice.period = 0;
                else voice.period = PERIODS[idx];
            }
            if (voice.val1 == 11) sample.arpeggio = voice.val2 & 7;

            if (voice.val1 != 12) {
              if (sample.wave > 31) {
                chan.pointer  = sample.pointer;
                chan.length   = sample.length;
                chan.enabled  = 0;
                voice.mixPtr  = sample.pointer;
                voice.mixEnd  = sample.pointer + sample.length;
                voice.mixMute = 0;
              } else {
                dst = sample.wave << 7;
                chan.pointer = dst;
                chan.length  = sample.waveLen;
                if (voice.val1 != 10) chan.enabled = 0;

                if (numChannels == 4) {
                  if (sample.effect != 0 && voice.val1 != 2 && voice.val1 != 4) {
                    len  = dst + 128;
                    src1 = sample.source1 << 7;
                    for (j = dst; j < len; ++j) memory[j] = memory[src1++];

                    sample.effectStep = 0;
                    voice.effectCtr   = sample.effectSpeed;
                  }
                }
              }
            }
            if (voice.val1 != 3 && voice.val1 != 4 && voice.val1 != 12) {
              voice.volumeCtr  = 1;
              voice.volumeStep = 0;
            }

            voice.arpeggioStep = 0;
            voice.pitchCtr     = sample.pitchDelay;
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
            value  = voice.val2 & 15;
            value |= value << 4;
            if (voice.val2 == 0 || voice.val2 > 15) break;
            speed = value;
            break;
          case 7:  //led filter on
            amiga.filter.active = 1;
            break;
          case 8:  //led filter off
            amiga.filter.active = 0;
            break;
          case 13: //shuffle
            voice.val1 = 0;
            value = voice.val2 & 0x0f;
            if (value == 0) break;
            value = voice.val2 & 0xf0;
            if (value == 0) break;
            speed = voice.val2;
            break;
        }
      }

      for (i = 0; i < numChannels; ++i) {
        voice  = voices[i];
        sample = voice.sample;

        if (numChannels == 4) {
          chan = amiga.channels[i];

          if (sample.wave < 32 && sample.effect && !sample.effectDone) {
            sample.effectDone = 1;

            if (voice.effectCtr) {
              voice.effectCtr--;
            } else {
              voice.effectCtr = sample.effectSpeed;
              dst = sample.wave << 7;

              switch (sample.effect) {
                case 1:  //filter
                  for (j = 0; j < 127; ++j) {
                    value  = memory[dst];
                    value += memory[int(dst + 1)];
                    memory[dst++] = value >> 1;
                  }
                  break;
                case 2:  //mixing
                  src1 = sample.source1 << 7;
                  src2 = sample.source2 << 7;
                  idx  = sample.effectStep;
                  len  = sample.waveLen;
                  sample.effectStep = ++sample.effectStep & 127;

                  for (j = 0; j < len; ++j) {
                    value  = memory[src1++];
                    value += memory[int(src2 + idx)];
                    memory[dst++] = value >> 1;
                    idx = ++idx & 127;
                  }
                  break;
                case 3:  //scr left
                  value = memory[dst];
                  for (j = 0; j < 127; ++j) memory[dst] = memory[++dst];
                  memory[dst] = value;
                  break;
                case 4:  //scr right
                  dst += 127;
                  value = memory[dst];
                  for (j = 0; j < 127; ++j) memory[dst] = memory[--dst];
                  memory[dst] = value;
                  break;
                case 5:  //upsample
                  idx = value = dst;
                  for (j = 0; j < 64; ++j) {
                    memory[idx++] = memory[dst++];
                    dst++;
                  }
                  idx = dst = value;
                  idx += 64;
                  for (j = 0; j < 64; ++j) memory[idx++] = memory[dst++];
                  break;
                case 6:  //downsample
                  src1 = dst + 64;
                  dst += 128;
                  for (j = 0; j < 64; ++j) {
                    memory[--dst] = memory[--src1];
                    memory[--dst] = memory[src1];
                  }
                  break;
                case 7:  //negate
                  dst += sample.effectStep;
                  memory[dst] = ~memory[dst] + 1;
                  if (++sample.effectStep >= sample.waveLen) sample.effectStep = 0;
                  break;
                case 8:  //madmix 1
                  sample.effectStep = ++sample.effectStep & 127;
                  src2 = (sample.source2 << 7) + sample.effectStep;
                  idx  = memory[src2];
                  len  = sample.waveLen;
                  value = 3;

                  for (j = 0; j < len; ++j) {
                    src1 = memory[dst] + value;
                    if (src1 < -128) src1 += 256;
                      else if (src1 > 127) src1 -= 256;

                    memory[dst++] = src1;
                    value += idx;

                    if (value < -128) value += 256;
                      else if (value > 127) value -= 256;
                  }
                  break;
                case 9:  //addition
                  src2 = sample.source2 << 7;
                  len  = sample.waveLen;

                  for (j = 0; j < len; ++j) {
                    value  = memory[src2++];
                    value += memory[dst];
                    if (value > 127) value -= 256;
                    memory[dst++] = value;
                  }
                  break;
                case 10: //filter 2
                  for (j = 0; j < 126; ++j) {
                    value  = memory[dst++] * 3;
                    value += memory[int(dst + 1)];
                    memory[dst] = value >> 2;
                  }
                  break;
                case 11: //morphing
                  src1 = sample.source1 << 7;
                  src2 = sample.source2 << 7;
                  len  = sample.waveLen;

                  sample.effectStep = ++sample.effectStep & 127;
                  value = sample.effectStep;
                  if (value >= 64) value = 127 - value;
                  idx = (value ^ 255) & 63;

                  for (j = 0; j < len; ++j) {
                    r  = memory[src1++] * value;
                    r += memory[src2++] * idx;
                    memory[dst++] = r >> 6;
                  }
                  break;
                case 12: //morph f
                  src1 = sample.source1 << 7;
                  src2 = sample.source2 << 7;
                  len  = sample.waveLen;

                  sample.effectStep = ++sample.effectStep & 31;
                  value = sample.effectStep;
                  if (value >= 16) value = 31 - value;
                  idx = (value ^ 255) & 15;

                  for (j = 0; j < len; ++j) {
                    r  = memory[src1++] * value;
                    r += memory[src2++] * idx;
                    memory[dst++] = r >> 4;
                  }
                  break;
                case 13: //filter 3
                  for (j = 0; j < 126; ++j) {
                    value  = memory[dst++];
                    value += memory[int(dst + 1)];
                    memory[dst] = value >> 1;
                  }
                  break;
                case 14: //polygate
                  idx = dst + sample.effectStep;
                  memory[idx] = ~memory[idx] + 1;
                  idx = (sample.effectStep + sample.source2) & (sample.waveLen - 1);
                  idx += dst;
                  memory[idx] = ~memory[idx] + 1;
                  if (++sample.effectStep >= sample.waveLen) sample.effectStep = 0;
                  break;
                case 15: //colgate
                  idx = dst;
                  for (j = 0; j < 127; ++j) {
                    value  = memory[dst];
                    value += memory[int(dst + 1)];
                    memory[dst++] = value >> 1;
                  }
                  dst = idx;
                  sample.effectStep++;

                  if (sample.effectStep == sample.source2) {
                    sample.effectStep = 0;
                    idx = value = dst;

                    for (j = 0; j < 64; ++j) {
                      memory[idx++] = memory[dst++];
                      dst++;
                    }
                    idx = dst = value;
                    idx += 64;
                    for (j = 0; j < 64; ++j) memory[idx++] = memory[dst++];
                  }
                  break;
              }
            }
          }
        } else {
          if (i < 3) chan = amiga.channels[i];
            else chan = mixChannel;
        }

        if (voice.volumeCtr) {
          voice.volumeCtr--;

          if (voice.volumeCtr == 0) {
            voice.volumeCtr  = sample.volumeSpeed;
            voice.volumeStep = ++voice.volumeStep & 127;

            if (voice.volumeStep || sample.volumeLoop) {
              idx = voice.volumeStep + (sample.volume << 7);
              value = ~(memory[idx] + 129) + 1;

              voice.volume = (value & 255) >> 2;
              chan.volume  = voice.volume;
            } else {
              voice.volumeCtr = 0;
            }
          }
        }
        value = voice.note;

        if (sample.arpeggio) {
          idx = voice.arpeggioStep + (sample.arpeggio << 5);
          value += arpeggios[idx];
          voice.arpeggioStep = ++voice.arpeggioStep & 31;
        }

        idx = value + voice.step.transpose + sample.finetune;
        voice.finalPeriod = PERIODS[idx];
        dst = voice.finalPeriod;

        if (voice.val1 == 1 || voice.val1 == 12) {
          value = ~voice.val2 + 1;
          voice.portamento += value;
          voice.finalPeriod += voice.portamento;

          if (voice.val2) {
            if ((value < 0 && voice.finalPeriod <= voice.period) || (value >= 0 && voice.finalPeriod >= voice.period)) {
              voice.portamento = voice.period - dst;
              voice.val2 = 0;
            }
          }
        }

        if (sample.pitch) {
          if (voice.pitchCtr) {
            voice.pitchCtr--;
          } else {
            idx = voice.pitchStep;
            voice.pitchStep = ++voice.pitchStep & 127;
            if (voice.pitchStep == 0) voice.pitchStep = sample.pitchLoop;

            idx += sample.pitch << 7;
            value = memory[idx];
            voice.finalPeriod += (~value + 1);
          }
        }
        chan.period = voice.finalPeriod;
      }

      if (numChannels > 4) {
        src1    = buffer1;
        buffer1 = buffer2;
        buffer2 = src1;

        chan = amiga.channels[3];
        chan.pointer = src1;

        for (i = 3; i < 7; ++i) {
          voice = voices[i];
          voice.mixStep = 0;

          if (voice.finalPeriod < 125) {
            voice.mixMute  = 1;
            voice.mixSpeed = 0;
          } else {
            j = ((voice.finalPeriod << 8) / mixPeriod) & 65535;
            src2 = ((256 / j) & 255) << 8;
            dst  = ((256 % j) << 8) & 16777215;
            voice.mixSpeed = (src2 | ((dst / j) & 255)) << 8;
          }

          if (voice.mixMute) voice.mixVolume = 0;
            else voice.mixVolume = voice.volume << 8;
        }

        for (i = 0; i < 350; ++i) {
          dst = 0;

          for (j = 3; j < 7; ++j) {
            voice = voices[j];
            src2 = (memory[int(voice.mixPtr + (voice.mixStep >> 16))] & 255) + voice.mixVolume;
            dst += volumes[src2];
            voice.mixStep += voice.mixSpeed;
          }
          memory[src1++] = averages[dst];
        }

        chan.length = 350;
        chan.period = mixPeriod;
        chan.volume = 64;
      }

      if (--timer == 0) {
        timer  = speed & 15;
        speed  = (speed & 240) >> 4;
        speed |= (timer << 4);
        patternEnd = 1;
        patternPos++;

        if (patternPos == 64 || patternPos == patternLen) {
          patternPos = 0;
          stepEnd    = 1;
          trackPos  += 4;

          if (trackPos == song1.length) {
            trackPos = song1.loopStep;
            amiga.complete = 1;
          }
        }
      } else {
        patternEnd = 0;
        stepEnd    = 0;
      }

      for (i = 0; i < numChannels; ++i) {
        voice = voices[i];
        voice.mixPtr += voice.mixStep >> 16;

        sample = voice.sample;
        sample.effectDone = 0;

        if (voice.mixPtr >= voice.mixEnd) {
          if (sample.loop) {
            voice.mixPtr -= sample.repeat;
          } else {
            voice.mixPtr  = 0;
            voice.mixMute = 1;
          }
        }

        if (i < 4) {
          chan = amiga.channels[i];
          chan.enabled = 1;
        }
      }
    }

    override protected function initialize():void {
      var chan:AmigaChannel, i:int, len:int, voice:DMData;
      super.initialize();
      if (playSong > 7) playSong = 0;
      song1  = songs[playSong];
      speed  = song1.speed & 0x0f;
      speed |= speed << 4;
      timer  = song1.speed;

      trackPos    = 0;
      patternPos  = 0;
      patternLen  = 64;
      patternEnd  = 1;
      stepEnd     = 1;
      numChannels = 4;

      for (i = 0; i < 7; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.sample = samples[0];

        if (i < 4) {
          chan = amiga.channels[i];
          chan.enabled = 0;
          chan.pointer = amiga.loopPtr;
          chan.length  = 2;
          chan.period  = 124;
          chan.volume  = 0;
        }
      }

      if (version == DIGITALMUG_V2) {
        if ((playSong & 1) != 0) playSong--;
        song2 = songs[int(playSong + 1)];
        mixChannel  = new AmigaChannel(7);
        numChannels = 7;

        chan = amiga.channels[3];
        chan.mute    = 0;
        chan.pointer = buffer1;
        chan.length  = 350;
        chan.period  = mixPeriod;
        chan.volume  = 64;

        len = buffer1 + 700;
        for (i = buffer1; i < len; ++i) amiga.memory[i] = 0;
      }
    }

    private function setup():void {
      var i:int, idx:int, j:int, pos:int, step:int, v1:int, v2:int, vol:int = 128;
      averages  = new Vector.<int>( 1024, true);
      volumes   = new Vector.<int>(16384, true);
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