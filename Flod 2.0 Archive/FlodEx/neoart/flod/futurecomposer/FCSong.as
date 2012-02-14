/* Flod Future Composer Replay 1.0
   2009/12/10
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.futurecomposer {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class FCSong {
    [Embed(source="waveforms.bin", mimeType="application/octet-stream")]
    private var Waveforms:Class;

    public var version:int;

    internal const FUTURECOMP_10:int = 1;
    internal const FUTURECOMP_14:int = 2;

    internal var length:int;
    internal var seqs:ByteArray;
    internal var pats:ByteArray;
    internal var vols:ByteArray;
    internal var frqs:ByteArray;
    internal var samples:Vector.<AmigaSample>;

    private const TRACKERS:Vector.<String> = Vector.<String>([
      "Unsupported Format",
      "Future Composer 1.0/1.3",
      "Future Composer 1.4"]);

    public function get tracker():String {
      return TRACKERS[version];
    }

    internal function initialize(stream:ByteArray, amiga:Amiga):int {
      var i:int, id:String, j:int, l:int, offset:int, pointer:int, position:int, sample:AmigaSample, temp:int, total:int, wave:ByteArray;
      stream.endian = "bigEndian";
      stream.position = 0;
      amiga.reset();

      id = stream.readMultiByte(4, Amiga.ENCODING);

      if (id == "SMOD") version = FUTURECOMP_10;
        else if (id == "FC14") version = FUTURECOMP_14;
          else return 0;

      seqs = new ByteArray();
      stream.position = 4;
      length = stream.readUnsignedInt();
      stream.position = version == FUTURECOMP_10 ? 100 : 180;
      stream.readBytes(seqs, 0, length);
      length /= 13;

      pats = new ByteArray();
      stream.position = 12;
      l = stream.readUnsignedInt();
      stream.position = 8;
      stream.position = stream.readUnsignedInt();
      stream.readBytes(pats, 0, l);

      pats.position = pats.length;
      pats.writeByte(0);
      pats.position = 0;

      frqs = new ByteArray();
      frqs.writeInt(0x01000000);
      frqs.writeInt(0x000000e1);
      stream.position = 20;
      l = stream.readUnsignedInt();
      stream.position = 16;
      stream.position = stream.readUnsignedInt();
      stream.readBytes(frqs, 8, l);

      frqs.position = frqs.length;
      frqs.writeByte(0xe1);
      frqs.position = 0;

      vols = new ByteArray();
      vols.writeInt(0x01000000);
      vols.writeInt(0x000000e1);
      stream.position = 28;
      l = stream.readUnsignedInt();
      stream.position = 24;
      stream.position = stream.readUnsignedInt();
      stream.readBytes(vols, 8, l);

      stream.position = 32;
      pointer = stream.readUnsignedInt();
      stream.position = 40;

      if (version == FUTURECOMP_10) {
        samples = new Vector.<AmigaSample>(57, true);
        offset = 0;
      } else {
        samples = new Vector.<AmigaSample>(200, true);
        offset = 2;
      }

      for (i = 0; i < 10; ++i) {
        l = stream.readUnsignedShort() << 1;

        if (l > 0) {
          position = stream.position;
          stream.position = pointer;
          id = stream.readMultiByte(4, Amiga.ENCODING);

          if (id == "SSMP") {
            temp = l;

            for (j = 0; j < 10; ++j) {
              stream.readInt();
              l = stream.readUnsignedShort() << 1;

              if (l > 0) {
                sample = new AmigaSample();
                sample.length    = l + 2;
                sample.loopStart = stream.readUnsignedShort();
                sample.repeatLen = stream.readUnsignedShort() << 1;

                if ((sample.loopStart + sample.repeatLen) > sample.length)
                  sample.repeatLen = sample.length - sample.loopStart;

                if ((pointer + sample.length) > stream.length)
                  sample.length = stream.length - pointer;

                sample.pointer = amiga.store(stream, sample.length, pointer + total);
                sample.loopPtr = sample.pointer + sample.loopStart;
                samples[100 + (i * 10) + j] = sample;
                total += sample.length;
                stream.position += 6;
              } else {
                stream.position += 10;
              }
            }

            pointer += (temp + 2);
            stream.position = position + 4;
          } else {
            stream.position = position;
            sample = new AmigaSample;
            sample.length    = l + offset;
            sample.loopStart = stream.readUnsignedShort();
            sample.repeatLen = stream.readUnsignedShort() << 1;

            if ((sample.loopStart + sample.repeatLen) > sample.length)
              sample.repeatLen = sample.length - sample.loopStart;

            if ((pointer + sample.length) > stream.length)
              sample.length = stream.length - pointer;

            sample.pointer = amiga.store(stream, sample.length, pointer);
            sample.loopPtr = sample.pointer + sample.loopStart;
            samples[i] = sample;
            pointer += sample.length;
          }
        } else {
          stream.position += 4;
        }
      }

      if (version == FUTURECOMP_10) {
        wave = new Waveforms() as ByteArray;
        pointer = 47;

        for (i = 10; i < 57; ++i) {
          sample = new AmigaSample();
          sample.length    = wave.readUnsignedByte() << 1;
          sample.loopStart = 0;
          sample.repeatLen = sample.length;
          sample.pointer   = amiga.store(wave, sample.length, pointer);
          sample.loopPtr   = sample.pointer;
          samples[i] = sample;
          pointer += sample.length;
        }
      } else {
        stream.position = 36;
        pointer = stream.readUnsignedInt();
        stream.position = 100;

        for (i = 10; i < 90; ++i) {
          l = stream.readUnsignedByte() << 1;
          if (l < 2) continue;
          sample = new AmigaSample();
          sample.length    = l;
          sample.loopStart = 0;
          sample.repeatLen = sample.length;

          if ((pointer + sample.length) > stream.length)
            sample.length = stream.length - pointer;

          sample.pointer = amiga.store(stream, sample.length, pointer);
          sample.loopPtr = sample.pointer;
          samples[i] = sample;
          pointer += sample.length;
        }
      }

      length = int(length * 13);
      stream.clear();
      return 1;
    }
  }
}