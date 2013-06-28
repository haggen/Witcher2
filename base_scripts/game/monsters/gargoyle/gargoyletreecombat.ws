/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

state TreeCombatGargoyle in CGargoyle extends TreeCombatMonster
{		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	var weakenedLevels : array<int>;
	var weakenedCounter : int;
	//var bombEntity : CBomb;
	var counterTime : EngineTime;
	var chargeAttackTime : EngineTime;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Teleportation
	var petardEntity : CAreaOfEffect;
	var petardPosition : Vector;
	
	var hitCounter : int;
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		super.OnEnterState();

		parent.DrawWeaponInstant(parent.GetInventory().GetFirstLethalWeaponId());	
		
		if( parent.CreateCombatEventsProxy( CECT_Gargoyle ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();
			//Gargoyle Attacks
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack4);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack5);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack6);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack7);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack8);
			
			//Gargoyle hit events
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);

			
			combatEvents.hitParryEnums.PushBack(BCH_Parry1);
			combatEvents.hitParryEnums.PushBack(BCH_Parry2);
			
			//CombatIdle events
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			combatEvents.idleEnums.PushBack(BCI_Idle3);
			
			//Combat charge
			combatEvents.chargeEnums.PushBack(BCA_Charge1);

		}
		
		parent.SetCombatSlotOffset(1.5);
		
		parent.AddTimer( 'GargoyleTimer', 1.0f, true );
	}
	
	event OnLeaveState()
	{
		parent.RemoveTimer( 'GargoyleTimer' );
		super.OnLeaveState();
		parent.ClearAttackTarget();
	}
	
	entry function TreeCombatGargoyle( params : SCombatParams )
	{
		LoadTree( params );
	}
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\gargoyle";
	}
		

	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3')
		{						
			Attack( animEventName );			
		}
		else if( animEventName == 'Charging' )
		{
			if( theGame.GetEngineTime() - chargeAttackTime > 2.0 )
			{
				if( Attack( 'Attack_t4' ) )
				{
					chargeAttackTime = theGame.GetEngineTime();
				}
			}
		}
		else if ( animEventName == 'trail_l' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_l');
		}
		else if ( animEventName == 'trail_r' && animEventType == AET_Tick)
		{
			parent.PlayEffect('trail_r');
		}
		else if ( animEventName == 'ground_hit' && animEventType == AET_Tick )
		{
			parent.PlayEffect ('fx_attack01');
			if(VecDistance(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 3.0)
			{
				parent.SetAttackTarget(thePlayer);
				Attack('Attack_t3');
			}
			if(VecDistance(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 15.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 0.1);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
		}	
	}
	
	event OnBeingHit( out hitParams : HitParams )
	{
		if(theGame.GetDifficultyLevel() <= 0)
		{	
			return true;
		}
		if( !parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ) )			
		{
			//hitParams.outDamageMultiplier = 4.0;
			return true;
		}
		else
		{
			if(2 + Rand(3) < hitCounter && !hitParams.rangedAttack)
			{
				hitCounter = 0;
				hitParams.attackReflected = true;
				hitParams.attacker.PlaySparksOnHit(hitParams.attacker, hitParams);
				HitParryGargoyle();
				return false;
			}
			else
			{
				hitCounter += 1;
			}
		}
		return true;
	}
	function ShouldPlayDamageFx() : bool
	{
		var maxVitality : float;
		maxVitality = parent.GetCharacterStats().GetFinalAttribute('vitality');
		if(parent.GetHealth() < 0.75*maxVitality && !parent.isPlayingDamageFX)
		{
			parent.isPlayingDamageFX = true;
			return true;
		}
		else
		{
			return false;
		}	
	}
	// Hit event
	event OnHit( hitParams : HitParams )
	{
		if( parent.IsAlive() )
		{
			if(parent.IsStrongAttack(hitParams.attackType))
			{
				HitStrongGargoyle();
			}
			else
			{
				HitFastGargoyle();
			}
			if(ShouldPlayDamageFx())
			{
				parent.PlayEffect('damage_fx1');
			}
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
	
	event OnAardHitReaction( CWitcherSignAard : CWitcherSignAard )
	{
		if(!parent.ApplyCriticalEffect(CET_Stun, NULL, 0, true))
			AardReactionGargoyle();
	}
	entry function AardReactionGargoyle()
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
			parent.GetBehTreeMachine().Restart();
		
	}	
	entry function HitFastGargoyle()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	entry function HitParryGargoyle()
	{
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget(parent.GetTarget());
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitParryEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	entry function HitStrongGargoyle()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
};
