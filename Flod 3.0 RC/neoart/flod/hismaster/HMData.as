package neoart.flod.hismaster {
  import neoart.flod.amiga.*;

  public final class HMData {
    internal var
      channel      : AmigaChannel,
      sample       : HMSample,
      enabled      : int,
      period       : int,
      effect       : int,
      param        : int,
      volume1      : int,
      volume2      : int,
      handler      : int,
      portaDir     : int,
      portaPeriod  : int,
      portaSpeed   : int,
      vibratoPos   : int,
      vibratoSpeed : int,
      wavePos      : int;

    internal function initialize():void {
      channel      = null;
      sample       = null;
      enabled      = 0;
      period       = 0;
      effect       = 0;
      param        = 0;
      volume1      = 0;
      volume2      = 0;
      handler      = 0;
      portaDir     = 0;
      portaPeriod  = 0;
      portaSpeed   = 0;
      vibratoPos   = 0;
      vibratoSpeed = 0;
      wavePos      = 0;
    }
  }
}