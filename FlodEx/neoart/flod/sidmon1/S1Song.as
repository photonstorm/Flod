/* Flod SidMon1 Replay 1.0
   2009/12/10
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.sidmon1 {
  import flash.utils.*;
  import neoart.flod.amiga.*;

  public final class S1Song {
    public var title:String;
    public var version:int;

    internal var speed:int;
    internal var stepLen:int;
    internal var patternLen:int;
    internal var doFilters:int;
    internal var doReset:int;
    internal var mix1Source1:int;
    internal var mix1Source2:int;
    internal var mix1Dest:int;
    internal var mix1Speed:int;
    internal var mix2Source1:int;
    internal var mix2Source2:int;
    internal var mix2Dest:int;
    internal var mix2Speed:int;

    internal var steps:Vector.<S1Step>;
    internal var stepsPtr:Vector.<int>;
    internal var patterns:Vector.<S1Command>;
    internal var patternsPtr:Vector.<int>;
    internal var samples:Vector.<S1Sample>;
    internal var waveLists:Vector.<int>;

    private const SIDMON_0FFA:int = 0x0ffa;
    private const SIDMON_1170:int = 0x1170;
    private const SIDMON_11C6:int = 0x11c6;
    private const SIDMON_11DC:int = 0x11dc;
    private const SIDMON_11E0:int = 0x11e0;
    private const SIDMON_125A:int = 0x125a;
    private const SIDMON_1444:int = 0x1444;

    private const EMBEDDED:Vector.<int> = Vector.<int>([1166, 408, 908]);

    public function get tracker():String {
      return "SidMon1";
    }

    internal function initialize(stream:ByteArray, amiga:Amiga):int {
      var com:S1Command, data:int, i:int, j:int, headers:int, len:int, pointer:int, sample:S1Sample, start:int, step:S1Step, totInstruments:int, totPatterns:int, totSamples:int, totWaveforms:int;
      stream.endian = "bigEndian";
      stream.position = 0;
      amiga.reset();

      while (stream.bytesAvailable) {
        start = stream.readUnsignedShort();
        if (start != 0x41fa) continue;
        pointer = stream.readUnsignedShort();

        start = stream.readUnsignedShort();
        if (start != 0xd1e8) continue;
        start = stream.readUnsignedShort();

        if (start == 0xffd4) {
          if (pointer == 0x0fec) version = SIDMON_0FFA;
            else if (pointer == 0x1466) version = SIDMON_1444;
              else version = pointer;

          pointer += stream.position - 6;
          break;
        }
      }

      if (pointer == 0) return 0;

      stream.position = pointer - 44;
      stepsPtr = new Vector.<int>(4, true);
      start = stream.readUnsignedInt();

      for (i = 1; i < 4; ++i)
        stepsPtr[i] = (stream.readUnsignedInt() - start) / 6;

      stream.position = pointer - 8;
      start = stream.readUnsignedInt();
      len = stream.readUnsignedInt();
      if (len < start) len = stream.length - pointer;

      totPatterns = (len - start) >> 2;
      patternsPtr = new Vector.<int>(totPatterns);
      stream.position = pointer + start + 4;

      for (i = 1; i < totPatterns; ++i) {
        start = stream.readUnsignedInt() / 5;
        if (start == 0) {
          totPatterns = i;
          break;
        }
        patternsPtr[i] = start;
      }

      patternsPtr.length = totPatterns;
      patternsPtr.fixed  = true;

      stream.position = pointer - 44;
      start = stream.readUnsignedInt();
      stream.position = pointer - 28;
      len = (stream.readUnsignedInt() - start) / 6;

      steps = new Vector.<S1Step>(len, true);
      stream.position = pointer + start;

      for (i = 0; i < len; ++i) {
        step = new S1Step();
        step.pattern = stream.readUnsignedInt();
        if (step.pattern >= totPatterns) step.pattern = 0;
        stream.readByte();
        step.transpose = stream.readByte();
        if (step.transpose < -99 || step.transpose > 99) step.transpose = 0;
        steps[i] = step;
      }

      stream.position = pointer - 24;
      start = stream.readUnsignedInt();
      totWaveforms = stream.readUnsignedInt() - start;

      amiga.samples.length = 32;
      amiga.store(stream, totWaveforms, pointer + start);
      totWaveforms >>= 5;

      stream.position = pointer - 16;
      start = stream.readUnsignedInt();
      len = (stream.readUnsignedInt() - start) + 16;
      j = (totWaveforms + 2) << 4;

      waveLists = new Vector.<int>(len < j ? j : len, true);
      stream.position = pointer + start;
      i = 0;

      while (i < j) {
        waveLists[i++] = i >> 4;
        waveLists[i++] = 0xff;
        waveLists[i++] = 0xff;
        waveLists[i++] = 0x10;
        i += 12;
      }

      for (i = 16; i < len; ++i)
        waveLists[i] = stream.readUnsignedByte();

      stream.position = pointer - 20;
      stream.position = pointer + stream.readUnsignedInt();

      mix1Source1 = stream.readUnsignedInt();
      mix2Source1 = stream.readUnsignedInt();
      mix1Source2 = stream.readUnsignedInt();
      mix2Source2 = stream.readUnsignedInt();
      mix1Dest    = stream.readUnsignedInt();
      mix2Dest    = stream.readUnsignedInt();
      patternLen  = stream.readUnsignedInt();
      stepLen     = stream.readUnsignedInt();
      speed       = stream.readUnsignedInt();
      mix1Speed   = stream.readUnsignedInt();
      mix2Speed   = stream.readUnsignedInt();

      if (mix1Source1 > totWaveforms) mix1Source1 = 0;
      if (mix2Source1 > totWaveforms) mix2Source1 = 0;
      if (mix1Source2 > totWaveforms) mix1Source2 = 0;
      if (mix2Source2 > totWaveforms) mix2Source2 = 0;
      if (mix1Dest > totWaveforms) mix1Speed = 0;
      if (mix2Dest > totWaveforms) mix2Speed = 0;
      if (speed == 0) speed = 4;

      stream.position = pointer - 28;
      j = stream.readUnsignedInt();
      totInstruments = (stream.readUnsignedInt() - j) >> 5;
      if (totInstruments > 63) totInstruments = 63;
      len = totInstruments + 1;

      stream.position = pointer - 4;
      start = stream.readUnsignedInt();

      if (start == 1) {
        stream.position = 0x71c;
        start = stream.readUnsignedShort();

        if (start != 0x4dfa) {
          stream.position = 0x6fc;
          start = stream.readUnsignedShort();
          if (start != 0x4dfa) return 0;
        }

        stream.position += stream.readUnsignedShort();
        samples = new Vector.<S1Sample>(len + 3, true);

        for (i = 0; i < 3; ++i) {
          sample = new S1Sample();
          sample.waveform  = 16 + i;
          sample.length    = EMBEDDED[i];
          sample.pointer   = amiga.store(stream, sample.length);
          sample.loopStart = sample.loopPtr = 0;
          sample.repeatLen = 4;
          sample.volume    = 64;

          samples[int(len + i)] = sample;
          stream.position += sample.length;
        }
      } else {
        samples = new Vector.<S1Sample>(len, true);
        stream.position = pointer + start;
        data = stream.readUnsignedInt();
        totSamples = (data >> 5) + 15;
        headers = stream.position;
        data += headers;
      }

      sample = new S1Sample();
      sample.name = "flod";
      samples[0] = sample;
      stream.position = pointer + j;

      for (i = 1; i < len; ++i) {
        sample = new S1Sample();
        sample.waveform = stream.readUnsignedInt();
        for (j = 0; j < 16; ++j) sample.arpeggio[j] = stream.readUnsignedByte();

        sample.attackSpeed  = stream.readUnsignedByte();
        sample.attackMax    = stream.readUnsignedByte();
        sample.decaySpeed   = stream.readUnsignedByte();
        sample.decayMin     = stream.readUnsignedByte();
        sample.sustain      = stream.readUnsignedByte();
        stream.readByte();
        sample.releaseSpeed = stream.readUnsignedByte();
        sample.releaseMin   = stream.readUnsignedByte();
        sample.phaseShift   = stream.readUnsignedByte();
        sample.phaseSpeed   = stream.readUnsignedByte();
        sample.finetune     = stream.readUnsignedByte();
        sample.pitchfall    = stream.readByte();

        if (version == SIDMON_1444) {
          sample.pitchfall = sample.finetune;
          sample.finetune = 0;
        } else {
          if (sample.finetune > 15) sample.finetune = 0;
          sample.finetune *= 67;
        }

        if (sample.phaseShift > totWaveforms) {
          sample.phaseShift = 0;
          sample.phaseSpeed = 0;
        }

        if (sample.waveform > 15) {
          if ((totSamples > 15) && (sample.waveform > totSamples)) {
            sample.waveform = 0;
          } else {
            start = headers + ((sample.waveform - 16) << 5);
            if (start >= stream.length) continue;
            j = stream.position;

            stream.position  = start;
            sample.pointer   = stream.readUnsignedInt();
            sample.loopStart = stream.readUnsignedInt();
            sample.length    = stream.readUnsignedInt();
            sample.name      = stream.readMultiByte(20, Amiga.ENCODING);

            if (sample.loopStart == 0      ||
                sample.loopStart == 99999  ||
                sample.loopStart == 199999 ||
                sample.loopStart >= sample.length) {

              sample.loopStart = 0;
              sample.repeatLen = version == SIDMON_0FFA ? 2 : 4;
            } else {
              sample.repeatLen = sample.length - sample.loopStart;
              sample.loopStart -= sample.pointer;
            }

            sample.length -= sample.pointer;
            if (sample.length < (sample.loopStart + sample.repeatLen))
              sample.length = sample.loopStart + sample.repeatLen;

            sample.pointer = amiga.store(stream, sample.length, data + sample.pointer);
            if (sample.repeatLen < 6 || sample.loopStart == 0) sample.loopPtr = 0;
              else sample.loopPtr = sample.pointer + sample.loopStart;

            stream.position = j;
          }
        } else if (sample.waveform > totWaveforms) {
          sample.waveform = 0;
        }

        samples[i] = sample;
      }

      stream.position = pointer - 12;
      start = stream.readUnsignedInt();
      len = (stream.readUnsignedInt() - start) / 5;
      patterns = new Vector.<S1Command>(len, true);
      stream.position = pointer + start;

      for (i = 0; i < len; ++i) {
        com = new S1Command();
        com.note   = stream.readUnsignedByte();
        com.sample = stream.readUnsignedByte();
        com.info   = stream.readUnsignedByte();
        com.data   = stream.readUnsignedByte();
        com.timer  = stream.readUnsignedByte();

        if (version == SIDMON_1444) {
          if (com.note > 0 && com.note < 255) com.note += 469;
          if (com.info > 0 && com.info < 255) com.info += 469;
          if (com.sample > 59) com.sample = totInstruments + (com.sample - 60);
        } else if (com.sample > totInstruments) {
          com.sample = 0;
        }

        patterns[i] = com;
      }

      if (version == SIDMON_1170 || version == SIDMON_11C6 || version == SIDMON_1444) {
        if (version == SIDMON_1170) mix1Speed = mix2Speed = 0;
        doReset = doFilters = 0;
      } else {
        doReset = doFilters = 1;
      }

      stream.clear();
      return 1;
    }
  }
}