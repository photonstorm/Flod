/* Flod Delta Music 2 Replay 1.0
   2009/12/24
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.delta2 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class D2Song {
    public var title:String;
    public var version:int;

    internal var tracksData:Vector.<int>;
    internal var tracks:Vector.<D2Step>;
    internal var patterns:Vector.<D2Command>;
    internal var arpeggios:Vector.<int>;
    internal var samples:Vector.<D2Sample>;

    internal function initialize(stream:ByteArray, amiga:Amiga):int {
      var com:D2Command, i:int, id:String, j:int, len:int, offsets:Vector.<int>, pointer:int, sample:D2Sample, step:D2Step, value:int;
      stream.endian = "bigEndian";
      stream.position = 0xbc6;
      amiga.reset();

      id = stream.readMultiByte(4, Amiga.ENCODING);
      if (id != ".FNL") return 0;

      stream.position = 0xfca;
      tracksData = new Vector.<int>(12, true);

      for (i = 0; i < 4; ++i) {
        tracksData[i + 4] = stream.readUnsignedShort();
        value = stream.readUnsignedShort() >> 1;
        tracksData[i + 8] = value;
        len += value;
      }

      value = len;
      for (i = 3; i > 0; --i) tracksData[i] = (value -= tracksData[i + 8]);

      tracks = new Vector.<D2Step>(len, true);

      for (i = 0; i < len; ++i) {
        step = new D2Step();
        step.pattern   = stream.readUnsignedByte() << 4;
        step.transpose = stream.readByte();
        tracks[i] = step;
      }

      len = stream.readUnsignedInt() >> 2;
      patterns = new Vector.<D2Command>(len, true);

      for (i = 0; i < len; ++i) {
        com = new D2Command();
        com.note   = stream.readUnsignedByte();
        com.sample = stream.readUnsignedByte();
        com.effect = stream.readUnsignedByte() - 1;
        com.data   = stream.readUnsignedByte();
        patterns[i] = com;
      }

      stream.position += 254;
      value = stream.readUnsignedShort();
      pointer = stream.position;
      stream.position -= 256;

      offsets = new Vector.<int>(128, true);
      len = 1;

      for (i = 0; i < 128; ++i) {
        j = stream.readUnsignedShort();
        if (j != value) offsets[len++] = j;
      }

      samples = new Vector.<D2Sample>(len);

      for (i = 0; i < len; ++i) {
        stream.position = pointer + offsets[i];
        sample = new D2Sample();

        sample.length    = stream.readUnsignedShort() << 1;
        sample.loopStart = stream.readUnsignedShort();
        sample.repeatLen = stream.readUnsignedShort() << 1;

        for (j = 0; j < 15; ++j) sample.volumes[j]  = stream.readUnsignedByte();
        for (j = 0; j < 15; ++j) sample.vibratos[j] = stream.readUnsignedByte();

        sample.bendrate = stream.readUnsignedShort();
        sample.synth    = stream.readByte();
        sample.number   = stream.readUnsignedByte();

        for (j = 0; j < 48; ++j) sample.waves[j] = stream.readUnsignedByte();
        samples[i] = sample;
      }

      len = stream.readUnsignedInt();
      amiga.store(stream, len);

      stream.position += 64;
      for (i = 0; i < 8; ++i) offsets[i] = stream.readUnsignedInt();

      len = samples.length;
      pointer = stream.position;

      for (i = 0; i < len; ++i) {
        sample = samples[i];
        if (sample.synth >= 0) continue;
        stream.position = pointer + offsets[sample.number];

        sample.pointer = amiga.store(stream, sample.length);
        sample.loopPtr = sample.loopStart + sample.pointer;

        amiga.samples[sample.loopPtr]     = 0;
        amiga.samples[sample.loopPtr + 1] = 0;
      }

      stream.position = 0xbca;
      arpeggios = new Vector.<int>(1024, true);
      for (i = 0; i < 1024; ++i) arpeggios[i] = stream.readByte();

      sample = new D2Sample();
      sample.pointer   = amiga.samples.length;
      sample.loopPtr   = sample.pointer;
      sample.length    =  2;
      sample.repeatLen =  2;
      sample.synth     = -1;

      len = samples.length;
      samples.length = len + 1;
      samples[len] = sample;
      samples.fixed = true;

      stream.clear();
      return 1;
    }
  }
}