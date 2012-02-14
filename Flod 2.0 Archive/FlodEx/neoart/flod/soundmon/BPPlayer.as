/* Flod Brian Postma's SoundMon Replay 1.01
   2009/12/30
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.soundmon {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class BPPlayer extends AmigaPlayer {
    public var song:BPSong;

    private var voices:Vector.<BPVoice>;
    private var buffer:Vector.<int>;
    private var curStep:int;
    private var curPattern:int;
    private var nextStep:int;
    private var jumpFlag:int;
    private var repeatCnt:int;
    private var arpeggioCnt:int;
    private var vibratoPos:int;

    private const PERIODS:Vector.<int> = Vector.<int>([
      6848,6464,6080,5760,5440,5120,4832,4576,4320,4064,3840,3616,
      3424,3232,3040,2880,2720,2560,2416,2288,2160,2032,1920,1808,
      1712,1616,1520,1440,1360,1280,1208,1144,1080,1016,0960,0904,
      0856,0808,0760,0720,0680,0640,0604,0572,0540,0508,0480,0452,
      0428,0404,0380,0360,0340,0320,0302,0286,0270,0254,0240,0226,
      0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113,
      0107,0101,0095,0090,0085,0080,0076,0072,0068,0064,0060,0057]);

    private const VIBRATO:Vector.<int> = Vector.<int>([0,64,128,64,0,-64,-128,-64]);

    private const ARPEGGIO_ONCE:   int = 0;
    private const SET_VOLUME:      int = 1;
    private const SET_SPEED:       int = 2;
    private const SET_FILTER:      int = 3;
    private const PORTAMENTO_UP:   int = 4;
    private const PORTAMENTO_DOWN: int = 5;
    private const SET_VIBRATO:     int = 6;
    private const STEP_JUMP:       int = 7;
    private const SET_AUTOSLIDE:   int = 8;
    private const SET_AUTOARPEGGIO:int = 9;
    private const TRANSPOSE:       int = 10;
    private const CHANGE_EFFECT:   int = 11;
    private const CHANGE_INVERSION:int = 13;
    private const NO_EG_RESET:     int = 14;
    private const NO_EG_ADSR_RESET:int = 15;

    private const FX_AVERAGING:         int = 1;
    private const FX_INVERSION:         int = 2;
    private const FX_BACKWARD_INVERSION:int = 3;
    private const FX_TRANSFORM:         int = 4;
    private const FX_BACKWARD_TRANSFORM:int = 5;
    private const FX_WAVE_CHANGE:       int = 6;

    public function BPPlayer() {
      PERIODS.fixed = true;
      VIBRATO.fixed = true;
      buffer = new Vector.<int>(128, true);
      voices = new Vector.<BPVoice>(4, true);
      voices[0] = new BPVoice();
      voices[1] = new BPVoice();
      voices[2] = new BPVoice();
      voices[3] = new BPVoice();
    }

    override public function load(stream:ByteArray):int {
      song = new BPSong();
      supported = song.initialize(stream, amiga);
      return supported;
    }

    override protected function initialize():void {
      var i:int, voice:BPVoice;
      amiga.initialize();

      timer       = 1;
      speed       = 6;
      complete    = 0;
      curStep     = 0;
      curPattern  = 0;
      nextStep    = 0;
      jumpFlag    = 0;
      repeatCnt   = 0;
      arpeggioCnt = 1;
      vibratoPos  = 0;

      for (i = 0; i < 128; ++i) buffer[i] = 0;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.samplePtr = amiga.empty;
      }
    }

    override protected function reset():void {
      var i:int, j:int, l:int, s:int, voice:BPVoice;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        if (voice.synthPtr < 0) continue;
        s = i << 5;
        l = voice.synthPtr + 32;
        for (j = voice.synthPtr; j < l; ++j) amiga.samples[j] = buffer[s++];
      }
    }

    override protected function process():void {
      var chan:AmigaChannel, com:BPCommand, d:int, data:int, i:int, instr:int, l:int, note:int, option:int, s:int, sample:BPSample, step:BPStep, tables:Vector.<int>, voice:BPVoice;
      arpeggioCnt = --arpeggioCnt & 3;
      vibratoPos  = ++vibratoPos  & 7;

      for (i = 0; i < 4; ++i) {
        chan  = amiga.channels[i];
        voice = voices[i];
        voice.period += voice.autoSlide;

        if (voice.vibrato) chan.period = voice.period + VIBRATO[vibratoPos] / voice.vibrato;
          else chan.period = voice.period;

        chan.pointer = voice.samplePtr;
        chan.length  = voice.sampleLen;

        if (voice.arpeggio || voice.autoArpeggio) {
          note = voice.note;

          if (arpeggioCnt == 0) {
            note += ((voice.arpeggio & 0xf0) >> 4) + ((voice.autoArpeggio & 0xf0) >> 4);
          } else if (arpeggioCnt == 1) {
            note += (voice.arpeggio & 0x0f) + (voice.autoArpeggio & 0x0f);
          }

          voice.period  = chan.period = PERIODS[int(note + 35)];
          voice.restart = 0;
        }

        if (!voice.synth) continue;
        sample = song.samples[voice.sample];
        tables = amiga.samples;

        if (voice.adsrControl) {
          if (--voice.adsrCnt == 0) {
            voice.adsrCnt = sample.adsrSpeed;
            data = (128 + tables[int((sample.adsrTable << 6) + voice.adsrPtr)]) >> 2;
            chan.volume = (data * voice.volume) >> 6;

            if (++voice.adsrPtr == sample.adsrLength) {
              voice.adsrPtr = 0;
              if (voice.adsrControl == 1) voice.adsrControl = 0;
            }
          }
        }

        if (voice.lfoControl) {
          if (--voice.lfoCnt == 0) {
            voice.lfoCnt = sample.lfoSpeed;
            data = tables[int((sample.lfoTable << 6) + voice.lfoPtr)];
            if (sample.lfoDepth) data /= sample.lfoDepth;
            chan.period = voice.period + data;

            if (++voice.lfoPtr == sample.lfoLength) {
              voice.lfoPtr = 0;
              if (voice.lfoControl == 1) voice.lfoControl = 0;
            }
          }
        }

        if (voice.synthPtr < 0) continue;

        if (voice.egControl) {
          if (--voice.egCnt == 0) {
            voice.egCnt = sample.egSpeed;
            data = voice.egValue;
            voice.egValue = (128 + tables[int((sample.egTable << 6) + voice.egPtr)]) >> 3;

            if (voice.egValue != data) {
              s = (i << 5) + data;
              d = voice.synthPtr + data;
              l = d;

              if (voice.egValue < data) {
                data -= voice.egValue;
                l -= data;
                for (d; d > l;) tables[--d] = buffer[--s];
              } else {
                data = voice.egValue - data;
                l += data;
                for (d; d < l;) tables[d++] = (~buffer[s++] + 1);
              }
            }

            if (++voice.egPtr == sample.egLength) {
              voice.egPtr = 0;
              if (voice.egControl == 1) voice.egControl = 0;
            }
          }
        }

        switch (voice.fxControl) {
          case 0:
            break;
          case FX_AVERAGING:
            if (--voice.fxCnt == 0) {
              voice.fxCnt = sample.fxSpeed;
              d = voice.synthPtr;
              l = voice.synthPtr + 32;
              data = d > 0 ? tables[int(d - 1)] : 0;

              for (d; d < l;) {
                data = (data + tables[int(d + 1)]) >> 1;
                tables[d++] = data;
              }
            }
            break;
          case FX_INVERSION:
            s = (i << 5) + 31;
            l = voice.synthPtr + 32;
            data = sample.fxSpeed;

            for (d = voice.synthPtr; d < l; ++d) {
              if (buffer[s] < tables[d]) {
                tables[d] -= data;
              } else if (buffer[s] > tables[d]) {
                tables[d] += data;
              }
              --s;
            }
            break;
          case FX_BACKWARD_INVERSION:
          case FX_BACKWARD_TRANSFORM:
            s = i << 5;
            l = voice.synthPtr + 32;
            data = sample.fxSpeed;

            for (d = voice.synthPtr; d < l; ++d) {
              if (buffer[s] < tables[d]) {
                tables[d] -= data;
              } else if (buffer[s] > tables[d]) {
                tables[d] += data;
              }
              ++s;
            }
            break;
          case FX_TRANSFORM:
            s = voice.synthPtr + 64;
            l = voice.synthPtr + 32;
            data = sample.fxSpeed;

            for (d = voice.synthPtr; d < l; ++d) {
              if (tables[s] < tables[d]) {
                tables[d] -= data;
              } else if (tables[s] > tables[d]) {
                tables[d] += data;
              }
              ++s;
            }
            break;
          case FX_WAVE_CHANGE:
            if (--voice.fxCnt == 0) {
              voice.fxControl = 0;
              voice.fxCnt = 1;
              s = voice.synthPtr + 64;
              l = voice.synthPtr + 32;
              for (d = voice.synthPtr; d < l; ++d) tables[d] = tables[s++];
            }
            break;
        }

        if (voice.modControl) {
          if (--voice.modCnt == 0) {
            voice.modCnt = sample.modSpeed;
            tables[int(voice.synthPtr + 32)] = tables[int((sample.modTable << 6) + voice.modPtr)];

            if (++voice.modPtr == sample.modLength) {
              voice.modPtr = 0;
              if (voice.modControl == 1) voice.modControl = 0;
            }
          }
        }
      }

      if (--timer == 0) {
        timer = speed;

        for (i = 0; i < 4; ++i) {
          chan  = amiga.channels[i];
          voice = voices[i];
          voice.enabled = 0;

          step   = song.steps[int((curStep << 2) + i)];
          com    = song.patterns[int(curPattern + ((step.pattern - 1) << 4))];
          note   = com.note;
          option = com.option;
          data   = com.data;

          if (note) {
            voice.autoArpeggio = voice.autoSlide = voice.vibrato = 0;

            if (option != TRANSPOSE || (data & 0xf0) == 0) note += step.transpose;
            voice.note = note;
            voice.period = PERIODS[int(note + 35)];

            if (option < CHANGE_INVERSION) voice.restart = voice.volumeDef = 1;
              else voice.restart = 0;

            instr = com.sample;
            if (instr == 0) instr = voice.sample;
            if (option != TRANSPOSE || (data & 0x0f) == 0) instr += step.soundTranspose;

            if (option < CHANGE_INVERSION && (!voice.synth || (voice.sample != instr))) {
              voice.sample  = instr;
              voice.enabled = 1;
            }
          }

          switch (option) {
            case ARPEGGIO_ONCE:
              voice.arpeggio = data;
              break;
            case SET_VOLUME:
              voice.volume = data;
              voice.volumeDef = 0;
              if (song.version < song.SOUNDMON_V3 || !voice.synth) chan.volume = voice.volume;
              break;
            case SET_SPEED:
              timer = speed = data;
              break;
            case SET_FILTER:
              amiga.filter.active = data;
              break;
            case PORTAMENTO_UP:
              voice.period -= data;
              voice.arpeggio = 0;
              break;
            case PORTAMENTO_DOWN:
              voice.period += data;
              voice.arpeggio = 0;
              break;
            case SET_VIBRATO:
              if (song.version == song.SOUNDMON_V3) voice.vibrato = data;
                else repeatCnt = data;
              break;
            case STEP_JUMP:
              if (song.version == song.SOUNDMON_V3) {
                nextStep = data;
                jumpFlag = 1;
              } else if (--repeatCnt == 0) {
                curStep = data;
              }
              break;
            case SET_AUTOSLIDE:
              voice.autoSlide = data;
              break;
            case SET_AUTOARPEGGIO:
              voice.autoArpeggio = data;
              if (song.version == song.SOUNDMON_V3) {
                voice.adsrPtr = 0;
                if (!voice.adsrControl) voice.adsrControl = 1;
              }
              break;
            case CHANGE_EFFECT:
              voice.fxControl = data;
              break;
            case CHANGE_INVERSION:
              voice.autoArpeggio = data;
              voice.fxControl ^= 1;
              voice.adsrPtr = 0;
              if (!voice.adsrControl) voice.adsrControl = 1;
              break;
            case NO_EG_RESET:
              voice.autoArpeggio = data;
              voice.adsrPtr = 0;
              if (!voice.adsrControl) voice.adsrControl = 1;
              break;
            case NO_EG_ADSR_RESET:
              voice.autoArpeggio = data;
              break;
          }
        }

        if (jumpFlag) {
          curStep = nextStep;
          curPattern = jumpFlag = 0;
        } else if (++curPattern == 16) {
          curStep++;
          curPattern = 0;

          if (curStep >= song.length) {
            curStep  = 0;
            complete = 1;
          }
        }

        for (i = 0; i < 4; ++i) {
          chan  = amiga.channels[i];
          voice = voices[i];
          if (voice.enabled) voice.enabled = chan.enabled = 0;
          if (!voice.restart) continue;

          if (voice.synthPtr > -1) {
            s = i << 5;
            l = voice.synthPtr + 32;
            for (d = voice.synthPtr; d < l; ++d) tables[d] = buffer[s++];
            voice.synthPtr = -1;
          }
        }

        for (i = 0; i < 4; ++i) {
          chan  = amiga.channels[i];
          voice = voices[i];
          if (!voice.restart) continue;

          chan.period = voice.period;
          voice.restart = 0;
          sample = song.samples[voice.sample];
          tables = amiga.samples;

          if (sample.synth) {
            voice.synth   = 1;
            voice.egValue = 0;
            voice.adsrPtr = voice.lfoPtr = voice.egPtr = voice.modPtr = 0;

            voice.adsrCnt = 1;
            voice.lfoCnt  = sample.lfoDelay + 1;
            voice.egCnt   = sample.egDelay  + 1;
            voice.fxCnt   = sample.fxDelay  + 1;
            voice.modCnt  = sample.modDelay + 1;

            voice.adsrControl = sample.adsrControl;
            voice.lfoControl  = sample.lfoControl;
            voice.egControl   = sample.egControl;
            voice.fxControl   = sample.fxControl;
            voice.modControl  = sample.modControl;

            voice.samplePtr = chan.pointer = sample.pointer;
            voice.sampleLen = chan.length  = sample.length;

            if (voice.adsrControl) {
              data = (128 + tables[int(sample.adsrTable << 6)]) >> 2;

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
              s = i << 5;
              l = voice.synthPtr + 32;
              for (d = voice.synthPtr; d < l; ++d) buffer[s++] = tables[d];
            }
          } else {
            voice.synth = voice.lfoControl = 0;

            if (sample.pointer < 0) {
              voice.samplePtr = amiga.empty;
              voice.sampleLen = 2;
            } else {
              chan.pointer = sample.pointer;
              chan.length  = sample.length;
              chan.volume  = voice.volumeDef ? sample.volume : voice.volume;

              if (sample.repeatLen != 2) {
                voice.samplePtr = sample.loopPtr;
                voice.sampleLen = chan.length = sample.repeatLen;
              } else {
                voice.samplePtr = amiga.empty;
                voice.sampleLen = 2;
              }
            }
          }

          voice.enabled = chan.enabled = 1;
        }
      }
    }
  }
}