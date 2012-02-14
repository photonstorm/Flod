package neoart.flod.digitalmugician {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class DMLoader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var data:int, i:int, id:String, index:Vector.<int>, instr:int, j:int, len:int, player:DMPlayer, position:int, row:AmigaRow, sample:DMSample, song:DMSong, step:DMStep;
      player = DMPlayer(amiga.player);

      id = stream.readMultiByte(24, AmigaPlayer.ENCODING);
      if (id == "MUGICIAN/SOFTEYES 1990 ") player.version = DMPlayer.DIGITALMUG_V1;
        else if (id == "MUGICIAN2/SOFTEYES 1990") player.version = DMPlayer.DIGITALMUG_V2;
          else return;

      stream.position = 28;
      index = new Vector.<int>(8, true);
      for (i = 0; i < 8; ++i) index[i] = stream.readUnsignedInt();

      stream.position = 76;

      for (i = 0; i < 8; ++i) {
        song = new DMSong();
        song.loop     = stream.readUnsignedByte();
        song.loopStep = stream.readUnsignedByte() << 2;
        song.speed    = stream.readUnsignedByte();
        song.length   = stream.readUnsignedByte() << 2;
        song.title    = stream.readMultiByte(12, AmigaPlayer.ENCODING);
        player.songs[i] = song;
      }

      stream.position = 204;

      for (i = 0; i < 8; ++i) {
        song = player.songs[i];
        len  = index[i] << 2;

        for (j = 0; j < len; ++j) {
          step = new DMStep();
          step.pattern   = stream.readUnsignedByte() << 6;
          step.transpose = stream.readByte();
          song.tracks[j] = step;
        }
        song.tracks.fixed = true;
      }

      position = stream.position;
      stream.position = 60;
      len = stream.readUnsignedInt();
      player.samples = new Vector.<DMSample>(++len, true);
      stream.position = position;

      for (i = 1; i < len; ++i) {
        sample = new DMSample();
        sample.wave        = stream.readUnsignedByte();
        sample.waveLen     = stream.readUnsignedByte() << 1;
        sample.volume      = stream.readUnsignedByte();
        sample.volumeSpeed = stream.readUnsignedByte();
        sample.arpeggio    = stream.readUnsignedByte();
        sample.pitch       = stream.readUnsignedByte();
        sample.effectStep  = stream.readUnsignedByte();
        sample.pitchDelay  = stream.readUnsignedByte();
        sample.finetune    = stream.readUnsignedByte() << 6;
        sample.pitchLoop   = stream.readUnsignedByte();
        sample.pitchSpeed  = stream.readUnsignedByte();
        sample.effect      = stream.readUnsignedByte();
        sample.source1     = stream.readUnsignedByte();
        sample.source2     = stream.readUnsignedByte();
        sample.effectSpeed = stream.readUnsignedByte();
        sample.volumeLoop  = stream.readUnsignedByte();
        player.samples[i] = sample;
      }

      player.samples[0] = player.samples[1];

      position = stream.position;
      stream.position = 64;
      len = stream.readUnsignedInt() << 7;
      stream.position = position;
      amiga.store(stream, len);

      position = stream.position;
      stream.position = 68;
      instr = stream.readUnsignedInt();

      stream.position = 26;
      len = stream.readUnsignedShort() << 6;
      player.patterns = new Vector.<AmigaRow>(len, true);
      stream.position = position + (instr << 5);

      if (instr) instr = position;

      for (i = 0; i < len; ++i) {
        row = new AmigaRow();
        row.note   = stream.readUnsignedByte();
        row.sample = stream.readUnsignedByte() & 63;
        row.data1  = stream.readUnsignedByte();
        row.data2  = stream.readByte();
        player.patterns[i] = row;
      }

      position = stream.position;
      stream.position = 72;

      if (instr) {
        len = stream.readUnsignedInt();
        stream.position = position;
        data = amiga.store(stream, len);
        position = stream.position;

        amiga.memory.length += 350;
        player.buffer1 = amiga.memory.length;
        amiga.memory.length += 350;
        player.buffer2 = amiga.memory.length;
        amiga.memory.length += 350;
        amiga.loopLen = 8;

        len = player.samples.length;

        for (i = 1; i < len; ++i) {
          sample = player.samples[i];
          if (sample.wave < 32) continue;
          stream.position = instr + ((sample.wave - 32) << 5);

          sample.pointer = stream.readUnsignedInt();
          sample.length  = stream.readUnsignedInt() - sample.pointer;
          sample.loop    = stream.readUnsignedInt();
          sample.name    = stream.readMultiByte(12, AmigaPlayer.ENCODING);

          if (sample.loop) {
            sample.loop  -= sample.pointer;
            sample.repeat = sample.length - sample.loop;
          } else {
            sample.loopPtr = amiga.memory.length;
            sample.repeat  = 8;
          }

          if ((sample.pointer & 1) != 0) sample.pointer--;
          if ((sample.length  & 1) != 0) sample.length--;

          sample.pointer += data;
          if (sample.loop) sample.loopPtr = sample.pointer + sample.loop;

          amiga.memory[sample.pointer] = 0;
          amiga.memory[int(sample.pointer + 1)] = 0;
        }
      } else
        position += stream.readUnsignedInt();

      stream.position = 24;

      if (stream.readUnsignedShort() == 1) {
        stream.position = position;
        len = stream.length - stream.position;
        if (len > 256) len = 256;
        for (i = 0; i < len; ++i) player.arpeggios[i] = stream.readUnsignedByte();
      }
    }
  }
}