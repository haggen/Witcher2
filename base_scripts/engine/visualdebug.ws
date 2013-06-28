/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for visual debug
/** Copyright © 2009
/***********************************************************************/

// Retained debug visualization
import class CVisualDebug extends CObject
{
	// Add debug text
	import final function AddText
	(
		dbgName : name,
		text : string,
		optional position : Vector,		// ZEROS
		optional absolutePos : bool,	// false
		optional line : byte,			// 0
		optional color : Color,			// WHITE
		optional background : bool,		// false
		optional timeout : float		// -1.0
	);
	
	// Add debug sphere
	import final function AddSphere
	(
		dbgName : name,
		radius : float,
		optional position : Vector,		// ZEROS
		optional absolutePos : bool,	// false
		optional color : Color,			// WHITE
		optional timeout : float		// -1.0
	);
	
	// Add debug box
	import final function AddBox
	(
		dbgName : name,
		size : Vector,
		optional position : Vector,		// ZEROS
		optional rotation : EulerAngles,// ZEROS
		optional absolutePos : bool,	// false
		optional color : Color,			// WHITE
		optional timeout : float		// -1.0
	);
	
	// Add debug axis
	import final function AddAxis
	(
		dbgName : name,
		optional scale : float,			// 1.0
		optional position : Vector,		// ZEROS
		optional rotation : EulerAngles,// ZEROS
		optional absolutePos : bool,	// false
		optional timeout : float		// -1.0
	);
	
	// Add debug line
	import final function AddLine
	(
		dbgName : name,
		optional startPosition, endPosition : Vector,		// ZEROS
		optional absolutePos : bool,						// false
		optional color : Color,								// WHITE
		optional timeout : float							// -1.0
	);
	
	// Remove debug text
	import final function RemoveText( dbgName : name );
	
	// Remove debug sphere
	import final function RemoveSphere( dbgName : name );
	
	// Remove debug box
	import final function RemoveBox( dbgName : name );
	
	// Remove debug axis
	import final function RemoveAxis( dbgName : name );
	
	// Remove debug line
	import final function RemoveLine( dbgName : name );
};