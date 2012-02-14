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

  public class NumericLabel extends Label {
    protected var m_hex:Boolean;
    protected var m_padding:int;
    protected var m_signed:Boolean;
    protected var m_value:int;

    public function NumericLabel(container:DisplayObjectContainer = null, x:Number = 0, y:Number = 0, value:int = 0, padding:int = 2, hex:Boolean = false) {
      super(container, x, y);
      m_hex = hex;
      m_padding = padding;
      m_value = value;
      invalidate(Invalidate.DATA);
    }

    public function get hex():Boolean { return m_hex; }
    public function set hex(val:Boolean):void {
      if (val == m_hex) return;
      m_hex = val;
      invalidate(Invalidate.DATA);
    }

    public function get padding():int { return m_padding; }
    public function set padding(val:int):void {
      if (val == m_padding || m_padding > 10) return;
      m_padding = val;
      invalidate(Invalidate.DATA);
    }

    public function get signed():Boolean { return m_signed; }
    public function set signed(val:Boolean):void {
      if (val == m_signed) return;
      m_signed = val;
      invalidate(Invalidate.DATA);
    }

    override public function set text(val:String):void {}

    public function get value():int { return m_value; }
    public function set value(val:int):void {
      if (val == m_value) return;
      m_value = val;
      invalidate(Invalidate.DATA);
    }

    override protected function draw():void {
      if (isInvalid(Invalidate.DATA)) {
        var string:String = m_hex ? m_value.toString(16).toUpperCase() : m_value.toString();

        if (m_padding > 1) {
          string = "0000000000" + string;
          string = string.substr(-m_padding);
        }
        if (m_value != 0) {
          if (m_value < 0) string = "-"+ string;
            else if (m_signed) string = "+"+ string;
        }
        super.text = string;
      }
      super.draw();
    }
  }
}