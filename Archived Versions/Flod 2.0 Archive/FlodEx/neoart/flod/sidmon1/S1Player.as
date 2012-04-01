/* Flod SidMon1 Replay 1.01
   2009/12/30
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.sidmon1 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class S1Player extends AmigaPlayer {
    public var song:S1Song;

    private var voices:Vector.<S1Voice>;
    private var curStep:int;
    private var stepEnd:int;
    private var curPattern:int;
    private var patternEnd:int;
    private var patternLen:int;

    private var audPtr:int;
    private var audLen:int;
    private var audPer:int;
    private var audVol:int;
    private var mix1Speed:int;
    private var mix2Speed:int;
    private var mix1Step:int;
    private var mix2Step:int;

    private const PERIODS:Vector.<int> = Vector.<int>([0,
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

    public function S1Player() {
      PERIODS.fixed = true;
      voices    = new Vector.<S1Voice>(4, true);
      voices[0] = new S1Voice();
      voices[1] = new S1Voice();
      voices[2] = new S1Voice();
      voices[3] = new S1Voice();
    }

    override public function load(stream:ByteArray):int {
      song = new S1Song();
      supported = song.initialize(stream, amiga);
      return supported;
    }

    override protected function initialize():void {
      var chan:AmigaChannel, i:int, step:S1Step, voice:S1Voice;
      amiga.initialize();

      speed = timer = song.speed;
      complete      = 0;
      curStep       = 1;
      stepEnd       = 0;
      curPattern    = -1;
      patternEnd    = 0;
      patternLen    = song.patternLen;

      mix1Speed = mix2Speed = 0;
      mix1Step  = mix2Step  = 0;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.step    = song.stepsPtr[i];
        step          = song.steps[voice.step];
        voice.pattern = song.patternsPtr[step.pattern];
        voice.sample  = song.patterns[voice.pattern].sample;

        chan = amiga.channels[i];
        chan.length  = 32;
        chan.period  = voice.period;
        chan.enabled = 1;
      }
    }

    override protected function process():void {
      var c:int, chan:AmigaChannel, com:S1Command, d:int, i:int, s1:int, s2:int, sample:S1Sample, step:S1Step, voice:S1Voice;

      for (i = 0; i < 4; ++i) {
        chan   = amiga.channels[i];
        voice  = voices[i];
        audPtr = -1;
        audLen = audPer = audVol = 0;

        if (timer == 0) {
          if (patternEnd) {
            if (stepEnd) voice.step = song.stepsPtr[i];
              else voice.step++;

            step = song.steps[voice.step];
            voice.pattern = song.patternsPtr[step.pattern];
            if (song.doReset) voice.noteTimer = 0;
          }

          if (voice.noteTimer == 0) {
            com = song.patterns[voice.pattern];

            if (com.sample == 0) {
              if (com.note) {
                voice.noteTimer = com.timer;

                if (voice.waitCnt) {
                  sample = song.samples[voice.sample];
                  audPtr = sample.pointer;
                  audLen = sample.length;
                  voice.samplePtr = sample.loopPtr;
                  voice.sampleLen = sample.repeatLen;
                  voice.waitCnt   = 1;
                  chan.enabled    = 0;
                }
              }
            } else {
              sample = song.samples[com.sample];
              if (voice.waitCnt) chan.enabled = voice.waitCnt = 0;

              if (sample.waveform > 15) {
                audPtr = sample.pointer;
                audLen = sample.length;
                voice.samplePtr = sample.loopPtr;
                voice.sampleLen = sample.repeatLen;
                voice.waitCnt   = 1;
              } else {
                voice.waveStep = 0;
                voice.waveList = sample.waveform;
                d = voice.waveList << 4;
                audPtr = song.waveLists[d] << 5;
                audLen = 32;
                voice.waveTimer = song.waveLists[++d];
              }

              voice.noteTimer = com.timer;
              voice.sample    = com.sample;

              voice.envelopeCnt = voice.pitchCnt = voice.pitchfallCnt = 0;
            }

            if (com.note) {
              voice.noteTimer = com.timer;

              if (com.note != 0xff) {
                sample = song.samples[voice.sample];
                step   = song.steps[voice.step];

                voice.note = com.note + step.transpose;
                voice.period = audPer = PERIODS[int(1 + sample.finetune + voice.note)];
                voice.phaseSpeed = sample.phaseSpeed;

                voice.bendSpeed   = voice.volume = 0;
                voice.envelopeCnt = voice.pitchCnt = voice.pitchfallCnt = 0;

                switch (com.info) {
                  case 0:
                    if (com.data == 0) break;
                    sample.attackSpeed = com.data;
                    sample.attackMax   = com.data;
                    voice.waveTimer = 0;
                    break;
                  case 2:
                    speed = com.data;
                    voice.waveTimer = 0;
                    break;
                  case 3:
                    patternLen = com.data;
                    voice.waveTimer = 0;
                    break;
                  default:
                    voice.bendTo    = com.info + step.transpose;
                    voice.bendSpeed = com.data;
                    break;
                }
              }
            }

            voice.pattern++;
          } else {
            voice.noteTimer--;
          }
        }

        sample = song.samples[voice.sample];
        audVol = voice.volume;

        switch (voice.envelopeCnt) {
          case 8:
            break;
          case 0:
            audVol += sample.attackSpeed;
            if (audVol > sample.attackMax) {
              audVol = sample.attackMax;
              voice.envelopeCnt += 2;
            }
            break;
          case 2:
            audVol -= sample.decaySpeed;
            if (audVol <= sample.decayMin || audVol < -256) {
              audVol = sample.decayMin;
              voice.envelopeCnt += 2;
              voice.sustainCnt = sample.sustain;
            }
            break;
          case 4:
            voice.sustainCnt--;
            if (voice.sustainCnt == 0 ||
                voice.sustainCnt == -256) voice.envelopeCnt += 2;
            break;
          case 6:
            audVol -= sample.releaseSpeed;
            if (audVol <= sample.releaseMin || audVol < -256) {
              audVol = sample.releaseMin;
              voice.envelopeCnt += 2;
            }
            break;
        }

        voice.volume = audVol;
        voice.arpeggioCnt = ++voice.arpeggioCnt & 15;
        d = sample.finetune + sample.arpeggio[voice.arpeggioCnt] + voice.note;
        voice.period = audPer = PERIODS[d];

        if (voice.bendSpeed) {
          c = PERIODS[int(sample.finetune + voice.bendTo)];
          d = ~voice.bendSpeed + 1;
          if (d < -128) d &= 0xff;
          voice.pitchCnt += d;
          voice.period += voice.pitchCnt;

          if ((d < 0 && voice.period <= c) || (d > 0 && voice.period >= c)) {
            voice.note      = voice.bendTo;
            voice.period    = c;
            voice.bendSpeed = 0;
            voice.pitchCnt  = 0;
          }
        }

        if (sample.phaseShift) {
          if (voice.phaseSpeed == 0) {
            voice.phaseTimer = ++voice.phaseTimer & 31;
            d = (sample.phaseShift << 5) + voice.phaseTimer;
            voice.period += amiga.samples[d] >> 2;
          } else {
            voice.phaseSpeed--;
          }
        }

        voice.pitchfallCnt -= sample.pitchfall;
        if (voice.pitchfallCnt < -256) voice.pitchfallCnt += 256;
        voice.period += voice.pitchfallCnt;

        if (voice.waitCnt == 0) {
          if (voice.waveTimer == 0) {
            if (voice.waveStep < 16) {
              d = (voice.waveList << 4) + voice.waveStep;
              c = song.waveLists[d++];

              if (c == 0xff) {
                voice.waveStep = song.waveLists[d] & 254;
              } else {
                audPtr = c << 5;
                voice.waveTimer = song.waveLists[d];
                voice.waveStep += 2;
              }
            }
          } else {
            voice.waveTimer--;
          }
        }

        if (audPtr > -1) chan.pointer = audPtr;
        if (audPer != 0) chan.period  = voice.period;

        if (sample.volume) chan.volume = sample.volume;
          else chan.volume = audVol >> 2;

        if (audLen != 0) chan.length = audLen;
        chan.enabled = 1;
      }

      stepEnd = patternEnd = 0;

      if (++timer > speed) {
        timer = 0;

        if (++curPattern == patternLen) {
          curPattern = 0;
          patternEnd = 1;
          if (++curStep == song.stepLen) curStep = stepEnd = complete = 1;
        }
      }

      if (song.mix1Speed) {
        if (mix1Speed == 0) {
          mix1Speed = song.mix1Speed;
          c = mix1Step = ++mix1Step & 31;

          d  = (song.mix1Dest    << 5) + 31;
          s1 = (song.mix1Source1 << 5) + 31;
          s2 =  song.mix1Source2 << 5;

          for (i = 31; i > -1; --i) {
            amiga.samples[d--] = (amiga.samples[s1--] + amiga.samples[int(s2 + c)]) >> 1;
            c = --c & 31;
          }
        }

        mix1Speed--;
      }

      if (song.mix2Speed) {
        if (mix2Speed == 0) {
          mix2Speed = song.mix2Speed;
          c = mix2Step = ++mix2Step & 31;

          d  = (song.mix2Dest    << 5) + 31;
          s1 = (song.mix2Source1 << 5) + 31;
          s2 =  song.mix2Source2 << 5;

          for (i = 31; i > -1; --i) {
            amiga.samples[d--] = (amiga.samples[s1--] + amiga.samples[int(s2 + c)]) >> 1;
            c = --c & 31;
          }
        }

        mix2Speed--;
      }

      if (song.doFilters) {
        d = mix1Step + 32;
        amiga.samples[d] = ~amiga.samples[d] + 1;
      }

      for (i = 0; i < 4; ++i) {
        chan  = amiga.channels[i];
        voice = voices[i];

        if (voice.waitCnt == 1) {
          voice.waitCnt++;
        } else if (voice.waitCnt == 2) {
          voice.waitCnt++;
          chan.pointer = voice.samplePtr;
          chan.length  = voice.sampleLen;
        }
      }
    }
  }
}