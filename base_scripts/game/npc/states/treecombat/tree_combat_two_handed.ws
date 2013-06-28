/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** NPC Combat
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// CombatTwoHanded state
/////////////////////////////////////////////

state TreeCombatTwoHanded in CNewNPC extends TreeCombatStandard
{		

	var hitParams  : HitParams;
	var hitCounter : int;
	var parryHitCounter : int;
	
	default parryHitCounter = 0;
		
	event OnEnterState()
	{
		var weaponId : SItemUniqueId;
		var combatEvents : W2CombatEvents;
		var i : int;
		
		hitCounter = 0;
		
		super.OnEnterState();
		
		parent.IssueRequiredItems( 'None', 'opponent_weapon' );
	
		parent.SetSuperblock( false );

		if( parent.CreateCombatEventsProxy( CECT_NPCTwoHanded ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();	
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence1);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence2);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence3);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence4);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence5);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
			
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			combatEvents.chargeEnums.PushBack(BCA_FromSlot1);
			combatEvents.chargeEnums.PushBack(BCA_FromSlot2);
			combatEvents.chargeEnums.PushBack(BCA_FromSlot3);
			
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected1);
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected2);
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected3);
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected4);
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected5);
			
			combatEvents.hitParryEnums.PushBack(BCH_Parry1);
			combatEvents.hitParryEnums.PushBack(BCH_Parry2);
			
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast3);
			
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong3);
		}
	}
	
	event OnLeaveState()
	{
		var weapon : SItemUniqueId;
		weapon = parent.GetInventory().GetItemByCategory('opponent_weapon', true);
		super.OnLeaveState();
		parent.RemoveTimer('BlockRelease');
		parent.SetBlockingHit(false);
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
		AttackBlockedTwoHanded();
	}
	event OnAxiiHitReaction()
	{
		if(CanPlayDamageAnim())
			AxiiReactionTwoHanded();
	}
	event OnAxiiHitResult(axii : CWitcherSignAxii, success : bool)
	{
		AxiiReactionTwoHandedResult(success);
	}
		entry function AxiiReactionTwoHanded()
	{
		parent.GetBehTreeMachine().Stop();
		parent.CantBlockCooldown(2.0);
		SetCanPlayDamageAnim(false, 2.0);
		HitEvent(BCH_AxiiLoop);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		SetCanPlayDamageAnim(true, 0.0);
		Sleep(5.0);
		parent.GetBehTreeMachine().Restart();
	}
	entry function AxiiReactionTwoHandedResult(success : bool)
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
	entry function AttackBlockedTwoHanded()
	{
		var hit : W2BehaviorCombatHit;
		parent.CantBlockCooldown(1.5);
		parent.GetBehTreeMachine().Stop();
		hit = GetHitReflectedEnum();
		HitEvent(hit);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function TreeCombatTwoHanded( params : SCombatParams )	
	{
		parent.LockEntryFunction(true);
		SetCanPlayDamageAnim(false, 6.0);
		combatParams = params;
		parent.GetBehTreeMachine().Stop();
		ExitWork();
		RequestTicketIfNeeded( params );
		LoadTree( params );
		ActivateCombatBehavior( params, 'npc_twohanded' );
		SetCanPlayDamageAnim(true, 0.0);
		parent.GetBehTreeMachine().Restart();
		parent.LockEntryFunction(false);
		
	}
	
	private function GetDefaultTreeAlias() : string
	{	
		if( UseNewCombat() && parent.GetTarget() == thePlayer )
		{
			return "behtree\player_combat_twohanded";
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
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}
	}
	entry function TwoHandedBerserk()
	{
		parent.SetBlock(false);
		parent.SetBlockingHit(false, 0.0);
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget(parent.GetTarget());
		AttackEvent(BCA_Special1);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('BerserkEnd');
		parent.GetBehTreeMachine().Restart();
	}
	function GetParryAttackEnum() : W2BehaviorCombatAttack
	{
		var rand : int;
		rand = Rand(4) + 1;
		if(rand == 1)
		{
			return BCA_CounterParry1;
		}
		else if(rand == 2)
		{
			return BCA_CounterParry2;
		}
		else if(rand == 3)
		{
			return BCA_CounterParry3;
		}
		else
		{
			return BCA_CounterParry4;
		}
	}
	
	entry function TwoHandedParryAttack()
	{
		var parryAttack : W2BehaviorCombatAttack;
		parryHitCounter = 0;
		parent.GetBehTreeMachine().Stop();
		parent.SetBlock(false);
		parent.SetAttackTarget(parent.GetTarget());
		parryAttack = GetParryAttackEnum();
		AttackEvent(parryAttack);
		parent.SetBlockingHit(false, 0.0);
		parent.WaitForBehaviorNodeDeactivation('ParryAttackEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function TwoHandedParryQuick()
	{
		var parryAttack : W2BehaviorCombatAttack;
		if(parent.GetHealth()< 0.5*parent.GetCharacterStats().GetFinalAttribute('vitality') && Rand(2) == 1)
		{
			TwoHandedBerserk();
		}
		else if(Rand(2) == 1 || parryHitCounter >= 1)
		{
			TwoHandedParryAttack();
		}
		else
		{
			parryHitCounter +=1;
			parent.SetBlock(true);
			parent.SetBlockingHit(true, 2.0);
			parent.GetBehTreeMachine().Stop();
			HitEvent(GetHitParryEnum());
			Sleep(1.5);
			parent.CantBlockCooldown(2.0);
			parent.SetAttackTarget( parent.GetTarget());
			parryAttack = GetParryAttackEnum();
			ParryEnd(parryAttack);
			parent.SetBlock(false);
			parent.SetBlockingHit(false, 0.0);
			parent.WaitForBehaviorNodeDeactivation('ParryEnd');
			parent.SetBlockingHit(false, 1.0);
			parryHitCounter = 0;
			parent.GetBehTreeMachine().Restart();
		}
	}
	// Hit event
	event OnHit( hitParams : HitParams )
	{		
		//var eventName : name;		
		//super.OnHit( hitParams );		
		if( parent.IsAlive() )
		{
			if(CanPlayDamageAnim())
			{
				TwoHandedDamage(hitParams);
			}
			else
			{
				parent.PlayBloodOnHit();
				theSound.PlaySoundOnActor(parent, 'head', "combat/weapons/hits/sword_hit");
			}
		}
	}	
	
	event OnBeingHit( out hitParams : HitParams )
	{
		var isnlockinghit : bool = false;
		if(theGame.GetDifficultyLevel()==0)
		{	
			return true;
		}
		hitCounter += 1;
		/*if( specialBlockTime > theGame.GetEngineTime() )
		{
			return false;
		}*/
		if(parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ))
		{
			if((Rand(5) < hitCounter || parent.IsBlockingHit())&& parent.CheckCanBlock())
			{
				parent.SetBlock(true);
				parent.SetBlockingHit(true, 2.0);
				hitParams.attackReflected = true;
				hitCounter = 0;
				TwoHandedParryQuick();
				return false;
			}
			else
			{
				return true;
			}
		}
		/*else if( superblockCounter >= 0 )
		{
			HitCounter();
		}*/
		else
		{
			//hitParams.outDamageMultiplier = 5.0;	 
			return true;
		}
	
		// If can block block, and return false to stop hit processing		
		/*if( parent.IsBlockingHit() )
		{	
			if( parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ) )
			{
				parent.RaiseEvent( 'hit_blocked' );
				//SetBlockTimer();
				return false;
			}
			else
			{
				// Attack from rear is not blocked
				parent.SetBlockingHit(false);
				//parent.RemoveTimer('BlockRelease');
				//TreeCombatSword();
				return true;
			}				
		}*/
		
	}
	event OnYrdenHitReaction( yrden : CWitcherSignYrden)
	{
		if(CanPlayDamageAnim())
			YrdenReactionTwoHanded(yrden);
	}
	entry function YrdenReactionTwoHanded(yrden : CWitcherSignYrden)
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
					AardReactionTwoHanded();
			}
		}
		else
		{
			if(CanPlayDamageAnim())
				AardReactionTwoHanded();
		}
		
	}
	entry function AardReactionTwoHanded()
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
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartTwohanded();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	// Get proper behavior hit event name
	function TwoHandedDamage( hitParams : HitParams )
	{
		if(Rand(2) == 1 || !parent.CheckCanBlock())
		{
			if( parent.IsStrongAttack(hitParams.attackType) )
			{
				HitStrong();
			}
			else
			{
				HitFast();
			}
		}
		else
		{
			if(parent.IsStrongAttack(hitParams.attackType))
			{
				CounterStrong();
			}
			else
			{
				CounterFast();
			}
		}
	}
	
	entry function HitFast()
	{
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 0.0;
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		//specialBlockTime = EngineTime();
		
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function HitStrong()
	{
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 0.0;
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		//specialBlockTime = EngineTime();
		parent.GetBehTreeMachine().Restart();
	}
	function GetCounterFastEnum() : W2BehaviorCombatAttack
	{
		var rand : int;
		rand = Rand(3) + 1;
		if(rand == 1)
		{
			return BCA_HitCounterFast1;
		}
		else if(rand == 2)
		{
			return BCA_HitCounterFast2;
		}
		else
		{
			return BCA_HitCounterFast3;
		}
	}
	function GetCounterStrongEnum() : W2BehaviorCombatAttack
	{
		var rand : int;
		rand = Rand(3) + 1;
		if(rand == 1)
		{
			return BCA_HitCounterStrong1;
		}
		else if(rand == 2)
		{
			return BCA_HitCounterStrong2;
		}
		else
		{
			return BCA_HitCounterStrong3;
		}
	}
	entry function CounterFast()
	{
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 2;
		parent.SetAttackTarget( parent.GetTarget() );
		AttackEvent(GetCounterFastEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'AttackEnd' );
		//specialBlockTime = EngineTime();
		
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartTwohanded();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	
	entry function CounterStrong()
	{
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 2;
		parent.SetAttackTarget( parent.GetTarget() );
		AttackEvent(GetCounterStrongEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'AttackEnd' );
		//specialBlockTime = EngineTime();
		
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartTwohanded();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
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
				CombatBurnStartTwohanded();
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
				CombatBurnEndTwohanded();
			return true;
		}
		else
		{
			return false;
		}
	}
	
	entry function CombatBurnStartTwohanded()
	{
		parent.GetBehTreeMachine().Stop();
		HitEvent(BCH_HitBurn);
		
	}
	entry function CombatBurnEndTwohanded()
	{
		HitEvent(BCH_HitBurn_End);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}

}
