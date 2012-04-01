package neoart.flod.digitalmugician {

  public final class DMSong {
    internal var
      title    : String,
      speed    : int,
      length   : int,
      loop     : int,
      loopStep : int,
      tracks   : Vector.<DMStep>;

    public function DMSong() {
      tracks = new Vector.<DMStep>();
    }
  }
}