/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** NPC Combat
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// CombatDraug state
/////////////////////////////////////////////
state TreeCombatDraug in CDraugBoss extends TreeCombatStandard
{		
	var weakenedLevels : array<int>;
	var weakenedCounter : int;
	var superblockLevels : array<int>;
	var superblockCounter, parryCounter : int;
	var hitParams  : HitParams;
	var counterTime : EngineTime;
	var aardHitCounter : int;
	var chargeAttackTime : EngineTime;
	
	default parryCounter = 0;
	default holsterOnExit = false;
	
	event OnEnterState()
	{
		var weaponId : SItemUniqueId;
		var combatEvents : W2CombatEvents;
		var i : int;
		parent.AddTimer('KeepPlayerCombat', 1.0, true);
		super.OnEnterState();				
		
		
		parent.SetWeakened( false );

		if(parent.CreateCombatEventsProxy( CECT_Draug ))
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();	
			
			//Hit
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);

			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
			
			combatEvents.hitParryEnums.PushBack(BCH_Parry1);
			combatEvents.hitParryEnums.PushBack(BCH_Parry2);
			combatEvents.hitParryEnums.PushBack(BCH_Parry3);
			combatEvents.hitParryEnums.PushBack(BCH_Parry4);
			
			//Attack			
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
			
			combatEvents.chargeEnums.PushBack(BCA_Charge1);
			combatEvents.chargeEnums.PushBack(BCA_Charge2);
			
			combatEvents.specialAttackEnums1.PushBack(BCA_Special1);
			
			//Throw
			combatEvents.throwEnums.PushBack(BCA_Throw1);
			//Idle
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
		}
	}

	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.RemoveTimer('BlockRelease');
		parent.SetBlockingHit(false);
		// release a ticket
		thePlayer.GetTicketPool( TPT_Attack ).ReleaseTicket( parent );
		if(!parent.IsAlive())
		{
			parent.RemoveTimer('KeepPlayerCombat');
		}
	}
	
	// Attack has been blocked
	event OnAttackBlocked( hitParams : HitParams )
	{
		//AttackBlockedDraug();
		HitFastDraug();
	}
	
	entry function AttackBlockedDraug()
	{
		var hit : W2BehaviorCombatHit;
		parent.GetBehTreeMachine().Stop();
		hit = GetHitLightEnum();
		HitEvent(hit);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function TreeCombatDraugSword( params : SCombatParams )	
	{
		var draugSword : SItemUniqueId;
		draugSword = parent.GetInventory().GetItemByCategory( 'opponent_weapon', false );
		if(draugSword == GetInvalidUniqueId())
		{
			Log("No draug sword!");
			draugSword = parent.GetInventory().GetFirstWeaponId();
		}
		parent.DrawWeaponInstant( draugSword );
		combatParams = params;
		parent.GetBehTreeMachine().Stop();	
		ExitWork();
		RequestTicketIfNeeded( params );
		LoadTree( params );
	}
	
	private function GetDefaultTreeAlias() : string
	{	
		return "behtree\draug";
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3' || animEventName == 'Attack_boss_t1' )
		{						
			Attack( animEventName, true, true );
		}
		else if( animEventType == AET_Tick && animEventName == 'TornadoStart' )
		{
			parent.TornadoStart( RandRangeF(10, 20) );
		}
		else if( animEventType == AET_Tick && animEventName == 'TornadoEffect' )
		{
			parent.PlayEffect('tornado');
		}
		else if( animEventType == AET_Tick && animEventName == 'stomp_l' )
		{
			if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 100.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
			else if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 10000.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
			parent.PlayEffect('fx_steps_left');
		}
		else if( animEventType == AET_Tick && animEventName == 'stomp_r' )
		{
			if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 100.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 1.0);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
			else if(VecDistanceSquared(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < 10000.0)
			{
				theCamera.SetBehaviorVariable('cameraShakeStrength', 0.5);
				theCamera.RaiseEvent('Camera_ShakeHit');
			}
			parent.PlayEffect('fx_steps_right');
		}
		else if( animEventType == AET_Tick && animEventName == 'CoverStart' )
		{
			if( Rand(2) == 0 )
			{	
				parent.PlayLine(26823, true);
				parent.DraugShootArrows();
			}
			else
			{
				parent.PlayLine(26819, true);
				parent.DraugShootFireBall();
			}
		}
		/*else if( animEventType == AET_DurationStart && animEventName == 'Charge' )
		{
			parent.AddTimer( 'UpdateCharge', 0.2, true );
		}
		else if( animEventType == AET_DurationEnd && animEventName == 'Charge' )
		{
			parent.RemoveTimer( 'UpdateCharge' );
		}*/
		else if( animEventName == 'Charge' )
		{
			if( theGame.GetEngineTime() - chargeAttackTime > 2.0 )
			{
				if( Attack( 'Attack_boss_t1' ) )
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
	
	timer function UpdateCharge( time : float )
	{
		if( parent.PlayerInRange( "CLOSE_ATTACK" ) )
		{
			thePlayer.Hit( parent, 'Attack_boss_t1', true );
		}
	}
	
	function GetParryAttackEnum() : W2BehaviorCombatAttack
	{
		switch( parryCounter )
		{
			case 0:
			{
				parryCounter += 1;
				return BCA_CounterParry1;
			}
			case 1:
			{
				parryCounter += 1;
				return BCA_CounterParry2;
			}
			case 2:
			{
				parryCounter += 1;
				return BCA_CounterParry3;
			}
			default:
			{
				parryCounter = 0;
				return BCA_CounterParry4;
			}
		}
	}
	
	entry function DraugParryAttack()
	{
		var parryAttack : W2BehaviorCombatAttack;
		
		parent.GetBehTreeMachine().Stop();
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
			DraugDamage(hitParams);
		}
	}
	
	function ParryChanceTest() : bool
	{
		return false;
	}
	
	entry function DraugBlock()
	{
		var blockEnum : W2BehaviorCombatHit;
		parent.GetBehTreeMachine().Stop();
		blockEnum = GetHitParryEnum();
		HitEvent(blockEnum);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	event OnBeingHitPosition(out hitParams : HitParams)
	{
		return OnBeingHit(hitParams);
	}
	event OnBeingHit( out hitParams : HitParams )
	{
		var isnlockinghit : bool = false;
		var rand : int;
		rand = Rand(3);
		
		if(parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ))
		{
			if(parent.CheckCanBlock())
			{
				//Do not break action if fast attack
				if( parent.IsStrongAttack(hitParams.attackType) )
				{
					if(rand >= 1)
					{
						DraugParryAttack();
					}
					else
					{
						DraugBlock();
					}
				}
				
				if(!hitParams.rangedAttack)
				{
					hitParams.attackReflected = true;
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
		//AxiiReactionSield(success);
		//We never succeed an Axii on Draug.
	}
		
	event OnYrdenHitReaction( yrden : CWitcherSignYrden)
	{
		YrdenReactionDraug(yrden);
	}
	
	entry function YrdenReactionDraug(yrden : CWitcherSignYrden)
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
		DraugAardReactionHit();
	}
	
	entry function DraugAardReactionHit()
	{
		parent.SetBlockingHit(false);
		parent.SetBlock(false);
		parent.CantBlockCooldown(3.0);
		parent.ActionCancelAll();
		parent.GetBehTreeMachine().Stop();
		if( aardHitCounter%2 == 0 )
			HitEvent(BCH_AardHit1);
		else
			HitEvent(BCH_AardHit2);
		aardHitCounter += 1;
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
	
	function DraugDamage( hitParams : HitParams )
	{
		if( parent.IsStrongAttack(hitParams.attackType) )
		{
			HitStrongDraug();
		}
		else
		{
			//Fast attacks do not break Draugs action
			//HitFastDraug();
		}	
	}
	
	event OnCriticalEffectStart( effectType : ECriticalEffectType, duration : float )
	{
		return true;
	}
	
	event OnCriticalEffectStop( effectType : ECriticalEffectType )
	{
		return true;
	}
	
	entry function HitFastDraug()
	{
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	
	entry function HitStrongDraug()
	{
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		parent.GetBehTreeMachine().Restart();
	}
	
}
state DraugTornado in CDraugBoss
{
	var tornadoTime : EngineTime;
	var tornadoDuration : float;
	
	function CheckTornadoActive() : bool
	{
		if(theGame.GetEngineTime() - tornadoTime < tornadoDuration)
		{
			return true;
		}
		return false;
	}
	
	entry function TornadoStart(time : float)
	{
		tornadoDuration = time;
		tornadoTime = theGame.GetEngineTime();
		parent.SetImmortalityModeRuntime(AIM_Invulnerable, time);
		parent.ApplyAppearance("draug_tornado");
		parent.StopEffect('draug_fire');
		parent.PlayEffect('tornado');
		theCamera.SetCameraPermamentShake( CShakeState_Tower, 1.0 );
		parent.WaitForBehaviorNodeDeactivation('AttackEnd');
		parent.AddTimer( 'UpdateTornado', 0.2, true );
		TornadoLoop();
	}
	
	function DamagePlayerIfNear()
	{
		if(VecDistance(thePlayer.GetWorldPosition(), parent.GetWorldPosition()) < parent.tornadoRadius)
		{
			thePlayer.HitPosition(parent.GetWorldPosition(), 'Attack_boss_t1', parent.tornadoDamage, true);
			TornadoEnd();
		}
	}
	
	timer function UpdateTornado( time : float )
	{
		DamagePlayerIfNear();
	}
	
	entry function TornadoLoop()
	{
		var duration : float;
		
		while( CheckTornadoActive() )
		{
			Sleep(0.5);
			thePlayer.KeepCombatMode();
			duration = VecDistanceSquared2D(thePlayer.GetWorldPosition(), parent.GetWorldPosition())/100.0;
			parent.ActionSlideTo(thePlayer.GetWorldPosition(), duration);
		}
		TornadoEnd();
	}
	
	entry function TornadoEnd()
	{
		var params : SCombatParams;
		
		parent.RemoveTimer('UpdateTornado');
		while( !parent.RaiseEvent('TornadoStop') )
		{
			Sleep(0.2);
		}
		parent.StopEffect('tornado');
		theCamera.SetCameraPermamentShake(CShakeState_Invalid, 0.0);
		parent.WaitForBehaviorNodeDeactivation('TornadoEnded');
		parent.ApplyAppearance("draug");
		parent.PlayEffect('draug_fire');
		parent.SetImmortalityModePersistent(AIM_None);
		parent.TreeCombatDraugSword(params);
	}
}

state DraugShootProjectiles in CDraugBoss extends TreeCombatStandard
{
	var projectileShooter : CDraugProjectilesShooter;
	
	event OnEnterState()
	{
		parent.isCovering = true;
	}
	
	event OnLeaveState()
	{
		parent.isCovering = false;
		if(!parent.IsAlive())
		{
			parent.RemoveTimer('KeepPlayerCombat');
		}
	}
	
	entry function DraugShootArrows()
	{
		projectileShooter = (CDraugProjectilesShooter)theGame.GetEntityByTag('draug_projectileShooter');
		projectileShooter.SetShootingRocks(true);
		projectileShooter.DraugRocks(10);
		Update();
	}
	
	entry function DraugShootFireBall()
	{
		projectileShooter = (CDraugProjectilesShooter)theGame.GetEntityByTag('draug_projectileShooter');
		projectileShooter.DraugArrows();
		Update();
	}
	
	entry function Update()
	{
		var params : SCombatParams;
		
		while( projectileShooter.ShootingInProgress() )
		{
			parent.RotateToNode( thePlayer, 0.3 );
			thePlayer.KeepCombatMode();
			if( VecDistanceSquared(parent.GetWorldPosition(), thePlayer.GetWorldPosition())<36.0 )
			{
				parent.RaiseEvent( 'CoverAttack' );
			}
			Sleep(0.2);
		}
		
		while( !parent.RaiseEvent( 'CoverStop' ) )
		{
			Sleep(0.2);
		}
		parent.WaitForBehaviorNodeDeactivation( 'CoverEnded' );
		
		parent.TreeCombatDraugSword(params);
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' )
		{
			parent.SetAttackTarget(thePlayer);
			Attack('Attack_t4', true, true);
		}
	}
}
