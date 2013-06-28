/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/


/////////////////////////////////////////////////////////////////////////

// This class describes a projectile that breaks into pieces upon impact
class CExplodingProjectile extends CEntity
{		
	editable var	shotVelocity		: float;
	editable var	impactStrength		: float;
	editable var	explosionLength		: float;
	
	var				caster				: CActor;
	var				velocity			: float;
	var				targetPos			: Vector;
	
	var 			destructionSystems 	: array< CDestructionSystemComponent >;
	
	final function ShootAtPosition( caster : CActor, velocity : float, target : Vector )
	{
		this.caster = caster;
		this.velocity = velocity;
		this.targetPos = target;
		Initialize();
	}
	
	final function ShootAtNode( caster : CActor, velocity : float, target : CNode )
	{
		this.caster = caster;
		this.velocity = velocity;
		this.targetPos = target.GetWorldPosition();
		Initialize();
	}
	
	function Initialize()
	{
		var size, i 			: int;
		var systems 			: array< CComponent >;
		var destructionSys		: CDestructionSystemComponent;
		
		// identify all destruction systems in the entity
 		systems = this.GetComponentsByClassName( 'CDestructionSystemComponent' );
 		size = systems.Size();
 		for ( i = 0; i < size; i += 1 )
 		{
			destructionSys = (CDestructionSystemComponent)systems[i];
			if ( destructionSys )
			{
				EnableCollisionInfoReportingForComponent( destructionSys, true, true );
				destructionSystems.PushBack( destructionSys );
			}
 		}
 		
 		// send the projectile flying
		Fly();
	}
	
	function OnExplode( impactPos : Vector )
	{
		var size, i 			: int;
		
 		ApplyExplosionEffects( impactPos );
	}
	
	function OnProjectileShot()
	{
		ApplyShotEffects();
	}
	function OnProjectileDestroy()
	{
		this.Destroy();
	}
	// Place the code responsible for applying the projectile being shot effects in this method's implementation
	abstract function ApplyShotEffects();
	
	// Place the code responsible for applying the projectile explosion effects in this method's implementation
	abstract function ApplyExplosionEffects( impactPos : Vector );
}

/////////////////////////////////////////////////////////////////////////

state Flying in CExplodingProjectile
{
	entry function Fly()
	{
		// set a timer that will destroy the projectile in due time
		parent.AddTimer( 'SpawnTimer', 0.1, false );
	}
	
	timer function SpawnTimer( timeElapsed : float )
	{
		parent.RemoveTimer( 'SpawnTimer' );
		ThrowEntityWithHorizontalVelocity( parent, parent.velocity, parent.targetPos );
		parent.OnProjectileShot();
		parent.AddTimer( 'PosTimer', 0.5, true );
	}
	
	timer function PosTimer( timeElapsed : float )
	{
		var pos : Vector = parent.GetWorldPosition();
		
		Log( "DRAUG BALL POS: " + pos.X + ", " + pos.Y + ", " + pos.Z );
	}
	
	event OnCollisionInfo( collisionInfo : SCollisionInfo, reportingComponent, collidingComponent : CComponent )
	{
		parent.RemoveTimer( 'PosTimer' ); 
		parent.Explode();
	}
}

/////////////////////////////////////////////////////////////////////////

state Exploding in CExplodingProjectile
{
	entry function Explode()
	{				
		// apply the explosion effect
		parent.OnExplode( parent.GetWorldPosition() );
		
		// set a timer that will destroy the projectile in due time
		parent.AddTimer( 'ExplosionTimer', parent.explosionLength, false );
	}
	
	timer function ExplosionTimer( timeElapsed : float )
	{
		parent.RemoveTimer( 'ExplosionTimer' );
		parent.OnProjectileDestroy();
	}
}

/////////////////////////////////////////////////////////////////////////
