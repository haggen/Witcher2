/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Action Point Manager
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// Action Point Manager
/////////////////////////////////////////////
import class CActionPointManager extends CObject
{
	// Returns true if action point has preferred next action points
	import final function HasPreferredNextAPs( currApID : int ) : bool;

	// Gets the next action point in sequence
	import final function GetSeqNextActionPoint( currApID : int ) : int;

	// Gets job tree related to the action point
	import final function GetJobTree( apID : int ) : CJobTree;

	// Returns 'true' if the action point isn't occupied
	import final function IsFree( apID : int ) : bool;

	// Tries to reserve the action point, returns true on success
	import final function TryReserve( userName : string, apID : int ) : bool;

	// Sets the action point as free
	import final function SetFree( userName : string, apID : int );

	// Resets items in the action point
	import final function ResetItems( apID : int );
	
	// Gets position, path engine position and rotation of the action point.
	import final function GetGoToPosition( apID : int, out placePos : Vector, out placeRot : float ) : bool;

	// Gets position at which the job should be executed
	import final function GetActionExecutionPosition( apID : int, out placePos : Vector, out placeRot : float ) : bool;
	
	// Gets friendly name for action point (for debug purposes only)
	import final function GetFriendlyAPName( apID : int ) : string;
	
	// Returns true if work in action point with ID 'id' can be interrupted
	import final function IsBreakable( apID : int ) : bool;
	
	// Returns true if work in action point with ID 'id' can be interrupted
	import final function GetPlacementImportance( apID : int ) : EWorkPlacementImportance;
}
