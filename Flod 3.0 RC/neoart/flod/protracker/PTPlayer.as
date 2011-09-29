package neoart.flod.protracker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class PTPlayer extends AmigaPlayer {
    public static const
      PROTRACKER_10 : int = 1,
      PROTRACKER_11 : int = 2,
      PROTRACKER_12 : int = 3;

    internal var
      track        : Vector.<int>,
      patterns     : Vector.<PTRow>,
      samples      : Vector.<PTSample>,
      length       : int,
      tempo        : int;
    private var
      voices       : Vector.<PTData>,
      trackPos     : int,
      patternPos   : int,
      patternBreak : int,
      patternDelay : int,
      breakPos     : int,
      jumpFlag     : int,
      vibratoDepth : int;

    private const
      ARPEGGIO : Vector.<int> = Vector.<int>([
        0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1]),
      FUNKREP  : Vector.<int> = Vector.<int>([
        0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128]),
      PERIODS  : Vector.<int> = Vector.<int>([
        856,808,762,720,678,640,604,570,538,508,480,453,
        428,404,381,360,339,320,302,285,269,254,240,226,
        214,202,190,180,170,160,151,143,135,127,120,113,0,
        850,802,757,715,674,637,601,567,535,505,477,450,
        425,401,379,357,337,318,300,284,268,253,239,225,
        213,201,189,179,169,159,150,142,134,126,119,113,0,
        844,796,752,709,670,632,597,563,532,502,474,447,
        422,398,376,355,335,316,298,282,266,251,237,224,
        211,199,188,177,167,158,149,141,133,125,118,112,0,
        838,791,746,704,665,628,592,559,528,498,470,444,
        419,395,373,352,332,314,296,280,264,249,235,222,
        209,198,187,176,166,157,148,140,132,125,118,111,0,
        832,785,741,699,660,623,588,555,524,495,467,441,
        416,392,370,350,330,312,294,278,262,247,233,220,
        208,196,185,175,165,156,147,139,131,124,117,110,0,
        826,779,736,694,655,619,584,551,520,491,463,437,
        413,390,368,347,328,309,292,276,260,245,232,219,
        206,195,184,174,164,155,146,138,130,123,116,109,0,
        820,774,730,689,651,614,580,547,516,487,460,434,
        410,387,365,345,325,307,290,274,258,244,230,217,
        205,193,183,172,163,154,145,137,129,122,115,109,0,
        814,768,725,684,646,610,575,543,513,484,457,431,
        407,384,363,342,323,305,288,272,256,242,228,216,
        204,192,181,171,161,152,144,136,128,121,114,108,0,
        907,856,808,762,720,678,640,604,570,538,508,480,
        453,428,404,381,360,339,320,302,285,269,254,240,
        226,214,202,190,180,170,160,151,143,135,127,120,0,
        900,850,802,757,715,675,636,601,567,535,505,477,
        450,425,401,379,357,337,318,300,284,268,253,238,
        225,212,200,189,179,169,159,150,142,134,126,119,0,
        894,844,796,752,709,670,632,597,563,532,502,474,
        447,422,398,376,355,335,316,298,282,266,251,237,
        223,211,199,188,177,167,158,149,141,133,125,118,0,
        887,838,791,746,704,665,628,592,559,528,498,470,
        444,419,395,373,352,332,314,296,280,264,249,235,
        222,209,198,187,176,166,157,148,140,132,125,118,0,
        881,832,785,741,699,660,623,588,555,524,494,467,
        441,416,392,370,350,330,312,294,278,262,247,233,
        220,208,196,185,175,165,156,147,139,131,123,117,0,
        875,826,779,736,694,655,619,584,551,520,491,463,
        437,413,390,368,347,328,309,292,276,260,245,232,
        219,206,195,184,174,164,155,146,138,130,123,116,0,
        868,820,774,730,689,651,614,580,547,516,487,460,
        434,410,387,365,345,325,307,290,274,258,244,230,
        217,205,193,183,172,163,154,145,137,129,122,115,0,
        862,814,768,725,684,646,610,575,543,513,484,457,
        431,407,384,363,342,323,305,288,272,256,242,228,
        216,203,192,181,171,161,152,144,136,128,121,114,0]),
      VIBRATO  : Vector.<int> = Vector.<int>([
        000,024,049,074,097,120,141,161,180,197,212,224,
        235,244,250,253,255,253,250,244,235,224,212,197,
        180,161,141,120,097,074,049,024]);

    public function PTPlayer(amiga:Amiga = null) {
      super(amiga);
      ARPEGGIO.fixed = true;
      FUNKREP.fixed  = true;
      PERIODS.fixed  = true;
      VIBRATO.fixed  = true;

      track   = new Vector.<int>(128, true);
      samples = new Vector.<PTSample>(32, true);
      voices  = new Vector.<PTData>(4, true);

      voices[0] = new PTData();
      voices[1] = new PTData();
      voices[2] = new PTData();
      voices[3] = new PTData();
    }

    override public function set force(value:int):void {
      if (value < PROTRACKER_10) value = PROTRACKER_10;
        else if (value > PROTRACKER_12) value = PROTRACKER_12;

      version = value;
      vibratoDepth = value < PROTRACKER_11 ? 6 : 7;
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      PTLoader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, j:int, pattern:int, row:PTRow, sample:PTSample, value:int, voice:PTData;

      if (++timer == speed) {
        timer = 0;

        if (patternDelay > 0) {
          effects();
        } else {
          pattern = track[trackPos] + patternPos;

          for (i = 0; i < 4; ++i) {
            chan = amiga.channels[i];
            voice = voices[i];
            voice.enabled = 0;

            if (voice.step == 0) chan.period = voice.period;
            row = patterns[int(pattern + i)];
            voice.step   = row.step;
            voice.effect = row.data1;
            voice.param  = row.data2;

            if (row.sample) {
              sample = voice.sample = samples[row.sample];

              voice.pointer  = sample.pointer;
              voice.length   = sample.length;
              voice.loopPtr  = voice.funkWave = sample.loopPtr;
              voice.repeat   = sample.repeat;
              voice.finetune = sample.finetune;

              chan.volume = voice.volume = sample.volume;
            } else
              sample = voice.sample;

            if (row.note == 0) {
              moreEffects(voice);
              continue;
            } else {
              if ((voice.step & 0x0ff0) == 0x0e50) {
                voice.finetune = (voice.param & 0x0f) * 37;
              } else if (voice.effect == 3 || voice.effect == 5) {
                if (row.note == voice.period)
                  voice.portaPeriod = 0;
                else {
                  j = voice.finetune;
                  value = j + 37;
                  for (j; j < value; ++j) if (row.note >= PERIODS[j]) break;
                  if (j == value) value--;

                  if (j > 0) {
                    value = (voice.finetune / 37) & 8;
                    if (value) j--;
                  }
                  voice.portaPeriod = PERIODS[j];
                  voice.portaDir = row.note > voice.portaPeriod ? 0 : 1;
                }
              } else if (voice.effect == 9)
                moreEffects(voice);
            }

            for (j = 0; j < 37; ++j) if (row.note >= PERIODS[j]) break;
            voice.period = PERIODS[int(voice.finetune + j)];

            if ((voice.step & 0x0ff0) == 0x0ed0) {
              updateFunk(voice);
              extended(voice);
              continue;
            }
            if (voice.vibratoWave < 4) voice.vibratoPos = 0;
            if (voice.tremoloWave < 4) voice.tremoloPos = 0;

            chan.enabled = 0;
            chan.pointer = voice.pointer;
            chan.length  = voice.length;
            chan.period  = voice.period;

            voice.enabled = 1;
            moreEffects(voice);
          }
        }

        patternPos += 4;
        if (patternDelay > 0)
          if (--patternDelay > 0) patternPos -= 4;

        if (patternBreak) {
          patternBreak = 0;
          patternPos = breakPos;
          breakPos = 0;
        }
        if (patternPos == 256) jumpFlag = 1;
      } else {
        effects();
      }

      if (jumpFlag) {
        patternPos = breakPos;
        breakPos = 0;
        jumpFlag = 0;

        if (++trackPos == length) {
          trackPos = 0;
          amiga.complete = 1;
        }
      }
    }

    override protected function initialize():void {
      var i:int, voice:PTData;
      super.initialize();
      tempo        = 125;
      speed        = 6;
      trackPos     = 0;
      patternPos   = 0;
      patternBreak = 0;
      patternDelay = 0;
      breakPos     = 0;
      jumpFlag     = 0;

      amiga.samplesTick = 110250 / tempo;
      force = version;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.channel = amiga.channels[i];
        voice.sample  = samples[0];
      }
    }

    private function effects():void {
      var chan:AmigaChannel, i:int, j:int, position:int, slide:int, value:int, voice:PTData, wave:int;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        chan  = voice.channel;
        slide = 0;

        updateFunk(voice);

        if ((voice.step & 0x0fff) == 0) {
          chan.period = voice.period;
          continue;
        }

        switch (voice.effect) {
          case 0:  //arpeggio
            value = ARPEGGIO[timer];
            if (value == 0) {
              chan.period = voice.period;
              continue;
            }

            if (value == 1) value = voice.param >> 4;
              else value = voice.param & 0x0f;

            j = voice.finetune;
            slide = j + 37;

            for (j; j < slide; ++j)
              if (voice.period >= PERIODS[j]) {
                chan.period = PERIODS[int(j + value)];
                break;
              }
            continue;
          case 1:  //portamento up
            voice.period -= voice.param;
            if (voice.period < 113) voice.period = 113;
            chan.period = voice.period;
            continue;
          case 2:  //portamento down
            voice.period += voice.param;
            if (voice.period > 856) voice.period = 856;
            chan.period = voice.period;
            continue;
          case 3:  //tone portamento
          case 5:  //tone portamento + volume slide
            if (voice.effect == 5) slide = 1;
            else if (voice.param) {
              voice.portaSpeed = voice.param;
              voice.param = 0;
            }

            if (voice.portaPeriod) {
              if (voice.portaDir) {
                voice.period -= voice.portaSpeed;
                if (voice.period < voice.portaPeriod) {
                  voice.period = voice.portaPeriod;
                  voice.portaPeriod = 0;
                }
              } else {
                voice.period += voice.portaSpeed;
                if (voice.period > voice.portaPeriod) {
                  voice.period = voice.portaPeriod;
                  voice.portaPeriod = 0;
                }
              }

              if (voice.glissando) {
                j = voice.finetune;
                value = j + 37;
                for (j; j < value; ++j) if (voice.period >= PERIODS[j]) break;
                if (j == value) j--;
                chan.period = PERIODS[j];
              } else
                chan.period = voice.period;
            }
            break;
          case 4:  //vibrato
          case 6:  //vibrato + volume slide
            if (voice.effect == 6) slide = 1;
            else if (voice.param) {
              value = voice.param & 0x0f;
              if (value) voice.vibratoParam = (voice.vibratoParam & 0xf0) | value;
              value = voice.param & 0xf0;
              if (value) voice.vibratoParam = (voice.vibratoParam & 0x0f) | value;
            }

            position = (voice.vibratoPos >> 2) & 31;
            wave = voice.vibratoWave & 3;

            if (wave == 1) {
              value = 255;
              position <<= 3;

              if (wave == 1) {
                if (voice.vibratoPos > 127) value -= position;
                  else value = position;
              }
            } else
              value = VIBRATO[position];

            value = ((voice.vibratoParam & 0x0f) * value) >> vibratoDepth;

            if (voice.vibratoPos > 127) chan.period = voice.period - value;
              else chan.period = voice.period + value;

            value = (voice.vibratoParam >> 2) & 60;
            voice.vibratoPos = (voice.vibratoPos + value) & 255;
            break;
          case 7:  //tremolo
            chan.period = voice.period;

            if (voice.param) {
              value = voice.param & 0x0f;
              if (value) voice.tremoloParam = (voice.tremoloParam & 0xf0) | value;
              value = voice.param & 0xf0;
              if (value) voice.tremoloParam = (voice.tremoloParam & 0x0f) | value;
            }

            position = (voice.tremoloPos >> 2) & 31;
            wave = voice.tremoloWave & 3;

            if (wave) {
              value = 255;
              position <<= 3;

              if (wave == 1) {
                if (voice.tremoloPos > 127) value -= position;
                  else value = position;
              }
            } else
              value = VIBRATO[position];

            value = ((voice.tremoloParam & 0x0f) * value) >> 6;

            if (voice.tremoloPos > 127) chan.volume = voice.volume - value;
              else chan.volume = voice.volume + value;

            value = (voice.tremoloParam >> 2) & 60;
            voice.tremoloPos = (voice.tremoloPos + value) & 255;
            break;
          case 10: //volume slide
            slide = 1;
            break;
          case 14: //extended effect
            extended(voice);
            continue;
        }

        if (slide) {
          value = voice.param >> 4;
          if (value) voice.volume += value;
            else voice.volume -= voice.param & 0x0f;

          if (voice.volume > 64) voice.volume = 64;
            else if (voice.volume < 0) voice.volume = 0;
          chan.volume = voice.volume;
        }
      }
    }

    private function moreEffects(voice:PTData):void {
      var chan:AmigaChannel = voice.channel, value:int;
      updateFunk(voice);

      switch (voice.effect) {
        case 9:  //sample offset
          if (voice.param) voice.offset = voice.param;
          value = voice.offset << 8;
          if (value >= voice.length) voice.length = 2;
          else {
            voice.pointer += value;
            voice.length  -= value;
          }
          break;
        case 11: //position jump
          trackPos = voice.param - 1;
          breakPos = 0;
          jumpFlag = 1;
          break;
        case 12: //set volume
          voice.volume = voice.param;
          if (voice.volume > 64) voice.volume = 64;
          chan.volume = voice.volume;
          break;
        case 13: //pattern break
          breakPos = ((voice.param >> 4) * 10) + (voice.param & 0x0f);
          if (breakPos > 63) breakPos = 0;
          breakPos <<= 2;
          jumpFlag = 1;
          break;
        case 14: //extended effect
          extended(voice);
          break;
        case 15: //set speed
          if (voice.param == 0) return;
          if (voice.param < 32) speed = voice.param;
            else amiga.samplesTick = 110250 / voice.param;
          timer = 0;
          break;
      }
    }

    private function extended(voice:PTData):void {
      var chan:AmigaChannel = voice.channel, effect:int = voice.param >> 4, i:int, len:int, memory:Vector.<int>, param:int = voice.param & 0x0f;

      switch (effect) {
        case 0:  //set filter
          amiga.filter.active = param;
          break;
        case 1:  //fine portamento up
          if (timer) return;
          voice.period -= param;
          if (voice.period < 113) voice.period = 113;
          chan.period = voice.period;
          break;
        case 2:  //fine portamento down
          if (timer) return;
          voice.period += param;
          if (voice.period > 856) voice.period = 856;
          chan.period = voice.period;
          break;
        case 3:  //glissando control
          voice.glissando = param;
          break;
        case 4:  //vibrato control
          voice.vibratoWave = param;
          break;
        case 5:  //set finetune
          voice.finetune = param * 37;
          break;
        case 6:  //pattern loop
          if (timer) return;
          if (param) {
            if (voice.loopCtr) voice.loopCtr--;
              else voice.loopCtr = param;
            if (voice.loopCtr) {
              breakPos = voice.loopPos << 2;
              patternBreak = 1;
            }
          } else
            voice.loopPos = patternPos >> 2;
          break;
        case 7:  //tremolo control
          voice.tremoloWave = param;
          break;
        case 8:  //karplus strong
          len = voice.length - 2;
          memory = amiga.memory;
          for (i = voice.loopPtr; i < len;) memory[i] = (memory[i] + memory[++i]) * 0.5;
          memory[++i] = (memory[i] + memory[0]) * 0.5;
          break;
        case 9:  //retrig note
          if (timer || param == 0 || voice.period == 0) return;
          if (timer % param) return;
          chan.enabled = 0;
          chan.pointer = voice.pointer;
          chan.length  = voice.length;
          chan.delay   = 30;
          chan.enabled = 1;
          chan.pointer = voice.loopPtr;
          chan.length  = voice.repeat;
          chan.period  = voice.period;
          break;
        case 10: //fine volume up
          if (timer) return;
          voice.volume += param;
          if (voice.volume > 64) voice.volume = 64;
          chan.volume = voice.volume;
          break;
        case 11: //fine volume down
          if (timer) return;
          voice.volume -= param;
          if (voice.volume < 0) voice.volume = 0;
          chan.volume = voice.volume;
          break;
        case 12: //note cut
          if (timer == param) chan.volume = voice.volume = 0;
          break;
        case 13: //note delay
          if (timer != param || voice.period == 0) return;
          chan.enabled = 0;
          chan.pointer = voice.pointer;
          chan.length  = voice.length;
          chan.delay   = 30;
          chan.enabled = 1;
          chan.pointer = voice.loopPtr;
          chan.length  = voice.repeat;
          chan.period  = voice.period;
          break;
        case 14: //pattern delay
          if (timer || patternDelay) return;
          patternDelay = ++param;
          break;
        case 15: //funk repeat/invert loop
          if (timer) return;
          voice.funkSpeed = param;
          if (param) updateFunk(voice);
          break;
      }
    }

    private function updateFunk(voice:PTData):void {
      var d1:int, d2:int, value:int;
      if (voice.funkSpeed == 0) return;

      value = FUNKREP[voice.funkSpeed];
      voice.funkPos += value;
      if (voice.funkPos < 128) return;

      if (version == 1) {
        d1 = voice.pointer  - voice.repeat + voice.sample.realLen;
        d2 = voice.funkWave + voice.repeat;

        if (d2 > d1) {
          d2 = voice.loopPtr;
          voice.channel.length = voice.repeat;
        }
        voice.funkWave = d2;
        voice.channel.pointer = d2;
      } else {
        d1 = voice.loopPtr  + voice.repeat;
        d2 = voice.funkWave + 1;
        if (d2 >= d1) d2 = voice.loopPtr;
        amiga.memory[d2] = -amiga.memory[d2];
      }
    }
  }
}