/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CPhysicsWorld
/** Copyright © 2009 CD Projekt RED
/***********************************************************************/

import struct SCollisionInfo
{
	import public var firstContactPoint : Vector;
	import public var collisionNormal : Vector;
	import public var impulseApplied : float;
	import public var soundMaterial : Int8;
	 
	// za doszywanie stringow do tej struktury bede urywal jaja
	// and i mean it.
	
	//import public var rigidBodyNameA : string;
	//import public var rigidBodyNameB : string;
};