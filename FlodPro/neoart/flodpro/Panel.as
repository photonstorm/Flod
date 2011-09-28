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
  import neoart.flod.*;

  public class Panel extends Sprite {
    private var canvas:BitmapData;
    private var screen:Bitmap;
    private var channels:Sprite;
    private var currentRow:Vector.<Label>;
    private var drawingRow:Vector.<Label>;
    private var fillRect:Rectangle;
    private var current:int;
    private var first:int;
    private var index:int;

    private var numChannels:int = 4;
    private var patternLength:int = ModFlod.PATTERN_LENGTH;
    private var patterns:Vector.<ModCommand>;

    private const EMPTY:String = "---00000";

    public function Panel(container:DisplayObjectContainer) {
      x = 17; y = 261;
      initialize();
      container.addChild(this);
    }

    public function start(song:ModSong):void {
      numChannels = song.numChannels;
      if (patternLength != song.patternLength) draw();
      patternLength = song.patternLength;
      patterns = song.patterns;
      first = song.positions[0];
      reset();
    }

    public function disable():void {
      stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
    }

    public function print(pattern:int):void {
      var cy:int, i:int, j:int, p:int;
      index = (pattern * patternLength) * numChannels;
      canvas.lock();
      canvas.fillRect(fillRect, Theme.PANEL_BACKGROUND);
      p = index;

      for (i = 0; i < patternLength; ++i) {
        cy = (i * 14) - 5;
        for (j = 0; j < numChannels; ++j) {
          drawingRow[j].text = patterns[p++].text;
          drawingRow[j].y = cy;
        }
        canvas.draw(channels);
      }
      canvas.unlock();
      scroll(0);
    }

    public function reset():void {
      current = 0;
      index = 0;
      print(first);
      stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
    }

    public function scroll(row:int):void {
      var i:int, j:int;
      screen.y = 98 - (row * 14);
      j = index + (row * numChannels);
      currentRow[4].text = pad(row);

      for (i = 0; i < 4; ++i)
        currentRow[i].text = patterns[j + i].text;
    }

    private function initialize():void {
      var g:Graphics, i:int, masker:Shape;
      mouseEnabled = false;
      tabEnabled = false;

      screen = new Bitmap(null, "always", false);
      screen.y = 98;

      channels = new Sprite();
      channels.mouseEnabled = false;
      channels.tabEnabled = false;

      drawingRow = new Vector.<Label>(4, true);
      drawingRow[0] = new Label(channels,  64, 0, EMPTY);
      drawingRow[1] = new Label(channels, 193, 0, EMPTY);
      drawingRow[2] = new Label(channels, 322, 0, EMPTY);
      drawingRow[3] = new Label(channels, 451, 0, EMPTY);

      for (i = 0; i < 4; ++i) {
        drawingRow[i].formatBold();
        drawingRow[i].color = Theme.LABEL_PATTERN;
      }
      draw();

      masker = new Shape();
      g = masker.graphics;
      g.beginFill(0xff00ff);
      g.drawRect(  0,   0, 20, 95);
      g.drawRect( 66,   0, 84, 95);
      g.drawRect(195,   0, 84, 95);
      g.drawRect(324,   0, 84, 95);
      g.drawRect(453,   0, 84, 95);
      g.drawRect(  0, 112, 20, 95);
      g.drawRect( 66, 112, 84, 95);
      g.drawRect(195, 112, 84, 95);
      g.drawRect(324, 112, 84, 95);
      g.drawRect(453, 112, 84, 95);
      g.endFill();
      screen.mask = masker;

      addChild(screen);
      addChild(masker);

      currentRow = new Vector.<Label>(5, true);
      currentRow[0] = new Label(this,  64, 93, EMPTY);
      currentRow[1] = new Label(this, 193, 93, EMPTY);
      currentRow[2] = new Label(this, 322, 93, EMPTY);
      currentRow[3] = new Label(this, 451, 93, EMPTY);
      currentRow[4] = new Label(this,  -2, 93, "00");

      for (i = 0; i < 5; ++i) {
        currentRow[i].formatBold();
        currentRow[i].font = Theme.FONT_DEFAULT;
        currentRow[i].color = Theme.LABEL_BUTTON;
      }
    }

    private function draw():void {
      var cy:int, i:int, label:Label;
      if (canvas) canvas.dispose();
      canvas = new BitmapData(537, (patternLength * 14) - 3, false, Theme.PANEL_BACKGROUND);
      canvas.lock();
      screen.bitmapData = canvas;

      label = new Label(channels, -2, 0);
      label.formatBold();
      label.color = Theme.LABEL_PATTERN;

      for (i = 0; i < patternLength; ++i) {
        cy = (i * 14) - 5;
        label.text = pad(i);
        label.y = cy;
        drawingRow[0].y = cy;
        drawingRow[1].y = cy;
        drawingRow[2].y = cy;
        drawingRow[3].y = cy;
        canvas.draw(channels);
      }
      canvas.unlock();
      channels.removeChild(label);
      label = null;
      fillRect = new Rectangle(66, 0, 471, canvas.height);
    }

    private function pad(value:int, length:int = 2, hex:Boolean = false):String {
      var text:String = "00000";
      text += hex ? value.toString(16).toUpperCase() : value.toString();
      return text.substr(-length);
    }

    private function keyboardHandler(e:KeyboardEvent):void {
      if (e.keyCode == 38) {
        if (--current < 0) current = patternLength - 1;
        scroll(current);
      } else if (e.keyCode == 40) {
        if (++current >= patternLength) current = 0;
        scroll(current);
      }
    }
  }
}