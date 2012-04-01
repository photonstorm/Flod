package neoart.flod.digitalmugician {

  public final class DMData {
    internal var
      sample       : DMSample,
      step         : DMStep,
      note         : int,
      period       : int,
      val1         : int,
      val2         : int,
      finalPeriod  : int,
      arpeggioStep : int,
      effectCtr    : int,
      pitch        : int,
      pitchCtr     : int,
      pitchStep    : int,
      portamento   : int,
      volume       : int,
      volumeCtr    : int,
      volumeStep   : int,
      mixMute      : int,
      mixPtr       : int,
      mixEnd       : int,
      mixSpeed     : int,
      mixStep      : int,
      mixVolume    : int;

    internal function initialize():void {
      sample       = null;
      step         = null;
      note         = 0;
      period       = 0;
      val1         = 0;
      val2         = 0;
      finalPeriod  = 0;
      arpeggioStep = 0;
      effectCtr    = 0;
      pitch        = 0;
      pitchCtr     = 0;
      pitchStep    = 0;
      portamento   = 0;
      volume       = 0;
      volumeCtr    = 0;
      volumeStep   = 0;
      mixMute      = 1;
      mixPtr       = 0;
      mixEnd       = 0;
      mixSpeed     = 0;
      mixStep      = 0;
      mixVolume    = 0;
    }
  }
}