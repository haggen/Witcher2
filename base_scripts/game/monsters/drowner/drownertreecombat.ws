/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

state TreeCombatDrowner in CDrowner extends TreeCombatMonster
{		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	var bombEntity : CAreaOfEffect;
	var weakenedLevels : array<int>;
	var weakenedCounter : int;
	var hitParams  : HitParams;
	var counterTime : EngineTime;
	var templ : CEntityTemplate;
	
	var isHidingBreakAllowed : bool;
	default isHidingBreakAllowed = false;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		var i : int;
		
		super.OnEnterState();
		parent.DrawWeaponInstant( parent.GetInventory().GetFirstLethalWeaponId() );
		
		if( parent.CreateCombatEventsProxy( CECT_Rotfiend ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();
			//Rotfiend Attacks
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
			
			
			//Rotfiend hit events
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);

			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);

			
			//CombatIdle events
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);

			
			//Combat charge
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			
			//Combat special attacks
			combatEvents.specialAttackEnums1.PushBack(BCA_Special1);
			
		}		
		
		parent.SetCombatSlotOffset(1.9);

	}
	
	event OnLeaveState()
	{

		super.OnLeaveState();
		parent.ClearAttackTarget();
	}
	

	
	entry function TreeCombatDrowner( params : SCombatParams )
	{

		LoadTree( params );
		
		templ = (CEntityTemplate)LoadResource("gameplay\despawn_rotfiend");
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3')
		{						
			Attack( animEventName );			
		}
		else if ( animEventName == 'Explode' && animEventType == AET_Tick)
		{
			//Explosion();
		}
		else if ( animEventName == 'trail_l' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_l');
		}
		else if ( animEventName == 'trail_r' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_r');
		}
		else if ( animEventName == 'Hiding' )
		{
			if ( animEventType == AET_DurationStart )
			{

				isHidingBreakAllowed = true;

			}
			else if ( animEventType == AET_DurationEnd )
			{
				isHidingBreakAllowed = false;
			}
		}
		else if ( animEventName == 'stomp' && animEventType == AET_Tick )
		{
			parent.PlayEffect ('fx_attack01');
		}
		else if ( animEventName == 'despawn' && animEventType == AET_Tick )
		{
			Despawn();
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}

	}
	
	function Despawn()
	{
		theGame.CreateEntity( templ, parent.GetWorldPosition(), parent.GetWorldRotation() );
	}
	
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\rotfiend";
	}
			
	event OnBeingHit( out hitParams : HitParams )
	{
		if(theGame.GetDifficultyLevel() <= 0)
		{	
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

		if ( parent.isHiding ) return false;
		if( parent.IsAlive() )
		{

			if(parent.IsStrongAttack(hitParams.attackType))
			{
				if(CanPlayDamageAnim())
				{
					HitStrongDrowner();
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
					HitFastDrowner();
				}
				else
				{
					parent.PlayBloodOnHit();
					theSound.PlaySoundOnActor(parent, 'head', "combat/weapons/hits/sword_hit");
				}
			}
			
		}
	}
	
	event OnAardHitReaction( CWitcherSignAard : CWitcherSignAard )
	{
		if(parent.AardKnockdownChance())
		{
			if(!parent.ApplyCriticalEffect(CET_Stun, NULL, 0, true) && !parent.ApplyCriticalEffect(CET_Knockdown, NULL, 0, true))
			{
				if(CanPlayDamageAnim())
					AardReactionDrowner();
			}
		}
		else
		{
			if(CanPlayDamageAnim())
				AardReactionDrowner();
		}
		
	}
	entry function AardReactionDrowner()
	{
		SetCanPlayDamageAnim(false, 2.0);
		parent.SetBlockingHit(false);
		parent.SetBlock(false);
		parent.CantBlockCooldown(3.0);
		parent.ActionCancelAll();
		parent.SetRotationTarget( parent.GetTarget() );
		parent.GetBehTreeMachine().Stop();	
		HitEvent(BCH_AardHit1);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('AardEnd');
		SetCanPlayDamageAnim(true, 0.0);
		parent.GetBehTreeMachine().Restart();
	}	
	entry function HitFastDrowner()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
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
	entry function HitStrongDrowner()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
		
	timer function RotfiendTimer( timeDelta : float )
	{
		if ( parent.retryRegenerationTimer > 0 )
		{
			parent.retryRegenerationTimer -= timeDelta;
		}
	}
};
