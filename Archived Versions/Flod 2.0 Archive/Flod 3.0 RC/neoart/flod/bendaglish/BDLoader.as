package neoart.flod.bendaglish {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class BDLoader {

    public static function load(stream:ByteArray, amiga:Amiga):void {
      var i:int, player:BDPlayer, sample:BDSample, song:BDSong, value:int;
      player = BDPlayer(amiga.player);
      value = stream.readUnsignedShort();
      if (value != 0x6000) return;

      stream.position = 0xd8;
      player.periods = new ByteArray();
      stream.readBytes(player.periods, 0, 288);

      stream.position = 0x552;
      player.patterns = new ByteArray();
      stream.readBytes(player.patterns, 0, 656);

      stream.position = 0x7e2;
      player.patPointers = new Vector.<int>(20, true);
      for (i = 0; i < 20; ++i) player.patPointers[i] = stream.readUnsignedShort();

      player.songs = new Vector.<BDSong>(1, true);
      song = new BDSong();
      for (i = 0; i < 4; ++i) song.tracks[i] = new ByteArray();
      stream.position = 0x812;
      stream.readBytes(song.tracks[0], 0, 36);
      stream.readBytes(song.tracks[1], 0, 52);
      stream.readBytes(song.tracks[2], 0, 68);
      stream.readBytes(song.tracks[3], 0, 34);
      player.songs[0] = song;

      player.samOffset = new Vector.<int>(28, true);
      for (i = 0; i < 7; ++i) player.samOffset[i] = i;
      for (i = 0; i < 7; ++i) player.samOffset[i + 7] = i;
      for (i = 0; i < 7; ++i) player.samOffset[i + 14] = i;
      for (i = 0; i < 7; ++i) player.samOffset[i + 21] = i;

      player.samPointers = new Vector.<int>(13, true);
      player.samPointers[0] = 0;
      player.samPointers[1] = 2;
      player.samPointers[2] = 3;
      player.samPointers[3] = 4;
      player.samPointers[4] = 5;
      player.samPointers[5] = 6;
      player.samPointers[6] = 1;
      player.samPointers[7] = 7;
      player.samPointers[8] = 8;
      player.samPointers[9] = 9;
      player.samPointers[10] = 10;
      player.samPointers[11] = 11;
      player.samPointers[11] = 12;

      stream.position = 0x104e;
      player.samples = new Vector.<BDSample>(13, true);
      for (i = 0; i < 13; ++i) {
        sample = new BDSample();
        sample.long0 = stream.readUnsignedInt();
        sample.long4 = stream.readUnsignedInt();
        sample.word8 = stream.readUnsignedShort();
        sample.word10 = stream.readUnsignedShort();
        sample.word12 = stream.readUnsignedShort();
        sample.word14 = stream.readUnsignedShort();
        sample.word16 = stream.readUnsignedShort();
        sample.word18 = stream.readUnsignedShort();
        sample.word20 = stream.readUnsignedShort();
        sample.word22 = stream.readUnsignedShort();
        sample.word24 = stream.readUnsignedShort();
        sample.word26 = stream.readUnsignedShort();
        player.samples[i] = sample;
      }

      stream.position = 0x11ba;
      amiga.store(stream, 45972);
      player.version = 1;
    }
  }
}