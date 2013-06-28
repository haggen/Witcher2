/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CMovingAgentComponent
/** Copyright © 2010
/***********************************************************************/

/*enum EPathEngineEmptySpaceCollision
{
	PEESC_NavMesh,
	PEESC_SceneObstacles,
	PEESC_PlayerObstaclesNonActors,
	PEESC_PlayerObstacles,
};*/

import struct SPathEngineEmptySpaceQuery
{
	import var width : float;						//< Area width
	import var height : float;						//< Area height
	import var yaw : float;							//< Yaw (-1.0 means agent yaw for first (zero) test, and random for further tests)
	import var searchRadius : float;				//< Search radius
	import var localSearchRadius : float;			//< Local search radius for away path
	import var maxPathLen : float;					//< Max length of path to center of area
	import var maxCenterLevelDifference : float;	//< Max level difference to current position
	import var maxAreaLevelDifference : float;		//< Max difference inside area
	import var numTests : int;						//< Number of tests (+1 for agent position)
	import var checkObstaclesLevel : EPathEngineEmptySpaceCollision;	//< Check obstacles level in area test
	import var useAwayMethod : bool;				//< Path away method of center search
	import var debug : bool;						//< Debug draw
};

import class CMovingAgentComponent extends CAnimatedComponent
{
	// Sets maximum move rotation speed [deg/s]
	import final function SetMaxMoveRotationPerSec( rotSpeed : float );
	
	// Sets maximum move type
	import final function SetMoveType( moveType : EMoveType );
	
	// Find empty space ( returns -1.0 on error or width of found area )
	import final latent function FindEmptySpace( params : SPathEngineEmptySpaceQuery, out outNavMeshPos : Vector, out outYaw : float ) : float;

	// Get effective move speed returned from behavior
	import final function GetCurrentMoveSpeedAbs() : float;
	
	// Teleport actor behind the camera and optionaly continue movement
	import final function TeleportBehindCamera( continueMovement : bool ) : bool;
	
	// Enable combat movement mode
	import final function EnableCombatMode( combat : bool ) : bool;
	
	// Enable combat movement mode
	import final function GetCombatWalkAroundRadius() : float;
	
	// Enable combat movement mode
	import final function SetCombatWalkAroundRadius( radius : float );
	
	// Test if agent may move straight to given destination
	import final function CanGoStraightToDestination( destination : Vector ) : bool;
	
	// Test if the specified position is valid in terms of being located on a navmesh
	// and not being obstructed
	import final function IsPositionValid( position : Vector ) : bool;
	
	// Returns the line end point's navmesh position.
	import final function GetEndOfLineNavMeshPosition( pos : Vector, out outPos : Vector ) : bool;
	
	// Checks if one can reach the specified position in a straight line without
	// bumping into anything
	import final function IsEndOfLinePositionValid( position : Vector ) : bool;
	
	// Checks if the specified position is in the same room as the agent
	import final function IsInSameRoom( position : Vector ) : bool;
	
	// Toggle enabled, restore agent to stored position
	final function SetEnabledRestorePosition( enabled : bool ) : bool
	{
		SetEnabled( enabled );
		if( enabled )
		{
			return IsEnabled();
		}
		else
		{
			return false;
		}
	}
	
	// Returns the current speed (scalar) of the agent
	import final function GetSpeed() : float;
	
	// Returns the maximum speed of the agent
	import final function GetMaxSpeed() : float;
	
	// Returns agent's current velocity
	import final function GetVelocity() : Vector;
	
	// Returns agent's position with respect to its active representation
	import final function GetAgentPosition() : Vector;
}


import class CMovingPhysicalAgentComponent extends CMovingAgentComponent
{
	// Is physical movement enabled
	import final function IsPhysicalMovementEnabled() : bool;
}

import class CActionAreaComponent extends CTriggerAreaComponent
{
}
