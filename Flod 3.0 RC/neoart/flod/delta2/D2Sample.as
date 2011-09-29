package neoart.flod.delta2 {
  import neoart.flod.amiga.*;

  public final class D2Sample extends AmigaSample {
    internal var
      index     : int,
      pitchBend : int,
      synth     : int,
      table     : Vector.<int>,
      vibratos  : Vector.<int>,
      volumes   : Vector.<int>;

    public function D2Sample() {
      table    = new Vector.<int>(48, true);
      vibratos = new Vector.<int>(15, true);
      volumes  = new Vector.<int>(15, true);
    }
  }
}