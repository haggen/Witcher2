/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

state TreeCombatNekker in CNekker extends TreeCombatMonster
{	
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		super.OnEnterState();

		parent.DrawWeaponInstant(parent.GetInventory().GetFirstLethalWeaponId());	

		if( parent.CreateCombatEventsProxy( CECT_Nekker ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();
			//Standard Nekker Attacks
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence1);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence2);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence3);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);

			//Standard nekker hit events
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast3);
			
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong3);
			
			//Standard dodge events 
			combatEvents.dodgeBackEnums.PushBack(BCH_DodgeBack1);
			combatEvents.dodgeBackEnums.PushBack(BCH_DodgeBack2);
			combatEvents.dodgeBackEnums.PushBack(BCH_DodgeBack3);
			combatEvents.dodgeLeftEnums.PushBack(BCH_DodgeLeft1);
			combatEvents.dodgeRightEnums.PushBack(BCH_DodgeRight1);
			
			//CombatIdle events
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			combatEvents.idleEnums.PushBack(BCI_Idle3);
			combatEvents.idleEnums.PushBack(BCI_Idle4);
			
			//Combat charge
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
		}
		
		parent.SetCombatSlotOffset(1.3);
		
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.ClearAttackTarget();
	}
	
	entry function TreeCombatNekker( params : SCombatParams )
	{
		LoadTree( params );
	}
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\nekker";
	}
			
	event OnBeingHit( out hitParams : HitParams )
	{
		parent.ClearAttackTarget();
		return !parent.IsBlockingHit();
	}
	
	event OnAttackTell( hitParams : HitParams )
	{
		if( hitParams.attackType == 'StrongSwing' && Rand(2) == 1)
		{
			parent.GetBehTreeMachine().Stop();
			parent.ActionRotateToAsync( hitParams.hitPosition );
			if( parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ) )
			{
				parent.SetBlockingHit( true, 0.75 );
				TreeDodgeStart();					
			}
		}
	}
	
	event OnAardHitReaction( CWitcherSignAard : CWitcherSignAard )
	{
		if(parent.AardKnockdownChance())
		{
			parent.ActionRotateToAsync( thePlayer.GetWorldPosition() );
			if(!parent.ApplyCriticalEffect(CET_Stun, NULL,0, true))
				parent.ApplyCriticalEffect( CET_Knockdown, NULL, 0, true );
			TreeDelayedCombatRestart();
		}
		else
		{
			HitStrongNekker();
		}
	}
	
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{		
		if(parent.IsStrongAttack(hitParams.attackType))
		{
			HitStrongNekker();
		}
		else
		{
			HitFastNekker();
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
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}

	}
	entry function HitFastNekker()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function HitStrongNekker()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	function KnockdownOrHit( hitParams : HitParams ) : name
	{
		if( parent.ApplyCriticalEffect(CET_Knockdown, hitParams.attacker, 0, true ) )			
			return '';
		else
			return GetHitEventName_t0();	
	}
	
};