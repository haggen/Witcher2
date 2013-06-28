/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CKnightwraith class
/////////////////////////////////////////////

class W2KnightWraithSpawnEffect extends CEntity
{
	timer function DestroyEffect(td : float)
	{
		this.Destroy();
	}
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		this.PlayEffect('end_spawn_fx');
		this.AddTimer('DestroyEffect', 3.0, false);
	}
}

class W2Knightwraith extends W2Monster
{
	var spawned : bool;
	var templ, effectTempl : CEntityTemplate;
	var effectEnt : W2KnightWraithSpawnEffect;
	
	function GetMonsterType() : EMonsterType
	{
		return MT_KnightWraith;
	}
	function CanPerformRespondedBlock() : bool
	{
		return true;
	}
	// Initialize Knightwraith
	event OnSpawned(spawnData : SEntitySpawnData )
	{					
		var arbitrator : CAIArbitrator = GetArbitrator();
		var goal : CAIGoalMonsterSpawn;
		
		super.OnSpawned(spawnData);
		
		goal = new CAIGoalMonsterSpawn in arbitrator;
		arbitrator.AddGoal( goal, AIP_High );
	}
	
	latent function HandleItemsOnDeath() : bool
	{
		// Drop the weapon
		GetInventory().DropItem( GetCurrentWeapon( CH_Left ) );
		return true;
	}
	
	latent function KnightSpawn()
	{
		var entity : CEntity;
			
		if( !spawned )
		{
			
			SetImmortalityModeRuntime( AIM_Invulnerable );
			//PlayEffect('default_fx');
			templ = (CEntityTemplate) LoadResource("gameplay\knight_spawn");
			entity = theGame.CreateEntity( templ, GetWorldPosition(), GetWorldRotation() );	
			effectTempl = (CEntityTemplate) LoadResource("gameplay\knight_spawn_effect");
			Sleep(3.55);
			DrawWeaponInstant( GetInventory().GetItemByCategory( 'opponent_weapon', false ) );
			DrawWeaponInstant( GetInventory().GetItemByCategory( 'opponent_shield', false ) );
			effectEnt = (W2KnightWraithSpawnEffect)theGame.CreateEntity(effectTempl, this.GetWorldPosition(), this.GetWorldRotation());
			Sleep(0.05);
			SetAppearance ('spawned');
			PlayEffect('default_fx');
			Sleep(0.1);
			
			entity.Destroy();						
			//Sleep(0.5);
			spawned = true;
			SetImmortalityModeRuntime( AIM_None );
		}
	}
	
	function EnterCombat( params : SCombatParams )
	{
		TreeKnightwraith(params);
		OnEnteringCombat();	
	}
}

state Spawn in W2Knightwraith extends Base
{
	entry function StateMonsterSpawn( goalId : int )
	{
		SetGoalId( goalId );
		virtual_parent.KnightSpawn();
		MarkGoalFinished();
	}
};

