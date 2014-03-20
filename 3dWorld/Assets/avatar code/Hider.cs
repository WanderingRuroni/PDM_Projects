using UnityEngine;
using System.Collections;

public class Hider : MonoBehaviour {

	private CharacterController myCharacterController = null;
	public GameObject explorer = null;
	private Steering steerer = null;
	
	private Vector3 steeringForce = Vector3.zero;
	private Vector3 moveDirection;
	private float safeDistance;
	private GameObject[] obstacles;
	private float[] distances;
	
	private float[] minMax = new float[4];
	private Vector3 seekPt = new Vector3(159.0f, 41.0f, 214.0f);
	
	private float obstDist = 0.0f;
	
	public float friction = 0.997f;
	
	private bool shouldRun = false;
	private bool shouldHide = false;
	
	// Use this for initialization
	void Start () {
		myCharacterController = gameObject.GetComponent<CharacterController>();
		steerer = gameObject.GetComponent<Steering>();
		steerer.Radius = 5.0f;
		moveDirection = transform.forward;
		
		obstacles = GameObject.FindGameObjectsWithTag("Obstacle");
		distances = new float[obstacles.Length];
		
		minMax[0] = 92.0f;
		minMax[1] = 222.0f;
		minMax[2] = 20.0f;
		minMax[3] = 380.0f;
	}
	
	public Vector3 hide(GameObject explorer, GameObject[] obst, float tooClose)
	{
		// vector used for steering behavior
		Vector3 dv = Vector3.zero;
		float tempDist;
		obstDist = Vector3.Distance(obst[0].transform.position, transform.position);
		GameObject closestObst = obst[0];
		
		for(int i = 0; i < obst.Length; i++)
		{
			tempDist = Vector3.Distance(obst[i].transform.position, transform.position);
			
			
			if(tempDist < obstDist)
			{
				obstDist = tempDist;
			}
		}

		for(int j = 0; j < obst.Length; j++)
		{
			if(obstDist == Vector3.Distance(obst[j].transform.position, transform.position))
			{
				closestObst = obst[j];
				if(obst[j].layer == 2)
				{
					
				}
				else
					obst[j].layer = 2;
			}
		}
		
		float dist = Vector3.Distance(explorer.transform.position, transform.position);
		
		Vector3 explorerDir = closestObst.transform.position - explorer.transform.position;
		
		// normalizes the vector to keep its direction for use by the hider
		explorerDir = explorerDir.normalized;
		
		// a Vector3 position is found on the side opposite of the obstacle, away from the explorer
		Vector3 toHideSpot = closestObst.transform.position + (explorerDir * closestObst.GetComponent<Obstacle>().Radius * 1.5f);
		toHideSpot.y = transform.position.y;
		
		if(dist <= tooClose)
		{
			shouldRun = true;
			shouldHide = false;
			for(int j = 0; j < obst.Length; j++)
			{
				if(closestObst.transform.position == obst[j].transform.position)
					obst[j].layer = 0;
			}
		}
		
		if(shouldRun == true)
		{
			dv += steerer.flee(explorer) * 1.1f;
			shouldHide = false;
		}
		
		if(shouldHide == true)
		{
			dv += steerer.arrival(toHideSpot, 50);
		}
		
		return dv;
	}
	
	// Update is called once per frame
	void Update () {
		for(int i = 0; i < obstacles.Length; i ++)
		{
			distances[i] = Vector3.Distance(transform.position, obstacles[i].transform.position);	
		}
		
		CalcForces();
		ClampSteering();
		CalcVelocity();
		if(Vector3.Distance(explorer.transform.position, transform.position) < 60.0f)
			shouldHide = true;
		if(moveDirection != Vector3.zero)
			myCharacterController.Move(moveDirection * Time.deltaTime);
	}
	
	private void CalcVelocity()
	{
		moveDirection = transform.forward * steerer.Speed;
		// vehicle moves in forward direction
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
		
		moveDirection.y -= 2.0f;
	}
	
	// if steering forces exceed maxForce they are set to maxForce
	private void ClampSteering ()
	{
		if (steeringForce.magnitude > steerer.maxForce) {
			steeringForce.Normalize ();
			steeringForce *= steerer.maxForce;
		}
	}
	
	private void CalcForces()
	{
		steeringForce = Vector3.zero;
		if(shouldHide == true)
			steeringForce += hide(explorer, obstacles, 16.0f);
		else
		{
			steeringForce += steerer.wander() * 0.1f;
			shouldRun = false;
		}
		
		steeringForce += steerer.contain(minMax, seekPt) * 2;
		
		for(int i = 0; i < obstacles.Length; i++)
		{
			safeDistance = steerer.Radius + obstacles[i].GetComponent<Obstacle>().Radius * 2;
			if(Vector3.Dot(moveDirection, obstacles[i].transform.position - transform.position) < 0)
			{
				steeringForce += Vector3.zero;
			}
			else
				steeringForce += steerer.AvoidObstacle(obstacles[i], safeDistance);
		}
	}
}
