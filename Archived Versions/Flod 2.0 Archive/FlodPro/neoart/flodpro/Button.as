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
  import flash.utils.*;

  public class Button extends Control {
    protected var m_autoRepeat:Boolean;
    protected var m_caption:Label;
    protected var m_captionPos:int;
    protected var m_timer:Timer;

    public function Button(container:DisplayObjectContainer = null, x:Number = 0, y:Number = 0, caption:String = "", w:Number = 94, h:Number = 21) {
      super(container, x, y);
      m_caption.text = caption;
      enabled = false;
      resize(w, h);
    }

    public function get autoRepeat():Boolean { return m_autoRepeat; }
    public function set autoRepeat(val:Boolean):void {
      if (val == m_autoRepeat) return;
      m_autoRepeat = val;
      if (val) {
        m_timer = new Timer(240, 1);
        m_timer.addEventListener(TimerEvent.TIMER, timerHandler);
      } else {
        m_timer.removeEventListener(TimerEvent.TIMER, timerHandler);
        m_timer = null;
      }
    }

    public function get caption():String { return m_caption.text; }
    public function set caption(val:String):void {
      m_caption.text = val;
    }

    override public function set enabled(val:Boolean):void {
      super.enabled = val;
      m_caption.enabled = val;
    }

    override public function resize(w:Number, h:Number):void {
      super.resize(w, h);
      m_caption.resize(w, m_caption.height);
      m_captionPos = (m_height - m_caption.height) >> 1;
      m_caption.y = m_captionPos;
    }

    override protected function initialize():void {
      super.initialize();
      m_caption = new Label(this);
      m_caption.autoSize = false;
      m_caption.align = "center";
      m_caption.color = Theme.LABEL_BUTTON;

      addEventListener(MouseEvent.ROLL_OVER, rollHandler);
      addEventListener(MouseEvent.ROLL_OUT, rollHandler);
      addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    }

    override protected function draw():void {
      if (isInvalid(Invalidate.SIZE, Invalidate.STATE)) {
        var g:Graphics = graphics, h:int = m_height - 2, w:int = m_width - 1;
        g.clear();
        g.beginFill(Theme.BUTTON[m_state][0]);
        g.drawRect(0, 0, w, 1);
        g.drawRect(0, 1, 1, h);
        g.beginFill(Theme.BUTTON[m_state][1]);
        g.drawRect(1, h + 1, w, 1);
        g.drawRect(w, 1, 1, h);
        g.beginFill(Theme.BUTTON[m_state][2]);
        g.drawRect(1, 1, w - 1, h);
        g.endFill();

        if (m_state == Control.HOVER_PRESSED) m_caption.offset(1, 1);
          else m_caption.move(0, m_captionPos);
      }
      super.draw();
    }

    protected function mouseDownHandler(e:MouseEvent):void {
      stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
      m_state = Control.HOVER_PRESSED;
      invalidate(Invalidate.STATE);
      if (m_autoRepeat) m_timer.start();
    }

    protected function mouseUpHandler(e:MouseEvent):void {
      stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
      if (m_autoRepeat) endPress();
      m_state = (e.target == this) ? Control.HOVER : Control.NORMAL;
      invalidate(Invalidate.STATE);
    }

    protected function rollHandler(e:MouseEvent):void {
      if (m_autoRepeat) endPress();
      if (m_enabled) {
        m_state = (e.type == MouseEvent.ROLL_OUT) ? Control.NORMAL : Control.HOVER;
        invalidate(Invalidate.STATE);
      }
    }

    private function timerHandler(e:TimerEvent):void {
      dispatchEvent(new MouseEvent(MouseEvent.CLICK));
      m_timer.reset();
      m_timer.delay = 80;
      m_timer.start();
    }

    private function endPress():void {
      m_timer.reset();
      m_timer.delay = 240;
    }
  }
}