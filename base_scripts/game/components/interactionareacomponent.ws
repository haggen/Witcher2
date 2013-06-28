/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CInteractionAreaComponent
/** Copyright © 2010
/***********************************************************************/

import class CInteractionAreaComponent extends CComponent
{
	// Get minimum range
	import final function GetRangeMin() : float;

	// Get maximum range
	import final function GetRangeMax() : float;

	// Check if entity is inside area
	import final function ActivationTest( activator : CEntity ) : bool;
	
	// Checks if point is inside observation fov region
	import final function ActivationPointTest( point : Vector ) : bool;
	
	// Override to perform additional activation checks (performScriptedTest flag must be set to true)
	event OnActivationTest( activator : CEntity ) { return true; }
}