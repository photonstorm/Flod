package neoart.flip {
  import flash.utils.*;

  public final class ZipEntry {
    public var
      name       : String,
      extra      : ByteArray,
      version    : int,
      flag       : int,
      method     : int,
      time       : uint,
      crc        : uint,
      compressed : uint,
      size       : uint,
      offset     : uint;

    public function get date():Date {
      return new Date(
        ((time >> 25) & 0x7f) + 1980,
        ((time >> 21) & 0x0f) - 1,
         (time >> 16) & 0x1f,
         (time >> 11) & 0x1f,
         (time >>  5) & 0x3f,
         (time & 0x1f) << 1
      );
    }

    public function get isDirectory():Boolean { return Boolean(name.charAt(name.length - 1) == "/"); }
  }
}