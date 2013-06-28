/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/
 
/////////////////////////////////////////////
// Zagnica thrash projectile class
/////////////////////////////////////////////

class CThrashProjectile extends CEntity
{
	var component : CDestructionSystemComponent;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		component = (CDestructionSystemComponent)GetComponentByClassName('CDestructionSystemComponent');
		
		if( !component )
		{
			Log("Can not find CDestructionSystemComponent in tentadrake thrash entity");
			Destroy();
			return false;
		}

		EnableCollisionInfoReportingForComponent( component, true, true );
	}
	
	event OnCollisionInfo( collisionInfo : SCollisionInfo, reportingComponent, collidingComponent : CComponent )
	{
		if( collisionInfo.impulseApplied > 10 )
		{
			Teleport( component.GetCenterOfMassInWorld(0) );
			PlayEffect( 'explosion_fx' );
			theSound.PlaySoundOnActor( this, '', "fx/explosions/stone/fx_stone_blank_destroy_small");
			EnableCollisionInfoReportingForComponent( component, false, true );
		}
	}
}

state IsFlying in CThrashProjectile
{
	var CurrentPlayerPos, CurrentThrashPos : Vector;
	var dist, velocity : float;
	var rotation : EulerAngles;
	var zgn : Zagnica;

	entry function StartFlying()
	{
		var angularVelocity : Vector;
		
		angularVelocity.X = 13.2f;
		angularVelocity.Z = 5.3f;
		parent.component.SetAngularVelocity(0, angularVelocity);
		
		while (true)
		{			
			CurrentPlayerPos = thePlayer.GetWorldPosition();
			CurrentPlayerPos.Z += 1;
			CurrentThrashPos = parent.component.GetCenterOfMassInWorld(0);
			dist = VecDistance( CurrentThrashPos, CurrentPlayerPos );
			velocity = VecLength( parent.component.GetLinearVelocity(0) );
			
			if( dist <= 1.9f )
			{	
			//	parent.EnableCollisionInfoReportingForComponent( parent.GetComponentByClassName('CDestructionSystemComponent'), true ); 
				
				thePlayer.ZgnHit( theGame.zagnica, 'thrash', CurrentThrashPos );
				parent.StopFlying();
			}
			
			if( velocity < 3.f )
			{
				parent.StopFlying();
			}
			
			Sleep( 0.001f );
		}
	}
	
	timer function FlightEnd( TimeDelta : float )
	{
		parent.StopFlying();
	}

/*	
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
	//	parent.ForceNewDestructionState( 'Destroyed' );
	
		if( collidingComponent == terrainComponent )
		{
			parent.StopFlying();
		}
		
		else if( collidingComponent == playerComponent )
		{
			Player.ZgnHit( theGame.GetActorByTag('zagnica'), 'thrash', CurrentThrashPos );
//			parent.PlaySound( 'play_code_tentadrake_rock_smash' );
			
			zgn.playerHasBeenHit = true;
			zgn.AddTimer( 'HitDelay', 3.f );
	//		parent.EnableCollisionInfoReportingForComponent( parent.GetComponentByClassName('CRigidMeshComponent'), false ); 
			parent.StopFlying();
		}
	}
*/
}

state StoppedFlying in CThrashProjectile
{
	entry function StopFlying()
	{
		parent.AddTimer( 'DestroyThrash', 3.0f, false );
	}
	
	private timer function DestroyThrash( TimeDelta : float )
	{
		parent.Destroy();
	}
}
