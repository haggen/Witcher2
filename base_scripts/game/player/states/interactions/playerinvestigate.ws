/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** PlayerInvestigate state
/** Copyright © 2011
/***********************************************************************/

state PlayerInvestigate in CPlayer extends Base
{
	private var oldState : EPlayerState;
	
	event OnEnterState()
	{
		// Pass to base class
		super.OnEnterState();
		CreateNoSaveLock();
		
		LogChannel( 'states', "PlayerInvestigate - OnEnterState" );

		parent.SetManualControl( false, true );
		theGame.EnableButtonInteractions( false );		
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.SetManualControl( true, true );
		theGame.EnableButtonInteractions( true );
		LogChannel( 'states', "PlayerInvestigate - OnLeaveState" );
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		// Not handled
		return false;
	}
	
	event OnUseExploration( explorationArea : CActionAreaComponent )
	{
		return false;
	}

	event OnStartTraversingExploration() 
	{
		return false;
	}
	
	event OnFinishTraversingExploration()
	{
	}
	
	entry function EntryInvestigation( oldPlayerState : EPlayerState, behStateName : string, itemToInvestigate : CInvestigationItem )
	{
		oldState = oldPlayerState;
		
		itemToInvestigate.PlayScene();
		
		parent.PlayerStateCallEntryFunction( oldPlayerState, behStateName );
	}
	
	event OnExitPlayerState( newState : EPlayerState )
	{
		// don't allow the player state to be changed
	}
}
