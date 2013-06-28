/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CBehTreeMachine
/** Copyright © 2009 .
/***********************************************************************/

/*enum EBTNodeStatus
{
	BTNS_Invalid,
	BTNS_New,
	BTNS_Active,
	BTNS_Failed,
	BTNS_Completed,
	BTNS_Aborted
	BTNS_RepeatTree,	
};*/

/////////////////////////////////////////////////////////////////////
// CBehTreeMachine
/////////////////////////////////////////////////////////////////////
import class CBehTreeMachine extends CObject
{
	// Is stopped
	import final function IsStopped() : bool;

	// Initialize tree machine
	import final function Initialize( tree : CBehTree ) : bool;
	
	// Uninitialize tree machine
	import final function Uninitialize();

	// Stop tree machine
	import final function Stop();
	
	// Restart tree
	import final function Restart( optional oneExecution : bool /* = false */ );
	
	// Enable debug dump restart
	import final function EnableDebugDumpRestart( enable : bool );
	
	// Get info
	import final function GetInfo() : string;
};


/////////////////////////////////////////////////////////////////////
// IBehTreeTask
/////////////////////////////////////////////////////////////////////
import class IBehTreeTask extends CObject
{	
	// Set result value
	import final function SetResultValue( value : int );	
	
	// Get actor
	import final function GetActor() : CActor;
	
	// Get NPC
	import final function GetNPC() : CNewNPC;
	
	// Called on begin, can return BTNS_Failed, BTNS_Completed, BTNS_Active or BTNS_RepeatTree (keep commented)
	//function OnBegin() : EBTNodeStatus { return BTNS_Active; }
	
	// Called on abort (keep commented)
	//function OnAbort();
	
	// Main function header, can return BTNS_Failed, BTNS_Completed, or BTNS_RepeatTree (keep commented)
	//latent function Main() : EBTNodeStatus;
	
	// Get label function (keep commented)
	//function GetLabel( out label : string );
	
	// On anim event (keep commented)
	//event OnAnimEvent( animEventName : name, animEventType : EAnimationEventType );
	
	// Get target node
	private function GetTargetNode() : CNode
	{		
		var npc : CNewNPC = GetNPC();
		if( npc.IsInCombat() )
		{
			return npc.GetTarget();		
		}
		else
		{
			return npc.GetFocusedNode();		
		}
	}
	
	// Get target position
	private function GetTargetPosition() : Vector
	{		
		var npc : CNewNPC = GetNPC();
		if( npc.IsInCombat() )
		{			
			return npc.GetTarget().GetWorldPosition();
		}
		else
		{
			return npc.GetFocusedPosition();
		}
	}
};

/////////////////////////////////////////////////////////////////////
// Debug
/////////////////////////////////////////////////////////////////////
import function DebugBehTreeStart( machine : CBehTreeMachine );
import function DebugBehTreeStopAll();
