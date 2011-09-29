package neoart.flod.whittaker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class DW3Player extends AmigaPlayer {
    internal var
      song    : DWSong,
      songs   : Vector.<DWSong>,
      samples : Vector.<DWSample>,
      voices  : Vector.<DW3Data>,
      stream  : ByteArray,
      channels: int,
      offset  : int,
      table1  : int,
      table2  : int,
      table3  : int,
      periods : int,
      byte526 : int,
      byte9a6 : int,
      word9ac : int;

    public function DW3Player(amiga:Amiga = null) {
      super(amiga);

      voices = new Vector.<DW3Data>(4, true);
      voices[0] = new DW3Data();
      voices[1] = new DW3Data();
      voices[2] = new DW3Data();
      voices[3] = new DW3Data();
    }

    override public function load(stream:ByteArray, clear:int = 0):int {
      super.load(stream);
      DW3Loader.initialize(stream, amiga);
      this.stream = stream;
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, loop:int, position:int, sample:DWSample, value:int, voice:DW3Data, volume:int;

      if (version == 5) {
        byte526 += (song.unknown << 4);

        if (byte526 > 255) {
          byte526 &= 255;
          return;
        }
      }

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
              if (value >= -32) {
                value += 33;
                voice.d1_word28 = speed * value;
              } else if (value >= -64) {
                value += 64;
                voice.d1_long24 = value;
                sample = samples[value];
              } else if (value >= -80) {
                value += 80;
                position = stream.position;
                stream.position = table3 + (value << 1);
                stream.position = stream.readUnsignedShort() + offset;
                voice.d1_long34 = stream.position;
                stream.position--;
                voice.d1_byte42 = stream.readByte();
                stream.position = position;
              } else if (value >= -96) {
                position = stream.position;
                value += 96;
                stream.position = table1 + (value << 1);
                voice.d1_long12 = stream.readUnsignedShort() + offset;
                voice.d1_long16 = voice.d1_long12;
                stream.position = position;
              } else {
                value += 128;

                switch (value) {
                  case 0:
                    stream.position = voice.d1_word8 + voice.d1_word10;
                    value = stream.readUnsignedShort();

                    if (value) {
                      stream.position = value + offset;
                      voice.d1_word10 += 2;
                    } else {
                      stream.position = voice.d1_word8;
                      stream.position = stream.readUnsignedShort() + offset;
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
                    byte9a6 = stream.readByte();
                    break;
                  case 6:
                    voice.d1_byte1 = -1;
                    voice.d1_byte44 = stream.readByte();
                    voice.d1_byte45 = 0;
                    voice.d1_byte46 = stream.readByte();
                    break;
                  case 7:
                    voice.d1_byte1 = 0;
                    break;
                  case 8:
                    if (version == 3) voice.d1_byte3 = -1;
                      else voice.d1_byte47 = stream.readByte();
                    break;
                  case 9:
                    if (version == 3) voice.d1_byte3 = 0;
                    else {
                      voice.d1_word8  = stream.readUnsignedShort() + offset;
                      voice.d1_word10 = 0;
                    }
                    break;
                  case 10:
                    speed = stream.readByte();
                    break;
                }
              }
            } else break;
          }

          if (loop == -1) continue;

          voice.d1_long4  = stream.position;
          voice.d1_word30 = voice.d1_word28;

          if (loop != -2) {
            voice.d1_byte2 = value;
            value += (byte9a6 + voice.d1_byte47);

            stream.position = voice.d1_long34;
            voice.d1_long38 = stream.position;
            voice.d1_byte43 = voice.d1_byte42;
            volume = stream.readByte();

            if (version == 5) {
              volume = (volume * 64) >> 6; //temp
            } else {
              if (voice.d1_byte3) volume >>= 1;
              volume -= word9ac;
              if (volume < 0) volume = 0;
            }

            chan.pointer = sample.pointer;
            chan.length  = sample.length;
            chan.volume  = volume;

            stream.position = periods + (value << 1);
            chan.period  = (stream.readUnsignedShort() * sample.period) >> 10;
            voice.d1_byte22 = 0;
          }

          chan.enabled = 1;

        } else if (voice.d1_word30 == 1) {
          if (version == 5) {
            if (voice.d1_byte0 == 131) continue;
          }
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

          value = (value + voice.d1_byte2 + voice.d1_byte47 + byte9a6) & 0xff;
          stream.position = periods + (value << 1);
          value = (stream.readUnsignedShort() * sample.period) >> 10;

          if ((voice.d1_byte0 & 2) != 0) {
            if (voice.d1_byte21) --voice.d1_byte21;
            voice.d1_word32 += voice.d1_byte20;
            value -= voice.d1_word32;
          }

          if (voice.d1_byte1) {
            if (voice.d1_byte1 < 0) {
              voice.d1_byte45 += voice.d1_byte44;
              if (voice.d1_byte46 == voice.d1_byte45) voice.d1_byte1 += 128;
            } else {
              voice.d1_byte45 -= voice.d1_byte44;
              if (voice.d1_byte45 == 0) voice.d1_byte1 = -1;
            }

            if (voice.d1_byte45 == 0) voice.d1_byte1 = -2;

            if ((voice.d1_byte1 & 1) == 0) value -= voice.d1_byte45;
              else value += voice.d1_byte45;
          }

          chan.period = value;

          if (--voice.d1_byte43 < 0) {
            voice.d1_byte43 = voice.d1_byte42;
            stream.position = voice.d1_long38;
            volume = stream.readByte();
            if (volume > -1) voice.d1_long38 = stream.position;

            volume &= 127;
            if (version == 5) {
              volume = (volume * 64) >> 6; //temp
            } else {
              if (voice.d1_byte3) volume >>= 1;
              volume -= word9ac;
              if (volume < 0) volume = 0;
            }
            chan.volume = volume;
          }
        }
      }
    }

    override protected function initialize():void {
      var i:int, voice:DW3Data;
      super.initialize();
      song  = songs[currentSong];
      speed = song.speed;
      byte9a6 = 0;

      for (i = 0; i < channels; ++i) {
        voice = voices[i];
        voice.initialize();

        voice.d1_word8  = song.pointers[i];
        stream.position = voice.d1_word8;
        voice.d1_long4  = stream.readUnsignedShort() + offset;
        voice.d1_long12 = table2;
        voice.d1_long16 = table2;
      }
    }
  }
}