using UnityEngine;
using System.Collections;
//including some .NET for dynamic arrays called List in C#
using System.Collections.Generic;

public class FlockManager : MonoBehaviour
{
	// weight parameters are set in editor and used by all flockers 
	// if they are initialized here, the editor will override settings	 
	// weights used to arbitrate btweeen concurrent steering forces 
	public float alignmentWt;
	public float separationWt;
	public float cohesionWt;
	public float avoidWt;
	public float inBoundsWt;

	// these distances modify the respective steering behaviors
	public float avoidDist;
	public float separationDist;
	

	// set in editor to promote reusability.
	public int numberOfFlockers;
	public Object flockerPrefab;
	public Object obstaclePrefab;
	
	public GameObject flockCentroid;
	
	//values used by all flockers that are calculated by controller on update
	private Vector3 flockDirection;
	private Vector3 centroid;
	
	//accessors
	public Vector3 FlockDirection { get {return flockDirection;} }
	public Vector3 Centroid { get {return centroid; } }
		
	// list of flockers with accessor
	private List<GameObject> flockers = new List<GameObject>();
	public List<GameObject> Flockers {get{return flockers;}}

	// array of obstacles with accessor
	private  GameObject[] obstacles;
	public GameObject[] Obstacles {get{return obstacles;}}
	
	// this is a 2-dimensional array for distances between flockers
	// it is recalculated each frame on update
	private float[,] distances;
		

	public void Start ()
	{
		
		//construct our 2d array based on the value set in the editor
		distances = new float[numberOfFlockers, numberOfFlockers];
		//reference to Vehicle script component for each flocker
		Flocking flocker; // reference to flocker scripts
	
		obstacles = GameObject.FindGameObjectsWithTag("Obstacle");
		
		for(int i = 0; i < numberOfFlockers; i++)
		{
			//Instantiate a flocker prefab, catch the reference, cast it to a GameObject
			//and add it to our list all in one line.
			flockers.Add((GameObject)Instantiate(flockerPrefab, 
				new Vector3(150+5*i,42,150), Quaternion.identity));
			//grab a component reference
			flocker = flockers[i].GetComponent<Flocking>();
			//set values in the Vehicle script
			flocker.Index = i;
			flocker.setFlockManager(this.gameObject);
		}
		
	}
	public void Update( )
	{
		calcCentroid( );//find average position of each flocker 
		flockCentroid.transform.position = centroid;
		calcFlockDirection( );//find average "forward" for each flocker
		calcDistances( );
	}
	
	
	void calcDistances( )
	{
		float dist;
		for(int i = 0 ; i < numberOfFlockers; i++)
		{
			for( int j = i+1; j < numberOfFlockers; j++)
			{
				dist = Vector3.Distance(flockers[i].transform.position, flockers[j].transform.position);
				distances[i, j] = dist;
				distances[j, i] = dist;
			}
		}
	}
	
	public float getDistance(int i, int j)
	{
		return distances[i, j];
	}
	
	
		
	private void calcCentroid ()
	{
		// calculate the current centroid of the flock
		// use transform.position
		
		Vector3 flockCenter = Vector3.zero;
		
		for(int i = 0; i < Flockers.Count; i++)
		{
			flockCenter = flockCenter + Flockers[i].transform.position;	
		}
		
		centroid = flockCenter/Flockers.Count;
	}
	
	private void calcFlockDirection ()
	{
		// calculate the average heading of the flock
		// use transform.position
		
		Vector3 comboFwd = Vector3.zero;
		Vector3 dv = Vector3.zero;
		
		for(int j = 0; j < Flockers.Count; j++)
		{
			comboFwd = comboFwd + Flockers[j].transform.forward;	
		}
		
		dv = comboFwd.normalized;
		
		flockDirection = dv;
	}
	
}