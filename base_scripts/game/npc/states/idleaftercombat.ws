/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Idle after combat state
/** Copyright © 2010
/***********************************************************************/

state IdleAfterCombat in CNewNPC extends Idle
{
	event OnEnterState()
	{
		if(!virtual_parent.IsMonster() && !virtual_parent.IsBoss())
		{
			if(virtual_parent.HasCombatType(CT_Sword) || virtual_parent.HasCombatType(CT_Sword_Skilled))
			{
				virtual_parent.IssueRequiredItems( 'None', 'opponent_weapon' );
			}
			else if(virtual_parent.HasCombatType(CT_Bow) || virtual_parent.HasCombatType(CT_Bow_Walking))
			{
				virtual_parent.IssueRequiredItems( 'opponent_bow', 'None' );
			}
			else if(virtual_parent.HasCombatType(CT_ShieldSword))
			{
				virtual_parent.IssueRequiredItems( 'opponent_shield', 'opponent_weapon' );
			}
			else if(virtual_parent.HasCombatType(CT_TwoHanded))
			{
				virtual_parent.IssueRequiredItems( 'None', 'opponent_weapon' );
			}
			else if(virtual_parent.HasCombatType(CT_Dual))
			{
				virtual_parent.IssueRequiredItems( 'opponent_weapon', 'opponent_weapon_secondary' );
			}
			else if(virtual_parent.HasCombatType(CT_Dual_Assasin))
			{
				virtual_parent.IssueRequiredItems( 'opponent_weapon', 'opponent_weapon_secondary' );
			}
			else if(virtual_parent.HasCombatType(CT_Mage))
			{
				virtual_parent.IssueRequiredItems('None', 'opponent_weapon');
			}
			else if(virtual_parent.HasCombatType(CT_Halberd))
			{
				virtual_parent.IssueRequiredItems('None', 'opponent_weapon_polearm');
			}
		}
		virtual_parent.ActionCancelAll();
	}

	event OnLeaveState()
	{
		/*var itemId, mageStaff : SItemUniqueId;
		itemId = parent.GetCurrentWeapon( CH_Right );		
		if( itemId != GetInvalidUniqueId() )
		{
			if(parent.HasCombatType(CT_Mage))
			{
				if(!parent.GetArbitrator().HasCurrentGoalOfClass( 'CAIGoalQuestActing' ))
				{
					mageStaff = parent.GetInventory().GetItemByCategory('opponent_weapon', true);
					if(mageStaff == GetInvalidUniqueId())
					mageStaff = parent.GetInventory().GetItemByCategory('steelsword', true);
					parent.GetInventory().UnmountItem(mageStaff, true);
				}
			}
			else
			{
				parent.HolsterWeaponInstant( itemId );
			}
		}
		
		itemId = parent.GetCurrentWeapon( CH_Left );		
		if( itemId != GetInvalidUniqueId() )
		{
			parent.HolsterWeaponInstant( itemId );
		}*/
		super.OnLeaveState();
	}
	
	event OnMovementCollision( pusher : CMovingAgentComponent )
	{
		// can always slide along
		return true;
	}
	
	event OnPushed( pusher : CMovingAgentComponent )
	{
		parent.PushAway( pusher );
	}

	entry function StateIdleAfterCombat( time : float, goalId : int )
	{
		var endTime : EngineTime;
		var enumInt : int;
		var harpy : CHarpie;
		SetGoalId( goalId );
	
		harpy = (CHarpie)parent;
		if(harpy)
		{
			if(!harpy.IsGrounded())
			{
				harpy.SetGrounded(true);
				harpy.RaiseForceEvent('ToLand');
				Sleep(0.1);
				
				harpy.WaitForBehaviorNodeDeactivation('ToLand', 5.0);
				harpy.ActivateBehavior( 'grounded_harpie' );
				harpy.SetSpawnAnim(SA_Idle);
			}
		}
		
		if(!virtual_parent.IsMonster() && !virtual_parent.IsBoss())
		{
			if(virtual_parent.HasCombatType(CT_Sword) || virtual_parent.HasCombatType(CT_Sword_Skilled))
			{
				virtual_parent.ActivateAndSyncBehavior('npc_sword' );
			}
			else if(virtual_parent.HasCombatType(CT_Bow) || virtual_parent.HasCombatType(CT_Bow_Walking))
			{
				if ( virtual_parent.GetInventory().ItemHasTag( virtual_parent.GetInventory().GetItemByCategory('opponent_bow'), 'Crossbow' ) )
				{
					virtual_parent.ActivateAndSyncBehavior('npc_crossbow' );
				}
				else
				{
					virtual_parent.ActivateAndSyncBehavior('npc_bow' );
				}
			}
			else if(virtual_parent.HasCombatType(CT_ShieldSword))
			{
				virtual_parent.ActivateAndSyncBehavior('npc_shield' );
			}
			else if(virtual_parent.HasCombatType(CT_TwoHanded))
			{
				virtual_parent.ActivateAndSyncBehavior('npc_twohanded' );
			}
			else if(virtual_parent.HasCombatType(CT_Dual))
			{
				virtual_parent.ActivateAndSyncBehavior('npc_dual' );
			}
			else if(virtual_parent.HasCombatType(CT_Dual_Assasin))
			{
				virtual_parent.ActivateAndSyncBehavior('npc_dual' );
				enumInt = (int)DCE_Assasin;
				virtual_parent.SetBehaviorVariable("DualEnum", (float)enumInt);
			}
			else if(virtual_parent.HasCombatType(CT_Mage))
			{
				virtual_parent.ActivateAndSyncBehavior('npc_mage' );
			}
			else if(virtual_parent.HasCombatType(CT_Halberd))
			{
				virtual_parent.ActivateAndSyncBehavior('npc_polearm' );
			}
		}
		parent.ClearRotationTarget();
		parent.RaiseForceEvent('Idle');
		
		endTime = theGame.GetEngineTime() + time;
		while( theGame.GetEngineTime() < endTime || ( parent.GetGuardArea() && parent.GetGuardArea().MayWander() ) )
		{
			if( parent.GetArea() )
			{
				AreaIdle();
			}
			Sleep(3.0f);
		}
		parent.SetRequiredItems( 'None', 'None' );	
		parent.ProcessRequiredItems();
		MarkGoalFinished();
	}
};