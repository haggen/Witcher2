///////////////////////////////////////////////////////////////////////////////
// KLASA DLA OBIEKTÓW GENERUJ¥CYCH HA£AS ODBIERANY PRZEZ COMMUNITY (GUARDÓW) //

class CNoiseEmitter extends CEntity
{
	editable inlined var interestPoint : CInterestPoint;
	editable var noiseOnCollision	: bool;
	editable var noiseEffectName	: name;
	editable var noiseDuration		: float;
	
	default noiseOnCollision	= false; // no collision noise by default
	default noiseDuration		= 0.5f; 
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		if ( noiseOnCollision && interestPoint )
		{
			EnableCollisions( true );
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;
		
		affectedEntity = activator.GetEntity();
		
		if( affectedEntity == thePlayer && interestPoint )
		{
			GenerateNoise();
			AddTimer( 'GenerateNoiseTimer', noiseDuration, true, false );
		}
	}
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var affectedEntity : CEntity;

		affectedEntity = activator.GetEntity();
		
		if( affectedEntity == thePlayer && interestPoint )
		{
			RemoveTimers();
		}
	}

	timer function GenerateNoiseTimer( timeDelta : float )
	{
		if( thePlayer.IsPlayerMoving() )
		{
			GenerateNoise();
		}
	}
	
	function GenerateNoise()
	{
		var c : CComponent;
		
		// Broadcast interest point
		c = GetComponentByClassName('CSpriteComponent');
		if ( c )
		{
			theGame.GetReactionsMgr().BroadcastDynamicInterestPoint( interestPoint, c, noiseDuration );				
		}
		else
		{
			theGame.GetReactionsMgr().BroadcastStaticInterestPoint( interestPoint, GetWorldPosition(), noiseDuration );
		}
		
		// Play effect
		if ( noiseEffectName != '' )
		{
			this.PlayEffect( noiseEffectName );
		}
	}
	
	event OnCollisionInfo( collisionInfo : SCollisionInfo, reportingComponent, otherComponent : CComponent )
	{
		var sound : CSoundComponent;
		
		if( otherComponent.GetEntity() == thePlayer )
		{
			DisableNoiseForAMoment( noiseDuration );
			GenerateNoise();
		}
	}
	
	function DisableNoiseForAMoment( timeout : float )
	{
		EnableCollisions( false );
		AddTimer( 'EnableNoiseAfterAMoment', noiseDuration, false );
	}
	
	timer function EnableNoiseAfterAMoment( timeDelta : float )
	{
		EnableCollisions( true );
	}
	
	function EnableCollisions( enable : bool )
	{
		var component : CComponent = GetComponentByClassName('CDestructionSystemComponent');
		if ( ! component )
		{
			component = GetComponentByClassName('CStaticMeshComponent');
		}
		if ( ! component )
		{
			component = GetComponentByClassName('CPhysicsSystemComponent');
		}
		
		if ( component )
		{
			EnableCollisionInfoReportingForComponent( component, enable, thePlayer.GetMovingAgentComponent() );
		}
	}
}
