/* Flod Future Composer Replay 1.01
   2009/12/30
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.futurecomposer {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class FCPlayer extends AmigaPlayer {
    public var song:FCSong;

    private var voices:Vector.<FCVoice>;
    private var seqs:ByteArray;
    private var pats:ByteArray;
    private var frqs:ByteArray;
    private var vols:ByteArray;

    private const PERIODS:Vector.<int> = Vector.<int>([
      0x06b0,0x0650,0x05f4,0x05a0,0x054c,0x0500,0x04b8,0x0474,
      0x0434,0x03f8,0x03c0,0x038a,0x0358,0x0328,0x02fa,0x02d0,
      0x02a6,0x0280,0x025c,0x023a,0x021a,0x01fc,0x01e0,0x01c5,
      0x01ac,0x0194,0x017d,0x0168,0x0153,0x0140,0x012e,0x011d,
      0x010d,0x00fe,0x00f0,0x00e2,0x00d6,0x00ca,0x00be,0x00b4,
      0x00aa,0x00a0,0x0097,0x008f,0x0087,0x007f,0x0078,0x0071,
      0x0071,0x0071,0x0071,0x0071,0x0071,0x0071,0x0071,0x0071,
      0x0071,0x0071,0x0071,0x0071,0x0d60,0x0ca0,0x0be8,0x0b40,
      0x0a98,0x0a00,0x0970,0x08e8,0x0868,0x07f0,0x0780,0x0714,
      0x06b0,0x0650,0x05f4,0x05a0,0x054c,0x0500,0x04b8,0x0474,
      0x0434,0x03f8,0x03c0,0x038a,0x0358,0x0328,0x02fa,0x02d0,
      0x02a6,0x0280,0x025c,0x023a,0x021a,0x01fc,0x01e0,0x01c5,
      0x01ac,0x0194,0x017d,0x0168,0x0153,0x0140,0x012e,0x011d,
      0x010d,0x00fe,0x00f0,0x00e2,0x00d6,0x00ca,0x00be,0x00b4,
      0x00aa,0x00a0,0x0097,0x008f,0x0087,0x007f,0x0078,0x0071,
      0x0071,0x0071,0x0071,0x0071,0x0071,0x0071,0x0071,0x0071,
      0x0071,0x0071,0x0071,0x0071]);

    private const VOL_LOOP:        int = 0xe0;
    private const VOL_END:         int = 0xe1;
    private const VOL_SUSTAIN:     int = 0xe8;
    private const VOL_SLIDE:       int = 0xea;

    private const FRQ_LOOP:        int = 0xe0;
    private const FRQ_END:         int = 0xe1;
    private const FRQ_SET_WAVE:    int = 0xe2;
    private const FRQ_NEW_VIBRATO: int = 0xe3;
    private const FRQ_CHANGE_WAVE: int = 0xe4;
    private const FRQ_NEW_SEQUENCE:int = 0xe7;
    private const FRQ_SUSTAIN:     int = 0xe8;
    private const FRQ_SET_PACK:    int = 0xe9;
    private const FRQ_PITCH_BEND:  int = 0xea;

    public function FCPlayer() {
      PERIODS.fixed = true;
      voices    = new Vector.<FCVoice>(4, true);
      voices[0] = new FCVoice();
      voices[1] = new FCVoice();
      voices[2] = new FCVoice();
      voices[3] = new FCVoice();
    }

    override public function load(stream:ByteArray):int {
      song = new FCSong();
      supported = song.initialize(stream, amiga);
      return supported;
    }

    override protected function initialize():void {
      var i:int, voice:FCVoice;
      amiga.initialize();
      complete = 0;

      seqs = song.seqs;
      seqs.position = 0;
      pats = song.pats;
      pats.position = 0;
      frqs = song.frqs;
      frqs.position = 0;
      vols = song.vols;
      vols.position = 0;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.pattern = seqs.readUnsignedByte() << 6;
        voice.transpose = seqs.readByte();
        voice.soundTranspose = seqs.readByte();
      }

      speed = seqs.readUnsignedByte();
      if (speed == 0) speed = 3;
      timer = speed;
    }

    override protected function process():void {
      var base:int, chan:AmigaChannel, delta:int, i:int, info:int, loopEffect:int, loopSustain:int, period:int, sample:AmigaSample, temp:int, voice:FCVoice;

      if (--timer == 0) {
        base = seqs.position;

        for (i = 0; i < 4; ++i) {
          chan  = amiga.channels[i];
          voice = voices[i];

          pats.position = voice.pattern + voice.patStep;
          temp = pats.readUnsignedByte();

          if (voice.patStep >= 64 || temp == 0x49) {
            if (seqs.position == song.length) {
              seqs.position = 0;
              complete = 1;
            }

            voice.patStep = 0;
            voice.pattern = seqs.readUnsignedByte() << 6;
            voice.transpose = seqs.readByte();
            voice.soundTranspose = seqs.readByte();

            pats.position = voice.pattern;
            temp = pats.readUnsignedByte();
          }

          info = pats.readUnsignedByte();
          frqs.position = 0;
          vols.position = 0;

          if (temp != 0) {
            voice.note = temp & 0x7f;
            voice.pitch = 0;
            voice.portamento = 0;
            voice.enabled = chan.enabled = 0;

            temp = 8 + (((info & 0x3f) + voice.soundTranspose) << 6);
            if (temp < vols.length) vols.position = temp;
            voice.volStep = 0;
            voice.volSpeed = voice.volCnt = vols.readUnsignedByte();
            voice.volSustain = 0;

            voice.frqPos = 8 + (vols.readUnsignedByte() << 6);
            voice.frqStep = 0;
            voice.frqSustain = 0;

            voice.vibratoFlag = 0;
            voice.vibratoSpeed = vols.readUnsignedByte();
            voice.vibratoDepth = voice.vibrato = vols.readUnsignedByte();
            voice.vibratoDelay = vols.readUnsignedByte();
            voice.volPos = vols.position;
          }

          if (info & 0x40) {
            voice.portamento = 0;
          } else if (info & 0x80) {
            voice.portamento = pats[int(pats.position + 1)];
            if (song.version == song.FUTURECOMP_10) voice.portamento <<= 1;
          }
          voice.patStep += 2;
        }

        if (seqs.position != base) {
          temp = seqs.readUnsignedByte();
          if (temp) speed = temp;
        }
        timer = speed;
      }

      for (i = 0; i < 4; ++i) {
        chan  = amiga.channels[i];
        voice = voices[i];

        do {
          loopSustain = 0;

          if (voice.frqSustain) {
            voice.frqSustain--;
            break;
          }
          frqs.position = voice.frqPos + voice.frqStep;

          do {
            loopEffect = 0;
            if (frqs.bytesAvailable == 0) break;
            info = frqs.readUnsignedByte();
            if (info == FRQ_END) break;

            if (info == FRQ_LOOP) {
              voice.frqStep = frqs.readUnsignedByte() & 0x3f;
              frqs.position = voice.frqPos + voice.frqStep;
              info = frqs.readUnsignedByte();
            }

            switch (info) {
              case FRQ_SET_WAVE:
                chan.enabled  = 0;
                voice.enabled = 1
                voice.volCnt  = 1;
                voice.volStep = 0;
              case FRQ_CHANGE_WAVE:
                sample = song.samples[frqs.readUnsignedByte()];

                if (sample) {
                  chan.pointer = sample.pointer;
                  chan.length  = sample.length;
                } else {
                  voice.enabled = 0;
                }

                voice.sample = sample;
                voice.frqStep += 2;
                break;
              case FRQ_SET_PACK:
                temp = 100 + (frqs.readUnsignedByte() * 10);
                sample = song.samples[int(temp + frqs.readUnsignedByte())];

                if (sample) {
                  chan.enabled = 0;
                  chan.pointer = sample.pointer;
                  chan.length  = sample.length;
                  voice.enabled = 1;
                }

                voice.sample = sample;
                voice.volCnt = 1;
                voice.volStep  = 0;
                voice.frqStep += 3;
                break;
              case FRQ_NEW_SEQUENCE:
                loopEffect = 1;
                voice.frqPos = 8 + (frqs.readUnsignedByte() << 6);
                if (voice.frqPos >= frqs.length) voice.frqPos = 0;
                voice.frqStep = 0;
                frqs.position = voice.frqPos;
                break;
              case FRQ_PITCH_BEND:
                voice.pitchBendSpeed = frqs.readByte();
                voice.pitchBendTime  = frqs.readUnsignedByte();
                voice.frqStep += 3;
                break;
              case FRQ_SUSTAIN:
                loopSustain = 1;
                voice.frqSustain = frqs.readUnsignedByte();
                voice.frqStep += 2;
                break;
              case FRQ_NEW_VIBRATO:
                voice.vibratoSpeed = frqs.readUnsignedByte();
                voice.vibratoDepth = frqs.readUnsignedByte();
                voice.frqStep += 3;
                break;
            }

            if (!loopSustain && !loopEffect) {
              frqs.position = voice.frqPos + voice.frqStep;
              voice.frqTranspose = frqs.readByte();
              voice.frqStep++;
            }
          } while (loopEffect);
        } while (loopSustain);

        if (voice.volSustain) {
          voice.volSustain--;
        } else {
          if (voice.volBendTime) {
            voice.volumeBend();
          } else {
            if (--voice.volCnt == 0) {
              voice.volCnt = voice.volSpeed;

              do {
                loopEffect = 0;
                vols.position = voice.volPos + voice.volStep;
                if (vols.bytesAvailable == 0) break;
                info = vols.readUnsignedByte();
                if (info == VOL_END) break;

                switch (info) {
                  case VOL_SLIDE:
                    voice.volBendSpeed = vols.readByte();
                    voice.volBendTime  = vols.readUnsignedByte();
                    voice.volStep += 3;
                    voice.volumeBend();
                    break;
                  case VOL_SUSTAIN:
                    voice.volSustain = vols.readUnsignedByte();
                    voice.volStep += 2;
                    break;
                  case VOL_LOOP:
                    loopEffect = 1;
                    temp = vols.readUnsignedByte() & 0x3f;
                    voice.volStep = temp - 5;
                    break;
                  default:
                    voice.volume = info;
                    voice.volStep++;
                    break;
                }
              } while (loopEffect);
            }
          }
        }

        info = voice.frqTranspose;
        if (info >= 0) info += (voice.note + voice.transpose);
        info &= 0x7f;
        period = PERIODS[info];

        if (voice.vibratoDelay) {
          voice.vibratoDelay--;
        } else {
          temp = voice.vibrato;

          if (voice.vibratoFlag) {
            delta = voice.vibratoDepth << 1;
            temp += voice.vibratoSpeed;

            if (temp > delta) {
              temp = delta;
              voice.vibratoFlag = 0;
            }
          } else {
            temp -= voice.vibratoSpeed;

            if (temp < 0) {
              temp = 0;
              voice.vibratoFlag = 1;
            }
          }

          voice.vibrato = temp;
          temp -= voice.vibratoDepth;
          base = (info << 1) + 160;

          while (base < 256) {
            temp <<= 1;
            base += 24;
          }
          period += temp;
        }

        voice.portamentoFlag ^= 1;

        if (voice.portamentoFlag && voice.portamento) {
          if (voice.portamento > 0x1f)
            voice.pitch += voice.portamento & 0x1f;
          else
            voice.pitch -= voice.portamento;
        }
        voice.pitchBendFlag ^= 1;

        if (voice.pitchBendFlag && voice.pitchBendTime) {
          voice.pitchBendTime--;
          voice.pitch -= voice.pitchBendSpeed;
        }
        period += voice.pitch;

        if (period < 113) period = 113;
          else if (period > 3424) period = 3424;

        chan.period = period;
        chan.volume = voice.volume;

        if (voice.sample) {
          sample = voice.sample;
          chan.enabled = voice.enabled;
          chan.pointer = sample.loopPtr;
          chan.length  = sample.repeatLen;
        }
      }
    }
  }
}