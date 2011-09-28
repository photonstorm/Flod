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
  import flash.geom.*;
  import flash.text.*;

  public class Tip extends Control {
    protected var m_container:Sprite;
    protected var m_header:Label;
    protected var m_control:Control;
    protected var m_below:Boolean;
    protected var m_headerHeight:int = 21;
    protected var m_margin:int;

    public function Tip(container:DisplayObjectContainer = null, x:Number = 0, y:Number = 0, tip:String = "", control:Control = null) {
      m_control = control;
      m_control.y = m_headerHeight;
      super(container, x, y);
      m_header.text = tip;
      resize(m_control.width, m_control.height);
    }

    public function get align():String { return m_header.align; }
    public function set align(val:String):void {
      m_header.align = val;
      if (val == "left") m_header.x = 4;
    }

    public function get below():Boolean { return m_below; }
    public function set below(val:Boolean):void {
      if (val == m_below) return;
      if (val) {
        m_control.y = 0;
        m_container.y = m_control.height + m_margin;
      } else {
        m_control.y = m_headerHeight + m_margin;
        m_container.y = 0;
      }
      m_below = val;
      invalidate();
    }

    override public function set enabled(val:Boolean):void {
      super.enabled = val;
      m_control.enabled = val;
    }

    public function get headerHeight():int { return m_headerHeight; }
    public function set headerHeight(val:int):void {
      if (val == m_headerHeight) return;
      m_headerHeight = val;
      m_control.y = val + m_margin;
      invalidate();
    }

    public function get margin():int { return m_margin; }
    public function set margin(val:int):void {
      if (val == m_margin) return;
      m_margin = val;
      m_control.y = m_headerHeight + val;
      invalidate();
    }

    public function get tip():String { return m_header.text; }
    public function set tip(val:String):void {
      m_header.text = val;
    }

    override public function resize(w:Number, h:Number):void {
      m_container.x = (m_control.width - Math.round(w)) >> 1;
      super.resize(w, h);
    }

    override protected function initialize():void {
      super.initialize();
      m_header = new Label(this);
      m_header.autoSize = false;
      m_header.align = "center";
      m_header.color = Theme.LABEL_BUTTON;
      m_header.letterSpacing = 0;
      m_header.width = m_control.width;

      m_container = new Sprite();
      m_container.alpha = 0.9;
      m_container.mouseEnabled = false;
      m_container.tabEnabled = false;
      m_container.visible = false;
      m_container.addChild(m_header);

      addChild(m_container);
      addChild(m_control);
      addEventListener(MouseEvent.ROLL_OVER, rollHandler);
      addEventListener(MouseEvent.ROLL_OUT, rollHandler);

      if (m_control is Slider)
        m_control.addEventListener(SliderEvent.THUMB_DRAG, thumbDragHandler);
    }

    override protected function draw():void {
      if (isInvalid(Invalidate.SIZE)) {
        var g:Graphics = m_container.graphics, h:int = m_headerHeight - 2, w:int = m_width - 1;
        g.clear();
        g.beginFill(0, 0);
        if (m_below) g.drawRect(0, -m_margin, m_width, m_margin);
          else g.drawRect(0, m_headerHeight, m_width, m_margin);

        g.beginFill(Theme.BUTTON[1][0]);
        g.drawRect(0, 0, w, 1);
        g.drawRect(0, 1, 1, h);
        g.beginFill(Theme.BUTTON[1][1]);
        g.drawRect(1, h + 1, w, 1);
        g.drawRect(w, 1, 1, h);
        g.beginFill(Theme.BUTTON[1][2]);
        g.drawRect(1, 1, w - 1, h);
        g.endFill();
      }
    }

    protected function rollHandler(e:MouseEvent):void {
      m_container.visible = (e.type == MouseEvent.ROLL_OUT) ? false : true;
    }

    protected function thumbDragHandler(e:SliderEvent):void {
      removeEventListener(MouseEvent.ROLL_OUT, rollHandler);
      m_control.addEventListener(SliderEvent.THUMB_RELEASE, thumbReleaseHandler);
    }

    protected function thumbReleaseHandler(e:SliderEvent):void {
      var p:Point = new Point(mouseX, mouseY);
      m_control.removeEventListener(SliderEvent.THUMB_RELEASE, thumbReleaseHandler);
      if (getObjectsUnderPoint(localToGlobal(p)).length == 0) m_container.visible = false;
      addEventListener(MouseEvent.ROLL_OUT, rollHandler);
    }
  }
}