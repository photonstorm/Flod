package neoart.flod.delta2 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class D2Loader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var i:int, id:String, j:int, len:int, offsets:Vector.<int>, player:D2Player, position:int, row:AmigaRow, sample:D2Sample, step:D2Step, value:int;
      stream.position = 3014;
      id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
      if (id != ".FNL") return;

      stream.position = 4042;
      player = D2Player(amiga.player);
      player.data = new Vector.<int>(12, true);

      for (i = 0; i < 4; ++i) {
        player.data[int(i + 4)] = stream.readUnsignedShort();
        value = stream.readUnsignedShort() >> 1;
        player.data[int(i + 8)] = value;
        len += value;
      }

      value = len;
      for (i = 3; i > 0; --i) player.data[i] = (value -= player.data[int(i + 8)]);
      player.tracks = new Vector.<D2Step>(len, true);

      for (i = 0; i < len; ++i) {
        step = new D2Step();
        step.pattern   = stream.readUnsignedByte() << 4;
        step.transpose = stream.readByte();
        player.tracks[i] = step;
      }

      len = stream.readUnsignedInt() >> 2;
      player.patterns = new Vector.<AmigaRow>(len, true);

      for (i = 0; i < len; ++i) {
        row = new AmigaRow();
        row.note   = stream.readUnsignedByte();
        row.sample = stream.readUnsignedByte();
        row.data1  = stream.readUnsignedByte() - 1;
        row.data2  = stream.readUnsignedByte();
        player.patterns[i] = row;
      }

      stream.position += 254;
      value = stream.readUnsignedShort();
      position = stream.position;
      stream.position -= 256;

      len = 1;
      offsets = new Vector.<int>(128, true);

      for (i = 0; i < 128; ++i) {
        j = stream.readUnsignedShort();
        if (j != value) offsets[len++] = j;
      }

      player.samples = new Vector.<D2Sample>(len, true);

      for (i = 0; i < len; ++i) {
        stream.position = position + offsets[i];
        sample = new D2Sample();
        sample.length = stream.readUnsignedShort() << 1;
        sample.loop   = stream.readUnsignedShort();
        sample.repeat = stream.readUnsignedShort() << 1;

        for (j = 0; j < 15; ++j)
          sample.volumes[j] = stream.readUnsignedByte();
        for (j = 0; j < 15; ++j)
          sample.vibratos[j] = stream.readUnsignedByte();

        sample.pitchBend = stream.readUnsignedShort();
        sample.synth     = stream.readByte();
        sample.index     = stream.readUnsignedByte();

        for (j = 0; j < 48; ++j)
          sample.table[j] = stream.readUnsignedByte();

        player.samples[i] = sample;
      }

      len = stream.readUnsignedInt();
      amiga.store(stream, len);

      stream.position += 64;
      for (i = 0; i < 8; ++i)
        offsets[i] = stream.readUnsignedInt();

      len = player.samples.length;
      position = stream.position;

      for (i = 0; i < len; ++i) {
        sample = player.samples[i];
        if (sample.synth >= 0) continue;
        stream.position = position + offsets[sample.index];
        sample.pointer = amiga.store(stream, sample.length);
        sample.loopPtr = sample.pointer + sample.loop;
      }

      stream.position = 3018;
      for (i = 0; i < 1024; ++i)
        player.arpeggios[i] = stream.readByte();

      sample = new D2Sample();
      sample.pointer = sample.loopPtr = amiga.memory.length;
      sample.length  = sample.repeat  = 2;

      player.samples[len] = sample;
      player.samples.fixed = true;
      player.version = 2;
    }
  }
}