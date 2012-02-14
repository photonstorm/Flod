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
  import neoart.flod.amiga.*;

  public final class S1Sample extends AmigaSample {
    internal var waveform:int;
    internal var arpeggio:Vector.<int>;
    internal var attackSpeed:int;
    internal var attackMax:int;
    internal var decaySpeed:int;
    internal var decayMin:int;
    internal var sustain:int;
    internal var releaseSpeed:int;
    internal var releaseMin:int;
    internal var phaseShift:int;
    internal var phaseSpeed:int;
    internal var finetune:int;
    internal var pitchfall:int;

    public function S1Sample() {
      arpeggio = new Vector.<int>(16, true);
    }
  }
}