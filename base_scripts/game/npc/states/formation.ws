/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Formation state
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Formation state
/////////////////////////////////////////////

state Formation in CNewNPC extends ReactingBase
{
	var formationFollowed : CFormation;
	
	event OnEnterState() 
	{
		super.OnEnterState();
	}
	
	event OnLeaveState()
	{
		if ( formationFollowed )
		{
			formationFollowed.RemoveMember( parent );
			formationFollowed = NULL;
		}
	}
	
	//////////////////////////////////////////////////////////////////
	
	entry function StateFollowFormation( formation : CFormation, goalId : int )
	{
		var wasAdded : bool;
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();
		
		formationFollowed = formation;
		
		if ( formationFollowed )
		{
			wasAdded = formationFollowed.AddMember( parent );
			if ( wasAdded )
			{
				while ( formationFollowed )
				{
					Sleep( 2.f );
				}
			}
		}
		
		MarkGoalFinished();		
	}

	//////////////////////////////////////////////////////////////////////////////////////////

	event OnMovementCollision( pusher : CMovingAgentComponent )
	{
		// can always slide along
		return true;
	}
	
	event OnPushed( pusher : CMovingAgentComponent )
	{
		if ( pusher.GetEntity() == thePlayer )
		{
			parent.PushAway( pusher );
		}
	}
	
	event OnInteractionTalkTest()
	{
		return thePlayer.CanPlayQuestScene() && parent.CanPlayQuestScene() && parent.HasInteractionScene() && theGame.IsStreaming() == false && parent.IsUsingExploration() == false && parent.WasVisibleLastFrame() == true;
	}
}
