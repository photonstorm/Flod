package neoart.flod.soundfx {
  import neoart.flod.amiga.*;

  public final class FXData {
    internal var
      channel     : AmigaChannel,
      sample      : AmigaSample,
      enabled     : int,
      period      : int,
      effect      : int,
      param       : int,
      volume      : int,
      last        : int,
      slideCtr    : int,
      slideDir    : int,
      slideParam  : int,
      slidePeriod : int,
      slideSpeed  : int,
      stepPeriod  : int,
      stepSpeed   : int,
      stepWanted  : int;

    internal function initialize():void {
      channel     = null;
      sample      = null;
      enabled     = 0;
      period      = 0;
      effect      = 0;
      param       = 0;
      volume      = 0;
      last        = 0;
      slideCtr    = 0;
      slideDir    = 0;
      slideParam  = 0;
      slidePeriod = 0;
      slideSpeed  = 0;
      stepPeriod  = 0;
      stepSpeed   = 0;
      stepWanted  = 0;
    }
  }
}