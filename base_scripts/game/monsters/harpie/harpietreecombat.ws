/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

state TreeCombatStandard in CHarpie extends TreeCombatMonster
{			
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		super.OnEnterState();

		parent.DrawWeaponInstant(parent.GetInventory().GetFirstLethalWeaponId());	
		
		if( parent.CreateCombatEventsProxy( CECT_Harpie ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();
			//Attacks
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack6);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack7);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack8);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack9);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack10);
			combatEvents.attackEnums.PushBack(BCA_MeleeSequence1);
			//Charge
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			combatEvents.chargeEnums.PushBack(BCA_Special1);
			
			//Hits
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast3);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
			
			
			//Dodge
			combatEvents.dodgeBackEnums.PushBack(BCH_DodgeBack1);
			combatEvents.dodgeBackEnums.PushBack(BCH_DodgeBack2);
			//combatEvents.dodgeRightEnums.PushBack(BCH_DodgeRight1);
			//combatEvents.dodgeLeftEnums.PushBack(BCH_DodgeLeft1);
			
			//Combat Idle
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			combatEvents.idleEnums.PushBack(BCI_Idle3);			
		}			
			
		parent.SetCombatSlotOffset(1.0);
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.ClearAttackTarget();
	}
	
	entry function TreeCombatHarpie( params : SCombatParams )
	{
		LoadTree( params );
		if(parent.IsGrounded())
		{
			parent.GetBehTreeMachine().Stop();
			parent.RaiseForceEvent('ToFly');
			parent.WaitForBehaviorNodeDeactivation('ToFly', 5.0);
			parent.SetGrounded(false);
			parent.ActivateBehavior( 'npc_exploration' );
			parent.SetSpawnAnim(SA_Idle);
			parent.GetBehTreeMachine().Restart();
		}
	}
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\harpie";
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3')
		{						
			Attack( animEventName );			
		}
		else if ( animEventName == 'trail_l' && animEventType == AET_Tick)
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
			
	event OnBeingHit( out hitParams : HitParams )
	{
		parent.ClearAttackTarget();
		return !parent.IsBlockingHit();
	}
	
	/*event OnAttackTell( hitParams : HitParams )
	{
		if( hitParams.attackType == 'StrongSwing' && Rand(4) > 0)
		{
			parent.GetBehTreeMachine().Stop();
			parent.ActionRotateToAsync( hitParams.hitPosition );
			if( parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ) )
			{
				parent.SetBlockingHit( true, 1.5 );
				TreeDodgeStart();					
			}
		}
	}*/
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{		

		if( parent.IsAlive() )
		{
			if(parent.IsStrongAttack(hitParams.attackType))
			{
				if(CanPlayDamageAnim())
				{
					HitStrongHarpy();
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
					HitFastHarpy();
				}
				else
				{
					parent.PlayBloodOnHit();
					theSound.PlaySoundOnActor(parent, 'head', "combat/weapons/hits/sword_hit");
				}
			}
		}
	}
	
	event OnAardHitReaction( sign : CWitcherSignAard )
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionRotateToAsync( thePlayer.GetWorldPosition() );
		if(parent.AardKnockdownChance())
		{
			if( !parent.ApplyCriticalEffect(CET_Knockdown, NULL, 0, true ) )
			{
				// No effect go directly to grounded
				if(CanPlayDamageAnim())
					TreeGroundedStart();
			}
		}
		else if(CanPlayDamageAnim())
		{
			TreeGroundedStart();
		}
	}
	
	function SetGroundedTimer()
	{
		parent.AddTimer( 'TreeGrounded', 20.0, false );
	}
	
	private entry function TreeGroundedStart()
	{
		if(parent.IsGrounded())
		{
			if(!parent.ApplyCriticalEffect(CET_Stun, NULL, 0 , true))
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
				parent.WaitForBehaviorNodeDeactivation('AardEnd');
				SetCanPlayDamageAnim(true, 0.0);
				parent.GetBehTreeMachine().Restart();
			}
		}
		else
		{
			parent.SetGrounded(true);
			SetCanPlayDamageAnim(false, 2.0);
			HitEvent(BCH_AardHit1);
			Sleep(0.1);
			parent.WaitForBehaviorNodeDeactivation('HitEnd');
			parent.ActivateAndSyncBehavior( 'grounded_harpie' );
			SetGroundedTimer(); 
			TreeDelayedCombatRestart();
		}
	}
	
	timer function TreeGrounded( timeDelta : float )
	{
		TreeGroundedStop();
	}
	
	private entry function TreeGroundedStop()
	{
		parent.GetBehTreeMachine().Stop();
		parent.RaiseForceEvent('ToFly');
		parent.WaitForBehaviorNodeDeactivation('ToFly', 5.0);
		parent.SetGrounded(false);
		parent.SetSpawnAnim(SA_Idle);
		parent.ActivateAndSyncBehavior( 'npc_exploration' );
		parent.GetBehTreeMachine().Restart();
	}
	entry function HitFastHarpy()
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
	entry function HitStrongHarpy()
	{
		var harpyHit : W2BehaviorCombatHit;
		var harpyInt : int;
		
		harpyHit = GetHitHeavyEnum();
		harpyInt = (int)harpyHit;
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		if(harpyHit == BCH_None)
		{

			Log("BCH_None!");
		}
		HitEvent(harpyHit);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
}
