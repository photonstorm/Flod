package neoart.flod.delta1 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class D1Player extends AmigaPlayer {
    internal var
      pointers : Vector.<int>,
      tracks   : Vector.<D1Step>,
      patterns : Vector.<AmigaRow>,
      samples  : Vector.<D1Sample>;
    private var
      voices   : Vector.<D1Data>;

    private const
      PERIODS:Vector.<int> = Vector.<int>([
        0000,6848,6464,6096,5760,5424,5120,4832,4560,4304,4064,3840,
        3616,3424,3232,3048,2880,2712,2560,2416,2280,2152,2032,1920,
        1808,1712,1616,1524,1440,1356,1280,1208,1140,1076,0960,0904,
        0856,0808,0762,0720,0678,0640,0604,0570,0538,0508,0480,0452,
        0428,0404,0381,0360,0339,0320,0302,0285,0269,0254,0240,0226,
        0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113,
        0113,0113,0113,0113,0113,0113,0113,0113,0113,0113,0113,0113]);

    public function D1Player(amiga:Amiga = null) {
      super(amiga);
      PERIODS.fixed = true;

      samples = new Vector.<D1Sample>(21, true);
      voices  = new Vector.<D1Data>(4, true);

      voices[0] = new D1Data();
      voices[1] = new D1Data();
      voices[2] = new D1Data();
      voices[3] = new D1Data();
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      D1Loader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var adsr:int, chan:AmigaChannel, i:int, loop:int, row:AmigaRow, sample:D1Sample, value:int, voice:D1Data;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        chan  = amiga.channels[i];

        if (--voice.timer == 0) {
          voice.timer = speed;
          if (voice.patternPos == 0) {
            voice.step = tracks[int(pointers[i] + voice.trackPos)];

            if (voice.step.pattern < 0) {
              voice.trackPos = voice.step.transpose;
              voice.step = tracks[int(pointers[i] + voice.trackPos)];
            }
            voice.trackPos++;
          }
          row = patterns[int(voice.step.pattern + voice.patternPos)];
          if (row.data1) voice.row = row;

          if (row.note) {
            chan.enabled = 0;
            voice.row = row;
            voice.note = row.note + voice.step.transpose;
            voice.arpeggioPos = voice.pitchBend = voice.status = 0;

            sample = voice.sample = samples[row.sample];
            if (!sample.synth) chan.pointer = sample.pointer;
            chan.length = sample.length;

            voice.tableCtr = voice.tablePos = 0;
            voice.vibratoCtr = sample.vibratoWait;
            voice.vibratoPos = sample.vibratoLen;
            voice.vibratoDir = sample.vibratoLen << 1;
            voice.volume  = voice.attackCtr = voice.decayCtr = voice.releaseCtr = 0;
            voice.sustain = sample.sustain;
          }
          if (++voice.patternPos == 16) voice.patternPos = 0;
        }
        sample = voice.sample;

        if (sample.synth) {
          if (voice.tableCtr == 0) {
            voice.tableCtr = sample.tableDelay;

            do {
              loop = 1;
              if (voice.tablePos >= 48) voice.tablePos = 0;
              value = sample.table[voice.tablePos];
              voice.tablePos++;

              if (value >= 0)
                chan.pointer = sample.pointer + (value << 5);
              else if (value != -1)
                sample.tableDelay = value & 127;
              else
                voice.tablePos = sample.table[voice.tablePos];
            } while (loop);
          } else
            voice.tableCtr--;
        }

        if (sample.portamento) {
          value = PERIODS[voice.note] + voice.pitchBend;

          if (voice.period != 0) {
            if (voice.period < value) {
              voice.period += sample.portamento;
              if (voice.period > value) voice.period = value;
            } else {
              voice.period -= sample.portamento;
              if (voice.period < value) voice.period = value;
            }
          } else
            voice.period = value;
        }

        if (voice.vibratoCtr == 0) {
          voice.vibratoPeriod = voice.vibratoPos * sample.vibratoStep;

          if ((voice.status & 1) == 0) {
            voice.vibratoPos++;
            if (voice.vibratoPos == voice.vibratoDir) voice.status ^= 1;
          } else {
            voice.vibratoPos--;
            if (voice.vibratoPos == 0) voice.status ^= 1;
          }
        } else
          voice.vibratoCtr--;

        if (sample.pitchBend < 0) voice.pitchBend += sample.pitchBend;
          else voice.pitchBend -= sample.pitchBend;

        if (voice.row) {
          row = voice.row;

          switch (row.data1) {
            case 0:
              break;
            case 1:
              value = row.data2 & 15;
              if (value) speed = value;
              break;
            case 2:
              voice.pitchBend -= row.data2;
              break;
            case 3:
              voice.pitchBend += row.data2;
              break;
            case 4:
              amiga.filter.active = row.data2;
              break;
            case 5:
              sample.vibratoWait = row.data2;
              break;
            case 6:
              sample.vibratoStep = row.data2;
            case 7:
              sample.vibratoLen = row.data2;
              break;
            case 8:
              sample.pitchBend = row.data2;
              break;
            case 9:
              sample.portamento = row.data2;
              break;
            case 10:
              value = row.data2;
              if (value > 64) value = 64;
              sample.volume = 64;
              break;
            case 11:
              sample.arpeggio[0] = row.data2;
              break;
            case 12:
              sample.arpeggio[1] = row.data2;
              break;
            case 13:
              sample.arpeggio[2] = row.data2;
              break;
            case 14:
              sample.arpeggio[3] = row.data2;
              break;
            case 15:
              sample.arpeggio[4] = row.data2;
              break;
            case 16:
              sample.arpeggio[5] = row.data2;
              break;
            case 17:
              sample.arpeggio[6] = row.data2;
              break;
            case 18:
              sample.arpeggio[7] = row.data2;
              break;
            case 19:
              sample.arpeggio[0] = sample.arpeggio[4] = row.data2;
              break;
            case 20:
              sample.arpeggio[1] = sample.arpeggio[5] = row.data2;
              break;
            case 21:
              sample.arpeggio[2] = sample.arpeggio[6] = row.data2;
              break;
            case 22:
              sample.arpeggio[3] = sample.arpeggio[7] = row.data2;
              break;
            case 23:
              value = row.data2;
              if (value > 64) value = 64;
              sample.attackStep = value;
              break;
            case 24:
              sample.attackDelay = row.data2;
              break;
            case 25:
              value = row.data2;
              if (value > 64) value = 64;
              sample.decayStep = value;
              break;
            case 26:
              sample.decayDelay = row.data2;
              break;
            case 27:
              sample.sustain = row.data2 & (sample.sustain & 255);
              break;
            case 28:
              sample.sustain = (sample.sustain & 65280) + row.data2;
              break;
            case 29:
              value = row.data2;
              if (value > 64) value = 64;
              sample.releaseStep = value;
              break;
            case 30:
              sample.releaseDelay = row.data2;
              break;
          }
        }

        if (sample.portamento)
          value = voice.period;
        else {
          value = PERIODS[int(voice.note + sample.arpeggio[voice.arpeggioPos])];
          voice.arpeggioPos = ++voice.arpeggioPos & 7;
          value -= (sample.vibratoLen * sample.vibratoStep);
          value += voice.pitchBend;
          voice.period = 0;
        }

        chan.period = value + voice.vibratoPeriod;
        adsr  = voice.status & 14;
        value = voice.volume;

        if (adsr == 0) {
          if (voice.attackCtr == 0) {
            voice.attackCtr = sample.attackDelay;
            value += sample.attackStep;

            if (value >= 64) {
              adsr |= 2;
              voice.status |= 2;
              value = 64;
            }
          } else
            voice.attackCtr--;
        }

        if (adsr == 2) {
          if (voice.decayCtr == 0) {
            voice.decayCtr = sample.decayDelay;
            value -= sample.decayStep;

            if (value <= sample.volume) {
              adsr |= 6;
              voice.status |= 6;
              value = sample.volume;
            }
          } else
            voice.decayCtr--;
        }

        if (adsr == 6) {
          if (voice.sustain == 0) {
            adsr |= 14;
            voice.sustain |= 14;
          } else
            voice.sustain--;
        }

        if (adsr == 14) {
          if (voice.releaseCtr == 0) {
            voice.releaseCtr = sample.releaseDelay;
            value -= sample.releaseStep;

            if (value < 0) {
              voice.status &= 9;
              value = 0;
            }
          } else
            voice.releaseCtr--;
        }

        chan.volume  = voice.volume = value;
        chan.enabled = 1;

        if (!sample.synth) {
          if (sample.loop) {
            chan.pointer = sample.loopPtr;
            chan.length  = sample.repeat;
          } else {
            chan.pointer = amiga.loopPtr;
            chan.length  = 2;
          }
        }
      }
    }

    override protected function initialize():void {
      var i:int, voice:D1Data;
      super.initialize();
      speed = 6;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.sample = samples[20];
      }
    }
  }
}