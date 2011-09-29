package neoart.flod.hismaster {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class HMPlayer extends AmigaPlayer {
    internal var
      track      : Vector.<int>,
      patterns   : Vector.<AmigaRow>,
      samples    : Vector.<HMSample>,
      length     : int,
      restart    : int;
    private var
      voices     : Vector.<HMData>,
      trackPos   : int,
      patternPos : int,
      jumpFlag   : int;

    private const
      ARPEGGIO : Vector.<int> = Vector.<int>([
        0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1]),
      MEGARPE  : Vector.<int> = Vector.<int>([
        00,03,07,12,15,12,07,03,00,03,07,12,15,12,07,03,
        00,04,07,12,16,12,07,04,00,04,07,12,16,12,07,04,
        00,03,08,12,15,12,08,03,00,03,08,12,15,12,08,03,
        00,04,08,12,16,12,08,04,00,04,08,12,16,12,08,04,
        00,05,08,12,17,12,08,05,00,05,08,12,17,12,08,05,
        00,05,09,12,17,12,09,05,00,05,09,12,17,12,09,05,
        12,00,07,00,03,00,07,00,12,00,07,00,03,00,07,00,
        12,00,07,00,04,00,07,00,12,00,07,00,04,00,07,00,
        00,03,07,03,07,12,07,12,15,12,07,12,07,03,07,03,
        00,04,07,04,07,12,07,12,16,12,07,12,07,04,07,04,
        31,27,24,19,15,12,07,03,00,03,07,12,15,19,24,27,
        31,28,24,19,16,12,07,04,00,04,07,12,16,19,24,28,
        00,12,00,12,00,12,00,12,00,12,00,12,00,12,00,12,
        00,12,24,12,00,12,24,12,00,12,24,12,00,12,24,12,
        00,03,00,03,00,03,00,03,00,03,00,03,00,03,00,03,
        00,04,00,04,00,04,00,04,00,04,00,04,00,04,00,04]),
      PERIODS  : Vector.<int> = Vector.<int>([
        856,808,762,720,678,640,604,570,538,508,480,453,428,
        404,381,360,339,320,302,285,269,254,240,226,214,202,
        190,180,170,160,151,143,135,127,120,113,000]),
      VIBRATO  : Vector.<int> = Vector.<int>([
        000,024,049,074,097,120,141,161,180,197,212,224,235,
        244,250,253,255,253,250,244,235,224,212,197,180,161,
        141,120,097,074,049,024]);

    public function HMPlayer(amiga:Amiga = null) {
      super(amiga);
      ARPEGGIO.fixed = true;
      MEGARPE.fixed  = true;
      PERIODS.fixed  = true;
      VIBRATO.fixed  = true;

      track   = new Vector.<int>(128, true);
      samples = new Vector.<HMSample>(32, true);
      voices  = new Vector.<HMData>(4, true);

      voices[0] = new HMData();
      voices[1] = new HMData();
      voices[2] = new HMData();
      voices[3] = new HMData();
    }

    override public function load(stream:ByteArray):int {
      super.load(stream);
      HMLoader.load(stream, amiga);
      return version;
    }

    override public function process():void {
      var chan:AmigaChannel, i:int, pattern:int, row:AmigaRow, sample:HMSample, value:int, voice:HMData;

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
            voice.volume2 = sample.volume;

            if (sample.name == "Mupp") {
              sample.loopPtr = sample.pointer + sample.waves[0];
              voice.handler = 1;
              voice.volume1 = sample.volumes[0];
            } else {
              voice.handler = 0;
              voice.volume1 = 64;
            }
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
              } else
                voice.portaPeriod = 0;
            } else {
              voice.period     = row.note;
              voice.vibratoPos = 0;
              voice.wavePos    = 0;
              voice.enabled    = 1;

              chan.enabled = 0;
              value = (voice.period * sample.finetune) >> 8;
              chan.period = voice.period + value;

              if (voice.handler) {
                chan.pointer = sample.loopPtr;
                chan.length  = sample.repeat;
              } else {
                chan.pointer = sample.pointer;
                chan.length  = sample.length;
              }
            }

            switch (voice.effect) {
              case 11: //position jump
                trackPos = voice.param - 1;
                jumpFlag = 1;
                break;
              case 12: //set volume
                voice.volume2 = voice.param;
                if (voice.volume2 > 64) voice.volume2 = 64;
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

            if (row.note == 0) effects(voice);
            handler(voice);
            if (voice.enabled) chan.enabled = 1;
            chan.pointer = sample.loopPtr;
            chan.length  = sample.repeat;
          }
        }
      } else {
        for (i = 0; i < 4; ++i) {
          voice = voices[i];
          effects(voice);
          handler(voice);
          sample = voice.sample;
          voice.channel.pointer = sample.loopPtr;
          voice.channel.length  = sample.repeat;
        }

        if (jumpFlag) next();
      }
    }

    override protected function initialize():void {
      var i:int, voice:HMData;
      super.initialize();
      speed      = 6;
      trackPos   = 0;
      patternPos = 0;
      jumpFlag   = 0;

      amiga.samplesTick = 884;

      for (i = 0; i < 4; ++i) {
        voice = voices[i];
        voice.initialize();
        voice.channel = amiga.channels[i];
        voice.sample  = samples[0];
      }
    }

    private function effects(voice:HMData):void {
      var chan:AmigaChannel = voice.channel, i:int, len:int, period:int, slide:int, value:int;
      period = voice.period & 0x0fff;

      if (voice.effect || voice.param) {
        switch (voice.effect) {
          case 0:  //arpeggio
            value = ARPEGGIO[timer];
            if (value == 0) break;
            if (value == 1) value = voice.param >> 4;
              else value = voice.param & 0x0f;

            len = 37 - value;

            for (i = 0; i < len; ++i) {
              if (period >= PERIODS[i]) {
                period = PERIODS[int(i + value)];
                break;
              }
            }
            break;
          case 1:  //portamento up
            voice.period -= voice.param;
            if (voice.period < 113) voice.period = 113;
            period = voice.period;
            break;
          case 2:  //portamento down
            voice.period += voice.param;
            if (voice.period > 856) voice.period = 856;
            period = voice.period;
            break;
          case 3:  //tone portamento
          case 5:  //tone portamento + volume slide
            if (voice.effect == 5) slide = 1;
            else {
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
            period = voice.period;
            break;
          case 4:  //vibrato
          case 6:  //vibrato + volume slide;
            if (voice.effect == 6) slide = 1;
              else if (voice.param) voice.vibratoSpeed = voice.param;

            value = VIBRATO[int((voice.vibratoPos >> 2) & 31)];
            value = ((voice.vibratoSpeed & 0x0f) * value) >> 7;

            if (voice.vibratoPos > 127) period -= value;
              else period += value;

            value = (voice.vibratoSpeed >> 2) & 60;
            voice.vibratoPos = (voice.vibratoPos + value) & 255;
            break;
          case 7:  //mega arpeggio
            value = MEGARPE[int((voice.vibratoPos & 0x0f) + ((voice.param & 0x0f) << 4))];
            voice.vibratoPos++;
            for (i = 0; i < 37; ++i) if (period >= PERIODS[i]) break;

            value += i;
            if (value > 35) value -= 12;
            period = PERIODS[value];
            break;
          case 10: //volume slide
            slide = 1;
            break;
        }
      }

      chan.period = period + ((period * voice.sample.finetune) >> 8);

      if (slide) {
        value = voice.param >> 4;
        if (value) voice.volume2 += value;
          else voice.volume2 -= voice.param & 0x0f;

        if (voice.volume2 > 64) voice.volume2 = 64;
          else if (voice.volume2 < 0) voice.volume2 = 0;
      }
    }

    private function handler(voice:HMData):void {
      var sample:HMSample;

      if (voice.handler) {
        sample = voice.sample;
        sample.loopPtr = sample.pointer + sample.waves[voice.wavePos];
        voice.volume1 = sample.volumes[voice.wavePos];

        if (++voice.wavePos > sample.waveLen)
          voice.wavePos = sample.restart;
      }
      voice.channel.volume = (voice.volume1 * voice.volume2) >> 6;
    }

    private function next():void {
      patternPos = jumpFlag = 0;
      trackPos = ++trackPos & 127;

      if (trackPos == length) {
        trackPos = restart;
        amiga.complete = 1;
      }
    }
  }
}