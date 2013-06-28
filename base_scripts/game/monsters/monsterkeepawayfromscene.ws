/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2010
/***********************************************************************/

state KeepAwayFromScene in W2Monster extends Base
{
	event OnLeaveState()
	{
		super.OnLeaveState();
	}

	entry function StateKeepAwayFromScene( goalId : int, sceneCenter : Vector, sceneRadius : float )
	{	
		var res : bool;
		SetGoalId( goalId );
		
		TeleportOutOfScene( sceneCenter, sceneRadius );

		while ( true )
		{
			Sleep( 1.0 );
			
			// exit state condition
			if ( thePlayer.GetCurrentStateName() != 'Scene' )
			{
				break;
			}
		}
		
		MarkGoalFinished();
	}
	
	function TeleportOutOfScene( sceneCenter : Vector, sceneRadius : float )
	{
		var pos : Vector;
		var radius : float;
		var teleportPos : Vector;
		
		pos = parent.GetWorldPosition() - sceneCenter;
		pos = VecNormalize( pos );
		pos = sceneCenter + (pos * (sceneRadius * 1.5));
		
		radius = sceneRadius * 0.5;
		
		if ( GetFreeReachablePoint( pos, radius, teleportPos ) )
		{
			parent.Teleport( teleportPos );
		}
	}
}
