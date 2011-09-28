/* Flod SidMon2 Replay 1.01
   2009/12/17
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.sidmon2 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class S2Song {
    public var title:String;
    public var version:int;

    internal var length:int;
    internal var speed:int;
    internal var dummy:S2Sample;

    internal var steps:Vector.<S2Step>;
    internal var patterns:Vector.<S2Command>;
    internal var instruments:Vector.<S2Instrument>;
    internal var samples:Vector.<S2Sample>;
    internal var waves:Vector.<int>;
    internal var arpeggios:Vector.<int>;
    internal var vibratos:Vector.<int>;

    internal function initialize(stream:ByteArray, amiga:Amiga):int {
      var com:S2Command, i:int, instr:S2Instrument, j:int, len:int, patternsPtr:Vector.<int>, pos:int, pointer:int, sample:S2Sample, step:S2Step, totPatterns:int, value:int;
      stream.endian = "bigEndian";
      stream.position = 0;
      amiga.reset();

      stream.readUnsignedShort();
      length = stream.readUnsignedByte();
      speed  = stream.readUnsignedByte();

      samples = new Vector.<S2Sample>(stream.readUnsignedShort() >> 6, true);

      stream.position = 14;
      len = stream.readUnsignedInt();
      steps = new Vector.<S2Step>(len, true);
      stream.position = 90;

      for (i = 0; i < len; ++i) {
        step = new S2Step();
        step.pattern = stream.readUnsignedByte();
        if (step.pattern > totPatterns) totPatterns = step.pattern;
        steps[i] = step;
      }

      for (i = 0; i < len; ++i) {
        step = steps[i];
        step.transpose = stream.readByte();
      }

      for (i = 0; i < len; ++i) {
        step = steps[i];
        step.soundTranspose = stream.readByte();
      }

      pointer = stream.position;
      stream.position = 26;
      len = stream.readUnsignedInt() >> 5;
      instruments = new Vector.<S2Instrument>(++len, true);
      stream.position = pointer;

      instruments[0] = new S2Instrument();

      for (i = 1; i < len; ++i) {
        instr = new S2Instrument();
        instr.wave           = stream.readUnsignedByte() << 4;
        instr.waveLength     = stream.readUnsignedByte();
        instr.waveSpeed      = stream.readUnsignedByte();
        instr.waveDelay      = stream.readUnsignedByte();
        instr.arpeggio       = stream.readUnsignedByte() << 4;
        instr.arpeggioLength = stream.readUnsignedByte();
        instr.arpeggioSpeed  = stream.readUnsignedByte();
        instr.arpeggioDelay  = stream.readUnsignedByte();
        instr.vibrato        = stream.readUnsignedByte() << 4;
        instr.vibratoLength  = stream.readUnsignedByte();
        instr.vibratoSpeed   = stream.readUnsignedByte();
        instr.vibratoDelay   = stream.readUnsignedByte();
        instr.pitchbend      = stream.readByte();
        instr.pitchbendDelay = stream.readUnsignedByte();
        stream.readByte();
        stream.readByte();
        instr.attackMax      = stream.readUnsignedByte();
        instr.attackSpeed    = stream.readUnsignedByte();
        instr.decayMin       = stream.readUnsignedByte();
        instr.decaySpeed     = stream.readUnsignedByte();
        instr.sustain        = stream.readUnsignedByte();
        instr.releaseMin     = stream.readUnsignedByte();
        instr.releaseSpeed   = stream.readUnsignedByte();
        instruments[i] = instr;
        stream.position += 9;
      }

      pointer = stream.position;
      stream.position = 30;
      len = stream.readUnsignedInt();
      waves = new Vector.<int>(len, true);
      stream.position = pointer;

      for (i = 0; i < len; ++i) waves[i] = stream.readUnsignedByte();

      pointer = stream.position;
      stream.position = 34;
      len = stream.readUnsignedInt();
      arpeggios = new Vector.<int>(len, true);
      stream.position = pointer;

      for (i = 0; i < len; ++i) arpeggios[i] = stream.readByte();

      pointer = stream.position;
      stream.position = 38;
      len = stream.readUnsignedInt();
      vibratos = new Vector.<int>(len, true);
      stream.position = pointer;

      for (i = 0; i < len; ++i) vibratos[i] = stream.readByte();

      len = samples.length;

      for (i = 0; i < len; ++i) {
        sample = new S2Sample();
        sample.pointer      = stream.readUnsignedInt();
        sample.length       = stream.readUnsignedShort() << 1;
        sample.loopStart    = stream.readUnsignedShort() << 1;
        sample.repeatLen    = stream.readUnsignedShort() << 1;
        sample.negStart     = stream.readUnsignedShort() << 1;
        sample.negLength    = stream.readUnsignedShort() << 1;
        sample.negSpeed     = stream.readUnsignedShort();
        sample.negDirection = stream.readUnsignedShort();
        sample.negOffset    = stream.readShort();
        sample.negStep      = stream.readUnsignedInt();
        sample.negCounter   = stream.readUnsignedShort();
        stream.position += 6;
        sample.name = stream.readMultiByte(32, Amiga.ENCODING);
        samples[i] = sample;
      }

      len = ++totPatterns;
      patternsPtr = new Vector.<int>(++totPatterns, true);
      for (i = 0; i < len; ++i) patternsPtr[i] = stream.readUnsignedShort();

      pointer = stream.position;
      stream.position = 50;
      len = stream.readUnsignedInt();
      patterns = new Vector.<S2Command>();
      stream.position = pointer;
      j = 1;

      for (i = 0; i < len; ++i) {
        com = new S2Command();
        value = stream.readByte();

        if (value == 0) {
          com.fx = stream.readByte();
          com.info = stream.readUnsignedByte();
          i += 2;
        } else if (value < 0) {
          com.timer = ~value;
        } else if (value < 112) {
          com.note = value;
          value = stream.readByte();
          i++;

          if (value < 0) {
            com.timer = ~value;
          } else if (value < 112) {
            com.instrument = value;
            value = stream.readByte();
            i++;

            if (value < 0) {
              com.timer = ~value;
            } else {
              com.fx = value;
              com.info = stream.readUnsignedByte();
              i++;
            }
          } else {
            com.fx = value;
            com.info = stream.readUnsignedByte();
            i++;
          }
        } else {
          com.fx = value;
          com.info = stream.readUnsignedByte();
          i++;
        }

        patterns[pos++] = com;

        if ((pointer + patternsPtr[j]) == stream.position)
          patternsPtr[j++] = pos;
      }

      patternsPtr[j] = patterns.length;
      patterns.fixed = true;

      if ((stream.position & 1) != 0) stream.position++;
      len = samples.length;

      for (i = 0; i < len; ++i) {
        sample = samples[i];
        sample.pointer   = amiga.store(stream, sample.length);
        sample.loopPtr   = sample.pointer + sample.loopStart;
        sample.negStart += sample.pointer;
      }

      len = steps.length;

      for (i = 0; i < len; ++i) {
        step = steps[i];
        step.pattern = patternsPtr[step.pattern];
      }

      dummy = new S2Sample();

      length++;
      stream.clear();
      return 1;
    }
  }
}