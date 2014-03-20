package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.utils.*;
	import flash.ui.*;
	
	public class WorldApp extends MovieClip
	{
		private var _dt					: Number;			// clock time since last update 
		private var _lastTime			: Number;			// for calculating dt
		private var _curTime			: Number;			// for calculating dt
		private var leader              : Leader;           // used for leader following
		private var flock               : Array ;           // used for leader following
		private var school              : Array;            // used for flocking of fish
		private var groupings           : Array;            // used for pedestrian unaligned collision
		private var pond                : Pond;             // used for keeping certain characters in the pond
		private var dragon              : Array;        
		private var sidewalk            : SideWalk;         // used for human unaligned avoidance
		private var minMaxWorld         : Array             // used for animals outside the sidewalk
	
		public function WorldApp( )
		{
			//event listener for to drive frame loop
			addEventListener(Event.ENTER_FRAME, frameLoop);
			flock = new Array();
			school = new Array();
			groupings = new Array();
			minMaxWorld = new Array();
			dragon = new Array();
			this.buildWorld( );
		}
		
		public function get Lead(): Leader { return leader; }
		
		public function get Flock(): Array { return flock; }
		
		public function get School(): Array { return school; }
		
		public function get Groupings(): Array { return groupings; }
		
		public function get MyPond(): Pond { return pond; }
		
		public function get MySidewalk(): SideWalk { return sidewalk; }
		
		public function get MinMaxWorld(): Array { return minMaxWorld; }
		
		// make the characters
		private function buildWorld( ): void
		{
			minMaxWorld[0] = 0;
			minMaxWorld[1] = 800;
			minMaxWorld[2] = 0;
			minMaxWorld[3] = 800;
			
			pond = new Pond(this, 300, 400);
			addChild(pond);
			
			sidewalk = new SideWalk(this, 925, 400);
			addChild(sidewalk);
			
			for(var l:Number = 0; l < 30; l++)
			{
				var fish = new FishSchool(this, (Math.random()* 200)+ 200, (Math.random() * 200) + 200, 10);
				school.push(fish);
			}
			
			leader = new Leader(this, 400, 400, 25);
			flock.push(leader);
			
			for(var i:Number = 0; i < 9; i++)
			{
				var baby:Followers = new Followers(this, (Math.random()* 600)+ 200, (Math.random() * 400) + 200, i, 20);
				flock.push(baby);
			}
			
			for(var m:Number = 0; m < 5; m++)
			{
				var dragonfly:DragonFly = new DragonFly(this, 200, 700, 15);
				dragon.push(dragonfly);
			}
			
			
			for(var j:Number = 0; j < 10; j++)
			{
				var human:Pedestrians = new Pedestrians(this, (875 + (j * 10)), (Math.random() * 600) + 100, 10);
				human.turnLeft(90);
				groupings.push(human);
			}
			
			for(var k:Number = 0; k < 10; k++)
			{
				var human1:Pedestrians = new Pedestrians(this, (875 + (k*10)), (Math.random() * 600) + 100, 10);
				human1.turnRight(90);
				groupings.push(human1);
			}
			
			_lastTime = getTimer( );
		}
		
		//This frameloop sends an update message to each turtle in the turtleArray
		private function frameLoop(e: Event ):void
		{
			// do update based on clock time
			_curTime = getTimer( );
			_dt = (_curTime - _lastTime)/1000;
			_lastTime = _curTime;
			
			leader.update(_dt);
			
			for(var i:Number = 0; i < flock.length; i++)
			{
				flock[i].update(_dt);
			}
			
			for(var j:Number = 0; j < school.length; j++)
			{
				school[j].update(_dt);
			}
			
			for(var k:Number = 0; k < dragon.length; k++)
			{
				dragon[k].update(_dt);
			}
			
			for(var l:Number = 0; l < groupings.length; l++)
			{
				groupings[l].update(_dt);
			}
			
			
		}
	}
}




