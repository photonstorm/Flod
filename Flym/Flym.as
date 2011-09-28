package {
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.utils.*;
  import neoart.flym.*;

  public class Flym extends Sprite {
    [Embed(source="nostalgic.ym", mimeType="application/octet-stream")]
    private var Song:Class;

    private var file:FileReference;
    private var processor:YmProcessor;
    private var stream:ByteArray;
    private var isPlaying:Boolean;

    public function Flym() {
      processor = new YmProcessor();
      stream = new Song() as ByteArray;
      btnLoad.addEventListener(MouseEvent.CLICK, browseHandler);
      btnPlay.addEventListener(MouseEvent.CLICK, playHandler);
      btnStereo.addEventListener(MouseEvent.CLICK, stereoHandler);
      btnSave.addEventListener(MouseEvent.CLICK, saveHandler);
    }

    private function browseHandler(e:MouseEvent):void {
      if (isPlaying) processor.stop();
      file = new FileReference();
      file.addEventListener(Event.CANCEL, cancelHandler);
      file.addEventListener(Event.SELECT, selectHandler);
      file.browse();
    }

    private function selectHandler(e:Event):void {
      cancelHandler(e);
      file.addEventListener(Event.COMPLETE, completeHandler);
      file.load();
    }

    private function cancelHandler(e:Event):void {
      file.removeEventListener(Event.CANCEL, cancelHandler);
      file.removeEventListener(Event.SELECT, selectHandler);
    }

    private function completeHandler(e:Event):void {
      file.removeEventListener(Event.COMPLETE, completeHandler);
      stream = file.data;
      file = null;
    }

    private function playHandler(e:MouseEvent):void {
      if (processor.load(stream)) {
        processor.play();
        btnPause.addEventListener(MouseEvent.CLICK, pauseHandler);
        btnStop.addEventListener(MouseEvent.CLICK, stopHandler);
        isPlaying = true;
        btnStereo.enabled = false;
      }
    }

    private function pauseHandler(e:MouseEvent):void {
      processor.pause();
    }

    private function stopHandler(e:MouseEvent):void {
      processor.stop();
      btnPause.removeEventListener(MouseEvent.CLICK, pauseHandler);
      btnStop.removeEventListener(MouseEvent.CLICK, stopHandler);
      isPlaying = false;
      btnStereo.enabled = true;
    }

    private function stereoHandler(e:MouseEvent):void {
      if (btnStereo.selected) {
        processor.stereo = true;
      } else {
        processor.stereo = false;
      }
    }

    private function saveHandler(e:MouseEvent):void {
      file = new FileReference();
      file.save(processor.song.data, "deinterleaved.bin");
    }
  }
}