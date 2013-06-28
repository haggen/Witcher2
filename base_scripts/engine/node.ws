/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Node class
/////////////////////////////////////////////

import class CNode extends CStateMachine
{
	// Get node name
	import final function GetName() : string;
	
	// Get node local position
	import final function GetLocalPosition() : Vector;
	
	// Get node local rotation
	import final function GetLocalRotation() : EulerAngles;
	
	// Get node local scale
	import final function GetLocalScale() : Vector;
	
	// Get node local to world matrix
	import final function GetLocalToWorld() : Matrix;
	
	// Get node world to local matrix
	import final function GetWorldToLocal() : Matrix;
	
	// Get node world position
	import final function GetWorldPosition() : Vector;
	
	// Get node world rotation
	import final function GetWorldRotation() : EulerAngles;
	
	// Get node heading ( world rotation yaw )
	import final function GetHeading() : float;
	
	// Return true is node has given tag
	import final function HasTag( tag : name ) : bool;
	
	// Get node tags
	import final function GetTags() : array< name >;
	
	// Set node tags
	import final function SetTags( tags : array< name > );
}

// Get node closest to position
import function FindClosestNode( position : Vector, nodes : array< CNode > ) : CNode;

// Sort nodes by distance to position
import function SortNodesByDistance( position : Vector, out nodes : array< CNode > );