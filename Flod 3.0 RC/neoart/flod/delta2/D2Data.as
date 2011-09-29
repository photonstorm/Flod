package neoart.flod.delta2 {
  import neoart.flod.amiga.*;

  public final class D2Data {
    internal var
      sample         : D2Sample,
      trackPtr       : int,
      trackPos       : int,
      trackLen       : int,
      patternPos     : int,
      restart        : int,
      step           : D2Step,
      row            : AmigaRow,
      note           : int,
      period         : int,
      finalPeriod    : int,
      arpeggioPtr    : int,
      arpeggioPos    : int,
      pitchBend      : int,
      portamento     : int,
      tableCtr       : int,
      tablePos       : int,
      vibratoCtr     : int,
      vibratoDir     : int,
      vibratoPos     : int,
      vibratoPeriod  : int,
      vibratoSustain : int,
      volume         : int,
      volumeMax      : int,
      volumePos      : int,
      volumeSustain  : int;

    internal function initialize():void {
      sample         = null;
      trackPtr       = 0;
      trackPos       = 0;
      trackLen       = 0;
      patternPos     = 0;
      restart        = 0;
      step           = null;
      row            = null;
      note           = 0;
      period         = 0;
      finalPeriod    = 0;
      arpeggioPtr    = 0;
      arpeggioPos    = 0;
      pitchBend      = 0;
      portamento     = 0;
      tableCtr       = 0;
      tablePos       = 0;
      vibratoCtr     = 0;
      vibratoDir     = 0;
      vibratoPos     = 0;
      vibratoPeriod  = 0;
      vibratoSustain = 0;
      volume         = 0;
      volumeMax      = 63;
      volumePos      = 0;
      volumeSustain  = 0;
    }
  }
}