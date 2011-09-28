package neoart.flym {
  import flash.events.*;
  import flash.media.*;
  import flash.utils.*;

  public class YmProcessor {
	public var counter:int;

    public var sound:Sound;
    public var soundChannel:SoundChannel;
    public var soundChannelPos:int;
    public var song:YmSong;
    public var loop:Boolean;
    public var stereo:Boolean;

    internal var audioFreq:int;
    internal var clock:int;
    internal var registers:ByteArray;
    internal var volumeEnv:int;

    private var buffer:Vector.<Sample>;
    private var bufferSize:int;
    private var voiceA:YmChannel;
    private var voiceB:YmChannel;
    private var voiceC:YmChannel;
    private var samplesTick:int;
    private var samplesLeft:int;
    private var frame:int;

    private var envData:Vector.<int>;
    private var envPhase:int;
    private var envPos:uint;
    private var envShape:int;
    private var envStep:int;

    private var noiseOutput:int;
    private var noisePos:int;
    private var noiseStep:int;
    private var rng:int;

    private var syncBuzzer:Boolean;
    private var syncBuzzerPhase:uint;
    private var syncBuzzerStep:int;

    public function YmProcessor() {
      init();
      reset();
    }

    public function load(stream:ByteArray):Boolean {
      song = new YmSong(stream);

      audioFreq = YmConst.PLAYER_FREQ;
      clock = song.clock;
      samplesTick = audioFreq / song.rate;

      return song.supported;
    }

    public function play():Boolean {
      if (!song || !song.supported) return false;

      sound = new Sound();
      sound.addEventListener(SampleDataEvent.SAMPLE_DATA, mixer);
      soundChannel = sound.play(soundChannelPos);
      soundChannelPos = 0;
      return true;
    }

    public function pause():int {
      soundChannelPos = soundChannel.position;
      soundChannel.stop();
      sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, mixer);
      return soundChannelPos;
    }

    public function stop():Boolean {
      if (soundChannel.position == 0) return false;

      soundChannel.stop();
      sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, mixer);
      reset();
      return true;
    }

    private function reset():void {
      var i:int;

      voiceA = new YmChannel(this);
      voiceB = new YmChannel(this);
      voiceC = new YmChannel(this);
      samplesLeft = 0;
      frame = 0;

      registers = new ByteArray();
      for (i = 0; i < 16; ++i) registers.writeByte(0);
      registers[7] = 255;

      writeRegisters();
      volumeEnv = 0;

      noiseOutput = 65535;
      noisePos = 0;
      noiseStep = 0;
      rng = 1;

      envPhase = 0;
      envPos = 0;
      envShape = 0;
      envStep = 0;

      syncBuzzerStop();
    }

    private function mixer(e:SampleDataEvent):void {
      var b:int, i:int, mixed:int, mixPos:int, sample:Sample, size:int, toMix:int, value:Number;

      while (mixed < bufferSize) {
        if (samplesLeft == 0) {
          if (frame >= song.length) {
            if (loop) {
              frame = song.restart;
            } else {
              sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, mixer);
              return;
            }
          }

          syncBuzzerStop();

          registers = song.frames[frame++];
          updateEffects(1, 6, 14);
          updateEffects(3, 8, 15);

          writeRegisters();
          samplesLeft = samplesTick;
        }

        toMix = samplesLeft;
        if ((mixed + toMix) > bufferSize) toMix = bufferSize - mixed;
        size = mixPos + toMix;

        for (i = mixPos; i < size; ++i) {
          sample = buffer[i];

          if (noisePos & 65536) {
            b = (rng & 1) ^ ((rng >> 2) & 1);
            rng = (rng >> 1) | (b << 16);
            noiseOutput ^= (b ? 0 : 65535);
            noisePos &= 65535;
          }

          volumeEnv = envData[int((envShape << 6) + (envPhase << 5) + (envPos >> 26))];

          b = voiceA.enabled & (noiseOutput | voiceA.mixNoise);
          sample.voiceA = (b) ? voiceA.volume : -1;
          b = voiceB.enabled & (noiseOutput | voiceB.mixNoise);
          sample.voiceB = (b) ? voiceB.volume : -1;
          b = voiceC.enabled & (noiseOutput | voiceC.mixNoise);
          sample.voiceC = (b) ? voiceC.volume : -1;

          voiceA.next();
          voiceB.next();
          voiceC.next();

          noisePos += noiseStep;
          envPos += envStep;
          if (envPos > 2147483647) envPos -= 2147483647;
          if (envPhase == 0 && envPos < envStep) envPhase = 1;

          if (syncBuzzer) {
            syncBuzzerPhase += syncBuzzerStep;

            if (syncBuzzerPhase & 1073741824) {
              envPos = 0;
              envPhase = 0;
              syncBuzzerPhase &= 0x3fffffff;
            }
          }
        }

        mixed += toMix;
        mixPos = size;
        samplesLeft -= toMix;
      }

      if (stereo) {
        for (i = 0; i < bufferSize; ++i) {
          sample = buffer[i];
          e.data.writeFloat(sample.left);
          e.data.writeFloat(sample.right);
        }
      } else {
        for (i = 0; i < bufferSize; ++i) {
          value = buffer[i].mono;
          e.data.writeFloat(value);
          e.data.writeFloat(value);
        }
      }
    }

    private function writeRegisters():void {
      var p:Number;

      registers[0] &= 255;
      registers[1] &= 15;
      voiceA.computeTone(registers[1], registers[0]);

      registers[2] &= 255;
      registers[3] &= 15;
      voiceB.computeTone(registers[3], registers[2]);

      registers[4] &= 255;
      registers[5] &= 15;
      voiceC.computeTone(registers[5], registers[4]);

      registers[6] &= 31;

      if (registers[6] < 3) {
        noisePos = 0;
        noiseOutput = 65535;
        noiseStep = 0;
      } else {
        p = clock / ((registers[6] << 3) * audioFreq);
        noiseStep = int(p * 32768);
      }

      registers[7] &= 255;

      voiceA.mixTone = (registers[7] & 1) ? 65535 : 0;
      voiceB.mixTone = (registers[7] & 2) ? 65535 : 0;
      voiceC.mixTone = (registers[7] & 4) ? 65535 : 0;

      voiceA.mixNoise = (registers[7] &  8) ? 65535 : 0;
      voiceB.mixNoise = (registers[7] & 16) ? 65535 : 0;
      voiceC.mixNoise = (registers[7] & 32) ? 65535 : 0;

      registers[8] &= 31;
      voiceA.volume = registers[8];
      registers[9] &= 31;
      voiceB.volume = registers[9];
      registers[10] &= 31;
      voiceC.volume = registers[10];

      registers[11] &= 255;
      registers[12] &= 255;
      p = (registers[12] << 8) | registers[11];

      if (p < 3) {
        envStep = 0;
      } else {
        p = clock / ((p << 8) * audioFreq);
        envStep = int(p * 1073741824);
      }

      if (registers[13] == 255) {
        registers[13] = 0;
      } else {
        registers[13] &= 15;
        envPhase = 0;
        envPos = 0;
        envShape = registers[13];
      }
    }

    private function updateEffects(code:int, preDiv:int, count:int):void {
    }

    private function updateOld():void {
    }

    private function syncBuzzerStart(timerFreq:int, shapeEnv:int):void {
      envShape = shapeEnv & 15;
      syncBuzzerStep = (timerFreq * 1073741824) / audioFreq;;
      syncBuzzerPhase = 0;
      syncBuzzer = true;
    }

    private function syncBuzzerStop():void {
      syncBuzzer = false;
      syncBuzzerPhase = 0;
      syncBuzzerStep = 0;
    }

    private function init():void {
      var i:int;

      bufferSize = YmConst.BUFFER_SIZE;
      buffer = new Vector.<Sample>(bufferSize, true);

      for (i = 0; i < bufferSize; ++i) buffer[i] = new Sample();

      envData = YmConst.ENVELOPES;
    }
  }
}