package neoart.flod.sidmon2 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class S2Loader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var i:int, id:String, instr:S2Instrument, j:int, len:int, patterns:int, player:S2Player, pointers:Vector.<int>, position:int, pos:int, row:S2Row, step:S2Step, sample:S2Sample, sampleData:int, value:int;
      player = S2Player(amiga.player);
      id = stream.readMultiByte(28, AmigaPlayer.ENCODING);
      if (id != "SIDMON II - THE MIDI VERSION") return;

      stream.position = 2;
      player.length   = stream.readUnsignedByte();
      player.speedDef = stream.readUnsignedByte();
      player.samples  = new Vector.<S2Sample>(stream.readUnsignedShort() >> 6, true);

      stream.position = 14;
      len = stream.readUnsignedInt();
      player.tracks = new Vector.<S2Step>(len, true);
      stream.position = 90;

      for (i = 0; i < len; ++i) {
        step = new S2Step();
        step.pattern = stream.readUnsignedByte();
        if (step.pattern > patterns) patterns = step.pattern;
        player.tracks[i] = step;
      }

      for (i = 0; i < len; ++i) {
        step = player.tracks[i];
        step.transpose = stream.readByte();
      }

      for (i = 0; i < len; ++i) {
        step = player.tracks[i];
        step.soundTranspose = stream.readByte();
      }

      position = stream.position;
      stream.position = 26;
      len = stream.readUnsignedInt() >> 5;
      player.instruments = new Vector.<S2Instrument>(++len, true);
      stream.position = position;

      player.instruments[0] = new S2Instrument();

      for (i = 0; ++i < len;) {
        instr = new S2Instrument();
        instr.wave           = stream.readUnsignedByte() << 4;
        instr.waveLen        = stream.readUnsignedByte();
        instr.waveSpeed      = stream.readUnsignedByte();
        instr.waveDelay      = stream.readUnsignedByte();
        instr.arpeggio       = stream.readUnsignedByte() << 4;
        instr.arpeggioLen    = stream.readUnsignedByte();
        instr.arpeggioSpeed  = stream.readUnsignedByte();
        instr.arpeggioDelay  = stream.readUnsignedByte();
        instr.vibrato        = stream.readUnsignedByte();
        instr.vibratoLen     = stream.readUnsignedByte();
        instr.vibratoSpeed   = stream.readUnsignedByte();
        instr.vibratoDelay   = stream.readUnsignedByte();
        instr.pitchBend      = stream.readByte();
        instr.pitchBendDelay = stream.readUnsignedByte();
        stream.readByte();
        stream.readByte();
        instr.attackMax      = stream.readUnsignedByte();
        instr.attackSpeed    = stream.readUnsignedByte();
        instr.decayMin       = stream.readUnsignedByte();
        instr.decaySpeed     = stream.readUnsignedByte();
        instr.sustain        = stream.readUnsignedByte();
        instr.releaseMin     = stream.readUnsignedByte();
        instr.releaseSpeed   = stream.readUnsignedByte();
        player.instruments[i] = instr;
        stream.position += 9;
      }

      position = stream.position;
      stream.position = 30;
      len = stream.readUnsignedInt();
      player.waves = new Vector.<int>(len, true);
      stream.position = position;

      for (i = 0; i < len; ++i) player.waves[i] = stream.readUnsignedByte();

      position = stream.position;
      stream.position = 34;
      len = stream.readUnsignedInt();
      player.arpeggios = new Vector.<int>(len, true);
      stream.position = position;

      for (i = 0; i < len; ++i) player.arpeggios[i] = stream.readByte();

      position = stream.position;
      stream.position = 38;
      len = stream.readUnsignedInt();
      player.vibratos = new Vector.<int>(len, true);
      stream.position = position;

      for (i = 0; i < len; ++i) player.vibratos[i] = stream.readByte();

      len = player.samples.length;
      position = 0;

      for (i = 0; i < len; ++i) {
        sample = new S2Sample();
        stream.readUnsignedInt();
        sample.length    = stream.readUnsignedShort() << 1;
        sample.loop      = stream.readUnsignedShort() << 1;
        sample.repeat    = stream.readUnsignedShort() << 1;
        sample.negStart  = position + (stream.readUnsignedShort() << 1);
        sample.negLen    = stream.readUnsignedShort() << 1;
        sample.negSpeed  = stream.readUnsignedShort();
        sample.negDir    = stream.readUnsignedShort();
        sample.negOffset = stream.readShort();
        sample.negPos    = stream.readUnsignedInt();
        sample.negCtr    = stream.readUnsignedShort();
        stream.position += 6;
        sample.name      = stream.readMultiByte(32, AmigaPlayer.ENCODING);

        sample.pointer = position;
        sample.loopPtr = position + sample.loop;
        position += sample.length;
        player.samples[i] = sample;
      }

      sampleData = position;
      len = ++patterns;
      pointers = new Vector.<int>(++patterns, true);
      for (i = 0; i < len; ++i) pointers[i] = stream.readUnsignedShort();

      position = stream.position;
      stream.position = 50;
      len = stream.readUnsignedInt();
      player.patterns = new Vector.<S2Row>();
      stream.position = position;
      j = 1;

      for (i = 0; i < len; ++i) {
        row   = new S2Row();
        value = stream.readByte();

        if (value == 0) {
          row.data1 = stream.readByte();
          row.data2 = stream.readUnsignedByte();
          i += 2;
        } else if (value < 0) {
          row.timer = ~value;
        } else if (value < 112) {
          row.note = value;
          value = stream.readByte();
          i++;

          if (value < 0) {
            row.timer = ~value;
          } else if (value < 112) {
            row.sample = value;
            value = stream.readByte();
            i++;

            if (value < 0) {
              row.timer = ~value;
            } else {
              row.data1 = value;
              row.data2 = stream.readUnsignedByte();
              i++;
            }
          } else {
            row.data1 = value;
            row.data2 = stream.readUnsignedByte();
            i++;
          }
        } else {
          row.data1 = value;
          row.data2 = stream.readUnsignedByte();
          i++;
        }

        player.patterns[pos++] = row;
        if ((position + pointers[j]) == stream.position) pointers[j++] = pos;
      }
      pointers[j] = player.patterns.length;
      player.patterns.fixed = true;

      if ((stream.position & 1) != 0) stream.position++;
      amiga.store(stream, sampleData);
      len = player.tracks.length;

      for (i = 0; i < len; ++i) {
        step = player.tracks[i];
        step.pattern = pointers[step.pattern];
      }
      player.length++;
      player.version = 2;
    }
  }
}