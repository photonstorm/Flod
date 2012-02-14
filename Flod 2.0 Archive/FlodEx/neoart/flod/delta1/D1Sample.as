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
  import neoart.flod.amiga.*;

  public final class D1Sample extends AmigaSample {
    internal var attackStep:int;
    internal var attackDelay:int;
    internal var decayStep:int;
    internal var decayDelay:int;
    internal var sustain:int;
    internal var releaseStep:int;
    internal var releaseDelay:int;
    internal var vibratoWait:int;
    internal var vibratoStep:int;
    internal var vibratoLength:int;
    internal var bendrate:int;
    internal var portamento:int;
    internal var arpeggio:Vector.<int>;
    internal var synth:int;
    internal var table:Vector.<int>;
    internal var tableDelay:int;

    public function D1Sample() {
      arpeggio = new Vector.<int>( 8, true);
      table    = new Vector.<int>(48, true);
    }
  }
}