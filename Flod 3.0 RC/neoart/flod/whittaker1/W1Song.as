package neoart.flod.whittaker1 {

  public final class W1Song {
    internal var
      pointers : Vector.<int>,
      speed    : int,
      timer    : int;

    public function W1Song() {
      pointers = new Vector.<int>();
    }
  }
}