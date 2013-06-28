/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exports
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Perform latent action tree state
/////////////////////////////////////////////

state Acting in CNewNPC extends Base
{
	var actionArray :  array< IActorLatentAction >;
	var currentAction : IActorLatentAction;
	
	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
	}
	
	event OnLeaveState()
	{
		if ( currentAction )
		{
			currentAction.Cancel( parent );
		}
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		if( currentAction )
		{
			currentAction.OnAnimEvent( animEventName, animEventTime, animEventType );
		}
	}

	entry function StateActing( actions : array< IActorLatentAction >, focusedNode : EntityHandle, goalId : int )
	{
		var i : int;
		var actionCount : int = actions.Size();
		actionArray.Grow( actionCount );
		for ( i = 0; i < actionCount; i += 1 )
		{
			if( actions[i] )
			{
				actionArray[i] = (IActorLatentAction)actions[i].Clone( this );
			}
		}
		
		SetGoalId( goalId );
				
		parent.SetFocusedNode( EntityHandleGet( focusedNode ) );
		
		for ( i = 0; i < actionCount; i += 1 )
		{
			currentAction = actionArray[i];
			currentAction.Perform( parent );
			
			//Yield();
		}
		
		currentAction = NULL;
		actionArray.Clear();
		
		MarkGoalFinished();
	}
}
