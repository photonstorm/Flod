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
  import neoart.flod.*;

  public class Meters extends Sprite {
    private var masks:Vector.<Shape>;

    public function Meters(container:DisplayObjectContainer) {
      x = 58; y = 263;
      initialize();
      container.addChild(this);
    }

    public function reset():void {
      for (var i:int = 0; i < 8; ++i)
        masks[i].height = 0;
    }

    public function set(data:ModData):void {
      var h:int, i:int, j:int;

      for (i = 0; i < 4; ++i) {
        if (data.periods[i] == 0) {
          masks[i].height -= 2;
          masks[i + 4].height -= 2;
        } else {
          h = data.volumes[i] * 188;
          if ((h & 1) != 0) h++;
          masks[i].height = h;
          j = i + 4;
          h = data.volumes[j] * 188;
          if ((h & 1) != 0) h++;
          masks[j].height = h;
        }
      }
    }

    public function update():void {
      for (var i:int = 0; i < 8; ++i)
        masks[i].height -= 2;
    }

    private function initialize():void {
      var bmp:Bitmap, cx:int, cy:int, i:int, meter:BitmapData, shp:Shape;
      meter = new VolumeMeter(0, 0);
      masks = new Vector.<Shape>(8, true);

      for (i = 0; i < 8; ++i) {
        shp = new Shape();
        shp.graphics.beginFill(0xff00ff);
        shp.graphics.drawRect(0, 0, meter.width, meter.height);
        shp.graphics.endFill();
        shp.rotation = 180;
        masks[i] = shp;

        if (i == 4) {
          cx = 0;
          cy = 112;
        }
        bmp = new Bitmap(meter);
        bmp.mask = shp;
        shp.x = cx + shp.width;
        bmp.x = cx;

        cx += 129;
        shp.y = cy + shp.height;
        bmp.y = cy;

        addChild(bmp);
        shp.height = 0;
        addChild(shp);
      }
    }
  }
}