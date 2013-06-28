/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Behavior Tree state
/** Copyright © 2009
/***********************************************************************/

state Reaction in CNewNPC extends ReactingBase
{
	private var reaction : CReactionScript;

	event OnEnterState()
	{	
		// Avoid action cancelling
		//super.OnEnterState();
		parent.GetComponent("talk").SetEnabled( false );	
	}

	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.RemoveTimer('ReactionTimeout');
		parent.GetComponent("talk").SetEnabled( true );	
		parent.SetFocusedNode( NULL );
	}
	
	event OnMovementCollision( pusher : CMovingAgentComponent )
	{
		return true;
	}
	
	event OnPushed( pusher : CMovingAgentComponent )
	{
		reaction.OnPushed( parent, pusher );
	}
	
	// Passed from reaction state
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		reaction.OnAnimEvent( parent, animEventName, animEventTime, animEventType );
	}

	entry function StateReaction( reactionIndex : int, interestPoint : PersistentRef, goalId : int )
	{
		var t1, t2: EngineTime;
		var delta, waitTime : float;
		var maxTime : float;
		SetGoalId( goalId );
		reaction = parent.GetReactionScript( reactionIndex );
		
		if( reaction.timeout > 0 )
		{
			parent.AddTimer( 'ReactionTimeout', reaction.timeout, false );
		}
		
		parent.ExitWork( reaction.exitWorkMode );		
		t1 = theGame.GetEngineTime();
		reaction.DoAction( parent, interestPoint );
		t2 = theGame.GetEngineTime();		
		delta = EngineTimeToFloat( t2 - t1 );
		maxTime = RandRangeF( 0.5, 1.5f );
		waitTime = MaxF( maxTime - delta, 0.0 );
		Sleep( waitTime ); // additional emergency sleep
		MarkGoalFinished();
	}
	
	timer function ReactionTimeout( timeDelta : float )
	{		
		MarkGoalFinished();
	}
	
	event OnInteractionTalkTest()
	{
		return thePlayer.CanPlayQuestScene() && parent.CanPlayQuestScene() && parent.HasInteractionScene() && theGame.IsStreaming() == false && parent.IsUsingExploration() == false && parent.WasVisibleLastFrame() == true;
	}
};