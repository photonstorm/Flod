package neoart.flod.whittaker2 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class W2Player extends AmigaPlayer {
    internal var
      songs       : Vector.<W2Song>,
      samples     : Vector.<W2Sample>,
      voices      : Vector.<W2Data>,
      stream      : ByteArray,
      offset      : int,
      channels    : int,
      master      : int,
      song        : W2Song,
      periods     : int,
      table1      : int,
      table2      : int,
      table3      : int,
      com2        : int,
      com3        : int,
      com4        : int,
      wave        : W2Sample,
      waveDir     : int,
      wavePos     : int,
      waveMin     : int,
      waveMax     : int,
      waveStep    : int,
      sample1     : int,
      sample2     : int,
      byte5b6     : int,
      byte5ba     : int,
      masterTimer : int,
      masterSpeed : int,
      interval    : int,
      counter     : int,
      multiply    : int;

    public function W2Player(amiga:Amiga = null) {
      super(amiga);
      voices = new Vector.<W2Data>(4, true);
      voices[0] = new W2Data();
      voices[1] = new W2Data();
      voices[2] = new W2Data();
      voices[3] = new W2Data();
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      W2Loader.load(stream, amiga);
      this.stream = stream;
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, loop:int, position:int, sample:W2Sample, value:int, voice:W2Data, volume:int;
      if (interval) {
        if (--counter == 0) {
          counter = 6;
          return;
        }
      }
      byte5b6 += (timer * multiply);

      if (byte5b6 > 255) {
        byte5b6 & 255;
        return;
      }
      if (masterTimer != 0) {
        if (master != 0) {
          if (--masterSpeed == 0) master--;
          if (master != 0) masterSpeed = masterTimer;
        }
      }
      if (master == 0) {
        amiga.complete = 1;
        return;
      }

      if (wave) {
        position = wave.pointer + wavePos;
        if (waveDir) {
          i = sample2;
          wavePos -= 2;
          if (wavePos == waveMin) waveDir = 0;
        } else {
          i = sample1;
          wavePos += 2;
          if (wavePos == waveMax) waveDir = 1;
        }
        amiga.memory[position] = i;
        if (waveStep != 1) amiga.memory[++position] = i;
      }

      for (i = 0; i < channels; ++i) {
        chan  = amiga.channels[i];
        voice = voices[i];

        stream.position = voice.stepPtr;
        sample = voice.sample;

        if (voice.sampleDone == 0) {
          voice.sampleDone = -1;

          if (sample.loop < 0) {
            chan.pointer = amiga.loopPtr;
            chan.length  = 64;
          } else {
            chan.pointer = sample.pointer + sample.loop;
            chan.length  = sample.length  - sample.loop;
          }
        }

        if (--voice.counter == 0) {
          voice.byte0 = 0;
          loop = 1;
          while (loop > 0) {
            value = stream.readByte();

            if (value < 0) {
              if (value >= -32) {
                value += 33;
                voice.speed = speed * value;
              } else if (value >= com2) {
                value -= com2;
                voice.sample = sample = samples[value];

              } else if (value >= com3) {
                value -= com3;
                position = stream.position;
                stream.position = table3 + (value << 1);
                stream.position = stream.readUnsignedShort() + offset;
                voice.long34 = stream.position;
                stream.position--;
                voice.byte42 = stream.readByte();
                stream.position = position;

              } else if (value >= com4) {
                value -= com4;
                position = stream.position;
                stream.position = table1 + (value << 1);
                voice.table2Ptr = stream.readUnsignedShort() + offset;
                voice.table2Pos = voice.table2Ptr;
                stream.position = position;
              } else {
                value += 128;

                switch (value) {
                  case 0:
                    stream.position = voice.patternPtr + voice.patternPos;
                    value = stream.readUnsignedShort();

                    if (value) {
                      stream.position = value + offset;
                      voice.patternPos += 2;
                    } else {
                      stream.position = voice.patternPtr;
                      stream.position = stream.readUnsignedShort() + offset;
                      voice.patternPos = 2;
                    }
                    break;
                  case 1:
                    voice.word32 = 0;
                    voice.byte20 = stream.readByte();
                    voice.byte21 = stream.readByte();
                    voice.byte0 |= 2;
                    break;
                  case 2:
                    voice.counter = voice.speed;
                    voice.stepPtr = stream.position;
                    chan.pointer  = amiga.loopPtr;
                    chan.length   = 64;
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
                    byte5ba = stream.readByte();
                    break;
                  case 6:
                    voice.byte1 = -1;
                    voice.byte44 = stream.readByte();
                    voice.byte46 = stream.readByte();
                    voice.byte45 = 0;
                    break;
                  case 7:
                    voice.byte1 = 0;
                    break;
                  case 8:
                    voice.byte3 = stream.readByte();
                    break;
                  case 9:
                    voice.patternPtr = stream.readUnsignedShort() + offset;
                    voice.patternPos = 0;
                    break;
                  case 10:
                    speed = stream.readByte();
                    break;
                  case 11:
                    masterTimer = stream.readByte();
                    masterSpeed = masterTimer;
                    break;
                  case 12:
                    master = stream.readByte();
                    break;
                  default:
                    trace("Unsupported effect:", value);
                    break;
                }
              }
            } else break;
          }

          if (loop == -1) continue;
          voice.stepPtr = stream.position;
          voice.counter = voice.speed;

          if (loop != -2) {
            voice.note = value;
            value += (byte5ba + voice.byte3);

            stream.position = voice.long34;
            volume = (stream.readByte() * master) >> 6;
            voice.long38 = stream.position;
            voice.byte43 = voice.byte42;

            chan.pointer = sample.pointer;
            chan.length  = sample.length;
            chan.volume  = volume;

            stream.position = periods + (value << 1);
            chan.period = (stream.readUnsignedShort() * sample.period) >> 10;
            voice.sampleDone = 0;
          }
          chan.enabled = 1;
        } else if (voice.counter == 1) {
          if (voice.byte0 != 131) chan.enabled = 0;
          continue;
        } else {
          stream.position = voice.table2Pos;
          value = stream.readByte();

          if (value < 0) {
            value += 128;
            voice.table2Pos = voice.table2Ptr;
          } else
            voice.table2Pos++;

          value += (voice.note + voice.byte3 + byte5ba);
          stream.position = periods + (value << 1);
          value = (stream.readUnsignedShort() * sample.period) >> 10;

          if ((voice.byte0 & 2) != 0) {
            if (voice.byte21) {
              voice.byte21--;
            } else {
              voice.word32 += voice.byte20;
              value -= voice.word32;
            }
          }

          if (voice.byte1) {
            if (voice.byte1 < 0) {
              voice.byte45 += voice.byte44;
              if (voice.byte46 == voice.byte45) voice.byte1 += 128;
            } else {
              voice.byte45 -= voice.byte44;
              if (voice.byte45 == 0) voice.byte1 = -1;
            }
            if (voice.byte45 == 0) voice.byte1 = -2;

            if ((voice.byte1 & 1) == 0) value -= voice.byte45;
              else value += voice.byte45;
          }
          chan.period = value;

          if (--voice.byte43 < 0) {
            voice.byte43    = voice.byte42;
            stream.position = voice.long38;

            volume = stream.readByte();
            if (volume > -1) voice.long38++;
            chan.volume = ((volume & 127) * master) >> 6;
          }
        }
      }
    }

    override protected function initialize():void {
      var i:int, len:int, voice:W2Data;
      super.initialize();
      if (playSong > lastSong) playSong = 0;
      song  = songs[playSong];
      speed = song.speed;
      timer = song.timer;
      byte5b6 = 0;
      byte5ba = 0;
      counter = 6;
      waveDir = 0;
      wavePos = waveMin;
      masterTimer = masterSpeed = 0;

      if (multiply == 0) multiply = 1;

      if (wave) {
        i = wave.pointer;
        len = i + (wave.length >> 1);
        for (; i < len; ++i) amiga.memory[i] = sample1;
        i = len;
        len += (wave.length >> 1);
        for (; i < len; ++i) amiga.memory[i] = sample2;
      }

      for (i = 0; i < channels; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.sample = samples[0];

        voice.patternPtr = song.pointers[i] + offset;
        stream.position  = voice.patternPtr;
        voice.stepPtr    = stream.readUnsignedShort() + offset;
        voice.table2Ptr  = table2;
        voice.table2Pos  = table2;
      }
    }
  }
}