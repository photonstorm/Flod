package neoart.flod.noisetracker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class MKLoader {

    internal static function load(stream:ByteArray, amiga:Amiga):void {
      var highest:int, i:int, id:String, j:int, player:MKPlayer, row:AmigaRow, sample:AmigaSample, size:int, value:int;
      if (stream.length < 2150) return;

      stream.position = 1080;
      id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
      if (id != "M.K." && id != "FLT4") return;

      stream.position = 0;
      player = MKPlayer(amiga.player);
      player.title = stream.readMultiByte(20, AmigaPlayer.ENCODING);
      player.version = MKPlayer.SOUNDTRACKER_23;
      stream.position += 22;

      for (i = 1; i < 32; ++i) {
        value = stream.readUnsignedShort();
        if (value == 0) {
          player.samples[i] = null;
          stream.position += 28;
          continue;
        }
        sample = new AmigaSample();
        stream.position -= 24;

        sample.name   = stream.readMultiByte(22, AmigaPlayer.ENCODING);
        sample.length = value << 1;
        stream.position += 3;
        sample.volume = stream.readUnsignedByte();
        sample.loop   = stream.readUnsignedShort() << 1;
        sample.repeat = stream.readUnsignedShort() << 1;

        stream.position += 22;
        sample.pointer = size;
        size += sample.length;
        player.samples[i] = sample;

        if (sample.length > 32768) player.version = MKPlayer.SOUNDTRACKER_24;
      }

      stream.position = 950;
      player.length = stream.readUnsignedByte();
      value = stream.readUnsignedByte();
      player.restart = value < player.length ? value : 0;

      for (i = 0; i < 128; ++i) {
        value = stream.readUnsignedByte() << 8;
        player.track[i] = value;
        if (value > highest) highest = value;
      }

      stream.position = 1084;
      highest += 256;
      player.patterns = new Vector.<AmigaRow>(highest, true);

      for (i = 0; i < highest; ++i) {
        row = new AmigaRow();
        value = stream.readUnsignedInt();
        row.note   = (value >> 16) & 0x0fff;
        row.data1  = (value >>  8) & 0x0f;
        row.sample = (value >> 24) & 0xf0 | (value >> 12) & 0x0f;
        row.data2  = value & 0xff;
        player.patterns[i] = row;

        if (row.sample > 31 || player.samples[row.sample] == null)
          row.sample = 0;
        if (row.data1 == 3 || row.data2 == 4)
          player.version = MKPlayer.NOISETRACKER_10;
        else if (row.data1 == 5 || row.data1 == 6)
          player.version = MKPlayer.NOISETRACKER_20;
        //else if ((row.data1 > 6 && row.data1 < 10) || (row.data1 == 14 && row.data2 > 1)) {
        //  player.version = 0;
        //  return;
        //}
      }

      amiga.store(stream, size);

      for (i = 1; i < 32; ++i) {
        sample = player.samples[i];
        if (sample == null) continue;
        if (sample.name.indexOf("2.0") > -1)
          player.version = MKPlayer.NOISETRACKER_20;

        if (sample.loop) {
          sample.loopPtr = sample.pointer + sample.loop;
          sample.length  = sample.loop + sample.repeat;
        } else {
          sample.loopPtr = amiga.memory.length;
          sample.repeat  = 2;
        }
        size = sample.pointer + 4;
        for (j = sample.pointer; j < size; ++j) amiga.memory[j] = 0;
      }

      sample = new AmigaSample();
      sample.pointer = sample.loopPtr = amiga.memory.length;
      sample.length  = sample.repeat  = 2;
      player.samples[0] = sample;

      if (player.version < MKPlayer.NOISETRACKER_20)
        if (player.restart) player.version = MKPlayer.NOISETRACKER_11;
    }
  }
}