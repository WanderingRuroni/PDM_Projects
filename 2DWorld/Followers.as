package  {
	
	public class Followers extends SteeringVehicle{

		private var radius:Number;
		private var linePosition:Number;

		public function Followers(aMan:WorldApp, aX:Number, aY:Number, aPos:Number, rad:Number) {
			// constructor code
			super(aMan, aX, aY, rad);
			aMan.addChild(this);
			this.maxSpeed = 200;
			linePosition = aPos;
		}
		
		override protected function calcSteeringForce():Vector2
		{
			var steeringForce:Vector2 = new Vector2();
			steeringForce = steeringForce.add(leaderFollow(_manager.Lead, _manager.Flock, 40, linePosition));
			return steeringForce;
		}

	}
	
}
