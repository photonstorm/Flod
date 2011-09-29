package neoart.flod.soundfx {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class FXPlayer extends AmigaPlayer {
    public static const
      SOUNDFX_10 : int = 1,
      SOUNDFX_18 : int = 2,
      SOUNDFX_19 : int = 3,
      SOUNDFX_20 : int = 4;

    internal var
      track      : Vector.<int>,
      patterns   : Vector.<AmigaRow>,
      samples    : Vector.<AmigaSample>,
      length     : int,
      tempo      : int;
    private var
      voices     : Vector.<FXData>,
      trackPos   : int,
      patternPos : int,
      jumpFlag   : int;

    private const
      ARPEGGIO : Vector.<int> = Vector.<int>([
        0,1,2,1,0]),
      PERIODS  : Vector.<int> = Vector.<int>([
        1076,1016,0960,0906,0856,0808,0762,0720,0678,0640,
        0604,0570,0538,0508,0480,0453,0428,0404,0381,0360,
        0339,0320,0302,0285,0269,0254,0240,0226,0214,0202,
        0190,0180,0170,0160,0151,0143,0135,0127,0120,0113,
        0113,0113,0113,0113,0113,0113,0113,0113,0113,0113,
        0113,0113,0113,0113,0113,0113,0113,0113,0113,0113,
        0113,0113,0113,0113,0113,0113,-1]);

    public function FXPlayer(amiga:Amiga = null) {
      super(amiga);
      ARPEGGIO.fixed = true;
      PERIODS.fixed  = true;

      track   = new Vector.<int>(128, true);
      samples = new Vector.<AmigaSample>();
      voices  = new Vector.<FXData>(4, true);

      voices[0] = new FXData();
      voices[1] = new FXData();
      voices[2] = new FXData();
      voices[3] = new FXData();
    }

    override public function set force(value:int):void {
      if (value < SOUNDFX_10) value = SOUNDFX_10;
        else if (value > SOUNDFX_20) value = SOUNDFX_20;
      version = value;
    }

    override public function set ntsc(value:int):void {
      super.ntsc = value;
      value = value ? 7.5152005551 : 7.58437970472;
      amiga.samplesTick = int((tempo / 122) * value);
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, index:int, period:int, row:AmigaRow, sample:AmigaSample, test:int, value:int, voice:FXData;

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

          if (row.note == -3) {
            voice.effect = 0;
            continue;
          }

          if (row.sample) {
            sample = voice.sample = samples[row.sample];
            voice.volume = sample.volume;
            if (voice.effect == 5)
              voice.volume += voice.param;
            else if (voice.effect == 6)
              voice.volume -= voice.param;
            chan.volume = voice.volume;
          } else
            sample = voice.sample;

          if (voice.period) {
            voice.last = voice.period;
            voice.slideSpeed = 0;
            voice.stepSpeed   = 0;

            voice.enabled = 1;
            chan.enabled  = 0;

            switch (voice.period) {
              case -2:
                chan.volume = 0;
                break;
              case -4:
                jumpFlag = 1;
                break;
              case -5:
                trace("Unknown command -5");
                break;
              default:
                chan.pointer = sample.pointer;
                chan.length  = sample.length;
                chan.period  = voice.period;
                break;
            }

            if (voice.enabled) chan.enabled = 1;
            chan.pointer = sample.loopPtr;
            chan.length  = sample.repeat;
          }

          patternPos += 4;

          if (patternPos == 256 || jumpFlag) {
            patternPos = jumpFlag = 0;

            if (++trackPos == length) {
              trackPos = 0;
              amiga.complete = 1;
            }
          }
        }
      } else {
        for (i = 0; i < 4; ++i) {
          voice = voices[i];
          chan  = voice.channel;
          if (version == 2 && voice.period == -3) continue;

          if (voice.stepSpeed) {
            voice.stepPeriod += voice.stepSpeed;

            if (voice.stepSpeed < 0) {
              if (voice.stepPeriod < voice.stepWanted) {
                voice.stepPeriod = voice.stepWanted;
                if (version > 2) voice.stepSpeed = 0;
              }
            } else {
              if (voice.stepPeriod > voice.stepWanted) {
                voice.stepPeriod = voice.stepWanted;
                if (version > 2) voice.stepSpeed = 0;
              }
            }
            if (version > 2) voice.last = voice.stepPeriod;
            chan.period = voice.stepPeriod;
          } else {
            if (voice.slideSpeed) {
              value = voice.slideParam & 0x0f;

              if (value) {
                if (++voice.slideCtr == value) {
                  voice.slideCtr = 0;
                  value = (voice.slideParam >> 4) << 3;

                  if (voice.slideDir == 0) {
                    voice.slidePeriod += 8;
                    chan.period = voice.slidePeriod;
                    value += voice.slideSpeed;
                    if (value == voice.slidePeriod) voice.slideDir = 1;
                  } else {
                    voice.slidePeriod -= 8;
                    chan.period = voice.slidePeriod;
                    value -= voice.slideSpeed;
                    if (value == voice.slidePeriod) voice.slideDir = 0;
                  }
                } else
                  continue;
              }
            }
            value = 0;

            switch (voice.effect) {
              case 1: //arpeggio
                value = ARPEGGIO[int(timer - 1)];
                index = 0;
                if (value == 2) {
                  chan.period = voice.last;
                  continue;
                }

                if (value == 1) value = voice.param & 0x0f;
                  else value = voice.param >> 4;

                while (voice.last != PERIODS[index]) index++;
                chan.period = PERIODS[int(index + value)];
                break;
              case 2: //pitchbend
                value = voice.param >> 4;
                if (value) voice.period += value;
                  else voice.period -= voice.param & 0x0f;
                chan.period = voice.period;
                break;
              case 3: //filter on
                amiga.filter.active = 1;
                break;
              case 4: //filter off
                amiga.filter.active = 0;
                break;
              case 8: //step down
                value = -1;
              case 7: //step up
                voice.stepSpeed = voice.param & 0x0f;
                test = version > 2 ? voice.last : voice.period;
                if (value < 0) voice.stepSpeed = -voice.stepSpeed;
                index = 0;

                while (true) {
                  period = PERIODS[index];
                  if (period == test) break;
                  if (period < 0) {
                    index = -1;
                    break;
                  } else
                    index++;
                }

                if (index > -1) {
                  period = voice.param >> 4;
                  if (value > -1) period = -period;
                  index += period;
                  if (index < 0) index = 0;
                  voice.stepWanted = PERIODS[index];
                } else
                  voice.stepWanted = voice.period;
                break;
              case 9: //auto slide
                voice.slideSpeed = voice.slidePeriod = voice.period;
                voice.slideParam  = voice.param;
                voice.slideDir = 0;
                voice.slideCtr = 0;
                break;
            }
          }
        }
      }
    }

    override protected function initialize():void {
      var i:int, voice:FXData;
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
  }
}