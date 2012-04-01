package neoart.flod.sidmon1 {

  public final class S1Data {
    internal var
      step         : int,
      row          : int,
      sample       : int,
      samplePtr    : int,
      sampleLen    : int,
      note         : int,
      noteTimer    : int,
      period       : int,
      volume       : int,
      bendTo       : int,
      bendSpeed    : int,
      arpeggioCtr  : int,
      envelopeCtr  : int,
      pitchCtr     : int,
      pitchFallCtr : int,
      sustainCtr   : int,
      phaseTimer   : int,
      phaseSpeed   : int,
      wavePos      : int,
      waveList     : int,
      waveTimer    : int,
      waitCtr      : int;

    internal function initialize():void {
      step         =  0;
      row          =  0;
      sample       =  0;
      samplePtr    = -1;
      sampleLen    =  0;
      note         =  0;
      noteTimer    =  0;
      period       =  0x9999;
      volume       =  0;
      bendTo       =  0;
      bendSpeed    =  0;
      arpeggioCtr  =  0;
      envelopeCtr  =  0;
      pitchCtr     =  0;
      pitchFallCtr =  0;
      sustainCtr   =  0;
      phaseTimer   =  0;
      phaseSpeed   =  0;
      wavePos      =  0;
      waveList     =  0;
      waveTimer    =  0;
      waitCtr      =  0;
    }
  }
}