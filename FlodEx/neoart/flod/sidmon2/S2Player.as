/* Flod SidMon2 Replay 1.02
   2009/12/30
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
   OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
   IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.sidmon2 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class S2Player extends AmigaPlayer {
    public var song:S2Song;

    private var voices:Vector.<S2Voice>;

    private var curStep:int;
    private var curPattern:int;
    private var patternLen:int;
    private var arpeggio:Vector.<int>;
    private var arpeggioStep:int;

    private const PERIODS:Vector.<int> = Vector.<int>([0,
      5760,5424,5120,4832,4560,4304,4064,3840,3616,3424,3232,3048,
      2880,2712,2560,2416,2280,2152,2032,1920,1808,1712,1616,1524,
      1440,1356,1280,1208,1140,1076,1016,0960,0904,0856,0808,0762,
      0720,0678,0640,0604,0570,0538,0508,0480,0453,0428,0404,0381,
      0360,0339,0320,0302,0285,0269,0254,0240,0226,0214,0202,0190,
      0180,0170,0160,0151,0143,0135,0127,0120,0113,0107,0101,0095]);

    public function S2Player() {
      PERIODS.fixed = true;
      voices    = new Vector.<S2Voice>(4, true);
      voices[0] = new S2Voice();
      voices[1] = new S2Voice();
      voices[2] = new S2Voice();
      voices[3] = new S2Voice();
      arpeggio  = new Vector.<int>(4, true);
    }

    override public function load(stream:ByteArray):int {
      song = new S2Song();
      supported = song.initialize(stream, amiga);
      return supported;
    }

    override protected function initialize():void {
      var i:int, step:S2Step, voice:S2Voice;
      amiga.initialize();

      speed = timer = song.speed;
      complete      = 0;
      curStep       = 0;
      curPattern    = 0;
      patternLen    = 64;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.instr  = song.instruments[0];
        voice.sample = song.dummy;
        arpeggio[i] = 0;
      }
    }

    override protected function process():void {
      var chan:AmigaChannel, com:S2Command, i:int, instr:S2Instrument, sample:S2Sample, value:int, voice:S2Voice;

      //arpeggioStep = ++arpeggioStep & 3;
      if (++arpeggioStep == 3) arpeggioStep = 0;

      if (++timer >= speed) {
        timer = 0;

        for (i = 0; i < 4; ++i) {
          chan  = amiga.channels[i];
          voice = voices[i];
          voice.dma = voice.note = 0;

          if (curPattern == 0) {
            voice.step    = song.steps[int(curStep + i * song.length)];
            voice.pattern = voice.step.pattern;
            voice.timer = 0;
          }

          if (--voice.timer < 0) {
            voice.com   = com = song.patterns[voice.pattern++];
            voice.timer = com.timer;

            if (com.note) {
              voice.dma  = 1;
              voice.note = com.note + voice.step.transpose;
              chan.enabled = 0;
            }
          }

          voice.pitchbend = 0;

          if (voice.note) {
            voice.waveCnt      = voice.sustainCnt     = 0;
            voice.arpeggioCnt  = voice.arpeggioStep   = 0;
            voice.vibratoCnt   = voice.vibratoStep    = 0;
            voice.pitchbendCnt = voice.noteSlideSpeed = 0;
            voice.adsrStep     = 4;
            voice.volume       = 0;

            if (com.instrument) {
              voice.instrument = com.instrument;
              voice.instr      = song.instruments[int(voice.instrument + voice.step.soundTranspose)];
              voice.sample     = song.samples[song.waves[voice.instr.wave]];
            }

            voice.original = voice.note + song.arpeggios[voice.instr.arpeggio];
            voice.period   = chan.period = PERIODS[voice.original];

            sample = voice.sample;
            chan.pointer = sample.pointer;
            chan.length  = sample.length;
            chan.enabled = voice.dma;
            chan.pointer = sample.loopPtr;
            chan.length  = sample.repeatLen;
          }
        }

        if (++curPattern == patternLen) {
          curPattern = 0;

          if (++curStep == song.length) {
            curStep  = 0;
            complete = 1;
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

        if (sample.negCounter == 0) {
          sample.negCounter = sample.negSpeed;
          if (sample.negDirection == 0) continue;

          value = sample.negStart + sample.negStep;
          amiga.samples[value] = ~amiga.samples[value];
          sample.negStep += sample.negOffset;
          value = sample.negLength - 1;

          if (sample.negStep < 0) {
            if (sample.negDirection == 2) {
              sample.negStep = value;
            } else {
              sample.negOffset = ~sample.negOffset + 1;
              sample.negStep += sample.negOffset;
            }
          } else if (value < sample.negStep) {
            if (sample.negDirection == 1) {
              sample.negStep = 0;
            } else {
              sample.negOffset = ~sample.negOffset + 1;
              sample.negStep += sample.negOffset;
            }
          }
        } else {
          sample.negCounter = --sample.negCounter & 31;
        }
      }

      for (i = 0; i < 4; ++i) {
        voice  = voices[i];
        if (!voice.sample) continue;
        sample = voice.sample;
        sample.negToggle = 0;
      }

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        chan  = amiga.channels[i];
        instr = voice.instr;

        switch (voice.adsrStep) {
          case 0:
            break;
          case 4:
            voice.volume += instr.attackSpeed;
            if (instr.attackMax <= voice.volume) {
              voice.volume = instr.attackMax;
              voice.adsrStep--;
            }
            break;
          case 3:
            if (instr.decaySpeed == 0) {
              voice.adsrStep--;
            } else {
              voice.volume -= instr.decaySpeed;
              if (instr.decayMin >= voice.volume) {
                voice.volume = instr.decayMin;
                voice.adsrStep--;
              }
            }
            break;
          case 2:
            if (voice.sustainCnt == instr.sustain) voice.adsrStep--;
              else voice.sustainCnt++;
            break;
          case 1:
            voice.volume -= instr.releaseSpeed;
            if (instr.releaseMin >= voice.volume) {
              voice.volume = instr.releaseMin;
              voice.adsrStep--;
            }
            break;
        }

        chan.volume = voice.volume >> 2;

        if (instr.waveLength) {
          if (voice.waveCnt == instr.waveDelay) {
            voice.waveCnt = instr.waveDelay - instr.waveSpeed;
            if (voice.waveStep == instr.waveLength) voice.waveStep = 0;
              else voice.waveStep++;

            sample = song.samples[song.waves[int(instr.wave + voice.waveStep)]];
            voice.sample = sample;
            chan.pointer = sample.pointer;
            chan.length  = sample.length;
          } else {
            voice.waveCnt++;
          }
        }

        if (instr.arpeggioLength) {
          if (voice.arpeggioCnt == instr.arpeggioDelay) {
            voice.arpeggioCnt = instr.arpeggioDelay - instr.arpeggioSpeed;
            if (voice.arpeggioStep == instr.arpeggioLength) voice.arpeggioStep = 0;
              else voice.arpeggioStep++;

            value = voice.original + song.arpeggios[int(instr.arpeggio + voice.arpeggioStep)];
            voice.period = PERIODS[value];
          } else {
            voice.arpeggioCnt++;
          }
        }

        com = voice.com;

        if (timer == 0) {
          switch (com.fx) {
            case 0:
              break;
            case 0x70: //ARPEGGIO
              arpeggio[0] = com.info >> 4;
              arpeggio[2] = com.info & 15;
              value = voice.original + arpeggio[arpeggioStep];
              voice.period = PERIODS[value];
              break;
            case 0x71: //PITCH UP
              voice.pitchbend = ~com.info + 1;
              break;
            case 0x72: //PITCH DOWN
              voice.pitchbend = com.info;
              break;
            case 0x73: //VOLUME UP
              if (voice.adsrStep != 0) break;
              if (voice.instrument != 0) voice.volume = instr.attackMax;
              voice.volume += com.info << 2;
              if (voice.volume >= 256) voice.volume = -1;
              break;
            case 0x74: //VOLUME DOWN
              if (voice.adsrStep != 0) break;
              if (voice.instrument != 0) voice.volume = instr.attackMax;
              voice.volume -= com.info << 2;
              if (voice.volume < 0) voice.volume = 0;
              break;
            }
        }

        switch (com.fx) {
          case 0:
            break;
          case 0x75: //SET ADSR ATTACK
            instr.attackMax   = com.info;
            instr.attackSpeed = com.info;
            break;
          case 0x76: //SET PATTERN LENGTH
            patternLen = com.info;
            break;
          case 0x7c: //SET VOLUME
            chan.volume  = com.info;
            voice.volume = com.info << 2;
            if (voice.volume >= 255) voice.volume = 255;
            break;
          case 0x7f: //SET SPEED
            value = com.info & 15;
            if (value) speed = value;
            break;
        }

        if (instr.vibratoLength) {
          if (voice.vibratoCnt == instr.vibratoDelay) {
            voice.vibratoCnt = instr.vibratoDelay - instr.vibratoSpeed;
            if (voice.vibratoStep == instr.vibratoLength) voice.vibratoStep = 0;
              else voice.vibratoStep++;

            value = song.vibratos[int(instr.vibrato + voice.vibratoStep)];
            voice.period += value;
          } else {
            voice.vibratoCnt++;
          }
        }

        if (instr.pitchbend) {
          if (voice.pitchbendCnt == instr.pitchbendDelay) {
            voice.pitchbend += instr.pitchbend;
          } else {
            voice.pitchbendCnt++;
          }
        }

        if (com.info != 0) {
          if (com.fx != 0 && com.fx < 0x70) {
            //voice.noteSlideTo = PERIODS[com.fx];
            voice.noteSlideTo = PERIODS[int(com.fx + voice.step.transpose)];

            value = com.info;
            if ((voice.noteSlideTo - voice.period) < 0) value = ~value + 1;
            voice.noteSlideSpeed = value;
          }
        }

        if (voice.noteSlideTo != 0 && voice.noteSlideSpeed != 0) {
          voice.period += voice.noteSlideSpeed;

          if ((voice.noteSlideSpeed < 0 && voice.period < voice.noteSlideTo) ||
              (voice.noteSlideSpeed > 0 && voice.period > voice.noteSlideTo)) {
            voice.noteSlideSpeed = 0;
            voice.period = voice.noteSlideTo;
          }
        }

        voice.period += voice.pitchbend;

        if (voice.period < 95) voice.period = 95;
          else if (voice.period > 5760) voice.period = 5760;

        chan.period = voice.period;
      }
    }
  }
}