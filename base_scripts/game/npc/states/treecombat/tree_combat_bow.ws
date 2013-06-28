/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Bow combat
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// TreeCombatBow state
/////////////////////////////////////////////
state TreeCombatBow in CNewNPC extends TreeCombatStandard
{
	var attackIndex, size : int;
	var crossbow : bool;
	var rangedWeapon : SItemUniqueId;
	var hitParams  : HitParams;
	var projectileItemId : SItemUniqueId;
	default crossbow = false;
	default attackIndex = 0;
		
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		var i : int;		

		super.OnEnterState();	
		
		parent.ActionCancelAll();
		
		parent.SetRequiredItems( 'opponent_bow', 'None' );
		
		parent.SetSuperblock( false );
		
		if( parent.CreateCombatEventsProxy( CECT_NPCBow ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();	
			combatEvents.attackEnums.PushBack(BCA_Special1);
			combatEvents.attackEnums.PushBack(BCA_Special2);
			
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
		
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast3);

		}
	}

	event OnLeaveState()
	{
		var fakeProjectile : SItemUniqueId;
		fakeProjectile = parent.GetInventory().GetItemByCategory('projectile', true);
		if(fakeProjectile != GetInvalidUniqueId())
			parent.GetInventory().UnmountItem(fakeProjectile, true);
		super.OnLeaveState();
		parent.RemoveTimer('BlockRelease');
		parent.SetBlockingHit(false);
		
	}
	
	// Attack has been blocked
	event OnAttackBlocked( hitParams : HitParams )
	{
		AttackBlockedBow();
	}
	
	entry function AttackBlockedBow()
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
	entry function TreeCombatBow( params : SCombatParams )	
	{
		var weaponId : SItemUniqueId;

		SetCanPlayDamageAnim(false, 2.0);
		combatParams = params;
		parent.GetBehTreeMachine().Stop();	


		weaponId = parent.GetInventory().GetItemByCategory( 'opponent_bow', false );
		if ( weaponId == GetInvalidUniqueId() )
		{
			Log( "NPC " + parent.GetName() + " has no ranged weapon!" );
		}
		else if ( parent.GetInventory().ItemHasTag( weaponId, 'Crossbow' ) )
		{
			crossbow = true;
		}	
		
		
		if(crossbow)
		{
			ActivateCombatBehavior( params, 'npc_crossbow' );
		}
		else
		{
			ActivateCombatBehavior( params, 'npc_bow' );
		}

		LoadTree( params );
		SetCanPlayDamageAnim(true, 0.0);
		parent.GetBehTreeMachine().Restart();

	}
	
	private function GetDefaultTreeAlias() : string
	{
		if(parent.HasTag('arena_wingman'))
		{
			return "behtree\arena_dwarf_crb";
		}
		else if(parent.HasCombatType(CT_Bow_Walking))
		{
			return "behtree\combat_bowman";
		}
		else
		{
			return "behtree\combat_bowman_static";
		} 
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{		
		var target : CActor = parent.GetTarget();
	
		if( animEventName == 'Attack' )
		{	
			DespawnProjectile();		
			ShootProjectile( target );
		}
		else if( animEventName == 'Projectile_Spawn' )
		{
			SpawnProjectile();
		}
		else
		{	
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}	
	}
	
	function SpawnProjectile()
	{
		var inv : CInventoryComponent = parent.GetInventory();		

		if(crossbow)
		{
			inv.AddItem('fake_bolt');
			projectileItemId = inv.GetItemId( 'fake_bolt' );
			inv.MountItem(projectileItemId);		
		}
		else
		{
			inv.AddItem('fake_arrow');
			projectileItemId = inv.GetItemId( 'fake_arrow' );
			inv.MountItem(projectileItemId);		
		}		


	}
	
	function DespawnProjectile()
	{
		var inv : CInventoryComponent = parent.GetInventory();	
		inv.UnmountItem( projectileItemId );
		inv.RemoveItem( projectileItemId );
	}
	
	function ShootProjectile( target : CActor )
	{
		var bowmanToTargetVec, movementDirection, arrowTarget, targetPosition, parentPosition : Vector;
		var targetZ, shooterZ, translation, movementMult : float;
		var ent : CEntity;
		var normal : EulerAngles;
		var proj : CRegularProjectile;
		var itemId : SItemUniqueId;
		var inventory : CInventoryComponent = parent.GetInventory();
		var targetSpeed, arrowSpeed, distanceToTarget : float;
		var shotAccuracy : float;
		shotAccuracy = parent.GetCharacterStats().GetAttribute('shot_accuracy');
		if(shotAccuracy <= 0.1)
		{
			shotAccuracy = 0.1;
		}
		itemId = parent.GetInventory().GetItemByCategory( 'projectile', false );
		
		/*if( itemId == GetInvalidUniqueId() )
		{
			parent.GetInventory().AddItem('Arrow',1);
			itemId = parent.GetInventory().GetItemByTag('Arrow');
		}*/
		
		ent = inventory.GetDeploymentItemEntity(itemId, parent.GetWorldPosition() + Vector( 0.0, 0.0, 1.3, 0.0 ), parent.GetWorldRotation() );
		proj = (CRegularProjectile)ent;
		if( proj )
		{
			targetPosition = target.GetWorldPosition();
			parentPosition = parent.GetWorldPosition();
			proj.Init( parent );
			parent.SetAttackTarget( target );
			proj.PlayEffect( 'trail_fx' );
			targetZ = 1+targetPosition.Z;
			shooterZ = 1+parentPosition.Z;
			translation = AbsF(targetZ-shooterZ) + 2.0;
			if(translation > 3.0)
			{
				translation = 0.0;
			}
			else
			{
				translation = 6.0;
			}
			bowmanToTargetVec = translation*VecNormalize(target.GetWorldPosition() - parent.GetWorldPosition());
			distanceToTarget = VecDistance2D(target.GetWorldPosition(), parent.GetWorldPosition());
			if(distanceToTarget <= 15.0)
			{
				//ShotAccuracy raises in close attack range
				shotAccuracy = shotAccuracy * 1.5;
			}
			if(distanceToTarget > 25.0)
			{
				//ShotAccuracy drops with attack distance
				shotAccuracy = shotAccuracy*0.75;
			}
			if(distanceToTarget > 50.0)
			{
				//ShotAccuracy drops with attack distance
				shotAccuracy = shotAccuracy*0.75;
			}
			if(distanceToTarget > 75.0)
			{
				//ShotAccuracy drops with attack distance
				shotAccuracy = shotAccuracy*0.5;
			}
			if(target.GetMovingAgentComponent().GetMoveSpeedAbs() > 0.75)
			{
				proj.SetProjectileRandomSpeed();
				targetSpeed = 5.0;
				arrowSpeed = proj.GetProjectileSpeed();
				movementDirection = VecFromHeading(target.GetHeading());
				movementMult = (targetSpeed*distanceToTarget) / arrowSpeed;
				arrowTarget = target.GetWorldPosition() + movementDirection*movementMult;	
				if(RandF() > shotAccuracy)
				{
					//Miss
					arrowTarget += VecRingRand(3.0, 4.0);
				}
			}
			else
			{
				arrowTarget = target.GetWorldPosition();
				
				//Target adjustment for better visuals
				arrowTarget += bowmanToTargetVec;
				
				//Non moving target raises the hit chance
				if(RandF() > 3.0*shotAccuracy)
				{
					//Miss
					arrowTarget += VecRingRand(0.0, 3.0);
				}
			}
			theGame.GetWorld().PointProjectionTest(arrowTarget, normal, 3.0);
			proj.Start( NULL, arrowTarget, false, 7.0 );
		}
		else
		{
			Log("ERROR: ShootProjectile no entity");
		}
	}
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{			
		if( parent.IsAlive() )
		{
			if(CanPlayDamageAnim())
			{
				BowDamage(hitParams);
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
		var params : SCombatParams;
		if(hitParams.attacker)
		{
			if(VecDistanceSquared(hitParams.attacker.GetWorldPosition(), parent.GetWorldPosition()) < 36.0)
			{
				if(parent.HasCombatType(CT_Sword) || parent.HasCombatType(CT_Sword_Skilled))
				{
					parent.TreeCombatSword(params);
				}
				else if(parent.HasCombatType(CT_TwoHanded))
				{
					parent.TreeCombatTwoHanded(params);
				}
				else if(parent.HasCombatType(CT_Dual) || parent.HasCombatType(CT_Dual_Assasin))
				{
					parent.TreeCombatDual(params);
				}
			}
		}
		if(theGame.GetDifficultyLevel()==0)
		{	
			return true;
		}
		else if(parent.IsRotatedTowardsPoint( hitParams.hitPosition, 90 ))
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
			AxiiReactionBow();
	}
	event OnAxiiHitResult(axii : CWitcherSignAxii, success : bool)
	{
			AxiiReactionBowResult(success);
	}
	entry function AxiiReactionBow()
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
	entry function AxiiReactionBowResult(success : bool)
	{
		var berserkDuration : float;
		
		parent.GetBehTreeMachine().Stop();
		parent.CantBlockCooldown(2.0);
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
		parent.GetBehTreeMachine().Restart();
	}			
	event OnYrdenHitReaction( yrden : CWitcherSignYrden)
	{
		if(CanPlayDamageAnim())
			YrdenReactionBow(yrden);
	}
	entry function YrdenReactionBow(yrden : CWitcherSignYrden)
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
					BowAardReactionHit();
			}
		}
		else
		{
			if(CanPlayDamageAnim())
				BowAardReactionHit();
		}
	}
	entry function BowAardReactionHit()
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
			parent.CombatBurnStartBow();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
		}	
	}
	function BowDamage( hitParams : HitParams )
	{
		HitFastBow();
	}
	entry function HitFastBow()
	{
		parent.GetBehTreeMachine().Stop();
		parent.SetAttackTarget( parent.GetTarget() );
		HitEvent(GetHitLightEnum());
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation ( 'HitEnd' );
		if(parent.IsCriticalEffectApplied(CET_Burn))
		{
			parent.CombatBurnStartBow();
		}
		else
		{
			parent.GetBehTreeMachine().Restart();
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
				CombatBurnStartBow();
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
				CombatBurnEndBow();
			return true;
		}
		else
		{
			return false;
		}
	}
	
	entry function CombatBurnStartBow()
	{
		parent.GetBehTreeMachine().Stop();
		HitEvent(BCH_HitBurn);
		
	}
	entry function CombatBurnEndBow()
	{
		HitEvent(BCH_HitBurn_End);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		parent.GetBehTreeMachine().Restart();
	}	
}
