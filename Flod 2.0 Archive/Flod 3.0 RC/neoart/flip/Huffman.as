package neoart.flip {

  public final class Huffman {
    internal var
      count  : Vector.<int>,
      symbol : Vector.<int>;

    public function Huffman(length:int) {
      count  = new Vector.<int>(length, true);
      symbol = new Vector.<int>(length, true);
    }
  }
}