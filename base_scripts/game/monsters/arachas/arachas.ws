/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CArachas class
/////////////////////////////////////////////
class CArachas extends W2Monster
{
	// Initialize Arachas
	latent function DestroyedOnFreeze() : bool
	{
		return false;
	}
	
	function GetMonsterType() : EMonsterType
	{
		return MT_Arachas;
	}
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		var arbitrator : CAIArbitrator = GetArbitrator();
		var goal : CAIGoalMonsterSpawn;	
		goal = new CAIGoalMonsterSpawn in arbitrator;
		arbitrator.AddGoal( goal, AIP_High );
		super.OnSpawned(spawnData);
		GetInventory().AddItem( 'Arachas Spit', 1 );
		GetInventory().AddItem( 'Arachas Bomb', 1 );
	}
	
	function EnterCombat( params : SCombatParams )
	{	
		TreeCombatArachas(params);
		OnEnteringCombat();		
	}
}

/////////////////////////////////////////////
// CArachasSpit class
/////////////////////////////////////////////
class CArachasSpit extends CProjectile
{
	private var hitActors : array< CActor >;

	event OnProjectileInit()
	{
		AddTimer( 'EndCheck', 0.5, true, false );
	}

	event OnProjectileCollision( collidingComponent : CComponent, pos, normal : Vector )
	{
		var entity : CEntity;
		var actor : CActor;
		var damage : float;

		entity = collidingComponent.GetEntity();
		if( entity.IsA('CActor') && !entity.IsA('CArachas') )
		{
			actor = (CActor)entity;
			if( !hitActors.Contains( actor ) )
			{
				damage = GetStrength();
				actor.HitPosition( GetWorldPosition(), 'Attack_t1', damage, true );
				hitActors.PushBack(actor);
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
state Spawn in CArachas extends Base
{
	entry function StateMonsterSpawn( goalId : int )
	{
		//parent.PlayEffect('appear_fx');
		SetGoalId( goalId );
		parent.WaitForBehaviorNodeDeactivation('SpawnEnd');
		MarkGoalFinished();
	}
};