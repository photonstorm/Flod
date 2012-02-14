package neoart.flod.sidmon1 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class S1Loader {
    private static const
      SIDMON_0FFA : int = 0x0ffa,
      SIDMON_1170 : int = 0x1170,
      SIDMON_11C6 : int = 0x11c6,
      SIDMON_11DC : int = 0x11dc,
      SIDMON_11E0 : int = 0x11e0,
      SIDMON_125A : int = 0x125a,
      SIDMON_1444 : int = 0x1444,
      EMBEDDED    : Vector.<int> = Vector.<int>([1166, 408, 908]);

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var data:int, i:int, id:String, j:int, headers:int, len:int, player:S1Player, position:int, row:S1Row, sample:S1Sample, start:int, step:S1Step, totInstruments:int, totPatterns:int, totSamples:int, totWaveforms:int, version:int;
      player = S1Player(amiga.player);

      while (stream.bytesAvailable > 8) {
        start = stream.readUnsignedShort();
        if (start != 0x41fa) continue;
        j = stream.readUnsignedShort();

        start = stream.readUnsignedShort();
        if (start != 0xd1e8) continue;
        start = stream.readUnsignedShort();

        if (start == 0xffd4) {
          if (j == 0x0fec) version = SIDMON_0FFA;
            else if (j == 0x1466) version = SIDMON_1444;
              else version = j;

          position = j + stream.position - 6;
          break;
        }
      }

      if (position == 0) return;
      stream.position = position;
      id = stream.readMultiByte(32, AmigaPlayer.ENCODING);
      if (id != " SID-MON BY R.v.VLIET  (c) 1988 ") return;

      stream.position = position - 44;
      start = stream.readUnsignedInt();

      for (i = 1; i < 4; ++i)
        player.tracksPtr[i] = (stream.readUnsignedInt() - start) / 6;

      stream.position = position - 8;
      start = stream.readUnsignedInt();
      len   = stream.readUnsignedInt();
      if (len < start) len = stream.length - position;

      totPatterns = (len - start) >> 2;
      player.patternsPtr = new Vector.<int>(totPatterns);
      stream.position = position + start + 4;

      for (i = 1; i < totPatterns; ++i) {
        start = stream.readUnsignedInt() / 5;
        if (start == 0) {
          totPatterns = i;
          break;
        }
        player.patternsPtr[i] = start;
      }

      player.patternsPtr.length = totPatterns;
      player.patternsPtr.fixed  = true;

      stream.position = position - 44;
      start = stream.readUnsignedInt();
      stream.position = position - 28;
      len = (stream.readUnsignedInt() - start) / 6;

      player.tracks = new Vector.<S1Step>(len, true);
      stream.position = position + start;

      for (i = 0; i < len; ++i) {
        step = new S1Step();
        step.pattern = stream.readUnsignedInt();
        if (step.pattern >= totPatterns) step.pattern = 0;
        stream.readByte();
        step.transpose = stream.readByte();
        if (step.transpose < -99 || step.transpose > 99) step.transpose = 0;
        player.tracks[i] = step;
      }

      stream.position = position - 24;
      start = stream.readUnsignedInt();
      totWaveforms = stream.readUnsignedInt() - start;

      amiga.memory.length = 32;
      amiga.store(stream, totWaveforms, position + start);
      totWaveforms >>= 5;

      stream.position = position - 16;
      start = stream.readUnsignedInt();
      len   = (stream.readUnsignedInt() - start) + 16;
      j = (totWaveforms + 2) << 4;

      player.waveLists = new Vector.<int>(len < j ? j : len, true);
      stream.position = position + start;
      i = 0;

      while (i < j) {
        player.waveLists[i++] = i >> 4;
        player.waveLists[i++] = 0xff;
        player.waveLists[i++] = 0xff;
        player.waveLists[i++] = 0x10;
        i += 12;
      }

      for (i = 16; i < len; ++i)
        player.waveLists[i] = stream.readUnsignedByte();

      stream.position = position - 20;
      stream.position = position + stream.readUnsignedInt();

      player.mix1Source1 = stream.readUnsignedInt();
      player.mix2Source1 = stream.readUnsignedInt();
      player.mix1Source2 = stream.readUnsignedInt();
      player.mix2Source2 = stream.readUnsignedInt();
      player.mix1Dest    = stream.readUnsignedInt();
      player.mix2Dest    = stream.readUnsignedInt();
      player.patternDef  = stream.readUnsignedInt();
      player.trackLen    = stream.readUnsignedInt();
      player.speedDef    = stream.readUnsignedInt();
      player.mix1Speed   = stream.readUnsignedInt();
      player.mix2Speed   = stream.readUnsignedInt();

      if (player.mix1Source1 > totWaveforms) player.mix1Source1 = 0;
      if (player.mix2Source1 > totWaveforms) player.mix2Source1 = 0;
      if (player.mix1Source2 > totWaveforms) player.mix1Source2 = 0;
      if (player.mix2Source2 > totWaveforms) player.mix2Source2 = 0;
      if (player.mix1Dest > totWaveforms) player.mix1Speed = 0;
      if (player.mix2Dest > totWaveforms) player.mix2Speed = 0;
      if (player.speedDef == 0) player.speedDef = 4;

      stream.position = position - 28;
      j = stream.readUnsignedInt();
      totInstruments = (stream.readUnsignedInt() - j) >> 5;
      if (totInstruments > 63) totInstruments = 63;
      len = totInstruments + 1;

      stream.position = position - 4;
      start = stream.readUnsignedInt();

      if (start == 1) {
        stream.position = 0x71c;
        start = stream.readUnsignedShort();

        if (start != 0x4dfa) {
          stream.position = 0x6fc;
          start = stream.readUnsignedShort();
          if (start != 0x4dfa) {
            player.version = 0;
            return;
          }
        }
        stream.position += stream.readUnsignedShort();
        player.samples = new Vector.<S1Sample>(len + 3, true);

        for (i = 0; i < 3; ++i) {
          sample = new S1Sample();
          sample.waveform = 16 + i;
          sample.length   = EMBEDDED[i];
          sample.pointer  = amiga.store(stream, sample.length);
          sample.loop     = sample.loopPtr = 0;
          sample.repeat   = 4;
          sample.volume   = 64;
          player.samples[int(len + i)] = sample;
          stream.position += sample.length;
        }
      } else {
        player.samples = new Vector.<S1Sample>(len, true);
        stream.position = position + start;
        data = stream.readUnsignedInt();
        totSamples = (data >> 5) + 15;
        headers = stream.position;
        data += headers;
      }

      sample = new S1Sample();
      sample.name = "flod";
      player.samples[0] = sample;
      stream.position = position + j;

      for (i = 1; i < len; ++i) {
        sample = new S1Sample();
        sample.waveform = stream.readUnsignedInt();
        for (j = 0; j < 16; ++j) sample.arpeggio[j] = stream.readUnsignedByte();

        sample.attackSpeed  = stream.readUnsignedByte();
        sample.attackMax    = stream.readUnsignedByte();
        sample.decaySpeed   = stream.readUnsignedByte();
        sample.decayMin     = stream.readUnsignedByte();
        sample.sustain      = stream.readUnsignedByte();
        stream.readByte();
        sample.releaseSpeed = stream.readUnsignedByte();
        sample.releaseMin   = stream.readUnsignedByte();
        sample.phaseShift   = stream.readUnsignedByte();
        sample.phaseSpeed   = stream.readUnsignedByte();
        sample.finetune     = stream.readUnsignedByte();
        sample.pitchFall    = stream.readByte();

        if (version == SIDMON_1444) {
          sample.pitchFall = sample.finetune;
          sample.finetune = 0;
        } else {
          if (sample.finetune > 15) sample.finetune = 0;
          sample.finetune *= 67;
        }

        if (sample.phaseShift > totWaveforms) {
          sample.phaseShift = 0;
          sample.phaseSpeed = 0;
        }

        if (sample.waveform > 15) {
          if ((totSamples > 15) && (sample.waveform > totSamples)) {
            sample.waveform = 0;
          } else {
            start = headers + ((sample.waveform - 16) << 5);
            if (start >= stream.length) continue;
            j = stream.position;

            stream.position = start;
            sample.pointer  = stream.readUnsignedInt();
            sample.loop     = stream.readUnsignedInt();
            sample.length   = stream.readUnsignedInt();
            sample.name     = stream.readMultiByte(20, AmigaPlayer.ENCODING);

            if (sample.loop == 0      ||
                sample.loop == 99999  ||
                sample.loop == 199999 ||
                sample.loop >= sample.length) {

              sample.loop   = 0;
              sample.repeat = version == SIDMON_0FFA ? 2 : 4;
            } else {
              sample.repeat = sample.length - sample.loop;
              sample.loop  -= sample.pointer;
            }

            sample.length -= sample.pointer;
            if (sample.length < (sample.loop + sample.repeat))
              sample.length = sample.loop + sample.repeat;

            sample.pointer = amiga.store(stream, sample.length, data + sample.pointer);
            if (sample.repeat < 6 || sample.loop == 0) sample.loopPtr = 0;
              else sample.loopPtr = sample.pointer + sample.loop;

            stream.position = j;
          }
        } else if (sample.waveform > totWaveforms)
          sample.waveform = 0;

        player.samples[i] = sample;
      }

      stream.position = position - 12;
      start = stream.readUnsignedInt();
      len = (stream.readUnsignedInt() - start) / 5;
      player.patterns = new Vector.<S1Row>(len, true);
      stream.position = position + start;

      for (i = 0; i < len; ++i) {
        row = new S1Row();
        row.note   = stream.readUnsignedByte();
        row.sample = stream.readUnsignedByte();
        row.data1  = stream.readUnsignedByte();
        row.data2  = stream.readUnsignedByte();
        row.timer  = stream.readUnsignedByte();

        if (version == SIDMON_1444) {
          if (row.note > 0 && row.note < 255) row.note += 469;
          if (row.data1 > 0 && row.data1 < 255) row.data1 += 469;
          if (row.sample > 59) row.sample = totInstruments + (row.sample - 60);
        } else if (row.sample > totInstruments)
          row.sample = 0;

        player.patterns[i] = row;
      }

      if (version == SIDMON_1170 || version == SIDMON_11C6 || version == SIDMON_1444) {
        if (version == SIDMON_1170) player.mix1Speed = player.mix2Speed = 0;
        player.doReset = player.doFilter = 0;
      } else
        player.doReset = player.doFilter = 1;

      player.version = 1;
    }
  }
}