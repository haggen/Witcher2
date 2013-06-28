/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exports
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Walk with actor state
/////////////////////////////////////////////

state WalkWithActor in CNewNPC extends Base
{
	var wwaAction : CActorLatentActionWalkWithActor;
	var leader    : CActor;
	
	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
	
		if ( wwaAction )
		{
			wwaAction.Cancel( parent );
			wwaAction = NULL;
		}
		leader = NULL;
	}

	// Set point of interest action, give timeout <= 0.f for infinite timeout
	entry function StateWalkWithActor( actor : EntityHandle, desiredDistanceMin : float, desiredDistanceMax : float, timeout, observeDelay : float,
									observeTargetTag : name, defaultSpeed : EMoveType, walkBehind : bool, goalId : int )
	{
		var leaderEntity : CEntity;
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();
		
		leaderEntity = EntityHandleWaitGet( actor );		
		leader = (CActor)leaderEntity;
		parent.SetFocusedNode( leader );
		
		wwaAction = new CActorLatentActionWalkWithActor in this;
		wwaAction.minDistance	= desiredDistanceMin;
		wwaAction.maxDistance	= desiredDistanceMax;
		wwaAction.timeout		= timeout;
		wwaAction.observeTargetTag	= observeTargetTag;
		wwaAction.observeDelay	= observeDelay;
		wwaAction.defaultSpeed	= defaultSpeed;
		wwaAction.walkBehind	= walkBehind;
		
		wwaAction.Perform( parent );
		
		MarkGoalFinished();
	}
	
	event OnInteractionTalkTest()
	{
		return thePlayer.CanPlayQuestScene() && parent.CanPlayQuestScene() && parent.HasInteractionScene() && theGame.IsStreaming() == false && parent.IsUsingExploration() == false && parent.WasVisibleLastFrame() == true;
	}
}

