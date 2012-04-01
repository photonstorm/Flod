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

  public final class S1Voice {
    internal var step:int;
    internal var pattern:int;
    internal var sample:int;
    internal var samplePtr:int;
    internal var sampleLen:int;
    internal var period:int;
    internal var note:int;
    internal var noteTimer:int;
    internal var volume:int;
    internal var bendTo:int;
    internal var bendSpeed:int;
    internal var pitchCnt:int;
    internal var pitchfallCnt:int;
    internal var arpeggioCnt:int;
    internal var envelopeCnt:int;
    internal var sustainCnt:int;
    internal var phaseTimer:int;
    internal var phaseSpeed:int;
    internal var waveStep:int;
    internal var waveList:int;
    internal var waveTimer:int;
    internal var waitCnt:int;

    internal function initialize() {
      samplePtr    = -1;
      sampleLen    = 0;
      period       = 0x9999;
      note         = 0;
      noteTimer    = 0;
      volume       = 0;
      bendTo       = 0;
      bendSpeed    = 0;
      pitchCnt     = 0;
      pitchfallCnt = 0;
      arpeggioCnt  = 0;
      envelopeCnt  = 8;
      sustainCnt   = 0;
      phaseTimer   = 0;
      phaseSpeed   = 0;
      waveStep     = 0;
      waveList     = 0;
      waveTimer    = 0;
      waitCnt      = 0;
    }
  }
}