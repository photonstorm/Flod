/* FlodEx version 1.3
   2009/12/30
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package {
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.utils.*;
  import neoart.flod.amiga.*;
  import neoart.flod.delta1.*;
  import neoart.flod.delta2.*;
  import neoart.flod.digitalmugician.*;
  import neoart.flod.futurecomposer.*;
  import neoart.flod.sidmon1.*;
  import neoart.flod.sidmon2.*;
  import neoart.flod.soundmon.*;

  public final class FlodEx extends Sprite {
    private var player:AmigaPlayer;
    private var file:FileReference;

    public function FlodEx() {
      btnSoundmon.addEventListener(MouseEvent.CLICK, browseHandler);
      btnFuture.addEventListener(MouseEvent.CLICK, browseHandler);
      btnDelta1.addEventListener(MouseEvent.CLICK, browseHandler);
      btnDelta2.addEventListener(MouseEvent.CLICK, browseHandler);
      btnSidmon1.addEventListener(MouseEvent.CLICK, browseHandler);
      btnSidmon2.addEventListener(MouseEvent.CLICK, browseHandler);
      btnMugician.addEventListener(MouseEvent.CLICK, browseHandler);

      btnPlay.addEventListener(MouseEvent.CLICK, playHandler);
      btnPause.addEventListener(MouseEvent.CLICK, pauseHandler);
      btnStop.addEventListener(MouseEvent.CLICK, stopHandler);

      btnPlay.enabled  = false;
      btnPause.enabled = false;
      btnStop.enabled  = false;
    }

    private function browseHandler(e:MouseEvent):void {
      if (player) player.stop();

      if (e.target == btnSoundmon) {
        player = new BPPlayer();
      } else if (e.target == btnFuture) {
        player = new FCPlayer();
      } else if (e.target == btnDelta1) {
        player = new D1Player();
      } else if (e.target == btnDelta2) {
        player = new D2Player();
      } else if (e.target == btnSidmon1) {
        player = new S1Player();
      } else if (e.target == btnSidmon2) {
        player = new S2Player();
      } else if (e.target == btnMugician) {
        player = new DMPlayer();
      }

      player.amiga.record = 0;

      btnPlay.enabled  = false;
      btnPause.enabled = false;
      btnStop.enabled  = false;

      file = new FileReference();
      file.addEventListener(Event.CANCEL, cancelHandler);
      file.addEventListener(Event.SELECT, selectHandler);
      file.browse();
    }

    private function cancelHandler(e:Event):void {
      file.removeEventListener(Event.CANCEL, cancelHandler);
      file.removeEventListener(Event.SELECT, selectHandler);
    }

    private function selectHandler(e:Event):void {
      cancelHandler(e);
      file.addEventListener(Event.COMPLETE, completeHandler);
      file.load();
    }

    private function completeHandler(e:Event):void {
      file.removeEventListener(Event.COMPLETE, completeHandler);
      if (player.load(e.target.data)) {
        player.play();
        btnPause.enabled = true;
        btnStop.enabled  = true;
      }
      file = null;
    }

    private function playHandler(e:MouseEvent):void {
      if (!btnPlay.enabled) return;
      if (player.play()) {
        btnPlay.enabled  = false;
        btnPause.enabled = true;
        btnStop.enabled  = true;
      }
    }

    private function pauseHandler(e:MouseEvent):void {
      if (!btnPause.enabled) return;
      player.pause();
      btnPlay.enabled  = true;
      btnPause.enabled = false;
    }

    private function stopHandler(e:MouseEvent):void {
      if (!btnStop.enabled) return;
      player.stop();
      if (player.amiga.available) {
        file = new FileReference();
        file.save(player.amiga.output, "FlodEx.wav");
      }
      btnPlay.enabled  = true;
      btnPause.enabled = false;
      btnStop.enabled  = false;
    }
  }
}