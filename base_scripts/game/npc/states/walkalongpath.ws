/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Triss state for the walk along the beach on the beginning of act 1
/** Copyright © 2009
/***********************************************************************/

state WalkAlongPath in CNewNPC extends ReactingBase
{
//////////////////////////////////////////////////////////////////////////////////////////

	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
	}
		
	entry function StateWalkAlongPath( path : EntityHandle, upThePath : bool, fromBegining : bool, margin : float, moveType : EMoveType, speed : float, goalId : int )
	{		
		var pathEntity : CEntity;
		var pathComponent : CPathComponent;
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();
		
		pathEntity = EntityHandleGet( path );
		pathComponent = pathEntity.GetPathComponent();
		
		parent.ActionMoveAlongPath( pathComponent, upThePath, fromBegining, margin, moveType, speed );
		MarkGoalFinished();
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
};
