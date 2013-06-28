/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// W2MonsterTroll class
/////////////////////////////////////////////

class W2MonsterTroll extends W2Monster
{
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Bomb
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	editable var retryBombTime				: float;    // >=0		After bomb explode, the monster will not set off bomb again for this amount of time
	editable var lowHealthPercentForBomb	: int;      // (0,100]	If health is greater than this percentage than monster will not set off a bomb
	editable var hitCountCapForBomb         : int;      // >=0		If monster hit count is less than this number than monster will not set off a bomb

	default retryBombTime = 5;
	default lowHealthPercentForBomb = 60;
	default hitCountCapForBomb = 5;

	// private
	var bombRetryTimer     : float;
	var bombLowHealthValue : float;
	var bombHitCount       : int;
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Throw
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	editable var throwRetryTime      : float; // >=0 seconds
	editable var throwMinPlayerRange : float; // >0  meters
	editable var throwMaxPlayerRange : float; // >0  meters
	editable var throwDamageRange    : float;
	
	default throwRetryTime      = 3.0;
	default throwMinPlayerRange = 5.0;
	default throwMaxPlayerRange = 10.0;
	default throwDamageRange    = 4.0;
	
	// private
	var throwRetryTimer            : float;
	var throwMinPlayerRangeSquared : float;
	var throwMaxPlayerRangeSquared : float;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	var isInitialized : bool;

	default isInitialized = false;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Initialize Troll
	function GetMonsterType() : EMonsterType
	{
		return MT_Troll;
	}
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{		
		super.OnSpawned(spawnData);
		
		// Bomb
		bombLowHealthValue = initialHealth * (lowHealthPercentForBomb / 100.0);
		GetInventory().AddItem( 'Troll Bomb', 1 );
		bombRetryTimer = 0;
		bombHitCount = 0;
		
		// Throw
		GetInventory().AddItem( 'Troll Throw', 1 );
		throwMinPlayerRangeSquared = throwMinPlayerRange * throwMinPlayerRange;
		throwMaxPlayerRangeSquared = throwMaxPlayerRange * throwMaxPlayerRange;
		throwRetryTimer = throwRetryTime;

		isInitialized = true;
	}
	
	function EnterCombat( params : SCombatParams )
	{
		TreeCombatTroll( params );
		OnEnteringCombat();
	}
	
	latent function DestroyedOnFreeze() : bool
	{
		return false;
	}
}

/////////////////////////////////////////////
// W2MonsterTrollThrow class
/////////////////////////////////////////////
class W2MonsterTrollThrow extends CProjectile
{
	//private var hitActors : array< CActor >;
	private var destroyRequest : bool;

	event OnProjectileInit()
	{
		destroyRequest = false;
		AddTimer( 'EndCheck', 0.5, true, false );
	}

	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var entity : CEntity;
		var actor : CActor;
		var damage : float;

