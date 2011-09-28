package neoart.flym {
  import flash.utils.*;

  public class YmSong {
    public var title:String;
    public var author:String;
    public var comment:String;

    public var attribs:int;
    public var clock:int;
    public var digidrums:Vector.<Digidrum>;
    public var drums:int;
    public var frames:Vector.<ByteArray>;
    public var frameSize:int;
    public var length:int;
    public var rate:int;
    public var restart:int;
    public var supported:Boolean = true;

    public var data:ByteArray;

    public function YmSong(stream:ByteArray) {
      data = stream;
      init();
    }

    private function init():void {
      var i:int, lha:LHa = new LHa();

      data = lha.unpack(data);
      data.endian = Endian.BIG_ENDIAN;
      data.position = 0;

      decode();
      if (attribs & YmConst.INTERLEAVED) deinterleave();

      frames = new Vector.<ByteArray>(length, true);

      for (i = 0; i < length; ++i) {
        frames[i] = new ByteArray();
        frames[i].endian = Endian.BIG_ENDIAN;
        data.readBytes(frames[i], 0, frameSize);
      }

      //data.clear();
      //data = null;
    }

    private function decode():void {
      var digidrum:Digidrum, i:int, id:String = data.readMultiByte(4, YmConst.ENCODING);

      switch (id) {
        case "YM2!":
        case "YM3!":
        case "YM3b":
          frameSize = 14;
          length = (data.length - 4) / frameSize;
          clock = YmConst.ATARI_FREQ;
          rate = 50;
          restart = (id != "YM3b") ? 0 : data.readByte();
          attribs = YmConst.INTERLEAVED | YmConst.TIME_CONTROL;
          break;

        case "YM4!":
          supported = false;
          break;

        case "YM5!":
        case "YM6!":
          id = data.readMultiByte(8, YmConst.ENCODING);
          if (id != "LeOnArD!") {
            supported = false;
            return;
          }

          length  = data.readInt();
          attribs = data.readInt();
          drums   = data.readShort();
          clock   = data.readInt();
          rate    = data.readShort();
          restart = data.readInt();
          data.readShort();

          if (drums) {
            digidrums = new Vector.<Digidrum>(drums, true);

            for (i = 0; i < drums; ++i) {
              digidrum = new Digidrum(data.readInt());

              if (digidrum.size != 0) {
                data.readBytes(digidrum.wave, 0, digidrum.size);
                digidrum.convert(attribs);
                digidrums[i] = digidrum;
              }
            }
            attribs &= (~YmConst.DRUM_4BITS);
          }

          title = readString();
          author = readString();
          comment = readString();

          frameSize = 16;
          attribs = YmConst.INTERLEAVED | YmConst.TIME_CONTROL;
          break;

        case "MIX1":
          supported = false;
          break;

        case "YMT1":
        case "YMT2":
          supported = false;
          break;

        default:
          supported = false;
          break;
      }
    }

    private function deinterleave():void {
      var i:int, j:int, s:int,
          p:Vector.<int> = new Vector.<int>(frameSize, true),
          r:ByteArray = new ByteArray();

      for (i = 0; i < frameSize; ++i) p[i] = data.position + (length * i);

      for (i = 0; i < length; ++i) {
        for (j = 0; j < frameSize; ++j) r[j + s] = data[i + p[j]];
        s += frameSize;
      }

      data.clear();
      data = r;
      attribs &= (~YmConst.INTERLEAVED);
    }

    private function readString():String {
      var b:int, s:String = "";

      for (;;) {
        b = data.readUnsignedByte();
        if (b == 0) return s;
        s += String.fromCharCode(b);
      }

      return s;
    }
  }
}