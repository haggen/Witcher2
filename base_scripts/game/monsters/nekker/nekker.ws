/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// CNekker class
/////////////////////////////////////////////

class CNekker extends W2Monster
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
		despawnTemplate = (CEntityTemplate)LoadResource("fx\nekker\despawn");
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
	function GetMonsterType() : EMonsterType
	{
		return MT_Nekker;
	}
	function CanAct() : bool
	{
		return true;
	}
	// q106_rishon - stunning nekker situation
	latent function UnconsciousStarted()
	{
		var nekkerRotation : EulerAngles;
		var nekkerPosition : Vector;
		var interactionTemplate : CEntityTemplate;

		
		if( FactsQuerySum( "q106_stunning_nekker_phase" ) == 1)
		{
			nekkerRotation = GetWorldRotation();
			nekkerPosition = GetWorldPosition();
			interactionTemplate = (CEntityTemplate)LoadResource( "gameplay\q106_nekker_stunned_interaction");			
			interactionEntity = theGame.CreateEntity(interactionTemplate, nekkerPosition, nekkerRotation);
		}
	}

	latent function UnconsciousEnded()
	{
		if( interactionEntity )
		{
			interactionEntity.Destroy();	
		}
	}

	// Initialize Nekker
	event OnSpawned(spawnData : SEntitySpawnData )
	{
		var arbitrator : CAIArbitrator = GetArbitrator();
		var goal : CAIGoalMonsterSpawn;	
		actActions.PushBack(AA_Act1);
		actActions.PushBack(AA_Act2);
		actActions.PushBack(AA_Act3);
		actActions.PushBack(AA_Act4);
		super.OnSpawned(spawnData);
		goal = new CAIGoalMonsterSpawn in arbitrator;
		arbitrator.AddGoal( goal, AIP_High );
		this.SetAttackableByPlayerRuntime( false );
	}
	
	function EnterCombat( params : SCombatParams )
	{
		TreeCombatNekker(params);
		OnEnteringCombat();
	}
}
state Spawn in CNekker extends Base
{
	entry function StateMonsterSpawn( goalId : int )
	{
		SetGoalId( goalId );
		Sleep(1.3);
		parent.SetAttackableByPlayerRuntime( true );
		MarkGoalFinished();
	}
};
