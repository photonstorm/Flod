/* FlodPro Base Custom Control
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

  public class Control extends Sprite {
    public static const NORMAL:       int = 0;
    public static const HOVER:        int = 1;
    public static const HOVER_PRESSED:int = 2;
    public static const PRESSED:      int = 3;
    public static const DISABLED:     int = 4;

    protected var m_enabled:Boolean = true;
    protected var m_flags:Invalidate;
    protected var m_state:int;
    protected var m_width:int;
    protected var m_height:int;

    public function Control(container:DisplayObjectContainer, x:Number, y:Number) {
      move(x, y);
      if (container) container.addChild(this);
      initialize();
      m_width  = super.width;
      m_height = super.height;
    }

    public function get enabled():Boolean { return m_enabled; }
    public function set enabled(val:Boolean):void {
      if (val == m_enabled) return;
      m_enabled = val;
      m_state = val ? NORMAL : DISABLED;
      mouseEnabled = val;
      invalidate(Invalidate.STATE);
    }

    override public function get width():Number { return m_width; }
    override public function set width(val:Number):void {
      if (val == m_width) return;
      resize(val, m_height);
    }

    override public function get height():Number { return m_height; }
    override public function set height(val:Number):void {
      if (val == m_height) return;
      resize(m_width, val);
    }

    override public function set x(val:Number):void {
      move(val, super.y);
    }

    override public function set y(val:Number):void {
      move(super.x, val);
    }

    public function move(x:Number, y:Number):void {
      super.x = Math.round(x);
      super.y = Math.round(y);
    }

    public function offset(x:Number, y:Number):void {
      move(super.x + x, super.y + y);
    }

    public function resize(w:Number, h:Number):void {
      m_width  = Math.round(w);
      m_height = Math.round(h);
      invalidate(Invalidate.SIZE);
    }

    protected function initialize():void {
      tabEnabled = false;
      m_flags = new Invalidate();
    }

    protected function draw():void {
      m_flags.reset();
    }

    protected function invalidate(index:int = Invalidate.ALL):void {
      m_flags.invalidate(index);
      addEventListener(Event.ENTER_FRAME, invalidateHandler);
    }

    protected function isInvalid(index:int, ...indexes:Array):Boolean {
      if (m_flags.isInvalid(index) || m_flags.isInvalid(Invalidate.ALL)) return true;
      while (indexes.length > 0)
        if (m_flags.isInvalid(indexes.pop())) return true;
      return false;
    }

    private function invalidateHandler(e:Event):void {
      removeEventListener(Event.ENTER_FRAME, invalidateHandler);
      draw();
    }
  }
}