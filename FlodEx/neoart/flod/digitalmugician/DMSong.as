package neoart.flod.digitalmugician {

  internal final class DMSong {
    internal var title:String;
    internal var speed:int;
    internal var length:int;
    internal var loop:int;
    internal var loopStep:int;
    internal var tracks:Vector.<DMStep>;

    public function DMSong() {
      tracks = new Vector.<DMStep>();
    }
  }
}