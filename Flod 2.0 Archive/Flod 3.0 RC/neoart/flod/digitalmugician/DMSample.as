package neoart.flod.digitalmugician {
  import neoart.flod.amiga.*;

  public final class DMSample extends AmigaSample {
    internal var
      wave        : int,
      waveLen     : int,
      finetune    : int,
      arpeggio    : int,
      pitch       : int,
      pitchDelay  : int,
      pitchLoop   : int,
      pitchSpeed  : int,
      effect      : int,
      effectDone  : int,
      effectStep  : int,
      effectSpeed : int,
      source1     : int,
      source2     : int,
      volumeLoop  : int,
      volumeSpeed : int;
  }
}