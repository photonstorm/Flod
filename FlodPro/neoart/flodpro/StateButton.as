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

  public class StateButton extends Button {
    protected var m_index:int;
    protected var m_labels:Vector.<String>;

    public function StateButton(container:DisplayObjectContainer = null, x:Number = 0, y:Number = 0, w:Number = 47, h:Number = 21) {
      super(container, x, y, "", w, h);
    }

    public function get captions():Array { return m_labels as Array; }
    public function set captions(val:Array):void {
      if (val.length == 0) return;
      m_labels = Vector.<String>(val);
      m_caption.text = m_labels[0];
      m_index = 0;
      invalidate(Invalidate.DATA);
    }

    public function get state():int { return m_index; }
    public function set state(val:int):void {
      if (val >= m_labels.length) val = m_labels.length;
      m_caption.text = m_labels[val];
      m_index = val;
      invalidate(Invalidate.DATA);
    }

    override protected function initialize():void {
      super.initialize();
      m_labels = new Vector.<String>;
    }

    override protected function draw():void {
      super.draw();
      if (!m_enabled) return;
      if (m_state == Control.HOVER || m_state == Control.HOVER_PRESSED) {
        var g:Graphics = graphics, cy:int = 2, i:int, len:int = m_labels.length;

        for (i = 0; i < len; ++i) {
          g.beginFill(i == m_index ? Theme.BUTTON_STATE_ON : Theme.BUTTON_STATE_OFF);
          g.drawRect(2, cy, 3, 3);
          g.endFill();
          cy += 4;
        }
      }
    }

    override protected function mouseDownHandler(e:MouseEvent):void {
      super.mouseDownHandler(e);
      if (++m_index >= m_labels.length) m_index = 0;
      m_caption.text = m_labels[m_index];
    }
  }
}