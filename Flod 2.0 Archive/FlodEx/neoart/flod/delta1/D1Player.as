/* Flod Delta Music 1 Replay 1.01
   2009/12/30
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.delta1 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class D1Player extends AmigaPlayer {
    public var song:D1Song;

    private var voices:Vector.<D1Voice>;

    private const PERIODS:Vector.<int> = Vector.<int>([
      0000,6848,6464,6096,5760,5424,5120,4832,4560,4304,4064,3840,
      3616,3424,3232,3048,2880,2712,2560,2416,2280,2152,2032,1920,
      1808,1712,1616,1524,1440,1356,1280,1208,1140,1076,0960,0904,
      0856,0808,0762,0720,0678,0640,0604,0570,0538,0508,0480,0452,
      0428,0404,0381,0360,0339,0320,0302,0285,0269,0254,0240,0226,
      0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113,
      0113,0113,0113,0113,0113,0113,0113,0113,0113,0113,0113,0113]);

    public function D1Player() {
      PERIODS.fixed = true;
      voices    = new Vector.<D1Voice>(4, true);
      voices[0] = new D1Voice();
      voices[1] = new D1Voice();
      voices[2] = new D1Voice();
      voices[3] = new D1Voice();
    }

    override public function load(stream:ByteArray):int {
      song = new D1Song();
      supported = song.initialize(stream, amiga);
      return supported;
    }

    override protected function initialize():void {
      var i:int, voice:D1Voice;
      amiga.initialize();

      speed    = song.speed;
      complete = 0;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.sample = song.samples[20];
		//voice.stepCnt = 0;
      }
    }

    override protected function process():void {
      var adsr:int, chan:AmigaChannel, com:D1Command, i:int, loopTable:int, sample:D1Sample, value:int, voice:D1Voice;

      for (i = 0; i < 4; ++i) {
        chan  = amiga.channels[i];
        voice = voices[i];

        if (--voice.timer == 0) {
          voice.timer = speed;

          if (voice.patternCnt == 0) {
            value = song.stepsPtr[i] + voice.stepCnt;
            voice.step = song.steps[value];

            if (voice.step.pattern < 0) {
              voice.stepCnt = voice.step.transpose;
              voice.step    = song.steps[int(song.stepsPtr[i] + voice.stepCnt)];
            }

            voice.stepCnt++;
          }

          //voice.com = com = song.patterns[int(voice.step.pattern + voice.patternCnt)];
		  com = song.patterns[int(voice.step.pattern + voice.patternCnt)];
		  if (com.effect != 0) voice.com = com;

          if (com.note) {
			voice.com = com;
            voice.note = com.note + voice.step.transpose;
            chan.enabled = 0;

            voice.arpeggioCnt = 0;
            voice.bendrate    = 0;
            voice.status      = 0;

            voice.sample = sample = song.samples[com.sample];

            if (!sample.synth) chan.pointer = sample.pointer;
            chan.length = sample.length;

            voice.tableCnt       = 0;
            voice.tablePos       = 0;
            voice.vibratoCnt     = sample.vibratoWait;
            voice.vibratoPos     = sample.vibratoLength;
            voice.vibratoCompare = sample.vibratoLength << 1;
            voice.volume         = 0;
            voice.attackCnt      = 0;
            voice.decayCnt       = 0;
            voice.sustain        = sample.sustain;
            voice.releaseCnt     = 0;
          }

          if (++voice.patternCnt == 16) voice.patternCnt = 0;
        }

        sample = voice.sample;

        if (sample.synth) {
          if (voice.tableCnt == 0) {
            voice.tableCnt = sample.tableDelay;
            do {
              loopTable = 1;
              if (voice.tablePos >= 48) voice.tablePos = 0;
              value = sample.table[voice.tablePos];

              if (value >= 0) {
                chan.pointer = sample.pointer + (value << 5);
                voice.tablePos++;
                loopTable = 0;
              } else if (value != -1) {
                sample.tableDelay = value & 127;
                voice.tablePos++;
              } else {
                voice.tablePos = sample.table[++voice.tablePos];
              }
            } while (loopTable);
          } else {
            voice.tableCnt--;
          }
        }

        if (sample.portamento) {
          value = PERIODS[voice.note] + voice.bendrate;

          if (voice.period == 0) {
            voice.period = value;
          } else if (value != voice.period) {
            if (voice.period < value) {
              voice.period += sample.portamento;
              if (voice.period > value) voice.period = value;
            } else {
              voice.period -= sample.portamento;
              if (voice.period < value) voice.period = value;
            }
          }
        }

        if (voice.vibratoCnt == 0) {
          voice.vibratoPeriod = voice.vibratoPos * sample.vibratoStep;

          if ((voice.status & 1) == 0) {
            voice.vibratoPos++;
            if (voice.vibratoPos == voice.vibratoCompare) voice.status ^= 1;
          } else {
            voice.vibratoPos--;
            if (voice.vibratoPos == 0) voice.status ^= 1;
          }
        } else {
          voice.vibratoCnt--;
        }

        if (sample.bendrate < 0) {
          voice.bendrate += sample.bendrate;
        } else {
          voice.bendrate -= sample.bendrate;
        }

        com = voice.com;
if (com) {
        switch (com.effect) {
          case 0:
            break;
          case 1:
            value = com.data & 15;
            if (value) speed = value;
            break;
          case 2:
            voice.bendrate -= com.data;
            break;
          case 3:
            voice.bendrate += com.data;
            break;
          case 4:
            amiga.filter.active = com.data;
            break;
          case 5:
            sample.vibratoWait = com.data;
            break;
          case 6:
            sample.vibratoStep = com.data;
            break;
          case 7:
            sample.vibratoLength = com.data;
            break;
          case 8:
            sample.bendrate = com.data;
            break;
          case 9:
            sample.portamento = com.data;
            break;
          case 10:
            value = com.data;
            if (value > 64) value = 64;
            sample.volume = value;
            break;
          case 11:
            sample.arpeggio[0] = com.data;
            break;
          case 12:
            sample.arpeggio[1] = com.data;
            break;
          case 13:
            sample.arpeggio[2] = com.data;
            break;
          case 14:
            sample.arpeggio[3] = com.data;
            break;
          case 15:
            sample.arpeggio[4] = com.data;
            break;
          case 16:
            sample.arpeggio[5] = com.data;
            break;
          case 17:
            sample.arpeggio[6] = com.data;
            break;
          case 18:
            sample.arpeggio[7] = com.data;
            break;
          case 19:
            sample.arpeggio[0] = sample.arpeggio[4] = com.data;
            break;
          case 20:
            sample.arpeggio[1] = sample.arpeggio[5] = com.data;
            break;
          case 21:
            sample.arpeggio[2] = sample.arpeggio[6] = com.data;
            break;
          case 22:
            sample.arpeggio[3] = sample.arpeggio[7] = com.data;
            break;
          case 23:
            value = com.data;
            if (value > 64) value = 64;
            sample.attackStep = value;
            break;
          case 24:
            sample.attackDelay = com.data;
            break;
          case 25:
            value = com.data;
            if (value > 64) value = 64;
            sample.decayStep = value;
            break;
          case 26:
            sample.decayDelay = com.data;
            break;
          case 27:
            sample.sustain = com.data & (sample.sustain & 255);
            break;
          case 28:
            sample.sustain = (sample.sustain & 65280) + com.data;
            break;
          case 29:
            value = com.data;
            if (value > 64) value = 64;
            sample.releaseStep = value;
            break;
          case 30:
            sample.releaseDelay = com.data;
            break;
        }
}
        if (sample.portamento == 0) {
          value = PERIODS[int(voice.note + sample.arpeggio[voice.arpeggioCnt])];
          voice.arpeggioCnt = ++voice.arpeggioCnt & 7;
          value -= (sample.vibratoLength * sample.vibratoStep);
          value += voice.bendrate;
          voice.period = 0;
        } else {
          value = voice.period;
        }

        chan.period = value + voice.vibratoPeriod;
//trace(chan.period.toString(16), value.toString(16), voice.vibratoPeriod, voice.bendrate, com.effect, com.data, voice.stepCnt, voice.patternCnt);
        adsr  = voice.status & 14;
        value = voice.volume;

        if (adsr == 0) {
          if (voice.attackCnt == 0) {
            voice.attackCnt = sample.attackDelay;
            value += sample.attackStep;

            if (value >= 64) {
              adsr |= 2;
              voice.status |= 2;
              value = 64;
            }
          } else {
            voice.attackCnt--;
          }
        }

        if (adsr == 2) {
          if (voice.decayCnt == 0) {
            voice.decayCnt = sample.decayDelay;
            value -= sample.decayStep;
            if (value <= sample.volume) {
              adsr |= 6;
              voice.status |= 6;
              value = sample.volume;
            }
          } else {
            voice.decayCnt--;
          }
        }

        if (adsr == 6) {
          if (voice.sustain == 0) {
            adsr |= 14;
            voice.status |= 14;
          } else {
            voice.sustain--;
          }
        }

        if (adsr == 14) {
          if (voice.releaseCnt == 0) {
            voice.releaseCnt = sample.releaseDelay;
            value -= sample.releaseStep;

            if (value < 0) {
              voice.status &= 9;
              value = 0;
            }
          } else {
            voice.releaseCnt--;
          }
        }

        voice.volume = chan.volume = value;

        chan.enabled = 1;

        if (!sample.synth) {
          chan.pointer = sample.loopPtr;
          chan.length  = sample.repeatLen;
        }
      }
    }
  }
}