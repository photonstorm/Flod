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

  public class Slider extends Control {
    protected var m_interval:Number = 0.05;
    protected var m_min:Number = 0.0;
    protected var m_max:Number = 1.0;
    protected var m_value:Number = 1.0;
    protected var m_cursor:Shape;
    protected var m_thumb:Sprite;
    protected var m_step:Number;

    public function Slider(container:DisplayObjectContainer = null, x:Number = 0, y:Number = 0, w:Number = 181, h:Number = 17) {
      super(container, x, y);
      resize(w, h);
    }

    public function get interval():Number { return m_interval; }
    public function set interval(val:Number):void {
      if (val < 0 || isNaN(val)) return;
      m_interval = val;
      positionThumb();
    }

    public function get min():Number { return m_min; }
    public function set min(val:Number):void {
      if (val == m_min || val > m_max) return;
      m_min = val;
      if (m_value < val) this.value = val;
        else invalidate(Invalidate.SIZE);
    }

    public function get max():Number { return m_max; }
    public function set max(val:Number):void {
      if (val == m_max || val < m_min) return;
      m_max = val;
      if (m_value > val) this.value = val;
        else invalidate(Invalidate.SIZE);
    }

    public function get value():Number { return m_value; }
    public function set value(val:Number):void {
      if (val == m_value) return;
      setPosition(val);
    }

    override protected function initialize():void {
      super.initialize();
      m_cursor = new Shape();
      addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);

      m_thumb = new Sprite();
      m_thumb.addEventListener(MouseEvent.ROLL_OVER, rollHandler);
      m_thumb.addEventListener(MouseEvent.ROLL_OUT, rollHandler);
      addChild(m_thumb);
    }

    override protected function draw():void {
      var g:Graphics, h:int = m_height - 2;

      if (isInvalid(Invalidate.SIZE)) {
        update();
        g = m_cursor.graphics;
        g.beginFill(Theme.SLIDER_CURSOR_BORDER);
        g.drawRect(0, 0, 10, m_height);
        g.beginFill(Theme.SLIDER_CURSOR_FACE);
        g.drawRect(1, 1, 8, h);
        g.endFill();
      }

      if (isInvalid(Invalidate.DATA, Invalidate.SIZE, Invalidate.STATE, Invalidate.STYLE)) {
        g = graphics;
        g.clear();
        g.beginFill(0, 0);
        g.drawRect(0, 0, m_width, m_height);
        g.beginFill(Theme.SLIDER_TRACK_SELECTED);
        g.drawRect(0, m_height >> 1, m_thumb.x, 1);
        g.beginFill(Theme.SLIDER_TRACK_DEFAULT);
        g.drawRect(m_thumb.x + 1, m_height >> 1, (m_width - m_thumb.x - 1), 1);
        g.endFill();

        g = m_thumb.graphics;
        g.beginFill(Theme.BUTTON[m_state][0]);
        g.drawRect(0, 0, 9, 1);
        g.drawRect(0, 1, 1, h);
        g.beginFill(Theme.BUTTON[m_state][1]);
        g.drawRect(1, h + 1, 9, 1);
        g.drawRect(9, 1, 1, h);
        g.beginFill(Theme.BUTTON[m_state][2]);
        g.drawRect(1, 1, 8, h);
        g.endFill();
      }
      super.draw();
    }

    protected function getPrecision(val:Number):int {
      var text:String = val.toString();
      if (text.indexOf(".") < 0) return 0;
      return text.split(".").pop().length;
    }

    protected function update():void {
      m_step = (m_max - m_min) / (m_width - 10);
      positionThumb();
    }

    protected function calculatePosition(val:Number):void {
      val = ((val - 5) * m_step) + m_min;
      setPosition(val);
    }

    protected function setPosition(val:Number):void {
      var current:Number = m_value;

      if (m_interval != 0 || m_interval != 1) {
        var pow:Number = Math.pow(10, getPrecision(m_interval)),
           snap:Number = m_interval * pow,
        rounded:Number = Math.round(val * pow),
        snapped:Number = Math.round(rounded / snap) * snap;
        val = snapped / pow;
      }
      m_value = Math.max(m_min, Math.min(m_max, val));

      if (current != m_value) {
        dispatchEvent(new SliderEvent(SliderEvent.CHANGE, m_value));
        positionThumb();
      }
    }

    protected function positionThumb():void {
      var val:Number = m_value - m_min;
      m_cursor.x = Math.round(val / m_step);

      if (val != m_thumb.x) {
        if (!contains(m_cursor)) {
          m_thumb.x = m_cursor.x;
          invalidate(Invalidate.DATA);
        }
      }
    }

    protected function mouseDownHandler(e:MouseEvent):void {
      addChild(m_cursor);
      if (e.target == m_thumb) {
        stage.addEventListener(MouseEvent.MOUSE_MOVE, thumbDragHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, thumbReleaseHandler);
        dispatchEvent(new SliderEvent(SliderEvent.THUMB_PRESS, m_value));
      } else {
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        calculatePosition(mouseX);
      }
    }

    protected function mouseUpHandler(e:MouseEvent):void {
      stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
      removeChild(m_cursor);
      positionThumb();
    }

    protected function thumbDragHandler(e:MouseEvent):void {
      calculatePosition(mouseX);
      dispatchEvent(new SliderEvent(SliderEvent.THUMB_DRAG, m_value));
    }

    protected function thumbReleaseHandler(e:MouseEvent):void {
      stage.removeEventListener(MouseEvent.MOUSE_UP, thumbReleaseHandler);
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbDragHandler);
      removeChild(m_cursor);
      positionThumb();
      dispatchEvent(new SliderEvent(SliderEvent.THUMB_RELEASE, m_value));
    }

    protected function rollHandler(e:MouseEvent):void {
      m_state = (e.type == MouseEvent.ROLL_OUT) ? Control.NORMAL : Control.HOVER;
      invalidate(Invalidate.STATE);
    }
  }
}