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

  public class ToggleButton extends Button {
    protected var m_captionDefault:String;
    protected var m_captionPressed:String;
    protected var m_pressed:Boolean;

    public function ToggleButton(container:DisplayObjectContainer = null, x:Number = 0, y:Number = 0, caption:String = "", w:Number = 47, h:Number = 21) {
      m_captionDefault = caption;
      m_captionPressed = caption;
      super(container, x, y, caption, w, h);
    }

    override public function set enabled(val:Boolean):void {
      super.enabled = val;
      if (val) {
        m_state = m_pressed ? Control.PRESSED : Control.NORMAL;
        invalidate(Invalidate.STATE);
      }
    }

    override public function get caption():String { return m_captionDefault; }
    override public function set caption(val:String):void {
      m_captionDefault = val;
      super.caption = val;
    }

    public function get captionPressed():String { return m_captionPressed; }
    public function set captionPressed(val:String):void {
      m_captionPressed = val;
      if (m_pressed) m_caption.text = val;
    }

    public function get pressed():Boolean { return m_pressed; }
    public function set pressed(val:Boolean):void {
      if (val == m_pressed) return;
      m_pressed = val;
      m_state = val ? Control.PRESSED : Control.NORMAL;
      invalidate(Invalidate.STATE);
    }

    override protected function draw():void {
      super.draw();
      if (!m_enabled) return;

      if (m_pressed) {
        m_caption.color = Theme.LABEL_COLOR;
        m_caption.text = m_captionPressed;
      } else {
        m_caption.color = Theme.LABEL_BUTTON;
        m_caption.text = m_captionDefault;
      }
    }

    override protected function mouseDownHandler(e:MouseEvent):void {
      m_pressed = Boolean(!m_pressed);
      super.mouseDownHandler(e);
    }

    override protected function mouseUpHandler(e:MouseEvent):void {
      stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
      m_state = m_pressed ? Control.PRESSED : Control.HOVER;
      invalidate(Invalidate.STATE);
    }

    override protected function rollHandler(e:MouseEvent):void {
      if (!m_pressed) super.rollHandler(e);
    }
  }
}