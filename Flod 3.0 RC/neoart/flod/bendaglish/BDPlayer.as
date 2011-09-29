package neoart.flod.bendaglish {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class BDPlayer extends AmigaPlayer {
    internal var
      voices       : Vector.<BDData>,
      periods      : ByteArray,
      patterns     : ByteArray,
      patPointers  : Vector.<int>;
      songs        : Vector.<BDSong>,
      samOffset    : Vector.<int>,
      samPointers  : Vector.<int>,
      samples      : Vector.<BDSample>,
      song         : BDSong,
      globalVolume : int,
      fadeSpeed    : int,
      fadeCounter  : int;

    public function BDPlayer(amiga:Amiga = null) {
      super(amiga);
      voices = new Vector.<BDData>(4, true);
      voices[0] = new BDData();
      voices[1] = new BDData();
      voices[2] = new BDData();
      voices[3] = new BDData();
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      BDLoader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, flag:int, i:int, track:ByteArray, value:int, voice:BDData;

      for (i = 0; i < 4; ++i) {
        chan  = amiga.channels[i];
        voice = voices[i];
        track = song.tracks[i];

        if (voice.d2_byte22 == 0) continue;
        subf76();
        subfca();
        flag = 0;

        if (voice.d2_byte20 != 0) {
          if (--voice.d2_byte18 != 0) {
            voice.d2_long10 = voice.d2_long6;
            voice.d2_byte20 = 0;
            //goto loccf6
          } else {
            voice.d2_byte18 = 1;
            track.position = voice.d2_long2;
            //locc76
            while (true) {
              value = track.readByte();
              if (value < 200) {
                //loccd8
                voice.d2_byte20 = 0;
                voice.d2_long2 = track.position;
                voice.d2_long6 = patPointers[value];
                patterns.position = voice.d2_long6;
                flag = 2;
                break;
                //goto loccfa
              } else if (value == 254) {
                voice.d2_byte19 = track.readByte();
              } else if (value == 255) {
                if (voice.d1_word6 <= 0) voice.d2_byte22 = 0; //if 0 or $8000 (-1 in my case)
                flag = 1;
                break; //next voice
              } else if (value == 253) {
                fadeSpeed = track.readByte();
              } else if (value >= 240) {
                value = (value - 240) + voice.d2_word0;
                samOffset[value] = track.readByte();
              } else { // > 199 && < 240
                voice.d2_byte18 = value - 200;
              }
            }
            if (flag == 1) continue;
          }
          //loccf6
          if (flag != 2) patterns.position = voice.d2_long10;
          //loccfa
          if (--voice.d2_byte21 == 0) {
            
          } else {
            value = patterns.readByte();
            patterns.position--;
            if (value > -1) {
              voice.d2_long10 = pattern.position;
              continue;
            }
          }
        }
      }
    }

    override protected function initialize():void {
      var i:int, voice:BDData;
      super.initialize();

      if (playSong > lastSong) playSong = 0;
      song  = songs[playSong];
      speed = song.speed;

      globalVolume = 64;
      fadeSpeed    = 0;
      fadeConter   = 0;

      for (i = 0; i < 4; ++i) { 
        voice = voices[i];
        voice.initialize();
        voice.d2_word0 = i << 3; //* 8;
      }
    }

    private function subf76():void {
    }

    private function subfca():void {
    }
  }
}