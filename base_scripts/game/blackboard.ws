/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** BlackBoard
/** Copyright © 2010
/***********************************************************************/

import class CBlackboard extends CObject
{
	// Add entry (update if exists)
	import final function AddEntryFloat	( entryName : name, number : float );
	import final function AddEntryVector( entryName : name, vec : Vector );
	import final function AddEntryTime	( entryName : name, time : EngineTime );
	import final function AddEntryEntity( entryName : name, entity : CEntity );
	
	// Get entry value, returns false if not found
	import final function GetEntryFloat	( entryName : name, out outNumber : float ) : bool;
	import final function GetEntryVector( entryName : name, out outVec : Vector ) : bool;
	import final function GetEntryTime	( entryName : name, out outTime : EngineTime ) : bool;
	import final function GetEntryEntity( entryName : name, out outEntity : CEntity ) : bool;
};
