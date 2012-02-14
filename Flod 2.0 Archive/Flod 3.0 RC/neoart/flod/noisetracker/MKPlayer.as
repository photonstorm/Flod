package neoart.flod.noisetracker {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class MKPlayer extends AmigaPlayer {
    public static const
      SOUNDTRACKER_23 : int = 1,
      SOUNDTRACKER_24 : int = 2,
      NOISETRACKER_10 : int = 3,
      NOISETRACKER_11 : int = 4,
      NOISETRACKER_20 : int = 5;

    internal var
      track        : Vector.<int>,
      patterns     : Vector.<AmigaRow>,
      samples      : Vector.<AmigaSample>,
      length       : int,
      restart      : int;
    private var
      voices       : Vector.<MKData>,
      trackPos     : int,
      patternPos   : int,
      jumpFlag     : int,
      vibratoDepth : int,
      restartSave  : int;

    private const
      ARPEGGIO : Vector.<int> = Vector.<int>([
        0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1]),
      PERIODS  : Vector.<int> = Vector.<int>([
        856,808,762,720,678,640,604,570,538,508,480,453,428,
        404,381,360,339,320,302,285,269,254,240,226,214,202,
        190,180,170,160,151,143,135,127,120,113,000]),
      VIBRATO  : Vector.<int> = Vector.<int>([
        000,024,049,074,097,120,141,161,180,197,212,224,235,
        244,250,253,255,253,250,244,235,224,212,197,180,161,
        141,120,097,074,049,024]);

    public function MKPlayer(amiga:Amiga = null) {
      super(amiga);
      ARPEGGIO.fixed = true;
      PERIODS.fixed  = true;
      VIBRATO.fixed  = true;

      track   = new Vector.<int>(128, true);
      samples = new Vector.<AmigaSample>(32, true);
      voices  = new Vector.<MKData>(4, true);

      voices[0] = new MKData();
      voices[1] = new MKData();
      voices[2] = new MKData();
      voices[3] = new MKData();
    }

    override public function set force(value:int):void {
      if (value < SOUNDTRACKER_23) value = SOUNDTRACKER_23;
        else if (value > NOISETRACKER_20) value = NOISETRACKER_20;
      version = value;

      if (value == NOISETRACKER_20) vibratoDepth = 6;
        else vibratoDepth = 7;

      if (value == NOISETRACKER_10) {
        restartSave = restart;
        restart = 0;
      } else {
        restart = restartSave;
        restartSave = 0;
      }
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      MKLoader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, j:int, len:int, pattern:int, period:int, row:AmigaRow, sample:AmigaSample, slide:int, value:int, voice:MKData;
      if (++timer == speed) {
        timer = 0;
        pattern = track[trackPos] + patternPos;

        for (i = 0; i < 4; ++i) {
          voice = voices[i];
          chan  = voice.channel;
          voice.enabled = 0;

          row = patterns[int(pattern + i)];
          voice.effect = row.data1;
          voice.param  = row.data2;

          if (row.sample) {
            sample = voice.sample = samples[row.sample];
            chan.volume = voice.volume = sample.volume;
          } else
            sample = voice.sample;

          if (row.note) {
            if (voice.effect == 3 || voice.effect == 5) {
              if (row.note < voice.period) {
                voice.portaDir = 1;
                voice.portaPeriod = row.note;
              } else if (row.note > voice.period) {
                voice.portaDir = 0;
                voice.portaPeriod = row.note;
              } else {
                voice.portaPeriod = 0;
              }
            } else {
              voice.vibratoPos = 0;
              voice.enabled    = 1;

              chan.enabled = 0;
              chan.pointer = sample.pointer;
              chan.length  = sample.length;
              chan.period  = voice.period = row.note;
            }
          }

          switch (voice.effect) {
            case 11: //position jump
              trackPos = voice.param - 1;
              jumpFlag = 1;
              break;
            case 12: //set volume
              chan.volume = voice.param;
              if (version == 5) voice.volume = voice.param;
              break;
            case 13: //pattern break
              jumpFlag = 1;
              break;
            case 14: //set filter
              amiga.filter.active = voice.param ^ 1;
              break;
            case 15: //set speed
              value = voice.param;
              if (value < 1) value = 1;
                else if (value > 31) value = 31;
              speed = value;
              timer = 0;
              break;
          }

          if (voice.enabled) chan.enabled = 1;
          chan.pointer = sample.loopPtr;
          chan.length  = sample.repeat;
        }

        patternPos += 4;
        if (patternPos == 256) next();
      } else {
        for (i = 0; i < 4; ++i) {
          voice = voices[i];
          chan  = voice.channel;
          slide = 0;

          if (voice.effect == 0 && voice.param == 0) {
            chan.period = voice.period;
            continue;
          }

          switch (voice.effect) {
            case 0:  //arpeggio
              value = ARPEGGIO[timer];
              if (value == 0) {
                chan.period = voice.period;
                continue;
              }

              if (value == 1) value = voice.param >> 4;
                else value = voice.param & 0x0f;

              period = voice.period & 0x0fff;
              len = 37 - value;

              for (j = 0; j < len; ++j) {
                if (period >= PERIODS[j]) {
                  chan.period = PERIODS[int(j + value)];
                  break;
                }
              }
              continue;
            case 1:  //portamento up
              voice.period -= voice.param;
              if (voice.period < 113) voice.period = 113;
              chan.period = voice.period;
              continue;
            case 2:  //portamento down
              voice.period += voice.param;
              if (voice.period > 856) voice.period = 856;
              chan.period = voice.period;
              continue;
            case 3:  //tone portamento
            case 5:  //tone portamento + volume slide
              if (voice.effect == 5) slide = 1;
              else if (voice.param) {
                voice.portaSpeed = voice.param;
                voice.param = 0;
              }

              if (voice.portaPeriod) {
                if (voice.portaDir) {
                  voice.period -= voice.portaSpeed;
                  if (voice.period < voice.portaPeriod) {
                    voice.period = voice.portaPeriod;
                    voice.portaPeriod = 0;
                  }
                } else {
                  voice.period += voice.portaSpeed;
                  if (voice.period > voice.portaPeriod) {
                    voice.period = voice.portaPeriod;
                    voice.portaPeriod = 0;
                  }
                }
              }

              chan.period = voice.period;
              break;
            case 4:  //vibrato
            case 6:  //vibrato + volume slide
              if (voice.effect == 6) slide = 1;
                else if (voice.param) voice.vibratoSpeed = voice.param;

              value = (voice.vibratoPos >> 2) & 31;
              value = ((voice.vibratoSpeed & 0x0f) * VIBRATO[value]) >> vibratoDepth;

              if (voice.vibratoPos > 127) chan.period = voice.period - value;
                else chan.period = voice.period + value;

              value = (voice.vibratoSpeed >> 2) & 60;
              voice.vibratoPos = (voice.vibratoPos + value) & 255;
              break;
          }

          if (slide) {
            value = voice.param >> 4;
            if (value) voice.volume += value;
              else voice.volume -= voice.param & 0x0f;

            if (voice.volume > 64) voice.volume = 64;
              else if (voice.volume < 0) voice.volume = 0;
            chan.volume = voice.volume;
          }
        }

        if (jumpFlag) next();
      }
    }

    override protected function initialize():void {
      var i:int, voice:MKData;
      super.initialize();
      speed      = 6;
      trackPos   = 0;
      patternPos = 0;
      jumpFlag   = 0;

      force = version;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.channel = amiga.channels[i];
        voice.sample  = samples[0];
      }
    }

    private function next():void {
      patternPos = jumpFlag = 0;
      trackPos   = ++trackPos & 127;

      if (trackPos == length) {
        trackPos = restart;
        amiga.complete = 1;
      }
    }
  }
}