package  
{
	import flash.display.MovieClip;
	
	public class VectorTurtle extends MovieClip
	{
		protected var _position : Vector2;
		protected var _fwd : Vector2;
		protected var _velocity : Vector2;
		protected var _speed : Number;
		protected var _manager: WorldApp;
		
		
		//constructor 
		public function VectorTurtle(aMan:WorldApp, anX:Number = 0, 
								aY:Number = 0, aSpeed:Number = 10) 
		{
			_manager = aMan;
			x= anX;
			y = aY;
			_position = new Vector2(x, y);
			_speed = aSpeed;
			_fwd = new Vector2(1, 0);
			_velocity = _fwd.multiply(_speed);
		}

		//accessors and mutators -- getters and setters
		public function get position( )		: Vector2				{ return  _position;	}
		public function get speed( )        : Number                { return _speed;        }
		public function get fwd( )			: Vector2				{ return _fwd;			}
		
		public function set position(pos : Vector2): void
		{
			_position.x = pos.x;
			_position.y = pos.y; 
			x = pos.x;
			y = pos.y;
		}
		
		// assigning a new value to the fwd vector requires adjusting rotation
		public function set fwd(vec: Vector2): void
		{
			_fwd.x = vec.x;
			_fwd.y = vec.y;
			_fwd.normalize( );
			rotation = _fwd.angle;
		}
		
		public function set speed(spd:Number):void
		{
			_speed = spd;
		}
		
		//-----------------WRITE THESE FUNCTIONS----------------------//
		public function update( dt : Number): void
		{
			// calculate _velocity
			_velocity = _fwd.multiply(_speed);
			// call move passing in velocity modified to reflect dt (elapsed time)
			move(_velocity.multiply(dt));
		}
	
		//turn ang degrees clockwise
		public function turnRight(ang: Number): void
		{
			// change rotation
			rotation += ang;
			// change forward vector to reflect new orientation
			_fwd.rotate(ang);
		 }
		
		public function turnLeft(ang: Number): void
		{
			// change rotation
			rotation -= ang;
			// change forward vector to reflect new orientation
			_fwd.rotate(-ang);
		}
		
		
		public function move( motion:Vector2): void
		{
			// calculate new position by adding the motion vector to old position
			_position = _position.add(motion);
			// update MovieClip's coordinates 
			x = position.x;
			y = position.y;
			
		}
		
		//-----------------ADDITIONAL FUNCTIONS-----------------//
		
		public function turnAbs(ang: Number): void
		{
			rotation = ang;
			_fwd = Vector2.degToVector(rotation);
		}

	}
}
