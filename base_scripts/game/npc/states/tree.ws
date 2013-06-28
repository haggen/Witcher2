/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Behavior Tree state
/** Copyright © 2009
/***********************************************************************/

state Tree in CNewNPC extends ReactingBase
{
	var started : bool;
	var m_canBePushed : bool;
	
	event OnEnterState()
	{	
		// Avoid action cancelling
		//super.OnEnterState();
		m_canBePushed = true;
		started	= false;
	}
	
	event OnLeaveState()
	{
		parent.GetBehTreeMachine().Stop();
		parent.GetBehTreeMachine().Uninitialize();
		
		parent.SetFocusedNode( NULL );
		parent.SetFocusedPostion( Vector( 0, 0, 0, 0 ) );
	}
	
	event OnMovementCollision( pusher : CMovingAgentComponent )
	{
		// can't slide along other agents
		return false;
	}
	
	event OnPushed( pusher : CMovingAgentComponent )
	{
		if ( m_canBePushed )
		{
			parent.PushAway( pusher );
		}
	}
	
	entry function StateTree( treeRes : string, persistentRef : PersistentRef, processOnce : bool, timeout : float, exitWorkMode : EExitWorkMode, canBePushed : bool, goalId : int )
	{
		var machine : CBehTreeMachine;
		var tree : CBehTree;
		var entity : CEntity;
		var pos : Vector;
		
		m_canBePushed = canBePushed;
		SetGoalId( goalId );
		
		parent.ChangeNpcExplorationBehavior();

		entity = PersistentRefGetEntity( persistentRef );		
		if( entity )
		{
			parent.SetFocusedNode( entity );
		}
		else
		{
			pos = PersistentRefGetWorldPosition( persistentRef );
			parent.SetFocusedPostion( pos );
		}
		
		machine = parent.GetBehTreeMachine();
		
		// Stop if already running
		machine.Stop();
		machine.Uninitialize();
		
		parent.ExitWork( exitWorkMode );
		
		// Initialize new tree
		tree = (CBehTree)LoadResource( treeRes );	
		machine.Initialize( tree );		
		machine.Restart( processOnce );
		started = true;
		
		if ( timeout > 0.f ) // if timeout is defined, return to idle when it passed
		{
			Sleep( timeout );
			MarkGoalFinished();
		}
	}
	
	event OnBehTreeEnded()
	{
		if( started )
		{
			MarkGoalFinished();		
		}
	}
}
