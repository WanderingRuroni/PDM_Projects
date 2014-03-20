package  {
	
	public class Pedestrians extends SteeringVehicle{

		private var _wanderRad:Number = 4;
		private var _wanderAng :Number = 0;
		private var _wanderDist :Number = 15;

		public function Pedestrians(aMan:WorldApp, aX:Number, aY:Number, aRad:Number) {
			// constructor code
			super(aMan, aX, aY, aRad);
			aMan.addChild(this);
			this.maxSpeed = 150;
		}
		
		override protected function calcSteeringForce():Vector2 
		{
			var steeringForce:Vector2 = new Vector2();
			steeringForce = steeringForce.add(contain(_manager.MySidewalk.MinMax, _manager.MySidewalk.Position));
			steeringForce = steeringForce.add(wander());
			steeringForce = steeringForce.add(unalignedAvoidance(3, _manager.Groupings));
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
		
		override public function update(dt:Number):void{
			super.update(dt);
			
			if(y < 0)
			{
				y = stage.stageHeight;
				this.position = new Vector2(x, y);
			}
			if( y > stage.stageHeight)
			{
				y = 0;
				this.position = new Vector2(x, y);
			}
		}

	}
	
}
