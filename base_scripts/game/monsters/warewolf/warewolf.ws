/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CNekker class
/////////////////////////////////////////////

class CWarewolf extends W2Monster
{
	var interactionEntity : CEntity;
	
	event OnDestroyed()
	{
		if( interactionEntity )
		{
			interactionEntity.Destroy();	
		}	
	}
	latent function OnBeforeDestroy()
	{
		var despawnTemplate : CEntityTemplate;
		var despawnWithoutAnimRange : float = 90; // 30*30 -> squared distance
		var playerPos : Vector;
		var monsterPos : Vector;
		var squaredDistToPlayer : float;
		//despawnTemplate = (CEntityTemplate)LoadResource("fx\nekker\despawn");
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
				}
			}
		}
	}
	function CanPerformRespondedBlock() : bool
	{
		return true;
	}
	function GetMonsterType() : EMonsterType
	{
		return MT_Warewolf;
	}
	function CanAct() : bool
	{
		return true;
	}
	
	// Initialize Nekker
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		var arbitrator : CAIArbitrator = GetArbitrator();
		var goal : CAIGoalMonsterSpawn;	
		actActions.PushBack(AA_Act1);
		actActions.PushBack(AA_Act2);
		super.OnSpawned(spawnData);
		goal = new CAIGoalMonsterSpawn in arbitrator;
		arbitrator.AddGoal( goal, AIP_High );
		this.SetAttackableByPlayerRuntime( false );
	}
	
	function EnterCombat( params : SCombatParams )
	{
		TreeCombatWarewolf(params);
		OnEnteringCombat();
	}
}
state Spawn in CWarewolf extends Base
{
	entry function StateMonsterSpawn( goalId : int )
	{
		SetGoalId( goalId );
		parent.RaiseEvent('Appear');
		Sleep(1.3);
		parent.SetAttackableByPlayerRuntime( true );
		MarkGoalFinished();
	}
};
