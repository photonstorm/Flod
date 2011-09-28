/* Flod Amiga Core 3.01
   2010/01/01
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.amiga {

  public final class AmigaFilter {
    public static const AUTOMATIC:int =  0;
    public static const FORCE_OFF:int = -1;
    public static const FORCE_ON: int =  1;

    public var active:int;
    public var forced:int = FORCE_OFF;

    private var l0:Number;
    private var l1:Number;
    private var l2:Number;
    private var l3:Number;
    private var l4:Number;
    private var r0:Number;
    private var r1:Number;
    private var r2:Number;
    private var r3:Number;
    private var r4:Number;

    internal function initialize():void {
      l0 = l1 = l2 = l3 = l4 = 0.0;
      r0 = r1 = r2 = r3 = r4 = 0.0;
    }

    internal function process(model:int, data:Sample):void {
      var d:Number, f:Number = 0.5213345843532200, p0:Number = 0.4860348337215757, p1:Number = 0.9314955486749749;

      if (!model) {
        d = 1 - p0;
        l0 = p0 * data.l + d * l0 + 1e-18 - 1e-18;
        r0 = p0 * data.r + d * r0 + 1e-18 - 1e-18;
        d = 1 - p1;
        l1 = p1 * l0 + d * l1;
        r1 = p1 * r0 + d * r1;
        data.l = l1;
        data.r = r1;
      }

      if ((active | forced) > 0) {
        d = 1 - f;
        l2 = f * data.l + d * l2;
        r2 = f * data.r + d * r2;
        l3 = f * l2 + d * l3;
        r3 = f * r2 + d * r3;
        l4 = f * l3 + d * l4;
        r4 = f * r3 + d * r4;
        data.l = l4;
        data.r = r4;
      }

      if (data.l > 1.0) data.l = 1.0;
        else if (data.l < -1.0) data.l = -1.0;

      if (data.r > 1.0) data.r = 1.0;
        else if (data.r < -1.0) data.r = -1.0;
    }
  }
}