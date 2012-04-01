package neoart.flod.sidmon2 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class S2Player extends AmigaPlayer {
    internal var
      tracks      : Vector.<S2Step>,
      patterns    : Vector.<S2Row>,
      instruments : Vector.<S2Instrument>,
      samples     : Vector.<S2Sample>,
      arpeggios   : Vector.<int>,
      vibratos    : Vector.<int>,
      waves       : Vector.<int>,
      length      : int,
      speedDef    : int;
    private var
      voices      : Vector.<S2Data>,
      trackPos    : int,
      patternPos  : int,
      patternLen  : int,
      arpeggioFx  : Vector.<int>,
      arpeggioPos : int;

    private const
      PERIODS : Vector.<int> = Vector.<int>([0,
        5760,5424,5120,4832,4560,4304,4064,3840,3616,3424,3232,3048,
        2880,2712,2560,2416,2280,2152,2032,1920,1808,1712,1616,1524,
        1440,1356,1280,1208,1140,1076,1016,0960,0904,0856,0808,0762,
        0720,0678,0640,0604,0570,0538,0508,0480,0453,0428,0404,0381,
        0360,0339,0320,0302,0285,0269,0254,0240,0226,0214,0202,0190,
        0180,0170,0160,0151,0143,0135,0127,0120,0113,0107,0101,0095]);

    public function S2Player(amiga:Amiga = null) {
      super(amiga);
      PERIODS.fixed = true;

      arpeggioFx = new Vector.<int>(4, true);
      voices     = new Vector.<S2Data>(4, true);

      voices[0] = new S2Data();
      voices[1] = new S2Data();
      voices[2] = new S2Data();
      voices[3] = new S2Data();
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      S2Loader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, instr:S2Instrument, row:S2Row, sample:S2Sample, value:int, voice:S2Data;
      arpeggioPos = ++arpeggioPos & 3;

      if (++timer >= speed) {
        timer = 0;

        for (i = 0; i < 4; ++i) {
          voice = voices[i];
          chan  = amiga.channels[i];
          voice.enabled = voice.note = 0;

          if (patternPos == 0) {
            voice.step    = tracks[int(trackPos + i * length)];
            voice.pattern = voice.step.pattern;
            voice.timer   = 0;
          }
          if (--voice.timer < 0) {
            voice.row   = row = patterns[voice.pattern++];
            voice.timer = row.timer;

            if (row.note) {
              voice.enabled = 1;
              voice.note    = row.note + voice.step.transpose;
              chan.enabled  = 0;
            }
          }
          voice.pitchBend = 0;

          if (voice.note) {
            voice.waveCtr      = voice.sustainCtr     = 0;
            voice.arpeggioCtr  = voice.arpeggioPos    = 0;
            voice.vibratoCtr   = voice.vibratoPos     = 0;
            voice.pitchBendCtr = voice.noteSlideSpeed = 0;
            voice.adsrPos = 4;
            voice.volume  = 0;

            if (row.sample) {
              voice.instrument = row.sample;
              voice.instr  = instruments[int(voice.instrument + voice.step.soundTranspose)];
              voice.sample = samples[waves[voice.instr.wave]];
            }
            voice.original = voice.note + arpeggios[voice.instr.arpeggio];
            chan.period    = voice.period = PERIODS[voice.original];

            sample = voice.sample;
            chan.pointer = sample.pointer;
            chan.length  = sample.length;
            chan.enabled = voice.enabled;
            chan.pointer = sample.loopPtr;
            chan.length  = sample.repeat;
          }
        }
        if (++patternPos == patternLen) {
          patternPos = 0;

          if (++trackPos == length) {
            trackPos = 0;
            amiga.complete = 1;
          }
        }
      }

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        if (!voice.sample) continue;
        chan   = amiga.channels[i];
        sample = voice.sample;

        if (sample.negToggle) continue;
        sample.negToggle = 1;

        if (sample.negCtr) {
          sample.negCtr = --sample.negCtr & 31;
        } else {
          sample.negCtr = sample.negSpeed;
          if (sample.negDir == 0) continue;

          value = sample.negStart = sample.negPos;
          amiga.memory[value] = ~amiga.memory[value];
          sample.negPos += sample.negOffset;
          value = sample.negLen - 1;

          if (sample.negPos < 0) {
            if (sample.negDir == 2) {
              sample.negPos = value;
            } else {
              sample.negOffset = ~sample.negOffset + 1;
              sample.negPos += sample.negOffset;
            }
          } else if (value < sample.negPos) {
            if (sample.negDir == 1) {
              sample.negPos = 0;
            } else {
              sample.negOffset = ~sample.negOffset + 1;
              sample.negPos += sample.negOffset;
            }
          }
        }
      }

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        if (!voice.sample) continue;
        voice.sample.negToggle = 0;
      }

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        chan  = amiga.channels[i];
        instr = voice.instr;

        switch (voice.adsrPos) {
          case 0:
            break;
          case 4: //attack
            voice.volume += instr.attackSpeed;
            if (instr.attackMax <= voice.volume) {
              voice.volume = instr.attackMax;
              voice.adsrPos--;
            }
            break;
          case 3: //decay
            if (instr.decaySpeed == 0) {
              voice.adsrPos--;
            } else {
              voice.volume -= instr.decaySpeed;
              if (instr.decayMin >= voice.volume) {
                voice.volume = instr.decayMin;
                voice.adsrPos--;
              }
            }
            break;
          case 2: //sustain
            if (voice.sustainCtr == instr.sustain) voice.adsrPos--;
              else voice.sustainCtr--;
            break;
          case 1: //release
            voice.volume -= instr.releaseSpeed;
            if (instr.releaseMin >= voice.volume) {
              voice.volume = instr.releaseMin;
              voice.adsrPos--;
            }
            break;
        }
        chan.volume = voice.volume >> 2;

        if (instr.waveLen) {
          if (voice.waveCtr == instr.waveDelay) {
            voice.waveCtr = instr.waveDelay - instr.waveSpeed;
            if (voice.wavePos == instr.waveLen) voice.wavePos = 0;
              else voice.wavePos++;

            voice.sample = sample = samples[waves[int(instr.wave + voice.wavePos)]];
            chan.pointer = sample.pointer;
            chan.length  = sample.length;
          } else
            voice.waveCtr++;
        }

        if (instr.arpeggioLen) {
          if (voice.arpeggioCtr == instr.arpeggioDelay) {
            voice.arpeggioCtr = instr.arpeggioDelay - instr.arpeggioSpeed;
            if (voice.arpeggioPos == instr.arpeggioLen) voice.arpeggioPos = 0;
              else voice.arpeggioPos++;

            value = voice.original + arpeggios[int(instr.arpeggio + voice.arpeggioPos)];
            voice.period = PERIODS[value];
          } else
            voice.arpeggioCtr++;
        }
        row = voice.row;

        if (timer == 0) {
          switch (row.data1) {
            case 0:
              break;
            case 0x70: //arpeggio
              arpeggioFx[0] = row.data2 >> 4;
              arpeggioFx[2] = row.data2 & 15;
              value = voice.original + arpeggioFx[arpeggioPos];
              voice.period = PERIODS[value];
              break;
            case 0x71: //pitch up
              voice.pitchBend = ~row.data2 + 1;
              break;
            case 0x72: //pitch down
              voice.pitchBend = row.data2;
              break;
            case 0x73: //volume up
              if (voice.adsrPos != 0) break;
              if (voice.instrument != 0) voice.volume = instr.attackMax;
              voice.volume += row.data2 << 2;
              if (voice.volume >= 256) voice.volume = -1;
              break;
            case 0x74: //volume down
              if (voice.adsrPos != 0) break;
              if (voice.instrument != 0) voice.volume = instr.attackMax;
              voice.volume -= row.data2 << 2;
              if (voice.volume < 0) voice.volume = 0;
              break;
          }
        }

        switch (row.data1) {
          case 0:
            break;
          case 0x75: //set adsr attack
            instr.attackMax   = row.data2;
            instr.attackSpeed = row.data2;
            break;
          case 0x76: //set pattern length
            patternLen = row.data2;
            break;
          case 0x77: //set volume
            chan.volume  = row.data2;
            voice.volume = row.data2 << 2;
            if (voice.volume >= 255) voice.volume = 255;
            break;
          case 0x78: //set speed
            value = row.data2 & 15;
            if (value) speed = value;
            break;
        }

        if (instr.vibratoLen) {
          if (voice.vibratoCtr == instr.vibratoDelay) {
            voice.vibratoCtr = instr.vibratoDelay - instr.vibratoSpeed;
            if (voice.vibratoPos == instr.vibratoLen) voice.vibratoPos = 0;
              else voice.vibratoPos++;

            voice.period += vibratos[int(instr.vibrato + voice.vibratoPos)];
          } else
            voice.vibratoCtr++;
        }

        if (instr.pitchBend) {
          if (voice.pitchBendCtr == instr.pitchBendDelay) {
            voice.pitchBend += instr.pitchBend;
          } else
            voice.pitchBendCtr++;
        }

        if (row.data2) {
          if (row.data1 && row.data1 < 0x70) {
            voice.noteSlideTo = PERIODS[int(row.data1 + voice.step.transpose)];
            value = row.data2;
            if ((voice.noteSlideTo - voice.period) < 0) value = ~value + 1;
            voice.noteSlideSpeed = value;
          }
        }

        if (voice.noteSlideTo && voice.noteSlideSpeed) {
          voice.period += voice.noteSlideSpeed;

          if ((voice.noteSlideSpeed < 0 && voice.period < voice.noteSlideTo) ||
              (voice.noteSlideSpeed > 0 && voice.period > voice.noteSlideTo)) {
            voice.noteSlideSpeed = 0;
            voice.period = voice.noteSlideTo;
          }
        }

        voice.period += voice.pitchBend;
        if (voice.period < 95) voice.period = 95;
          else if (voice.period > 5760) voice.period = 5760;
        chan.period = voice.period;
      }
    }

    override protected function initialize():void {
      var i:int, voice:S2Data;
      super.initialize();
      speed      = speedDef;
      timer      = speedDef;
      trackPos   = 0;
      patternPos = 0;
      patternLen = 64;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.instr   = instruments[0];
        arpeggioFx[i] = 0;
      }
    }
  }
}