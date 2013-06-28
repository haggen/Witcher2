/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Locomotion API
/** Copyright © 2011 
/***********************************************************************/

// ----------------------------------------------------------------------
// Locomotion goal manipulation
// ----------------------------------------------------------------------

import struct SMoveLocomotionGoal {};


// ----------------------------------------------------------------------
// Movement targetter
// ----------------------------------------------------------------------
import class CMoveTRGScript extends CObject
{
	import var agent 				: CMovingAgentComponent;
	import var timeDelta			: float;
	
	// Called in order to update the movement goal's channels
	abstract function UpdateChannels( out goal : SMoveLocomotionGoal );
	
	// Heading goal value -- where direction should the agent go.
	import function SetHeadingGoal( out goal : SMoveLocomotionGoal, heading : Vector );

	// Orientation goal value - what direction should the agent be facing. 
	// The 'alwaysSet' flag determines if the goal should
	// never be considered fulfilled ( when set to 'true' )
	import function SetOrientationGoal( out goal : SMoveLocomotionGoal, orientation : float, optional alwaysSet : bool );

	// Speed goal value - how fast should the agent be moving.
	import function SetSpeedGoal( out goal : SMoveLocomotionGoal, speed : float );

	// How long is the agent allowed to stand idly before the movement segment is considered failed.
	import function SetMaxWaitTime( out goal : SMoveLocomotionGoal, time : float );

	// When changing facing, should the agent change movement direction as well? Or should
	// the two be treated separately?
	import function MatchDirectionWithOrientation( out goal : SMoveLocomotionGoal, enable : bool );
	
	// Tells whether the targeter's goal has been fulfilled. Since there may be many targeters
	// working together, the flag is set using the AND boolean test - meaning that 
	// if called once with false, will invalidate all other targeters 'true' declarations.
	import function SetFulfilled( out goal : SMoveLocomotionGoal, isFulfilled : bool );
	
	// ----------------------------------------------------------------------
	// Steering API
	// ----------------------------------------------------------------------
	
	import final function Seek( pos : Vector ) : Vector;
	import final function Flee( pos : Vector ) : Vector;
	import final function Pursue( agent : CMovingAgentComponent ) : Vector;
	import final function FaceTarget( pos : Vector ) : Vector;
};