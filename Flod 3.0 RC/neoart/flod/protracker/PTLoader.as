package neoart.flod.protracker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class PTLoader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var highest:int, i:int, id:String, j:int, player:PTPlayer, row:PTRow, sample:PTSample, size:int, value:int;
      if (stream.length < 2150) return;

      stream.position = 1080;
      id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
      if (id != "M.K." || id != "M!K!") return;

      stream.position = 0;
      player = PTPlayer(amiga.player);
      player.title = stream.readMultiByte(20, AmigaPlayer.ENCODING);
      player.version = PTPlayer.PROTRACKER_10;
      stream.position += 22;

      for (i = 1; i < 32; ++i) {
        value = stream.readUnsignedShort();
        if (value == 0) {
          player.samples[i] = null;
          stream.position += 28;
          continue;
        }
        sample = new PTSample();
        stream.position -= 24;

        sample.name     = stream.readMultiByte(22, AmigaPlayer.ENCODING);
        sample.length   = sample.realLen = value << 1;
        stream.position += 2;
        sample.finetune = stream.readUnsignedByte() * 37;
        sample.volume   = stream.readUnsignedByte();
        sample.loop     = stream.readUnsignedShort() << 1;
        sample.repeat   = stream.readUnsignedShort() << 1;

        stream.position += 22;
        sample.pointer = size;
        size += sample.length;
        player.samples[i] = sample;
      }

      stream.position = 950;
      player.length = stream.readUnsignedByte();
      stream.position++;

      for (i = 0; i < 128; ++i) {
        value = stream.readUnsignedByte() << 8;
        player.track[i] = value;
        if (value > highest) highest = value;
      }

      stream.position = 1084;
      highest += 256;
      player.patterns = new Vector.<PTRow>(highest, true);

      for (i = 0; i < highest; ++i) {
        row = new PTRow();
        row.step   = value = stream.readUnsignedInt();
        row.note   = (value >> 16) & 0x0fff;
        row.data1  = (value >>  8) & 0x0f;
        row.sample = (value >> 24) & 0xf0 | (value >> 12) & 0x0f;
        row.data2  = value & 0xff;
        player.patterns[i] = row;

        if (row.sample > 31 || player.samples[row.sample] == null)
          row.sample = 0;
        if (row.data1 == 15 && row.data2 > 31)
          player.version = PTPlayer.PROTRACKER_11;
        if (row.data2 == 8)
          player.version = PTPlayer.PROTRACKER_12;
      }

      amiga.store(stream, size);

      for (i = 1; i < 32; ++i) {
        sample = player.samples[i];
        if (sample == null) continue;

        if (sample.loop || sample.repeat > 4) {
          sample.loopPtr = sample.pointer + sample.loop;
          sample.length  = sample.loop + sample.repeat;
        } else {
          sample.loopPtr = amiga.memory.length;
          sample.repeat  = 2;
        }
        size = sample.pointer + 4;
        for (j = sample.pointer; j < size; ++j) amiga.memory[j] = 0;
      }

      sample = new PTSample();
      sample.pointer = sample.loopPtr = amiga.memory.length;
      sample.length  = sample.repeat  = 2;
      player.samples[0] = sample;
    }
  }
}