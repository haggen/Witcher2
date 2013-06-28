/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CNekker class
/////////////////////////////////////////////

class CGargoyle extends W2Monster
{
	////////////////////////////////////////////////////////////////////////
	// Teleportation
	////////////////////////////////////////////////////////////////////////
	editable var teleportationRangeMin  : float; // >=0			The teleport distance from player
	editable var teleportationRangeMax  : float; // >=0			The teleport distance from player
	editable var retryTeleportationTime : float; // >=0			After teleportation Gargoyle will not teleport again for this amount of time
	editable var teleportationChance    : int;   // (0, 100]	The chance (in percentages) that Gargoyle will teleport
	editable var teleportDelay			: float; // >=0			The amount of time

	default teleportationRangeMin  = 2;   // meters
	default teleportationRangeMax  = 2.5;   // meters
    default retryTeleportationTime = 15;  // seconds
    default teleportationChance    = 80;
    default teleportDelay          = 2.0; // seconds

	// Private
	var isTeleporting           : bool;
	var retryTeleportationTimer : float;

	default isTeleporting = false;

	////////////////////////////////////////////////////////////////////////
	// Regeneration
	////////////////////////////////////////////////////////////////////////
	editable var lowHealthPercentage      : int;   // (0,100]	If health is below this percentage than Gargoyle can regenerate
	editable var minRegenerationTime      : float; // >=0		The minimum regeneration time duration - the time when Gargoyle is in regeneration state
	editable var maxRegenerationTime      : float; // >=0		The maximum regeneration time duration - the time when Gargoyle is in regeneration state
	editable var retryRegenerationTime    : float; // >=0		After regeneration Gargoyle will not regenerate again for this amount of time
	editable var regenerationChance       : int;   // (0, 100]	The chance (in percentages) that Gargoyle will enter regeneration state
	editable var regenerationFactor       : float; // (0, 1]	If equals 1 than after 'maxRegenerationTime' Rotfiend will regain full health
	editable var regenerateDistFromPlayer : float; // > 0		Gargoyle will not regenerate if it's distance to player is less than this variable value

	default lowHealthPercentage      = 10;  // in percents
	default minRegenerationTime      = 3;   // in seconds
    default maxRegenerationTime      = 7;   // in seconds
    default retryRegenerationTime    = 15;  // in seconds
    default regenerationChance       = 75;  // in percents
    default regenerationFactor       = 0.8;
    default regenerateDistFromPlayer = 5.0; // in meters

	var isPlayingDamageFX		: bool;
	var lowHealthValue          : float;
	var isRegenerating          : bool;
	var retryRegenerationTimer  : float;
	var stopRegenerationRequest : bool; // if true than stop hiding

	default isRegenerating          = false;
	default stopRegenerationRequest = false;

	////////////////////////////////////////////////////////////////////////

	var isInitialized : bool;
	
	default isInitialized = false;
	function GetMonsterType() : EMonsterType
	{
		return MT_Gargoyle;
	}
	function CanPerformRespondedBlock() : bool
	{
		return true;
	}
	latent function GetExplosionParams() : SDeathExplosionParams
	{
		var explosionParams : SDeathExplosionParams;
		var rand : float;
		rand = RandRangeF(0.75, 1.0);
		
		explosionParams.criticalEffectType = CET_Burn;
		explosionParams.attackType = 'Attack_t3';
		explosionParams.explosionDamage = rand * this.GetCharacterStats().GetFinalAttribute('explosion_damage');
		
		if(explosionParams.explosionDamage == 0.0f)
			explosionParams.explosionDamage = 20.0f;
		
		explosionParams.explosionRange = this.GetCharacterStats().GetFinalAttribute('explosion_range');
		if(explosionParams.explosionRange == 0.0f)
			explosionParams.explosionRange = 3.0f;
		
		explosionParams.explosionTemplate = (CEntityTemplate)LoadResource("fx\gargoyle\explosion");
		return explosionParams;
	}
	function ExplodesOnDeath() : bool
	{
		return true;
	}
	////////////////////////////////////////////////////////////////////////
	
	// Public methods for Gargoyle management (special monster behavior)
	
	public function StopRegeneration()
	{
		if ( isRegenerating )
		{
			stopRegenerationRequest = true;
		}
	}

	// =================================================================

	// Initialize Gargoyle
	event OnSpawned(spawnData : SEntitySpawnData )
	{		
		
		var arbitrator : CAIArbitrator = GetArbitrator();
		var goal : CAIGoalMonsterSpawn;		
		noragdollDeath = true;
		goal = new CAIGoalMonsterSpawn in arbitrator;
		arbitrator.AddGoal( goal, AIP_High );
		this.SetAttackableByPlayerRuntime( false );
		this.SetImmortalityModeRuntime( AIM_Invulnerable );
		
		isInitialized = true;
		super.OnSpawned(spawnData);
	}
	
	function EnterCombat( params : SCombatParams )
	{	
		if ( !isTeleporting && !isRegenerating )
		{
			TreeCombatGargoyle(params);
			OnEnteringCombat();
		}
	}
}
state Spawn in CGargoyle extends Base
{
	var templ : CEntityTemplate;
	entry function StateMonsterSpawn( goalId : int )
	{
		SetGoalId( goalId );
		templ = (CEntityTemplate)LoadResource("fx\gargoyle\appear");
		
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('SpawnEnd');
		parent.SetSpawnAnim(SA_Idle);
		parent.SetAttackableByPlayerRuntime( true );
		parent.SetImmortalityModeRuntime( AIM_None );
		parent.PlayEffect('default_fx');
		MarkGoalFinished();
	}
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if ( animEventName == 'ground_hit' && animEventType == AET_Tick )
		{
			theGame.CreateEntity( templ, parent.GetWorldPosition(), parent.GetWorldRotation() );
			//parent.PlayEffect ('fx_attack01');
			if(VecDistance(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 3.0)
			{
				parent.SetAttackTarget(thePlayer);
				thePlayer.HitPosition(parent.GetWorldPosition(), 'Attack_t2', 10.0, true);
			}
			if(VecDistance(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 15.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
		}	
	}
};
