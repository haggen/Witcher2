/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2009
/***********************************************************************/

state TreeCombatRotfiend in CRotfiend extends TreeCombatMonster
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
		
		//parent.AddTimer( 'RotfiendTimer', 1.0f, true );
		
		parent.SetWeakened( false );

		weakenedLevels.Clear();
		weakenedLevels.PushBack(30);
		weakenedLevels.PushBack(70);
		
		weakenedCounter = -1;
		for( i=0; i<weakenedLevels.Size(); i+=1 )
		{			
			if( parent.GetHealth() > weakenedLevels[i] )
			{
				weakenedCounter = i;
			}
		}
	
		// Restore (for sure) params if Roftiend was taken from resting entry without cleanup
		parent.SetImmortalityModeRuntime( AIM_None );
		parent.SetAttackableByPlayerRuntime( true );
		parent.SetBlockingHit( false );
	}
	
	event OnLeaveState()
	{
		parent.noragdollDeath = true;
		parent.RemoveTimer( 'RotfiendTimer' );
		
		// Restore (for sure) params if Roftiend was taken from resting entry without cleanup
		parent.SetImmortalityModeRuntime( AIM_None );
		parent.SetAttackableByPlayerRuntime( true );
		parent.SetBlockingHit( false );

		super.OnLeaveState();
		parent.ClearAttackTarget();
	}
	

	
	entry function TreeCombatRotfiend( params : SCombatParams )
	{

		
		if ( parent.isHidden )
		{
			LoadTree( params );
		}
		else
		{
			LoadTree( params );
		}
		
		templ = (CEntityTemplate)LoadResource("gameplay\despawn_rotfiend");
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
		/*if( parent.isHiding )
		{
			return false;
		}*/
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
		
		//HideCheck();
		//if ( parent.isHiding ) return false;
		if( parent.IsAlive() )
		{

			if(parent.IsStrongAttack(hitParams.attackType))
			{
				if(CanPlayDamageAnim())
				{
					HitStrongRotfiend();
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
					HitFastRotfiend();
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
					AardReactionRotfiend();
			}
		}
		else
		{
			if(CanPlayDamageAnim())
				AardReactionRotfiend();
		}
		
	}
	entry function AardReactionRotfiend()
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
	entry function HitFastRotfiend()
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
	entry function HitStrongRotfiend()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
		
	/*timer function RotfiendTimer( timeDelta : float )
	{
		if ( parent.retryRegenerationTimer > 0 )
		{
			parent.retryRegenerationTimer -= timeDelta;
		}
		
		HideCheck();
	}
	
	// cheks if monster should hide and regenerate
	private function HideCheck()
	{
		var regenerationDraw : int;

		if ( parent.health < parent.lowHealthValue && !parent.isHiding && parent.retryRegenerationTimer <= 0 )
		{
			regenerationDraw = Rand( 100 );
			if ( regenerationDraw < parent.regenerationChance )
			{
				parent.isHiding = true;
				//HideMonster();
				//ExplodeMonster();
			}
		}
	}
	
	entry function HideMonster()
	{
		var regenerationTime : float;
		//var regenerationHealthValue : float;
		var buriedTime : float = 0;
		//var teleportPos : Vector;
		//var teleportRot : EulerAngles = EulerAngles(0,0,0);
		
		parent.DebugDumpEntryFunctionCalls( true ); // tempshit
		
		parent.SetCleanupFunction( 'HideMonsterCleanup' );
	
		parent.GetBehTreeMachine().Stop();
		//parent.GetBehTreeMachine().EnableDebugDumpRestart(true);
		parent.ActionCancelAll();
		parent.SetImmortalityModeRuntime( AIM_Invulnerable );
		parent.SetAttackableByPlayerRuntime( false, parent.maxRegenerationTime );
		parent.SetBlockingHit( true, 5);

		if( AttackEvent(BCA_Special2) )
		{
			Sleep(0.1);
			parent.WaitForBehaviorNodeDeactivation( 'AttackEnd' );
		}

		// Teleport
		//teleportPos = GetTeleportPosition();
		//teleportRot.Yaw = GetTeleportRotation( teleportPos );
		//parent.TeleportWithRotation( teleportPos, teleportRot );
		parent.Teleport( GetTeleportPosition() );
		
		// Sleep and regenerate
		regenerationTime = RandRangeF( parent.minRegenerationTime, parent.maxRegenerationTime );
		while ( buriedTime < regenerationTime )
		{
			Sleep( 0.5 );
			buriedTime += 0.5;
			Regenerate( 0.5 );	

			if ( parent.unburyRequest )
			{
				parent.unburyRequest = false;
				break;
			}
		}
		
		RaiseAppearAndWait();
		HideMonsterReset();
	}
	
	private latent function RaiseAppearAndWait()
	{
		var templ : CEntityTemplate;
		
		templ = (CEntityTemplate)LoadResource("gameplay\spawn_rotfiend");
		theGame.CreateEntity( templ, parent.GetWorldPosition(), parent.GetWorldRotation() );
		Sleep(0.5);
		if( AttackEvent(BCA_Special3) )
		{
			Sleep(0.1);
			parent.WaitForBehaviorNodeDeactivation('AttackEnd');
			parent.GetBehTreeMachine().Restart();
		}
	}
	
	private cleanup function HideMonsterCleanup()
	{
		if( AttackEvent(BCA_Special3) )
		{
			//parent.GetBehTreeMachine().Restart();
		}
		HideMonsterReset();
	}
	
	private function HideMonsterReset()
	{
		parent.isHiding = false;
		parent.unburyRequest = false;
		parent.SetImmortalityModeRuntime( AIM_None );
		parent.SetAttackableByPlayerRuntime( true );
		parent.SetBlockingHit( false );
		
		// Reset regeneration timer
		parent.retryRegenerationTimer = parent.retryRegenerationTime;
	}

	private function GetTeleportPosition() : Vector
	{
		var result : Vector;
		var x      : float;
		var y      : float;
		
		// Version without PE checking
		//result = parent.GetWorldPosition();
		//x = RandRangeF( 1.0, parent.hiddenTeleportRange ) - (parent.hiddenTeleportRange / 2.0);
		//y = RandRangeF( 1.0, parent.hiddenTeleportRange ) - (parent.hiddenTeleportRange / 2.0);
		//result.X += x;
		//result.Y += y;
		
		// With PE checking
		result = parent.GetWorldPosition();
		GetRandomReachablePoint( parent.GetWorldPosition(), 0, parent.hiddenTeleportRange, result ); 
		
		// keep teleport place in range (within encounter)
		if ( !parent.GetArea().TestPointOverlap( result ) )
		{
			result = parent.GetWorldPosition();
		}
		
		return result;
	}
	
	private function GetTeleportRotation( newPos : Vector ) : float
	{
		var dir : Vector = thePlayer.GetWorldPosition() - parent.GetWorldPosition();
		return VecHeading( dir );
	}
	
	private function Regenerate( timeSpentUnderground : float )
	{
		var regenerationHealthValue : float;

		regenerationHealthValue = (parent.regenerationFactor * parent.initialHealth) * (timeSpentUnderground / parent.maxRegenerationTime);
		if ( (parent.health + regenerationHealthValue) > parent.initialHealth )
		{
			parent.health = parent.initialHealth; // full health restoration
		}
		else
		{
			parent.health += regenerationHealthValue;
		}
	}*/

	entry function ExplodeMonster()
	{
		parent.GetBehTreeMachine().Stop();
		parent.ActionCancelAll();
		parent.SetImmortalityModeRuntime( AIM_Invulnerable );
		parent.SetAttackableByPlayerRuntime( false );
		parent.SetBlockingHit( true, 30 );

		if( parent.RaiseForceEvent( 'Explode' ) )
		{
			parent.WaitForBehaviorNodeActivation( 'ExplodeEnd' );
		}

		parent.GetArbitrator().AddGoalDespawn( true );
	}
};
