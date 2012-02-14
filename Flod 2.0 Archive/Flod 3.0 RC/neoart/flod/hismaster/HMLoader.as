package neoart.flod.hismaster {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class HMLoader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var higher:int, i:int, id:String, j:int, mupp:int, player:HMPlayer, position:int, row:AmigaRow, sample:HMSample, size:int, value:int;
      if (stream.length < 2150) return;

      stream.position = 1080;
      id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
      if (id != "FEST") return;

      stream.position = 0;
      player = HMPlayer(amiga.player);
      player.title = stream.readMultiByte(20, AmigaPlayer.ENCODING);
      player.version = 1;

      stream.position = 950;
      player.length  = stream.readUnsignedByte();
      player.restart = stream.readUnsignedByte();

      for (i = 0; i < 128; ++i)
        player.track[i] = stream.readUnsignedByte();

      for (i = 1; i < 32; ++i) {
        player.samples[i] = null;
        id = stream.readMultiByte(4, AmigaPlayer.ENCODING);

        if (id == "Mupp") {
          value = stream.readUnsignedByte();
          for (j = 0; j < 128; ++j)
            if (player.track[j] >= value) player.track[j]--;

          sample = new HMSample();
          sample.name = id;
          sample.length  = sample.repeat = 32;
          sample.restart = stream.readUnsignedByte();
          sample.waveLen = stream.readUnsignedByte();
          stream.position += 17;
          sample.finetune = stream.readByte();
          sample.volume   = stream.readUnsignedByte();

          position = stream.position + 4;
          value = 1084 + (value << 10);
          stream.position = value;

          sample.pointer = amiga.memory.length;
          sample.waves = new Vector.<int>(64, true);
          sample.volumes = new Vector.<int>(64, true);
          amiga.store(stream, 896);

          for (j = 0; j < 64; ++j)
            sample.waves[j] = stream.readUnsignedByte() << 5;
          for (j = 0; j < 64; ++j)
            sample.volumes[j] = stream.readUnsignedByte() & 127;

          stream.position = value;
          stream.writeInt(0x666c6f64);
          stream.position = position;
          mupp += 896;
        } else {
          id = id.substr(0, 2);
          if (id == "El")
            stream.position += 18;
          else {
            stream.position -= 4;
            id = stream.readMultiByte(22, AmigaPlayer.ENCODING);
          }
          value = stream.readUnsignedShort();
          if (value == 0) continue;

          sample = new HMSample();
          sample.name = id;
          sample.pointer  = size;
          sample.length   = value << 1;
          sample.finetune = stream.readByte();
          sample.volume   = stream.readUnsignedByte();
          sample.loop     = stream.readUnsignedShort() << 1;
          sample.repeat   = stream.readUnsignedShort() << 1;
          size += sample.length;
        }
        player.samples[i] = sample;
      }

      for (i = 0; i < 128; ++i) {
        value = player.track[i] << 8;
        player.track[i] = value;
        if (value > higher) higher = value;
      }

      stream.position = 1084;
      higher += 256;
      player.patterns = new Vector.<AmigaRow>(higher, true);

      for (i = 0; i < higher; ++i) {
        value = stream.readUnsignedInt();
        while (value == 0x666c6f64) {
          stream.position += 1020;
          value = stream.readUnsignedInt();
        }

        row = new AmigaRow();
        row.note   = (value >> 16) & 0x0fff;
        row.sample = (value >> 24) & 0xf0 | (value >> 12) & 0x0f;
        row.data1  = (value >>  8) & 0x0f;
        row.data2  = value & 0xff;
        player.patterns[i] = row;
      }

      amiga.store(stream, size);

      for (i = 1; i < 32; ++i) {
        sample = player.samples[i];
        if (sample == null || sample.name == "Mupp") continue;
        sample.pointer += mupp;

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

      sample = new HMSample();
      sample.pointer = sample.loopPtr = amiga.memory.length;
      sample.length  = sample.repeat  = 2;
      player.samples[0] = sample;
    }
  }
}