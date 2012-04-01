package neoart.flod.amiga {
  import flash.events.*;
  import flash.media.*;
  import flash.utils.*;

  public class AmigaPlayer extends EventDispatcher {
    public static const
      ENCODING  : String = "us-ascii";
    public var
      amiga     : Amiga,
      title     : String = "",
      version   : int,
      loopSong  : int,
      playSong  : int,
      lastSong  : int = 1;
    protected var
      sound     : Sound,
      soundChan : SoundChannel,
      soundPos  : int,
      mode      : int,
      speed     : int,
      timer     : int;

    public function AmigaPlayer(amiga:Amiga = null) {
      this.amiga = amiga || new Amiga();
      this.amiga.player = this;
      ntsc = loopSong = 0;
    }

    public function set force(value:int):void { version = 1; }

    public function set ntsc(value:int):void {
      if (value) {
        amiga.clock = 81.16882653;
        amiga.samplesTick = 735;
      } else {
        amiga.clock = 80.42844898;
        amiga.samplesTick = 882;
      }

      mode = value;
    }

    public function set stereo(value:Number):void {
      var chan:AmigaChannel, i:int;
      if (value < 0.0) value = 0.0; else if (value > 1.0) value = 1.0;

      for (i = 0; i < 4; ++i) {
        chan = amiga.channels[i];
        chan.level = value * chan.panning;
      }
    }

    public function set volume(value:Number):void {
      if (value < 0.0) value = 0.0; else if (value > 1.0) value = 1.0;
      amiga.master = value * 0.00390625;
    }

    public function load(stream:ByteArray):int {
      amiga.reset();
      version = 0;
      stream.endian = "bigEndian";
      stream.position = 0;
      return 0;
    }

    public function play(soundProcessor:Sound = null):int {
      if (version == 0) return 0;
      if (soundPos == 0.0) initialize();
      sound = soundProcessor || new Sound();
      sound.addEventListener(SampleDataEvent.SAMPLE_DATA, amiga.mixer);
      soundChan = sound.play(soundPos);
      soundChan.addEventListener(Event.SOUND_COMPLETE, completeHandler, false, 0, true);
      soundPos = 0.0;
      return 1;
    }

    public function pause():void {
      if (version == 0 || !soundChan) return;
      soundPos = soundChan.position;
      soundChan.stop();
      sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, amiga.mixer);
    }

    public function stop():void {
      if (version == 0) return;
      if (soundChan) {
        soundChan.stop();
        sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, amiga.mixer);
      }
      soundPos = 0.0;
      reset();
    }

    public function process():void { }

    protected function initialize():void {
      amiga.initialize();
      speed = timer = 0;
    }

    protected function reset():void { }

    private function completeHandler(e:Event):void {
      sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, amiga.mixer);
      dispatchEvent(e);
    }
  }
}