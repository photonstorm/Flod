package neoart.flod.digitalmugician {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  internal final class DMModule {
    internal var version:int;
    internal var loopPtr:int;
    internal var buffer1:int;
    internal var buffer2:int;

    internal var songs:Vector.<DMSong>;
    internal var patterns:Vector.<DMCommand>;
    internal var samples:Vector.<DMSample>;
    internal var arpeggios:Vector.<int>;

    internal function initialize(stream:ByteArray, amiga:Amiga):int {
      var com:DMCommand, i:int, id:String, index:Vector.<int>, instr:int, j:int, len:int, pointer:int, sample:DMSample, song:DMSong, step:DMStep;
      stream.endian = "bigEndian";
      stream.position = 0;
      amiga.reset();

      id = stream.readMultiByte(24, Amiga.ENCODING);

      if (id == " MUGICIAN/SOFTEYES 1990 ") version = 1;
        else if (id == " MUGICIAN2/SOFTEYES 1990") version = 2;
          else return 0;

      stream.position = 28;
      index = new Vector.<int>(8);
      for (i = 0; i < 8; ++i) index[i] = stream.readUnsignedInt();

      stream.position = 76;
      songs = new Vector.<DMSong>(8, true);

      for (i = 0; i < 8; ++i) {
        song = new DMSong();
        song.loop     = stream.readUnsignedByte();
        song.loopStep = stream.readUnsignedByte() << 2;
        song.speed    = stream.readUnsignedByte();
        song.length   = stream.readUnsignedByte() << 2;
        song.title    = stream.readMultiByte(12, Amiga.ENCODING);
        songs[i] = song;
      }

      stream.position = 204;

      for (i = 0; i < 8; ++i) {
        song = songs[i];
        len  = index[i] << 2;

        for (j = 0; j < len; ++j) {
          step = new DMStep();
          step.pattern   = stream.readUnsignedByte() << 6;
          step.transpose = stream.readByte();
          song.tracks[j] = step;
        }
        song.tracks.fixed = true;
      }

      pointer = stream.position;
      stream.position = 60;
      len = stream.readUnsignedInt();
      samples = new Vector.<DMSample>(++len, true);
      stream.position = pointer;

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
        samples[i] = sample;
      }

      pointer = stream.position;
      stream.position = 64;
      len = stream.readUnsignedInt() << 7;
      stream.position = pointer;
      amiga.store(stream, len);

      pointer = stream.position;
      stream.position = 68;
      instr = stream.readUnsignedInt();

      if (instr) {
        len = samples.length;
        index.length = instr + 1;

        for (i = 0; i < instr; ++i) {
          stream.position = pointer + (i * 32);
          index[i] = stream.readUnsignedInt();
		  if (i == (instr - 1)) {
		    index[instr] = stream.readUnsignedInt();
		  }
        }

        for (i = 1; i < len; ++i) {
          sample = samples[i];
          if (sample.wave < 32) continue;
          j = sample.wave - 32;
          stream.position = pointer + (j << 5);

          sample.pointer    = stream.readUnsignedInt();
          sample.length     = stream.readUnsignedInt() - sample.pointer;
          //if ((sample.length & 1) != 0) sample.length--;
          sample.loopStart  = stream.readUnsignedInt();
          sample.name       = stream.readMultiByte(12, Amiga.ENCODING);
          sample.realLength = index[j + 1] - sample.pointer;

          if (sample.loopStart) {
            sample.loopStart -= sample.pointer;
            sample.repeatLen = sample.length - sample.loopStart;
          }
        }
        pointer += instr << 5;
      }

      stream.position = 26;
      len = stream.readUnsignedShort() << 6;
      patterns = new Vector.<DMCommand>(len, true);
      stream.position = pointer;

      for (i = 0; i < len; ++i) {
        com = new DMCommand();
        com.note   = stream.readUnsignedByte();
        com.sample = stream.readUnsignedByte() & 63;
        com.val1   = stream.readUnsignedByte();
        com.val2   = stream.readUnsignedByte();
        patterns[i] = com;
      }

      pointer = stream.position;

      if (instr) {
        index.length = 33;
        for (i = 0; i < 33; ++i) index[i] = 0;
        len = samples.length;

        for (i = 1; i < len; ++i) {
          sample = samples[i];
          if (sample.wave < 32) continue;
          j = sample.wave - 31;
          stream.position = pointer + sample.pointer;

          if (index[j] == 0) index[j] = amiga.store(stream, sample.realLength);
          sample.pointer = index[j];
          sample.loopPtr = sample.pointer + sample.loopStart;
        }
      }

      stream.position = 24;
      arpeggios = new Vector.<int>(256, true);

      if (stream.readUnsignedShort() == 1) {
        stream.position = 72;
        stream.position = pointer + stream.readUnsignedInt();
        len = stream.length - stream.position;
        if (len > 256) len = 256;
        for (i = 0; i < len; ++i) arpeggios[i] = stream.readUnsignedByte();
      }

      buffer1 = amiga.samples.length;
      amiga.samples.length += 350;
      buffer2 = amiga.samples.length;
      amiga.samples.length += 350;
      loopPtr = amiga.samples.length;

      if (instr) {
        len = samples.length;

        for (i = 1; i < len; ++i) {
          sample = samples[i];
          if (sample.wave < 32 || sample.loopStart) continue;

          sample.loopPtr   = loopPtr;
          sample.repeatLen = 8;
        }
        amiga.samples.length += 8;
      }

      sample = new DMSample();
      sample.pointer = sample.loopPtr   = loopPtr;
      sample.length  = sample.repeatLen = 8;
      samples[0] = sample;

      stream.clear();
      return version;
    }
  }
}