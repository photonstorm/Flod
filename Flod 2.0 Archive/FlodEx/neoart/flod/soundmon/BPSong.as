/* Flod Brian Postma's SoundMon Replay 1.0
   2009/12/10
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.soundmon {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class BPSong {
    public var title:String;
    public var version:int;

    internal const SOUNDMON_V1:int = 1;
    internal const SOUNDMON_V2:int = 2;
    internal const SOUNDMON_V3:int = 3;

    internal var length:int;
    internal var steps:Vector.<BPStep>;
    internal var patterns:Vector.<BPCommand>;
    internal var samples:Vector.<BPSample>;

    private const TRACKERS:Vector.<String> = Vector.<String>([
      "Unsupported Format",
      "SoundMon 1.0",
      "SoundMon 1.1/2.0",
      "SoundMon 2.1",
      "SoundMon 2.2"]);

    public function get tracker():String {
      return TRACKERS[version];
    }

    internal function initialize(stream:ByteArray, amiga:Amiga):int {
      var com:BPCommand, i:int, id:String, l:int, totPatterns:int, totTables:int, sample:BPSample, step:BPStep;
      stream.endian = "bigEndian";
      stream.position = 0;
      amiga.reset();

      title = stream.readMultiByte(26, Amiga.ENCODING);
      id = stream.readMultiByte(4, Amiga.ENCODING);

      if (id == "BPSM") {
        version = SOUNDMON_V1;
      } else {
        id = id.substr(0, 3);

        if (id == "V.2") version = SOUNDMON_V2;
          else if (id == "V.3") version = SOUNDMON_V3;
            else return 0;

        stream.position = 29;
        totTables = stream.readUnsignedByte();
      }

      length  = stream.readUnsignedShort();
      samples = new Vector.<BPSample>(16, true);

      for (i = 0; ++i < 16;) {
        sample = new BPSample();

        if (stream.readUnsignedByte() == 0xff) {
          sample.synth = 1;

          sample.waveTable   = stream.readUnsignedByte();
          sample.pointer     = sample.waveTable << 6;
          sample.length      = stream.readUnsignedShort() << 1;
          sample.adsrControl = stream.readUnsignedByte();
          sample.adsrTable   = stream.readUnsignedByte();
          sample.adsrLength  = stream.readUnsignedShort();
          sample.adsrSpeed   = stream.readUnsignedByte();
          sample.lfoControl  = stream.readUnsignedByte();
          sample.lfoTable    = stream.readUnsignedByte();
          sample.lfoDepth    = stream.readUnsignedByte();
          sample.lfoLength   = stream.readUnsignedShort();

          if (version < SOUNDMON_V3) {
            stream.readByte();
            sample.lfoDelay   = stream.readUnsignedByte();
            sample.lfoSpeed   = stream.readUnsignedByte();
            sample.egControl  = stream.readUnsignedByte();
            sample.egTable    = stream.readUnsignedByte();
            stream.readByte();
            sample.egLength   = stream.readUnsignedShort();
            stream.readByte();
            sample.egDelay    = stream.readUnsignedByte();
            sample.egSpeed    = stream.readUnsignedByte();
            sample.fxControl  = 0;
            sample.fxSpeed    = 1;
            sample.fxDelay    = 0;
            sample.modControl = 0;
            sample.modTable   = 0;
            sample.modSpeed   = 1;
            sample.modDelay   = 0;
            sample.volume     = stream.readUnsignedByte();
            sample.modLength  = 0;
            stream.position  += 6;
          } else {
            sample.lfoDelay   = stream.readUnsignedByte();
            sample.lfoSpeed   = stream.readUnsignedByte();
            sample.egControl  = stream.readUnsignedByte();
            sample.egTable    = stream.readUnsignedByte();
            sample.egLength   = stream.readUnsignedShort();
            sample.egDelay    = stream.readUnsignedByte();
            sample.egSpeed    = stream.readUnsignedByte();
            sample.fxControl  = stream.readUnsignedByte();
            sample.fxSpeed    = stream.readUnsignedByte();
            sample.fxDelay    = stream.readUnsignedByte();
            sample.modControl = stream.readUnsignedByte();
            sample.modTable   = stream.readUnsignedByte();
            sample.modSpeed   = stream.readUnsignedByte();
            sample.modDelay   = stream.readUnsignedByte();
            sample.volume     = stream.readUnsignedByte();
            sample.modLength  = stream.readUnsignedShort();
          }
        } else {
          stream.position--;
          sample.synth  = 0;
          sample.name   = stream.readMultiByte(24, Amiga.ENCODING);
          sample.length = stream.readUnsignedShort() << 1;

          if (sample.length) {
            sample.loopStart = stream.readUnsignedShort();
            sample.repeatLen = stream.readUnsignedShort() << 1;
            sample.volume    = stream.readUnsignedShort();

            if ((sample.loopStart + sample.repeatLen) > sample.length)
              sample.repeatLen = sample.length - sample.loopStart;
          } else {
            sample.pointer--;
            sample.repeatLen = 2;
            stream.position += 6;
          }
        }

        samples[i] = sample;
      }

      l = length << 2;
      steps = new Vector.<BPStep>(l, true);

      for (i = 0; i < l; ++i) {
        step = new BPStep();
        step.pattern = stream.readUnsignedShort();
        step.soundTranspose = stream.readByte();
        step.transpose = stream.readByte();
        if (step.pattern > totPatterns) totPatterns = step.pattern;
        steps[i] = step;
      }

      l = totPatterns << 4;
      patterns = new Vector.<BPCommand>(l, true);

      for (i = 0; i < l; ++i) {
        com = new BPCommand();
        com.note   = stream.readByte();
        com.sample = stream.readUnsignedByte();
        com.option = com.sample & 0x0f;
        com.data   = stream.readByte();
        com.sample = (com.sample & 0xf0) >> 4;
        patterns[i] = com;
      }

      for (i = 0; i < totTables; ++i) amiga.store(stream, 64);

      for (i = 0; ++i < 16;) {
        sample = samples[i];
        if (sample.synth || sample.length == 0) continue;

        if ((stream.position + sample.length) >= stream.length)
          sample.length = stream.length - stream.position;

        sample.pointer = amiga.store(stream, sample.length);
        sample.loopPtr = sample.pointer + sample.loopStart;
      }

      stream.clear();
      return 1;
    }
  }
}