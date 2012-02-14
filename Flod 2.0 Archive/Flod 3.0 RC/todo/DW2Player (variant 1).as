package neoart.flod.whittaker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class DW2Player extends AmigaPlayer {
    internal var
      song    : DWSong,
      songs   : Vector.<DWSong>,
      samples : Vector.<DWSample>,
      voices  : Vector.<DW2Data>,
      stream  : ByteArray,
      channels: int,
      table1  : int,
      table2  : int,
      periods : int,
      unknown : int,
      volTranspose : int;

    public function DW2Player(amiga:Amiga = null) {
      super(amiga);

      voices = new Vector.<DW2Data>(4, true);
      voices[0] = new DW2Data();
      voices[1] = new DW2Data();
      voices[2] = new DW2Data();
      voices[3] = new DW2Data();
    }

    override public function load(stream:ByteArray, clear:int = 0):int {
      super.load(stream);
      DW2Loader.initialize(stream, amiga);
      this.stream = stream;
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, loop:int, position:int, sample:DWSample, value:int, voice:DW2Data;

      for (i = channels; i > -1; --i) {
        chan = amiga.channels[i];
        voice = voices[i];

        stream.position = voice.d1_long4;
        sample = samples[voice.d1_long24];

        if (voice.d1_byte22 == 0) {
          voice.d1_byte22 = -1;

          if (sample.loopStart < 0) {
            chan.pointer = amiga.loopPtr;
            chan.length  = 64;
          } else {
            chan.pointer = sample.pointer + sample.loopStart;
            chan.length  = sample.length  - sample.loopStart;
          }
        }

        if (--voice.d1_word30 == 0) {
          voice.d1_byte0 = 0;
          loop = 1;

          while (loop > 0) {
            value = stream.readByte();

            if (value < 0) {
              value += 256;

              if (value >= 0xe0) {
                value -= 223;
                voice.d1_word28 = speed * value;
              } else if (value >= 0xc0) {
                value -= 192;
                voice.d1_long24 = value;
                sample = samples[value];
              } else if (value >= 160) {
                position = stream.position;
                value -= 160;
                stream.position = table1 + (value << 1);
                voice.d1_long12 = stream.readUnsignedShort();
                voice.d1_long16 = voice.d1_long12;
                stream.position = position;
              } else {
                value &= 127;

                switch (value) {
                  case 0:
                    stream.position = voice.d1_word8 + voice.d1_word10;
                    value = stream.readUnsignedShort();

                    if (value) {
                      stream.position = value;
                      voice.d1_word10 += 2;
                    } else {
                      stream.position = voice.d1_word8;
                      stream.position = stream.readUnsignedShort();
                      voice.d1_word10 = 2;
                    }
                    break;
                  case 1:
                    voice.d1_word32 = 0;
                    voice.d1_byte20 = stream.readByte();
                    voice.d1_byte21 = stream.readByte();
                    voice.d1_byte0 |= 2;
                    break;
                  case 2:
                    voice.d1_word30 = voice.d1_word28;
                    voice.d1_long4 = stream.position;
                    chan.pointer = amiga.loopPtr;
                    chan.length  = 64;
                    loop = -1;
                    break;
                  case 3:
                    loop = -2;
                    break;
                  case 4:
                    amiga.complete = 1;
                    loop = -1;
                    break;
                  case 5:
                    unknown = stream.readByte();
                    break;
                  case 6:
                    voice.d1_byte1 = -1;
                    voice.d1_byte34 = stream.readByte();
                    voice.d1_byte35 = 0;
                    voice.d1_byte36 = stream.readByte();
                    break;
                  case 7:
                    if (version == 1) voice.d1_byte1 = 0;
                      else volTranspose = stream.readByte();
                    break;
                  case 8:
                    voice.d1_byte1 = 0;
                    break;
                }
              }
            } else break;
          }

          if (loop == -1) continue;

          voice.d1_long4  = stream.position;
          voice.d1_word30 = voice.d1_word28;

          if (loop != -2) {
            value += sample.unknown;
            voice.d1_byte2  = value;
            voice.d1_byte22 = 0;

            chan.pointer = sample.pointer;
            chan.length  = sample.length;
            chan.volume  = sample.volume - volTranspose;

            stream.position = periods + (value << 1);
            chan.period  = (stream.readUnsignedShort() * sample.period) >> 10;
          }

          chan.enabled = 1;

        } else if (voice.d1_word30 == 1) {
          chan.enabled = 0;
          continue;
        } else {
          stream.position = voice.d1_long16;
          value = stream.readByte();

          if (value < 0) {
            value += 128;
            voice.d1_long16 = voice.d1_long12;
          } else
            voice.d1_long16 = stream.position;

          value = (value + voice.d1_byte2 + unknown) & 0xff;
          stream.position = periods + (value << 1);
          value = (stream.readUnsignedShort() * sample.period) >> 10;

          if ((voice.d1_byte0 & 2) != 0) {
            if (voice.d1_byte21) --voice.d1_byte21;
            voice.d1_word32 += voice.d1_byte20;
            value -= voice.d1_word32;
          }

          if (voice.d1_byte1) {
            if (voice.d1_byte1 < 0) {
              voice.d1_byte35 += voice.d1_byte34;
              if (voice.d1_byte36 == voice.d1_byte35) voice.d1_byte1 += 128;
            } else {
              voice.d1_byte35 -= voice.d1_byte34;
              if (voice.d1_byte35 == 0) voice.d1_byte1 = -1;
            }

            if (voice.d1_byte35 == 0) voice.d1_byte1 = -2;

            if ((voice.d1_byte1 & 1) == 0) value -= voice.d1_byte35;
              else value += voice.d1_byte35;
          }

          chan.period = value;
        }
      }
    }

    override protected function initialize():void {
      var i:int, voice:DW2Data;
      super.initialize();
      song  = songs[currentSong];
      speed = song.speed;
      unknown = volTranspose = 0;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();

        voice.d1_word8  = song.pointers[i];
        stream.position = voice.d1_word8;
        voice.d1_long4  = stream.readUnsignedShort();
        voice.d1_long12 = table2;
        voice.d1_long16 = table2;
      }
    }
  }
}