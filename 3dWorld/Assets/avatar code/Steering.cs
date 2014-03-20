using UnityEngine;
using System.Collections;
//including some .NET for dynamic arrays called List in C#
using System.Collections.Generic;

//directive to enforce that our parent Game Object has a Character Controller
[RequireComponent(typeof(CharacterController))]

public class Steering : MonoBehaviour
{

	private CharacterController myCharacterController = null;

	//movement variables - exposed in inspector panel
	public float maxSpeed = 50.0f;
	//maximum speed of vehicle
	public float maxForce = 15.0f;
	// maximimum force allowed
	
	//movement variables - updated by this component
	private float speed = 0.0f;
	//current speed of vehicle
	private Vector3 steeringForce;
	// force that accelerates the vehicle
	private Vector3 velocity = Vector3.zero;
	//change in position per second
	
	private float rad;
	private float wanderAng_ = 0;
	
	public Vector3 Velocity {get {return velocity;}}
		
	public float Speed {
		get { return speed; }
		set { speed = Mathf.Clamp (value, 0, maxSpeed); }
	}
	
	public void Start ()
	{
		//get component reference
		myCharacterController = gameObject.GetComponent<CharacterController> ();
		float x = renderer.bounds.extents.x;
		float z = renderer.bounds.extents.z;
		rad = Mathf.Sqrt (x * x + z * z);
	}
	
	public float Radius {
		get {
			//Mesh mesh = GetComponent<MeshFilter> ().mesh;
			//Debug.Log (mesh.bounds.size.x * transform.localScale.x);
			return rad;
		}
		set {
			rad = value;	
		}
	}

	
	public Vector3 seek (Vector3 pos)
	{
		// find dv, the desired velocity
		Vector3 dv = pos - transform.position;
		dv.y = 0; //only steer in the x/z plane
		dv = dv.normalized * maxSpeed;//scale by maxSpeed
		dv -= transform.forward * speed;//subtract velocity to get vector in that direction
		return dv;
	}
	
	// same as seek pos above, but parameter is game object
	public Vector3 seek (GameObject gO)
	{
		return seek(gO.transform.position);
	}
	
	public Vector3 interpose(GameObject g1, GameObject g2)
	{
		Vector3 futurePos0 = g1.transform.position + (transform.forward * Speed);
		Vector3 futurePos1 = g2.transform.position;
		
		// uses interpolation to find a point from min obstacle position to the max of explorer position
		Vector3 interpolatedPt = Vector3.Lerp(futurePos0, futurePos1, 0.5f);
		interpolatedPt.y = transform.position.y;
		
		// This method just seeks the midpoint between the points
		//Vector3 interpolatedPt = new Vector3((futurePos0.x + futurePos1.x)/2, (futurePos0.y + futurePos1.y)/2, (futurePos0.z + futurePos1.z)/2);
		
		return arrival(interpolatedPt, 40);
	}
	
	public Vector3 contain(float[] minMax, Vector3 seekPt)
	{
		Vector3 steeringForce = Vector3.zero;
		Vector3 surfaceNormal;
		Vector3 offset;
		Vector3 futurePos = transform.position + (transform.forward * Speed);
		
		if(futurePos.x < minMax[1] && futurePos.x > minMax[0] && futurePos.z < minMax[3] && futurePos.z > minMax[2])
			return steeringForce;
		else if(futurePos.x < minMax[0])
		{
			surfaceNormal = new Vector3(minMax[0], futurePos.y, futurePos.z);
			if(futurePos.z > transform.position.z)
				offset = surfaceNormal + (transform.right * Speed * 2);
			else
				offset = surfaceNormal - (transform.right * Speed * 2);
			steeringForce = seek(offset);
		}
		else if(futurePos.x > minMax[1])
		{
			surfaceNormal = new Vector3(minMax[1], futurePos.y, futurePos.z);
			if(futurePos.z > transform.position.z)
				offset = surfaceNormal - (transform.right * Speed * 2);
			else
				offset = surfaceNormal + (transform.right * Speed * 2);
			steeringForce = seek(offset);
		}
		else if(futurePos.z < minMax[2])
		{
			surfaceNormal = new Vector3(futurePos.x, futurePos.y, minMax[2]);
			if(futurePos.x > transform.position.x)
				offset = surfaceNormal - (transform.right * Speed * 2);
			else
				offset = surfaceNormal + (transform.right * Speed * 2);
			steeringForce = seek(offset);
		}
		else if(futurePos.z > minMax[3])
		{
			surfaceNormal = new Vector3(futurePos.x, futurePos.y, minMax[3]);
			if(futurePos.x > transform.position.x)
				offset = surfaceNormal + (transform.right * Speed * 2);
			else
				offset = surfaceNormal - (transform.right * Speed * 2);
			steeringForce = seek(offset);
		}
		else
			return seek(seekPt);
		
		return steeringForce;
	}
	
