/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Job system classes
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Job tree node
/////////////////////////////////////////////

import class CJobTree extends CResource
{
	// Get speed for the tree
	final function GetMovementSpeed( out moveType : EMoveType, out absSpeed : float );
}

/*
/////////////////////////////////////////////
// Job action
/////////////////////////////////////////////

import class CJobAction
{
	// Get the category of animation at this action node
	import final function GetAnimCategory() : string;
	
	// Get the name of the animation at this action node
	import final function GetAnimName() : string;
	
	// Get name of the place ( entity's waypoint ) at which this action should occur
	import final function GetPlace() : name;
	
	// Shoud path engine agent be disabled in this action
	import final function IsNoPathAgent() : bool;
}*/