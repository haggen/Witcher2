/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Dead state fro NPC
/** Copyright © 2009
/***********************************************************************/

state Incapacitated in CNewNPC extends Base
{
	event OnEnterState()
	{
		super.OnEnterState();
		parent.PlayVoiceset( 100, "on_axii" );
		parent.ActivateBehavior( 'npc_exploration' );
	}
	
	event OnLeaveState()
	{
		super.OnLeaveState();
		parent.PlayVoiceset( 100, "axii_recovery" );
	}

	entry function StateIncapacitated( duration : float, wandering : bool, goalId : int )
	{
		var prevTime : float = 0;
		var afterTime : float = 0;
		var diff : float = 0;
		var infiniteStateWait : bool = false;
		
		SetGoalId( goalId );
		
		//LogChannel( 'rython', "ENTER ---------" );
		
		if ( duration == -1 )
		{
			infiniteStateWait = true;
		}

		while ( duration > 0 || infiniteStateWait )
		{
			prevTime = EngineTimeToFloat( theGame.GetEngineTime() );
			//LogChannel( 'rython', "Prev: " + seconds );
			
			if ( wandering )
			{
				Wander();
			}
			else
			{
				Sleep( 0.1 );
			}
			
			afterTime = EngineTimeToFloat( theGame.GetEngineTime() );
			//LogChannel( 'rython', "Post: " + a );
			diff = afterTime - prevTime;
			//LogChannel( 'rython', "Difference: " + diff );
			
			//LogChannel( 'rython', "* Duration prev: " + duration );
			duration -= diff;
			//LogChannel( 'rython', "* Duration post: " + duration );
		}
		
		//LogChannel( 'rython', "EXIT ---------" );

		MarkGoalFinished();
	}
	
	private latent function Wander()
	{
		var target, navMeshPos : Vector;
		target = parent.FindRandomPosition();
		if( parent.GetMovingAgentComponent().GetEndOfLineNavMeshPosition( target, navMeshPos ) )
		{
			parent.ActionMoveTo( navMeshPos, MT_Walk, 1.0, 2.0 );								
		}
	}
};
