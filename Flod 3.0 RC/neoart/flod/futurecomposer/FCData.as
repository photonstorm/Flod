package neoart.flod.futurecomposer {
  import neoart.flod.amiga.*;

  public final class FCData {
    internal var
      sample         : AmigaSample,
      enabled        : int,
      pattern        : int,
      soundTranspose : int,
      transpose      : int,
      patStep        : int,
      frqStep        : int,
      frqPos         : int,
      frqSustain     : int,
      frqTranspose   : int,
      volStep        : int,
      volPos         : int,
      volCtr         : int,
      volSpeed       : int,
      volSustain     : int,
      note           : int,
      pitch          : int,
      volume         : int,
      pitchBendFlag  : int,
      pitchBendSpeed : int,
      pitchBendTime  : int,
      portamentoFlag : int,
      portamento     : int,
      volBendFlag    : int,
      volBendSpeed   : int,
      volBendTime    : int,
      vibratoFlag    : int,
      vibratoSpeed   : int,
      vibratoDepth   : int,
      vibratoDelay   : int,
      vibrato        : int;

    internal function initialize():void {
      sample         = null;
      enabled        = 0;
      pattern        = 0;
      soundTranspose = 0;
      transpose      = 0;
      patStep        = 0;
      frqStep        = 0;
      frqPos         = 0;
      frqSustain     = 0;
      frqTranspose   = 0;
      volStep        = 0;
      volPos         = 0;
      volCtr         = 1;
      volSpeed       = 1;
      volSustain     = 0;
      note           = 0;
      pitch          = 0;
      volume         = 0;
      pitchBendFlag  = 0;
      pitchBendSpeed = 0;
      pitchBendTime  = 0;
      portamentoFlag = 0;
      portamento     = 0;
      volBendFlag    = 0;
      volBendSpeed   = 0;
      volBendTime    = 0;
      vibratoFlag    = 0;
      vibratoSpeed   = 0;
      vibratoDepth   = 0;
      vibratoDelay   = 0;
      vibrato        = 0;
    }

    internal function volumeBend():void {
      volBendFlag ^= 1;

      if (volBendFlag) {
        volBendTime--;
        volume += volBendSpeed;
        if (volume < 0 || volume > 64) volBendTime = 0;
      }
    }
  }
}