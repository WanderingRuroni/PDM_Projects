using UnityEngine;
using System.Collections;

public class Obstacle : MonoBehaviour {

	private float rad;
	public bool taken;
	
	// Use this for initialization
	void Start () {
		float x = renderer.bounds.extents.x;
		float z = renderer.bounds.extents.z;
		rad = Mathf.Sqrt (x * x + z * z);
		taken = false;
	}
	
	public float Radius {
		get {
			return rad;
		}
	}
	
	public bool Taken {
		get {
			return taken;	
		}
		
		set {
			taken = value;	
		}
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
