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
  import flash.text.*;

  public class Label extends Control {
    protected var m_autoSize:Boolean = true;
    protected var m_color:int;
    protected var m_field:TextField;
    protected var m_format:TextFormat;
    protected var m_labelWidth:int;
    protected var m_labelHeight:int;

    public function Label(container:DisplayObjectContainer = null, x:Number = 0, y:Number = 0, text:String = "") {
      super(container, x, y);
      m_field.text = text;
    }

    public function get align():String { return m_format.align; }
    public function set align(val:String):void {
      if (val == m_format.align) return;
      m_format.align = val;
      draw();
    }

    public function get autoSize():Boolean { return m_autoSize; }
    public function set autoSize(val:Boolean):void {
      if (val == m_autoSize) return;
      m_autoSize = val;
      if (val) {
        m_field.autoSize = "left";
        draw();
      } else {
        m_field.autoSize = "none";
        resize(m_labelWidth, m_labelHeight);
      }
    }

    public function get color():int { return m_color; }
    public function set color(val:int):void {
      m_color = val;
      m_format.color = val;
      m_field.setTextFormat(m_format);
    }

    override public function set enabled(val:Boolean):void {
      super.enabled = val;
      mouseEnabled = false;
      m_format.color = val ? m_color : Theme.LABEL_DISABLED;
      m_field.setTextFormat(m_format);
    }

    public function get font():String { return m_format.font; }
    public function set font(val:String):void {
      m_format.font = val;
      m_field.setTextFormat(m_format);
    }

    public function get letterSpacing():int { return int(m_format.letterSpacing); }
    public function set letterSpacing(val:int):void {
      m_format.letterSpacing = val;
      m_field.setTextFormat(m_format);
    }

    public function get size():int { return int(m_format.size); }
    public function set size(val:int):void {
      m_format.size = val;
      m_field.setTextFormat(m_format);
    }

    public function get text():String { return m_field.text; }
    public function set text(val:String):void {
      m_field.text = val;
      m_field.setTextFormat(m_format);
    }

    public function formatDefault():void {
      m_format.font = Theme.FONT_DEFAULT;
      m_format.size = 14;
      m_format.letterSpacing = 1;
      m_field.sharpness = -220;
      m_field.thickness = -20;
      m_field.setTextFormat(m_format);
    }

    public function formatBold():void {
      m_format.font = Theme.FONT_BOLD;
      m_format.size = 14;
      m_format.letterSpacing = 3;
      m_field.sharpness = -150;
      m_field.thickness = 80;
      m_field.setTextFormat(m_format);
    }

    override public function resize(w:Number, h:Number):void {
      if (!m_autoSize) {
        m_labelWidth  = Math.round(w);
        m_labelHeight = Math.round(h);
      }
      super.resize(w, h);
    }

    override protected function initialize():void {
      super.initialize();
      mouseEnabled = false;
      m_field = new TextField();
      m_format = new TextFormat();
      m_format.color = Theme.LABEL_COLOR;
      formatDefault();

      m_field.antiAliasType = "advanced";
      m_field.autoSize = "left";
      m_field.defaultTextFormat = m_format;
      m_field.embedFonts = true;
      m_field.gridFitType = "subpixel";
      m_field.mouseEnabled = false;
      m_field.selectable = false;
      m_field.text = "FlodPro";
      m_field.wordWrap = false;

      m_labelWidth = m_field.width;
      m_width = m_labelWidth;
      m_labelHeight = m_field.height;
      m_height = m_labelHeight;
      addChild(m_field);
    }

    override protected function draw():void {
      m_field.setTextFormat(m_format);

      if (m_autoSize) {
        if (m_width  != Math.round(m_field.width) ||
            m_height != Math.round(m_field.height))
          resize(m_field.width, m_field.height);
      } else {
        m_field.width  = m_labelWidth;
        m_field.height = m_labelHeight;

        switch (m_format.align) {
          case "center":
            m_field.scrollH = m_field.maxScrollH >> 1;
            break;
          case "right":
            m_field.scrollH = m_field.maxScrollH;
            break;
          default:
            m_field.scrollH = 0;
            break;
        }
      }
      super.draw();
    }
  }
}