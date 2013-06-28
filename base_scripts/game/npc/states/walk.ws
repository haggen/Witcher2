state MoveToTarget in CNewNPC extends ReactingBase
{
	event OnEnterState()
	{
		// Pass to base class
		//super.OnEnterState();
	}
	
	event OnLeaveState()
	{
		// Pass to base class
		super.OnLeaveState();
	}

	entry function StateMoveToTarget( targetPosition : Vector, targetHeading : float, moveType : EMoveType, speed : float, distance : float, exitWorkMode : EExitWorkMode, goalId : int )
	{		
		SetGoalId( goalId );
		parent.ChangeNpcExplorationBehavior();
		parent.ExitWork( exitWorkMode );
		parent.ActionMoveToWithHeading( targetPosition, targetHeading, moveType, speed, distance );		
		MarkGoalFinished();
	}
	
	event OnInteractionTalkTest()
	{
		return thePlayer.CanPlayQuestScene() && parent.CanPlayQuestScene() && parent.HasInteractionScene() && theGame.IsStreaming() == false && parent.IsUsingExploration() == false && parent.WasVisibleLastFrame() == true;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
		
	event OnMovementCollision( pusher : CMovingAgentComponent )
	{
		return true;
	}
	
	event OnPushed( pusher : CMovingAgentComponent )
	{
		parent.PushAway( pusher );
	}
}
