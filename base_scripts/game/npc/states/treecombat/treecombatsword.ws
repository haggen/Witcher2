/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** TreeCombatSword
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// TreeCombatSword state
/////////////////////////////////////////////
state TreeCombatSword in CNewNPC extends TreeCombatStandard
{		
	var hitParams  : HitParams;
	var hitCounter : int;
	var parryHitCounter : int;
	var isSkilledSwordFighter : bool;
	var parryChance : float;
	default isSkilledSwordFighter = false;
	
	default parryHitCounter = 0;
		
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		var i : int;
		
		hitCounter = 0;
		
		super.OnEnterState();				
		
		parent.SetRequiredItems( 'None', 'opponent_weapon' );
		
		parryChance = parent.GetCharacterStats().GetFinalAttribute('block');
			
		parent.SetSuperblock( false );
		if(parent.HasCombatType(CT_Sword_Skilled))
		{
			isSkilledSwordFighter = true;
		}
		
		if( isSkilledSwordFighter )
		{
			if( parent.CreateCombatEventsProxy( CECT_NPCSword_Skilled ))
			{
				combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();	
				combatEvents.attackEnums.PushBack(BCA_MeleeAttack8);
				combatEvents.attackEnums.PushBack(BCA_MeleeAttack9);
				combatEvents.attackEnums.PushBack(BCA_MeleeAttack10);
				combatEvents.attackEnums.PushBack(BCA_MeleeSequence1);
				combatEvents.attackEnums.PushBack(BCA_MeleeSequence2);
				combatEvents.attackEnums.PushBack(BCA_MeleeSequence3);
				combatEvents.attackEnums.PushBack(BCA_MeleeSequence4);
				combatEvents.attackEnums.PushBack(BCA_MeleeSequence5);

				combatEvents.idleEnums.PushBack(BCI_Idle1);
				combatEvents.idleEnums.PushBack(BCI_Idle2);
				
				combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected1);
				combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected2);
							
				combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
				combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
				combatEvents.hitLightEnums.PushBack(BCH_HitFast3);
				combatEvents.hitLightEnums.PushBack(BCH_HitFast4);
				combatEvents.hitLightEnums.PushBack(BCH_HitFast5);
				
				combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
				combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
				
				combatEvents.chargeEnums.PushBack(BCA_Charge1);
				combatEvents.chargeEnums.PushBack(BCA_Charge2);
			}
		}
		else 
		{
			if( parent.CreateCombatEventsProxy( CECT_NPCSword ) )
			{
				combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();	
				combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
				combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
				combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
				combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
				combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
				combatEvents.attackEnums.PushBack(BCA_MeleeAttack6);
				combatEvents.attackEnums.PushBack(BCA_MeleeAttack7);
				
				combatEvents.idleEnums.PushBack(BCI_Idle1);
				combatEvents.idleEnums.PushBack(BCI_Idle2);

				
				combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected1);
				combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected2);
							
				combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
				combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
				combatEvents.hitLightEnums.PushBack(BCH_HitFast3);
				combatEvents.hitLightEnums.PushBack(BCH_HitFast4);
				combatEvents.hitLightEnums.PushBack(BCH_HitFast5);
				
				combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
				combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
				
				combatEvents.chargeEnums.PushBack(BCA_Charge1);
				combatEvents.chargeEnums.PushBack(BCA_Charge2);
			}
		}
	}

	event OnLeaveState()
	{
		var weapon : SItemUniqueId;
		super.OnLeaveState();
		parent.RemoveTimer('BlockRelease');
		parent.SetBlockingHit(false);
		weapon = parent.GetInventory().GetItemByCategory('opponent_weapon', true);
		// release a ticket
		thePlayer.GetTicketPool( TPT_Attack ).ReleaseTicket( parent );
		if(!parent.IsAlive())
		{
			parent.GetInventory().DropItem(weapon, true);
		}
	}
	
	// Attack has been blocked
	event OnAttackBlocked( hitParams : HitParams )
	{
		AttackBlockedSword();
	}
	
	entry function AttackBlockedSword()
	{
		var hit : W2BehaviorCombatHit;
		parent.CantBlockCooldown(1.5);
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();		
		hit = GetHitReflectedEnum();
		HitEvent(hit);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function TreeCombatSword( params : SCombatParams )	
	{
		parent.LockEntryFunction(true);
		SetCanPlayDamageAnim(false, 6.0);
		combatParams = params;
		parent.GetBehTreeMachine().Stop();	
		ExitWork();
		RequestTicketIfNeeded( params );
		ActivateCombatBehavior( params, 'npc_sword' );
		LoadTree( params );
		SetCanPlayDamageAnim(true, 0.0);
		parent.GetBehTreeMachine().Restart();
		parent.LockEntryFunction(false);
	}
	
	private function GetDefaultTreeAlias() : string
	{	
		if( UseNewCombat() && parent.GetTarget() == thePlayer )
		{
			return "behtree\player_combat_sword";
		}
		else
		{	
			return "behtree\combat_non_geralt";
		}
	}
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3')
		{						
			Attack( animEventName);			
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}
	function GetParryAttackEnum() : W2BehaviorCombatAttack
	{
		return BCA_CounterParry1;
	}
	
	entry function SwordParryAttack()
	{
		var parryAttack : W2BehaviorCombatAttack;
		parryHitCounter = 0;
		parent.ActionCancelAll();
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
			SwordDamage(hitParams);
		}
	}	
	function ParryChanceTest() : bool
	{
		if(RandF() <= parryChance)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	event OnBeingHit( out hitParams : HitParams )
	{
		var isnlockinghit : bool = false;
		if(theGame.GetDifficultyLevel()==0)
		{	
			return true;
		}
		else if(parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ))
		{
			if(isSkilledSwordFighter && ParryChanceTest() && parent.CheckCanBlock())
			{
				hitParams.attackReflected = true;
				SwordParryAttack();
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
			return true;
		}				
	}
	event OnAxiiHitReaction()
	{
		//if(CanPlayDamageAnim())
			AxiiReactionSword();
	}
	event OnAxiiHitResult(axii : CWitcherSignAxii, success : bool)
	{
		//if(CanPlayDamageAnim())
			AxiiReactionSwordResult(success);
	}
	entry function AxiiReactionSword()
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
	entry function AxiiReactionSwordResult(success : bool)
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
			YrdenReactionSword(yrden);
	}
	entry function YrdenReactionSword(yrden : CWitcherSignYrden)
	{
		var immobileDuration : float;
		parent.ClearRotationTarget();
		immobileDuration = yrden.GetImmobileTime();
		parent.GetBehTreeMachine().Stop();
		parent.CantBlockCooldown(immobileDuration);
		HitEvent(BCH_HitYrden);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		Sleep(immobileDuration);
		parent.RaiseEvent('YrdenEnd');
		Sleep(0.1);
		
		parent.WaitForBehaviorNodeDeactivation('YrdenEnd');
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartSword();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}

	}
	event OnAardHitReaction( aard : CWitcherSignAard )
	{
		if(parent.AardKnockdownChance())
		{

			if(!parent.ApplyCriticalEffect(CET_Stun, NULL, 0, true) && !parent.ApplyCriticalEffect(CET_Knockdown, NULL, 0, true))
			{
				if(CanPlayDamageAnim())
					SwordAardReactionHit();
			}
		}
		else
		{
			if(CanPlayDamageAnim())
				SwordAardReactionHit();
		}
			
	}
	entry function SwordAardReactionHit()
	{
		SetCanPlayDamageAnim(false, 3.0);
		parent.GetBehTreeMachine().Stop();
		virtual_parent.SetBlockingHit(false);
		virtual_parent.SetBlock(false);
		virtual_parent.CantBlockCooldown(3.0);
		virtual_parent.ActionCancelAll();
		virtual_parent.ClearRotationTarget();
		HitEvent(BCH_AardHit1);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		SetCanPlayDamageAnim(true, 0.0);
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartSword();
		}	
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	function SwordDamage( hitParams : HitParams )
	{
		if( parent.IsStrongAttack(hitParams.attackType) )
		{
			if(CanPlayDamageAnim())
			{
				HitStrongSword();
			}
			else
			{
				parent.PlayStrongBloodOnHit();
				theSound.PlaySoundOnActor(parent, 'head', "combat/weapons/hits/sword_hit");
			}
			
		}
		else
		{
			if(CanPlayDamageAnim())
			{
				HitFastSword();
			}
			else
			{
				parent.PlayBloodOnHit();
				theSound.PlaySoundOnActor(parent, 'head', "combat/weapons/hits/sword_hit");
			}
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
				CombatBurnStartSword();
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
				CombatBurnEndSword();
			return true;
		}
		else
		{
			return false;
		}
	}
	entry function CombatKnockdownStartSword()
	{
		parent.GetBehTreeMachine().Stop();
		HitEvent(BCH_Knockdown);
	}
	entry function CombatKnockdownStopSword()
	{
		HitEvent(BCH_KnockdownEnd);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function CombatBurnStartSword()
	{
		parent.GetBehTreeMachine().Stop();
		if(CanPlayDamageAnim())
			HitEvent(BCH_HitBurn);
		
	}
	entry function CombatBurnEndSword()
	{
		if(CanPlayDamageAnim())
		{
			HitEvent(BCH_HitBurn_End);
			Sleep(0.1);
			parent.WaitForBehaviorNodeDeactivation('HitEnd');
		}
		parent.GetBehTreeMachine().Restart();
	}
	entry function HitFastSword()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartSword();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
		parent.ProcessRequiredItems();
	}
	
	entry function HitStrongSword()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartSword();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
		parent.ProcessRequiredItems();
	}
	
}
