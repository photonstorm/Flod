package neoart.flym {
  import flash.utils.*;

  class LHaHeader {
    public var size:int;
    public var checksum:int;
    public var method:String;
    public var packed:int;
    public var original:int;
    public var timeStamp:int;
    public var attribute:int;
    public var level:int;
    public var nameLength:int;
    public var name:String;

    public function LHaHeader(source:ByteArray) {
      source.endian = Endian.LITTLE_ENDIAN;
      source.position = 0;

      size       = source.readUnsignedByte();
      checksum   = source.readUnsignedByte();
      method     = source.readMultiByte(5, YmConst.ENCODING);
      packed     = source.readUnsignedInt();
      original   = source.readUnsignedInt();
      timeStamp  = source.readUnsignedInt();
      attribute  = source.readUnsignedByte();
      level      = source.readUnsignedByte();
      nameLength = source.readUnsignedByte();
      name       = source.readMultiByte(nameLength, YmConst.ENCODING);

      source.readUnsignedShort();
    }
  }
}