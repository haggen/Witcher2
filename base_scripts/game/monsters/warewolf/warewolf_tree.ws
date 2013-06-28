/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

state TreeCombatWarewolf in CWarewolf extends TreeCombatMonster
{	
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		super.OnEnterState();

		parent.DrawWeaponInstant(parent.GetInventory().GetFirstLethalWeaponId());	

		if( parent.CreateCombatEventsProxy( CECT_Warewolf ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();
			//Standard Nekker Attacks

			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack6);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack7);

			//Standard nekker hit events
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast3);
			
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
			
			combatEvents.specialAttackEnums1.PushBack(BCA_Special1);
			
			//CombatIdle events
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			
			//Combat charge
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			combatEvents.chargeEnums.PushBack(BCA_Charge2);
			combatEvents.chargeEnums.PushBack(BCA_FromSlot1);
		}
		
		parent.SetCombatSlotOffset(1.3);
		
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.ClearAttackTarget();
	}
	
	entry function TreeCombatWarewolf( params : SCombatParams )
	{
		LoadTree( params );
	}
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\warewolf";
	}
			
	event OnBeingHit( out hitParams : HitParams )
	{
		parent.ClearAttackTarget();
		if(theGame.GetDifficultyLevel() == 0)
		{
			return true;
		}
		if(Rand(3) == 1 && parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ))
		{
			hitParams.attackReflected = true;
			WarewolfParry();
			return false;
		}
		else
		{
			return !parent.IsBlockingHit();
		}
	}
	
	entry function WarewolfCounter()
	{
		var attackEvent : W2BehaviorCombatAttack;
		
		var rand : int;
		
		parent.GetBehTreeMachine().Stop();
		
		if(parent.GetTarget())
		{
			parent.SetRotationTarget(parent.GetTarget());
		}
		
		rand = Rand(2);
		
		switch( rand )
		{
			case 0 : attackEvent = BCA_HitCounterFast1;
				break;
				
			case 1 : attackEvent = BCA_HitCounterFast2;
				break;
				
			case 2 : attackEvent = BCA_HitCounterFast3;
				break;	
		}
		parent.SetAttackTarget( parent.GetTarget() );
		AttackEvent(attackEvent);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('AttackEnd');
		parent.GetBehTreeMachine().Restart();
	}
	entry function WarewolfParry()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		AttackEvent(BCA_CounterParry1);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'AttackEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	
	event OnAardHitReaction( CWitcherSignAard : CWitcherSignAard )
	{
		if(parent.AardKnockdownChance())
		{
			parent.ActionRotateToAsync( thePlayer.GetWorldPosition() );
			if(!parent.ApplyCriticalEffect( CET_Knockdown, NULL,0, true))
			{
				if(!parent.ApplyCriticalEffect( CET_Stun, NULL, 0, true ))
				{
					HitStrongWarewolf();
				}
			}
				
			TreeDelayedCombatRestart();
		}
		else
		{
			HitStrongWarewolf();
		}
	}
	
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{		
		if(parent.IsStrongAttack(hitParams.attackType))
		{
			HitStrongWarewolf();
		}
		else
		{
			//HitFastWarewolf();
			HitStrongWarewolf();
		}
	}
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{

		if ( animEventName == 'trail_l' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_l');
		}
		else if ( animEventName == 'trail_r' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_r');
		}
		else if( animEventName == 'Charging' )
		{
			if( theGame.GetEngineTime() - chargeAttackTime > 2.0 )
			{
				if( Attack( 'Attack_t3' ) )
				{
					chargeAttackTime = theGame.GetEngineTime();
				}
			}
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}

	}
	entry function HitFastWarewolf()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );

		WarewolfCounter();
		
		//parent.GetBehTreeMachine().Restart();
	}
	
	entry function HitStrongWarewolf()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		
		WarewolfCounter();
		
		//parent.GetBehTreeMachine().Restart();
	}
	function KnockdownOrHit( hitParams : HitParams ) : name
	{
		if( parent.ApplyCriticalEffect(CET_Knockdown, hitParams.attacker, 0, true ) )			
			return '';
		else
			return GetHitEventName_t0();	
	}
	
};