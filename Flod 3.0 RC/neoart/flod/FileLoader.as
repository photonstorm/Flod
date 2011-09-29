package neoart.flod {
  import flash.utils.*;
  import neoart.flip.*;
  import neoart.flod.amiga.*;
  import neoart.flod.delta1.*;
  import neoart.flod.delta2.*;
  import neoart.flod.digitalmugician.*;
  import neoart.flod.futurecomposer.*;
  import neoart.flod.hismaster.*;
  import neoart.flod.noisetracker.*;
  import neoart.flod.protracker.*;
  import neoart.flod.sidmon1.*;
  import neoart.flod.sidmon2.*;
  import neoart.flod.soundfx.*;
  import neoart.flod.soundmon.*;
  import neoart.flod.soundtracker.*;
  import neoart.flod.whittaker1.*;
  import neoart.flod.whittaker2.*;

  public final class FileLoader {
    private var
      amiga   : Amiga,
      player  : AmigaPlayer,
      index   : int,
      version : int;

    private const
      SOUNDTRACKER : int = 0,
      NOISETRACKER : int = 4,
      PROTRACKER   : int = 9,
      HISMASTER    : int = 12,
      SOUNDFX      : int = 13,
      BPSOUNDMON   : int = 17,
      DELTAMUSIC   : int = 20,
      DIGITALMUG   : int = 22,
      FUTURECOMP   : int = 24,
      SIDMON       : int = 26,
      WHITTAKER    : int = 28,

      TRACKERS : Vector.<String> = Vector.<String>([
        "Unknown Format",
        "Ultimate SoundTracker",
        "D.O.C. SoundTracker 9",
        "Master SoundTracker",
        "D.O.C. SoundTracker 2.0/2.2",
        "SoundTracker 2.3",
        "SoundTracker 2.4",
        "NoiseTracker 1.0",
        "NoiseTracker 1.1",
        "NoiseTracker 2.0",
        "ProTracker 1.0",
        "ProTracker 1.1/2.1",
        "ProTracker 1.2/2.0",
        "His Master's NoiseTracker",
        "SoundFX 1.0/1.7",
        "SoundFX 1.8",
        "SoundFX 1.945",
        "SoundFX 1.994/2.0",
        "BP SoundMon V1",
        "BP SoundMon V2",
        "BP SoundMon V3",
        "Delta Music 1.0",
        "Delta Music 2.0",
        "Digital Mugician",
        "Digital Mugician 7 Voices",
        "Future Composer 1.0/1.3",
        "Future Composer 1.4",
        "SidMon 1.0",
        "SidMon 2.0",
        "David Whittaker V1",
        "David Whittaker V2"]);

    public function FileLoader() {
      amiga = new Amiga();
    }

    public function get tracker():String { return TRACKERS[int(index + version)]; }

    public function load(stream:ByteArray):AmigaPlayer {
      var archive:ZipFile, id:String, sig:int;
      stream.endian = "bigEndian";
      sig = stream.readUnsignedInt();

      if (sig == 0x504b0304) {
        archive = new ZipFile(stream);
        stream = archive.uncompress(archive.entries[0]);
      }

      if (player) {
        player.load(stream);
        if (player.version) {
          version = player.version;
          return player;
        }
      }

      if (stream.length > 2149) {
        stream.position = 1080;
        id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
        if (id == "M.K." || id == "FLT4") {
          player = new MKPlayer(amiga);
          player.load(stream);
          if (player.version) {
            index   = NOISETRACKER;
            version = player.version;
            return player;
          }
        }
      }

      if (stream.length > 1685) {
        stream.position = 60;
        id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
        if (id != "SONG") {
          stream.position = 124;
          id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
        }
        if (id == "SONG" || id == "SO31") {
          player = new FXPlayer(amiga);
          player.load(stream);
          if (player.version) {
            index   = SOUNDFX;
            version = player.version;
            return player;
          }
        }
      }

      if (stream.length > 2149) {
        stream.position = 1080;
        id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
        if (id == "M.K." || id == "M!K!") {
          player = new PTPlayer(amiga);
          player.load(stream);
          if (player.version) {
            index   = PROTRACKER;
            version = player.version;
            return player;
          }
        } else if (id == "FEST") {
          player = new HMPlayer(amiga);
          player.load(stream);
          if (player.version) {
            index   = HISMASTER;
            version = player.version;
            return player;
          }
        }
      }

      if (stream.length > 4) {
        stream.position = 0;
        id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
        if (id == "ALL ") {
          player = new D1Player(amiga);
          player.load(stream);
          if (player.version) {
            index   = DELTAMUSIC;
            version = player.version;
            return player;
          }
        }
      }

      if (stream.length > 3018) {
        stream.position = 3014;
        id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
        if (id == ".FNL") {
          player = new D2Player(amiga);
          player.load(stream);
          if (player.version) {
            index   = DELTAMUSIC;
            version = player.version;
            return player;
          }
        }
      }

      if (stream.length > 30) {
        stream.position = 26;
        id = stream.readMultiByte(3, AmigaPlayer.ENCODING);
        if (id == "BPS" || id == "V.2" || id == "V.3") {
          player = new BPPlayer(amiga);
          player.load(stream);
          if (player.version) {
            index   = BPSOUNDMON;
            version = player.version;
            return player;
          }
        }
      }

      if (stream.length > 4) {
        stream.position = 0;
        id = stream.readMultiByte(4, AmigaPlayer.ENCODING);
        if (id == "SMOD" || id == "FC14") {
          player = new FCPlayer(amiga);
          player.load(stream);
          if (player.version) {
            index   = FUTURECOMP;
            version = player.version;
            return player;
          }
        }
      }

      if (stream.length > 10) {
        stream.position = 0;
        id = stream.readMultiByte(9, AmigaPlayer.ENCODING);
        if (id == "MUGICIAN") {
          player = new DMPlayer(amiga);
          player.load(stream);
          if (player.version) {
            index   = DIGITALMUG;
            version = player.version;
            return player;
          }
        }
      }

      if (stream.length > 86) {
        stream.position = 58;
        id = stream.readMultiByte(28, AmigaPlayer.ENCODING);
        if (id == "SIDMON II - THE MIDI VERSION") {
          player = new S2Player(amiga);
          player.load(stream);
          if (player.version) {
            index   = SIDMON;
            version = player.version;
            return player;
          }
        }
      }

      if (stream.length > 5220) {
        player = new S1Player(amiga);
        player.load(stream);
        if (player.version) {
          index   = SIDMON;
          version = player.version;
          return player;
        }
      }

      if (stream.length > 1625) {
        player = new STPlayer(amiga);
        player.load(stream);
        if (player.version) {
          index   = SOUNDTRACKER;
          version = player.version;
          return player;
        }
      }

      player = new W2Player(amiga);
      player.load(stream);
      if (player.version) {
        index   = WHITTAKER;
        version = player.version;
        return player;
      }

      stream.clear();
      index = version = 0;
      player = null;
      return player;
    }
  }
}