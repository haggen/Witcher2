/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// CBullvore class
/////////////////////////////////////////////

class W2MonsterBullvore extends W2Monster
{
	editable var shouldWander : bool;
	
	default shouldWander = true;
	
	// Initialize Bullvore
	function GetMonsterType() : EMonsterType
	{
		return MT_Bullvore;
	}
	
	event OnSpawned(spawnData : SEntitySpawnData )
	{		
		super.OnSpawned(spawnData);
		GetInventory().AddItem( 'Bullvore Spit', 1 );
		GetInventory().AddItem( 'Bullvore Throw', 1 );
	}
	
	function EnterCombat( params : SCombatParams )
	{
		TreeCombatBullvore( params );
		OnEnteringCombat();
	}
	
	latent function DestroyedOnFreeze() : bool
	{
		return false;
	}
}

/////////////////////////////////////////////
// CBullvoreSpit class
/////////////////////////////////////////////
class W2MonsterBullvoreSpit extends CProjectile
{
	private var hitActors : array< CActor >;

	event OnProjectileInit()
	{
		AddTimer( 'EndCheck', 0.5, true, false );
	}

	// Check who Bullvore's spit hit
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var entity : CEntity;
		var actor : CActor;
		var damage : float;
		var rotfiend : CRotfiend;
		
		entity = collidingComponent.GetEntity();

		if ( entity.IsA('CRotfiend') )
		{
			rotfiend = (CRotfiend)entity;
			rotfiend.OnBullvoreSpitHit();
		}
		else if ( entity.IsA('CActor') && !entity.IsA('W2MonsterBullvore') )
		{
			actor = (CActor)entity;
			if ( !hitActors.Contains( actor ) )
			{
				damage = GetStrength();
				actor.HitPosition( GetWorldPosition(), 'Attack_t1', damage, true );
				hitActors.PushBack( actor );
			}
		}
	}
	
	timer function EndCheck( t : float )
	{
		if( GetStrength() <= 0.0 )
		{
			Destroy();
		}
	}
};

/////////////////////////////////////////////
// CBullvoreThrow class
/////////////////////////////////////////////
class W2MonsterBullvoreThrow extends CProjectile
{
	private var hitActors      : array< CActor >;
	private var destroyRequest : bool;

	event OnProjectileInit()
	{
		destroyRequest = false;
		AddTimer( 'EndCheck', 0.5, true, false );
	}

	// Check who Bullvore's spit hit
	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var entity : CEntity;
		var actor : CActor;
		var damage : float;
		var rotfiend : CRotfiend;
		
		entity = collidingComponent.GetEntity();

		if ( entity.IsA('CActor') && !entity.IsA('W2MonsterBullvore') )
		{
			actor = (CActor)entity;
			if ( !hitActors.Contains( actor ) )
			{
				damage = GetStrength();
				actor.HitPosition( GetWorldPosition(), 'Attack_t1', damage, true );
				hitActors.PushBack( actor );
			}
		}
	}

	event OnRangeReached( inTheAir : bool )
	{
		destroyRequest = true;
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
