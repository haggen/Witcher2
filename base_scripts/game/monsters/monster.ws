/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// W2Monster class
/////////////////////////////////////////////
enum ESpawnAnim 
{
	SA_Spawn,
	SA_Idle,
	SA_Spawn2,
	SA_Spawn3
}
class W2Monster extends CNewNPC
{	
	private var isAttractedByLure : bool;
	private var isFightingForLure : bool;
	editable var usesSpawnAnimation : bool;
	editable var usesDespawnAnimation : bool;
	editable var canUseCharge : bool;
	default usesSpawnAnimation = true;
	default usesDespawnAnimation = true;
	editable var mayWander : bool;
	var lure : CLure;
	default mayWander = true;
	default canUseCharge = true;
	
	//override default value from actor
	//temporary cast to int because default values dont work while being an enum
	default finisherType	= 1;//FT_Single;
	
	function CanUseChargeAttack() : bool
	{
		return canUseCharge;
	}
	
	function GetLure() : CLure
	{
		return lure;
	}
	function SetSpawnAnim(spawnAnim : ESpawnAnim)
	{
		var spawnAnimInt : int;
		spawnAnimInt = (int)spawnAnim;
		SetBehaviorVariable("SpawnAnim", (float)spawnAnimInt);
	}
	function SetAttractedByLure( value : bool, attractedBy : CLure )
	{
		lure = attractedBy;
		isAttractedByLure = value;
	}
	
	function IsAttractedByLure() : bool
	{
		return isAttractedByLure;
	}
	
	function SetFightingForLure( value : bool )
	{
		isFightingForLure = value;
	}
	
	function IsFightingForLure() : bool
	{
		return isFightingForLure;
	}

	event OnNearbySceneStarted( sceneCenter : Vector, sceneRadius : float )
	{
		GetArbitrator().AddGoalKeepAwayFromScene( sceneCenter, sceneRadius );
		
		return true;
	}
	event OnCriticalEffectStart( effectType : ECriticalEffectType, duration : float )
	{
		if(effectType == CET_Burn)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	event OnCriticalEffectStop( effectType : ECriticalEffectType )
	{
		if(effectType == CET_Burn)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	event OnNearbySceneEnded()
	{
		GetArbitrator().MarkGoalsFinishedByClassName( 'CAIGoalKeepAwayFromScene' );
	}
	
	// Initialize
	event OnSpawned(spawnData : SEntitySpawnData )
	{		
		super.OnSpawned(spawnData);
		AddTimer( 'GenerateReactionField', 3.0, true, true );
	}
	
	timer function GenerateReactionField( td : float )
	{
		theGame.GetReactionsMgr().BroadcastDynamicInterestPoint( thePlayer.monsterInterestPoint, this, 5.0 );
	}
	
	private function EnterDead( optional deathData : SActorDeathData )
	{
		RemoveTimer( 'GenerateReactionField' );
		super.EnterDead( deathData );
	}

	// Can actor act as takedown victim
	function CanBeTakedowned( attacker : CActor, primary : bool ) : bool
	{		
		return false;
	}
	
	function IsMonster() : bool
	{
		return true;
	}
	
	function IsInCloseCombat() : bool
	{
		return true;
	}
	function StopMonsterEffects()
	{

	}
	latent function OnBeforeDestroy()
	{
		var despawnWithoutAnimRange : float = 90; // 30*30 -> squared distance
		var playerPos : Vector;
		var monsterPos : Vector;
		var squaredDistToPlayer : float;
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
					WaitForBehaviorNodeActivation( 'CombatDespawn' );
				}
			}
		}
	}	
};
class CAIGoalMonsterSpawn extends CAIGoal
{	
	function Start() : bool
	{
		var monster : W2Monster;
		monster = (W2Monster)GetOwner();
		//if(VecDistance(monster.GetWorldPosition(), thePlayer.GetWorldPosition()) < 20.0)
			//thePlayer.KeepCombatMode();
		return monster.StateMonsterSpawn(GetGoalId());
	}
	
}
state Spawn in W2Monster extends Base
{
	entry function StateMonsterSpawn( goalId : int )
	{
		SetGoalId( goalId );
		Sleep(1.0);
		MarkGoalFinished();
	}
};
