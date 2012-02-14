package neoart.flod.whittaker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class DW3Loader {

    public static function initialize(stream:ByteArray, amiga:Amiga):void {
      var i:int, channels:int, lower:int, noSamples:int, noSongs:int, player:DW3Player, sample:DWSample, samplesData:int, samplesHeader:int, song:DWSong, songsData:int, value:int;

      player = DW3Player(amiga.player);
      player.version = 3;

      while (stream.bytesAvailable) {
        value = stream.readUnsignedShort();

        if (value == 0x47fa) {
          player.offset = stream.readShort() + stream.position - 2;
        } else if (value == 0x6100) {
          stream.position += 2;
          value = stream.readUnsignedShort();

          if (value == 0x6100) {
            stream.position += stream.readUnsignedShort();

            while (stream.bytesAvailable) {
              value = stream.readUnsignedShort();

              if (value == 0x41fa) {
                samplesData = stream.readUnsignedShort() + stream.position - 2;
                value = stream.readUnsignedShort();

                if (value == 0x4bfa) {
                  samplesHeader = stream.position + stream.readShort();
                  stream.position++;
                  noSamples = stream.readUnsignedByte() + 1;
                  break;
                }
              }
            }
            break;
          }
        } else if (value == 0x6600) {
          stream.position += 2;
          value = stream.readUnsignedShort();

          if (value == 0x41fa) {
            samplesData = stream.readUnsignedShort() + stream.position - 2;
            value = stream.readUnsignedShort();

            if (value == 0x4bfa) {
              samplesHeader = stream.readUnsignedShort() + stream.position - 2;
              stream.position++;
              noSamples = stream.readUnsignedByte() + 1;
              player.version = 4;
              break;
            }
          }
        }
      }

      stream.position = 0;

      while (stream.bytesAvailable) {
        value = stream.readUnsignedShort();

        if (value == 0xbe7c) {
          player.channels = stream.readUnsignedShort() - 1;
          break;
        }
      }

      if (samplesData == 0 || player.channels == 0) return;
      player.samples = new Vector.<DWSample>(noSamples, true);
      stream.position = samplesData;

      for (i = 0; i < noSamples; ++i) {
        sample = new DWSample();
        sample.length = stream.readUnsignedInt();
        sample.period = stream.readUnsignedShort();
        if (sample.period == 0) return;

        sample.period = 3579545 / sample.period;
        sample.pointer = stream.position;
        stream.position += sample.length;
        player.samples[i] = sample;
      }

      stream.position = samplesHeader;

      for (i = 0; i < noSamples; ++i) {
        sample = player.samples[i];
        stream.position += 4;
        sample.loopStart = stream.readInt();
        stream.position += 4;

        value = stream.position;
        stream.position = sample.pointer;
        sample.pointer = amiga.memory.length;
        amiga.store(stream, sample.length);
        stream.position = value;
      }

      player.samples.fixed = true;
      amiga.loopLen = 64;

      stream.position = 20;
      channels = player.channels + 1;
      lower = (channels << 1) + 2;

      while (stream.bytesAvailable) {
        value = stream.readUnsignedShort();

        if (value == 0x4880) {
          stream.position += 2;
          value = stream.readUnsignedShort();

          if (value == lower) {
            stream.position += 2;
            songsData = stream.readUnsignedShort() + stream.position - 2;

            value = stream.readUnsignedShort();
            if (value != 0x3770) player.version = 5;
          }
        } else if (value == 0x51e9) {
          stream.position += 2;
          value = stream.readUnsignedShort();

          if (value == 0x50e9) {
            stream.position += 2;
            value = stream.readUnsignedShort();
            if (value != 0x41fa) stream.position += 4;
            player.table2 = stream.readUnsignedShort() + stream.position - 2;
            break;
          } else stream.position -= 2;
        }
      }

      if (songsData == 0) return;
      player.songs = new Vector.<DWSong>();
      lower = 0xffff;
      stream.position = songsData;

      while (true) {
        if (player.version == 5) {
          song = new DWSong();
          song.pointers = new Vector.<int>(4, true);
          song.speed = stream.readUnsignedByte();
          song.unknown = stream.readUnsignedByte();
        } else {
          value = stream.readUnsignedShort();
          if (value > 255) break;

          song = new DWSong();
          song.pointers = new Vector.<int>(channels, true);
          song.speed = value;
        }

        for (i = 0; i < channels; ++i) {
          value = stream.readUnsignedShort() + player.offset;
          if (value < lower) lower = value;
          song.pointers[i] = value;
        }

        player.songs[noSongs++] = song;
        if (stream.position >= lower) break;
      }

      player.songs.fixed = true;
      player.maxSong = --noSongs;

      stream.length  = samplesData;
      stream.position = 400;

      while (stream.bytesAvailable) {
        value = stream.readUnsignedShort();

        if (value == 0x00a8) {
          stream.position += 4;
          value = stream.readUnsignedShort();

          if (value == 0x45fa)
            player.periods = stream.readUnsignedShort() + stream.position - 2;
        } else if (value == 0xb03c) {
          value = stream.readUnsignedShort();

          if (value == 0x00b0) {
            stream.position += 10;
            player.table3 = stream.readUnsignedShort() + stream.position - 2;
          } else if (value == 0x00a0) {
            stream.position += 10;
            player.table1 = stream.readUnsignedShort() + stream.position - 2;
            break;
          }
        }
      }
    }
  }
}