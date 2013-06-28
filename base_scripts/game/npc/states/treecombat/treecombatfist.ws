/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** TreeCombatSword
/** Copyright © 2010
/***********************************************************************/

/////////////////////////////////////////////
// TreeCombatSword state
/////////////////////////////////////////////
state TreeCombatFist in CNewNPC extends TreeCombatStandard
{	
	private var normalCombatRadius : float;
	private var wasAttackableByPlayer : bool;

	event OnEnterState()
	{
		var combatEvents : W2CombatEvents;
		var id : SItemUniqueId;
		super.OnEnterState();
		
		normalCombatRadius = parent.GetMovingAgentComponent().GetCombatWalkAroundRadius();
		parent.GetMovingAgentComponent().SetCombatWalkAroundRadius( 0.6 );
		
		parent.SetCombatSlotOffset(1.3);
		parent.EmptyHands();
		id = parent.GetInventory().GetFirstNonLethalWeaponId();
		if( id != GetInvalidUniqueId() )
		{
			parent.DrawWeaponInstant(id);
		}
		

		if( parent.CreateCombatEventsProxy( CECT_NPCFist ) )
		{
			combatEvents = parent.GetCombatEventsProxy().GetCombatEvents();
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack1);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack2);
			combatEvents.attackEnums.PushBack(BCA_MeleeAttack3);
			
			combatEvents.hitLightEnums.PushBack(BCH_HitFast1);
			
			combatEvents.idleEnums.PushBack(BCI_Idle1);
		}
		
		parent.GetMovingAgentComponent().EnableCombatMode( false );
	}
	
	event OnLeaveState()
	{
		parent.GetMovingAgentComponent().SetCombatWalkAroundRadius( normalCombatRadius );
		super.OnLeaveState();
		
		if( combatParams.fistfightArea )
		{
			parent.SetImmortalityModeRuntime( AIM_None );
			parent.SetAttackableByPlayerRuntime( true );
		}
	}
	
	event OnAnimEvent( animEventName : name, animEventTime : float, animEventType : EAnimationEventType )
	{	
		var damage : float;
		if( animEventName == 'FF_Hit' )
		{			
			damage = 20;
			damage = MinF( parent.GetHealth() - 5, damage );
			parent.DecreaseHealth( damage, false, parent );		
		}
		else if( animEventName == 'Hit_fx' )		
		{
			parent.PlayEffect('fistfight_strong');
		}
		else
		{
			super.OnAnimEvent( animEventName, animEventTime, animEventType );
		}
	}
	
	entry function TreeCombatFist( params : SCombatParams )	
	{
		combatParams = params;
		parent.GetBehTreeMachine().Stop();
		ExitWork();
		ActivateCombatBehavior( params, 'npc_fistfight' );
		LoadTree( params, true );				
		virtual_parent.BeforeCombat();
		parent.GetBehTreeMachine().Restart();
		if( params.fistfightArea )
		{
			parent.SetImmortalityModeRuntime( AIM_Invulnerable, 100000 );
			parent.SetAttackableByPlayerRuntime( false, 100000 );
		}
	}
	
	private function GetDefaultTreeAlias() : string
	{		
		return "behtree\combat_fist";
	}
	
	// Hit event
	event OnHit( hitParams : HitParams )
	{		
		var eventEnum : W2BehaviorCombatHit;		
		TreeDelayedCombatRestart();
		if( parent.IsAlive() )
		{
			eventEnum = GetHitLightEnum();
			HitEvent(eventEnum);
		}
	}
		
	event OnBeingHit( out hitParams : HitParams )
	{
		// If can block block, and return false to stop hit processing		
		if( parent.IsBlockingHit() )
		{	
			return false;
		}
		
		return true;
	}

}
