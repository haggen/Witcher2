/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Object classes exprots
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Generic component 
/////////////////////////////////////////////

import class CComponent extends CNode
{
	// Get entity that owns this component
	import final function GetEntity() : CEntity;
	
	// Is component enabled
	import final function IsEnabled() : bool;
	
	// Set component enabled
	import final function SetEnabled( flag : bool );
	
	// Set local-space position. PLEASE use with caution.
	import final function SetPosition( position : Vector );
	
	// Set local-space rotation. PLEASE use with caution.
	import final function SetRotation( rotation : EulerAngles );
	
	// Set local-space scale. PLEASE use with caution.
	import final function SetScale( scale : Vector );
}

/////////////////////////////////////////////
// Animated component
/////////////////////////////////////////////

import class CAnimatedComponent extends CComponent
{
	// Activate behavior graph instances
	import final function ActivateBehaviors( names : array< name > ) : bool;
	
	// Attach behavior graph
	import final function AttachBehavior( instanceName : name ) : bool;
	
	// Detach behavior graph
	import final function DetachBehavior( instanceName : name ) : bool;
	
	// Get behavior float variable
	import final function GetBehaviorVariable( varName : string ) : float;
	
	// Get behavior vector variable
	import final function GetBehaviorVectorVariable( varName : string ) : Vector;
	
	// Set behavior float variable
	import final function SetBehaviorVariable( varName : string, varValue : float ): bool;
	
	// Set behavior vector variable
	import final function SetBehaviorVectorVariable( varName : string, varValue : Vector ) : bool;
	
	// Activate behavior animation constraint with dynamic target, return true if activation was success
	import final function ActivateDynamicAnimatedConstraint( target : CNode, activationVariableName : string, variableToControlName : string, optional timeout : float ) : bool;
	
	// Activate behavior animation constraint with static target, return true if activation was success
	import final function ActivateStaticAnimatedConstraint( target : Vector, activationVariableName : string, variableToControlName : string, optional timeout : float ) : bool;
	
	// Activate behavior animation constraint with actor's bone target, return true if activation was success
	import final function ActivateBoneAnimatedConstraint( target : CEntity, bone : string, activationVariableName : string, variableToControlName : string,
							optional useOffset : bool /* = false */, optional offsetMatrix : Matrix /* = IDENTITY */, optional timeout : float /* = 0.0f */ ) : bool;
	
	// Deactivate behavior animation constraint
	import final function DeactivateAnimatedConstraint( activationVariableName : string ) : bool;
	
	// Has behavior animation constraint
	import final function HasAnimatedConstraint( activationVariableName : string ) : bool;

	// Display skeleton
	import final function DisplaySkeleton( bone : bool, optional axis : bool, optional names : bool );
	
	// Get animation time multiplier of this actor
	import final function GetAnimationTimeMultiplier() : float;
	
	// Set animation time multiplier of this actor
	import final function SetAnimationTimeMultiplier( mult : float );
	
	// Get absolute move speed
	import final function GetMoveSpeedAbs() : float;
	
	// Get bone world matrix by name
	import final function GetBoneMatrixWorldSpace( bone : name ) : Matrix;

	// Raise behavior event
	import final function RaiseBehaviorEvent( eventName : name ) : bool;
	
	// Raise behavior force event
	import final function RaiseBehaviorForceEvent( eventName : name ) : bool;
	
	// Apply linear impulse to ragdoll rigid body (directly - use this when ragdoll is dynamic - at least one frame after turning it on)
	// Pass -1 as the index to apply impulse on all bodies.
	import final function ApplyLinearImpulse( rigidBodyIndex : int, impulse : Vector );
	
	// Apply impulse to the ragdoll rigid body (via behavior - use this in the same frame you turn the ragdoll on)
	import final function SetRootBoneImpulse( impulse : Vector );
	
	// Set can stick to meshes
	import final function SetCanStickToMesh( rigidBodyName : name );
	
	// Returns true if body is sticked to the mesh
	import final function IsStickedToMesh() : bool;
	
	// Returns the 0-indexed bone world position
	import final function GetCenterOfMassWorldPos( out position : Vector ) : bool;
	
	// Resets angular and linear velocity of all rigid bodies to zero
	import final function ResetRigidBodiesVelocity();
	
	// Find bone nearest to given world-space position, and return bone index. Bone position will be written back to 'position' argument.
	import final function FindNearestBoneWS( out position : Vector, out distance : float ) : int; 
	
	// Get bone name
	import final function GetBoneName( index : int ) : name;
}

/////////////////////////////////////////////
// Component with bounds
/////////////////////////////////////////////

import class CBoundedComponent extends CComponent
{
	// Gets component's bounding box
	import final function GetBoundingBox() : Box;
}

/////////////////////////////////////////////
// Component that can be drawn
/////////////////////////////////////////////

import class CDrawableComponent extends CBoundedComponent
{
	// Is component visible
	import final function IsVisible() : bool;
	
	// Set component visible
	import final function SetVisible( flag : bool );

	// Changes gameplay parameter ( used for highlighting )
//	import final function SetGameplayParameter( paramIdx : int, enable : bool, changeTime : float );
}

/////////////////////////////////////////////
// Sprite component
/////////////////////////////////////////////

import class CSpriteComponent extends CComponent
{
}

/////////////////////////////////////////////
// Generic waypoint component
/////////////////////////////////////////////

import class CWayPointComponent extends CSpriteComponent 
{
}

/////////////////////////////////////////////
// Area environment component
/////////////////////////////////////////////

// Activate area anvironment with given name
import function AreaEnvironmentActivate( areaEnvName : string );

// Deactivate area anvironment with given name
import function AreaEnvironmentDeactivate( areaEnvName : string );

// Stabilizes area environments blending
import function AreaEnvironmentStabilize( );


/////////////////////////////////////////////
// Environment
/////////////////////////////////////////////

// Weather
import function GetRainStrength() : float;
import function GetWeatherType() : EWeatherType;

import function ForceFakeEnvTime( hour : float );
import function DisableFakeEnvTime();

import function ForceConvergence( convergence : float );
import function DisableForceConvergence();

import function EnableDarkMode();
import function DisableDarkMode();

