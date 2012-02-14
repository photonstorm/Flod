package neoart.flod.soundtracker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class STLoader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var higher:int, i:int, j:int, player:STPlayer, row:AmigaRow, sample:AmigaSample, score:int, size:int, value:int;
      if (stream.length < 1626) return;

      player = STPlayer(amiga.player);
      player.title = stream.readMultiByte(20, AmigaPlayer.ENCODING);
      player.version = STPlayer.ULTIMATE_SOUNDTRACKER;
      if (isLegal(player.title)) score++;
      stream.position = 42;

      for (i = 1; i < 16; ++i) {
        value = stream.readUnsignedShort();
        if (value == 0) {
          player.samples[i] = null;
          stream.position += 28;
          continue;
        }
        sample = new AmigaSample();
        stream.position -= 24;

        sample.name = stream.readMultiByte(22, AmigaPlayer.ENCODING);
        sample.length = value << 1;
        stream.position += 3;
        sample.volume = stream.readUnsignedByte();
        sample.loop   = stream.readUnsignedShort();
        sample.repeat = stream.readUnsignedShort() << 1;

        stream.position += 22;
        sample.pointer += size;
        size += sample.length;
        player.samples[i] = sample;

        if (isLegal(sample.name)) score++;
        if (sample.length > 9999)
          player.version = STPlayer.MASTER_SOUNDTRACKER;
      }

      stream.position = 470;
      player.length = stream.readUnsignedByte();
      player.tempo  = stream.readUnsignedByte();

      for (i = 0; i < 128; ++i) {
        value = stream.readUnsignedByte() << 8;
        if (value > 16384) score--;
        player.track[i] = value;
        if (value > higher) higher = value;
      }

      stream.position = 600;
      higher += 256;
      player.patterns = new Vector.<AmigaRow>(higher, true);

      i = (stream.length - size - 600) >> 2;
      if (higher > i) higher = i;

      for (i = 0; i < higher; ++i) {
        row = new AmigaRow();
        row.note   = stream.readUnsignedShort();
        value      = stream.readUnsignedByte();
        row.data2  = stream.readUnsignedByte();
        row.data1  = value & 0x0f;
        row.sample = value >> 4;
        player.patterns[i] = row;

        if (row.data1 > 2 && row.data1 < 11) score--;
        if (row.note != 0)
          if (row.note < 113 || row.note > 856) score--;

        if (row.sample != 0)
          if (row.sample > 15 || player.samples[row.sample] == null) {
            row.sample = 0;
            score--;
          }

        if (row.data1 > 2 || (row.data1 == 0 && row.data2 != 0))
          player.version = STPlayer.DOC_SOUNDTRACKER_9;
        if (row.data1 == 11 || row.data1 == 13)
          player.version = STPlayer.DOC_SOUNDTRACKER_20;
      }

      amiga.store(stream, size);

      for (i = 1; i < 16; ++i) {
        sample = player.samples[i];
        if (sample == null) continue;

        if (sample.loop) {
          sample.loopPtr = sample.pointer + sample.loop;
          sample.pointer = sample.loopPtr;
          sample.length  = sample.repeat;
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

      if (score < 1) player.version = 0;
    }

    public static function isLegal(text:String):int {
      var c:int, i:int, len:int = text.length;
      if (len == 0) return 0;

      for (i = 0; i < len; ++i) {
        c = text.charCodeAt(i);
        if (c) { if (c < 32 || c > 127) return 0; }
      }
      return 1;
    }
  }
}