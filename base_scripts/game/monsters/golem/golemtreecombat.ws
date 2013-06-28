/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

state TreeCombatGolem in W2MonsterGolem extends TreeCombatMonster
{		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	var weakenedLevels : array<int>;
	var weakenedCounter : int;
	var counterTime : EngineTime;
	var superblockLevels : array<int>;
	var superblockCounter : int;
	var rock, destructionRock : CEntityTemplate;
	var rockEnt : CEntity;
	var hitCounter : int;
	var parryCounter : int;
	var isInParry : bool;
	var golemDespawn : CEntityTemplate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		var i : int;
		super.OnEnterState();
		parent.noragdollDeath = true;
		parent.DrawWeaponInstant(parent.GetInventory().GetFirstLethalWeaponId());	
		if( parent.CreateCombatEventsProxy( CECT_Golem ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();
			//Golem Attacks
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
			
			//Golem hit events
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);

			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);

			
			//CombatIdle events
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			
			//Combat charge
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			
		}
						
		parent.SetCombatSlotOffset(1.9);
	
	}
	
	event OnLeaveState()
	{
		if(!parent.IsAlive())
		{
			parent.StopEffect('default_fx');
			if(parent.elemental)
			{
				parent.PlayEffect('disappear');
			}
		}
		super.OnLeaveState();
		parent.ClearAttackTarget();
		rockEnt.Destroy();
	}
	
	entry function TreeCombatGolem( params : SCombatParams )
	{
		LoadTree( params );
	}
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\golem";
	}
		
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3')
		{						
			Attack( animEventName, true );			
		}
		else if(animEventName == 'AttackBoss' && animEventType == AET_Tick)
		{
			Attack( 'Attack_boss_t1', true );
			//Attack( animEventName );
		}
		else if ( animEventName == 'stomp' && animEventType == AET_Tick )
		{
			if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 64.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
		}
		else if ( animEventName == 'steps_left_fx' && animEventType == AET_Tick )
		{
			parent.PlayEffect('fx_steps_left');
			if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 100.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 0.3);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
			else if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 800.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
			
		}
		else if ( animEventName == 'steps_right_fx' && animEventType == AET_Tick )
		{
			parent.PlayEffect('fx_steps_right');
			if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 100.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 0.3);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
			else if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 800.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
		}
		else if ( animEventName == 'trail_l' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_l');
		}
		else if ( animEventName == 'trail_r' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_r');
		}
		else if ( animEventName == 'shake' && animEventType == AET_Tick )
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
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}
	event OnBeingHit( out hitParams : HitParams )
	{
		var rand : int;
		hitCounter += 1;
		rockEnt.Destroy();
		rand = Rand(3) + 2;
		if(theGame.GetDifficultyLevel() <= 0)
		{	
			return true;
		}
		if( parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ) )			
		{
			if(hitCounter > rand || isInParry)
			{
				ParryGolem();
				hitParams.attacker.PlaySparksOnHit(hitParams.attacker, hitParams);
				hitParams.attackReflected = true;
				return false;
			}
				return true;
		}
		
		return true;
	}
	event OnAttackTell( hitParams : HitParams )
	{

	}
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{
		rockEnt.Destroy();
		if( parent.IsAlive() )
		{
			if(parent.IsStrongAttack(hitParams.attackType))
			{
				HitStrongGolem();
			}
			else
			{
				HitFastGolem();
			}
		}
	}
	
	event OnCriticalEffectStart( effectType : ECriticalEffectType, duration : float )
	{
		rockEnt.Destroy();
		if(effectType == CET_Burn)
		{
			
			return true;
		}
		else
		{
			return false;
		}
	}
	
	event OnAardHitReaction( CWitcherSignAard : CWitcherSignAard )
	{
		rockEnt.Destroy();
		
		if(parent.AardKnockdownChance())
		{
			if(!parent.ApplyCriticalEffect(CET_Stun, NULL, 0, true) && !parent.ApplyCriticalEffect(CET_Knockdown, NULL, 0, true))
			{
				AardReactionGolem();
			}
		}
		else
		{
			AardReactionGolem();
		}
	}
	entry function AardReactionGolem()
	{
		parent.SetBlockingHit(false);
		parent.SetBlock(false);
		parent.CantBlockCooldown(3.0);
		parent.ActionCancelAll();
		parent.SetRotationTarget( parent.GetTarget() );
		parent.GetBehTreeMachine().Stop();	
		HitEvent(BCH_AardHit1);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function ParryAttackGolem()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		hitCounter = 0;
		isInParry = false;
		AttackEvent(BCA_CounterParry1);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'AttackEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	entry function ParryGolem()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		isInParry = true;
		if(Rand(2) == 1)
		{
			HitEvent(BCH_Parry1);
		}
		else
		{
			HitEvent(BCH_Parry2);
		}
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		if(hitCounter > Rand(3))
		{
			ParryAttackGolem();
		}
		else
		{
			Sleep(2.0);
			ParryAttackGolem();
		}
	}
	entry function HitFastGolem()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function HitStrongGolem()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
};
