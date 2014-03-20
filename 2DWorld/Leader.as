package  {
	
	public class Leader extends SteeringVehicle {
		
		private var _wanderRad:Number = 4;
		private var _wanderAng :Number = 0;
		private var _wanderDist :Number = 12;
		
		private var center:Vector2;

		public function Leader(aMan:WorldApp, aX:Number, aY:Number, rad:Number) {
			// constructor code
			super(aMan, aX, aY, 25);
			aMan.addChild(this);
			center = new Vector2 (500,400);
			this.maxSpeed = 50;
		}
		
		override protected function calcSteeringForce():Vector2
		{
			var steeringForce:Vector2 = new Vector2();
			if(_manager.MyPond.hitTestPoint(position.x, position.y))
			{
				this.maxSpeed = 60;   
			}
			else
			{
				this.maxSpeed = 30;
			}
			steeringForce = steeringForce.add(contain(_manager.MinMaxWorld, center));
			steeringForce = steeringForce.add(wander());
			steeringForce = steeringForce.add(unalignedAvoidance(1, _manager.Flock));
			return steeringForce;
		}
		
		private function wander():Vector2
		{
			_wanderAng += calcRandom()
			var redDot :Vector2 = position.add(fwd.multiply(_wanderDist));
			var offset :Vector2 = fwd.multiply(_wanderRad);
			offset.rotate(_wanderAng);
			redDot = redDot.add(offset);
			return seek(redDot);
		}
		
		private function calcRandom():Number
		{
			var initial:Number = this.Velocity.magnitude();
			var nextSpeed:Number = initial + (((Math.random() * 2) - 1) * this.maxSpeed);
			if(nextSpeed < -1) return -1;
			if(nextSpeed > 1) return 1;
			return initial;
		}
		
		override public function update(dt:Number):void
		{
			super.update(dt);
		}

	}
	
}
