/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

state TreeCombatBullvore in W2MonsterBullvore extends TreeCombatMonster
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		var i : int;
		super.OnEnterState();

		parent.DrawWeaponInstant(parent.GetInventory().GetFirstLethalWeaponId());	
		if( parent.CreateCombatEventsProxy( CECT_Bullvore ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();
			//Bullvore Attacks
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
			
			//Bullvore hit events
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);

			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);

			
			//CombatIdle events
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			
			//Combat charge
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			
			//Bullvore Throw
			combatEvents.throwEnums.PushBack(BCA_Throw1);
			//Combat parry
			combatEvents.hitParryEnums.PushBack(BCH_Parry1);
		}
						
		parent.SetCombatSlotOffset(1.9);
	
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.ClearAttackTarget();
		rockEnt.Destroy();
	}
	
	entry function TreeCombatBullvore( params : SCombatParams )
	{
		LoadTree( params );
	}
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\bullvore";
	}
		
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3' )
		{						
			Attack( animEventName, true );			
		}
		else if ( animEventName == 'ground_hit' && animEventType == AET_Tick )
		{
			parent.PlayEffect ('fx_attack01');
		}	
		else if ( animEventName == 'step' && animEventType == AET_Tick )
		{
			parent.PlayEffect ('fx_attack01');
		}
		else if ( animEventName == 'trail_l' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_l');
		}
		else if ( animEventName == 'trail_r' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_r');
		}
		else if ( animEventName == 'stomp' && animEventType == AET_Tick )
		{
			if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 64.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}

	entry function BullvoreParry()
	{
		var rand : int; 
		rand = Rand(3);
		parent.GetBehTreeMachine().Stop();
		if( parryCounter < rand)
		{
			parryCounter += 1;
			HitEvent(GetHitParryEnum());
			Sleep(0.1);
			parent.WaitForBehaviorNodeDeactivation('HitEnd');
			Sleep(2.0);
		}
		parryCounter = 0;
		if(Rand(2) == 1)
		{
			AttackEvent(BCA_CounterParry1);
		}
		else
		{
			AttackEvent(BCA_CounterParry2);
		}
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('AttackEnd');
		parent.GetBehTreeMachine().Restart();
	}
	event OnBeingHit( out hitParams : HitParams )
	{
		var rand : int;
		rockEnt.Destroy();
		rand = Rand(5) + 3;
		if(theGame.GetDifficultyLevel() <= 0)
		{	
			return true;
		}
		if( !parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ) )			
		{
			//hitParams.outDamageMultiplier = 4.0;
			return true;
		}
		hitCounter += 1;
		if(parent.CheckCanBlock() && hitCounter > rand)
		{
			hitCounter = 0;
			BullvoreParry();
			hitParams.attackReflected = true;
			hitParams.attacker.PlaySparksOnHit(hitParams.attacker, hitParams);
			return false;
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
				HitStrongBullvore();
			}
			else
			{
				HitFastBullvore();
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
				AardReactionBullvore();
			}
		}
		else
		{
			AardReactionBullvore();
		}
	}
	entry function AardReactionBullvore()
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
	entry function HitFastBullvore()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function HitStrongBullvore()
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
