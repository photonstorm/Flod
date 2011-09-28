/* Flod SidMon2 Replay 1.0
   2009/12/17
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.sidmon2 {

  public final class S2Voice {
    internal var dma:int;
    internal var step:S2Step;
    internal var pattern:int;
    internal var com:S2Command;
    internal var instrument:int;
    internal var instr:S2Instrument;
    internal var sample:S2Sample;
    internal var period:int;
    internal var volume:int;
    internal var note:int;
    internal var original:int;
    internal var adsrStep:int;
    internal var sustainCnt:int;
    internal var pitchbend:int;
    internal var pitchbendCnt:int;
    internal var noteSlideTo:int;
    internal var noteSlideSpeed:int;
    internal var waveCnt:int;
    internal var waveStep:int;
    internal var arpeggioCnt:int;
    internal var arpeggioStep:int;
    internal var vibratoCnt:int;
    internal var vibratoStep:int;
    internal var timer:int;

    internal function initialize():void {
      dma            = 0;
      step           = null;
      pattern        = 0;
      com            = null;
      instrument     = 0;
      instr          = null;
      sample         = null;
      period         = 0;
      volume         = 0;
      note           = 0;
      original       = 0;
      adsrStep       = 0;
      sustainCnt     = 0;
      pitchbend      = 0;
      pitchbendCnt   = 0;
      noteSlideTo    = 0;
      noteSlideSpeed = 0;
      waveCnt        = 0;
      waveStep       = 0;
      arpeggioCnt    = 0;
      arpeggioStep   = 0;
      vibratoCnt     = 0;
      vibratoStep    = 0;
      timer          = 0;
    }
  }
}