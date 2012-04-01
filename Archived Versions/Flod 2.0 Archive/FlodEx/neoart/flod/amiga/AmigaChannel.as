/* Flod Amiga Core 3.0
   2009/12/10
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.amiga {

  public final class AmigaChannel {
    public var id:int;
    public var mute:int;
    public var pointer:int;
    public var length:int;
    public var period:int;

    internal var panning:Number = 1.0;

    internal var audena:int;
    internal var audloc:int;
    internal var audlen:int;
    internal var audvol:int;

    internal var timer:Number;
    internal var level:Number;
    internal var ldata:Number;
    internal var rdata:Number;

    public function AmigaChannel(id:int) {
      this.id = id;
      if ((++id & 2) == 0) panning = ~panning + 1;
      level = 1.0 * panning;
    }

    public function set enabled(value:int):void {
      if (value == audena) return;// || period < 50) return;
      audena = value;
      audloc = pointer;
      audlen = pointer + length;
      timer  = 1.0;
      ldata  = rdata = 0.0;
    }

    public function set volume(value:int):void {
      if (value < 0) value = 0; else if (value > 64) value = 64;
      audvol = value;
    }

    internal function initialize():void {
      pointer = length = period = 0;
      audena  = audloc = 0;
      audlen  = audvol = 0;
      timer   = 1.0;
      ldata   = rdata = 0.0;
    }
  }
}