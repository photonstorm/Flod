package neoart.flod.hismaster {
  import neoart.flod.amiga.*;

  public final class HMSample extends AmigaSample {
    internal var
      finetune : int,
      restart  : int,
      waveLen  : int,
      waves    : Vector.<int>,
      volumes  : Vector.<int>;
  }
}