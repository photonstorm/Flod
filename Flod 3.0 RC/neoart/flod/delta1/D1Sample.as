package neoart.flod.delta1 {
  import neoart.flod.amiga.*;

  public final class D1Sample extends AmigaSample {
    internal var
      synth        : int,
      attackStep   : int,
      attackDelay  : int,
      decayStep    : int,
      decayDelay   : int,
      releaseStep  : int,
      releaseDelay : int,
      sustain      : int,
      arpeggio     : Vector.<int>,
      pitchBend    : int,
      portamento   : int,
      table        : Vector.<int>,
      tableDelay   : int,
      vibratoWait  : int,
      vibratoStep  : int,
      vibratoLen   : int;

    public function D1Sample() {
      arpeggio = new Vector.<int>( 8, true);
      table    = new Vector.<int>(48, true);
    }
  }
}