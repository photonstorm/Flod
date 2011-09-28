/* Flod Amiga Core 3.01
   2009/12/30
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.amiga {
  import flash.events.*;
  import flash.media.*;
  import flash.utils.*;

  public class AmigaPlayer {
    public var amiga:Amiga;
    public var sound:Sound;
    public var soundChannel:SoundChannel;
    public var soundChannelPos:Number = 0.0;
    public var loop:int;
    public var supported:int;    

    protected var speed:int;
    protected var timer:int;
    protected var complete:int;
    protected var samplesLeft:int;
    protected var samplesTick:int;

    public function AmigaPlayer() {
      amiga = new Amiga();
       ntsc = 0;
       loop = 1;
    }

    public function set ntsc(value:int):void {
      if (value) {
        amiga.clock = 81.16882653;
        samplesTick = 735;
      } else {
        amiga.clock = 80.42844898;
        samplesTick = 882;
      }
    }

    public function set stereo(value:Number):void {
      var chan:AmigaChannel, i:int;
      if (value < 0.0) value = 0.0; else if (value > 1.0) value = 1.0;

      for (i = 0; i < 4; ++i) {
        chan = amiga.channels[i];
        chan.level = value * chan.panning;
      }
    }

    public function load(stream:ByteArray):int {
      return 0;
    }

    public function play(soundProcessor:Sound = null):int {
      if (!supported) return 0;
      if (soundChannelPos == 0.0) initialize();

      sound = soundProcessor ? soundProcessor : new Sound();
      sound.addEventListener(SampleDataEvent.SAMPLE_DATA, mixer);
      soundChannel = sound.play(soundChannelPos);
      soundChannelPos = 0.0;
      return 1;
    }

    public function pause():void {
      if (!supported || !soundChannel) return;
      soundChannelPos = soundChannel.position;
      soundChannel.stop();
      sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, mixer);
    }

    public function stop():void {
      if (!supported || !soundChannel) return;
      soundChannel.stop();
      sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, mixer);
      soundChannelPos = 0.0;
      reset();
    }

    protected function initialize():void {}

    protected function reset():void {}

    protected function process():void {}

    protected function mixer(e:SampleDataEvent):void {
      var l:int = amiga.bufferSize, mixed:int, toMix:int;

      while (mixed < l) {
        if (samplesLeft == 0) {
          if (complete) {
            if (loop == 0) {
              sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, mixer);
              l = amiga.mixPos;
            }
          }
          process();
          samplesLeft = samplesTick;
        }

        toMix = samplesLeft;
        if ((mixed + toMix) >= l) toMix = l - mixed;
        amiga.mixLen = toMix;
        amiga.mix();

        mixed += toMix;
        samplesLeft -= toMix;
      }

      amiga.mixData = e.data;
      amiga.play();
    }
  }
}