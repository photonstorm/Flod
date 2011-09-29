package neoart.flod.amiga {
  import flash.events.*;
  import flash.utils.*;

  public final class Amiga {
    public static const
      MODEL_A500  : int = 0,
      MODEL_A1200 : int = 1;
    public var
      player      : AmigaPlayer,
      filter      : AmigaFilter,
      model       : int = MODEL_A1200,
      record      : int,
      memory      : Vector.<int>,
      channels    : Vector.<AmigaChannel>,
      samplesTick : int,
      loopPtr     : int,
      loopLen     : int = 4;
    internal var
      clock       : Number,
      master      : Number = 0.00390625;
    private var
      buffer      : Vector.<Sample>,
      completed   : int,
      samplesLeft : int,
      wave        : ByteArray;

    public function Amiga() {
      var i:int;
      wave = new ByteArray();
      wave.endian = "littleEndian";

      channels = new Vector.<AmigaChannel>(4, true);
      channels[0] = new AmigaChannel(0);
      channels[1] = new AmigaChannel(1);
      channels[2] = new AmigaChannel(2);
      channels[3] = new AmigaChannel(3);

      filter = new AmigaFilter();
      buffer = new Vector.<Sample>(8192, true);
      for (i = 0; i < 8192; ++i) buffer[i] = new Sample();
    }

    public function get available():int { return wave.length; }

    public function get output():ByteArray {
      var data:ByteArray = new ByteArray;
      data.endian = "littleEndian";

      data.writeUTFBytes("RIFF");
      data.writeInt(wave.length + 44);
      data.writeUTFBytes("WAVEfmt ");
      data.writeInt(16);
      data.writeShort(1);
      data.writeShort(2);
      data.writeInt(44100);
      data.writeInt(44100 << 1);
      data.writeShort(2);
      data.writeShort(8);
      data.writeUTFBytes("data");
      data.writeInt(wave.length);
      data.writeBytes(wave);

      data.position = 0;
      return data;
    }

    public function set complete(value:int):void { completed = value ^ player.loopSong; }

    public function set volume(value:int):void {
      if (value > 0) {
        if (value > 64) value = 64;
        master = value * 0.00390625;
      } else {
        master = 0.0;
      }
    }

    public function store(data:ByteArray, len:int, ptr:int = -1):int {
      var add:int, i:int, pos:int, start:int = memory.length, total:int;
      pos = data.position;
      if (ptr > -1) data.position = ptr;
      total = data.position + len;

      if (total >= data.length) {
        add = total - data.length;
        len = data.length - data.position;
      }

      len += start;
      for (i = start; i < len; ++i) memory[i] = data.readByte();
      memory.length += add;

      data.position = pos;
      return start;
    }

    internal function initialize():void {
      var i:int, sample:Sample;
      wave.clear();
      filter.initialize();

      if (memory.fixed == false) {
        loopPtr = memory.length;
        memory.length += loopLen;
        memory.fixed = true;
      }

      completed = samplesLeft = 0;

      channels[0].initialize();
      channels[1].initialize();
      channels[2].initialize();
      channels[3].initialize();

      for (i = 0; i < 8192; ++i) {
        sample = buffer[i];
        sample.l = sample.r = 0.0;
      }
    }

    internal function reset():void { memory = new Vector.<int>(); }

    internal function mixer(e:SampleDataEvent):void {
      var chan:AmigaChannel, data:ByteArray = e.data, i:int, j:int, mixed:int, mixLen:int, mixPos:int, sample:Sample, size:int = 8192, speed:Number, toMix:int, value:Number, lv:Number, rv:Number;

      while (mixed < size) {
        if (samplesLeft == 0) {
          if (completed) size = mixPos;
          player.process();
          samplesLeft = samplesTick;
        }

        toMix = samplesLeft;
        if ((mixed + toMix) >= size) toMix = size - mixed;
        mixLen = mixPos + toMix;

        for (i = 0; i < 4; ++i) {
          chan = channels[i];

          if (chan.audena) {
            speed = chan.audper / clock;

            value = chan.audvol * master;
            lv = value * (1 - chan.level);
            rv = value * (1 + chan.level);

            mixPos += chan.delay;
            chan.delay = 0;

            for (j = mixPos; j < mixLen; ++j) {
              if (--chan.timer < 1) {
                if (chan.mute == 0) {
                  value = memory[chan.audloc] * 0.0078125;
                  chan.ldata = value * lv;
                  chan.rdata = value * rv;
                }

                chan.audloc++;
                chan.timer += speed;

                if (chan.audloc >= chan.audcnt) {
                  chan.audloc = chan.pointer;
                  chan.audcnt = chan.pointer + chan.length;
                }
              }

              sample = buffer[j];
              sample.l += chan.ldata;
              sample.r += chan.rdata;
            }
          } else {
            for (j = mixPos; j < mixLen; ++j) {
              sample = buffer[j];
              sample.l += chan.ldata;
              sample.r += chan.rdata;
            }
          }
        }

        mixPos = mixLen;
        mixed += toMix;
        samplesLeft -= toMix;
      }

      if (record) {
        for (i = 0; i < size; ++i) {
          sample = buffer[i];
          filter.process(model, sample);
          wave.writeByte(128 + int(sample.l * 128));
          wave.writeByte(128 + int(sample.r * 128));

          data.writeFloat(sample.l);
          data.writeFloat(sample.r);
          sample.l = sample.r = 0.0;
        }
      } else {
        for (i = 0; i < size; ++i) {
          sample = buffer[i];
          filter.process(model, sample);

          data.writeFloat(sample.l);
          data.writeFloat(sample.r);
          sample.l = sample.r = 0.0;
        }
      }
    }
  }
}