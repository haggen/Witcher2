////// Scripts for q215r_battle_for_vergen ////////

class CDetmoldBomb extends CItemEntity
{
	editable var damageMin, damageMax : float;

	var damageFinal : float;
	var victim : CActor;
	var victims : array<CActor>;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		PlayEffect( 'time_bomb_start' );
		AddTimer( 'StartBombTicking', 4.0f, false );
	}
	
	event OnInteractionActivated( interactionName : name, activator : CEntity )
	{
		if( interactionName == 'FireDmgRange' && activator.IsA( 'CActor' ) && !activator.IsA( 'W2MonsterGolem' ) )
		{
			victim = (CActor) activator;
			victims.PushBack( victim );
		}
	}
	
	event OnInteractionDeactivated( interactionName : name, activator : CEntity )
	{
		if( interactionName == 'FireDmgRange' && activator.IsA( 'CActor' ) && !activator.IsA( 'W2MonsterGolem' ) )
		{
			victim = (CActor) activator;
			victims.Remove( victim );
		}
	}
	
	timer function StartBombTicking( timeDelta : float )
	{
		var i : int;
	
		PlayEffect( 'explosion' );
		
		for( i=0; i<victims.Size(); i+= 1 )
		{
			((CActor)victims[i]).ApplyCriticalEffect( CET_Burn, NULL );
			((CActor)victims[i]).HitPosition( this.GetWorldPosition(), 'Attack', 100.f, true );;
		}
		
		AddTimer( 'DestroyTimer', 10.0f, false );
	}
	
	timer function DestroyTimer( timeDelta : float )
	{
		Destroy();
	}
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////

quest function q215r_DetmoldBombSpell( bombEntity : CEntityTemplate ) : bool
{
	return theGame.CreateEntity( bombEntity, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
}

quest latent function q215r_DetmoldBombSpellMultiple( bombEntity : CEntityTemplate )
{
	var pos : Vector;
	
	pos = thePlayer.GetWorldPosition();
	
	pos.Y -= 6.f;
	
	theGame.CreateEntity( bombEntity, pos, thePlayer.GetWorldRotation() );
	
	Sleep( 1.f );
	pos.Y += 6.f;
	
	theGame.CreateEntity( bombEntity, pos, thePlayer.GetWorldRotation() );
	
	Sleep( 1.f );
	pos.Y += 6.f;
	
	theGame.CreateEntity( bombEntity, pos, thePlayer.GetWorldRotation() );
}

