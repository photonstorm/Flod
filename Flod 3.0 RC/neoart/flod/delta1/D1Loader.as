package neoart.flod.delta1 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class D1Loader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var data:Vector.<int>, i:int, id:String, index:int, j:int, len:int, player:D1Player, position:int, row:AmigaRow, sample:D1Sample, step:D1Step, value:int;
      id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
      if (id != "ALL ") return;

      player = D1Player(amiga.player);
      position = 104;
      data = new Vector.<int>(25 ,true);
      for (i = 0; i < 25; ++i) data[i] = stream.readUnsignedInt();

      player.pointers = new Vector.<int>(4, true);
      for (i = 1; i < 4; ++i)
        player.pointers[i] = player.pointers[j] + (data[j++] >> 1) - 1;

      len = player.pointers[3] + (data[3] >> 1) - 1;
      player.tracks = new Vector.<D1Step>(len, true);
      index = position + data[1] - 2;
      stream.position = position;
      j = 1;

      for (i = 0; i < len; ++i) {
        step  = new D1Step();
        value = stream.readUnsignedShort();

        if (value == 0xffff || stream.position == index) {
          step.pattern   = -1;
          step.transpose = stream.readUnsignedShort();
          index += data[j++];
        } else {
          stream.position--;
          step.pattern   = ((value >> 2) & 0x3fc0) >> 2;
          step.transpose = stream.readByte();
        }
        player.tracks[i] = step;
      }

      len = data[4] >> 2;
      player.patterns = new Vector.<AmigaRow>(len, true);

      for (i = 0; i < len; ++i) {
        row = new AmigaRow();
        row.sample = stream.readUnsignedByte();
        row.note   = stream.readUnsignedByte();
        row.data1  = stream.readUnsignedByte() & 31;
        row.data2  = stream.readUnsignedByte();
        player.patterns[i] = row;
      }

      index = 5;

      for (i = 0; i < 20; ++i) {
        player.samples[i] = null;

        if (data[index] != 0) {
          sample = new D1Sample();
          sample.attackStep   = stream.readUnsignedByte();
          sample.attackDelay  = stream.readUnsignedByte();
          sample.decayStep    = stream.readUnsignedByte();
          sample.decayDelay   = stream.readUnsignedByte();
          sample.sustain      = stream.readUnsignedShort();
          sample.releaseStep  = stream.readUnsignedByte();
          sample.releaseDelay = stream.readUnsignedByte();
          sample.volume       = stream.readUnsignedByte();
          sample.vibratoWait  = stream.readUnsignedByte();
          sample.vibratoStep  = stream.readUnsignedByte();
          sample.vibratoLen   = stream.readUnsignedByte();
          sample.pitchBend    = stream.readByte();
          sample.portamento   = stream.readUnsignedByte();
          sample.synth        = stream.readUnsignedByte();
          sample.tableDelay   = stream.readUnsignedByte();

          for (j = 0; j < 8; ++j)
            sample.arpeggio[j] = stream.readByte();

          sample.length = stream.readUnsignedShort();
          sample.loop   = stream.readUnsignedShort();
          sample.repeat = stream.readUnsignedShort() << 1;
          sample.synth  = sample.synth ? 0 : 1;

          if (sample.synth) {
            for (j = 0; j < 48; ++j)
              sample.table[j] = stream.readByte();
            len = data[index] - 78;
          } else
            len = sample.length;

          sample.pointer = amiga.store(stream, len);
          sample.loopPtr = sample.pointer + sample.loop;
          player.samples[i] = sample;
        }
        index++;
      }

      sample = new D1Sample();
      sample.pointer = sample.loopPtr = amiga.memory.length;
      sample.length  = sample.repeat  = 2;
      player.samples[20] = sample;
      player.version = 1;
    }
  }
}