		entity = collidingComponent.GetEntity();
		if( entity.IsA('CActor') && !entity.IsA('W2MonsterTroll') )
		{
			actor = (CActor)entity;
			//if( !hitActors.Contains( actor ) )
			{
				//damage = GetStrength();
				//actor.HitPosition( GetWorldPosition(), 'Attack_t1', damage, true );
				//hitActors.PushBack(actor);
				
				DealAoEDamage();
				destroyRequest = true;
			}
		}
	}

	event OnRangeReached( inTheAir : bool )
	{
		DealAoEDamage();
		destroyRequest = true;
	}
	
	private function DealAoEDamage()
	{
		var affected    : array< CActor >;
		var i           : int;
		var damage      : float = GetStrength();
		var hitPos      : Vector = GetWorldPosition();
		var casterTroll : W2MonsterTroll;
		var damageRange : float = 3.0;

		casterTroll = (W2MonsterTroll)caster;
		damageRange = casterTroll.throwDamageRange;

		GetActorsInRange( affected, damageRange, '', this );
		for ( i = 0; i < affected.Size(); i += 1 )
		{
			affected[i].HitPosition( hitPos, 'Attack_t1', damage, true );
		}
	}

	timer function EndCheck( t : float )
	{
		if( GetStrength() <= 0.0 || destroyRequest )
		{
			RemoveTimer( 'EndCheck' );
			Destroy();
		}
	}
};
class CTrollRock extends CRegularProjectile
{
	editable var explodingFX : CEntityTemplate;

	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		Explode();
	}
	event OnRangeReached( inTheAir : bool )
	{
		Explode();
	}
	function DealDamage(actor : CActor, position : Vector)
	{
		var finalDamage : float;

		finalDamage = RandRangeF(caster.GetCharacterStats().GetFinalAttribute('ranged_damage_min'), caster.GetCharacterStats().GetFinalAttribute('ranged_damage_max'));
		
		if(finalDamage <= 0)
		{
			finalDamage = RandRangeF(this.minDamage, this.maxDamage); 
		}
		actor.HitPosition(position, 'Attack', finalDamage, true);
	}
	
	function Explode()
	{
		var actors : array<CActor>;
		var i, size : int;
		var destructionSystems	: array< CDestructionSystemComponent >;
		var components : array<CComponent>;
		var rigidMeshes : array<CRigidMeshComponent>;
		var rb : CRigidMeshComponent;
		var impulse : Vector;
		var dc : CDestructionSystemComponent;
		GetActorsInRange(actors, 3.0, '', this);
		size = actors.Size();
		if(size > 0)
		{
			for(i = 0; i < size ; i += 1)
			{
				DealDamage(actors[i], this.GetWorldPosition());
			}
		}
		theGame.CreateEntity(explodingFX, this.GetWorldPosition(), this.GetWorldRotation());
		
		this.ApplyAppearance("no_rock");
		this.StopEffect('trail_fx');
		this.StopEffect('destruction_fx');
		this.AddTimer('DestroyTrollRock', 5.0, false);
		
	}
	timer function DestroyTrollRock( timeDelta : float )
	{
		this.Destroy();		
	}
}
class CTrollRockExplosion extends CEntity
{
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		this.AddTimer('Explode', 0.02, false);
		this.AddTimer('DestroyBall', 6.0, false);
	}
	timer function Explode(td : float)
	{
		var destructionSystems	: array< CDestructionSystemComponent >;
		var impulse : Vector;
		var components : array<CComponent>;
		var rigidMeshes : array<CRigidMeshComponent>;
		var dc : CDestructionSystemComponent;
		var rb : CRigidMeshComponent;
		var rbcount : int;
		var size, i, j : int;
		components = this.GetComponentsByClassName( 'CDestructionSystemComponent' );
		size = components.Size();
		for(i = 0; i < size; i += 1)
		{
			dc = (CDestructionSystemComponent)components[i];
			rb = (CRigidMeshComponent)components[i];
			if(dc)
			{
				destructionSystems.PushBack(dc);
			}
			if(rb)
			{
				rigidMeshes.PushBack(rb);
			}
		}
		size = rigidMeshes.Size();
		for(i = 0; i < size; i += 1)
		{
			rigidMeshes[i].ApplyLinearImpulse(impulse);
		}
		size = destructionSystems.Size();
		for(i = 0; i < size; i += 1)
		{
			destructionSystems[i].SetEnabled(true);
			rbcount = destructionSystems[i].GetRigidBodyCount();
			destructionSystems[i].SetTakesDamage( true );
			destructionSystems[i].ApplyScriptedDamage( -1, 10000 );
			for(j = 0; j < rbcount; j += 1)
			{
				impulse = Vector(RandRangeF(-150, 150), RandRangeF(-150,150), RandRangeF(150,250), 0);
				destructionSystems[i].SetAngularVelocity(j, impulse);
			}
		}
		if(VecDistanceSquared(thePlayer.GetWorldPosition(), this.GetWorldPosition()) < 64.0)
		{
			theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
			theCamera.RaiseEvent('Camera_ShakeHit');
		}
		this.PlayEffect('destruction_fx');
	}
	timer function DestroyBall(td : float)
	{
		this.Destroy();
	}
}
