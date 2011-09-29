package {
  import flash.display.*;
  import flash.utils.*;
  import neoart.flod.*;
  import neoart.flod.amiga.*;
  import neoart.flod.soundtracker.*;
  //import neoart.flod.bendaglish.*;

  public final class Player extends Sprite {
    [Embed(source="sarcophaser.ust", mimeType="application/octet-stream")]
    private var Song:Class;

    //var loader:FileLoader;

    public function Player() {
      stage.quality   = "high";
      stage.scaleMode = "noScale";
      //loader = new FileLoader();

      var stream:ByteArray = new Song() as ByteArray;
      var amiga:Amiga = new Amiga();
      var player:AmigaPlayer = new STPlayer(amiga);

      player.load(stream);
      if (player.version) player.play();
    }
  }
}