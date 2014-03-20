package  {
	
	import flash.geom.Point;
	import flash.events.*;
	import flash.utils.Timer;
	
	public class FishSchool extends SteeringVehicle{

		private var dither:Number = 0;
		private var shouldFlee:Boolean = false;
		private var fleePt:Vector2 = new Vector2();
		private var myTimer:Timer = new Timer(1000, 1);

		public function FishSchool(aMan:WorldApp, aX:Number, aY:Number, rad:Number) {
			// constructor code
			super(aMan, aX, aY, rad);
			aMan.addChild(this);
			this.maxForce = 150;
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		override protected function calcSteeringForce():Vector2
		{
			var steeringForce:Vector2 = new Vector2();
			var futurePos:Vector2 = position.add(fwd.multiply(this.speed * 3.0));
			
			if(!_manager.MyPond.hitTestPoint(futurePos.x, futurePos.y))
			{
				steeringForce = steeringForce.add(seek(_manager.MyPond.Position).multiply(3));
			}
			steeringForce = steeringForce.add(alignment(_manager.School).multiply(2));
			steeringForce = steeringForce.add(cohesion(_manager.School));
			if(dither < 0.6)
			{
				steeringForce = steeringForce.add(separation(_manager.School, 30).multiply(2));
			}
			
			if(shouldFlee != false)
			{
				steeringForce = flee(fleePt);
				
				if(!_manager.MyPond.hitTestPoint(futurePos.x, futurePos.y))
				{
					steeringForce = steeringForce.add(seek(new Vector2(200, 400)).multiply(2));
				}
			}
			return steeringForce;
		}
		
		override public function update(dt:Number):void
		{
			dither = Math.random();
			super.update(dt);
		}
		
		private function onClick(e:MouseEvent):void
		{
			if(_manager.MyPond.hitTestPoint(stage.mouseX, stage.mouseY))
			{
				shouldFlee = true;
				fleePt = new Vector2(stage.mouseX, stage.mouseY);
				myTimer.start();
				myTimer.addEventListener(TimerEvent.TIMER, tick);
			}
		}
		
		private function tick(e:TimerEvent):void{
			shouldFlee = false;
			myTimer.removeEventListener(TimerEvent.TIMER, tick);
		}

	}
	
}
