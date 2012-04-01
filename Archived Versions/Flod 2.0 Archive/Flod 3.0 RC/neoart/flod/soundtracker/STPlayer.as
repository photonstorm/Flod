package neoart.flod.soundtracker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class STPlayer extends AmigaPlayer {
    public static const
      ULTIMATE_SOUNDTRACKER : int = 1,
      DOC_SOUNDTRACKER_9    : int = 2,
      MASTER_SOUNDTRACKER   : int = 3,
      DOC_SOUNDTRACKER_20   : int = 4;

    internal var
      track      : Vector.<int>,
      patterns   : Vector.<AmigaRow>,
      samples    : Vector.<AmigaSample>,
      length     : int,
      tempo      : int;
    private var
      voices     : Vector.<STData>,
      trackPos   : int,
      patternPos : int,
      jumpFlag   : int;

    private const
      ARPEGGIO : Vector.<int> = Vector.<int>([
        0,1,2,0,1,2]),
      PERIODS  : Vector.<int> = Vector.<int>([
        856,808,762,720,678,640,604,570,538,508,480,453,
        428,404,381,360,339,320,302,285,269,254,240,226,
        214,202,190,180,170,160,151,143,135,127,120,113,
        000]);

    public function STPlayer(amiga:Amiga = null) {
      super(amiga);
      ARPEGGIO.fixed = true;
      PERIODS.fixed  = true;

      track   = new Vector.<int>(128, true);
      samples = new Vector.<AmigaSample>(16, true);
      voices  = new Vector.<STData>(4, true);

      voices[0] = new STData();
      voices[1] = new STData();
      voices[2] = new STData();
      voices[3] = new STData();
    }

    override public function set force(value:int):void {
      if (value < ULTIMATE_SOUNDTRACKER) value = ULTIMATE_SOUNDTRACKER;
        else if (value > DOC_SOUNDTRACKER_20) value = DOC_SOUNDTRACKER_20;
      version = value;
    }

    override public function set ntsc(value:int):void {
      super.ntsc = value;

      if (version < MASTER_SOUNDTRACKER) {
        var temp:Number = value ? 7.5152005551 : 7.58437970472;
        amiga.samplesTick = int((240 - tempo) * temp);
      }
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      STLoader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, row:AmigaRow, sample:AmigaSample, value:int, voice:STData;

      if (++timer == speed) {
        timer = 0;
        value = track[trackPos] + patternPos;

        for (i = 0; i < 4; ++i) {
          voice = voices[i];
          chan  = voice.channel;
          voice.enabled = 0;

          row = patterns[int(value + i)];
          voice.period = row.note;
          voice.effect = row.data1;
          voice.param  = row.data2;

          if (row.sample) {
            sample = voice.sample = samples[row.sample];
            if ((version & 2) == 2) {
              if (voice.effect == 12) chan.volume = voice.param;
                else chan.volume = sample.volume;
            } else
              chan.volume = sample.volume;
          } else
            sample = voice.sample;

          if (voice.period) {
            voice.enabled = 1;

            chan.enabled = 0;
            chan.pointer = sample.pointer;
            chan.length  = sample.length;
            chan.period  = voice.last = voice.period;
          }

          if (voice.enabled) chan.enabled = 1;
          chan.pointer = sample.loopPtr;
          chan.length  = sample.repeat;

          if (version < 4) continue;

          switch (voice.effect) {
            case 11: //position jump
              trackPos = voice.param - 1;
              jumpFlag ^= 1;
              break;
            case 12: //set volume
              chan.volume = voice.param;
              break;
            case 13: //pattern break
              jumpFlag ^= 1;
              break;
            case 14: //set filter
              amiga.filter.active = voice.param ^ 1;
              break;
            case 15: //set speed
              if (voice.param == 0) break;
              speed = voice.param & 0x0f;
              timer = 0;
              break;
          }
        }

        patternPos += 4;

        if (patternPos == 256 || jumpFlag) {
          patternPos = jumpFlag = 0;

          if (++trackPos == length) {
            trackPos = 0;
            amiga.complete = 1;
          }
        }
      } else {
        for (i = 0; i < 4; ++i) {
          voice = voices[i];
          if (voice.param == 0) continue;
          chan = voice.channel;

          if (version == 1) {
            switch (voice.effect) {
              case 1:  //arpeggio
                arpeggio(chan);
                break;
              case 2:  //pitchbend
                value = voice.param >> 4;

                if (value) {
                  voice.period += value;
                  chan.period = voice.period;
                } else {
                  voice.period -= voice.param & 0x0f;
                  chan.period = voice.period;
                }
                break;
            }
            continue;
          }

          switch (voice.effect) {
            case 0:  //arpeggio
              arpeggio(chan);
              break;
            case 1:  //portamento up
              voice.period -= voice.param & 0x0f;
              if (voice.period < 113) voice.period = 113;
              chan.period = voice.period;
              break;
            case 2:  //portamento down
              voice.period += voice.param & 0x0f;
              if (voice.period > 856) voice.period = 856;
              chan.period = voice.period;
              break;
          }

          if ((version & 2) != 2) continue;

          switch (voice.effect) {
            case 12: //set volume
              chan.volume = voice.param;
              break;
            case 14: //set filter
              amiga.filter.active = 0;
              break;
            case 15: //set speed
              speed = voice.param & 0x0f;
              break;
          }
        }
      }
    }

    override protected function initialize():void {
      var i:int, voice:STData;
      super.initialize();
      speed      = 6;
      trackPos   = 0;
      patternPos = 0;
      jumpFlag   = 0;

      ntsc = mode;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.channel = amiga.channels[i];
        voice.sample  = samples[0];
      }
    }

    private function arpeggio(chan:AmigaChannel):void {
      var index:int, param:int = ARPEGGIO[timer], voice:STData = voices[chan.index];

      if (param == 0) {
        chan.period = voice.last;
        return;
      }

      if (param == 1) param = voice.param >> 4;
        else param = voice.param & 0x0f;

      while (voice.last != PERIODS[index]) index++;
      chan.period = PERIODS[int(index + param)];
    }
  }
}