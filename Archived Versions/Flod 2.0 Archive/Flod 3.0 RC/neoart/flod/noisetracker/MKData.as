package neoart.flod.noisetracker {
  import neoart.flod.amiga.*;

  public final class MKData {
    internal var
      channel      : AmigaChannel,
      sample       : AmigaSample,
      enabled      : int,
      period       : int,
      effect       : int,
      param        : int,
      volume       : int,
      portaDir     : int,
      portaPeriod  : int,
      portaSpeed   : int,
      vibratoPos   : int,
      vibratoSpeed : int;

    internal function initialize():void {
      channel      = null;
      sample       = null;
      enabled      = 0;
      period       = 0;
      effect       = 0;
      param        = 0;
      volume       = 0;
      portaDir     = 0;
      portaPeriod  = 0;
      portaSpeed   = 0;
      vibratoPos   = 0;
      vibratoSpeed = 0;
    }
  }
}