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

  public final class D2Voice {
    internal var trackPtr:int;
    internal var trackPos:int;
    internal var trackLen:int;
    internal var patternPos:int;
    internal var restart:int;
    internal var step:D2Step;
    internal var com:D2Command;
    internal var sample:D2Sample;
    internal var note:int;
    internal var period:int;
    internal var finalPeriod:int;
    internal var bendrate:int;
    internal var portamento:int;
    internal var arpeggioPtr:int;
    internal var arpeggioStep:int;
    internal var vibratoCnt:int;
    internal var vibratoDir:int;
    internal var vibratoPeriod:int;
    internal var vibratoStep:int;
    internal var vibratoSustain:int;
    internal var volume:int;
    internal var volumeMax:int;
    internal var volumeStep:int;
    internal var volumeSustain:int;
    internal var waveCnt:int;
    internal var waveStep:int;

    internal function initialize():void {
      trackPtr       = 0;
      trackPos       = 0;
      trackLen       = 0;
      patternPos     = 0;
      restart        = 0;
      step           = null;
      com            = null;
      sample         = null;
      note           = 0;
      period         = 0;
      finalPeriod    = 0;
      bendrate       = 0;
      portamento     = 0;
      arpeggioPtr    = 0;
      arpeggioStep   = 0;
      vibratoCnt     = 0;
      vibratoDir     = 0;
      vibratoPeriod  = 0;
      vibratoStep    = 0;
      vibratoSustain = 0;
      volume         = 0;
      volumeMax      = 63;
      volumeStep     = 0;
      volumeSustain  = 0;
      waveCnt        = 0;
      waveStep       = 0;
    }
  }
}