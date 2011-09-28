/* FlodPro Custom Controls
   2009/08/15
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flodpro {

  public class Invalidate {
    public static const ALL:     int = 0;
    public static const DATA:    int = 1;
    public static const SIZE:    int = 2;
    public static const STATE:   int = 3;
    public static const STYLE:   int = 4;

    private var flags:int;

    public function isInvalid(index:int):Boolean {
      var bit:int = index & 31;
      return Boolean((flags & (1 << bit)) >> bit);
    }

    public function reset():void {
      flags = 0;
    }

    public function invalidate(index:int):void {
      flags |= (1 << (index & 31));
    }

    public function validate(index:int):void {
      flags &= ~(1 << (index & 31));
    }
  }
}