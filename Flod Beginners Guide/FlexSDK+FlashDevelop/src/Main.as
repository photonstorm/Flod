/**
 * Flod Beginners Guide
 * v1.0 - www.photonstorm.com
 * 29th October 2009
 * @author Richard Davey (rdavey@gmail.com)
 */

package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.ByteArray;
	import flash.system.Capabilities;
	
	import neoart.flod.*;
	
	//	Only needed for flectrum VU meter
	import neoart.flectrum.*;
	
	public class Main extends Sprite 
	{
		//	Our first module
		[Embed(source="assets/banja_dsx_trsi.mod", mimeType="application/octet-stream")]
		private var Song1:Class;
		
		//	Our second module
		[Embed(source="assets/180_degrees_dsx_trsi.mod", mimeType="application/octet-stream")]
		private var Song2:Class;
		
		//	Required to replay a mod
		private var stream:ByteArray;
		private var processor:ModProcessor;
		
		//	These two are only needed for flectrum display
		private var sound:SoundEx;
		private var flectrum:Flectrum;
		
		//	Graphics for the background
		[Embed(source="assets/background.jpg")]
		private var backgroundImage:Class;
		
		//	Graphics for the flectrum VU meter
		[Embed(source="assets/FlectrumMeter2.png")]
		private var FlectrumMeter2PNG:Class;
		
		public function Main():void 
		{
			//	Something to look at while we listen to the music
			addChild(new backgroundImage());
			
			//	If this isn't running in Flash Player 10 (or above) then it doesn't run at all
			if (isFlashPlayer10())
			{
				//	Example 1 - The most basic replay you can have
				playSong();
				
				//	Example 2 - Replay with Flectrum VU meter displayed (comment out the playSong() above and uncomment this one to see it in action)
				//playSongWithFlectrum();
				
				//	Listen to key presss (that control the replay)
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPress, false, 0, true);
			}
		}
		
		/**
		 * Plays a module
		 */
		private function playSong():void
		{
			//	1) First we get the module into a ByteArray
			
			stream = new Song1() as ByteArray;
			
			//	2) Create the ModProcessor which will play the song
			
			processor = new ModProcessor();
			
			//	3) Load the song (now converted into a ByteArray) into the ModProcessor
			//	This returns true on success, meaing the module was parsed successfully
			
			if (processor.load(stream))
			{
				//	Will the song loop at the end? (boolean)
				processor.loopSong = true;
				
				//	4) Play it!
				processor.play();
			}
		}
		
		/**
		 * Plays a module and displays the flectrum (vu-meter) on-screen
		 */
		private function playSongWithFlectrum():void
		{
			//	1) First we get the module into a ByteArray
			
			stream = new Song1() as ByteArray;
			
			//	2) Create the ModProcessor which will play the song
			
			processor = new ModProcessor();
			
			//	3) Create the SoundEx, this keeps track of the sound channel and sound mixer
			
			sound = new SoundEx();
			
			//	4) Create the Flectrum - the first parameter is the soundEx above. The second two control the size of the flectrum
			
			flectrum = new Flectrum(sound, 64, 32);
			//	This bitmap is the vu meter
			flectrum.useBitmap(Bitmap(new FlectrumMeter2PNG()).bitmapData);
			//	You can control the spacing between the peaks with these pixel values
			flectrum.rowSpacing = 0;
			flectrum.columnSpacing = 0;
			//	Turn it on to see it in action :)
			flectrum.showBackground = false;
			//	Should the background pulse to the beat? You can also control its alpha
			flectrum.backgroundBeat = true;
			//	Location of the flectrum on-screen
			flectrum.x = 0;
			flectrum.y = 380;
			
			//	Add it to the display list
			addChild(flectrum);
			
			//	5) Load the song (now converted into a ByteArray) into the ModProcessor
			//	This returns true on success, meaning the module was parsed successfully
			
			if (processor.load(stream))
			{
				//	Will the song loop at the end? (boolean)
				processor.loopSong = true;
				
				//	6) Play it! Note that this time we pass in the SoundEx to the ModProcessor, so it can update the Flectrum
				processor.play(sound);
			}
		}

		/**
		 * This function just demonstrates how you can hook key presses into Flod commands
		 * @param	event
		 */
		private function keyPress(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				//	1 - Play module 1
				case 49:
					processor.stop();
				
					stream = new Song1() as ByteArray;
					
					if (processor.load(stream))
					{
						processor.loopSong = true;
						processor.play(sound);
					}
					break;
					
				//	2 - Play module 2
				case 50:
					processor.stop();
					
					stream = new Song2() as ByteArray;
					
					if (processor.load(stream))
					{
						processor.loopSong = true;
						processor.play(sound);
					}
					break;
				
				//	M - Pause or Resume the playback
				case 77:
					if (processor.isPlaying)
					{
						processor.pause();
					}
					else
					{
						processor.play(sound);
					}
					break;
				
				//	Stereo Separation
				
				//	Left - Adjust the stereo separation
				case 37:
					if (processor.stereo > 0)
					{
						processor.stereo -= 0.10;
					}
					break;
					
				//	Right
				case 39:
					if (processor.stereo < 1)
					{
						processor.stereo += 0.10;
					}
					break;
			}
		}
		
		/**
		 * Checks if this SWF is running with Flash Player 10 (or greater)
		 * @return Boolean
		 */
		private function isFlashPlayer10():Boolean
		{
			var versionArray:Array = Capabilities.version.split(",");
			var platformAndVersion:Array = versionArray[0].split(" ");
			var majorVersion:Number = parseInt(platformAndVersion[1]);
			
			if (majorVersion < 10)
			{
				return false;
			}
			
			return true;
		}
		
		
	}
	
}