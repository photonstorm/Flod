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
  import neoart.flod.amiga.*;

  public final class BPSample extends AmigaSample {
    internal var synth:int;
    internal var waveTable:int;
    internal var adsrControl:int;
    internal var adsrTable:int;
    internal var adsrLength:int;
    internal var adsrSpeed:int;
    internal var lfoControl:int;
    internal var lfoTable:int;
    internal var lfoDepth:int;
    internal var lfoLength:int;
    internal var lfoDelay:int;
    internal var lfoSpeed:int;
    internal var egControl:int;
    internal var egTable:int;
    internal var egLength:int;
    internal var egDelay:int;
    internal var egSpeed:int;
    internal var fxControl:int;
    internal var fxSpeed:int;
    internal var fxDelay:int;
    internal var modControl:int;
    internal var modTable:int;
    internal var modSpeed:int;
    internal var modDelay:int;
    internal var modLength:int;
  }
}