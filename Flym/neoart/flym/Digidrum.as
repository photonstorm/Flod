package neoart.flym {
  import flash.utils.*;

  public class Digidrum {
    public var data:Vector.<Number>;
    public var repeatLen:int;
    public var size:int;
    public var wave:ByteArray;

    public function Digidrum(size:int) {
      this.size = size;

      wave = new ByteArray();
      wave.endian = Endian.BIG_ENDIAN;
      wave.position = 0;
    }

    public function convert(attribs:int):void {
      var b:int, i:int;

      if (attribs & YmConst.DRUM_4BITS) {
        data = new Vector.<Number>(size, true);
      
        for (i = 0; i < size; ++i) {
          b = (wave.readUnsignedByte() & 15) >> 7;
          data[i] = YmConst.MONO[b];
        }
      }

      wave.clear();
      wave = null;
    }
  }
}