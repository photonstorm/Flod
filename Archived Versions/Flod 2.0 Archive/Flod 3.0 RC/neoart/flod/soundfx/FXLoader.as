package neoart.flod.soundfx {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class FXLoader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var higher:int, i:int, id:String, j:int, length:int, offset:int, row:AmigaRow, sample:AmigaSample, size:int, value:int;
      if (stream.length < 1686) return;

      player = FXPlayer(amiga.player);
      stream.position = 60;
      id = stream.readMultiByte(4, AmigaPlayer.ENCODING);

      if (id != "SONG") {
        stream.position = 124;
        id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
        if (id != "SO31") return;
        if (stream.length < 2350) return;

        length = 32;
        offset = 544;
        player.version = FXPlayer.SOUNDFX_20;
      } else {
        length = 16;
        offset = 0;
        player.version = FXPlayer.SOUNDFX_10;
      }

      player.samples.length = length;
      player.samples.fixed  = true;
      player.tempo = stream.readUnsignedShort();
      stream.position = 0;

      for (i = 1; i < length; ++i) {
        value = stream.readUnsignedInt();

        if (value) {
          sample = new AmigaSample();
          sample.pointer = size;
          size += value;
          player.samples[i] = sample;
        } else
          player.samples[i] = null;
      }

      stream.position += 20;

      for (i = 1; i < length; ++i) {
        sample = player.samples[i];
        if (sample == null) {
          stream.position += 30;
          continue;
        }

        sample.name   = stream.readMultiByte(22, AmigaPlayer.ENCODING);
        sample.length = stream.readUnsignedShort() << 1;
        sample.volume = stream.readUnsignedShort();
        sample.loop   = stream.readUnsignedShort();
        sample.repeat = stream.readUnsignedShort() << 1;
      }

      stream.position = 530 + offset;
      player.length = length = stream.readUnsignedByte();
      stream.position++;

      for (i = 0; i < length; ++i) {
        value = stream.readUnsignedByte() << 8;
        player.track[i] = value;
        if (value > higher) higher = value;
      }

      if (offset) offset += 4;
      stream.position = 660 = offset;
      higher += 256;
      length = player.samples.length;
      player.patterns = new Vector.<AmigaRow>(higher, true);

      for (i = 0; i < higher; ++i) {
        row = new AmigaRow();
        row.note   = stream.readShort();
        value      = stream.readUnsignedByte();
        row.data2  = stream.readUnsignedByte();
        row.data1  = value & 0x0f;
        row.sample = value >> 4;
        player.patterns[i] = row;

        if (player.version == FXPlayer.SOUNDFX_20) {
          if (row.note & 0x1000) {
            row.sample += 16;
            if (row.note > 0) row.note &= 0xefff;
          }
        } else {
          if (row.data1 == 9 || row.note > 856)
            player.version = FXPlayer.SOUNDFX_18;
          if (row.note < -3)
            player.version = FXPlayer.SOUNDFX_19;
        }

        if (row.sample >= length || player.samples[row.sample] == null)
          row.sample = 0;
      }

      amiga.store(stream, size);

      for (i = 1; i < length; ++i) {
        sample = player.samples[i];
        if (sample == null) continue;

        if (sample.loop)
          sample.loopPtr = sample.pointer + sample.loop;
        else {
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
    }
  }
}