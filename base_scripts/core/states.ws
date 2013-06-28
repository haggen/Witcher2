/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// State in a state machine
/////////////////////////////////////////////

import class CState extends CObject
{
	// Is this state the active one in the state machine
	import function IsActive() : bool;

	// Get the name of this state
	import function GetStateName() : name;

	// Called to check if this state can be entered
	event OnEnteringState() { return true; }

	// Called to check if this tate can be leaved
	event OnLeavingState() { return true; }

	// Called when we are entering this state
	event OnEnterState();

	// Called when we are leaving this state
	event OnLeaveState();
}

/////////////////////////////////////////////
// State machine
/////////////////////////////////////////////

import class CStateMachine
{
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// Get state by name, low level, use with care
	import final function GetState( stateName : name ) : CState;

	// Get the current state this state machine is in
	import final function GetCurrentState() : CState;

	// Get the name of the state this state machine is in
	import final function GetCurrentStateName() : name;

	// Change current state of state machine, returns false if something failed
	import final function ChangeState( newStateName : name ) : bool;

	// Stop related state code	
	import final function Stop();
	
	// Prevents activation of new entry function or new state
	import final function LockEntryFunction( lock : bool );
	
	// Set cleanup function
	import final function SetCleanupFunction( functionName : name );
	
	// Clear cleanup function
	import final function ClearCleanupFunction();
	
	// Enables entry function logging
	import final function DebugDumpEntryFunctionCalls( enabled : bool );
}
