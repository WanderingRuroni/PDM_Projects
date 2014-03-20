using UnityEngine;
using System.Collections;

public class Waypoint : MonoBehaviour {
	
	public GameObject next;
	public GameObject previous;
	
	private Vector3 unitDir;
	private Vector3 prevToWp;
	private float distToWp;
	
	public GameObject Next
	{
		get { return next; }
		set { next = value; }
	}
	
	public GameObject Previous
	{
		get { return previous; }
		set { previous = value; }
	}
	
	// Use this for initialization
	void Start () {
		
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}
	
	/* public Vector3 closestPoint(Vector3 futurePos)
	{
		// recognize special cases when your future position is past the next
		// waypoint or it is before the previous waypoint
	}*/
}
