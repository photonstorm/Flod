/* FlodPro Custom Events
   2009/08/15
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flodpro {
  import flash.events.*;

  public class SliderEvent extends Event {
    public static const CHANGE:String        = "change";
    public static const THUMB_DRAG:String    = "thumbDrag";
    public static const THUMB_PRESS:String   = "thumbPress";
    public static const THUMB_RELEASE:String = "thumbRelease";

    public var value:Number;

    public function SliderEvent(type:String, value:Number, bubbles:Boolean = false, cancelable:Boolean = false) {
      this.value = value;
      super(type, bubbles, cancelable);
    }

    override public function toString():String {
      return formatToString("SliderEvent", "type", "value", "bubbles", "cancelable");
    }

    override public function clone():Event {
      return new SliderEvent(type, value, bubbles, cancelable);
    }
  }
}