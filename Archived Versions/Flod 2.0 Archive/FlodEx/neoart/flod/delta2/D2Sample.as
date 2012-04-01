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
  import neoart.flod.amiga.*;

  public final class D2Sample extends AmigaSample {
    internal var synth:int;
    internal var bendrate:int;
    internal var number:int;
    internal var vibratos:Vector.<int>;
    internal var volumes:Vector.<int>;
    internal var waves:Vector.<int>;

    public function D2Sample() {
      vibratos = new Vector.<int>(15, true);
      volumes  = new Vector.<int>(15, true);
      waves    = new Vector.<int>(48, true);
    }
  }
}