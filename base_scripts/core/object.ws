/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Base object
/////////////////////////////////////////////

import class CObject
{
	// Get the parent of this object
	import function GetParent() : CObject;
	
	// Make clone of this object
	import function Clone( newParent : CObject ) : CObject;

	// Returns true if object is inside given other object ( checks using GetParent() ) 
	import function IsIn( other : CObject ) : bool;

	// Check if object is of given class
	import function IsA( className : name ) : bool;

	// Get human readable string description of object
	import function ToString() : string;
}
