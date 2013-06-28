/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** NPC Combat
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// CombatPoleArmstate
/////////////////////////////////////////////

state TreeCombatPoleArm in CNewNPC extends TreeCombatStandard
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
		
		parent.IssueRequiredItems( 'None', 'opponent_weapon_polearm' );
	
		parent.SetSuperblock( false );

		// does this kind of fight require the use of tickets?
		if( UseNewCombat() && parent.GetTarget() == thePlayer )
		{
			// acquire a ticket
			thePlayer.GetTicketPool( TPT_Attack ).RequestTicket( parent );
		}
		if( parent.CreateCombatEventsProxy( CECT_NPCPoleArm) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();	
			//combatEvents.attackEnums.PushBack(BCA_MeleeSequence1);
			//combatEvents.attackEnums.PushBack(BCA_MeleeSequence2);
			//combatEvents.attackEnums.PushBack(BCA_MeleeSequence3);
			//combatEvents.attackEnums.PushBack(BCA_MeleeSequence4);
			//combatEvents.attackEnums.PushBack(BCA_MeleeSequence5);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
			
			//combatEvents.chargeEnums.PushBack(BCA_Charge1);
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
			
			//combatEvents.hitParryEnums.PushBack(BCH_Parry1);
			//combatEvents.hitParryEnums.PushBack(BCH_Parry2);
			
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
		if(weapon == GetInvalidUniqueId())
			weapon = parent.GetInventory().GetItemByCategory('opponent_weapon_polearm', true);
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
		AttackBlockedPoleArm();
	}
	
	entry function AttackBlockedPoleArm()
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
	entry function TreeCombatPoleArm( params : SCombatParams )	
	{
		parent.LockEntryFunction(true);
		SetCanPlayDamageAnim(false, 6.0);
		combatParams = params;
		parent.GetBehTreeMachine().Stop();	
		ExitWork();
		RequestTicketIfNeeded( params );
		LoadTree( params );
		ActivateCombatBehavior( params, 'npc_polearm' );
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
			return "behtree\combat_non_geralt";
		}
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3')
		{	
			//Halberd always knocks player down.
			animEventName = 'Attack_t3';	
			Attack( animEventName );			
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
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
				PoleArmDamage(hitParams);
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
			return true;
		}
		else
		{
			//hitParams.outDamageMultiplier = 5.0;	 
			return true;
		}
	}
	event OnAxiiHitReaction()
	{
		if(CanPlayDamageAnim())
			AxiiReactionPole();
	}
	event OnAxiiHitResult(axii : CWitcherSignAxii, success : bool)
	{
			AxiiReactionPoleResult(success);
	}
	entry function AxiiReactionPole()
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
	entry function AxiiReactionPoleResult(success : bool)
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
			YrdenReactionPoleArm(yrden);
	}
	entry function YrdenReactionPoleArm(yrden : CWitcherSignYrden)
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
					AardReactionPoleArm();
			}
		}
		else
		{
			if(CanPlayDamageAnim())
				AardReactionPoleArm();
		}
		
	}
	entry function AardReactionPoleArm()
	{
		SetCanPlayDamageAnim(false, 3.0);
		parent.SetBlockingHit(false);
		parent.SetBlock(false);
		parent.CantBlockCooldown(3.0);
		parent.ActionCancelAll();
		parent.SetRotationTarget( parent.GetTarget() );
		parent.GetBehTreeMachine().Stop();	
		HitEvent(BCH_AardHit1);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		SetCanPlayDamageAnim(true, 0.0);
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartPoleArm();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}

	// Get proper behavior hit event name
	function PoleArmDamage( hitParams : HitParams )
	{
		if(Rand(2) == 1 || !parent.CheckCanBlock())
		{
			if( parent.IsStrongAttack(hitParams.attackType) )
			{
				HitStrongPoleArm();
			}
			else
			{
				HitFastPoleArm();
			}
		}
		else
		{
			if(parent.IsStrongAttack(hitParams.attackType))
			{
				CounterStrongPoleArm();
			}
			else
			{
				CounterFastPoleArm();
			}
		}
	}
	
	entry function HitFastPoleArm()
	{
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 0.0;
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		//specialBlockTime = EngineTime();
		
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartPoleArm();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	
	entry function HitStrongPoleArm()
	{
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 0.0;
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		//specialBlockTime = EngineTime();
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartPoleArm();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
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
	entry function CounterFastPoleArm()
	{
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 2;
		parent.SetAttackTarget( parent.GetTarget() );
		AttackEvent(GetCounterFastEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'AttackEnd' );
		//specialBlockTime = EngineTime();
		
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function CounterStrongPoleArm()
	{
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 2;
		parent.SetAttackTarget( parent.GetTarget() );
		AttackEvent(GetCounterStrongEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'AttackEnd' );
		//specialBlockTime = EngineTime();
		
		parent.GetBehTreeMachine().Restart();
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
				CombatBurnStartPoleArm();
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
				CombatBurnEndPoleArm();
			return true;
		}
		else
		{
			return false;
		}
	}
	
	entry function CombatBurnStartPoleArm()
	{
		parent.GetBehTreeMachine().Stop();
		HitEvent(BCH_HitBurn);
		
	}
	entry function CombatBurnEndPoleArm()
	{
		HitEvent(BCH_HitBurn_End);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}

}
