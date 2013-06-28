/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Critical effect states
/** Copyright © 2010
/***********************************************************************/

///////////////////////////////////////////////////////////////////////
state Burn in CNewNPC extends Base
{
	event OnEnterState()
	{
		if(thePlayer.IsInCombat() && VecDistance(parent.GetWorldPosition(), thePlayer.GetWorldPosition()) < 25.0)
		{
			parent.AddTimer('KeepCombatTimer', 1.0, true);
		}
		super.OnEnterState();
		parent.SetBehaviorVariable( "CriticalState", (int)CST_Burn );
	}

	event OnLeaveState()
	{
		parent.RemoveTimer('KeepCombatTimer');
		super.OnLeaveState();
		//parent.ActivateBehavior('npc_exploration');
		HitEvent(BCH_HitBurn_End);
		parent.SetBehaviorVariable( "CriticalState", (int)CST_None );
	}
	final function HitEvent(hitEvent : W2BehaviorCombatHit) : bool
	{
		var hitEventInt : int;
		parent.StartsWithCombatIdle(false);
		hitEventInt = (int)hitEvent;
		parent.SetBehaviorVariable("HitEnum", (float)hitEventInt);
		return parent.RaiseForceEvent('Hit');
	}
	entry function StateBurn( goalId : int )
	{
		var pos, navMeshPos : Vector;
		SetGoalId( goalId );
		HitEvent(BCH_HitBurn);
	}
}

///////////////////////////////////////////////////////////////////////
state Knockdown in CNewNPC extends Base
{
	var wasInCombat : bool;
	event OnEnterState()
	{
		if(thePlayer.IsInCombat() && VecDistance(parent.GetWorldPosition(), thePlayer.GetWorldPosition()) < 25.0)
		{
			parent.AddTimer('KeepCombatTimer', 1.0, true);
		}
		super.OnEnterState();
		virtual_parent.SetBehaviorVariable( "CriticalState", (int)CST_Knockdown );
	}
	function SetWasInCombat(flag : bool)
	{
		wasInCombat = flag;
	}
	event OnLeaveState()
	{
		parent.RemoveTimer('KeepCombatTimer');
		super.OnLeaveState();		
		if( !virtual_parent.RaiseEvent('KnockdownFinish') )
		{
			virtual_parent.RaiseForceEvent('Idle');
		}
		virtual_parent.SetBlockingHit(false);
		
		virtual_parent.SetBehaviorVariable( "CriticalState", (int)CST_None );
	}
	event OnCriticalEffectStop( effectType : ECriticalEffectType )
	{
		if(effectType == CET_Knockdown && wasInCombat)
		{
			KnockDownEnd();
			return true;
		}
		else
		{
			return false;
		}
	}
	event OnBeingHitCriticalEffect(out hitParams : HitParams)
	{
		if(hitParams.attacker != thePlayer)
			return true;
		if(virtual_parent.IsMonster())
		{
			hitParams.outDamageMultiplier = 10.0;
			return true;
		}
		if(virtual_parent.IsKnockedDown() && !hitParams.groupAttack && virtual_parent.CanBeFinishedOff(hitParams.attacker))
		{
			//thePlayer.HideNearbyEnemies(30.0, 3.0, virtual_parent);				
			theGame.GetCSTakedown().OnCSTakedown_1ManDown( virtual_parent );
			return false;
		}
		else if(virtual_parent.IsKnockedDown() && !hitParams.groupAttack )
		{
			hitParams.outDamageMultiplier = hitParams.outDamageMultiplier + 2;
			return true;
		}
		else
		{
			return virtual_parent.OnBeingHit( hitParams );
		}
	}
	entry function KnockDownEnd()
	{
		parent.SetKnockedDown(false);
		HitEvent(BCH_KnockdownEnd);
		Sleep(0.1);
		parent.WaitForBehaviorNodeDeactivation('HitEnd');
		MarkGoalFinished();
	}
	final function HitEvent(hitEvent : W2BehaviorCombatHit)
	{
		var hitEventInt : int;
		parent.StartsWithCombatIdle(false);
		hitEventInt = (int)hitEvent;
		virtual_parent.SetBehaviorVariable("HitEnum", (float)hitEventInt);
		virtual_parent.RaiseForceEvent('Hit');
	}
	entry function StateKnockdown( goalId : int, combat : bool )
	{	
		var res : bool;
		parent.SetKnockedDown(true);
		SetWasInCombat(combat);
		SetGoalId( goalId );
		//parent.CantBlockCooldown();
		virtual_parent.ActionCancelAll();
		if(wasInCombat)
		{
			HitEvent(BCH_Knockdown);
		}
		else
		{
			res = virtual_parent.RaiseForceEvent('Knockdown');	
		}
		
	}
}

