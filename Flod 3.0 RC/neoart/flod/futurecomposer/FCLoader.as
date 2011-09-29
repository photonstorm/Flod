package neoart.flod.futurecomposer {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class FCLoader {
    [Embed(source="waveforms.bin", mimeType="application/octet-stream")]
    private static var Waveforms:Class;

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var i:int, id:String, j:int, len:int, offset:int, player:FCPlayer, position:int, sample:AmigaSample, size:int, temp:int, total:int, wave:ByteArray;
      player = FCPlayer(amiga.player);

      id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
      if (id == "SMOD") player.version = FCPlayer.FUTURECOMP_10;
        else if (id == "FC14") player.version = FCPlayer.FUTURECOMP_14;
          else return;

      player.seqs = new ByteArray();
      stream.position = 4;
      player.length   = stream.readUnsignedInt();
      stream.position = player.version == FCPlayer.FUTURECOMP_10 ? 100 : 180;
      stream.readBytes(player.seqs, 0, player.length);
      player.length  /= 13;

      player.pats = new ByteArray();
      stream.position = 12;
      len = stream.readUnsignedInt();
      stream.position = 8;
      stream.position = stream.readUnsignedInt();
      stream.readBytes(player.pats, 0, len);

      player.pats.position = player.pats.length;
      player.pats.writeByte(0);
      player.pats.position = 0;

      player.frqs = new ByteArray();
      player.frqs.writeInt(0x01000000);
      player.frqs.writeInt(0x000000e1);
      stream.position = 20;
      len = stream.readUnsignedInt();
      stream.position = 16;
      stream.position = stream.readUnsignedInt();
      stream.readBytes(player.frqs, 8, len);

      player.frqs.position = player.frqs.length;
      player.frqs.writeByte(0xe1);
      player.frqs.position = 0;

      player.vols = new ByteArray();
      player.vols.writeInt(0x01000000);
      player.vols.writeInt(0x000000e1);
      stream.position = 28;
      len = stream.readUnsignedInt();
      stream.position = 24;
      stream.position = stream.readUnsignedInt();
      stream.readBytes(player.vols, 8, len);

      stream.position = 32;
      size = stream.readUnsignedInt();
      stream.position = 40;

      if (player.version == FCPlayer.FUTURECOMP_10) {
        player.samples = new Vector.<AmigaSample>(57, true);
        offset = 0;
      } else {
        player.samples = new Vector.<AmigaSample>(200, true);
        offset = 2;
      }

      for (i = 0; i < 10; ++i) {
        len = stream.readUnsignedShort() << 1;

        if (len > 0) {
          position = stream.position;
          stream.position = size;
          id = stream.readMultiByte(4, AmigaPlayer.ENCODING);

          if (id == "SSMP") {
            temp = len;

            for (j = 0; j < 10; ++j) {
              stream.readInt();
              len = stream.readUnsignedShort() << 1;

              if (len > 0) {
                sample = new AmigaSample();
                sample.length = len + 2;
                sample.loop   = stream.readUnsignedShort();
                sample.repeat = stream.readUnsignedShort() << 1;

                if ((sample.loop + sample.repeat) > sample.length)
                  sample.repeat = sample.length - sample.loop;

                if ((size + sample.length) > stream.length)
                  sample.length = stream.length - size;

                sample.pointer = amiga.store(stream, sample.length, size + total);
                sample.loopPtr = sample.pointer + sample.loop;
                player.samples[100 + (i * 10) + j] = sample;
                total += sample.length;
                stream.position += 6;
              } else
                stream.position += 10;
            }

            size += (temp + 2);
            stream.position = position + 4;
          } else {
            stream.position = position;
            sample = new AmigaSample();
            sample.length = len + offset;
            sample.loop   = stream.readUnsignedShort();
            sample.repeat = stream.readUnsignedShort() << 1;

            if ((sample.loop + sample.repeat) > sample.length)
              sample.repeat = sample.length - sample.loop;

            if ((size + sample.length) > stream.length)
              sample.length = stream.length - size;

            sample.pointer = amiga.store(stream, sample.length, size);
            sample.loopPtr = sample.pointer + sample.loop;
            player.samples[i] = sample;
            size += sample.length;
          }
        } else
          stream.position += 4;
      }

      if (player.version == FCPlayer.FUTURECOMP_10) {
        wave = new Waveforms() as ByteArray;
        size = 47;

        for (i = 10; i < 57; ++i) {
          sample = new AmigaSample();
          sample.length  = wave.readUnsignedByte() << 1;
          sample.loop    = 0;
          sample.repeat  = sample.length;
          sample.pointer = amiga.store(wave, sample.length, size);
          sample.loopPtr = sample.pointer;
          player.samples[i] = sample;
          size += sample.length;
        }
      } else {
        stream.position = 36;
        size = stream.readUnsignedInt();
        stream.position = 100;

        for (i = 10; i < 90; ++i) {
          len = stream.readUnsignedByte() << 1;
          if (len < 2) continue;
          sample = new AmigaSample();
          sample.length = len;
          sample.loop   = 0;
          sample.repeat = sample.length;

          if ((size + sample.length) > stream.length)
            sample.length = stream.length - size;

          sample.pointer = amiga.store(stream, sample.length, size);
          sample.loopPtr = sample.pointer;
          player.samples[i] = sample;
          size += sample.length;
        }
      }

      player.length = int(player.length * 13);
    }
  }
}