package neoart.flod.soundmon {
  import neoart.flod.amiga.*;

  public final class BPData {
    internal var
      channel      : AmigaChannel,
      enabled      : int,
      restart      : int,
      note         : int,
      period       : int,
      sample       : int,
      samplePtr    : int,
      sampleLen    : int,
      synth        : int,
      synthPtr     : int,
      arpeggio     : int,
      autoArpeggio : int,
      autoSlide    : int,
      vibrato      : int,
      volume       : int,
      volumeDef    : int,
      adsrControl  : int,
      adsrPtr      : int,
      adsrCtr      : int,
      lfoControl   : int,
      lfoPtr       : int,
      lfoCtr       : int,
      egControl    : int,
      egPtr        : int,
      egCtr        : int,
      egValue      : int,
      fxControl    : int,
      fxCtr        : int,
      modControl   : int,
      modPtr       : int,
      modCtr       : int;

    internal function initialize():void {
      channel      =  null,
      enabled      =  0;
      restart      =  0;
      note         =  0;
      period       =  0;
      sample       =  0;
      samplePtr    =  0;
      sampleLen    =  2;
      synth        =  0;
      synthPtr     = -1;
      arpeggio     =  0;
      autoArpeggio =  0;
      autoSlide    =  0;
      vibrato      =  0;
      volume       =  0;
      volumeDef    =  0;
      adsrControl  =  0;
      adsrPtr      =  0;
      adsrCtr      =  0;
      lfoControl   =  0;
      lfoPtr       =  0;
      lfoCtr       =  0;
      egControl    =  0;
      egPtr        =  0;
      egCtr        =  0;
      egValue      =  0;
      fxControl    =  0;
      fxCtr        =  0;
      modControl   =  0;
      modPtr       =  0;
      modCtr       =  0;
    } 
  }
}