///////////////////////////////////////////////////////////////////////
state Falter in CNewNPC extends Base
{
	event OnEnterState()
	{
		super.OnEnterState();
		parent.SetBehaviorVariable( "CriticalState", (int)CST_Falter );
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();		
		if( !parent.RaiseEvent('KnockdownFinish') )
		{
			parent.RaiseForceEvent('Idle');
		}
		parent.SetBlockingHit(false);
		
		parent.SetBehaviorVariable( "CriticalState", (int)CST_None );
	}
		

	entry function StateFalter( goalId : int )
	{	
		var res : bool;
		SetGoalId( goalId );
		
		//parent.SetBlockingHit(true, 30.0);
		parent.ActionCancelAll();
		res = parent.RaiseForceEvent('Knockdown');		
		Log("");
	}
}

///////////////////////////////////////////////////////////////////////
state Blind in CNewNPC extends Base
{
	var indicator : CEntity;
	
	event OnEnterState()
	{
		super.OnEnterState();
		parent.SetBehaviorVariable( "CriticalState", (int)CST_Blind );
		
		parent.ClearRotationTarget();
		parent.RaiseForceEvent( 'Idle' );
	}
	
	event OnLeaveState()
	{
		indicator.StopEffect( 'blind_fx' );
		parent.AddTimer( 'DestroyIndicator', 2.0f, false );
		super.OnLeaveState();
		//parent.ActivateBehavior('npc_exploration');
		
		parent.SetBehaviorVariable( "CriticalState", (int)CST_None );
	}

	entry function StateBlind( goalId : int )
	{
		var templ : CEntityTemplate;
		var pos : Vector;
		
		SetGoalId( goalId );
		parent.ActionCancelAll();
		
		templ = (CEntityTemplate)LoadResource("gameplay\blind_indicator");
		pos = MatrixGetTranslation( parent.GetBoneWorldMatrix('head') );
		indicator = theGame.CreateEntity( templ, pos );
		indicator.PlayEffect( 'blind_fx' );
	}
	
	timer function DestroyIndicator( time : float )
	{
		indicator.Destroy();
	}
}

///////////////////////////////////////////////////////////////////////
state Unbalance in CNewNPC extends Base
{
	event OnEnterState()
	{
		super.OnEnterState();
		parent.SetBehaviorVariable( "CriticalState", (int)CST_Unbalance );
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();		
		if ( !parent.RaiseEvent('UnbalanceFinish') )
		{
			parent.RaiseForceEvent('Idle');
		}
		parent.SetBlockingHit( false );
		
		parent.SetBehaviorVariable( "CriticalState", (int)CST_None );
	}

	entry function StateUnbalance( goalId : int )
	{
		var res : bool;
		
		SetGoalId( goalId );
		
		parent.SetBlockingHit( true, 30.0 );
		parent.ActionCancelAll();
		res = parent.RaiseForceEvent('Unbalance');
	}
}

///////////////////////////////////////////////////////////////////////
state Disorientation in CNewNPC extends Base
{
	event OnEnterState()
	{
		if(thePlayer.IsInCombat() && VecDistance(parent.GetWorldPosition(), thePlayer.GetWorldPosition()) < 25.0)
		{
			parent.AddTimer('KeepCombatTimer', 1.0, true);
		}
		super.OnEnterState();
		parent.SetBehaviorVariable( "CriticalState", (int)CST_Drunk );
	}
	
	event OnLeaveState()
	{
		parent.RemoveTimer('KeepCombatTimer');
		super.OnLeaveState();
		//parent.ActivateBehavior('npc_exploration');
		
		parent.SetBehaviorVariable( "CriticalState", (int)CST_None );
	}

	entry function StateDisorientation( goalId : int )
	{
		var pos, navMeshPos : Vector;
		SetGoalId( goalId );
		
		parent.ActivateBehavior( 'npc_panic' );
		
		while( 1 )
		{
			pos = parent.FindRandomPosition();
			if( pos != parent.GetWorldPosition() )
			{
				if( parent.GetMovingAgentComponent().GetEndOfLineNavMeshPosition(pos, navMeshPos) )
				{
					parent.ActionMoveTo( navMeshPos, MT_Walk, 1.0, 3.0 );
				}
			}
			Sleep(0.1);
		}
	}
}

