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

  public final class D1Voice {
    internal var stepCnt:int;
    internal var step:D1Step;
    internal var patternCnt:int;
    internal var com:D1Command;
    internal var sample:D1Sample;
    internal var tableCnt:int;
    internal var tablePos:int;
    internal var note:int;
    internal var period:int;
    internal var arpeggioCnt:int;
    internal var bendrate:int;
    internal var vibratoCnt:int;
    internal var vibratoPos:int;
    internal var vibratoCompare:int;
    internal var vibratoPeriod:int;
    internal var volume:int;
    internal var attackCnt:int;
    internal var decayCnt:int;
    internal var sustain:int;
    internal var releaseCnt:int;
    internal var status:int;
    internal var timer:int;

    internal function initialize():void {
      stepCnt        = 0;
      step           = null;
      patternCnt     = 0;
      com            = null;
      sample         = null;
      tableCnt       = 0;
      tablePos       = 0;
      note           = 0;
      period         = 0;
      arpeggioCnt    = 0;
      bendrate       = 0;
      vibratoCnt     = 0;
      vibratoPos     = 0;
      vibratoCompare = 0;
      vibratoPeriod  = 0;
      volume         = 0;
      attackCnt      = 0;
      decayCnt       = 0;
      sustain        = 1;
      releaseCnt     = 0;
      status         = 0;
      timer          = 1;
    }
  }
}