/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** String processing functions
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Action point class
/////////////////////////////////////////////

import class CActionPointComponent extends CWayPointComponent
{
	// Get next action point that is in sequence with this one
	//import final function GetSeqNextActionPoint() : CActionPointComponent;

	// Get job tree related to this action point
	//import final function GetJobTree() : CJobTreeNode;
	
	// Try to reserve the action point
	//import final function TryReserve() : bool;
	 
	// Set action point as free
	//import final function SetFree();
	
	// Returns 'true' if the action point isn't occupied.
	//import final function IsFree() : bool;
	
	// Reset items in this action point
	//import final function ResetItems();
	
	// Returns the ID of action point
	import final function GetID();
}
