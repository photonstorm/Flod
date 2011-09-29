package neoart.flod.whittaker2 {

  public final class W2Data {
    internal var
      sample     : W2Sample,
      byte0      : int,
      byte1      : int,
      note       : int,
      byte3      : int,
      stepPtr    : int,
      patternPtr : int,
      patternPos : int,
      table2Ptr  : int,
      table2Pos  : int,
      byte20     : int,
      byte21     : int,
      sampleDone : int,
      speed      : int,
      counter    : int,
      word32     : int,
      long34     : int,
      long38     : int,
      byte42     : int,
      byte43     : int,
      byte44     : int,
      byte45     : int,
      byte46     : int;

    internal function initialize():void {
      sample     =  null;
      byte0      =  0;
      byte1      =  0;
      note       =  0;
      byte3      =  0;
      stepPtr    =  0;
      patternPtr =  0;
      patternPos =  2;
      table2Ptr  =  0;
      table2Pos  =  0;
      byte20     =  0;
      byte21     =  0;
      sampleDone = -1;
      speed      =  0;
      counter    =  1;
      word32     =  0;
      long34     =  0;
      long38     =  0;
      byte42     =  0;
      byte43     =  0;
      byte44     =  0;
      byte45     =  0;
      byte46     =  0;
    }
  }
}