package  {
	
	import flash.display.MovieClip;
	
	public class Pond extends MovieClip{

		private var position : Vector2;
		private var manager : WorldApp;
		protected var _radius: Number;

		public function Pond(aMan:WorldApp, aX:Number = 0, aY:Number = 0) {
			// constructor code
			manager = aMan;
			x = aX;
			y = aY;
			position = new Vector2(x,y);
			_radius = 350;
		}
		
		// accessor to get at position vector of the obstacle
		public function get Position():Vector2 { return position; }
		
		public function get radius():Number { return _radius; }

	}
	
}
