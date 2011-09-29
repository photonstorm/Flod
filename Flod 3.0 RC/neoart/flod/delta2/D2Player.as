package neoart.flod.delta2 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class D2Player extends AmigaPlayer {
    internal var
      tracks    : Vector.<D2Step>,
      patterns  : Vector.<AmigaRow>,
      samples   : Vector.<D2Sample>,
      data      : Vector.<int>,
      arpeggios : Vector.<int>;
    private var
      voices    : Vector.<D2Data>,
      noise     : uint;

    private const
      PERIODS : Vector.<int> = Vector.<int>([
      0000,6848,6464,6096,5760,5424,5120,4832,4560,4304,4064,3840,3616,3424,3232,
      3048,2880,2712,2560,2416,2280,2152,2032,1920,1808,1712,1616,1524,1440,1356,
      1280,1208,1140,1076,1016,0960,0904,0856,0808,0762,0720,0678,0640,0604,0570,
      0538,0508,0480,0452,0428,0404,0381,0360,0339,0320,0302,0285,0269,0254,0240,
      0226,0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113,0113,0113,
      0113,0113,0113,0113,0113,0113,0113,0113,0113,0113]);

    public function D2Player(amiga:Amiga = null) {
      super(amiga);
      PERIODS.fixed = true;

      arpeggios = new Vector.<int>(1024, true);
      voices    = new Vector.<D2Data>(4, true);

      voices[0] = new D2Data();
      voices[1] = new D2Data();
      voices[2] = new D2Data();
      voices[3] = new D2Data();
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      D2Loader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, level:int, row:AmigaRow, sample:D2Sample, value:int, voice:D2Data;

      for (i = 0; i < 64;) {
        noise = (noise << 7) | (noise >>> 25);
        noise += 0x6eca756d;
        noise ^= 0x9e59a92b;

        value = (noise >>> 24) & 255;
        if (value > 127) value |= -256;
        amiga.memory[i++] = value;

        value = (noise >>> 16) & 255;
        if (value > 127) value |= -256;
        amiga.memory[i++] = value;

        value = (noise >>> 8) & 255;
        if (value > 127) value |= -256;
        amiga.memory[i++] = value;

        value = noise & 255;
        if (value > 127) value |= -256;
        amiga.memory[i++] = value;
      }
      if (--timer < 0) timer = speed;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        if (voice.trackLen < 1) continue;
        chan = amiga.channels[i];
        sample = voice.sample;

        if (sample.synth) {
          chan.pointer = sample.loopPtr;
          chan.length  = sample.repeat;
        }

        if (timer == 0) {
          if (voice.patternPos == 0) {
            voice.step = tracks[int(voice.trackPtr + voice.trackPos)];
            if (++voice.trackPos == voice.trackLen)
              voice.trackPos = voice.restart;
          }
          row = voice.row = patterns[int(voice.step.pattern + voice.patternPos)];

          if (row.note) {
            chan.enabled = 0;
            voice.note = row.note;
            voice.period = PERIODS[int(row.note + voice.step.transpose)];

            sample = voice.sample = samples[row.sample];

            if (sample.synth < 0) {
              chan.pointer = sample.pointer;
              chan.length  = sample.length;
            }
            voice.arpeggioPos    = 0;
            voice.tableCtr       = 0;
            voice.tablePos       = 0;
            voice.vibratoCtr     = sample.vibratos[1];
            voice.vibratoPos     = 0;
            voice.vibratoDir     = 0;
            voice.vibratoPeriod  = 0;
            voice.vibratoSustain = sample.vibratos[2];
            voice.volume         = 0;
            voice.volumePos      = 0;
            voice.volumeSustain  = 0;
          }

          switch (row.data1) {
            case -1:
              break;
            case 0:
              speed = row.data2 & 15;
              break;
            case 1:
              amiga.filter.active = row.data2;
              break;
            case 2:
              voice.pitchBend = ~(row.data2 & 255) + 1;
              break;
            case 3:
              voice.pitchBend = row.data2 & 255;
              break;
            case 4:
              voice.portamento = row.data2;
              break;
            case 5:
              voice.volumeMax = row.data2 & 63;
              break;
            case 6:
              amiga.volume = row.data2;
              break;
            case 7:
              voice.arpeggioPtr = (row.data2 & 63) << 4;
              break;
          }
          voice.patternPos = ++voice.patternPos & 15;
        }
        sample = voice.sample;

        if (sample.synth >= 0) {
          if (voice.tableCtr) {
            voice.tableCtr--;
          } else {
            voice.tableCtr = sample.index;
            value = sample.table[voice.tablePos];

            if (value == 0xff) {
              value = sample.table[++voice.tablePos];
              if (value != 0xff) {
                voice.tablePos = value;
                value = sample.table[voice.tablePos];
              }
            }

            if (value != 0xff) {
              chan.pointer = value << 8;
              chan.length  = sample.length;
              if (++voice.tablePos > 47) voice.tablePos = 0;
            }
          }
        }
        value = sample.vibratos[voice.vibratoPos];

        if (voice.vibratoDir) voice.vibratoPeriod -= value;
          else voice.vibratoPeriod += value;

        if (--voice.vibratoCtr == 0) {
          voice.vibratoCtr = sample.vibratos[int(voice.vibratoPos + 1)];
          voice.vibratoDir = ~voice.vibratoDir;
        }

        if (voice.vibratoSustain) {
          voice.vibratoSustain--;
        } else {
          voice.vibratoPos += 3;
          if (voice.vibratoPos == 15) voice.vibratoPos = 12;
          voice.vibratoSustain = sample.vibratos[int(voice.vibratoPos + 2)];
        }

        if (voice.volumeSustain) {
          voice.volumeSustain--;
        } else {
          value = sample.volumes[voice.volumePos];
          level = sample.volumes[int(voice.volumePos + 1)];

          if (level < voice.volume) {
            voice.volume -= value;
            if (voice.volume < level) {
              voice.volume = level;
              voice.volumePos += 3;
              voice.volumeSustain = sample.volumes[int(voice.volumePos - 1)];
            }
          } else {
            voice.volume += value;
            if (voice.volume > level) {
              voice.volume = level;
              voice.volumePos += 3;
              if (voice.volumePos == 15) voice.volumePos = 12;
              voice.volumeSustain = sample.volumes[int(voice.volumePos - 1)];
            }
          }
        }

        if (voice.portamento) {
          if (voice.period < voice.finalPeriod) {
            voice.finalPeriod -= voice.portamento;
            if (voice.finalPeriod < voice.period) voice.finalPeriod = voice.period;
          } else {
            voice.finalPeriod += voice.portamento;
            if (voice.finalPeriod > voice.period) voice.finalPeriod = voice.period;
          }
        }
        value = arpeggios[int(voice.arpeggioPtr + voice.arpeggioPos)];

        if (value == -128) {
          voice.arpeggioPos = 0;
          value = arpeggios[voice.arpeggioPtr]
        }
        voice.arpeggioPos = ++voice.arpeggioPos & 15;

        if (voice.portamento == 0) {
          value = voice.note + voice.step.transpose + value;
          if (value < 0) value = 0;
          voice.finalPeriod = PERIODS[value];
        }

        voice.vibratoPeriod -= (sample.pitchBend - voice.pitchBend);
        chan.period = voice.finalPeriod + voice.vibratoPeriod;

        value = (voice.volume >> 2) & 63;
        if (value > voice.volumeMax) value = voice.volumeMax;
        chan.volume  = value;
        chan.enabled = 1;
      }
    }

    override protected function initialize():void {
      var i:int, last:int = samples.length - 1, voice:D2Data;
      super.initialize();
      speed = 5;
      timer = 0;
      noise = 0;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.sample   = samples[last];
        voice.trackPtr = data[i];
        voice.restart  = data[int(i + 4)];
        voice.trackLen = data[int(i + 8)];
      }
    }
  }
}