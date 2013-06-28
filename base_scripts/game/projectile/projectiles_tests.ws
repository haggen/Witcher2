/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/



class CProjectileShooter extends CEntity
{
	editable var projectileTemplate : CEntityTemplate;
	var startPos : Vector;
	var proj : CRegularProjectile;
	
	private var projectiles : array< CRegularProjectile >;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		// start the timer
		AddTimer('ShooterUpdate', 10.0, true);
	}
	
	function ShootTestArrows(target : CActor)
	{
		var i : int;
		for( i = 0; i < 250; i += 1 )
		{
			startPos = thePlayer.GetWorldPosition() + theCamera.GetCameraDirection() * 40.0;
			startPos += VecRingRand( 0.0, 20.0 );
			startPos.Z = 5.0;
			proj = (CRegularProjectile)theGame.CreateEntity(projectileTemplate ,startPos, EulerAngles()); 
			if( proj )
			{
				if(i%25 == 0)
				{
					proj.PlayEffect('trials');
					proj.Start(target, Vector(0, 0, 0), false ); 
				}
				else
				{
					proj.PlayEffect('trials');
					proj.Start( NULL, target.GetWorldPosition() + VecRingRand(2.0, 10.0), false ); 
				}
			}
			else
			{
				Log("Cannot create projectile");
			}
		}
	}
	timer function ShooterUpdate(timeDelta : float)
	{
		ShootTestArrows(thePlayer);
	}
}

/////////////////////////////////////////////

// A spawner of projectiles
class TestProjectileSpawner extends CEntity
{
	editable var	projectileEntity 	: CEntityTemplate;
	editable var	spawnPeriod 		: float;
	editable var	spawnDistance		: float;
	editable var	shotAngle			: float;
	editable var	shotVelocity		: float;
	editable var	shotStrength		: float;
	editable var	maxSpawned			: int;
	
	default spawnPeriod					= 1.0;
	default spawnDistance				= 30.0;
	default shotAngle					= 30.0;
	default shotVelocity				= 10.0;
	default shotStrength				= 0.0;
	default maxSpawned					= 0;
	
	var spawned							: array< CEntity >;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		// start throwing the projectiles
		AddTimer( 'ProjectileSpawner', spawnPeriod, true );
	}
	
	timer function ProjectileSpawner( timeElapsed : float )
	{
		var ent 			: CEntity;
		var projectile		: CProjectile;
		var spawnPos 		: Vector;
		var spawnRotation 	: EulerAngles;
		
		
		// calculate spawn location
		spawnRotation = thePlayer.GetWorldRotation();
		spawnPos = thePlayer.GetWorldPosition() + RotForward( spawnRotation ) * spawnDistance;
		
		// spawn the projectile
		ent = theGame.CreateEntity( projectileEntity, GetWorldPosition(), spawnRotation );
		
		// remember spawned en(.)(.) only when the limit is set
		if ( maxSpawned > 0 )
		{
			// despawn oldest entities and remove them from array
			while ( spawned.Size() >= maxSpawned )
			{
				spawned[ 0 ].Destroy();
				spawned.Remove( spawned[ 0 ] );
			}
			
			// add new entity to the list
			spawned.PushBack( ent );
		}
		
		if ( ent.IsA( 'CExplodingProjectile' ) )
		{
			((CExplodingProjectile)ent).ShootAtNode( NULL, shotVelocity, thePlayer );
		}
		else if ( ent.IsA( 'CProjectile' ) )
		{
			projectile = (CProjectile)ent;
			projectile.Init( NULL );
			projectile.ShootProjectileAtNode( shotAngle, shotVelocity, shotStrength, thePlayer );
		}
		else
		{
			ent.Destroy();
		}
	}
}

