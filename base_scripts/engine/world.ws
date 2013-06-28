/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CWorld
/** Copyright © 2010 CD Projekt RED
/***********************************************************************/

import class CWorld extends CResource
{
	// Show layer group
	import final function ShowLayerGroup( layerGroupName : string );

	// Hide layer group
	import final function HideLayerGroup( layerGroupName : string );
	
	// Trace
	import final function PointProjectionTest( point : Vector, normal : EulerAngles, range : float ) : bool; 
	
	// Trejs
	import final function StaticTrace( pointA, pointB : Vector, out position, normal : Vector, optional layer : ECollisionLayerType ) : bool;
};
