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
  import flash.display.*;
  import flash.events.*;
  import flash.text.*;

  public class Spin extends Control {
    protected var m_caption:Label;
    protected var m_prev:Button;
    protected var m_next:Button;
    protected var m_value:NumericLabel;
    protected var m_min:int;
    protected var m_max:int = 31;

    public function Spin(container:DisplayObjectContainer = null, x:Number = 0, y:Number = 0, caption:String = "", padding:int = 2, hex:Boolean = false) {
      super(container, x, y);
      m_caption.text = caption;
      m_value.hex = hex;
      m_value.padding = padding;
    }

    override public function set enabled(val:Boolean):void {
      super.enabled = val;
      m_prev.enabled = val;
      m_next.enabled = val;
    }

    public function get min():int { return m_min; }
    public function set min(val:int):void {
      if (m_min >= m_max) return;
      m_min = val;
      if (m_value.value < val) m_value.value = val;
    }

    public function get max():int { return m_max; }
    public function set max(val:int):void {
      if (m_max <= m_min) return;
      m_max = val;
      if (m_value.value > val) m_value.value = val;
    }

    public function get value():int { return m_value.value; }
    public function set value(val:int):void {
      if (val == m_value.value) return;
      if (val < m_min) val = m_min;
        else if (val > m_max) val = m_max;
      m_value.value = val;
    }

    override protected function initialize():void {
      super.initialize();
      m_caption = new Label(this, 4);

      m_prev = new Button(this,  89, 0, "<", 19);
      m_next = new Button(this, 108, 0, ">", 19);
      m_prev.autoRepeat = true;
      m_next.autoRepeat = true;
      m_prev.addEventListener(MouseEvent.CLICK, prevHandler);
      m_next.addEventListener(MouseEvent.CLICK, nextHandler);

      m_value = new NumericLabel(this, 127, 0);
      m_value.autoSize = false;
      m_value.align = "right";
      m_value.color = Theme.LABEL_BUTTON;
      m_value.letterSpacing = 2;
      m_value.width = 59;
    }

    protected function prevHandler(e:MouseEvent):void {
      value--;
    }

    protected function nextHandler(e:MouseEvent):void {
      value++;
    }
  }
}