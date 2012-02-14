package neoart.flod.whittaker2 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class W2Loader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var channels:int, data:int, i:int, info:int, init:int, loop:int, lower:int, player:W2Player, position:int, sample:W2Sample, song:W2Song, total:int, value:int;
      player = W2Player(amiga.player);
      value = stream.readUnsignedShort();
      if (value != 0x48e7) return;

      stream.position = 4;
      value = stream.readUnsignedShort();
      if (value != 0x6100) return;
      stream.position += stream.readUnsignedShort();

      while (value != 0x4e75) {
        value = stream.readUnsignedShort();

        switch (value) {
          case 0x6100:
            stream.position += 2;
            value = stream.readUnsignedShort();
            if (value != 0x6100) return;
            init = stream.position + stream.readUnsignedShort();
            break;
          case 0x41fa:
            info = stream.position + stream.readUnsignedShort();
            break;
          case 0x50e9:
            stream.position += 2;
            value = stream.readUnsignedShort();
            if (value != 0x41fa) return;
            player.table2 = stream.position + stream.readUnsignedShort();
            break;
          case 0xbe7c:
            channels = player.channels = stream.readUnsignedShort();
            stream.position += 2;
            value = stream.readUnsignedShort();
            if (value == 0x377c) player.master = stream.readUnsignedShort();
            value = 0x4e75;
            break;
        }
        if (stream.bytesAvailable == 0) return;
      }

      player.songs = new Vector.<W2Song>();
      lower = 0x7fffffff;
      total = 0;
      stream.position = info;

      while (stream.position < lower) {
        song = new W2Song();
        song.speed = stream.readUnsignedByte();
        song.timer = stream.readUnsignedByte();

        for (i = 0; i < channels; ++i) {
          value = stream.readUnsignedShort();
          if (value < lower) lower = value;
          song.pointers[i] = value;
        }
        song.pointers.fixed = true;
        player.songs[total++] = song;
      }

      player.songs.fixed = true;
      player.lastSong = --total;

      stream.position = init;
      value = stream.readUnsignedShort();
      if (value != 0x4a2b) return;

      while (value != 0x4e75) {
        value = stream.readUnsignedShort();

        if (value == 0x41fa) {
          data = stream.position + stream.readUnsignedShort();
          value = stream.readUnsignedShort();

          if (value == 0x4bfa) {
            info = stream.position + stream.readShort();
            stream.position++;
            total = stream.readUnsignedByte();
          } else {
            while (value != 0x4bfa) {
              value = stream.readUnsignedShort();
              if (value == 0xd0fc) data += stream.readUnsignedShort();
              if (stream.bytesAvailable == 0) return;
            }
            info = stream.position + stream.readShort();
            stream.position++;
            total = stream.readUnsignedByte();
          }

          player.samples = new Vector.<W2Sample>(++total, true);
          position = stream.position;
          stream.position = data;

          for (i = 0; i < total; ++i) {
            sample = new W2Sample();
            sample.length = stream.readUnsignedInt();
            sample.period = stream.readUnsignedShort();
            if (sample.period == 0) return;

            sample.period  = int(3579545 / sample.period);
            sample.pointer = value = stream.position;

            stream.position  = info + (i * 12) + 4;
            sample.loop = stream.readInt();

            stream.position = sample.pointer;
            sample.pointer  = amiga.memory.length;
            amiga.store(stream, sample.length);
            stream.position = value + sample.length;

            player.samples[i] = sample;
          }
          player.samples.fixed = true;
          amiga.loopLen = 64;

          stream.length   = data;
          stream.position = position;
        } else if (value == 0x50eb) {
          while (value != 0x4e75) {
            value = stream.readUnsignedShort();

            switch (value) {
              case 0x046b:
                value = stream.readUnsignedShort();
                lower = int((stream.readUnsignedShort() - info) / 12);
                player.samples[lower].period -= value;
                break;
              case 0x066b:
                value = stream.readUnsignedShort();
                lower = int((stream.readUnsignedShort() - info) / 12);
                player.samples[lower].period += value;
                break;
              case 0x207a:
                value = int((stream.position + stream.readShort() - info) / 12);
                player.wave = player.samples[value];
                stream.position += 6;
                player.sample1 = stream.readByte();
                stream.position += 12;
                player.sample2 = stream.readByte();
                stream.position += 12;
                player.wave.length = stream.readUnsignedShort() << 1;
                value = 0x4e75;
                break;
            }
          }
        }
        if (stream.bytesAvailable == 0) return;
      }

      stream.position = 330;
      player.com2 = 0xb0;
      player.com3 = 0xa0;
      player.com4 = 0x90;
      player.waveStep = loop = 1;

      while (loop) {
        value = stream.readUnsignedShort();

        switch (value) {
          case 0x47fa:
            player.offset = stream.position + stream.readShort();
            value = stream.readUnsignedShort();
            if (value != 0x4a2b) break;
            stream.position += 4;
            value = stream.readUnsignedShort();

            if (value == 0x4a2b) {
              position = stream.position;
              stream.position = stream.readUnsignedShort();
              player.interval = stream.readByte();
              stream.position = position;
            } else if (value == 0x103a) {
              stream.position += 4;
              value = stream.readUnsignedShort();
              if (value == 0xc0fc) player.multiply = stream.readUnsignedShort();
            }
            break;
          case 0x31bc:
            player.waveStep = 2;
          case 0x11bc:
            stream.position++;
            value = stream.readByte();

            if (value == player.sample1) {
              stream.position += 6;
              value = stream.readUnsignedShort();
              if (value == 0x0c6b) player.waveMax = stream.readUnsignedShort();
            } else if (value == player.sample2) {
              stream.position += 6;
              value = stream.readUnsignedShort();
              if (value == 0x0c6b) player.waveMin = stream.readUnsignedShort();
            }
            break;
          case 0xc2c2:
            if (player.master != 0) break;
            position = stream.position;
            stream.position -= 4;
            stream.position += stream.readUnsignedShort();
            player.master = stream.readUnsignedShort();
            stream.position = position;
            break;
          case 0x3d41:
            value = stream.readUnsignedShort();
            if (value != 0x00a8) break;
            stream.position += 8;
            value = stream.readUnsignedShort();
            if (value != 0x322d) break;
            stream.position -= 4;
            player.periods = stream.position + stream.readUnsignedShort();
            break;
          case 0xb03c:
            value = stream.readUnsignedShort();

            if (value == 0x00c0) {
              player.com2 = 0xc0;
              player.com3 = 0xb0;
              player.com4 = 0xa0;
            } else if (value == player.com3) {
              stream.position += 10;
              player.table3 = stream.position + stream.readUnsignedShort();
            } else if (value == player.com4) {
              stream.position += 10;
              player.table1 = stream.position + stream.readShort();
              loop = 0;
            }
            break;
        }
        if (stream.bytesAvailable == 0) return;
      }
      if (player.periods == 0 || player.table1 == 0 || player.table3 == 0) return;

      player.version = 2;
      player.com2 -= 256;
      player.com3 -= 256;
      player.com4 -= 256;
    }
  }
}