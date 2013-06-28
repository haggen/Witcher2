/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/
 
/////////////////////////////////////////////
// DraugMiniboss class
/////////////////////////////////////////////

class CDraugMiniboss extends W2Knightwraith
{
	editable var spawnDraugAfterDeathTemplate	: CEntityTemplate; // template of Draug Boss to spawn after death.
	
	/*event OnCutsceneEnded()
	{
		var spawnPosition : Vector = theGame.GetEntityByTag('draug_spawn').GetWorldPosition();
		var spawnRotation : EulerAngles = theGame.GetEntityByTag('draug_spawn').GetWorldRotation();
		
		//csRunning = false;
		//SPAWN BOSS
		theGame.CreateEntity(spawnDraugAfterDeathTemplate, spawnPosition);
	}*/
	
	latent function KnightSpawn()
	{
		var entity : CEntity;
			
		if( !spawned )
		{
			SetImmortalityModeRuntime( AIM_Invulnerable );
			PlayEffect('default_fx');
			templ = (CEntityTemplate) LoadResource("gameplay\knight_spawn");
			entity = theGame.CreateEntity( templ, GetWorldPosition(), GetWorldRotation() );	
			Sleep (0.5);
			effectTempl = (CEntityTemplate) LoadResource("gameplay\knight_spawn_effect");
			entity.RaiseEvent ('spawn');
			entity.WaitForBehaviorNodeDeactivation ( 'spawnend');
			DrawWeaponInstant( GetInventory().GetItemByCategory( 'opponent_weapon', false ) );
			DrawWeaponInstant( GetInventory().GetItemByCategory( 'opponent_shield', false ) );
			effectEnt = (W2KnightWraithSpawnEffect)theGame.CreateEntity(effectTempl, this.GetWorldPosition(), this.GetWorldRotation());
			Sleep(0.05);
			SetBodyPartState('wraith_knight_spawn', 'spawned');
			//SetAppearance ('spawned');
			PlayEffect('default_fx');
			entity.Destroy();						
			//Sleep(0.5);
			spawned = true;
			SetImmortalityModeRuntime( AIM_None );
		}
	}
}

quest function QSpawnDraug( entity : CEntityTemplate )
{
	var spawnPoint : CNode = theGame.GetNodeByTag('draug_spawn');
	var spawnPosition : Vector = spawnPoint.GetWorldPosition();
	var npc : CNewNPC;
	var spawnRotation : EulerAngles;// = spawnPoint.GetWorldRotation();
	
	spawnRotation = VecToRotation( thePlayer.GetWorldPosition() - spawnPoint.GetWorldPosition() );
	//csRunning = false;
	
	//SPAWN BOSS
	npc = (CNewNPC)theGame.CreateEntity(entity, spawnPosition, spawnRotation);
	if( npc )
	{
		npc.StartsWithCombatIdle(true);
	}
	
	theCamera.ResetRotation();
}

/*
state DraugDead in CDraugMiniboss extends Dead
{
		var tags : array< name >;
		var i : int;
	
	event OnEnterState()
	{
		parent.SetAlive(false);
		// CLEAR ROTATION TARGET
		parent.ClearRotationTarget();
				
		// DISABLE  PATHENGINE		
		parent.EnablePathEngineAgent( false );
		
		// FACTS DB
		tags = parent.GetTags();
		for( i=0; i<tags.Size(); i+=1 )
		{
			FactsAdd( "actor_" + tags[i] + "_was_killed", 1 );
		}
		
		//
		
		// INFORM PLAYER
		thePlayer.OnNPCDeath(parent);
	}
	event OnLeavingState()
	{
		return true;
	}
	entry function StateDead()
	{
		
	}

}
state DeadCutscene in CDraugMiniboss extends Cutscene
{
	var spawnPosition : Vector;
	var spawnRotation : EulerAngles;
	event OnLeavingState()
	{
		return !csRunning;
	}
	
	event OnLeaveState()
	{
		// Pass to base class
		super.OnLeaveState();
	}
	
	event OnCutsceneStarted()
	{
		
	}
	
	event OnCutsceneEnded()
	{
		csRunning = false;
		//MarkGoalFinished();
		Log("----- Cutscene Ended   " + parent);
		//SPAWN BOSS
		spawnPosition = theGame.GetEntityByTag('draug_spawn').GetWorldPosition();
		spawnRotation = theGame.GetEntityByTag('draug_spawn').GetWorldRotation();
		theGame.CreateEntity(parent.spawnDraugAfterDeathTemplate, spawnPosition);
		parent.DraugMinibossDestroy();
		//parent.OnCutsceneEnded();
	}
	entry function DraugMinibossDestroy()
	{
		parent.ActivateBehavior( 'npc_exploration' );
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		
		parent.RaiseForceEvent('UnconsciousForced');
		OnCommunityNPCDeath( parent );
		Sleep(10.0f);
		parent.Destroy();
	}
	
	entry function StateCutscene( goalId : int )
	{
		SetGoalId( goalId );
		csRunning = true;
	}
}*/

