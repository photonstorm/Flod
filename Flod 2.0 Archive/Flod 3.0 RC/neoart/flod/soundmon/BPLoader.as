package neoart.flod.soundmon {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class BPLoader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var i:int, id:String, len:int, patterns:int, player:BPPlayer, row:AmigaRow, sample:BPSample, step:BPStep, tables:int;
      player = BPPlayer(amiga.player);
      player.title = stream.readMultiByte(26, AmigaPlayer.ENCODING);

      id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
      if (id == "BPSM") {
        player.version = BPPlayer.BPSOUNDMON_V1;
      } else {
        id = id.substr(0, 3);
        if (id == "V.2") player.version = BPPlayer.BPSOUNDMON_V2;
          else if (id == "V.3") player.version = BPPlayer.BPSOUNDMON_V3;
            else return;

        stream.position = 29;
        tables = stream.readUnsignedByte();
      }

      player.length = stream.readUnsignedShort();

      for (i = 0; i < 16; ++i) {
        sample = new BPSample();
        if (stream.readUnsignedByte() == 0xff) {
          sample.synth   = 1;
          sample.table   = stream.readUnsignedByte();
          sample.pointer = sample.table << 6;
          sample.length  = stream.readUnsignedShort() << 1;

          sample.adsrControl = stream.readUnsignedByte();
          sample.adsrTable   = stream.readUnsignedByte() << 6;
          sample.adsrLen     = stream.readUnsignedShort();
          sample.lfoControl  = stream.readUnsignedByte();
          sample.lfoTable    = stream.readUnsignedByte() << 6;
          sample.lfoDepth    = stream.readUnsignedByte();
          sample.lfoLen      = stream.readUnsignedShort();

          if (player.version < BPPlayer.BPSOUNDMON_V3) {
            stream.readByte();
            sample.lfoDelay  = stream.readUnsignedByte();
            sample.lfoSpeed  = stream.readUnsignedByte();
            sample.egControl = stream.readUnsignedByte();
            sample.egTable   = stream.readUnsignedByte() << 6;
            stream.readByte();
            sample.egLen     = stream.readUnsignedShort();
            stream.readByte();
            sample.egDelay   = stream.readUnsignedByte();
            sample.egSpeed   = stream.readUnsignedByte();
            sample.fxSpeed   = 1;
            sample.modSpeed  = 1;
            sample.volume    = stream.readUnsignedByte();
            stream.position += 6;
          } else {
            sample.lfoDelay   = stream.readUnsignedByte();
            sample.lfoSpeed   = stream.readUnsignedByte();
            sample.egControl  = stream.readUnsignedByte();
            sample.egTable    = stream.readUnsignedByte() << 6;
            sample.egLen      = stream.readUnsignedShort();
            sample.egDelay    = stream.readUnsignedByte();
            sample.egSpeed    = stream.readUnsignedByte();
            sample.fxControl  = stream.readUnsignedByte();
            sample.fxSpeed    = stream.readUnsignedByte();
            sample.fxDelay    = stream.readUnsignedByte();
            sample.modControl = stream.readUnsignedByte();
            sample.modTable   = stream.readUnsignedByte() << 6;
            sample.modSpeed   = stream.readUnsignedByte();
            sample.modDelay   = stream.readUnsignedByte();
            sample.volume     = stream.readUnsignedByte();
            sample.modLen     = stream.readUnsignedShort();
          }
        } else {
          stream.position--;
          sample.synth  = 0;
          sample.name   = stream.readMultiByte(24, AmigaPlayer.ENCODING);
          sample.length = stream.readUnsignedShort() << 1;

          if (sample.length) {
            sample.loop   = stream.readUnsignedShort();
            sample.repeat = stream.readUnsignedShort() << 1;
            sample.volume = stream.readUnsignedShort();

            if ((sample.loop + sample.repeat) >= sample.length)
              sample.repeat = sample.length - sample.loop;
          } else {
            sample.pointer--;
            sample.repeat = 2;
            stream.position += 6;
          }
        }
        player.samples[i] = sample;
      }

      len = player.length << 2;
      player.tracks = new Vector.<BPStep>(len, true);

      for (i = 0; i < len; ++i) {
        step = new BPStep();
        step.pattern = stream.readUnsignedShort();
        step.soundTranspose = stream.readByte();
        step.transpose = stream.readByte();
        if (step.pattern > patterns) patterns = step.pattern;
        player.tracks[i] = step;
      }

      len = patterns << 4;
      player.patterns = new Vector.<AmigaRow>(len, true);

      for (i = 0; i < len; ++i) {
        row = new AmigaRow();
        row.note   = stream.readByte();
        row.sample = stream.readUnsignedByte();
        row.data1  = row.sample & 0x0f;
        row.sample = (row.sample & 0xf0) >> 4;
        row.data2  = stream.readByte();
        player.patterns[i] = row;
      }

      amiga.store(stream, tables << 6);

      for (i = 0; ++i < 16;) {
        sample = player.samples[i];
        if (sample.synth || sample.length == 0) continue;
        sample.pointer = amiga.store(stream, sample.length);
        sample.loopPtr = sample.pointer + sample.loop;
      }
    }
  }
}