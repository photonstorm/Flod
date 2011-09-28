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

  public final class BPVoice {
    internal var enabled:int;
    internal var restart:int;
    internal var note:int;
    internal var period:int;
    internal var sample:int;
    internal var samplePtr:int;
    internal var sampleLen:int;
    internal var synth:int;
    internal var synthPtr:int;
    internal var arpeggio:int;
    internal var autoArpeggio:int;
    internal var autoSlide:int;
    internal var vibrato:int;
    internal var volume:int;
    internal var volumeDef:int;
    internal var adsrControl:int;
    internal var adsrPtr:int;
    internal var adsrCnt:int;
    internal var lfoControl:int;
    internal var lfoPtr:int;
    internal var lfoCnt:int;
    internal var egControl:int;
    internal var egPtr:int;
    internal var egCnt:int;
    internal var egValue:int;
    internal var fxControl:int;
    internal var fxCnt:int;
    internal var modControl:int;
    internal var modPtr:int;
    internal var modCnt:int;

    internal function initialize():void {
      enabled      = 0;
      restart      = 0;
      note         = 0;
      period       = 0;
      sample       = 0;
      samplePtr    = 0;
      sampleLen    = 2;
      synth        = 0;
      synthPtr     = -1;
      arpeggio     = 0;
      autoArpeggio = 0;
      autoSlide    = 0;
      vibrato      = 0;
      volume       = 0;
      volumeDef    = 0;
      adsrControl  = 0;
      adsrPtr      = 0;
      adsrCnt      = 0;
      lfoControl   = 0;
      lfoPtr       = 0;
      lfoCnt       = 0;
      egControl    = 0;
      egPtr        = 0;
      egCnt        = 0;
      egValue      = 0;
      fxControl    = 0;
      fxCnt        = 0;
      modControl   = 0;
      modPtr       = 0;
      modCnt       = 0;
    }
  }
}