///////////////////////////////////////////////////////////////////////
state Stun in CNewNPC extends Base
{

	var wasInCombat : bool;
	event OnEnterState()
	{
		if(thePlayer.IsInCombat() && VecDistance(parent.GetWorldPosition(), thePlayer.GetWorldPosition()) < 25.0)
		{
			parent.AddTimer('KeepCombatTimer', 1.0, true);
		}
		super.OnEnterState();
		virtual_parent.SetBehaviorVariable( "CriticalState", (int)CST_Knockdown );
	}
	function SetWasInCombat(flag : bool)
	{
		wasInCombat = flag;
	}
	event OnLeaveState()
	{
		parent.RemoveTimer('KeepCombatTimer');
		super.OnLeaveState();		
		if( !virtual_parent.RaiseEvent('StunEnd') )
		{
			virtual_parent.RaiseForceEvent('Idle');
		}
		virtual_parent.SetBlockingHit(false);
		
		virtual_parent.SetBehaviorVariable( "CriticalState", (int)CST_None );
	}
	event OnCriticalEffectStop( effectType : ECriticalEffectType )
	{
		if(effectType == CET_Stun && wasInCombat)
		{
			StunEnd();
			return true;
		}
		else
		{
			return false;
		}
	}
	event OnBeingHitCriticalEffect(out hitParams : HitParams)
	{
		if(hitParams.attacker != thePlayer)
			return true;
		if(!hitParams.groupAttack && virtual_parent.CanBeFinishedOff(hitParams.attacker))
		{
			//thePlayer.HideNearbyEnemies(30.0, 3.0, virtual_parent);				
			theGame.GetCSTakedown().OnCSTakedown_1Man( virtual_parent, false );
			return false;
		}
		else
		{
			return virtual_parent.OnBeingHit( hitParams );
		}
	}
	entry function StunEnd()
	{
		if(!virtual_parent.IsMonster())
		{
			parent.SetKnockedDown(false);
			HitEvent(BCH_StunEnd);
			Sleep(0.1);
			parent.WaitForBehaviorNodeDeactivation('HitEnd');
		}
		else
		{
			parent.RaiseForceEvent('Idle');
		}
		MarkGoalFinished();
	}
	final function HitEvent(hitEvent : W2BehaviorCombatHit)
	{
		var hitEventInt : int;
		parent.StartsWithCombatIdle(false);
		hitEventInt = (int)hitEvent;
		virtual_parent.SetBehaviorVariable("HitEnum", (float)hitEventInt);
		virtual_parent.RaiseForceEvent('Hit');
	}
	entry function StateStun( goalId : int, combat : bool )
	{	
		var res : bool;
		//parent.SetKnockedDown(true);
		SetWasInCombat(combat);
		SetGoalId( goalId );
		//parent.CantBlockCooldown();
		virtual_parent.ActionCancelAll();

		//theHud.m_hud.ShowTutorial("tut02", "tut02_333x166", true); // <-- tutorial content is present in external tutorial - disabled
		//theHud.ShowTutorialPanelOld( "tut02", "tut02_333x166" );
		
		if(wasInCombat)
		{
			HitEvent(BCH_Stun);
		}
		else
		{
			res = virtual_parent.RaiseForceEvent('Knockdown');	
		}
		
	}	
}

///////////////////////////////////////////////////////////////////////
state Immobile in CNewNPC extends Base
{
	event OnEnterState()
	{
		super.OnEnterState();
		parent.ClearRotationTarget();
		parent.RaiseForceEvent( 'Idle' );
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();		
		parent.SetBehaviorVariable( "CriticalState", (int)CST_None );
	}

	entry function StateImmobile( goalId : int )
	{
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();		
		parent.SetBehaviorVariable( "CriticalState", (int)CST_Immobile );
		
		parent.RaiseForceEvent( 'Axii_front' );
		Sleep(4.0);
		parent.RaiseForceEvent( 'Idle' );
	}
}

///////////////////////////////////////////////////////////////////////
state Fear in CNewNPC extends Base
{
	event OnEnterState()
	{
		super.OnEnterState();
		parent.SetBehaviorVariable( "CriticalState", (int)CST_Fear );
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		//parent.ActivateBehavior('npc_exploration');
		
		if ( !parent.RaiseEvent('FearFinish') )
		{
			parent.RaiseForceEvent('Idle');
		}
		
		parent.SetBehaviorVariable( "CriticalState", (int)CST_None );
	}
	function GotToCombat()
	{
		var params : SCombatParams;
		parent.EnterCombat(params);
	}
	event OnBeingHit(hitParams : HitParams)
	{
		GotToCombat();
		return true;
	}
	event OnBeingHitPosition(hitParams : HitParams)
	{
		GotToCombat();
		return true;
	}
	entry function StateFear( goalId : int )
	{
		var pos, navMeshPos : Vector;
		var i : int;
		SetGoalId( goalId );
		
		parent.RaiseForceEvent('Idle');
		while(true)
		{
			for ( i = 0; i < 5; i += 1 ) // the number of trials
			{
				pos = parent.FindRandomPosition();
				if ( pos != parent.GetWorldPosition() )
				{
					if ( parent.GetMovingAgentComponent().GetEndOfLineNavMeshPosition(pos, navMeshPos) )
					{
						parent.ActionMoveTo( navMeshPos, MT_Run, 1.0, 3.0 );
						break;
					}
				}
			}
			Sleep( 3.0 );
		}
	}
}
