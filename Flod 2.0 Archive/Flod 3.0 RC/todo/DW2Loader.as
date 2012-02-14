package neoart.flod.whittaker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class DW2Loader {

    public static function initialize(stream:ByteArray, amiga:Amiga):void {
      var i:int, channels:int, lower:int, noSamples:int, noSongs:int, player:DW2Player, sample:DWSample, samplesData:int, samplesHeader:int, song:DWSong, songsData:int, value:int;

      player = DW2Player(amiga.player);

      while (stream.bytesAvailable) {
        value = stream.readUnsignedByte();

        if (value == 0x66) {
          stream.position++;
          value = stream.readUnsignedShort();

          if (value == 0x41fa) {
            samplesData = stream.readUnsignedShort() + stream.position - 2;
            value = stream.readUnsignedShort();

            if (value == 0x4bfa) {
              samplesHeader = stream.readUnsignedShort() + stream.position - 2;
              stream.position++;
              noSamples = stream.readUnsignedByte() + 1;
              break;
            }
          }
        }
      }

      stream.position = 0;

      while (stream.bytesAvailable) {
        value = stream.readUnsignedShort();

        if (value == 0x4e75) {
          stream.position -= 10;
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
        sample.volume  = stream.readUnsignedShort();
        sample.unknown = stream.readByte();

        value = stream.position + 1;
        stream.position = sample.pointer;
        sample.pointer = amiga.memory.length;
        amiga.store(stream, sample.length);
        stream.position = value;
      }

      player.samples.fixed = true;
      amiga.loopLen = 64;

      stream.position = 70;

      while (stream.bytesAvailable) {
        value = stream.readUnsignedShort();

        if (value == 0x3770) {
          stream.position -= 4;
          songsData = stream.readUnsignedShort() + stream.position - 2;
          stream.position += 2;
        } else if (value == 0x51e9) {
          stream.position += 2;
          value = stream.readUnsignedShort();

          if (value == 0x50e9) {
            stream.position += 4;
            player.table2 = stream.readUnsignedShort() + stream.position - 2;
            break;
          } else stream.position -= 2;
        }
      }

      if (songsData == 0) return;
      player.songs = new Vector.<DWSong>();
      lower = 0xffff;
      channels = player.channels + 1;
      stream.position = songsData;

      while (true) {
        song = new DWSong();
        song.pointers = new Vector.<int>(channels, true);
        song.speed = stream.readUnsignedShort();

        for (i = 0; i < channels; ++i) {
          value = stream.readUnsignedShort();
          if (value < lower) lower = value;
          song.pointers[i] = value;
        }

        player.songs[noSongs++] = song;
        if (stream.position >= lower) break;
      }

      player.songs.fixed = true;
      player.maxSong = --noSongs;
      player.version = 1;

      stream.position = 72;
      if (stream.readUnsignedShort() == 0x426b) player.version = 2;

      stream.length  = samplesData;
      stream.position = 300;

      while (stream.bytesAvailable) {
        value = stream.readUnsignedShort();

        if (value == 0x00a8) {
          stream.position += 4;
          value = stream.readUnsignedShort();

          if (value == 0x45fa)
            player.periods = stream.readUnsignedShort() + stream.position - 2;
        } else if (value == 0xb03c) {
          value = stream.readUnsignedShort();

          if (value == 0x00a0) {
            stream.position += 10;
            player.table1 = stream.readUnsignedShort() + stream.position - 2;
            break;
          }
        }
      }
    }
  }
}