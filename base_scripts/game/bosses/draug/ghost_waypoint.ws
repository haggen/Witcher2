
class CGhostWaypoint extends CEntity
{
	var manager 					: CGhostManager;
	var ghostInWaypoint 			: CEntity;
	var disappearEffectTime 		: float;
	
	default disappearEffectTime 	= 1.0;
	
	function Initialize( manager : CGhostManager )
	{
		this.manager = manager;
	}
	
	// Mark the waypoint as one that doesn't need a ghost.
	// BY DEX: DO NOT CHANGE THE NAME OR FORMAT OF THIS FUNCTION, used in a hacky way by C++
	// BY DEX: DO NOT CHANGE THE NAME OR FORMAT OF THIS FUNCTION, used in a hacky way by C++
	// BY DEX: DO NOT CHANGE THE NAME OR FORMAT OF THIS FUNCTION, used in a hacky way by C++
	// BY DEX: DO NOT CHANGE THE NAME OR FORMAT OF THIS FUNCTION, used in a hacky way by C++
	function FreeWaypoint()
	{
		if ( ghostInWaypoint )
		{
			ghostInWaypoint.PlayEffect('disappear');
			ghostInWaypoint.StopEffect('appear');
			this.AddTimer( 'WaypointUpdate', disappearEffectTime, false );
		}
	}
	
	// Process the despawn of a ghost
	timer function WaypointUpdate(timeDelta : float)
	{
		RemoveTimer( 'WaypointUpdate' );
		if ( ghostInWaypoint )
		{
			manager.DespawnGhost( this, ghostInWaypoint );
			ghostInWaypoint = NULL;
		}
	}
	
	// Populate the waypoint with a ghost, if there's one available
	// BY DEX: DO NOT CHANGE THE NAME OR FORMAT OF THIS FUNCTION, used in a hacky way by C++
	// BY DEX: DO NOT CHANGE THE NAME OR FORMAT OF THIS FUNCTION, used in a hacky way by C++
	// BY DEX: DO NOT CHANGE THE NAME OR FORMAT OF THIS FUNCTION, used in a hacky way by C++
	// BY DEX: DO NOT CHANGE THE NAME OR FORMAT OF THIS FUNCTION, used in a hacky way by C++
	function PopulateWaypoint()
	{
		if( !ghostInWaypoint )
		{
			ghostInWaypoint = manager.GetFreeGhost();
	
			if( ghostInWaypoint )
			{
				ghostInWaypoint.PlayEffect('appear');
				ghostInWaypoint.TeleportWithRotation( this.GetWorldPosition(), this.GetWorldRotation() );
			}
		}
	}
}