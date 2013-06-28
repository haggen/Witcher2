//Classes for special entities in Tentadrake arena

class CForceField extends CEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var hitPos : Vector;
		
		if( activator.GetEntity() != thePlayer )
		{
			return false;
		}
		
		hitPos = thePlayer.GetWorldPosition() + VecFromHeading( thePlayer.GetHeading() );
		thePlayer.HitPosition( hitPos, 'Attack', thePlayer.GetInitialHealth() * 0.1f, true, NULL, true );
		thePlayer.PlayEffect( 'lightning_hit_fx' );
		
		AddTimer( 'Update', 1.0f, true );
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() != thePlayer )
		{
			return false;
		}
		
		RemoveTimers();
	}
	
	timer function Update( time : float )
	{
		var hitPos : Vector;
		
		hitPos = thePlayer.GetWorldPosition() + VecFromHeading( thePlayer.GetHeading() );
		thePlayer.HitPosition( hitPos, 'Attack', thePlayer.GetInitialHealth() * 0.1f, true, NULL, true );
		thePlayer.PlayEffect( 'lightning_hit_fx' );
	}
	
	function SetActive( active : bool )
	{
		GetComponentByClassName( 'CTriggerAreaComponent' ).SetEnabled( active );
	}
}

class CElvenBridge extends CEntity
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( FactsDoesExist( "q105_tenta_dead" ) )
		{
			RaiseForceEvent( 'collapse' );
		}
	}
	
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		if ( eventName == 'Shake' )
		{
			theCamera.RaiseEvent( 'Camera_Shake_zagnica_hit' );
		}
	}
}