using UnityEngine;
using System.Collections;

public class Seeker : MonoBehaviour {
	
	private CharacterController myCharacterController = null;
	public GameObject nest = null;
	public GameObject explorer = null;
	private Steering steerer = null;
	
	private Vector3 steeringForce = Vector3.zero;
	private Vector3 moveDirection;
	private float safeDistance;
	private GameObject[] obstacles;
	
	public float maxSpeed = 50.0f;
	public float maxForce = 8.0f;
	public float friction = 0.997f;
	
	private float[] minMax = new float[4];
	private Vector3 seekPt = new Vector3(159.0f, 41.0f, 214.0f);
	
	// Use this for initialization
	void Start () {
		myCharacterController = gameObject.GetComponent<CharacterController>();
		steerer = gameObject.GetComponent<Steering>();
		moveDirection = transform.forward;
		
		obstacles = GameObject.FindGameObjectsWithTag("Obstacle");
		
		minMax[0] = 92.0f;
		minMax[1] = 300.0f;
		minMax[2] = 20.0f;
		minMax[3] = 380.0f;
	}
	
	// Update is called once per frame
	void Update () {
		CalcForces();
		ClampSteering();
		CalcVelocity();
		if(moveDirection != Vector3.zero)
			myCharacterController.Move(moveDirection * Time.deltaTime);
	}
	
	private void CalcVelocity()
	{
		moveDirection = transform.forward * steerer.Speed;
		// movedirection equals velocity
		//add acceleration
		moveDirection += steeringForce * Time.deltaTime;
		//update speed
		steerer.Speed = moveDirection.magnitude;
		if (steerer.Speed != moveDirection.magnitude) {
			moveDirection = moveDirection.normalized * steerer.Speed;
		}
		//orient transform
		if (moveDirection != Vector3.zero)
			transform.forward = moveDirection;
		
		moveDirection.y -= 5.0f;
	}
	
	// if steering forces exceed maxForce they are set to maxForce
	private void ClampSteering ()
	{
		if (steeringForce.magnitude > maxForce) {
			steeringForce.Normalize ();
			steeringForce *= maxForce;
		}
	}
	
	private void CalcForces()
	{
		steeringForce = Vector3.zero;
		float begin = Vector3.Distance(explorer.transform.position, nest.transform.position);
		if(begin < 60.0f)
		{
			steeringForce += steerer.interpose(nest, explorer);
		}
		
		if(Vector3.Distance(transform.position, nest.transform.position) > 30.0f)
		{
			steeringForce += steerer.arrival(nest.transform.position, 150);	
		}
		else
			steeringForce += steerer.wander() * 0.03f;
		
		steeringForce += steerer.contain(minMax, seekPt) * 3;
		
		for(int i = 0; i < obstacles.Length; i++)
		{
			safeDistance = steerer.GetComponent<Steering>().Radius + obstacles[i].GetComponent<Obstacle>().Radius * 4;
			steeringForce += steerer.AvoidObstacle(obstacles[i], safeDistance);
		}
		
	}
}
