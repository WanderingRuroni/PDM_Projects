package  {
	
	import flash.utils.Timer;
	import flash.events.*;
	
	public class DragonFly extends SteeringVehicle{

		private var myTimer:Timer = new Timer(5000, 0);
		private var flyToPt:Vector2;

		public function DragonFly(aMan:WorldApp, aX:Number, aY:Number, aRad:Number) {
			// constructor code
			super(aMan, aX, aY, aRad);
			aMan.addChild(this);
			this.maxSpeed = 300;
			flyToPt = new Vector2(Math.random() * 700, Math.random() * 600);
			myTimer.start();
			myTimer.addEventListener(TimerEvent.TIMER, tick);
		}
		
		override protected function calcSteeringForce():Vector2
		{
			var steeringForce:Vector2 = new Vector2();
			steeringForce = steeringForce.add(arrival(flyToPt, 80));
			return steeringForce;
		}
		
		override public function update(dt:Number):void{
			super.update(dt);
		}
		
		private function tick(e:TimerEvent):void 
		{
			var xNum:Number = (Math.random() * 700) + 50;
			var yNum:Number = (Math.random() * 600) + 100;
			
			flyToPt = new Vector2(xNum, yNum);
		}

	}
	
}
