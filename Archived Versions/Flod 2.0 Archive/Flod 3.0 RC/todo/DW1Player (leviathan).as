package neoart.flod.whittaker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class DW1Player extends AmigaPlayer {
    internal var
      song    : DWSong,
      songs   : Vector.<DWSong>,
      samples : Vector.<DWSample>,
      voices  : Vector.<DW1Data>,
      stream  : ByteArray,
      periods : int;

    public function DW1Player(amiga:Amiga = null) {
      super(amiga);

      voices = new Vector.<DW1Data>(4, true);
      voices[0] = new DW1Data();
      voices[1] = new DW1Data();
      voices[2] = new DW1Data();
      voices[3] = new DW1Data();
    }

    override public function load(stream:ByteArray, clear:int = 0):int {
      super.load(stream);
      DW1Loader.initialize(stream, amiga);
      this.stream = stream;
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, loop:int, sample:DWSample, value:int, voice:DW1Data;

      for (i = 3; i > -1; --i) {
        chan = amiga.channels[i];
        voice = voices[i];

        stream.position = voice.d1_long4;
        sample = samples[voice.d1_long26];

        if (voice.d1_byte24 == 0) {
          voice.d1_byte24 = -1;

          if (sample.loopStart < 0) {
            chan.pointer = amiga.loopPtr;
            chan.length  = 64;
          } else {
            chan.pointer = sample.pointer + sample.loopStart;
            chan.length  = sample.length  - sample.loopStart;
          }
        }

        if (--voice.d1_word18 == 0) {
          voice.d1_byte0 = 0;
          loop = 1;

          while (loop > 0) {
            value = stream.readByte();

            if (value < 0) {
              value += 256;

              if (value >= 0xe0) {
                value -= 223;
                voice.d1_word16 = speed * value;
              } else if (value >= 0xc0) {
                value -= 192;
                voice.d1_long26 = value;
                sample = samples[value];
              } else {
                value &= 127;

                switch (value) {
                  case 0:
                    stream.position = voice.d1_long8 + voice.d1_long12;
                    value = stream.readUnsignedInt();

                    if (value) {
                      stream.position = value;
                      voice.d1_long12 += 4;
                    } else {
                      stream.position = voice.d1_long8;
                      stream.position = stream.readUnsignedInt();
                      voice.d1_long12 = 4;
                    }
                    break;
                  case 1:
                    voice.d1_byte22 = stream.readByte();
                    voice.d1_byte23 = stream.readByte();
                    voice.d1_byte0 |= 2;
                    break;
                  case 2:
                    voice.d1_word18 = voice.d1_word16;
                    voice.d1_long4 = stream.position;
                    chan.pointer = amiga.loopPtr;
                    chan.length  = 64;
                    loop = -1;
                    break;
                  case 4:
                    amiga.complete = 1;
                    loop = -1;
                    break;
                  default:
                    break;
                }
              }
            } else break;
          }

          if (loop == -1) continue;

          voice.d1_word18 = voice.d1_word16;
          voice.d1_byte2  = value;
          voice.d1_long4  = stream.position;

          chan.pointer = sample.pointer;
          chan.length  = sample.length;
          chan.volume  = sample.volume;

          stream.position = periods + (value << 1);
          voice.d1_word20 = (stream.readUnsignedShort() * sample.period) >> 10;
          chan.period  = voice.d1_word20;
          chan.enabled = 1;
          voice.d1_byte24 = 0;

        } else if (voice.d1_word18 == 1) {
          chan.enabled = 0;
        } else {
          if ((voice.d1_byte0 & 2) == 0) continue;

          if (voice.d1_byte23) {
            --voice.d1_byte23;
          } else {
            voice.d1_word20 -= voice.d1_byte22;
            chan.period = voice.d1_word20;
          }
        }
      }
    }

    override protected function initialize():void {
      var i:int, voice:DW1Data;
      super.initialize();
      song  = songs[currentSong];
      speed = song.speed;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();

        voice.d1_long8  = song.pointers[i];
        stream.position = voice.d1_long8;
        voice.d1_long4  = stream.readUnsignedInt();
      }
    }
  }
}