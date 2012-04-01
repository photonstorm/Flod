package neoart.flod.sidmon2 {

  public final class S2Data {
    internal var
      step           : S2Step,
      row            : S2Row,
      instr          : S2Instrument,
      sample         : S2Sample,
      enabled        : int,
      pattern        : int,
      instrument     : int,
      note           : int,
      period         : int,
      volume         : int,
      original       : int,
      adsrPos        : int,
      sustainCtr     : int,
      pitchBend      : int,
      pitchBendCtr   : int,
      noteSlideTo    : int,
      noteSlideSpeed : int,
      waveCtr        : int,
      wavePos        : int,
      arpeggioCtr    : int,
      arpeggioPos    : int,
      vibratoCtr     : int,
      vibratoPos     : int,
      timer          : int;

    internal function initialize():void {
      step           = null;
      row            = null;
      instr          = null;
      sample         = null;
      enabled        = 0;
      pattern        = 0;
      instrument     = 0;
      note           = 0;
      period         = 0;
      volume         = 0;
      original       = 0;
      adsrPos        = 0;
      sustainCtr     = 0;
      pitchBend      = 0;
      pitchBendCtr   = 0;
      noteSlideTo    = 0;
      noteSlideSpeed = 0;
      waveCtr        = 0;
      wavePos        = 0;
      arpeggioCtr    = 0;
      arpeggioPos    = 0;
      vibratoCtr     = 0;
      vibratoPos     = 0;
      timer          = 0;
    }
  }
}