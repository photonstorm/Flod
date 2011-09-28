package neoart.flym {

  public class Sample {
    public var voiceA:int;
    public var voiceB:int;
    public var voiceC:int;

    public function Sample(voiceA:int = -1, voiceB:int = -1, voiceC:int = -1) {
      this.voiceA = voiceA;
      this.voiceB = voiceB;
      this.voiceC = voiceC;
    }

    public function get mono():Number {
      var v:Vector.<Number> = YmConst.MONO,
          vol:Number = 0.0;

      if (voiceA > -1) vol += v[voiceA];
      if (voiceB > -1) vol += v[voiceB];
      if (voiceC > -1) vol += v[voiceC];
      return vol;
    }

    public function get left():Number {
      var v:Vector.<Number> = YmConst.STEREO,
          vol:Number = 0.0;

      if (voiceA > -1) vol += v[voiceA];
      if (voiceB > -1) vol += v[voiceB];
      return vol;
    }

    public function get right():Number {
      var v:Vector.<Number> = YmConst.STEREO,
          vol:Number = 0.0;

      if (voiceB > -1) vol += v[voiceB];
      if (voiceC > -1) vol += v[voiceC];
      return vol;
    }
  }
}