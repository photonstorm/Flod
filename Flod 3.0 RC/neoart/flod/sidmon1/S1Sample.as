package neoart.flod.sidmon1 {
  import neoart.flod.amiga.*;

  public final class S1Sample extends AmigaSample {
    internal var
      waveform     : int,
      arpeggio     : Vector.<int>,
      attackSpeed  : int,
      attackMax    : int,
      decaySpeed   : int,
      decayMin     : int,
      sustain      : int,
      releaseSpeed : int,
      releaseMin   : int,
      phaseShift   : int,
      phaseSpeed   : int,
      finetune     : int,
      pitchFall    : int;

    public function S1Sample() {
      arpeggio = new Vector.<int>(16, true);
    }
  }
}