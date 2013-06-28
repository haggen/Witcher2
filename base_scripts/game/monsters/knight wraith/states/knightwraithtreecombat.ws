/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** NPC Combat
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// CombatKnightWraith state
/////////////////////////////////////////////
state TreeCombatKnightWraith in W2Knightwraith extends TreeCombatMonster
{		
	var weakenedLevels : array<int>;
	var weakenedCounter : int;
	var superblockLevels : array<int>;
	var superblockCounter, parryCounter : int;
	var hitParams  : HitParams;
	var counterTime : EngineTime;
	var aardHitCounter, maxAardHitCounter : int;
		
	default aardHitCounter = 0;	
	default parryCounter = 0;	
	default maxAardHitCounter = 1;	
	
	event OnEnterState()
	{
		var weaponId : SItemUniqueId;
		var combatEvents : W2CombatEvents;
		var i : int;

		super.OnEnterState();				
		
		
		parent.SetWeakened( false );

		if(parent.CreateCombatEventsProxy( CECT_KnightWraith ))
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();	
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack6);
			

			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected1);
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected2);
						
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);

			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
			
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			combatEvents.chargeEnums.PushBack(BCA_Charge2);
			combatEvents.chargeEnums.PushBack(BCA_FromSlot1);
			
			combatEvents.hitParryEnums.PushBack(BCH_Parry1);
			combatEvents.hitParryEnums.PushBack(BCH_Parry2);
			combatEvents.hitParryEnums.PushBack(BCH_Parry3);
			combatEvents.hitParryEnums.PushBack(BCH_Parry4);
		}
	}

	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.RemoveTimer('BlockRelease');
		parent.SetBlockingHit(false);
		// release a ticket
		thePlayer.GetTicketPool( TPT_Attack ).ReleaseTicket( parent );
		if(!parent.IsAlive())
		{
			parent.StopEffect('default_fx');
		}
	}
	
	// Attack has been blocked
	event OnAttackBlocked( hitParams : HitParams )
	{
		AttackBlockedKnightWraith();
	}
	
	entry function AttackBlockedKnightWraith()
	{
		var hit : W2BehaviorCombatHit;
		parent.CantBlockCooldown(2.5);
		parent.GetBehTreeMachine().Stop();
		hit = GetHitReflectedEnum();
		HitEvent(hit);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function TreeKnightwraith( params : SCombatParams )	
	{
		var weapon : SItemUniqueId;
		weapon = parent.GetInventory().GetItemByCategory( 'opponent_weapon', false );
		parent.DrawWeaponInstant( weapon );
		weapon = parent.GetInventory().GetItemByCategory( 'opponent_shield', false );
		parent.DrawWeaponInstant( weapon );
		combatParams = params;
		LoadTree( params );
	}
	
	private function GetDefaultTreeAlias() : string
	{	
		return "behtree\knight_wraith";
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3')
		{						
			Attack( animEventName );			
		}
		else if(animEventType == AET_Tick && animEventName == 'GuardDown')
		{
			parent.CantBlockCooldown(2.0);
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}
	function GetParryAttackEnum() : W2BehaviorCombatAttack
	{
		
		if(parryCounter == 0)
		{
			parryCounter += 1;
			return BCA_CounterParry1;
			
		}
		else if(parryCounter == 1)
		{
			parryCounter += 1;
			return BCA_CounterParry2;
			
		}
		else if(parryCounter == 2)
		{
			parryCounter += 1;
			return BCA_CounterParry3;
			
		}
		else
		{
			parryCounter = 0;
			return BCA_CounterParry4;
			
		}
	}
	entry function KnightWraithWeakenedStart()
	{
		var weakenedEnum : W2BehaviorCombatHit;
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.ClearRotationTarget();
		aardHitCounter = 0;
		weakenedEnum = BCH_HitWeakenedStart1;
		HitEvent(weakenedEnum);
		Sleep(0.1);
		parent.SetWeakened(true);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		Sleep(2.0);
		KnightWraithWeakenedStop();
	}
	entry function KnightWraithWeakenedStop()
	{
		var weakenedEnum : W2BehaviorCombatHit;
		weakenedEnum = BCH_HitWeakenedStop1;
		HitEvent(weakenedEnum);
		Sleep(0.1);
		parent.SetWeakened(false);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function KnightWraithWeakenedBlock()
	{
		var weakenedEnum : W2BehaviorCombatHit;
		if(Rand(2) == 1)
		{
			weakenedEnum = BCH_HitWeakened1;
		}
		else
		{
			weakenedEnum = BCH_HitWeakened2;
		}
		HitEvent(weakenedEnum);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		KnightWraithWeakenedStop();
	}
	entry function KnightWraithWeakenedBackHit()
	{
		var weakenedEnum : W2BehaviorCombatHit;
		weakenedEnum = BCH_HitWeakened3;
		HitEvent(weakenedEnum);
		Sleep(0.1);
		parent.SetWeakened(false);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function KnightWraithParryAttack()
	{
		var parryAttack : W2BehaviorCombatAttack;
		parent.PlayBloodOnHit();
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget(parent.GetTarget());
		parent.SetBlock(false);
		parent.SetAttackTarget(parent.GetTarget());
		parryAttack = GetParryAttackEnum();
		AttackEvent(parryAttack);
		parent.SetBlockingHit(false, 0.0);
		parent.WaitForBehaviorNodeDeactivation('ParryAttackEnd');
		parent.GetBehTreeMachine().Restart();
	}
	// Hit event
	event OnHit( hitParams : HitParams )
	{			
		if( parent.IsAlive() )
		{
			KnightWraithDamage(hitParams);
		}
	}
	function ParryChanceTest() : bool
	{
		return false;
	}
	entry function KnightWraithBlock()
	{
		var blockEnum : W2BehaviorCombatHit;
		parent.PlayBloodOnHit();
		parent.GetBehTreeMachine().Stop();
		blockEnum = GetHitParryEnum();
		HitEvent(blockEnum);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	event OnBeingHit( out hitParams : HitParams )
	{
		var isnlockinghit : bool = false;
		var rand : int;
		rand = Rand(3);
		if(theGame.GetDifficultyLevel()==0)
		{	
			return true;
		}
		else if(parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ))
		{
			if(parent.IsWeakened())
			{
				KnightWraithWeakenedBlock();
			}
			else if(parent.CheckCanBlock())
			{
				if(rand >= 1)
				{
					KnightWraithParryAttack();
				}
				else
				{
					KnightWraithBlock();
				}
				hitParams.attackReflected = true;
				return false;
			}
			else
			{
				return true;
			}
		}
		else
		{
			//hitParams.outDamageMultiplier = 5.0;
			if(parent.IsWeakened())
			{
				KnightWraithWeakenedBackHit();
			}
			else
			{
				return true;
			}
		}				
	}
	event OnYrdenHitReaction( yrden : CWitcherSignYrden)
	{
		YrdenReactionKnightWraith(yrden);
	}
	entry function YrdenReactionKnightWraith(yrden : CWitcherSignYrden)
	{
		var immobileDuration : float;
		immobileDuration = yrden.GetImmobileTime();
		parent.GetBehTreeMachine().Stop();
		parent.CantBlockCooldown(immobileDuration);
		HitEvent(BCH_HitYrden);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		Sleep(immobileDuration);
		parent.RaiseEvent('YrdenEnd');
		Sleep(0.1);
		parent.StopEffect('yrden_lv0_fx');
		parent.StopEffect('yrden_lv1_fx');
		parent.StopEffect('yrden_lv2_fx');
		parent.WaitForBehaviorNodeDeactivation('YrdenEnd');
		parent.GetBehTreeMachine().Restart();

	}
	event OnAardHitReaction( aard : CWitcherSignAard )
	{
		parent.PlayBloodOnHit();
		KnightWraithAardReactionHit();
	}
	entry function KnightWraithAardReactionHit()
	{
		if(!parent.ApplyCriticalEffect(CET_Stun, NULL,0, true))
		{
			if(aardHitCounter >= maxAardHitCounter)
			{
				KnightWraithWeakenedStart();
			}
			else
			{
				aardHitCounter += 1;
				parent.SetBlockingHit(false);
				parent.SetBlock(false);
				parent.CantBlockCooldown(3.0);
				parent.ActionCancelAll();
				parent.GetBehTreeMachine().Stop();	
				HitEvent(BCH_AardHit1);
				Sleep(0.1);
				parent.WaitForBehaviorNodeDeactivation('HitEnd');
				parent.GetBehTreeMachine().Restart();
			}
		}
		else
		{
				aardHitCounter += 1;
				parent.SetBlockingHit(false);
				parent.SetBlock(false);
				parent.CantBlockCooldown(3.0);
				parent.ActionCancelAll();
				parent.GetBehTreeMachine().Stop();	
				HitEvent(BCH_AardHit1);
				Sleep(0.1);
				parent.WaitForBehaviorNodeDeactivation('HitEnd');
				parent.GetBehTreeMachine().Restart();
		}
	}
	function KnightWraithDamage( hitParams : HitParams )
	{
		if( parent.IsStrongAttack(hitParams.attackType) )
		{
			HitStrongKnightWraith();
		}
		else
		{
			HitFastKnightWraith();
		}	
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
	entry function HitFastKnightWraith()
	{
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function HitStrongKnightWraith()
	{
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
		
	}
	
}