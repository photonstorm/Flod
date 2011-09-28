/* FlodPro Player version 1.0
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
  import flash.media.*;
  import flash.net.*;
  import flash.utils.*;
  import neoart.flectrum.*;
  import neoart.flod.*;

  public class ProPlayer extends Sprite {
    private var flectrum:Flectrum;
    private var meters:Meters;
    private var panel:Panel;
    private var processor:ModProcessorEx;
    private var song:ModSong;
    private var sound:SoundEx;
    private var soundform:SoundTransform;
    private var file:FileReference;
    private var fileName:String;

    private var timer:TimerEx;
    private var data:ModData;
    private var counter:int;
    private var index:int;
    private var position:int;
    private var previousTime:int;
    private var totalSamples:int;
    private var restart:Boolean = true;

    private var btnPlay:Button;
    private var btnPause:Button;
    private var btnStop:Button;
    private var btnBrowse:Button;
    private var btnRecord:ToggleButton;
    private var btnSave:Button;
    private var btnLoop:ToggleButton;
    private var btnStandard:ToggleButton;
    private var btnFilter:StateButton;
    private var btnPrefs:Button;
    private var btnMeters:ToggleButton;

    private var btnChan1:ToggleButton;
    private var btnChan2:ToggleButton;
    private var btnChan3:ToggleButton;
    private var btnChan4:ToggleButton;
    private var btnChan5:ToggleButton;
    private var btnChan6:ToggleButton;
    private var btnChan7:ToggleButton;
    private var btnChan8:ToggleButton;

    private var spnPosition:Spin;
    private var spnSample:Spin;
    private var spnPattern:Spin;
    private var sldVolume:Slider;
    private var sldStereo:Slider;
    private var tipFilter:Tip;
    private var tipVolume:Tip;
    private var tipStereo:Tip;

    private var lblSongLen:NumericLabel;
    private var lblFinetune:NumericLabel;
    private var lblVolume:NumericLabel;
    private var lblLength:NumericLabel;
    private var lblLoop:NumericLabel;
    private var lblRepeat:NumericLabel;
    private var lblTitle:Label;
    private var lblSample:Label;
    private var lblTracker:Label;
    private var lblTempo:Label;
    private var lblSpeed:Label;
    private var lblDuration:Label;
    private var lblTime:Label;

    private const VERSION:String = "FlodPro 1.0 2009/08/15";
    private const TEMPO:  String = "Tempo:";
    private const SPEED:  String = "Speed:";
    private const STEREO: String = "Stereo Separation:";
    private const VOLUME: String = "Global Volume:";
    private const TIME:   String = "00:00";

    public function ProPlayer(container:DisplayObjectContainer) {
      initialize();
      container.addChild(this);
    }

    private function timerHandler(e:TimerEvent):void {
      var min:int = totalSamples * 0.000022675737, pattern:int;
      timer.reset();

      if (min > previousTime) {
        lblTime.text = printTime(min);
        previousTime = min;
      }

      if (counter == 0) {
        if (processor.index == index) {
          if (btnPlay.enabled) restart = true;
            else reset();
          return;
        }
        data = processor.data[index];
        if (++index >= song.patternLength) index = 0;
        timer.tick = data.samplesTick * 0.022675737;
        lblTempo.text = TEMPO + data.tempo.toString();
        lblSpeed.text = SPEED + data.speed.toString();
        if (!btnMeters.pressed) meters.set(data);

        if (position != data.position) {
          position = data.position;
          spnPosition.value = data.position;
          pattern = song.positions[position];
          spnPattern.value = pattern;
          panel.print(pattern);
          timer.setColumn();
        } else {
          panel.scroll(data.row);
          if (restart) {
            restart = false;
            timer.initialize();
          } else timer.setRow();
        }
        ++counter;
      } else {
        if (++counter >= data.speed) counter = 0;
        if (!btnMeters.pressed) meters.update();
        timer.tick = data.samplesTick * 0.022675737;
        timer.set();
      }

      totalSamples += data.samplesTick;
      timer.start();
      e.updateAfterEvent();
    }

    private function playHandler(e:MouseEvent):void {
      if (!processor.play(sound)) return;
      panel.disable();
      processor.soundChannel.soundTransform = soundform;
      timer.start();
      toggleControls(false);
      btnPlay.enabled  = false;
      btnPause.enabled = true;
      btnStop.enabled  = true;
    }

    private function pauseHandler(e:MouseEvent):void {
      processor.pause();
      btnPlay.enabled  = true;
      btnPause.enabled = false;
    }

    private function stopHandler(e:MouseEvent):void {
      processor.stop();
      timer.reset();
      reset();
    }

    private function browseHandler(e:MouseEvent):void {
      file = new FileReference();
      file.addEventListener(Event.CANCEL, cancelHandler);
      file.addEventListener(Event.SELECT, selectHandler);
      file.browse();
    }

    private function recordHandler(e:MouseEvent):void {
      processor.record = btnRecord.pressed;
      btnSave.enabled = Boolean(!btnRecord.pressed && processor.available);
    }

    private function saveHandler(e:MouseEvent):void {
      file = new FileReference();
      file.addEventListener(Event.COMPLETE, saveCompleteHandler);
      file.save(processor.output, getFilename());
    }

    private function cancelHandler(e:Event):void {
      file.removeEventListener(Event.CANCEL, cancelHandler);
      file.removeEventListener(Event.SELECT, selectHandler);
    }

    private function selectHandler(e:Event):void {
      cancelHandler(e);
      file.addEventListener(Event.COMPLETE, loadCompleteHandler);
      file.load();
    }

    private function loadCompleteHandler(e:Event):void {
      file.removeEventListener(Event.COMPLETE, loadCompleteHandler);
      btnChan1.pressed = false;
      btnChan2.pressed = false;
      btnChan3.pressed = false;
      btnChan4.pressed = false;

      if (processor.load(file.data)) {
        song = processor.song;
        toggleControls(true);
        printSong();
        lblDuration.text = printTime(processor.duration() * 0.000022675737);
        fileName = file.name;

        btnChan1.enabled = true;
        btnChan2.enabled = true;
        btnChan3.enabled = true;
        btnChan4.enabled = true;

        btnPlay.enabled = true;
        btnLoop.enabled = true;
        spnSample.enabled = true;
        panel.start(song);
      } else {
        song = null;
        data = null;
        toggleControls(false);
        clearSong();
        lblDuration.text = TIME;
        fileName = "";

        btnPlay.enabled = false;
        btnLoop.enabled = false;
        spnSample.enabled = false;
        panel.disable();
      }
      file = null;
    }

    private function saveCompleteHandler(e:Event):void {
      file.removeEventListener(Event.COMPLETE, saveCompleteHandler);
      file = null;
    }

    private function loopHandler(e:MouseEvent):void {
      processor.loopSong = Boolean(!processor.loopSong);
    }

    private function standardHandler(e:MouseEvent):void {
      processor.ntsc = btnStandard.pressed;
      stage.frameRate = btnStandard.pressed ? 30 : 25;
      lblDuration.text = printTime(processor.duration() * 0.000022675737);
    }

    private function filterHandler(e:MouseEvent):void {
      processor.forceFilter = btnFilter.state;
    }

    private function prefsHandler(e:MouseEvent):void {
    }

    private function channelHandler(e:MouseEvent):void {
      var id:int = parseInt(ToggleButton(e.target).caption);
      processor.toggleChannel(--id);
    }

    private function positionHandler(e:MouseEvent):void {
      if (song) {
        spnPattern.value = song.positions[spnPosition.value];
        panel.print(spnPattern.value);
      }
    }

    private function patternHandler(e:MouseEvent):void {
      if (song) panel.print(spnPattern.value);
    }

    private function sampleHandler(e:MouseEvent):void {
      if (song) printSample();
    }

    private function volumeHandler(e:SliderEvent):void {
      soundform.volume = e.value;
      tipVolume.tip = VOLUME + int(e.value * 100).toString() + "%";
      if (processor.soundChannel) processor.soundChannel.soundTransform = soundform;
    }

    private function stereoHandler(e:SliderEvent):void {
      processor.stereo = e.value;
      tipStereo.tip = STEREO + int(e.value * 100).toString() +"%";
    }

    private function metersHandler(e:MouseEvent):void {
      if (btnMeters.pressed) meters.reset();
    }

    private function initialize():void {
      var label:Label;
      sound = new SoundEx();
      soundform = new SoundTransform();
      processor = new ModProcessorEx();

      addChild(new Bitmap(new Screen(0, 0)));
      panel  = new Panel(this);
      meters = new Meters(this);
      timer  = new TimerEx(40, 1);
      timer.addEventListener(TimerEvent.TIMER, timerHandler);

      flectrum = new Flectrum(sound, 31, 33);
      flectrum.useBitmap(new FlectrumMeter(0, 0));
      flectrum.rowSpacing = 0;
      flectrum.x = 195; flectrum.y = 87;
      addChild(flectrum);

      new Label(this, 4,  42, "Song Length");
      new Label(this, 4,  84, "Finetune");
      new Label(this, 4, 105, "Volume");
      new Label(this, 4, 126, "Length");
      new Label(this, 4, 147, "Loop Start");
      new Label(this, 4, 168, "Repeat Length");

      lblSongLen  = new NumericLabel(this, 127,  42, 1, 3);
      lblFinetune = new NumericLabel(this, 127,  84, 0, 0);
      lblVolume   = new NumericLabel(this, 127, 105, 0, 2, true);
      lblLength   = new NumericLabel(this, 127, 126, 0, 5, true);
      lblLoop     = new NumericLabel(this, 127, 147, 0, 5, true);
      lblRepeat   = new NumericLabel(this, 127, 168, 2, 5, true);
      lblFinetune.signed = true;

      formatLabel(lblSongLen);
      formatLabel(lblFinetune);
      formatLabel(lblVolume);
      formatLabel(lblLength);
      formatLabel(lblLoop);
      formatLabel(lblRepeat);

      label = new Label(this, 4, 189, "Song Name:");
      label.autoSize = false;
      label.align = "right";
      label.width = 110;

      label = new Label(this, 4, 210, "Sample Name:");
      label.autoSize = false;
      label.align = "right";
      label.width = 110;

      label = new Label(this, 4, 231, "Tracker:");
      label.autoSize = false;
      label.align = "right";
      label.width = 110;

      lblTitle   = new Label(this, 114, 189);
      lblSample  = new Label(this, 114, 210);
      lblTracker = new Label(this, 114, 231);
      lblTitle.color   = Theme.LABEL_BUTTON;
      lblSample.color  = Theme.LABEL_BUTTON;
      lblTracker.color = Theme.LABEL_BUTTON;
      lblTracker.letterSpacing = 0;

      lblTempo = new Label(this, 380, 63, TEMPO + ModFlod.DEFAULT_TEMPO);
      lblSpeed = new Label(this, 474, 63, SPEED + ModFlod.DEFAULT_SPEED);
      lblTempo.autoSize = false;
      lblTempo.align = "center";
      lblTempo.width = 92;
      lblSpeed.autoSize = false;
      lblSpeed.align = "center";
      lblSpeed.width = 92;

      lblDuration = new Label(this, 508, 190, TIME);
      lblTime     = new Label(this, 508, 209, TIME);
      lblDuration.autoSize = false;
      lblDuration.align = "center";
      lblDuration.color = Theme.LABEL_BUTTON;
      lblDuration.width = 59;
      lblTime.autoSize = false;
      lblTime.align = "center";
      lblTime.color = Theme.LABEL_BUTTON;
      lblTime.width = 59;

      label = new Label(this, 326, 231, VERSION);
      label.color = Theme.LABEL_VERSION;
      label.letterSpacing = 0;

      btnChan1 = new ToggleButton(this, 192, 0, "1");
      btnChan2 = new ToggleButton(this, 239, 0, "2");
      btnChan3 = new ToggleButton(this, 286, 0, "3");
      btnChan4 = new ToggleButton(this, 333, 0, "4");
      btnChan5 = new ToggleButton(this, 380, 0, "5");
      btnChan6 = new ToggleButton(this, 427, 0, "6");
      btnChan7 = new ToggleButton(this, 474, 0, "7");
      btnChan8 = new ToggleButton(this, 521, 0, "8");

      btnChan1.addEventListener(MouseEvent.CLICK, channelHandler);
      btnChan2.addEventListener(MouseEvent.CLICK, channelHandler);
      btnChan3.addEventListener(MouseEvent.CLICK, channelHandler);
      btnChan4.addEventListener(MouseEvent.CLICK, channelHandler);

      btnPlay   = new Button(this, 192, 21, "PLAY");
      btnPause  = new Button(this, 192, 42, "PAUSE");
      btnStop   = new Button(this, 192, 63, "STOP");
      btnBrowse = new Button(this, 286, 21, "BROWSE");
      btnSave   = new Button(this, 286, 63, "SAVE");
      btnPrefs  = new Button(this, 474, 42, "PREFS");
      btnBrowse.enabled = true;

      btnPlay.addEventListener(MouseEvent.CLICK, playHandler);
      btnPause.addEventListener(MouseEvent.CLICK, pauseHandler);
      btnStop.addEventListener(MouseEvent.CLICK, stopHandler);
      btnBrowse.addEventListener(MouseEvent.CLICK, browseHandler);
      btnSave.addEventListener(MouseEvent.CLICK, saveHandler);

      btnRecord   = new ToggleButton(this, 286, 42, "RECORD", 94);
      btnLoop     = new ToggleButton(this, 380, 21, "LOOP",   94);
      btnStandard = new ToggleButton(this, 380, 42, "PAL",    94);
      btnStandard.captionPressed = "NTSC";

      btnRecord.addEventListener(MouseEvent.CLICK, recordHandler);
      btnLoop.addEventListener(MouseEvent.CLICK, loopHandler);
      btnStandard.addEventListener(MouseEvent.CLICK, standardHandler);

      btnFilter = new StateButton(null, 0, 0, 94);
      btnFilter.captions = ["AUTO", "FORCE OFF", "FORCE ON"];
      btnFilter.state = 1;
      btnFilter.addEventListener(MouseEvent.CLICK, filterHandler);
      tipFilter = new Tip(this, 474, 0, "LED Filter", btnFilter);
      tipFilter.enabled = false;

      btnMeters = new ToggleButton(this, 507, 231, "ON", 61);
      btnMeters.captionPressed = "OFF";
      btnMeters.enabled = true;
      btnMeters.addEventListener(MouseEvent.CLICK, metersHandler);

      spnPosition = new Spin(this, 0,  0, "Position", 3);
      spnPattern  = new Spin(this, 0, 21, "Pattern",  3);
      spnSample   = new Spin(this, 0, 63, "Sample #", 2, true);
      spnSample.min = 1;

      spnPosition.addEventListener(MouseEvent.CLICK, positionHandler);
      spnPattern.addEventListener(MouseEvent.CLICK, patternHandler);
      spnSample.addEventListener(MouseEvent.CLICK, sampleHandler);

      sldVolume = new Slider();
      sldVolume.addEventListener(SliderEvent.CHANGE, volumeHandler);
      tipVolume = new Tip(this, 324, 168, VOLUME +"100%", sldVolume);
      tipVolume.align = "left";
      tipVolume.margin = 2;
      tipVolume.width = 185;

      sldStereo = new Slider();
      sldStereo.addEventListener(SliderEvent.CHANGE, stereoHandler);
      tipStereo = new Tip(this, 324, 212, STEREO +"100%", sldStereo);
      tipStereo.align = "left";
      tipStereo.margin = 2;
      tipStereo.width = 185;
      tipStereo.below = true;
    }

    private function printSong():void {
      spnPosition.max   = song.length - 1;
      spnPosition.value = 0;
      spnPattern.max    = song.numPatterns - 1;
      spnPattern.value  = song.positions[0];
      lblSongLen.value  = song.length;
      spnSample.max     = song.numSamples;
      spnSample.value   = 1;
      lblTitle.text     = song.title.toUpperCase();
      lblTracker.text   = song.tracker;
      lblTempo.text     = TEMPO + song.tempo.toString();
      lblSpeed.text     = SPEED + ModFlod.DEFAULT_SPEED;
      lblTime.text      = TIME;
      printSample();
      meters.reset();
    }

    private function printSample():void {
      var sample:ModSample = song.samples[spnSample.value];
      lblFinetune.value = sample.finetune < 8 ? sample.finetune : -8 + (sample.finetune - 8);
      lblVolume.value   = sample.volume;
      lblLength.value   = sample.realLength;
      lblLoop.value     = sample.loopStart;
      lblRepeat.value   = sample.repeatLen;
      lblSample.text    = sample.name.toUpperCase();
    }

    private function printTime(min:int):String {
      var sec:int, m:String, s:String;
      sec = min % 60;
      min /= 60;
      m = min.toString();
      s = sec.toString();
      if (min < 10) m = "0"+ m;
      if (sec < 10) s = "0"+ s;
      return m +":"+ s;
    }

    private function clearSong():void {
      spnPosition.value = 0;
      spnPattern.value  = 0;
      lblSongLen.value  = 0;
      spnSample.value   = 1;
      lblTitle.text     = "";
      lblTracker.text   = "";
      lblTempo.text     = TEMPO + ModFlod.DEFAULT_TEMPO;
      lblSpeed.text     = SPEED + ModFlod.DEFAULT_SPEED;
      lblDuration.text  = TIME;
      lblTime.text      = TIME;
    }

    private function clearSample():void {
      lblFinetune.value = 0;
      lblVolume.value   = 0;
      lblLength.value   = 0;
      lblLoop.value     = 0;
      lblRepeat.value   = 2;
      lblSample.text    = "";
    }

    private function reset():void {
      sound.stop();
      counter = index = position = 0;
      previousTime = 0;
      totalSamples = 0;
      restart = true;
      panel.reset();
      printSong();

      toggleControls(true);
      btnPlay.enabled  = true;
      btnPause.enabled = false;
      btnStop.enabled  = false;

      if (btnRecord.pressed)
        recordHandler(new MouseEvent(MouseEvent.CLICK));
    }

    private function formatLabel(label:Label):void {
      label.autoSize = false;
      label.align = "right";
      label.color = Theme.LABEL_BUTTON;
      label.letterSpacing = 2;
      label.width = 59;
    }

    private function toggleControls(value:Boolean):void {
      spnPosition.enabled = value;
      spnPattern.enabled  = value;
      btnBrowse.enabled   = value;
      btnRecord.enabled   = value;
      btnSave.enabled     = false;
      btnStandard.enabled = value;
      btnPrefs.enabled    = false;
      tipFilter.enabled   = value;
    }

    private function getFilename():String {
      var text:String = fileName.replace(/\./g, "_");
      text = text.replace(/mod/gi, "flod");
      return text +".wav";
    }
  }
}