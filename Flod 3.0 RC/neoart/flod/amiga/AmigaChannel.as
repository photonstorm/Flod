package neoart.flod.amiga {

  public final class AmigaChannel {
    public var
      index   : int,
      mute    : int,
      panning : Number = 1.0,
      pointer : int,
      length  : int,
      delay   : int;
    internal var
      audena  : int,
      audcnt  : int,
      audloc  : int,
      audper  : int,
      audvol  : int,
      timer   : Number,
      level   : Number,
      ldata   : Number,
      rdata   : Number;

    public function AmigaChannel(index:int) {
      this.index = index;
      if ((++index & 2) == 0) panning = -panning;
      level = panning;
    }

    public function set enabled(value:int):void {
      if (value == audena) return;
      audena = value;
      audloc = pointer;
      audcnt = pointer + length;
      timer  = 1.0;
      if (value) delay += 2;
    }

    public function set period(value:int):void {
      if (value > 65535 || value < 1) value = 65535;
      audper = value;
    }

    public function set volume(value:int):void {
      if (value < 0) value = 0; else if (value > 64) value = 64;
      audvol = value;
    }

    internal function initialize():void {
      pointer = length = 0;
      audena  = audvol = 0;
      audloc  = audcnt = 0;
      audper  = 50;
      delay   = 0;
      timer   = 0.0;
      ldata   = rdata = 0.0;
    }
  }
}