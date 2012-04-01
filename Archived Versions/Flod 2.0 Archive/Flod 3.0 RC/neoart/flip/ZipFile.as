package neoart.flip {
  import flash.utils.*;

  public final class ZipFile {
    public static const
      ENDIAN  : String = "littleEndian";
    public var
      entries : Vector.<ZipEntry>;
    private const
      ERROR1  : String = "The archive is either in unknown format or damaged.",
      ERROR2  : String = "Unexpected end of archive.",
      ERROR3  : String = "Encrypted archive not supported.",
      ERROR4  : String = "Compression method not supported.";
    private var
      stream  : ByteArray;

    public function ZipFile(stream:ByteArray) {
      this.stream = stream;
      this.stream.endian = ENDIAN;
      parseEnd();
    }

    public function uncompress(entry:ZipEntry):ByteArray {
      var buffer:ByteArray, inflater:Inflater, size:int;
      if (entry == null) return null;

      stream.position = entry.offset + 28;
      size = stream.readUnsignedShort();
      stream.position = 30 + entry.name.length + size;

      buffer = new ByteArray();
      buffer.endian = ENDIAN;
      if (entry.compressed > 0) stream.readBytes(buffer, 0, entry.compressed);

      switch (entry.method) {
        case 0:
          return buffer;
        case 8:
          inflater = new Inflater();
          inflater.input = buffer;
          inflater.inflate();
          return inflater.output;
        default:
          throw new Error(ERROR4, 4);
          break;
      }
    }

    private function parseCentral():void {
      var entry:ZipEntry, i:int, header:ByteArray = new ByteArray, len:int = entries.length, size:int;
      header.endian = ENDIAN;

      for (i = 0; i < len; ++i) {
        stream.readBytes(header, 0, 46);
        if (header.readUnsignedInt() != 0x02014b50) throw new Error(ERROR2, 2);
        header.position += 24;

        size = header.readUnsignedShort();
        if (size == 0) throw new Error(ERROR2, 2);
        entry = new ZipEntry();
        entry.name = stream.readUTFBytes(size);

        size = header.readUnsignedShort();
        if (size > 0) {
          entry.extra = new ByteArray();
          stream.readBytes(entry.extra, 0, size);
        }

        stream.position += header.readUnsignedShort();
        header.position  = 6;
        entry.version    = header.readUnsignedShort();

        entry.flag = header.readUnsignedShort();
        if ((entry.flag & 1) == 1) throw new Error(ERROR3, 3);

        entry.method     = header.readUnsignedShort();
        entry.time       = header.readUnsignedInt();
        entry.crc        = header.readUnsignedInt();
        entry.compressed = header.readUnsignedInt();
        entry.size       = header.readUnsignedInt();

        header.position = 42;
        entry.offset = header.readUnsignedInt();
        entries[i] = entry;
      }
    }

    private function parseEnd():void {
      var i:int = stream.length - 22, l:int = (i - 65536) > 0 ? i - 65536 : 0;

      do {
        if (stream[i] != 0x50) continue;
        stream.position = i;
        if (stream.readUnsignedInt() == 0x06054b50) break;
      } while (--i > l);

      if (i == l) throw new Error(ERROR1, 1);

      stream.position = i + 10;
      entries = new Vector.<ZipEntry>(stream.readUnsignedShort(), true);
      stream.position = i + 16;
      stream.position = stream.readUnsignedInt();
      parseCentral();
    }
  }
}