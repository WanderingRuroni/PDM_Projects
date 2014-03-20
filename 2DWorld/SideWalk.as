package  {
	
	import flash.display.MovieClip;
	
	public class SideWalk extends MovieClip {

		private var position : Vector2;
		private var manager : WorldApp;
		private var minMaxNumbers : Array = new Array;

		public function SideWalk(aMan:WorldApp, aX:Number = 0, aY:Number = 0) {
			// constructor code
			manager = aMan;
			x = aX;
			y = aY;
			position = new Vector2(x,y);
			minMaxNumbers[0] = 850;
			minMaxNumbers[1] = 1000;
			minMaxNumbers[2] = -50;
			minMaxNumbers[3] = 850;
		}
		
		public function get Position():Vector2 { return position; }
		
		public function get MinMax(): Array { return minMaxNumbers; }

	}
	
}
