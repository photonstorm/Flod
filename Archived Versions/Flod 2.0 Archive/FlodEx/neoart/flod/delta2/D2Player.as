/* Flod Delta Music 2 Replay 1.01
   2009/12/30
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
   OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
   IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.delta2 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class D2Player extends AmigaPlayer {
    public var song:D2Song;

    private var voices:Vector.<D2Voice>;
    private var noise:int;

    private const PERIODS:Vector.<int> = Vector.<int>([
      0000,6848,6464,6096,5760,5424,5120,4832,4560,4304,4064,3840,3616,3424,3232,
      3048,2880,2712,2560,2416,2280,2152,2032,1920,1808,1712,1616,1524,1440,1356,
      1280,1208,1140,1076,1016,0960,0904,0856,0808,0762,0720,0678,0640,0604,0570,
      0538,0508,0480,0452,0428,0404,0381,0360,0339,0320,0302,0285,0269,0254,0240,
      0226,0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113,0113,0113,
      0113,0113,0113,0113,0113,0113,0113,0113,0113,0113]);

    public function D2Player() {
      PERIODS.fixed = true;
      voices    = new Vector.<D2Voice>(4, true);
      voices[0] = new D2Voice();
      voices[1] = new D2Voice();
      voices[2] = new D2Voice();
      voices[3] = new D2Voice();
    }

    override public function load(stream:ByteArray):int {
      song = new D2Song();
      supported = song.initialize(stream, amiga);
      return supported;
    }

    override protected function initialize():void {
      var i:int, voice:D2Voice;
      amiga.initialize();

      speed    = 5;
      timer    = 1;
      complete = 0;
      noise    = 0;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.sample   = song.samples[0];
        voice.trackPtr = song.tracksData[i];
        voice.restart  = song.tracksData[i + 4];
        voice.trackLen = song.tracksData[i + 8];
      }
    }

    override protected function process():void {
      var chan:AmigaChannel, com:D2Command, i:int, level:int, sample:D2Sample, value:int, voice:D2Voice;

      for (i = 0; i < 64; ++i) {
        noise = (noise << 7) | (noise >>> 25);
        noise += 0x6eca756d;
        noise ^= 0x9e59a92b;

        value = (noise >>> 24) & 0xff;
        if (value > 127) value -= 256;
        amiga.samples[i++] = value;

        value = (noise >>> 16) & 0xff;
        if (value > 127) value -= 256;
        amiga.samples[i++] = value;

        value = (noise >>> 8) & 0xff;
        if (value > 127) value -= 256;
        amiga.samples[i++] = value;

        value = noise & 0xff;
        if (value > 127) value -= 256;
        amiga.samples[i] = value;
      }

      if (--timer < 0) timer = speed;

      for (i = 0; i < 4; ++i) {
        voice  = voices[i];
        if (voice.trackLen < 1) continue;
        chan   = amiga.channels[i];
        sample = voice.sample;

        if (sample.synth < 0) {
          chan.pointer = sample.loopPtr;
          chan.length  = sample.repeatLen;
        }

        if (timer == 0) {
          if (voice.patternPos == 0) {
            voice.step = song.tracks[int(voice.trackPtr + voice.trackPos)];
            if (++voice.trackPos == voice.trackLen) voice.trackPos = voice.restart;
          }

          com = voice.com = song.patterns[int(voice.step.pattern + voice.patternPos)];

          if (com.note) {
            chan.enabled = 0;
            voice.note = com.note;
            voice.period = PERIODS[int(com.note + voice.step.transpose)];

            sample = voice.sample = song.samples[com.sample];

            if (sample.synth < 0) {
              chan.pointer = sample.pointer;
              chan.length  = sample.length;
            }

            voice.arpeggioStep   = 0;
            voice.vibratoCnt     = sample.vibratos[1];
            voice.vibratoDir     = 0;
            voice.vibratoPeriod  = 0;
            voice.vibratoStep    = 0;
            voice.vibratoSustain = sample.vibratos[2];
            voice.volume         = 0
            voice.volumeStep     = 0;
            voice.volumeSustain  = 0;
            voice.waveCnt        = 0;
            voice.waveStep       = 0;
          }

          switch (com.effect) {
            case -1:
              break;
            case 0:
              speed = com.data & 15;
              break;
            case 1:
              amiga.filter.active = com.data;
              break;
            case 2:
              value = com.data & 255;
              voice.bendrate = ~value + 1;
              break;
            case 3:
              voice.bendrate = com.data & 255;
              break;
            case 4:
              voice.portamento = com.data;
              break;
            case 5:
              voice.volumeMax = com.data & 63;
              break;
            case 6:
              break;
            case 7:
              voice.arpeggioPtr = (com.data & 63) << 4;
              break;
          }

          voice.patternPos = ++voice.patternPos & 15;
        }

        sample = voice.sample;

        if (sample.synth >= 0) {
          if (voice.waveCnt == 0) {
            voice.waveCnt = sample.number;
            value = sample.waves[voice.waveStep];

            if (value == 0xff) {
              value = sample.waves[++voice.waveStep];

              if (value != 0xff) {
                voice.waveStep = value;
                value = sample.waves[voice.waveStep];
              }
            }

            if (value != 0xff) {
              chan.pointer = value << 8;
              chan.length  = sample.length;
              if (++voice.waveStep > 47) voice.waveStep = 0;
            }
          } else {
            voice.waveCnt--;
          }
        }

        value = sample.vibratos[voice.vibratoStep];

        if (voice.vibratoDir == 0) voice.vibratoPeriod += value;
          else voice.vibratoPeriod -= value;

        if (--voice.vibratoCnt == 0) {
          voice.vibratoCnt = sample.vibratos[voice.vibratoStep + 1];
          voice.vibratoDir = ~voice.vibratoDir;
        }
		//if (voice.vibratoCnt < 0) voice.vibratoCnt = 255; 
        if (voice.vibratoSustain == 0) {
          voice.vibratoStep += 3;
          if (voice.vibratoStep == 15) voice.vibratoStep = 12;
          voice.vibratoSustain = sample.vibratos[voice.vibratoStep + 2];
        } else {
          voice.vibratoSustain--;
        }

        if (voice.volumeSustain == 0) {
          value = sample.volumes[voice.volumeStep];
          level = sample.volumes[voice.volumeStep + 1];

          if (level < voice.volume) {
            voice.volume -= value;

            if (voice.volume < level) {
              voice.volume = level;
              voice.volumeStep += 3
              voice.volumeSustain = sample.volumes[voice.volumeStep - 1];
            }
          } else {
            voice.volume += value;

            if (voice.volume > level) {
              voice.volume = level;
              voice.volumeStep += 3
              if (voice.volumeStep == 15) voice.volumeStep = 12;
              voice.volumeSustain = sample.volumes[voice.volumeStep - 1];
            }
          }
        } else {
          voice.volumeSustain--;
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

        value = song.arpeggios[int(voice.arpeggioPtr + voice.arpeggioStep)];

        if (value == 128) {
          voice.arpeggioStep = 0;
          value = song.arpeggios[voice.arpeggioPtr];
        }

        voice.arpeggioStep = ++voice.arpeggioStep & 15;

        if (voice.portamento == 0) {
          value = voice.note + voice.step.transpose + value;
          if (value < 0) value = 0;
          voice.finalPeriod = PERIODS[value];
        }

        voice.vibratoPeriod -= (sample.bendrate - voice.bendrate);
        chan.period = voice.finalPeriod + voice.vibratoPeriod;
		if (chan.period < 0) chan.period += 65536;

        value = (voice.volume >> 2) & 63;
        if (value > voice.volumeMax) value = voice.volumeMax;
        chan.volume  = value;
        chan.enabled = 1;
      }
    }
  }
}