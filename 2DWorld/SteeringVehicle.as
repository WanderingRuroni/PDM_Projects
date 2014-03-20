package  
{
	public class SteeringVehicle extends VectorTurtle
	{
		protected var _maxSpeed: Number = 250;
		protected var _maxForce: Number = 250;
		protected var _mass: Number = 0.5;
		
		private var stageRadius: Number;
		private var radius: Number;
		
		// vectors used for flock center finding and forward headings
		private var comboFwd : Vector2;
		private var flockCenter : Vector2;
		private var center: Vector2;
		
		// used for unaligned collision detection
		private var otherNearestApproach:Vector2;
		private var yourNearestApproach:Vector2;
	
		public function SteeringVehicle(aMan:WorldApp, aX:Number = 0, 
								aY:Number = 0, aSpeed:Number = 0) 
		{
			super(aMan, aX, aY, aSpeed);
			// initialize velocity to zero so movement results from applied force
			_velocity = new Vector2( );
			
			center = new Vector2(500, 400);
			stageRadius = 600;
			radius = aSpeed;
		}
		
		public function set maxSpeed(s:Number)		{_maxSpeed = s;	}
		public function set maxForce(f:Number)		{_maxForce = f;	}
		public function get maxSpeed( )		{ return _maxSpeed;	}
		public function get maxForce( )		{ return _maxForce; }
		public function get right( )		{ return fwd.perpRight( ); }
		public function get Velocity( )     { return _velocity; }
		public function get Radius()        { return radius; }


		override public function update(dt:Number): void
		{
			/*for(var i:Number = 0; i < _manager.TurtleArray.length; i++)
			{
				comboFwd = comboFwd.add(_manager.TurtleArray[i].fwd);
				flockCenter = flockCenter.add(_manager.TurtleArray[i].position);
			}*/
			//call calcSteeringForce (override in subclass) to get steering force
			var steeringForce:Vector2 = calcSteeringForce( ); 
			
			// clamp steering force to max force
			steeringForce = clampSteeringForce(steeringForce);
	
			// calculate acceleration: force/mass
			var acceleration:Vector2 = steeringForce.divide(_mass);
			// add acceleration for time step to velocity
			_velocity = _velocity.add(acceleration.multiply(dt));
			// update speed to reflect new velocity
			_speed = _velocity.magnitude( );
			
			// update fwd to reflect new velocity 
			fwd = _velocity;
			
			// clamp speed and velocity to max speed
			if (_speed > _maxSpeed)
			{
				_velocity = _velocity.divide(_speed);
				_velocity = _velocity.multiply(_maxSpeed);
				_speed = _maxSpeed;
			}
			// call move with velocity adjusted for time step
			move( _velocity.multiply(dt));
		}
		
				
		protected function calcSteeringForce( ):Vector2
		{
			var steeringForce:Vector2;
			//override in subclasses
			// add forces to create desired behavior
			return steeringForce;
		}

			
		private function clampSteeringForce(force: Vector2 ): Vector2
		{
			var mag:Number = force.magnitude();
			if(mag > _maxForce)
			{
				force = force.divide(mag);
				force = force.multiply(_maxForce);
			}
			return force;
		}
		
		private function timeOfClosestApproach(char:SteeringVehicle):Number
		{
			var t, b, c, e, f: Number;
            var  posDif: Vector2 = this.position.subtract(char.position);
            var velDif:  Vector2 = this.Velocity.subtract(char.Velocity);
            b = 2 * velDif.x * posDif.x;
            c = velDif.x * velDif.x;
            e = 2 * velDif.y * posDif.y;
            f = velDif.y * velDif.y;
            t = -(b + e)/ (2 * (c + f));
            return t;
		}
		
		private function computeFuturePositions(object:SteeringVehicle, time:Number):Number
		{
			var myTravel:Vector2 = fwd.multiply(_speed * time);
			var objTravel:Vector2 = object.fwd.multiply(object._speed * time);
			
			var finalTravel:Vector2 = position.add(myTravel);
			var otherFinal:Vector2 = object.position.add(objTravel);
			
			yourNearestApproach = finalTravel;
			otherNearestApproach = otherFinal;
			
			var distances:Number = finalTravel.distance(otherFinal);
			return distances;
		}
		
		protected function alignment(flock:Array):Vector2
		{
			var desVel:Vector2 = new Vector2();
			
			comboFwd = new Vector2();
			
			for(var i:Number = 0; i < flock.length; i++)
			{
				comboFwd = comboFwd.add(flock[i].fwd);
			}
			
			desVel = comboFwd.normalized().multiply(_maxSpeed);
			
			var steeringForce:Vector2 = desVel.subtract(_velocity);
			
			return steeringForce;
		}
		
		protected function cohesion(flock:Array):Vector2 
		{
			var desVel:Vector2 = new Vector2();
			flockCenter = new Vector2();
			
			for(var j:Number = 0; j < flock.length; j++)
			{
				flockCenter = flockCenter.add(flock[j].position);
			}
			
			flockCenter = flockCenter.divide(flock.length);
			
			desVel = desVel.add(seek(flockCenter));
			
			return desVel;
		}
		
		protected function separation(flock:Array, tooClose:Number):Vector2 
		{
			var desVel:Vector2 = new Vector2();
			var closer:Vector2 = new Vector2();
			var dist:Number;
			var closeMates:Array = new Array();
			var closeDistance:Array = new Array();
			var normalMates:Array = new Array();
			
			for(var l:Number = 0; l < flock.length; l++)
			{
				dist = this.position.distance(flock[l].position);
				if(dist < tooClose && dist > 0)
				{
					closeMates.push((flock[l].position));
					closeDistance.push(dist);
				}
			}
			
			for(var m:Number = 0; m < closeMates.length; m++)
			{
				closer = closer.add(flee(closeMates[m]).multiply(1/closeDistance[m]));
			}
			
			desVel = closer.normalized().multiply(_maxSpeed);
			
			return desVel.subtract(_velocity);
		}
		
		protected function contain(minMax:Array, seekPt:Vector2):Vector2
		{
			// requires a normal vector from the containing structure
			// use minx, maxX, miny, maxy
			var steeringForce:Vector2 = new Vector2();
			var surfaceNormal:Vector2;
			var offset:Vector2
			var futurePos:Vector2 = position.add(fwd.multiply(this.speed));
			if(futurePos.x < minMax[1] && futurePos.x > minMax[0] && futurePos.y < minMax[3] && futurePos.y > minMax[2])
			{
				return steeringForce;
			}
			else if(futurePos.x < minMax[0])
			{
				surfaceNormal = new Vector2(minMax[0], futurePos.y);
				offset = surfaceNormal.add(right.multiply(this.speed * 2));
				steeringForce = seek(offset);
			}
			else if(futurePos.x > minMax[1])
			{
				surfaceNormal = new Vector2(minMax[1], futurePos.y);
				offset = surfaceNormal.subtract(right.multiply(this.speed * 2));
				steeringForce = seek(offset);
			}
			else if(futurePos.y < minMax[2])
			{
				surfaceNormal = new Vector2(futurePos.x, minMax[2]);
				offset = surfaceNormal.subtract(right.multiply(this.speed * 2));
				steeringForce = seek(offset);
			}
			else if(futurePos.y > minMax[3])
			{
				surfaceNormal = new Vector2(futurePos.x, minMax[3]);
				offset = surfaceNormal.add(right.multiply(this.speed * 2));
				steeringForce = seek(offset);
			}
			
			if(position.x < minMax[0] || position.y < minMax[2] || position.x > minMax[1] || position.y > minMax[3])
			{
				steeringForce = seek(seekPt);
			}
			
			return steeringForce;
		}
		
			
		protected function seek(targPos : Vector2) : Vector2
		{
			// set desVel equal desired velocity
			var desVel:Vector2 = targPos.subtract(position);

			// scale desired velocity to max speed
			desVel = desVel.normalized().multiply(_maxSpeed);

			// subtract current velocity from desired velocity
			// to get steering force
			var steeringForce:Vector2 = desVel.subtract(_velocity);
		
			//return steering force
			return steeringForce;
		}
		
		protected function arrival(targPos: Vector2, dist:Number) : Vector2
		{
			var targOff:Vector2 = targPos.subtract(this.position);
			var distance:Number = targOff.magnitude();
			var rampedSpeed:Number = _maxSpeed * (distance/dist);
			var clippedSpeed:Number = Math.min(rampedSpeed, _maxSpeed);
			var desVel:Vector2 = targOff.multiply(clippedSpeed/distance);
			var steeringForce = desVel.subtract(_velocity);
			return steeringForce;
		}
		
		protected function leaderFollow(targPos:Leader, flock:Array, tooClose:Number, position:Number) : Vector2
		{
			var leaderPos:Vector2;
			var tempPos:Vector2;
			
			tempPos = _manager.Flock[position].position;
			leaderPos = tempPos.add(_manager.Flock[position].fwd.multiply(-20));
			
			var steeringForce:Vector2 = arrival(leaderPos, 80);
			steeringForce = steeringForce.add(separation(flock, tooClose));
			if(this.position.distance(leaderPos) <= tooClose)
			{
				steeringForce = unalignedAvoidance(2, flock);
				return steeringForce;
			}
			return steeringForce;
		}
		
		protected function unalignedAvoidance(minTime:Number, neighbors:Array):Vector2
		{
			var steeringForce:Vector2 = new Vector2();
			var steer:Number = 0;
			var threat:SteeringVehicle = null;
			
			var minimalTime:Number = minTime;
			var offset:Vector2 = new Vector2();
			
			for(var j:Number = 0; j < neighbors.length; j++)
			{
				var other:SteeringVehicle = neighbors[j];
				
				var dangerThreshold:Number = other.Radius * 10;
				
				var myTime:Number = timeOfClosestApproach(other);
			
				if(myTime >= 0 && myTime < minTime)
				{
					if(computeFuturePositions(other, myTime) < dangerThreshold)
					{
						minimalTime = myTime;
						threat = other;
					}
				}
			}
			
			if(threat != null)
			{
				var parallel:Number = fwd.dot(threat.fwd);
				var angle:Number = .707;
				
				if(parallel < -angle)
				{
					offset = otherNearestApproach.subtract(this.position);
					var sideDot:Number = offset.dot(this.right);
					steer = (sideDot > 0) ? -1 : 1;
				}
				else
				{
					if(parallel > angle)
					{
						offset = threat.position.subtract(this.position);
						var someDot:Number = offset.dot(this.right);
						steer = (someDot > 0) ? -1 : 1;
					}
					else
					{
						if(threat.speed <= this.speed)
						{
							var otherDot:Number = this.right.dot(threat.Velocity);
							steer = (otherDot > 0) ? -1 : 1;
						}
					}
				}
			}
			
			steeringForce = right.multiply(steer * 5);
			return steeringForce;
		}
		
		protected function flee(targPos : Vector2) : Vector2
		{
			//similar to seek - opposite direction for desVel
			var desVel:Vector2 = position.subtract(targPos);
			
			desVel = desVel.normalized().multiply(_maxSpeed);
			
			var steeringForce:Vector2 = desVel.subtract(_velocity);
			
			return steeringForce;
		}
		

		protected function avoid(obstaclePos:Vector2, obstacleRadius:Number, safeDistance:Number): Vector2 
		{
			var desVel: Vector2; //desired velocity
			var vectorToObstacleCenter: Vector2 = obstaclePos.subtract(position);
			var distance: Number = vectorToObstacleCenter.magnitude();
			//if vectorToCenter - obstacleRadius longer than safe return zero vector
			if((distance - obstacleRadius) > safeDistance)
			{
				return new Vector2();
			}
			 
			// if object behind me return zero vector
			if(vectorToObstacleCenter.dot(fwd) < 0)
			{
				return new Vector2();
			}
			 
			var rightDotVTOC:Number = vectorToObstacleCenter.dot(right);
			// if sum of radii < dot of vectorToCenter with right return zero vector
			if((obstacleRadius + this.radius) < Math.abs(rightDotVTOC))
			{
				return new Vector2();
			}
			 
			//desired velocity is to right or left depending on 
			// sign of  dot of vectorToCenter with right 
			//option: increase magnitude when obstacle is close
			if(rightDotVTOC < 0) {
				desVel = right;
			}
			else {
				desVel = right.multiply(-1);
			}
			
			desVel = desVel.multiply(safeDistance/distance);
			
			desVel = desVel.multiply(_velocity.magnitude());
			
			var steeringForce = desVel.subtract(_velocity);
			
			//subtract current velocity from desired velocity to get steering force
			return steeringForce;
		}
			
	}
}



