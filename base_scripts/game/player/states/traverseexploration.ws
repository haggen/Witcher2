state TraverseExploration in CPlayer extends Movable
{
	private var oldState : EPlayerState;
	
	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
		CreateNoSaveLock();
		
		LogChannel( 'states', "TraverseExploration - OnEnterState" );
		parent.SetManualControl( false, true );

		theGame.EnableButtonInteractions( false );		
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.SetManualControl( true, true );
		theGame.EnableButtonInteractions( true );
		LogChannel( 'states', "TraverseExploration - OnLeaveState" );
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		// Not handled
		return false;
	}
	
	event OnHit( hitParams : HitParams )
	{
		// don't react to hits while traversing an exploration
	}
	
	event OnUseExploration( explorationArea : CActionAreaComponent )
	{
		return false;
	}

	event OnStartTraversingExploration() 
	{
		return true;
	}
	
	event OnFinishTraversingExploration()
	{
	}
	
	entry function EntryTraverseExploration( oldPlayerState : EPlayerState, behStateName : string, explorationArea : CActionAreaComponent )
	{
		oldState = oldPlayerState;
		if( parent.IsCombatState( oldPlayerState ) )
		{
			parent.GetMovingAgentComponent().EnableCombatMode(true);
		}
		if(explorationArea.GetEntity().HasTag('q000_destroy_exploration'))
		{
			FactsAdd("q001_exploration_started", 1);
		}
		parent.ActionSlideThrough( explorationArea );
		parent.PlayerStateCallEntryFunction( oldState, behStateName );
	}
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		// don't allow the player state to be changed immediately
		oldState = newState;
	}
}