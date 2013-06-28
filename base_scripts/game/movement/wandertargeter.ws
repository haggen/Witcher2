/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Wandering movement targeter
/** Copyright © 2011
/***********************************************************************/

class CMoveTRGWander extends CMoveTRGScript
{
	private var		headingChangeCooldown : float;
	default headingChangeCooldown		= 2.0;
	
	// Called in order to update the movement goal's channels
	function UpdateChannels( out goal : SMoveLocomotionGoal )
	{
		var heading				: float;
		var newHeading 			: Vector;
		var headingChange 		: float;
		var checkPos 			: Vector;
		var npc 				: CNewNPC;
		var bb 					: CBlackboard;
	
		SetFulfilled( goal, false );	
		
		npc = (CNewNPC)agent.GetEntity();
		if ( !npc )
		{
			return;
		}
		
		bb = npc.GetLocalBlackboard();
		if ( !bb )
		{
			return;
		}
		
		bb.GetEntryFloat( 'wanderHeading', heading );
		headingChangeCooldown -= timeDelta;
		if ( headingChangeCooldown < 0 )
		{		
			headingChange = RandRangeF( 30.0, 60.0 );
			if ( RandRangeF( -1.0, 1.0 ) < 0 )
			{
				headingChange *= -1;
			}
			heading = heading  + headingChange;
			
			headingChangeCooldown = RandRangeF( 0.5, 2.0 );

			newHeading = VecFromHeading( heading );
			
			checkPos = agent.GetAgentPosition() + newHeading * 2.0;
			if ( agent.CanGoStraightToDestination( checkPos ) == false )
			{
				heading = 180 - heading;
				newHeading = VecFromHeading( heading );
			}
			bb.AddEntryFloat( 'wanderHeading', heading );
		}
		else
		{
			newHeading = VecFromHeading( heading );
		}
		
		SetHeadingGoal( goal, newHeading );
		SetOrientationGoal( goal, heading );
	}
};
