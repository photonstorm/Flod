package neoart.flym {
  import flash.utils.*;

  public class LHa {
    public var data:ByteArray;

    private var source:ByteArray;
    private var buffer:ByteArray;
    private var output:ByteArray;
    private var srcSize:int;
    private var dstSize:int;
    private var srcPos:int;
    private var dstPos:int;

    private var c_Table:Vector.<int>;
    private var p_Table:Vector.<int>;
    private var c_Len:Vector.<int>;
    private var p_Len:Vector.<int>;
    private var l_Tree:Vector.<int>;
    private var r_Tree:Vector.<int>;

    private var bitBuffer:int;
    private var bitCount:int;
    private var subBuffer:int;
    private var blockSize:int;
    private var fillBufferSize:int;
    private var fillIndex:int;
    private var decodei:int;
    private var decodej:int;

    public function LHa() {
      data   = new ByteArray();
      buffer = new ByteArray();
      output = new ByteArray();

      c_Table = new Vector.<int>(4096, true);
      p_Table = new Vector.<int>(256,  true);
      c_Len   = new Vector.<int>(510,  true);
      p_Len   = new Vector.<int>(19,   true);
      l_Tree  = new Vector.<int>(1018, true);
      r_Tree  = new Vector.<int>(1018, true);
    }

    public function unpack(source:ByteArray):ByteArray {
      var header:LHaHeader = new LHaHeader(source);
      if (header.size == 0 || header.method != "-lh5-" || header.level != 0) return source;

      this.source = source;
      srcSize = header.packed;
      srcPos  = source.position;
      dstSize = header.original;

      fillBufferSize = 0;
      bitBuffer = 0;
      bitCount  = 0;
      subBuffer = 0;
      fillBuffer(16);
      blockSize = 0;
      decodej   = 0;

      var l:int = dstSize, n:int, np:int;

      while (l != 0) {
        n = l > 8192 ? 8192 : l;
        decode(n);
        np = n > dstSize ? dstSize : n;

        if (np > 0) {
          output.position = 0;
          output.readBytes(data, dstPos, np);
          dstPos += np;
          dstSize -= np;
        }

        l -= n;
      }

      //source.clear();
      buffer.clear();
      output.clear();
      return data;
    }

    private function decode(count:int):void {
      var c:int, r:int;

      while (--decodej >= 0) {
        output[r] = output[decodei];
        decodei = ++decodei & 8191;
        if (++r == count) return;
      }

      for (;;) {
        c = decode_c();

        if (c <= 255) {
          output[r] = c;
          if (++r == count) return;
        } else {
          decodej = c - 253;
          decodei = (r - decode_p() - 1) & 8191;

          while (--decodej >= 0) {
            output[r] = output[decodei];
            decodei = ++decodei & 8191;
            if (++r == count) return;
          }
        }
      }
    }

    private function decode_c():int {
      var j:int, mask:int;

      if (blockSize == 0) {
        blockSize = getBits(16);
        read_p(19, 5, 3);
        read_c();
        read_p(14, 4, -1);
      }

      blockSize--;
      j = c_Table[bitBuffer >> 4];

      if (j >= 510) {
        mask = 1 << 3;

        do {
          j = (bitBuffer & mask) ? r_Tree[j] : l_Tree[j];
          mask >>= 1;
        } while (j >= 510);
      }

      fillBuffer(c_Len[j]);
      return j & 0xffff;
    }

    private function decode_p():int {
      var j:int = p_Table[bitBuffer >> 8], mask:int;

      if (j >= 14) {
        mask = 1 << 7;

        do {
          j = (bitBuffer & mask) ? r_Tree[j] : l_Tree[j];
          mask >>= 1;
        } while (j >= 14);
      }

      fillBuffer(p_Len[j]);
      if (j != 0) j = (1 << (j - 1)) + getBits(j - 1);
      return j & 0xffff;
    }

    private function read_c():void {
      var c:int, i:int, mask:int, n:int = getBits(9);

      if (n == 0) {
        c = getBits(9);
        for (i = 0; i < 510; ++i) c_Len[i] = 0;
        for (i = 0; i < 4096; ++i) c_Table[i] = c;
      } else {
        while (i < n) {
          c = p_Table[bitBuffer >> 8];

          if (c >= 19) {
            mask = 1 << 7;

            do {
              c = (bitBuffer & mask) ? r_Tree[c] : l_Tree[c];
              mask >>= 1;
            } while (c >= 19);
          }

          fillBuffer(p_Len[c]);

          if (c <= 2) {
            if (c == 0)
              c = 1;
            else if (c == 1)
              c = getBits(4) + 3;
            else
              c = getBits(9) + 20;

            while (--c >= 0) c_Len[i++] = 0;
          } else {
            c_Len[i++] = c - 2;
          }
        }

        while (i < 510) c_Len[i++] = 0;
        makeTable(510, c_Len, 12, c_Table);
      }
    }

    private function read_p(nn:int, nbit:int, iSpecial:int):void {
      var c:int, i:int, mask:int, n:int = getBits(nbit);

      if (n == 0) {
        c = getBits(nbit);
        for (i = 0; i < nn; ++i) p_Len[i] = 0;
        for (i = 0; i < 256; ++i) p_Table[i] = c;
      } else {
        while (i < n) {
          c = bitBuffer >> 13;

          if (c == 7) {
            mask = 1 << 12;

            while (mask & bitBuffer) {
              mask >>= 1;
              c++;
            }
          }

          fillBuffer(c < 7 ? 3 : c - 3);
          p_Len[i++] = c;

          if (i == iSpecial) {
            c = getBits(2);
            while (--c >= 0) p_Len[i++] = 0;
          }
        }

        while (i < nn) p_Len[i++] = 0;
        makeTable(nn, p_Len, 8, p_Table);
      }
    }

    private function getBits(n:int):int {
      var r:int = bitBuffer >> (16 - n);
      fillBuffer(n);
      return r & 0xffff;
    }

    private function fillBuffer(n:int):void {
      var np:int;

      bitBuffer = (bitBuffer << n) & 0xffff;

      while (n > bitCount) {
        bitBuffer |= subBuffer << (n -= bitCount);
        bitBuffer &= 0xffff;

        if (fillBufferSize == 0) {
          fillIndex = 0;
          np = srcSize > 4064 ? 4064 : srcSize;

          if (np > 0) {
            source.position = srcPos;
            source.readBytes(buffer, 0, np);
            srcPos += np;
            srcSize -= np;
          }

          fillBufferSize = np;
        }

        if (fillBufferSize > 0) {
          fillBufferSize--;
          subBuffer = buffer[fillIndex++];
        } else {
          subBuffer = 0;
        }

        bitCount = 8;
      }

      bitBuffer |= subBuffer >> (bitCount -= n);
      bitBuffer &= 0xffff;
    }

    private function makeTable(nchar:int, bitlen:Vector.<int>, tablebits:int, table:Vector.<int>):Boolean {
      var a:int = nchar,h:int,
          i:int, j:int, k:int,
          l:int, n:int, p:int,
          t:Vector.<int>,
		  r:Vector.<int>,
          c:Vector.<int> = new Vector.<int>(17, true),
          w:Vector.<int> = new Vector.<int>(17, true),
          s:Vector.<int> = new Vector.<int>(18, true),
          mask:int = 1 << (15 - tablebits);

      for (i = 0; i < nchar; ++i) c[bitlen[i]]++;

      s[1] = 0;
      for (i = 1; i < 17; ++i) s[i + 1] = (s[i] + (c[i] << (16 - i))) & 0xffff;

      if (s[17] != 0) return false;
      j = 16 - tablebits;

      for (i = 1; i <= tablebits; ++i) {
        s[i] >>= j;
        w[i] = 1 << (tablebits - i);
      }

      while (i < 17) w[i] = 1 << (16 - i++);
      i = s[tablebits + 1] >> j;

      if (i != 0) {
        k = 1 << tablebits;
        while (i != k) table[i++] = 0;
      }

      for (h = 0; h < nchar; ++h) {
        if ((l = bitlen[h]) == 0) continue;
        n = s[l] + w[l];

        if (l <= tablebits) {
          for (i = s[l]; i < n; ++i) table[i] = h;
        } else {
          i = l - tablebits;
          k = s[l];
          p = k >> j;
          t = table;

          while (i != 0) {
            if (t[p] == 0) {
              l_Tree[a] = 0;
              r_Tree[a] = 0;
              t[p] = a++;
            }

            r = (k & mask) ? r_Tree : l_Tree;
            k <<= 1;
            i--;
          }

          r[t[p]] = h;
        }
        s[l] = n;
      }

      return true;
    }
  }
}