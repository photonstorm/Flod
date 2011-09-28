package neoart.flod.digitalmugician {

  internal final class DMVoice {
    internal var step:DMStep;
    internal var sample:DMSample;
    internal var note:int;
    internal var period:int;
    internal var val1:int;
    internal var val2:int;
    internal var finalPeriod:int;
    internal var arpeggioStep:int;
    internal var effectCnt:int;
    internal var pitch:int;
    internal var pitchCnt:int;
    internal var pitchStep:int;
    internal var portamento:int;
    internal var volume:int;
    internal var volumeCnt:int;
    internal var volumeStep:int;
    internal var mixMute:int;
    internal var mixPtr:int;
    internal var mixEnd:int;
    internal var mixSpeed:int;
    internal var mixStep:uint;//int
    internal var mixVolume:int;

    internal function initialize():void {
      step         = null;
      sample       = null;
      note         = 0;
      period       = 0;
      val1         = 0;
      val2         = 0;
      finalPeriod  = 0;
      arpeggioStep = 0;
      effectCnt    = 0;
      pitch        = 0;
      pitchCnt     = 0;
      pitchStep    = 0;
      portamento   = 0;
      volume       = 0;
      volumeCnt    = 0;
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