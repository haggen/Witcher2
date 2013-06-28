/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 CD Projekt RED
/***********************************************************************/

// Black room is a special streaming construct for act 3
class W2BlackRoom extends CEntity
{
	private editable var blackRoomWayPoint : name;
	private editable var targetPartition : string;
	private editable var targetWayPoint : name;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var blackRoomPos : Vector;
		var targetPos : Vector;
		var targetRot : EulerAngles;
		var node : CNode;
		
		if ( activator.GetEntity() == thePlayer )
		{
			// Find black room waypoint
			node = theGame.GetNodeByTag( blackRoomWayPoint );
			if ( !node )
			{
				Log( "ERROR: No black room waypoint of tag '" + blackRoomWayPoint + "'" );
				return false;
			}
			
			// Get position of blackroom node
			blackRoomPos = node.GetWorldPosition();
		
			// Find black room waypoint
			node = theGame.GetNodeByTag( targetWayPoint );
			if ( !node )
			{
				Log( "ERROR: No black room waypoint of tag '" + targetWayPoint + "'" );
				return false;
			}
			
			// Get position of target node
			targetPos = node.GetWorldPosition();
			targetRot = node.GetWorldRotation();

			// Go there	
			Log( "Blackrooming to partition '" + targetPartition + "' via blackroom '" + blackRoomWayPoint + "' and exiting at '" + targetWayPoint + "'" );
			Transit( blackRoomPos, targetPos, targetRot, targetPartition );
			
		}		
	}	
}

// Transition state
state Transition in W2BlackRoom
{
	entry function Transit( blackRoomPos : Vector, targetPos : Vector, targetRot : EulerAngles, targetPartition : string )
	{
		var waitedTime : float;
		
		// Fade out
		theGame.FadeOut();
			
		// Teleport player to blackroom
		thePlayer.Teleport( blackRoomPos );
			
		// Start streaming of target location
		theGame.StreamWorldPartition( targetPartition );

		// Fade back in		
		theGame.FadeIn();
		
		// Wait for streaming to finish
		while ( waitedTime < 30.0 && theGame.IsStreaming() )
		{
			// Wait for a second more
			waitedTime += 1.0;
			Sleep( 1.0f );
		}
		
		// Wait at least a 3s
		if ( waitedTime < 3.0 )
		{
			Sleep( 3.0 - waitedTime );
		}
		
		// Fade back to black
		theGame.FadeOut();
			
		// Teleport player to final location
		thePlayer.TeleportWithRotation( targetPos, targetRot );

		// Force load target location
		theGame.LoadWorldPartition( targetPartition );

		// Final fade in			
		theGame.FadeIn();
	}	
}

