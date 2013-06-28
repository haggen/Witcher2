/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

state TreeCombatMage in CNewNPC extends TreeCombatStandard
{		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	var aoeSpell : SItemUniqueId;
	var aoeSpellEnt, magicTrapEnt : CMagicAOESpell;
	var magicTrap, magicBolt, magicFireball : SItemUniqueId;
	var canUseMagicTrap, canUseMagicBolt, canUseFireball : bool;
	var staffEffect : name;
	var weapon : SItemUniqueId;
	var shieldUsedTime : EngineTime;
	var shieldDuration : float;
	var hitCounter : int;
	var isTeleporting : bool;
	
	
	default shieldDuration = 7.0;
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function HasActiveShield() : bool
	{
		if(theGame.GetEngineTime() <= shieldUsedTime + shieldDuration)
		{
			return true;
		}
		else
		{
			parent.RemoveTimer('TimerShieldOff');
			parent.SetBlockingHit(false, 0.0);
			parent.StopEffect('electric_shield_fx');
			return false;
		}
	}
	timer function TimerShieldOff(td : float)
	{
		parent.SetBlockingHit(false, 0.0);
		parent.StopEffect('electric_shield_fx');
	}
	function ShieldOn()
	{
		parent.SetBlockingHit(true, shieldDuration);
		shieldUsedTime = theGame.GetEngineTime();
		parent.AddTimer('TimerShieldOff', shieldDuration, false);
	}
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		parent.IssueRequiredItems('None', 'opponent_weapon');
		super.OnEnterState();
		magicTrap = parent.GetInventory().GetItemByCategory('trap', false);
		magicFireball = parent.GetInventory().GetItemByCategory('projectile', false);
		aoeSpell = parent.GetInventory().GetItemByCategory('magic', false);
		magicBolt = parent.GetInventory().GetItemByCategory('magic_bolts', false);
		if(magicTrap != GetInvalidUniqueId())
		{
			canUseMagicTrap = true;
		}
		else
		{
			canUseMagicTrap = false;
		}
		if(magicBolt != GetInvalidUniqueId())
		{
			canUseMagicBolt = true;
		}
		else
		{
			canUseMagicBolt = false;
		}
		if(magicFireball != GetInvalidUniqueId())
		{
			canUseFireball = true;
		}
		else
		{
			canUseFireball = false;
		}
		if(parent.GetCharacterStats().HasAbility('MageTypeLightning'))
		{
			staffEffect = 'lightning_fx';
		}
		else if(parent.GetCharacterStats().HasAbility('MageTypeFire'))
		{
			staffEffect = 'fire_fx';
		}
		else if(parent.GetCharacterStats().HasAbility('MageTypeDethmold'))
		{
			staffEffect = 'detmold_lightning_fx';
		}
		else
		{
			staffEffect = 'fire_fx';
		}
		

		weapon = parent.GetInventory().GetItemByCategory('opponent_weapon', true);
		if(weapon != GetInvalidUniqueId())
		{
			parent.GetInventory().PlayItemEffect(weapon, staffEffect);
		}
		
				
		if( parent.CreateCombatEventsProxy( CECT_NPCMage ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();	
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);

			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
			
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast3);
			
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
		}
		
		parent.SetCombatSlotOffset(1.3);
		//parent.GetBehTreeMachine().EnableDebugDumpRestart(true);
		
	}
	
	event OnPlayerThrowBomb()
	{
		if(!theGame.tutorialenabled)
		{
			if(!parent.HasMagicShield())
			{
				if(Rand(3) > 0)
				{
					if( !parent.HasUnlimitedMagicShield() )
						{
							SetCanPlayDamageAnim(false, 1.5);
							MagicShield();
						}
				}
			}
		}
	}
	
	event OnLeaveState()
	{
		
		var  weapon : SItemUniqueId;
		weapon = parent.GetInventory().GetItemByCategory('opponent_weapon', true);
		if(weapon == GetInvalidUniqueId())
			weapon = parent.GetInventory().GetItemByCategory('steelsword', true);
		parent.GetInventory().StopItemEffect(weapon, 'fire_fx');
		parent.GetInventory().StopItemEffect(weapon, 'lightning_fx');
		parent.GetInventory().StopItemEffect(weapon, 'detmold_lightning_fx');
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
	
	entry function TreeCombatMage( params : SCombatParams )
	{
		parent.LockEntryFunction(true);
		SetCanPlayDamageAnim(false, 6.0);
		LoadTree( params );
		ActivateCombatBehavior( params, 'npc_mage' );
		SetCanPlayDamageAnim(true, 0.0);
		parent.LockEntryFunction(false);
	}
	
	private function GetDefaultTreeAlias() : string
	{
		if(parent.HasTag('arena_wingman'))
		{
			return "behtree\arena_mage";
		}
		else
		{		
			return "behtree\combat_mage";
		}
	}
	
	// ----------------------------------------------------------------------
	// Events the mage experiences through
	// ----------------------------------------------------------------------
	event OnBeingHitPosition( out hitParams : HitParams)
	{
		if(parent.HasMagicShield())
		{
			parent.PlayEffect('electric_shield_hit');
			return false;
		}
		else
		{
			return OnBeingHit(hitParams);
		}
	}
	event OnBeingHit( out hitParams : HitParams )
	{
		// ??? PAKSAS TODO: dlaczego przed byciem uderzonym czyscimy cel ataku?
		parent.ClearAttackTarget();
		if(parent.HasMagicShield())
		{
			parent.PlayEffect('electric_shield_hit');
			if(!hitParams.rangedAttack)
			{
				hitParams.attackReflected = true;
			}
			return false;
		}
		else
		{
			if(1 + Rand(3) < hitCounter)
			{
				if(CanPlayDamageAnim())
				{
					if( !parent.HasUnlimitedMagicShield() )
					{
						hitCounter = 0;
						MagicShield();
						return false;
					}
				}
				else
				{	
					hitCounter += 1;
				}
			}
			else
			{
				hitCounter += 1;
			}
			
		}
		// process the hit only if we're not blocking the hit, nor when we're using a special
		// magical protective shield
		return !parent.IsBlockingHit();
	}
	
	event OnAttackTell( hitParams : HitParams )
	{
		// ??? kiedy to jest wolane
	}



	entry function MagePreTeleport()
	{
		SetCanPlayDamageAnim( false, 4.0 );
		isTeleporting = true;
	}
		
	entry function MagePostTeleport()
	{
		SetCanPlayDamageAnim( true, 0.0 );
		isTeleporting = false;
	}
	


	entry function MageHitFast()
	{
		parent.ActionCancelAll();
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 0.0;
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		//specialBlockTime = EngineTime();
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartMage();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	entry function MageHitStrong()
	{
		parent.ActionCancelAll();
		parent.GetBehTreeMachine().Stop();
		//specialBlockTime = theGame.GetEngineTime() + 0.0;
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitHeavyEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		//specialBlockTime = EngineTime();
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartMage();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	// Hit event
	event OnHit( hitParams : HitParams )
	{		
		if( parent.IsAlive() )
		{
			if(parent.IsStrongAttack(hitParams.attackType))
			{
				if(CanPlayDamageAnim())
				{
					MageHitStrong();
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
					MageHitFast();
				}
				else
				{
					parent.PlayBloodOnHit();
					theSound.PlaySoundOnActor(parent, 'head', "combat/weapons/hits/sword_hit");
				}
			}
			
		}
		
		virtual_parent.OnHitAdditional( hitParams );
	}
	
	event OnBeforeAttack()
	{
		if(!isTeleporting)
		{
			if( !parent.GetBehTreeMachine().IsStopped() )
			{
				parent.GetBehTreeMachine().Stop();
				parent.ActionCancelAll();
				TreeDelayedCombatRestart();
			}
		}
	}
	
	// --------------------------------------------------------------------
	// Attacking
	// --------------------------------------------------------------------	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && ( animEventName == 'Fireball' || animEventName == 'Magic_Attack_t1' ) )
		{						
			// this is a magic attack
			if(canUseMagicBolt && canUseFireball)
			{
				if(Rand(2) == 1)
				{
					MagicLightning(parent);
				}
				else
				{
					MagicAttack( animEventName );	
				}
			}
			else if(canUseMagicBolt && !canUseFireball)
			{
				MagicLightning(parent);
			}
			else if(!canUseMagicBolt && canUseFireball)
			{
				MagicAttack( animEventName );	
			}
					
		}
		else if( animEventType == AET_Tick && ( animEventName == 'FindTarget' ) )
		{						
			parent.GetLocalBlackboard().AddEntryVector('rangedTargetPos', parent.GetTarget().GetWorldPosition());
		}
		else if( animEventType == AET_Tick && ( animEventName == 'Attack' ) )
		{						
			parent.SetAttackTarget(parent.GetTarget());
			Attack('Attack_t4');
		}
		else if( animEventType == AET_Tick && ( animEventName == 'FireballCast' ) )
		{						
			parent.PlayEffect('fireball_cast_fx');		
		}
		else if( animEventType == AET_Tick && ( animEventName == 'MagicTrap' ) )
		{						
			MagicTrap(5 + Rand(6));	
		}
		/*else if( animEventType == AET_Tick && ( animEventName == 'MeleeSpell' ) )
		{						
			MagicMeleeAttack();
		}*/
		else if( animEventType == AET_Tick && ( animEventName == 'Lightning' ) )
		{						
			MagicLightning(parent);
		}
		else
		{	
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}	
	}
	entry function AardReaction()
	{
		SetCanPlayDamageAnim(false, 3.0);
		parent.GetBehTreeMachine().Stop();
		if(parent.IsRotatedTowardsPoint( thePlayer.GetWorldPosition(), 90 ) )
		{
			HitEvent(BCH_AardHit1);
		}
		else
		{
			HitEvent(BCH_AardHit2);
		}
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		SetCanPlayDamageAnim(true, 0.0);
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartMage();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}
	}
	event OnAxiiHitReaction()
	{
		if(CanPlayDamageAnim())
			AxiiReactionMage();
	}
	event OnAxiiHitResult(axii : CWitcherSignAxii, success : bool)
	{
			AxiiReactionMageResult(success);
	}
	entry function AxiiReactionMage()
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
	entry function AxiiReactionMageResult(success : bool)
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
			YrdenReactionMage(yrden);
	}
	entry function YrdenReactionMage(yrden : CWitcherSignYrden)
	{
		var immobileDuration : float;
		immobileDuration = yrden.GetImmobileTime();
		parent.GetBehTreeMachine().Stop();
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
					AardReaction();
			}
		}
		else
		{
			if(CanPlayDamageAnim())
				AardReaction();
		}
		
	}
	function MagicTrap(trapNum : int)
	{
		var trapSpawn : Vector;
		var i : int;
		var targetPos : Vector;
		targetPos = parent.GetTarget().GetWorldPosition();
		for(i = 0; i < trapNum; i += 1)
		{
			if(GetRandomReachablePoint(targetPos, 4.0, 12.0, trapSpawn))
			{
				magicTrapEnt = (CMagicAOESpell)parent.GetInventory().GetDeploymentItemEntity(magicTrap,trapSpawn, parent.GetWorldRotation());
				magicTrapEnt.Init(parent);
			}
		}
		//parent.GetInventory().GetDeploymentItemEntity(magicTrap, )
	}
	function MagicMeleeAttack()
	{
		aoeSpellEnt = (CMagicAOESpell)parent.GetInventory().GetDeploymentItemEntity(aoeSpell,parent.GetWorldPosition(), parent.GetWorldRotation());
		aoeSpellEnt.Init(parent);
	}
	entry function MagicShield()
	{
		AttackEvent(BCA_Special1);
		parent.SetMagicShield(10.0, 'electric_shield_fx');
		//ShieldOn();
		Sleep(0.5);
		parent.GetBehTreeMachine().Stop();
		SetCanPlayDamageAnim(false, 2.0);
		//parent.PlayEffect('electric_shield_fx');
		parent.WaitForBehaviorNodeDeactivation('AttackEnd');
		parent.GetBehTreeMachine().Restart();
	}
	function MagicLightning(owner : CNewNPC)
	{
		var component : CComponent;
		var target : CActor;
		var proj : CMagicBoltColider;
		var boneMtx	: Matrix;
		var node : CNode;
		var magicBolt : CMagicBolt;
		var hitEffectPosition, projSpawnPos : Vector;
		var damage : float;
		var item : SItemUniqueId;
		damage = CalculateWeatherDmgBonus() * RandRangeF(owner.GetCharacterStats().GetFinalAttribute('ranged_damage_min'), owner.GetCharacterStats().GetFinalAttribute('ranged_damage_max'));
		target = owner.GetTarget();
		component = target.GetComponent("fx point1");
		if(!component)
		{
			component = target.GetComponent("hit_point_fx");
		}
		if(component)
		{
			node = (CNode)component;
		}
		else
		{
			node = (CNode)target;
		}
		if(target.GetBoneIndex('pelvis') == -1)
		{
			hitEffectPosition = target.GetWorldPosition();
			hitEffectPosition.Z += 1.0;
		}
		else
		{
			boneMtx = target.GetBoneWorldMatrix('pelvis');
			hitEffectPosition = MatrixGetTranslation(boneMtx);
		}
		item = owner.GetInventory().GetItemByCategory('magic_bolts', false);
		
		magicBolt = (CMagicBolt)owner.GetInventory().GetDeploymentItemEntity(item, hitEffectPosition, owner.GetWorldRotation());
		projSpawnPos = owner.GetWorldPosition();
		projSpawnPos.Z += 1.5;
		proj = (CMagicBoltColider)theGame.CreateEntity(magicBolt.GetBoltColider(), projSpawnPos, owner.GetWorldRotation());
		proj.Init(owner);
		proj.Start(target, Vector(0,0,0), false);
		owner.PlayEffect( magicBolt.GetBoltFXName(), node );
		target.HitPosition(owner.GetWorldPosition(), 'Attack', damage, true, owner,false,true, true);
		target.PlayEffect(magicBolt.GetBoltActorHitFXName());
	}
	private function MagicAttack( animEventName : name ) : bool
	{
		// spawn a fireball 
		var inventory 				: CInventoryComponent 	= parent.GetInventory();
		var itemId 					: SItemUniqueId 		= inventory.GetItemByCategory('projectile', false);
		var itemHoldSlotName		: name 					= inventory.GetItemHoldSlot( itemId );
		var spell					: CMagicProjectile;
		var spawnPosition, targetPosition 			: Vector;
		var spawnRotation 			: EulerAngles;
		var ac 						: CAnimatedComponent	= parent.GetRootAnimatedComponent();
		var boneMtx					: Matrix;
		var ent 					: CEntity				= NULL;
		var zAdjust 				: float					= 1.3;
		var hitComponent			: CComponent;
		
		if ( !ac )
		{
			return false;
		}
			
		//hitComponent = thePlayer.GetComponent( "hit_point_fx" );
		
		//parent.PlayEffect( 'lightning_star_wars', hitComponent );
		
		boneMtx = ac.GetBoneMatrixWorldSpace( itemHoldSlotName );
		spawnPosition = parent.GetWorldPosition();//MatrixGetTranslation( boneMtx );
		spawnRotation = parent.GetWorldRotation();//MatrixGetRotation( boneMtx );
		spawnPosition.Z += zAdjust;
		ent = inventory.GetDeploymentItemEntity( itemId, spawnPosition, spawnRotation );
		spell = (CMagicProjectile)ent;
		spell.Init(parent);
		parent.GetLocalBlackboard().GetEntryVector('rangedTargetPos', targetPosition);
		targetPosition.Z += zAdjust;
		spell.Start(NULL, targetPosition, false, 5.0);
	}
	
	// --------------------------------------------------------------------
	// Hit events names management
	// --------------------------------------------------------------------	
	
	// Get proper behavior hit event name
	function GetHitEventName( hitPosition : Vector, attackType : name ) : name
	{
		// PAKSAS TODO: tutaj rozkminiamy nazwe hit'u jaka powinnismy odegrac, jak nas wiesiek trafi
		if(	attackType == 'FastAttack_t0' )
		{
			if( parent.IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				parent.ActionRotateToAsync( hitPosition );
				return GetHitEventName_t0();
			}
			else
			{
				return 'c_hit_back';
			}
		}
	
		if(	attackType == 'FastAttack_t1' )
		{
			if( parent.IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				parent.ActionRotateToAsync( hitPosition );
				return GetHitEventName_t0();
			}
			else
			{
				return 'c_hit_back';
			}
		}
		else if( attackType == 'FastAttack_t2' )
		{
			if( parent.IsRotatedTowardsPoint( hitPosition, 90 ) )
			{
				parent.ActionRotateToAsync( hitPosition );
				return GetHitEventName_t0();
			}
			else
			{
				return 'c_hit_back';
			}	
	    }	
		else if ( attackType == 'FastAttack_t3' )
		{
			if( parent.IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				parent.ActionRotateToAsync( hitPosition );
				return GetHitEventName_t0();
			}
			else
			{
				return 'c_hit_back';

			}		
		}
		if(	attackType == 'StrongAttack_t0' )
		{
			if( parent.IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				parent.ActionRotateToAsync( hitPosition );
				return GetHitEventName_t1();
			}
			else
			{
				return 'c_hit_back';

			}
		}
		if(	attackType == 'StrongAttack_t1' )
		{
			if( parent.IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				parent.ActionRotateToAsync( hitPosition );
				return GetHitEventName_t1();
			}
			else
			{
				return 'c_hit_back';

			}
		}
		else if( attackType == 'StrongAttack_t2' )
		{
			if( parent.IsRotatedTowardsPoint( hitPosition, 90 ) )
			{
				parent.ActionRotateToAsync( hitPosition );
				return GetHitEventName_t1();
			}
			else
			{
				return 'c_hit_back';
			}	
	    }	
		else if ( attackType == 'StrongAttack_t3' )
		{
			if( parent.IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				parent.ActionRotateToAsync( hitPosition );
				return GetHitEventName_t1();
			}
			else
			{
				return 'c_hit_back';

			}		
		}
		else if ( attackType == 'MagicAttack_t1' )
		{
			if( parent.IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				parent.ActionRotateToAsync( hitPosition );
				return GetHitEventName_t0();			}
			else
			{
				return 'c_hit_back';

			}		
		}
		
		else if( attackType == 'JumpAttack_t1' )
		{
			if( parent.IsRotatedTowardsPoint( hitPosition, 90 ) )
			{	
				parent.ActionRotateToAsync( hitPosition );	
				return GetHitEventName_t0();
			}
			else
			{
				return 'c_hit_back';
			}
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
				CombatBurnStartMage();
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
				CombatBurnEndMage();
			return true;
		}
		else
		{
			return false;
		}
	}
	
	entry function CombatBurnStartMage()
	{
		parent.GetBehTreeMachine().Stop();
		HitEvent(BCH_HitBurn);
		
	}
	entry function CombatBurnEndMage()
	{
		HitEvent(BCH_HitBurn_End);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}
};
