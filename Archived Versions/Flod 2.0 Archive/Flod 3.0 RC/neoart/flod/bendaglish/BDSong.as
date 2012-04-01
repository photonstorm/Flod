package neoart.flod.bendaglish {
  import flash.utils.*;

  public final class BDSong {
    internal var
      tracks : Vector.<ByteArray>,
      speed  : int;

    public function BDSong() {
      tracks = new Vector.<ByteArray>(4, true);
    }
  }
}