/* Flod Delta Music 1 Replay 1.0
   2009/12/24
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.delta1 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class D1Song {
    public var title:String;
    public var version:int;

    internal var speed:int;

    internal var stepsPtr:Vector.<int>;
    internal var steps:Vector.<D1Step>;
    internal var patterns:Vector.<D1Command>;
    internal var samples:Vector.<D1Sample>;

    internal function initialize(stream:ByteArray, amiga:Amiga):int {
      var com:D1Command, i:int, id:String, j:int, len:int, pointer:int, pos:int, sample:D1Sample, sizes:Vector.<int>, step:D1Step, v:int;
      stream.endian = "bigEndian";
      stream.position = 0;
      amiga.reset();

      id = stream.readMultiByte(4, Amiga.ENCODING);
      if (id != "ALL ") return 0;

      pointer = 104;
      sizes   = new Vector.<int>(25, true);
      for (i = 0; i < 25; ++i) sizes[i] = stream.readUnsignedInt();

      stepsPtr = new Vector.<int>(4, true);
      for (i = 1; i < 4; ++i) stepsPtr[i] = (stepsPtr[j] + (sizes[j++] >> 1)) - 1;

      len = (stepsPtr[3] + (sizes[3] >> 1)) - 1;
      pos = pointer + sizes[1] - 2;
      steps = new Vector.<D1Step>(len, true);
      stream.position = pointer;
      v = 1;

      for (i = 0; i < len; ++i) {
        step = new D1Step();
        j = stream.readUnsignedShort();

        if (j == 0xffff || stream.position == pos) {
          step.pattern = -1;
          step.transpose = stream.readUnsignedShort();
          pos += sizes[v++];
        } else {
          stream.position--;
          step.transpose = stream.readByte();
          step.pattern   = ((j >> 2) & 16320) >> 2;
        }

        steps[i] = step;
      }

      len = sizes[4] >> 2;
      patterns = new Vector.<D1Command>(len, true);

      for (i = 0; i < len; ++i) {
        com = new D1Command();
        com.sample = stream.readUnsignedByte();
        com.note   = stream.readUnsignedByte();
        com.effect = stream.readUnsignedByte() & 31;
        com.data   = stream.readUnsignedByte();
        patterns[i] = com;
      }

      samples = new Vector.<D1Sample>(21, true);
      pos = 5;

      for (i = 0; i < 20; ++i) {
        if (sizes[pos] != 0) {
          sample = new D1Sample();

          sample.attackStep    = stream.readUnsignedByte();
          sample.attackDelay   = stream.readUnsignedByte();
          sample.decayStep     = stream.readUnsignedByte();
          sample.decayDelay    = stream.readUnsignedByte();
          sample.sustain       = stream.readUnsignedShort();
          sample.releaseStep   = stream.readUnsignedByte();
          sample.releaseDelay  = stream.readUnsignedByte();
          sample.volume        = stream.readUnsignedByte();
          sample.vibratoWait   = stream.readUnsignedByte();
          sample.vibratoStep   = stream.readUnsignedByte();
          sample.vibratoLength = stream.readUnsignedByte();
          sample.bendrate      = stream.readByte();
          sample.portamento    = stream.readUnsignedByte();
          sample.synth         = stream.readUnsignedByte();
          sample.tableDelay    = stream.readUnsignedByte();

          for (j = 0; j < 8; ++j) sample.arpeggio[j] = stream.readByte();

          sample.length    = stream.readUnsignedShort();
          sample.loopStart = stream.readUnsignedShort();
          sample.repeatLen = stream.readUnsignedShort() << 1;
          sample.synth     = sample.synth ? 0 : 1;

          if (sample.synth) {
            for (j = 0; j < 48; ++j) sample.table[j] = stream.readByte();
            len = sizes[pos] - 78;
          } else {
            len = sample.length;
          }
          sample.pointer = amiga.store(stream, len);
          sample.loopPtr += sample.pointer;

          if (!sample.synth) {
            amiga.samples[sample.pointer]     = 0;
            amiga.samples[sample.pointer + 1] = 0;
          }

          samples[i] = sample;
        }
        pos++;
      }

      samples[20] = new D1Sample();

      speed = 6;
      stream.clear();
      return 1;
    }
  }
}