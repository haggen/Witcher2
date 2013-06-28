/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Trap Induced States
/***********************************************************************/

//state frozen for creatures when freezing trap is triggered in a proximity

/*state Frozen in CNewNPC extends Base
{
	var initialHealth : float;

	event OnEnterState()
	{
		super.OnEnterState();
	
		parent.ChangeNpcExplorationBehavior();
		
		parent.ClearRotationTarget();
		parent.RaiseForceEvent( 'Idle' );
		//parent.RaiseForceEvent( 'Freeze' );
		//parent.SetBodyState( 'select', true );
		initialHealth = parent.health;
		parent.health = 12;
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.ClearUnconscious();
		if( parent.GetHealth() > 0 )
		{
			parent.health = initialHealth;
		}
	}

	entry function EnterFrozen( time : float )
	{
		parent.GetArbitrator().ClearAllGoals();
	
		Sleep( time );
		
		parent.RaiseForceEvent( 'Idle' );
		parent.GetArbitrator().AddGoalIdle( true );
	}
}*/

/* STAN PLAYERA POWINIEN BYC W KATALOGU PLAYER W RAMACH STANOW PLAYERA!!!
// state trapped on witcher, when he enters animal trap
state Trapped in CPlayer extends Base
{
	event OnEnterState()
	{
		super.OnEnterState();
		parent.RaiseForceEvent( 'Idle' );
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
	}

	entry function EnterTrapped( time : float )
	{
		Sleep( time );
		parent.RaiseForceEvent( 'Idle' );
	}
}*/

//state grappled for a creature when it triggers grappling trap

/*state Grappled in CNewNPC extends Base
{
	var initialHealth : float;

	event OnEnterState()
	{
		super.OnEnterState();
		parent.ClearRotationTarget();
		parent.RaiseForceEvent( 'Grappled' );
		
		initialHealth = parent.health;
		
		if( parent.HasTag( 'enemy_big' ) )
		{
			parent.health = 35;
		}
		else
		{
			parent.health = 12;
		}
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.ClearUnconscious();
		if( parent.GetHealth() > 0 )
		{
			parent.health = initialHealth;
		}
		parent.RaiseForceEvent( 'RipChains' );
	}

	entry function EnterGrappled( time : float )
	{
		if( parent.HasTag( 'enemy_big' ) )
		{
			Sleep( time / 2 );
		}
		else
		{
			Sleep( time );
		}
		parent.RaiseForceEvent( 'Idle' );
		parent.StateIdle();	
	}
}*/

/*
//state ragging for a creatures caught in proximity of triggered rage trap

state Raging in CNewNPC extends Base
{
	event OnEnterState()
	{
		super.OnEnterState();
		//parent.ClearRotationTarget();
		//parent.RaiseForceEvent( 'Raging' );
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		//parent.RaiseForceEvent( 'Calming' );
		parent.SetAttitude( thePlayer, AIA_Hostile );
	}


}
*/