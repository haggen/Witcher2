// Klasa obslugujaca interakcje zabijajaca potwory i gracza w swiecie duchow w akcie 2

class q002_trap_door extends CEntity
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var component : CComponent;
		component = GetComponent( "q002_trap_door" );
		component.SetEnabled( true );
	}

	event OnInteraction( actionName : name, activator : CEntity )
	{
			var component : CComponent;
			component = GetComponent( "q002_trap_door" );
			component.SetEnabled( false );
			OpenTrapDoor();
	}
}

state trap_door_opening in q002_trap_door
{
	entry function OpenTrapDoor()
	{
		var exploration : CEntity;
		var exploration_component, waypoint : CComponent;
		var vector, wpvector, player_vector : Vector;
		var wpRotation : EulerAngles;	
		var distance : float;
		
		player_vector = thePlayer.GetWorldPosition();
		vector = parent.GetWorldPosition();
		waypoint = parent.GetComponent( "q002_waypoint" );	
		exploration = theGame.GetEntityByTag('q002_trap_door_expl');
		exploration_component = exploration.GetComponent( "q002_trap_door_expl" );
		wpvector = waypoint.GetWorldPosition();
		
		while ( thePlayer.GetCurrentPlayerState() != PS_Exploration && thePlayer.GetCurrentPlayerState() != PS_Sneak )
		{
			thePlayer.ChangePlayerState( PS_Sneak );
			Sleep( 0.5f );
		}
		
		thePlayer.SetManualControl(false, true);
		thePlayer.BlockPlayerState( thePlayer.GetCurrentPlayerState() );
		
		distance = VecDistance2D( player_vector,wpvector );
		if( distance >= 1.0f )
		{
			thePlayer.RotateTo( wpvector, 0.2f );
			thePlayer.ActionMoveToWithHeading( wpvector, waypoint.GetHeading(), MT_Walk, 1.0, 0.3);	
		}
		else
		{
			thePlayer.ActionSlideToWithHeading( wpvector, waypoint.GetHeading(), 0.2f); 
		}
		
		thePlayer.RaiseForceEvent( 'TrapDoor' );
		parent.RaiseEvent( 'open' );
		//Sleep(0.2f);
		
		thePlayer.WaitForBehaviorNodeDeactivation( 'TrapDoorEnd', 20.f );
		exploration_component.SetEnabled( true );
		thePlayer.SetManualControl(true, true);
		thePlayer.UnblockAllPlayerStates();
	}
}