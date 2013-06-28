/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** NPC Combat
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// CombatShield state
/////////////////////////////////////////////
state TreeCombatShieldShield in CNewNPC extends TreeCombatStandard
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
		
		// Inform npc what items should he use
		parent.IssueRequiredItems( 'opponent_shield', 'opponent_weapon' );
		
		parent.SetWeakened( false );

		if(parent.CreateCombatEventsProxy( CECT_NPCShielded ))
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
		var shield, weapon : SItemUniqueId;
		shield = parent.GetInventory().GetItemByCategory('opponent_shield', true);
		weapon = parent.GetInventory().GetItemByCategory('opponent_weapon', true);
		super.OnLeaveState();
		parent.RemoveTimer('BlockRelease');
		parent.SetBlockingHit(false);
		// release a ticket
		thePlayer.GetTicketPool( TPT_Attack ).ReleaseTicket( parent );
		if(!parent.IsAlive())
		{
			parent.GetInventory().DropItem(shield, true);
			parent.GetInventory().DropItem(weapon, true);
		}
	}
	
	// Attack has been blocked
	event OnAttackBlocked( hitParams : HitParams )
	{
		AttackBlockedShield();
	}
	
	entry function AttackBlockedShield()
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
	entry function TreeCombatShieldSword( params : SCombatParams )	
	{
		parent.LockEntryFunction(true);
		SetCanPlayDamageAnim(false, 6.0);
		combatParams = params;
		parent.GetBehTreeMachine().Stop();	
		ExitWork();
		RequestTicketIfNeeded( params );
		LoadTree( params );
		ActivateCombatBehavior( params, 'npc_shield' );
		SetCanPlayDamageAnim(true, 0.0);
		parent.GetBehTreeMachine().Restart();
		parent.LockEntryFunction(false);
	}
	
	private function GetDefaultTreeAlias() : string
	{	
		if( UseNewCombat() && parent.GetTarget() == thePlayer )
		{
			return "behtree\player_combat_shield";
		}
		else
		{	
			if(parent.HasTag('arena_wingman'))
			{
				return "behtree\arena_ng";
			}
			else
			{
				return "behtree\combat_non_geralt";
			}
		}
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
		else if(parryCounter == 3)
		{
			parryCounter += 1;
			return BCA_CounterParry4;
			
		}
		else
		{
			parryCounter = 0;
			return BCA_CounterParry5;
			
		}
	}
	entry function ShieldWeakenedStart()
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
		ShieldWeakenedStop();
	}
	entry function ShieldWeakenedStop()
	{
		var weakenedEnum : W2BehaviorCombatHit;
		weakenedEnum = BCH_HitWeakenedStop1;
		HitEvent(weakenedEnum);
		Sleep(0.1);
		parent.SetWeakened(false);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function ShieldWeakenedBlock()
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
		ShieldWeakenedStop();
	}
	entry function ShieldWeakenedBackHit()
	{
		var weakenedEnum : W2BehaviorCombatHit;
		SetCanPlayDamageAnim(false, 5.0);
		weakenedEnum = BCH_HitWeakened3;
		HitEvent(weakenedEnum);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.SetWeakened(false);
		parent.GetBehTreeMachine().Restart();
		SetCanPlayDamageAnim(true, 0.0);
	}
	entry function ShieldParryAttack()
	{
		var parryAttack : W2BehaviorCombatAttack;
		parent.GetBehTreeMachine().Stop();
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
			if(CanPlayDamageAnim())
			{
				ShieldDamage(hitParams);
			}
			else
			{
				parent.PlayBloodOnHit();
				theSound.PlaySoundOnActor(parent, 'head', "combat/weapons/hits/sword_hit");
			}
		}
	}
	function ParryChanceTest() : bool
	{
		return false;
	}
	entry function ShieldBlock()
	{
		var blockEnum : W2BehaviorCombatHit;
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
		else if(parent.IsWeakened() && parent.IsRotatedTowardsPoint( hitParams.hitPosition, 45 ))
		{
			ShieldWeakenedBlock();
		}
		else if(parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ))
		{

			if(parent.CheckCanBlock())
			{
				if(rand >= 1)
				{
					ShieldParryAttack();
				}
				else
				{
					ShieldBlock();
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
			if(parent.IsWeakened() && CanPlayDamageAnim())
			{
				ShieldWeakenedBackHit();
				return true;
			}
			else
			{
				return true;
			}
		}				
	}
	event OnAxiiHitReaction()
	{
		if(CanPlayDamageAnim())
			AxiiReactionShield();
	}
	event OnAxiiHitResult(axii : CWitcherSignAxii, success : bool)
	{
		AxiiReactionShieldResult(success);
	}
		entry function AxiiReactionShield()
	{
		parent.GetBehTreeMachine().Stop();
		parent.CantBlockCooldown(2.0);
		SetCanPlayDamageAnim(false, 5.0);
		HitEvent(BCH_AxiiLoop);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		SetCanPlayDamageAnim(true, 0.0);
		Sleep(5.0);
		parent.GetBehTreeMachine().Restart();
	}
	entry function AxiiReactionShieldResult(success : bool)
	{
		var berserkDuration : float;
		
		parent.GetBehTreeMachine().Stop();
		parent.CantBlockCooldown(2.0);
		SetCanPlayDamageAnim(false, 3.0);
		if(success)
		{
			HitEvent(BCH_HitAxiiSuccess);
		}
		else
		{
			HitEvent(BCH_HitAxiiFail);
		}
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		SetCanPlayDamageAnim(true, 0.0);
		parent.GetBehTreeMachine().Restart();
	}
	event OnYrdenHitReaction( yrden : CWitcherSignYrden)
	{
		if(CanPlayDamageAnim())
			YrdenReactionShield(yrden);
	}
	entry function YrdenReactionShield(yrden : CWitcherSignYrden)
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
		if(parent.AardKnockdownChance())
		{
			
			if(!parent.ApplyCriticalEffect(CET_Stun, NULL, 0, true) && !parent.ApplyCriticalEffect(CET_Knockdown, NULL, 0, true))
			{
				if(CanPlayDamageAnim())
					ShieldAardReactionHit();
			}
		}
		else
		{
			if(CanPlayDamageAnim())
				ShieldAardReactionHit();
		}
		
	}
	entry function ShieldAardReactionHit()
	{
		if(aardHitCounter >= maxAardHitCounter)
		{
			ShieldWeakenedStart();
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
			if(parent.IsCriticalEffectApplied(CET_Burn))
			{
				parent.CombatBurnStartShield();
			}
			else
			{
				parent.GetBehTreeMachine().Restart();
			}
		}	
	}
	function ShieldDamage( hitParams : HitParams )
	{
		if( parent.IsStrongAttack(hitParams.attackType) )
		{
			HitStrongShield();
		}
		else
		{
			HitFastShield();
		}	
	}
	event OnCriticalEffectStart( effectType : ECriticalEffectType, duration : float )
	{
		if(effectType == CET_Burn)
		{
			if(CanPlayDamageAnim())
			{
				parent.ActionCancelAll();
				parent.ClearRotationTarget();
				parent.CantBlockCooldown(duration);
				CombatBurnStartShield();
			}
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
			if(CanPlayDamageAnim())
				CombatBurnEndShield();
			return true;
		}
		else
		{
			return false;
		}
	}
	
	entry function CombatBurnStartShield()
	{
		parent.GetBehTreeMachine().Stop();
		HitEvent(BCH_HitBurn);
		
	}
	entry function CombatBurnEndShield()
	{
		HitEvent(BCH_HitBurn_End);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function HitFastShield()
	{
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartShield();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	
	entry function HitStrongShield()
	{
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartShield();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	
}
