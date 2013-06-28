/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

state TreeCombatBruxa in W2MonsterBruxa extends TreeCombatMonster
{		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
	// Teleportation
	var petardEntity : CAreaOfEffect;
	var petardPosition : Vector;
	var spawnTmpl, despawnTmpl : CEntityTemplate;
	// Bomb
	var bombPosition : Vector;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		var itemId : SItemUniqueId;

		super.OnEnterState();

		parent.DrawWeaponInstant(parent.GetInventory().GetFirstLethalWeaponId());	
		
		if( parent.CreateCombatEventsProxy( CECT_Bruxa ) )
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
			
			//Hits
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast2);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast3);
			combatEvents.hitLightEnums.PushBack(BCH_HitFast4);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong1);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong2);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong3);
			combatEvents.hitHeavyEnums.PushBack(BCH_HitStrong4);
			
			//Dodge
			combatEvents.dodgeBackEnums.PushBack(BCH_DodgeBack1);
			combatEvents.dodgeBackEnums.PushBack(BCH_DodgeBack2);
			
			//Combat Idle
			combatEvents.idleEnums.PushBack(BCI_Idle1);
			combatEvents.idleEnums.PushBack(BCI_Idle2);
		}		
		
		parent.SetCombatSlotOffset(1.9);
		
		
		itemId = parent.GetInventory().GetItemByCategory( 'monster_weapon', false );
		parent.DrawWeaponInstant( itemId );
		itemId = parent.GetInventory().GetItemByCategory( 'monster_weapon_secondary', false );
		parent.DrawWeaponInstant( itemId );
	}
	
	event OnLeaveState()
	{
		var leftHandItem, rightHandItem : SItemUniqueId;
		super.OnLeaveState();
		parent.ClearAttackTarget();
		if(!parent.IsAlive())
		{
			parent.PlayEffect('death_fx');
			parent.StopEffect('default_fx');
			//theGame.CreateEntity(despawnTmpl, parent.GetWorldPosition(), parent.GetWorldRotation());
			leftHandItem = parent.GetInventory().GetItemByCategory('monster_weapon_secondary', true, false);
			rightHandItem = parent.GetInventory().GetItemByCategory('monster_weapon', true, false);
			if(leftHandItem != GetInvalidUniqueId())
				parent.GetInventory().UnmountItem(leftHandItem, true);
			if(rightHandItem != GetInvalidUniqueId())
				parent.GetInventory().DropItem(rightHandItem, true);
		}
	}
	
	
	entry function TreeCombatBruxa( params : SCombatParams )
	{
		spawnTmpl = (CEntityTemplate)LoadResource("fx\bruxa\spawn");
		despawnTmpl = (CEntityTemplate)LoadResource("fx\wraith\despawn");
		LoadTree( params );
	}
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\bruxa";
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{
		if( animEventType == AET_Tick && animEventName == 'Attack' || animEventName == 'Attack_t1' || animEventName == 'Attack_t2' || animEventName == 'Attack_t3')
		{	
			parent.SetAttackTarget(parent.GetTarget());
			Attack( animEventName );			
		}
		else
		{
			super.OnAnimEvent(animEventName, animEventTime, animEventType);
		}

	}
				
	event OnBeingHit( out hitParams : HitParams )
	{
		return !parent.IsBlockingHit();
	}
	
	event OnAttackTell( hitParams : HitParams )
	{
		if( hitParams.attackType == 'StrongSwing')
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
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{		

		if( parent.IsAlive() )
		{
			if(parent.IsStrongAttack(hitParams.attackType))
			{
				HitStrongBruxa();
			}
			else
			{
				HitFastBruxa();
			}
		}
		
		//Log( parent.GetName()+" OnHit "+hitParams.attackType+" "+EngineTimeToString( theGame.GetEngineTime()) );
	}
	
	event OnAardHitReaction( CWitcherSignAard : CWitcherSignAard )
	{
		if(parent.AardKnockdownChance())
		{
			if(!parent.ApplyCriticalEffect(CET_Stun, NULL, 0, true) && !parent.ApplyCriticalEffect(CET_Knockdown, NULL, 0, true))
			{
				AardReactionBruxa();
			}
		}
		else
		{
			AardReactionBruxa();
		}
	}
	
	entry function AardReactionBruxa()
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
	
	entry function HitFastBruxa()
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
	entry function HitStrongBruxa()
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
