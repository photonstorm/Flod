package neoart.flod.amiga {

  public final class AmigaFilter {
    public static const
      AUTOMATIC : int =  0,
      FORCE_ON  : int =  1,
      FORCE_OFF : int = -1;
    public var
      active    : int,
      forced    : int = FORCE_OFF;

    private const
      FL : Number = 0.5213345843532200,
      P0 : Number = 0.4860348337215757,
      P1 : Number = 0.9314955486749749;
    private var
      l0 : Number,
      l1 : Number,
      l2 : Number,
      l3 : Number,
      l4 : Number,
      r0 : Number,
      r1 : Number,
      r2 : Number,
      r3 : Number,
      r4 : Number;

    internal function initialize():void {
      l0 = l1 = l2 = l3 = l4 = 0.0;
      r0 = r1 = r2 = r3 = r4 = 0.0;
    }

    internal function process(model:int, sample:Sample):void {
      var d:Number;

      if (model == 0) {
        d = 1 - P0;
        l0 = P0 * sample.l + d * l0 + 1e-18 - 1e-18;
        r0 = P0 * sample.r + d * r0 + 1e-18 - 1e-18;
        d = 1 - P1;
        l1 = P1 * l0 + d * l1;
        r1 = P1 * r0 + d * r1;
        sample.l = l1;
        sample.r = r1;
      }

      if ((active | forced) > 0) {
        d = 1 - FL;
        l2 = FL * sample.l + d * l2 + 1e-18 - 1e-18;
        r2 = FL * sample.r + d * r2 + 1e-18 - 1e-18;
        l3 = FL * l2 + d * l3;
        r3 = FL * r2 + d * r3;
        l4 = FL * l3 + d * l4;
        r4 = FL * r3 + d * r4;
        sample.l = l4;
        sample.r = r4;
      }

      if (sample.l > 1.0) sample.l = 1.0;
        else if (sample.l < -1.0) sample.l = -1.0;

      if (sample.r > 1.0) sample.r = 1.0;
        else if (sample.r < -1.0) sample.r = -1.0;
    }
  }
}