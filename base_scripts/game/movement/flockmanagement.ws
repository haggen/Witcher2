/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Flock steering management
/** Copyright © 2011 
/***********************************************************************/

// ------------------------------------------------------------------------
// Default FlockManager implementation
// ------------------------------------------------------------------------

import class CDefaultFlockManager extends CObject
{
	// All members of the flock
	import var flockMembers : array<CActor>;
	
	// Radius in which flock members affect each other
	import var radius		: float;
	
	
	// Get desired separation vector for flock member that keeps him in distance from other flock mates
	import function GetSeparationVector( agent : CMovingAgentComponent ) : Vector;

	// Get desired cohesion vector for flock member that keeps him together with his co members
	import function GetCohesionVector( agent : CMovingAgentComponent ) : Vector;

	// Get desired alignment vector for flock member that specifies common velocity for all members
	import function GetAlignmentVector( agent : CMovingAgentComponent ) : Vector;
	
	// Get center of the flock based on positions of all members
	import function GetFlockCenterPosition() : Vector;
}

class CFlockTRGScript extends CMoveTRGScript
{
	private var flockManager : CDefaultFlockManager;
	var currentAction : int;
	
	function UpdateChannels( out goal : SMoveLocomotionGoal )
	{
		var heading		: float;
		var newHeading	: Vector;
		
		SetFulfilled( goal, false );
		
		switch( currentAction )
		{
			case 0:
				flockManager.radius = 2.0f;
				newHeading = flockManager.GetSeparationVector( agent );
				break;
			case 1:
				flockManager.radius = 5.0f;
				newHeading = flockManager.GetCohesionVector( agent );
				break;
			case 2:
				flockManager.radius = 10.0f;
				newHeading = flockManager.GetAlignmentVector( agent );
				break;
		}
		
		heading = VecHeading( newHeading );
		
		SetHeadingGoal( goal, newHeading );
		SetOrientationGoal( goal, heading );
		SetSpeedGoal( goal, 2.f );
	}
}

exec function FlockTest( action : int )
{
	var actors : array<CActor>;
	var i, size : int;
	var flockManager : CDefaultFlockManager;
	var trg : CFlockTRGScript;
	
	flockManager = new CDefaultFlockManager in theGame;
	
	theGame.GetActorsByTag( 'chicken', actors );
	size = actors.Size();
	for( i = 0; i < size; i += 1 )
	{
		flockManager.flockMembers.PushBack( actors[i] );
	}
	
	for( i = 0; i < size; i += 1 )
	{
		trg = new CFlockTRGScript in actors[i];
		trg.flockManager = flockManager;
		trg.currentAction = action;
		actors[i].ActionMoveCustomAsync( trg );
	}
}