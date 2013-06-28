/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CRotfiend class
/////////////////////////////////////////////

class CRotfiend extends W2Monster
{
	editable var lowHealthPercentage   : int;   // (0,100]	If health is below this percentage than Rotfiend can hide
	editable var hiddenTeleportRange   : float; // >=0		The maximum range of teleport when Rotfiend is hiding
	editable var minRegenerationTime   : float; // >=0		The minimum regeneration time duration - the time when Rotfiend is hiding (is buried)
	editable var maxRegenerationTime   : float; // >=0		The maximum regeneration time duration - the time when Rotfiend is hiding (is buried)
	editable var retryRegenerationTime : float; // >=0		After regeneration Rotfiend will not regenerate again for this amount of time
	editable var regenerationChance    : int;   // (0, 100]	The chance (in percentages) that Rotfiend will hide and regenerate
	editable var regenerationFactor    : float; // (0, 1]	If equals 1 than after 'maxRegenerationTime' Rotfiend will regain full health
	
	default lowHealthPercentage = 20;   // 20%
	default hiddenTeleportRange = 15;   // in meters
	default minRegenerationTime = 3;    // in seconds
    default maxRegenerationTime = 7;    // in seconds
    default retryRegenerationTime = 15; // in seconds
    default regenerationChance = 75;    // 75%
    default regenerationFactor = 0.8;

	var lowHealthValue : float;
	var isHiding : bool;
	var retryRegenerationTimer : float;
	var unburyRequest : bool; // if true than stop hiding
	
	default isHiding = false;
	default unburyRequest = false;


	// Public methods for Rotfiend management (special monster behavior)
	latent function GetExplosionParams() : SDeathExplosionParams
	{
		var explosionParams : SDeathExplosionParams;
		var rand : float;
		rand = RandRangeF(0.75, 1.0);
		explosionParams.criticalEffectType = CET_Poison;
		explosionParams.attackType = 'Attack_t3';
		explosionParams.explosionDamage = rand * this.GetCharacterStats().GetFinalAttribute('explosion_damage');
		
		if(explosionParams.explosionDamage == 0.0f)
			explosionParams.explosionDamage = 20.0f;
		
		explosionParams.explosionRange = this.GetCharacterStats().GetFinalAttribute('explosion_range');
		if(explosionParams.explosionRange == 0.0f)
			explosionParams.explosionRange = 3.0f;
		
		explosionParams.explosionTemplate = (CEntityTemplate)LoadResource("gameplay\rotfiend_destruction");
		return explosionParams;
	}
	function GetMonsterType() : EMonsterType
	{
		return MT_Rotfiend;
	}
	
	public function Unbury()
	{
		if ( isHiding )
		{
			unburyRequest = true;
		}
	}
	
	public function OnBullvoreSpitHit()
	{
		ExplodeMonster();
	}
	
	// =================================================================

	function CanAct() : bool
	{
		return true;
	}
	// Initialize Rotfiend
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		var arbitrator : CAIArbitrator = GetArbitrator();
		var goal : CAIGoalMonsterSpawn;	
		actActions.PushBack(AA_Act1);
		actActions.PushBack(AA_Act2);
		actActions.PushBack(AA_Act3);
		actActions.PushBack(AA_Act4);	
		super.OnSpawned(spawnData);
		noragdollDeath = true;
		GetInventory().AddItem( 'Rotfiend Guts', 1 );
		// calculate low health
		lowHealthValue = initialHealth * (lowHealthPercentage / 100.0);
		
		isHiding = false;
		retryRegenerationTimer = 0;
		unburyRequest = false;
		goal = new CAIGoalMonsterSpawn in arbitrator;
		arbitrator.AddGoal( goal, AIP_High );
		this.SetAttackableByPlayerRuntime( false );
		this.SetImmortalityModeRuntime( AIM_Invulnerable );
	}
	
	function EnterCombat( params : SCombatParams )
	{	
		if ( !isHiding )
		{
			TreeCombatRotfiend(params);
			OnEnteringCombat();
		}
	}
	function ExplodesOnDeath() : bool
	{
		return true;
	}
	latent function OnBeforeDestroy()
	{
		var despawnTemplate : CEntityTemplate;
		var despawnWithoutAnimRange : float = 90; // 30*30 -> squared distance
		var playerPos : Vector;
		var monsterPos : Vector;
		var squaredDistToPlayer : float;
		despawnTemplate = (CEntityTemplate)LoadResource("fx\rotfiend\despawn");
		EnablePathEngineAgent( false );
		this.SetImmortalityModeRuntime(AIM_Invulnerable, 10.0);
		this.SetAttackableByPlayerRuntime(false, 10.0);
		// Raise event only if entity isn't far away from player AND isn't outside camera
		if(usesDespawnAnimation && IsAlive())
		{
			// Get distance from monster to the Player
			playerPos = thePlayer.GetWorldPosition();
			monsterPos = GetWorldPosition();
			squaredDistToPlayer = VecDistanceSquared( playerPos, monsterPos );

			if ( squaredDistToPlayer < despawnWithoutAnimRange || IsPointSeenByPlayer( monsterPos ) )
			{
				StopMonsterEffects();
				if ( RaiseForceEvent( 'CombatDespawn' ) )
				{
					theGame.CreateEntity(despawnTemplate, this.GetWorldPosition(),  this.GetWorldRotation());
					WaitForBehaviorNodeActivation( 'CombatDespawn' );
					SetHideInGame(true);
				}
			}
		}
	}
}
state Spawn in CRotfiend extends Base
{
	var templ : CEntityTemplate;
	entry function StateMonsterSpawn( goalId : int )
	{
		SetGoalId( goalId );
		if(parent.usesSpawnAnimation)
		{
			templ = (CEntityTemplate)LoadResource("gameplay\spawn_rotfiend");
			theGame.CreateEntity( templ, parent.GetWorldPosition(), parent.GetWorldRotation() );
			Sleep(0.5);
			parent.RaiseEvent('Appear');
			parent.WaitForBehaviorNodeDeactivation('SpawnEnd');
		}
		parent.SetSpawnAnim(SA_Idle);
		parent.SetImmortalityModeRuntime( AIM_None );
		parent.SetAttackableByPlayerRuntime( true );
		MarkGoalFinished();
	}
};
