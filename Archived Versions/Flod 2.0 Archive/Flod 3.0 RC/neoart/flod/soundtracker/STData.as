package neoart.flod.soundtracker {
  import neoart.flod.amiga.*;

  public final class STData {
    internal var
      channel : AmigaChannel,
      sample  : AmigaSample,
      enabled : int,
      period  : int,
      effect  : int,
      param   : int,
      last    : int;

    internal function initialize():void {
      channel = null;
      sample  = null;
      enabled = 0;
      period  = 0;
      effect  = 0;
      param   = 0;
      last    = 0;
    }
  }
}