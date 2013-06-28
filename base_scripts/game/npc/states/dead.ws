/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Dead state fro NPC
/** Copyright © 2009
/***********************************************************************/


state Dead in CNewNPC extends Base
{	
	private var canLeave : bool;	
	private var deathEventNames : array<name>;
	private var explosionParams : SDeathExplosionParams;
	private var storedDeathData : SActorDeathData;
		
	event OnAnimEvent( eventName : name, eventTime : float, eventType : EAnimationEventType )
	{
		var golem : W2MonsterGolem;
		if (eventName == 'SetRagdoll' && !virtual_parent.noragdollDeath)
		{
			parent.EnablePathEngineAgent( false );
			if(!parent.IsKnockedDown() && !virtual_parent.IsWeakened())
			{
				parent.SetRagdoll(true);
			}
		}
		if (eventName == 'GolemDeath' )
		{
			if(virtual_parent.GetMonsterType() == MT_Golem)
			{
				golem = (W2MonsterGolem)parent;
				theGame.CreateEntity(golem.GetGolemDestructionTemplate(), golem.GetWorldPosition(), golem.GetWorldRotation());
				//parent.SetHideInGame(true);
				parent.AddTimer('HideGolem', 0.01);
			}
		}
		if ( eventType == AET_Tick && eventName == 'Disappear')
		{
			if(virtual_parent.GetMonsterType() != MT_Wraith && virtual_parent.GetMonsterType() != MT_Bruxa)
			{
				parent.SetHideInGame(true);
				StateDestruct(storedDeathData, false);
			}
		}
		else if(eventType == AET_Tick && eventName == 'Explode')
		{
			if(explosionParams.explosionTemplate)
			{
				Explosion(explosionParams);
			}
		}
		else if ( eventName == 'shake' && eventType == AET_Tick )
		{
			if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 36.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 0.3);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
			else if(VecDistance(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 20.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
		}
	}
	timer function HideGolem(td : float)
	{
		parent.SetHideInGame(true);
	}
	event OnEnterState()
	{
		var physicalAgent : CMovingPhysicalAgentComponent;
		var arena : CArenaManager;
		if(theGame.GetIsPlayerOnArena())
		{
			if(!parent.HasTag('arena_wingman'))
			{
				arena = theGame.GetArenaManager();
				arena.GetCurrentWave().GetCurrentRound().RemoveKilledEnemy(parent);
				arena.CheckPlayerCheat(parent);
			}
		}
		parent.GetComponent("talk").SetEnabled( false );
		
		parent.SetAlive(false);
		canLeave = false;
		
		// CLEAR ROTATION TARGET
		parent.ClearRotationTarget();
				
		// DISABLE  PATHENGINE		
		parent.EnablePathEngineAgent( false );
		
		// INFORM COMMUNITY SYSTEM
		OnCommunityNPCDeath( parent );
		
		// FACTS DB
		AddFactsDBEntry();
		
	}
	
	event OnLeaveState()
	{
		// REENABLE  PATHENGINE		
		parent.EnablePathEngineAgent( true );
	}
	
	event OnLeavingState()
	{
		return canLeave;
	}
	
	event OnDespawn( forced : bool )
	{
		canLeave = true;
	}
	
	function AddFactsDBEntry()
	{
		var tags : array< name >;
		var i : int;
		
		tags = parent.GetTags();
		for( i=0; i<tags.Size(); i+=1 )
		{
			FactsAdd( "actor_" + tags[i] + "_was_killed", 1 );
		}
	}
	function StopEffects()
	{
		parent.StopEffect('stun_fx');
		parent.StopEffect('axii_level1');
		parent.StopEffect('axii_fx');
		parent.StopEffect('ghost_fx');
		parent.RemoveTimer( 'Raging' );
		parent.RemoveTimer( 'LookForTargets' );
		thePlayer.RemoveAxiiTarget(parent);
	}
	entry function StateDead( deathData : SActorDeathData )
	{
		var itemsDropped : bool;
		var res : bool;
		var los : float;		
		var eventName : name;
		var destroyed : bool;
		//var dismembered : bool;
		storedDeathData = deathData;
		//Sleep(2.0);
		parent.MapPinClear();
		parent.RemoveTimer('RemoveCombatSelection');

		if(virtual_parent.ExplodesOnDeath())
		{
			explosionParams = virtual_parent.GetExplosionParams();
		}
		StopEffects();
		if( deathData.noActionCancelling == false )
		{
			// Avoid ActionCancelAll
			super.OnEnterState();
		}
		
		deathEventNames.Clear();
		if ( parent.IsWeakened() )
		{			
			deathEventNames.PushBack('Death3');	
		}
		else if(parent.IsKnockedDown())
		{
		
			deathEventNames.PushBack('DeathGround');	
			deathData.ragDollAfterDeath = false;
			if(theGame.GetIsPlayerOnArena())
			{
				thePlayer.ShowArenaPoints(thePlayer.GetCharacterStats().GetAttribute('arena_fin1_bonus'));
			}
		}
		else
		{			
			deathEventNames.Clear();
			//deathEventNames.PushBack('Death1');
			deathEventNames.PushBack('Death2');
		}		
		// INFORM PLAYER
		thePlayer.SetKilledWithoutHurt( thePlayer.GetKilledWithoutHurt() + 1 );
		if ( thePlayer.GetKilledWithoutHurt() == 10 ) theGame.UnlockAchievement('ACH_PERFECIONIST'); 
		thePlayer.OnNPCDeath(parent);		
		
		if( !deathData.silent )
		{
			parent.ActionCancelAll();
			//dismembered = Dismember();
			
			if( parent.IsCriticalEffectApplied(CET_Freeze) )
			{
				destroyed = parent.DestroyedOnFreeze();
				if( destroyed )
				{
					parent.StopAllEffects();
					parent.SetHideInGame( true );
				}
			}
			
			if ( parent.GetMonsterType() != MT_Rotfiend )
			{ 
				parent.AddTimer( 'DelayLootDrop', 0.2f, false );
			}
			//NPCs don't drop items on arena
			if(theGame.GetIsPlayerOnArena())
			{
				itemsDropped = true;
			}
			else
			{
				itemsDropped = virtual_parent.HandleItemsOnDeath();
			}
		
			if( !destroyed )
			{
				res = Dismember();
				if( true )
				{	
					// PLAY DEATH EVENT			
					if(!deathData.deadState)
					{
						if(!deathData.fallDownDeath)
						{
							parent.PlayDeathSounds();
						}
					
						eventName = GetDeathEventName();			
						if( !parent.RaiseForceEvent( eventName ) )
						{		
							if( !parent.RaiseForceEvent( 'Death1' ) || !parent.RaiseForceEvent( 'Death2' ) )
							{
								Log( "state Dead RaiseForceEvent failed "+parent.GetName() );
							}
						}
					}
					else
					{
						if(!parent.RaiseForceEvent( 'DeadState' ))
							parent.RaiseForceEvent( 'Death1' );
						if(deathData.ragDollAfterDeath && !parent.IsKnockedDown() && !virtual_parent.IsWeakened())
							parent.SetRagdoll(true);
					}
					
					parent.SetBehaviorVariable("death", 1.0 );
				}
			}
			

			// Set dying state
			if(virtual_parent.GetMonsterType() == MT_Wraith || virtual_parent.GetMonsterType() == MT_Bruxa)
			{
				//virtual_parent.StopEffect('default_fx');
				//virtual_parent.PlayEffect('teleport_in');
				//Sleep(1.5);
							
				//virtual_parent.SetHideInGame(true);
			}
		
			parent.SetDyingState();
		}

		parent.PlayEffect ( 'disapear' );
		
		// SELF DESTRUCT
		StateDestruct( deathData, itemsDropped );
	}
	
	entry function StateDestruct( optional deathData : SActorDeathData, optional dontDropItems : bool )
	{
		var i : int;
		i = 0;
		
		if ( !dontDropItems )
		{
			if ( parent.GetMonsterType() == MT_Rotfiend )
			{ 
				parent.AddTimer( 'DelayLootDrop', 3.0f, false );
			}
		}
		
		parent.EnablePathEngineAgent( false );
		
		if (parent.IsRagdollObstacle())
		{
			Sleep( 15.f );
		}
		else
		{
			Sleep( 5.0f );
			
			while( !parent.CanBeDesctructed() && i < 120 )
			{
				Sleep(1.0);
				i+=1;
			}
		}
		SelfDestruct();
	}
	
	timer function DelayLootDrop( time : float )
	{
		var itemTags : array< name >;
		
		// THROW AWAY ITEMS
		itemTags.PushBack( 'NoDrop' );
		if(!theGame.GetIsPlayerOnArena())
		{
			parent.GetInventory().ThrowAwayItemsFiltered( itemTags );
		}
	}
	
	private function SelfDestruct()
	{
		parent.Destroy();
	}
	
	function GetDeathEventName() : name
	{
		var s : int;
		s = deathEventNames.Size();
		if( s == 0 )
		{
			return '';
		}
		else
		{	
			return deathEventNames[Rand(s)];
		}
	}
	
	
	latent function Dismember() : bool
	{	
		var res : bool;
		if ( /*parent.allowToCut.LeftArm*/ !virtual_parent.IsMonster() && parent.readyToCut.LeftArm ) 
		{
			Log("[ Cut Body Part] -> Cutting arm_L ");
			parent.EnablePathEngineAgent( false );
			parent.SetRagdoll(true);
			Sleep(0.1);
			parent.CutBodyPart("arm_L", "", 'l_forearm');
			thePlayer.ResetAllowCutParts();
			res = true;
		}
		if ( /*parent.allowToCut.RightArm*/ !virtual_parent.IsMonster() && parent.readyToCut.RightArm ) 
		{
			Log("[ Cut Body Part] -> Cutting arm_R ");
			parent.EnablePathEngineAgent( false );
			parent.SetRagdoll(true);
			Sleep(0.1);
			parent.CutBodyPart("arm_R", "", 'r_forearm');
			thePlayer.ResetAllowCutParts();
			res = true;
		}
		/*if (  !virtual_parent.IsMonster() && parent.readyToCut.Torso ) 
		{
			Log("[ Cut Body Part] -> Cutting torso ");
			parent.EnablePathEngineAgent( false );
			parent.SetRagdoll(true);
			Sleep(0.1);
			parent.CutBodyPart("body", "", 'torso');
			thePlayer.ResetAllowCutParts();
			res = true;
		}*/
		
		return res;
		
		
	}

	entry function Explosion(explosionData : SDeathExplosionParams)
	{
		var templ : CEntityTemplate;
		var actors : array<CActor>;
		var actor : CActor;
		var i, size : int;
		var explosionEntity : CEntity;
		var explosionPos : Vector;
		var attackType : name;
		attackType = explosionData.attackType;
		
		parent.StopEffect('default_fx');
		
		if(attackType == '')
		{
			attackType = 'Attack';
		}
		templ = explosionData.explosionTemplate;
		explosionEntity = theGame.CreateEntity( templ, parent.GetWorldPosition(), parent.GetWorldRotation() );
		
		if(!explosionEntity)
			return;
		explosionPos = explosionEntity.GetWorldPosition();
		GetActorsInRange(actors, explosionData.explosionRange, '', explosionEntity);
		size = actors.Size();
		if(explosionData.explosionDamage > 0.0f)
		{
			if(size > 0)
			{
				for(i = 0; i < size; i+=1)
				{
					actor = actors[i];
					actor.HitPosition(explosionPos, attackType, explosionData.explosionDamage, true);
					actor.ApplyCriticalEffect(explosionData.criticalEffectType, NULL);
				}
			}
		}
		Sleep(0.1);
		parent.SetHideInGame( true );
		StateDestruct();
	}
}
