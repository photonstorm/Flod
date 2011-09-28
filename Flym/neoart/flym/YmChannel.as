package neoart.flym {

  public class YmChannel {
    public var mixNoise:int;
    public var mixTone:int;
    public var mode:Boolean;
    public var position:uint;
    public var step:int;

    private var processor:YmProcessor;
    private var vol:int;

    public function YmChannel(processor:YmProcessor) {
      this.processor = processor;
    }

    public function get enabled():int {
      return (position >> 30) | mixTone;
    }

    public function get volume():int {
      return (mode) ? processor.volumeEnv : vol;
    }

    public function set volume(value:int):void {
      mode = Boolean(value & 16);
      vol = value;
    }

    public function next():void {
      position += step;
      if (position > 2147483647) position -= 2147483647;
    }

    public function computeTone(high:int, low:int):void {
      var p:Number = (high << 8) | low;

      if (p < 5) {
        position = 1073741824;
        step = 0;
      } else {
        p = processor.clock / ((p << 3) * processor.audioFreq);
        step = int(p * 1073741824);
      }
    }
  }
}