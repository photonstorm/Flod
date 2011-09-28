/* Flod Amiga Core 3.01
   2009/12/12
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.amiga {
  import flash.utils.*;

  public final class Amiga {
    public static const MODEL_A500: int = 0;
    public static const MODEL_A1200:int = 1;

    public static const ENCODING:String = "us-ascii";

    public var channels:Vector.<AmigaChannel>;
    public var empty:int;
    public var filter:AmigaFilter;
    public var model:int = MODEL_A1200;
    public var record:int;
    public var samples:Vector.<int>;

    internal var bufferSize:int = 8192;
    internal var clock:Number;
    internal var mixData:ByteArray;
    internal var mixPos:int;
    internal var mixLen:int;

    private var buffer:Vector.<Sample>;
    private var wave:ByteArray;

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
      buffer = new Vector.<Sample>(bufferSize, true);
      for (i = 0; i < bufferSize; ++i) buffer[i] = new Sample();
    }

    public function get available():Boolean {
      return Boolean(wave.length > 2);
    }

    public function get output():ByteArray {
      var out:ByteArray = new ByteArray();
      out.endian = "littleEndian";

      out.writeUTFBytes("RIFF");
      out.writeInt(wave.length + 44);
      out.writeUTFBytes("WAVEfmt ");
      out.writeInt(16);
      out.writeShort(1);
      out.writeShort(2);
      out.writeInt(44100);
      out.writeInt(44100 << 1);
      out.writeShort(2);
      out.writeShort(8);
      out.writeUTFBytes("data");
      out.writeInt(wave.length);
      out.writeBytes(wave);

      out.position = 0;
      return out;
    }

    public function initialize():void {
      var i:int, sample:Sample;
      wave.clear();
      wave.writeByte(128);
      wave.writeByte(128);

      if (!samples.fixed) {
        empty = samples.length;
        samples[samples.length] = 0;
        samples[samples.length] = 0;
        samples.fixed = true;
      }

      channels[0].initialize();
      channels[1].initialize();
      channels[2].initialize();
      channels[3].initialize();

      filter.initialize();

      for (i = 0; i < bufferSize; ++i) {
        sample = buffer[i];
        sample.l = 0.0;
        sample.r = 0.0;
      }
    }

    public function reset():void {
      samples = new Vector.<int>();
    }

    public function store(stream:ByteArray, len:int, pointer:int = -1):int {
      var add:int, i:int, pos:int, start:int = samples.length, total:int;
      if (pointer > -1) {
        pos = stream.position;
        stream.position = pointer;
      }
      total = stream.position + len;

      if (total >= stream.length) {
        add = total - stream.length;
        len = stream.length - stream.position;
      }

      len += start;
      for (i = start; i < len; ++i) samples[i] = stream.readByte();
      if (add) samples.length += add;
      if (pointer > -1) stream.position = pos;
      return start;
    }

    internal function mix():void {
      var chan:AmigaChannel, i:int, j:int, l:int = mixPos + mixLen, sample:Sample, speed:Number, value:Number, vl:Number, vr:Number;

      for (i = 0; i < 4; ++i) {
        chan = channels[i];
        if (!chan.audena) continue;
        speed = chan.period / clock;

        value = chan.audvol * 0.00390625;
        vl = value * (1 - chan.level);
        vr = value * (1 + chan.level);

        for (j = mixPos; j < l; ++j) {
          if (--chan.timer < 1) {
            if (!chan.audvol || !chan.mute) {
              value = samples[chan.audloc] * 0.0078125;
              chan.ldata = value * vl;
              chan.rdata = value * vr;
            }

            chan.audloc++;
            chan.timer += speed;

            if (chan.audloc >= chan.audlen) {
              chan.audloc = chan.pointer;
              chan.audlen = chan.pointer + chan.length;
            }
          }

          sample = buffer[j];
          sample.l += chan.ldata;
          sample.r += chan.rdata;
        }
      }

      mixPos = l;
    }

    internal function play():void {
      var i:int, l:int = bufferSize, sample:Sample;

      if (record) {
        for (i = 0; i < l; ++i) {
          sample = buffer[i];
          filter.process(model, sample);
          wave.writeByte(128 + (sample.l * 127));
          wave.writeByte(128 + (sample.r * 127));

          mixData.writeFloat(sample.l);
          mixData.writeFloat(sample.r);
          sample.l = sample.r = 0.0;
        }
      } else {
        for (i = 0; i < l; ++i) {
          sample = buffer[i];
          filter.process(model, sample);

          mixData.writeFloat(sample.l);
          mixData.writeFloat(sample.r);
          sample.l = sample.r = 0.0;
        }
      }

      mixPos = 0;
    }
  }
}