	public Vector3 wander()
	{
		wanderAng_ += calcRandom() * 10; 
		Vector3 redDot = transform.position + (transform.forward * 12);
		Vector3 offset = transform.position + (transform.forward * 6);
		Vector3 newVec = Quaternion.AngleAxis(wanderAng_, Vector3.up) * offset;
		redDot = redDot + newVec;

		return seek(redDot);
	}
	
	public Vector3 arrival(Vector3 g1, int dist)
	{
		Vector3 targOff = g1 - transform.position;
		float distance = targOff.magnitude;
		float rampedSpeed = maxSpeed * (distance/dist);
		float clippedSpeed = Mathf.Min(rampedSpeed, maxSpeed);
		Vector3 dv = targOff * ( clippedSpeed/distance);
		dv -= transform.forward * speed;
		return dv;
	}

	public Vector3 flee (Vector3 pos)
	{
		Vector3 dv = transform.position - pos;//opposite direction from seek 
		dv.y = 0;
		dv = dv.normalized * maxSpeed;
		dv -= transform.forward * speed;
		return dv;
	}
	
	public Vector3 flee (GameObject go)
	{
		Vector3 targetPos = go.transform.position;
		targetPos.y = transform.position.y;
		Vector3 dv = transform.position - targetPos;
		dv = dv.normalized * maxSpeed;
		return dv - transform.forward * speed;
	}

	public Vector3 alignTo (Vector3 direction)
	{
		// useful for aligning with flock direction
		Vector3 dv = direction.normalized;
		//dv.y = 0; //stay in x/z plane
		return dv * maxSpeed - transform.forward * speed;
		
	}

	//Assumtions:
	// we can access radius of obstacle
	// we have CharacterController component
	public Vector3 AvoidObstacle (GameObject obst, float safeDistance)
	{
		Vector3 dv = Vector3.zero;
		//compute a vector from charactor to center of obstacle
		Vector3 vecToCenter = obst.transform.position - transform.position;
		
		//eliminate y component so we have a 2D vector in the x, z plane
		vecToCenter.y = 0;
		float dist = vecToCenter.magnitude;
		
		//return zero vector if too far to worry about
		if (dist > safeDistance)
			return dv;
		
		//Debug.DrawLine(vecToCenter, transform.forward, Color.red);
		
		//return zero vector if behind us
		if (Vector3.Dot (vecToCenter, transform.forward) < 0)
			return dv;
		
		//return zero vector if we can pass safely
		float rightDotVTC = Vector3.Dot (vecToCenter, transform.right);
		//float upDotVTC = Vector3.Dot(vecToCenter, transform.up);
		
		if (Mathf.Abs (rightDotVTC) > obst.GetComponent<Obstacle> ().Radius)
			return dv;
		
		/*if(Mathf.Abs(upDotVTC) > obst.GetComponent<Obstacle> ().Radius + Radius)
			return dv;*/
		
		//obstacle on right so we steer to left
		if (rightDotVTC > 0)
			dv = transform.right * -maxSpeed * safeDistance / dist;
		else
		//obstacle on left so we steer to right
			dv = transform.right * maxSpeed * safeDistance / dist;
		
		/*if(upDotVTC > 0)
			dv = dv + (transform.up * -maxSpeed * safeDistance/dist);
		else
			dv = dv + (transform.up * maxSpeed * safeDistance/dist);*/
		
		//stay in x/z plane
		dv.y = 0;
		
		//compute the force
		dv -= transform.forward * speed;
		return dv;
	}
	
	// helper function for wander
	private float calcRandom()
	{
		float initial = Velocity.magnitude;
		float nextSpeed = initial + ((Random.value * 2) -1) * maxSpeed;
		if(nextSpeed < -1)
			return -1;
		if(nextSpeed > 1)
			return 1;
		
		return initial;
	}


}