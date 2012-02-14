package neoart.flod.delta1 {
  import neoart.flod.amiga.*;

  public final class D1Data {
    internal var
      sample        : D1Sample,
      trackPos      : int,
      patternPos    : int,
      status        : int,
      timer         : int,
      step          : D1Step,
      row           : AmigaRow,
      note          : int,
      period        : int,
      arpeggioPos   : int,
      pitchBend     : int,
      tableCtr      : int,
      tablePos      : int,
      vibratoCtr    : int,
      vibratoDir    : int,
      vibratoPos    : int,
      vibratoPeriod : int,
      volume        : int,
      attackCtr     : int,
      decayCtr      : int,
      releaseCtr    : int,
      sustain       : int;

    internal function initialize():void {
      sample        = null;
      trackPos      = 0;
      patternPos    = 0;
      status        = 0;
      timer         = 1;
      step          = null;
      row           = null;
      note          = 0;
      period        = 0;
      arpeggioPos   = 0;
      pitchBend     = 0;
      tableCtr      = 0;
      tablePos      = 0;
      vibratoCtr    = 0;
      vibratoDir    = 0;
      vibratoPos    = 0;
      vibratoPeriod = 0;
      volume        = 0;
      attackCtr     = 0;
      decayCtr      = 0;
      releaseCtr    = 0;
      sustain       = 1;
    }
  }
}