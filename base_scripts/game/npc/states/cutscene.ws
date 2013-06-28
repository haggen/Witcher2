/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Cutscene state
/////////////////////////////////////////////

state Cutscene in CNewNPC extends Base
{
	var csRunning : bool;
	
	event OnEnterState()
	{
		super.OnEnterState();
		
		parent.SetLookAtMode( LM_Cutscene );
	}
	
	event OnLeavingState()
	{
		return !csRunning;
	}
	
	event OnLeaveState()
	{
		parent.ResetLookAtMode( LM_Cutscene );
	
		// Pass to base class
		super.OnLeaveState();
	}
	
	event OnCutsceneStarted()
	{
		//Log( "ERROR OnCutsceneStarted : NPC is already in cutscene state");
		parent.GetArbitrator().AddGoalCutscene();
	}
	
	event OnCutsceneEnded()
	{
		csRunning = false;
		MarkGoalFinished();
		parent.OnCutsceneEnded();
	}
	
	entry function StateCutscene( goalId : int )
	{
		SetGoalId( goalId );
		csRunning = true;
	}
}
