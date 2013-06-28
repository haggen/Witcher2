/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CArachas class
/////////////////////////////////////////////
class CEndriag extends W2Monster
{
	// Initialize Nekker
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		var arbitrator : CAIArbitrator = GetArbitrator();
		var goal : CAIGoalMonsterSpawn;
		super.OnSpawned(spawnData);
		GetInventory().AddItem( 'Arachas Spit', 1 );
		GetInventory().AddItem( 'Arachas Bomb', 1 );
		goal = new CAIGoalMonsterSpawn in arbitrator;
		arbitrator.AddGoal( goal, AIP_High );
	}
	
	function GetMonsterType() : EMonsterType
	{
		return MT_Endriaga;
	}
	
	function EnterCombat( params : SCombatParams )
	{	
		TreeCombatEndriag(params);
		OnEnteringCombat();		
	}
}
state Spawn in CEndriag extends Base
{
	entry function StateMonsterSpawn( goalId : int )
	{
		SetGoalId( goalId );
		Sleep(0.1);
		if(theGame.GetIsPlayerOnArena())
		{
			parent.RaiseForceEvent('Idle');
		}
		else
		{
			parent.WaitForBehaviorNodeDeactivation('SpawnEnd');
			parent.SetSpawnAnim(SA_Idle);
		}
		MarkGoalFinished();
	}
};
/////////////////////////////////////////////
// CArachasSpit class
/////////////////////////////////////////////
class CEndriagSpit extends CProjectile
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