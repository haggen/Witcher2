/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** TreeCombatSword
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// TreeCombatSword state
/////////////////////////////////////////////
enum DualCharacterEnum
{
	DCE_Elf,
	DCE_Assasin
}
state TreeCombatDual in CNewNPC extends TreeCombatStandard
{
	var parryCounter : int;
	var hitParams  : HitParams;
	var hitCounter : int;
	var parryHitCounter : int;
	var hitParryRightEnums : array<W2BehaviorCombatHit>;
	var hitParryLeftEnums : array<W2BehaviorCombatHit>;
	var leftParry : bool;
	
	default leftParry = false;
	default parryHitCounter = 0;
	default parryCounter = 0;
		
	event OnEnterState()
	{
		var weaponId : SItemUniqueId;
		var combatEvents : W2CombatEvents;
		var i : int;
		
		parent.IssueRequiredItems( 'opponent_weapon', 'opponent_weapon_secondary' );
		
		hitCounter = 0;
		super.OnEnterState();						
		parent.SetSuperblock( false );
		hitParryRightEnums.PushBack(BCH_Parry1);
		hitParryLeftEnums.PushBack(BCH_Parry2);
		// does this kind of fight require the use of tickets?
		if( UseNewCombat() && parent.GetTarget() == thePlayer )
		{
			// acquire a ticket
			thePlayer.GetTicketPool( TPT_Attack ).RequestTicket( parent );
		}
		if( parent.CreateCombatEventsProxy( CECT_NPCDual ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();	
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			combatEvents.chargeEnums.PushBack(BCA_Charge2);
			
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected1);
			combatEvents.hitReflectedEnums.PushBack(BCH_AttackReflected2);
			
			combatEvents.hitParryEnums.PushBack(BCH_Parry3);
			
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong3);
		}
	}

	event OnLeaveState()
	{
		var secondWeapon, weapon : SItemUniqueId;
		secondWeapon = parent.GetInventory().GetItemByCategory('opponent_weapon_secondary', true);
		weapon = parent.GetInventory().GetItemByCategory('opponent_weapon', true);
		super.OnLeaveState();
		parent.RemoveTimer('BlockRelease');
		parent.SetBlockingHit(false);
		// release a ticket
		thePlayer.GetTicketPool( TPT_Attack ).ReleaseTicket( parent );
		if(!parent.IsAlive())
		{
			parent.GetInventory().DropItem(secondWeapon, true);
			parent.GetInventory().DropItem(weapon, true);
		}
	}
	
	// Attack has been blocked
	event OnAttackBlocked( hitParams : HitParams )
	{
		AttackBlockedDual();
	}
	
	entry function AttackBlockedDual()
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
	entry function TreeCombatDual( params : SCombatParams )	
	{
		var weapon : SItemUniqueId;
		var itemId : SItemUniqueId;
		var enumInt : int;
		parent.LockEntryFunction(true);
		SetCanPlayDamageAnim(false, 6.0);
		combatParams = params;
		
		parent.GetBehTreeMachine().Stop();	
		ExitWork();
		RequestTicketIfNeeded( params );
		LoadTree( params );
		ActivateCombatBehavior( params, 'npc_dual' );
		if(parent.HasCombatType(CT_Dual_Assasin))
		{
			enumInt = (int)DCE_Assasin;
			parent.SetBehaviorVariable("DualEnum", (float)enumInt);
		}
		SetCanPlayDamageAnim(true, 0.0);
		parent.GetBehTreeMachine().Restart();
		parent.LockEntryFunction(false);
	}
	
	private function GetDefaultTreeAlias() : string
	{	
		if( UseNewCombat() && parent.GetTarget() == thePlayer )
		{
			return "behtree\player_combat_dual";
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
			Attack( animEventName );			
		}
		else if(animEventType == AET_Tick && animEventName == 'GuardDown' )
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
		else
		{
			parryCounter = 0;
			return BCA_CounterParry3;
			
		}
		
		
	}
	
	entry function DualParryAttack()
	{
		var parryAttack : W2BehaviorCombatAttack;
		parryHitCounter = 0;
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget(parent.GetTarget());
		parent.SetBlock(false);
		parent.SetAttackTarget(parent.GetTarget());
		parryAttack = GetParryAttackEnum();
		AttackEvent(parryAttack);
		parent.WaitForBehaviorNodeDeactivation('ParryAttackEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function DualParryQuick()
	{
		var parryAttack : W2BehaviorCombatAttack;
		var parryEnum : W2BehaviorCombatHit;
		parryHitCounter +=1;
		parent.GetBehTreeMachine().Stop();
		parryEnum = GetDualParryQuickEnum();
		HitEvent(parryEnum);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
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
				DualDamage(hitParams);
			}
			else
			{
				parent.PlayBloodOnHit();
				theSound.PlaySoundOnActor(parent, 'head', "combat/weapons/hits/sword_hit");
			}
		}
	}	
	function GetDualParryQuickEnum() : W2BehaviorCombatHit
	{
		var parryHitEnum : W2BehaviorCombatHit;
		var sizeLeft, sizeRight : int;
		sizeLeft = hitParryLeftEnums.Size();
		sizeRight = hitParryRightEnums.Size();
		
		if(leftParry)
		{
			parryHitEnum = hitParryLeftEnums[Rand(sizeLeft)];
			leftParry = false;
		}
		else
		{
			parryHitEnum = hitParryRightEnums[Rand(sizeRight)];
			leftParry = true;
		}
		return parryHitEnum;
	}
	entry function DualParry()
	{
		var parryAttack : W2BehaviorCombatAttack;
		parryHitCounter +=1;
		parent.GetBehTreeMachine().Stop();
		HitEvent(GetHitParryEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		Sleep(1.2);
		parryAttack = BCA_CounterParry5;
		ParryEnd(parryAttack);
		parent.WaitForBehaviorNodeDeactivation('ParryEnd');
		parent.GetBehTreeMachine().Restart();		
	}
	event OnBeingHit( out hitParams : HitParams )
	{
		if(theGame.GetDifficultyLevel()==0)
		{	
			return true;
		}
		hitCounter += 1;
		parent.SetBlock(true);

		if(parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ))
		{			
			if((4 + Rand(5) < hitCounter) && parent.CheckCanBlock())
			{
				parent.SetBlock(true);
				hitCounter = 0;
				hitParams.attackReflected = true;
				if(Rand(6) == 1 && parryHitCounter < 1)
				{
					DualParry();
				}
				else
				{
					parryHitCounter = 0;
					DualParryAttack();
				}
				return false;
			}
			else if(parent.CheckCanBlock())
			{
				hitParams.damage = 0.0;
				hitParams.attackReflected = false;
				if(!parent.IsStrongAttack(hitParams.attackType))
				{
					DualParryQuick();
				}
				else
				{
					DualParry();
				}
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
		if(CanPlayDamageAnim())
			AxiiReactionDual();
	}
	event OnAxiiHitResult(axii : CWitcherSignAxii, success : bool)
	{
			AxiiReactionDualResult(success);
	}
		entry function AxiiReactionDual()
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
	entry function AxiiReactionDualResult(success : bool)
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
			YrdenReactionDual(yrden);
	}
	entry function YrdenReactionDual(yrden : CWitcherSignYrden)
	{
		var immobileDuration : float;
		immobileDuration = yrden.GetImmobileTime();
		parent.GetBehTreeMachine().Stop();
		parent.CantBlockCooldown(yrden.GetImmobileTime());
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
					DualAardReaction();
			}
		}
		else
		{
			if(CanPlayDamageAnim())
				DualAardReaction();
		}
	}
	entry function DualAardReaction()
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
			parent.CombatBurnStartDual();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}

	// Get proper behavior hit event name
	function DualDamage( hitParams : HitParams )
	{
		if( parent.IsStrongAttack(hitParams.attackType) )
		{
			HitStrongDual();
		}
		else
		{
			HitFastDual();
		}
	}
	
	entry function HitFastDual()
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
			parent.CombatBurnStartDual();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	
	entry function HitStrongDual()
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
			parent.CombatBurnStartDual();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	function GetCounterFastDualEnum() : W2BehaviorCombatAttack
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
	function GetCounterStrongDualEnum() : W2BehaviorCombatAttack
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
	entry function CounterFastDual()
	{
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 2;
		parent.SetAttackTarget( parent.GetTarget() );
		AttackEvent(GetCounterFastDualEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'AttackEnd' );
		//specialBlockTime = EngineTime();
		
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function CounterStrongDual()
	{
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 2;
		parent.SetAttackTarget( parent.GetTarget() );
		AttackEvent(GetCounterStrongDualEnum());
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
				CombatBurnStartDual();
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
				CombatBurnEndDual();
			return true;
		}
		else
		{
			return false;
		}
	}
	
	entry function CombatBurnStartDual()
	{
		parent.GetBehTreeMachine().Stop();
		HitEvent(BCH_HitBurn);
		
	}
	entry function CombatBurnEndDual()
	{
		HitEvent(BCH_HitBurn_End);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}	
}