/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CAreaComponent & CTriggerAreaComponent
/** Copyright © 2010
/***********************************************************************/

import class CAreaComponent extends CBoundedComponent
{
	// Test if given point is inside the area
	import final function TestPointOverlap( point : Vector ) : bool;
	
	// Get local points
	import final function GetLocalPoints( out points : array<Vector> );
	
	// Get world points
	import final function GetWorldPoints( out points : array<Vector> );
	
	// Get radius of a sphere that contains area
	import final function GetBoudingAreaRadius() : float;
}

import class CTriggerAreaComponent extends CAreaComponent
{
}