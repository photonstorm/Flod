package neoart.flod.soundmon {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class BPPlayer extends AmigaPlayer {
    public static const
      BPSOUNDMON_V1 : int = 1,
      BPSOUNDMON_V2 : int = 2,
      BPSOUNDMON_V3 : int = 3;

    internal var
      tracks      : Vector.<BPStep>,
      patterns    : Vector.<AmigaRow>,
      samples     : Vector.<BPSample>,
      length      : int;
    private var
      buffer      : Vector.<int>,
      voices      : Vector.<BPData>,
      trackPos    : int,
      patternPos  : int,
      nextPos     : int,
      jumpFlag    : int,
      repeatCtr   : int,
      arpeggioCtr : int,
      vibratoPos  : int;

    private const
      PERIODS : Vector.<int> = Vector.<int>([
        6848,6464,6080,5760,5440,5120,4832,4576,4320,4064,3840,3616,
        3424,3232,3040,2880,2720,2560,2416,2288,2160,2032,1920,1808,
        1712,1616,1520,1440,1360,1280,1208,1144,1080,1016,0960,0904,
        0856,0808,0760,0720,0680,0640,0604,0572,0540,0508,0480,0452,
        0428,0404,0380,0360,0340,0320,0302,0286,0270,0254,0240,0226,
        0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113,
        0107,0101,0095,0090,0085,0080,0076,0072,0068,0064,0060,0057]),
      VIBRATO : Vector.<int> = Vector.<int>([
        0,64,128,64,0,-64,-128,-64]);

    public function BPPlayer(amiga:Amiga) {
      super(amiga);
      PERIODS.fixed = true;
      VIBRATO.fixed = true;

      buffer  = new Vector.<int>(128, true);
      samples = new Vector.<BPSample>(16, true);
      voices  = new Vector.<BPData>(4, true);

      voices[0] = new BPData();
      voices[1] = new BPData();
      voices[2] = new BPData();
      voices[3] = new BPData();
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      BPLoader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, data:int, dst:int, i:int, instr:int, len:int, memory:Vector.<int>, note:int, option:int, row:AmigaRow, sample:BPSample, src:int, step:BPStep, voice:BPData;
      arpeggioCtr = --arpeggioCtr & 3;
      vibratoPos  = ++vibratoPos  & 7;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        chan  = voice.channel;
        voice.period += voice.autoSlide;

        if (voice.vibrato) chan.period = voice.period + VIBRATO[vibratoPos] / voice.vibrato;
          else chan.period = voice.period;

        chan.pointer = voice.samplePtr;
        chan.length  = voice.sampleLen;

        if (voice.arpeggio || voice.autoArpeggio) {
          note = voice.note;

          if (arpeggioCtr == 0)
            note += ((voice.arpeggio & 0xf0) >> 4) + ((voice.autoArpeggio & 0xf0) >> 4);
          else if (arpeggioCtr == 1)
            note += (voice.arpeggio & 0x0f) + (voice.autoArpeggio & 0x0f);

          chan.period = voice.period = PERIODS[int(note + 35)];
          voice.restart = 0;
        }

        if (!voice.synth) continue;
        sample = samples[voice.sample];
        memory = amiga.memory;

        if (voice.adsrControl) {
          if (--voice.adsrCtr == 0) {
            voice.adsrCtr = sample.adsrSpeed;
            data = (128 + memory[int(sample.adsrTable + voice.adsrPtr)]) >> 2;
            chan.volume = (data * voice.volume) >> 6;

            if (++voice.adsrPtr == sample.adsrLen) {
              voice.adsrPtr = 0;
              if (voice.adsrControl == 1) voice.adsrControl = 0;
            }
          }
        }

        if (voice.lfoControl) {
          if (--voice.lfoCtr == 0) {
            voice.lfoCtr = sample.lfoSpeed;
            data = memory[int(sample.lfoTable + voice.lfoPtr)];
            if (sample.lfoDepth) data /= sample.lfoDepth;
            chan.period = voice.period + data;

            if (++voice.lfoPtr == sample.lfoLen) {
              voice.lfoPtr = 0;
              if (voice.lfoControl == 1) voice.lfoControl = 0;
            }
          }
        }

        if (voice.synthPtr < 0) continue;

        if (voice.egControl) {
          if (--voice.egCtr == 0) {
            voice.egCtr = sample.egSpeed;
            data = voice.egValue;
            voice.egValue = (128 + memory[int(sample.egTable + voice.egPtr)]) >> 3;

            if (voice.egValue != data) {
              src = (i << 5) + data;
              dst = voice.synthPtr + data;

              if (voice.egValue < data) {
                data -= voice.egValue;
                len = dst - data;
                for (dst; dst > len;) memory[--dst] = buffer[--src];
              } else {
                data = voice.egValue - data;
                len = dst + data;
                for (dst; dst < len;) memory[dst++] = ~buffer[src++] + 1
              }
            }

            if (++voice.egPtr == sample.egLen) {
              voice.egPtr = 0;
              if (voice.egControl == 1) voice.egControl = 0;
            }
          }
        }

        switch (voice.fxControl) {
          case 0:
            break;
          case 1: //averaging
            if (--voice.fxCtr == 0) {
              voice.fxCtr = sample.fxSpeed;
              dst = voice.synthPtr;
              len = voice.synthPtr + 32;
              data = dst > 0 ? memory[int(dst - 1)] : 0;

              for (dst; dst < len;) {
                data = (data + memory[int(dst + 1)]) >> 1;
                memory[dst++] = data;
              }
            }
            break;
          case 2: //inversion
            src = (i << 5) + 31;
            len = voice.synthPtr + 32;
            data = sample.fxSpeed;

            for (dst = voice.synthPtr; dst < len; ++dst) {
              if (buffer[src] < memory[dst])
                memory[dst] -= data;
              else if (buffer[src] > memory[dst])
                memory[dst] += data;
              src--;
            }
            break;
          case 3: //backward inversion
          case 5: //backward transform
            src = i << 5;
            len = voice.synthPtr + 32;
            data = sample.fxSpeed;

            for (dst = voice.synthPtr; dst < len; ++dst) {
              if (buffer[src] < memory[dst])
                memory[dst] -= data;
              else if (buffer[src] > memory[dst])
                memory[dst] += data;
              src++;
            }
            break;
          case 4: //transform
            src = voice.synthPtr + 64;
            len = voice.synthPtr + 32;
            data = sample.fxSpeed;

            for (dst = voice.synthPtr; dst < len; ++dst) {
              if (memory[src] < memory[dst])
                memory[dst] -= data;
              else if (memory[src] > memory[dst])
                memory[dst] += data;
              src++;
            }
            break;
          case 6: //wave change
            if (--voice.fxCtr == 0) {
              voice.fxControl = 0;
              voice.fxCtr = 1;
              src = voice.synthPtr + 64;
              len = voice.synthPtr + 32;
              for (dst = voice.synthPtr; dst < len; ++dst) memory[dst] = memory[src++];
            }
            break;
        }

        if (voice.modControl) {
          if (--voice.modCtr == 0) {
            voice.modCtr = sample.modSpeed;
            memory[int(voice.synthPtr + 32)] = memory[int(sample.modTable + voice.modPtr)];

            if (++voice.modPtr == sample.modLen) {
              voice.modPtr = 0;
              if (voice.modControl == 1) voice.modControl = 0;
            }
          }
        }
      }

      if (--timer == 0) {
        timer = speed;

        for (i = 0; i < 4; ++i) {
          voice = voices[i];
          chan  = voice.channel;
          voice.enabled = 0;

          step   = tracks[int((trackPos << 2) + i)];
          row    = patterns[int(patternPos + ((step.pattern - 1) << 4))];
          note   = row.note;
          option = row.data1;
          data   = row.data2;

          if (note) {
            voice.autoArpeggio = voice.autoSlide = voice.vibrato = 0;
            if (option != 10 || (data & 240) == 0) note += step.transpose;
            voice.note = note;
            voice.period = PERIODS[int(note + 35)];

            if (option < 13) voice.restart = voice.volumeDef = 1;
              else voice.restart = 0;

            instr = row.sample;
            if (instr == 0) instr = voice.sample;
            if (option != 10 || (data & 15) == 0) instr += step.soundTranspose;

            if (option < 13 && (!voice.synth || (voice.sample != instr))) {
              voice.sample = instr;
              voice.enabled = 1;
            }
          }

          switch (option) {
            case 0:  //arpeggio once
              voice.arpeggio = data;
              break;
            case 1:  //set volume
              voice.volume = data;
              voice.volumeDef = 0;
              if (version < 3 || !voice.synth) chan.volume = voice.volume;
              break;
            case 2:  //set speed
              timer = speed = data;
              break;
            case 3:  //set filter
              amiga.filter.active = data;
              break;
            case 4:  //portamento up
              voice.period -= data;
              voice.arpeggio = 0;
              break;
            case 5:  //portamento down
              voice.period += data;
              voice.arpeggio = 0;
              break;
            case 6:  //set vibrato
              if (version == 3) voice.vibrato = data;
                else repeatCtr = data;
              break;
            case 7:  //step jump
              if (version == 3) {
                nextPos = data;
                jumpFlag = 1;
              } else if (repeatCtr == 0) {
                trackPos = data;
              }
              break;
            case 8:  //set auto slide
              voice.autoSlide = data;
              break;
            case 9:  //set auto arpeggio
              voice.autoArpeggio = data;
              if (version == 3) {
                voice.adsrPtr = 0;
                if (voice.adsrControl == 0) voice.adsrControl = 1;
              }
              break;
            case 11: //change effect
              voice.fxControl = data;
              break;
            case 13: //change inversion
              voice.autoArpeggio = data;
              voice.fxControl ^= 1;
              voice.adsrPtr = 0;
              if (voice.adsrControl == 0) voice.adsrControl = 1;
              break;
            case 14: //no eg reset
              voice.autoArpeggio = data;
              voice.adsrPtr = 0;
              if (voice.adsrControl == 0) voice.adsrControl = 1;
              break;
            case 15: //no eg and no adsr reset
              voice.autoArpeggio = data;
              break;
          }
        }

        if (jumpFlag) {
          trackPos   = nextPos;
          patternPos = jumpFlag = 0;
        } else if (++patternPos == 16) {
          patternPos = 0;

          if (++trackPos == length) {
            trackPos = 0;
            amiga.complete = 1;
          }
        }

        for (i = 0; i < 4; ++i) {
          voice = voices[i];
          chan  = voice.channel;
          if (voice.enabled) chan.enabled = voice.enabled = 0;
          if (voice.restart == 0) continue;

          if (voice.synthPtr > -1) {
            src = i << 5;
            len = voice.synthPtr + 32;
            for (dst = voice.synthPtr; dst < len; ++dst) memory[dst] = buffer[src++];
            voice.synthPtr = -1;
          }
        }

        for (i = 0; i < 4; ++i) {
          voice = voices[i];
          chan  = voice.channel;
          if (voice.restart == 0) continue;

          chan.period   = voice.period;
          voice.restart = 0;
          sample = samples[voice.sample];
          memory = amiga.memory;

          if (sample.synth) {
            voice.synth   = 1;
            voice.egValue = 0;
            voice.adsrPtr = voice.lfoPtr = voice.egPtr = voice.modPtr = 0;

            voice.adsrCtr = 1;
            voice.lfoCtr  = sample.lfoDelay + 1;
            voice.egCtr   = sample.egDelay  + 1;
            voice.fxCtr   = sample.fxDelay  + 1;
            voice.modCtr  = sample.modDelay + 1;

            voice.adsrControl = sample.adsrControl;
            voice.lfoControl  = sample.lfoControl;
            voice.egControl   = sample.egControl;
            voice.fxControl   = sample.fxControl;
            voice.modControl  = sample.modControl;

            chan.pointer = voice.samplePtr = sample.pointer;
            chan.length  = voice.sampleLen = sample.length;

            if (voice.adsrControl) {
              data = (128 + memory[sample.adsrTable]) >> 2;

              if (voice.volumeDef) {
                voice.volume = sample.volume;
                voice.volumeDef = 0;
              }

              chan.volume = (data * voice.volume) >> 6;
            } else {
              chan.volume = voice.volumeDef ? sample.volume : voice.volume;
            }

            if (voice.egControl || voice.fxControl || voice.modControl) {
              voice.synthPtr = sample.pointer;
              dst = i << 5;
              len = voice.synthPtr + 32;
              for (src = voice.synthPtr; src < len; ++src) buffer[dst++] = memory[src];
            }
          } else {
            voice.synth = voice.lfoControl = 0;

            if (sample.pointer < 0) {
              voice.samplePtr = amiga.loopPtr;
              voice.sampleLen = 2;
            } else {
              chan.pointer = sample.pointer;
              chan.volume  = voice.volumeDef ? sample.volume : voice.volume;

              if (sample.repeat != 2) {
                voice.samplePtr = sample.loopPtr;
                chan.length = voice.sampleLen = sample.repeat;
              } else {
                voice.samplePtr = amiga.loopPtr;
                voice.sampleLen = 2;
                chan.length = sample.length;
              }
            }
          }

          chan.enabled = voice.enabled = 1;
        }
      }
    }

    override protected function initialize():void {
      var i:int, voice:BPData;
      super.initialize();
      speed       = 6;
      timer       = 1;
      trackPos    = 0;
      patternPos  = 0;
      nextPos     = 0;
      jumpFlag    = 0;
      repeatCtr   = 0;
      arpeggioCtr = 0;
      vibratoPos  = 0;

      for (i = 0; i < 128; ++i) buffer[i] = 0;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.channel   = amiga.channels[i];
        voice.samplePtr = amiga.loopPtr;
      }
    }

    override protected function reset():void {
      var i:int, j:int, len:int, pos:int, voice:BPData;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        if (voice.synthPtr == 0) continue;
        pos = i << 5;
        len = voice.synthPtr + 32;

        for (j = voice.synthPtr; j < len; ++j)
          amiga.memory[j] = buffer[pos++];
      }
    }
  }
}