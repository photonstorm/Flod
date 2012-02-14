package neoart.flod.protracker {
  import neoart.flod.amiga.*;

  public final class PTData {
    internal var
      channel      : AmigaChannel,
      sample       : PTSample,
      enabled      : int,
      loopCtr      : int,
      loopPos      : int,
      step         : int,
      period       : int,
      effect       : int,
      param        : int,
      volume       : int,
      pointer      : int,
      length       : int,
      loopPtr      : int,
      repeat       : int,
      finetune     : int,
      offset       : int,
      funkPos      : int,
      funkSpeed    : int,
      funkWave     : int,
      glissando    : int,
      portaDir     : int,
      portaPeriod  : int,
      portaSpeed   : int,
      tremoloParam : int,
      tremoloPos   : int,
      tremoloWave  : int,
      vibratoParam : int,
      vibratoPos   : int,
      vibratoWave  : int;

    internal function initialize():void {
      channel      = null;
      sample       = null;
      enabled      = 0;
      loopCtr      = 0;
      loopPos      = 0;
      step         = 0;
      period       = 0;
      effect       = 0;
      param        = 0;
      volume       = 0;
      pointer      = 0;
      length       = 0;
      loopPtr      = 0;
      repeat       = 0;
      finetune     = 0;
      offset       = 0;
      funkPos      = 0;
      funkSpeed    = 0;
      funkWave     = 0;
      glissando    = 0;
      portaDir     = 0;
      portaPeriod  = 0;
      portaSpeed   = 0;
      tremoloParam = 0;
      tremoloPos   = 0;
      tremoloWave  = 0;
      vibratoParam = 0;
      vibratoPos   = 0;
      vibratoWave  = 0;
    }
  }
}