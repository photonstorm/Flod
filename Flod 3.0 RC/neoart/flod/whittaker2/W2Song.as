package neoart.flod.whittaker2 {

  public final class W2Song {
    internal var
      pointers : Vector.<int>,
      speed    : int,
      timer    : int;

    public function W2Song() {
      pointers = new Vector.<int>();
    }
  }
}