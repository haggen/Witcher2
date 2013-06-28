// Say greeting on interaction state
// ---------------------------------

state Talk in CNewNPC extends Base
{
	event OnEnterState()
	{
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
	}

	entry function StateTalk( goalId : int )
	{
		var pos : Vector;
		var norm : Vector;
		
		SetGoalId( goalId );
		
		if ( !parent.IsSpeaking() )
		{
			parent.GetComponent("talk").SetEnabled( false );
			//parent.ActionExitWork( false );
			//parent.ActionRotateTo( thePlayer.GetWorldPosition() );
			parent.PlayVoiceset(100, "greeting_reply" );	
			//parent.EnableDynamicLookAt( thePlayer, 10.0 );
			parent.WaitForEndOfSpeach();
			//parent.DisableLookAt();
			parent.GetComponent("talk").SetEnabled( true );		
		}
		
		MarkGoalFinished();
		
	}
};